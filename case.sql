-- Selecionando o banco de dados
use uber;

SET SQL_SAFE_UPDATES = 0;

-- Verificando a estrutura dos dados
SELECT `Date`, `Booking Value`, `Ride Distance`
FROM ride_bookings;

-- Alterando o tipo dos dados
ALTER TABLE ride_bookings
MODIFY `Customer ID` VARCHAR (50),
MODIFY `Date` DATE,
MODIFY `Booking Value` INT,
MODIFY `Booking ID` VARCHAR(50),
MODIFY `Incomplete Rides` INT,
MODIFY `Ride Distance` DECIMAL (10,2),
MODIFY `Driver Ratings` INT,
MODIFY `customer Rating` INT;

-- Verificando o tipo dos dados nas colunas
DESCRIBE ride_bookings;


-- Analisando a presença de valores nulos
SELECT
    COUNT(*) AS total_registros,
    SUM(CASE WHEN `Date` IS NULL THEN 1 ELSE 0 END) AS Date_nulos,
    SUM(CASE WHEN `Time` IS NULL THEN 1 ELSE 0 END) AS Time_nulos,
    SUM(CASE WHEN `Booking ID` IS NULL THEN 1 ELSE 0 END) AS BookingID_nulos,
    SUM(CASE WHEN `Booking Status` IS NULL THEN 1 ELSE 0 END) AS BookingStatus_nulos,
    SUM(CASE WHEN `Customer ID` IS NULL THEN 1 ELSE 0 END) AS CustomerID_nulos,
    SUM(CASE WHEN `Vehicle Type` IS NULL THEN 1 ELSE 0 END) AS VehicleType_nulos,
    SUM(CASE WHEN `Pickup Location` IS NULL THEN 1 ELSE 0 END) AS PickupLocation_nulos,
    SUM(CASE WHEN `Drop Location` IS NULL THEN 1 ELSE 0 END) AS DropLocation_nulos,
    SUM(CASE WHEN `Avg VTAT` IS NULL THEN 1 ELSE 0 END) AS AvgVTAT_nulos,
    SUM(CASE WHEN `Avg CTAT` IS NULL THEN 1 ELSE 0 END) AS AvgCTAT_nulos,
    SUM(CASE WHEN `Cancelled Rides by Customer` IS NULL THEN 1 ELSE 0 END) AS CancelledRidesCustomer_nulos,
    SUM(CASE WHEN `Reason for cancelling by Customer` IS NULL THEN 1 ELSE 0 END) AS ReasonCancelledCustomer_nulos,
    SUM(CASE WHEN `Cancelled Rides by Driver` IS NULL THEN 1 ELSE 0 END) AS CancelledRidesDriver_nulos,
    SUM(CASE WHEN `Driver Cancellation Reason` IS NULL THEN 1 ELSE 0 END) AS DriverCancellationReason_nulos,
    SUM(CASE WHEN `Incomplete Rides` IS NULL THEN 1 ELSE 0 END) AS IncompleteRides_nulos,
    SUM(CASE WHEN `Incomplete Rides Reason` IS NULL THEN 1 ELSE 0 END) AS IncompleteRidesReason_nulos,
    SUM(CASE WHEN `Booking Value` IS NULL THEN 1 ELSE 0 END) AS BookingValue_nulos,
    SUM(CASE WHEN `Ride Distance` IS NULL THEN 1 ELSE 0 END) AS RideDistance_nulos,
    SUM(CASE WHEN `Driver Ratings` IS NULL THEN 1 ELSE 0 END) AS DriverRatings_nulos,
    SUM(CASE WHEN `Customer Rating` IS NULL THEN 1 ELSE 0 END) AS CustomerRating_nulos,
    SUM(CASE WHEN `Payment Method` IS NULL THEN 1 ELSE 0 END) AS PaymentMethod_nulos
FROM ride_bookings;

-- Criar novas colunas
ALTER TABLE ride_bookings
ADD COLUMN Avg_VTAT_tratado DECIMAL(10,2),
ADD COLUMN Avg_CTAT_tratado DECIMAL(10,2);

-- Atualizar com os valores substituídos pela média
UPDATE ride_bookings
SET Avg_VTAT_tratado = COALESCE(`Avg VTAT`, (SELECT AVG(`Avg VTAT`) FROM (SELECT * FROM ride_bookings) AS t WHERE `Avg VTAT` IS NOT NULL)),
    Avg_CTAT_tratado = COALESCE(`Avg CTAT`, (SELECT AVG(`Avg CTAT`) FROM (SELECT * FROM ride_bookings) AS t WHERE `Avg CTAT` IS NOT NULL));


SHOW COLUMNS FROM ride_bookings;

-- Removendo colunas que já sofreram tratamento
ALTER TABLE ride_bookings
DROP COLUMN `Avg VTAT`,
DROP COLUMN `Avg CTAT`;


select * from ride_bookings;
 

 -- Tratando colunas com valores nulls
 SELECT
  *,
  COALESCE(`Cancelled Rides by Customer`,0) AS Cancelled_Rides_Customer_tratado,
  COALESCE(`Cancelled Rides by Driver`,0) AS Cancelled_Rides_Driver_tratado,
  COALESCE(`Incomplete Rides`, 0) AS Incomplete_Rides_tratado,
  COALESCE(`Reason for cancelling by Customer`, 'Não aplicável') AS Reason_Cancel_Customer_tratado,
  COALESCE(`Driver Cancellation Reason`, 'Não aplicável') AS Driver_Cancel_Reason_tratado,
  COALESCE(`Incomplete Rides Reason`, 'Não aplicável') AS Incomplete_Rides_Reason_tratado
FROM ride_bookings;
 
 select * from ride_bookings;
 
 -- Atualizando a base de dados original com a substituição de valores nulos
UPDATE ride_bookings
SET `Cancelled Rides by Customer` = COALESCE(`Cancelled Rides by Customer`, 0),
    `Cancelled Rides by Driver`   = COALESCE(`Cancelled Rides by Driver`, 0),
    `Incomplete Rides`            = COALESCE(`Incomplete Rides`, 0),
    `Reason for cancelling by Customer` = COALESCE(`Reason for cancelling by Customer`, 'Não aplicavel'),
    `Driver Cancellation Reason`  = COALESCE(`Driver Cancellation Reason`, 'Não aplicavel'),
    `Incomplete Rides Reason`     = COALESCE(`Incomplete Rides Reason`, 'Não aplicavel'),
    `Booking Value`               = COALESCE(`Booking Value`, 0),
    `Ride Distance`               = COALESCE(`Ride Distance`, 0),
    `customer Rating`             = COALESCE(`customer Rating`, 0),
    `Driver Ratings`              = COALESCE(`Driver Ratings`,0),
    `Payment Method`              = COALESCE(`Payment Method`, 'Não informado');

     
   -- Verificando a presença de valores nulos nas colunas  
 select * from ride_bookings;
 
 DESCRIBE ride_bookings;


	