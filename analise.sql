-- Análise descritiva - Operacional
USE uber;

-- ====================================================================================================================================
-- 1: Qual nível de classificação mais frequente por status da reserva, clientes com baixa avaliação costumam cancelar mais?
-- ====================================================================================================================================
SELECT 
    CASE 
        WHEN customer_rating <= 2 THEN '1-2'
        WHEN customer_rating <= 4 THEN '3-4'
        ELSE '5'
    END AS faixa_rating,
    booking_status,
    COUNT(customer_rating) AS total_avaliacoes,
    ROUND(COUNT(customer_rating) * 100.0 / SUM(COUNT(customer_rating)) OVER (), 2) AS porcentagem
FROM rides
GROUP BY 
    CASE 
        WHEN customer_rating <= 2 THEN '1-2'
        WHEN customer_rating <= 4 THEN '3-4'
        ELSE '5'
    END,
    booking_status
ORDER BY total_avaliacoes DESC;

-- Distribuição de avaliações por status

SELECT
    booking_status,
    COUNT(customer_rating) AS total_avaliacoes,
    ROUND(COUNT(customer_rating) * 100.0 / SUM(COUNT(customer_rating)) OVER (), 2) AS porcentagem
FROM rides
GROUP BY booking_status
ORDER BY total_avaliacoes DESC;


-- ====================================================================================================================================
-- 2: Existe preferência entre o tipo de veiculo e o nivél de classificação, quais modelos de carros são mais bem avaliados?  
-- ====================================================================================================================================
SELECT 
    d.vehicle_type,
    AVG(r.customer_rating) AS media_avaliacao,
    COUNT(r.ride_id) AS qtd_corridas
FROM rides r
JOIN drivers d ON r.driver_id = d.driver_id
WHERE r.customer_rating IS NOT NULL
GROUP BY d.vehicle_type
ORDER BY media_avaliacao DESC, qtd_corridas DESC;

	
-- ====================================================================================================================================
-- 3: Qual o nível de satisfação do cliente em relação a distancia percorrida. 
-- ====================================================================================================================================
SELECT 
    CASE
        WHEN ride_distance = 0 THEN '0 km'
        WHEN ride_distance <= 5 THEN '0-5 km'
        WHEN ride_distance <= 10 THEN '6-10 km'
        WHEN ride_distance <= 20 THEN '11-20 km'
        ELSE '20+ km'
    END AS faixa_distancia,
    COUNT(customer_rating) AS contagem_avaliacao,
    AVG(customer_rating) AS media_avaliacao
FROM rides
GROUP BY faixa_distancia
ORDER BY faixa_distancia DESC;

-- ====================================================================================================================================
-- 4: Qual a relação entre o tempo médio de chegada dos motoristas e a duração da viagem em relação ao nível de satisfação do cliente.
-- ====================================================================================================================================
SELECT
  CASE
    WHEN avg_vtat_tratado <= 5  THEN '2-5 minutos'
    WHEN avg_vtat_tratado <= 10 THEN '6-10 minutos'
    WHEN avg_vtat_tratado <= 15 THEN '11-15 minutos'
    ELSE '16-20 minutos'
  END AS faixa_tempo_chegada,
  COUNT(customer_rating) AS contagem_avaliacao,
  AVG(customer_rating)   AS media_avaliacao
FROM rides
WHERE avg_vtat_tratado IS NOT NULL
GROUP BY faixa_tempo_chegada
ORDER BY media_avaliacao DESC;

-- ====================================================================================================================================
-- 5: Quais são as principais motivos de cancelamento feito pelos clientes e motoristas e os principais sinalizadores.
-- ====================================================================================================================================
-- Clientes

SELECT 
    c.reason_customer AS motivo_cancelamento_cliente,
    COUNT(*) AS total_cancelamentos,
    AVG(r.customer_rating) AS media_avaliacao,
    COUNT(r.customer_rating) AS contagem_avaliacao
FROM rides r
JOIN cancellations c ON c.ride_pk = r.ride_pk
WHERE c.cancelled_by_customer = 1
GROUP BY c.reason_customer
ORDER BY total_cancelamentos DESC;

-- Motoristas
SELECT 
    c.reason_driver AS motivo_cancelamento_motoristas,
    COUNT(*) AS total_cancelamentos,
    AVG(r.customer_rating) AS media_avaliacao,
    COUNT(r.customer_rating) AS contagem_avaliacao
FROM rides r
JOIN cancellations c ON c.ride_pk = r.ride_pk
WHERE c.cancelled_by_customer = 1
GROUP BY c.reason_driver
ORDER BY total_cancelamentos DESC;


-- ====================================================================================================================================
-- 6: Corridas mais caras tendem a ser mais canceladas ? qual a média de valores cobrada por corrida, e quais são os métodos de pagamentos mais utilizados.
-- ====================================================================================================================================
SELECT
  CASE
    WHEN booking_value < 20 THEN 'Baixo'
    WHEN booking_value BETWEEN 20 AND 50 THEN 'Médio'
    ELSE 'Alto'
  END AS faixa_valor,
  COUNT(*) AS total_corridas,
  SUM(CASE WHEN booking_status LIKE 'Cancelada%' THEN 1 ELSE 0 END) AS total_canceladas,
  ROUND(SUM(CASE WHEN booking_status LIKE 'Cancelada%' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS taxa_cancelamento
FROM rides
GROUP BY faixa_valor;

-- Métodos de pagamentos
SELECT payment_method, COUNT(*) AS total
FROM rides
GROUP BY payment_method
ORDER BY total DESC;



	
	

