-- ============================================
--  Modelo normalizado + carga a partir de ride_bookings
-- ============================================

USE uber;

-- Limpa em ordem segura para recriar
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS cancellations;
DROP TABLE IF EXISTS rides;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS customers;
SET FOREIGN_KEY_CHECKS = 1;

-- -------------------------
-- Tabela de clientes
-- -------------------------
CREATE TABLE customers (
  customer_id VARCHAR(50) PRIMARY KEY
) ENGINE=InnoDB;

-- -------------------------
-- Tabela de motoristas
-- -------------------------
CREATE TABLE drivers (
  driver_id INT AUTO_INCREMENT PRIMARY KEY,
  vehicle_type VARCHAR(50),
  driver_ratings INT,
  INDEX idx_drivers_vehicle_ratings (vehicle_type, driver_ratings)
) ENGINE=InnoDB;

-- -------------------------
-- Tabela de corridas (fato)
-- PK artificial para evitar conflitos de duplicatas no Booking ID
-- -------------------------
CREATE TABLE rides (
  ride_pk INT AUTO_INCREMENT PRIMARY KEY,      
  ride_id VARCHAR(50),                          
  customer_id VARCHAR(50),
  driver_id INT NULL,
  booking_status TEXT,
  date DATE,
  time TIME,
  pickup_location TEXT,
  drop_location TEXT,
  ride_distance DECIMAL(10,2),
  booking_value DECIMAL(10,2),
  payment_method TEXT,
  customer_rating INT,
  avg_vtat_tratado DECIMAL(10,2),
  avg_ctat_tratado DECIMAL(10,2),

  CONSTRAINT fk_rides_customer  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT fk_rides_driver    FOREIGN KEY (driver_id)   REFERENCES drivers(driver_id),

  INDEX idx_rides_bookingid (ride_id),
  INDEX idx_rides_customer (customer_id),
  INDEX idx_rides_driver   (driver_id)
) ENGINE=InnoDB;

-- -------------------------
-- Tabela de cancelamentos (detalhe)
-- Relacionamento via ride_pk
-- -------------------------
CREATE TABLE cancellations (
  cancellation_id INT AUTO_INCREMENT PRIMARY KEY,
  ride_pk INT NOT NULL,
  cancelled_by_customer BOOLEAN,
  reason_customer TEXT,
  cancelled_by_driver BOOLEAN,
  reason_driver TEXT,
  CONSTRAINT fk_cancellations_rides FOREIGN KEY (ride_pk) REFERENCES rides(ride_pk)
) ENGINE=InnoDB;

-- ============================================
-- Carga dos dados a partir de ride_bookings
-- ============================================

-- 1) Customers
INSERT INTO customers (customer_id)
SELECT DISTINCT `Customer ID`
FROM ride_bookings
WHERE `Customer ID` IS NOT NULL;

-- 2) Drivers
INSERT INTO drivers (vehicle_type, driver_ratings)
SELECT DISTINCT `Vehicle Type`, `Driver Ratings`
FROM ride_bookings
WHERE `Vehicle Type` IS NOT NULL OR `Driver Ratings` IS NOT NULL;

-- 3) Rides
-- Obs.: CAST para TIME lida com coluna Time que está como TEXT na origem.
INSERT INTO rides (
  ride_id, customer_id, driver_id, booking_status,
  date, time, pickup_location, drop_location,
  ride_distance, booking_value, payment_method,
  customer_rating, avg_vtat_tratado, avg_ctat_tratado
)
SELECT
  rb.`Booking ID`,
  rb.`Customer ID`,
  d.driver_id,
  rb.`Booking Status`,
  rb.`Date`,
  CAST(NULLIF(rb.`Time`, '') AS TIME),
  rb.`Pickup Location`,
  rb.`Drop Location`,
  rb.`Ride Distance`,
  rb.`Booking Value`,
  rb.`Payment Method`,
  rb.`customer Rating`,
  rb.`Avg_VTAT_tratado`,
  rb.`Avg_CTAT_tratado`
FROM ride_bookings rb
LEFT JOIN drivers d
  ON rb.`Vehicle Type`   = d.vehicle_type
 AND rb.`Driver Ratings` = d.driver_ratings;

-- 4) Cancellations
INSERT INTO cancellations (
  ride_pk, cancelled_by_customer, reason_customer,
  cancelled_by_driver, reason_driver
)
SELECT
  r.ride_pk,
  CASE WHEN rb.`Cancelled Rides by Customer` IS NOT NULL AND rb.`Cancelled Rides by Customer` <> '' THEN 1 ELSE 0 END,
  rb.`Reason for cancelling by Customer`,
  CASE WHEN rb.`Cancelled Rides by Driver`   IS NOT NULL AND rb.`Cancelled Rides by Driver`   <> '' THEN 1 ELSE 0 END,
  rb.`Driver Cancellation Reason`
FROM ride_bookings rb
JOIN rides r
  ON r.ride_id     = rb.`Booking ID`
 AND r.customer_id = rb.`Customer ID`
 AND r.date        = rb.`Date`;

-- ============================================
SELECT * FROM cancellations;
SELECT * FROM customers;
SELECT * FROM drivers;
SELECT * FROM rides;