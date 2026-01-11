USE retail_sales_db;

-- =====================================================
-- EDA – Objetivo 1: Rendimiento global del negocio
-- =====================================================
-- Contexto: Análisis de ventas de diciembre 2025
-- Queremos entender el tamaño del negocio en el periodo
-- y obtener métricas globales de desempeño.
-- =====================================================

-- -----------------------------------------------------
-- Métrica 1: Total de ventas y total de ingresos
-- -----------------------------------------------------
SELECT
    COUNT(sale_id) AS total_ventas,           -- Número total de ventas en diciembre
    SUM(total_amount) AS ingresos_totales     -- Suma de todos los importes de venta
FROM fact_sales;

-- -----------------------------------------------------
-- Métrica 2: Ticket medio por categoría
-- -----------------------------------------------------
-- Justificación: Los productos tienen rangos de precio muy distintos por categoría.
-- Calcular el promedio por categoría permite entender mejor el comportamiento de ventas por tipo de producto.
SELECT
	dc.category_name AS categoría,
    COUNT(fs.sale_id) AS numero_ventas, 				-- Número de ventas por categoría
    SUM(fs.total_amount) AS total_ventas, 				-- Total facturado por categoría
    ROUND(AVG(fs.total_amount),2) AS precio_medio 		-- Precio medio por categoría
FROM fact_sales fs
JOIN dim_product dm ON fs.product_id = dm.product_id
JOIN dim_category dc ON dm.category_id = dc.category_id
GROUP BY categoría
ORDER BY total_ventas DESC;

-- -----------------------------------------------------
-- Comentarios:
-- - COUNT(sale_id) por categoría indica cuántas transacciones corresponden a cada tipo de producto.
-- - SUM(total_amount) por categoría muestra qué categorías generan más ingresos.
-- - AVG(total_amount) por categoría da un ticket medio representativo de cada grupo de productos, evitando distorsión del global.
-- - Esta información es clave para priorizar promociones, ajustar stock y planificar campañas por categoría.

-- =====================================================
-- OBJETIVO 2: Evaluar el rendimiento por tienda y provincia
-- =====================================================
-- Contexto: Analizamos cuánto vendió cada tienda y provincia en diciembre 2025,
--          y creamos un ranking de tiendas según su facturación.
-- -----------------------------------------------------

-- Selección de ventas por tienda y provincia
SELECT 
    s.store_name,
    p.province_name,
    COUNT(fs.sale_id) AS total_ventas,           -- número de ventas
    SUM(fs.total_amount) AS ingresos_totales,   -- ingresos totales
    RANK() OVER (ORDER BY SUM(fs.total_amount) DESC) AS ranking_tienda  -- ranking por ingresos
FROM fact_sales fs
JOIN dim_store s ON fs.store_id = s.store_id
JOIN dim_province p ON s.province_id = p.province_id
GROUP BY s.store_name, p.province_name
ORDER BY ranking_tienda;

-- 📌 Comentario:
-- Esta consulta nos permite identificar:
-- 1. Qué tiendas fueron las más productivas durante el mes.
-- 2. Qué provincias generaron mayor facturación.
-- 3. Ranking para análisis comparativo y posibles estrategias de promoción.

-- =====================================================
-- OBJETIVO 3: Analizar el comportamiento por categoría y producto
-- Comparar la facturación de cada producto con la media de su categoría
-- =====================================================

-- Utilizamos CTEs (WITH) para organizar el cálculo en pasos claros

WITH ingresos_productos AS (
    -- CTE 1: Calculamos la facturación total por producto
    SELECT
        dp.product_name,          -- Nombre del producto
        dc.category_name,         -- Categoría a la que pertenece
        SUM(fs.total_amount) AS facturacion  -- Total de ventas por producto
    FROM fact_sales fs
    JOIN dim_product dp ON fs.product_id = dp.product_id  -- Unimos con productos
    JOIN dim_category dc ON dp.category_id = dc.category_id  -- Unimos con categorías
    GROUP BY dp.product_name, dc.category_name
),
media_ingresos AS (
    -- CTE 2: Calculamos la media de facturación por categoría
    SELECT
        category_name,
        AVG(facturacion) AS media_categoria  -- Media de facturación por categoría
    FROM ingresos_productos
    GROUP BY category_name
)

-- Seleccionamos los datos finales para comparación
SELECT
    ip.product_name,            -- Producto
    ip.category_name,           -- Categoría
    ip.facturacion,             -- Facturación total del producto
    mi.media_categoria,         -- Media de facturación de su categoría
    CASE
        -- Comparamos la facturación del producto con la media de su categoría
        WHEN ip.facturacion > mi.media_categoria THEN 'Por encima de la media'
        ELSE 'Por debajo de la media'
    END AS comparacion_media
FROM ingresos_productos ip
JOIN media_ingresos mi ON ip.category_name = mi.category_name  -- Unimos para comparar
ORDER BY ip.category_name, ip.facturacion DESC;  -- Ordenamos por categoría y facturación

-- Comentarios:
-- 1. SUM(fs.total_amount) nos da la facturación total por producto.
-- 2. AVG(facturacion) sobre la CTE calcula la media por categoría.
-- 3. CASE permite clasificar los productos según su desempeño relativo.
-- 4. Insights: Podemos identificar qué productos son “estrella” y cuáles necesitan promoción.

-- =====================================================
-- OBJETIVO 4️: Analizar la evolución temporal de las ventas
-- =====================================================
-- Contexto: Queremos ver cómo evolucionan las ventas a lo largo del mes
-- de diciembre 2025, identificar picos y patrones. Aunque solo tenemos
-- 31 días, sirve para practicar funciones de fecha y CASE.

-- Iniciamos la consulta
WITH ventas_diarias AS (
    SELECT
        fs.date_id,
        dc.day,
        dc.month,
        dc.year,
        SUM(fs.total_amount) AS total_facturacion,
        COUNT(fs.sale_id) AS total_ventas,
        AVG(fs.unit_price) AS precio_medio_unitario,
        -- Clasificamos los días en periodos pre-navidad, navidad y fin de año
        CASE
            WHEN dc.day < 24 THEN 'Pre-Navidad'
            WHEN dc.day BETWEEN 24 AND 25 THEN 'Navidad'
            ELSE 'Fin de Año'
        END AS periodo
    FROM fact_sales fs
    JOIN dim_calendar dc ON fs.date_id = dc.date_id
    GROUP BY fs.date_id, dc.day, dc.month, dc.year
)
SELECT
    date_id,
    day,
    month,
    year,
    periodo,
    total_ventas,
    total_facturacion,
    ROUND(precio_medio_unitario,2) AS precio_medio_unitario
FROM ventas_diarias
ORDER BY date_id;

-- Comentarios:
-- 1. SUM, COUNT y AVG permiten ver la facturación, cantidad de ventas y precio promedio diario.
-- 2. La columna "periodo" nos ayuda a identificar fácilmente picos en Navidad y Fin de Año.
-- 3. Esta información permite planificar campañas y anticipar demanda en días clave.

-- =====================================================
-- OBJETIVO 5️: Crear una VIEW resumen de ventas por provincia y categoría
-- =====================================================
-- Contexto: Consolidar información relevante para tomar decisiones estratégicas.
-- La vista nos permitirá ver:
--  - Provincia y categoría de producto
--  - Total de ventas (cantidad)
--  - Ingresos totales
--  - Promedio de ingreso por venta

CREATE OR REPLACE VIEW vw_resumen_ventas AS
SELECT
    p.province_name,
    c.category_name,            -- viene de dim_category, no de dim_product
    COUNT(fs.sale_id) AS total_ventas,
    SUM(fs.total_amount) AS total_ingresos
FROM fact_sales fs
JOIN dim_store s ON fs.store_id = s.store_id
JOIN dim_province p ON s.province_id = p.province_id
JOIN dim_product dp ON fs.product_id = dp.product_id
JOIN dim_category c ON dp.category_id = c.category_id
GROUP BY p.province_name, c.category_name
ORDER BY p.province_name;


-- Comentarios:
-- 1. JOINs permiten relacionar ventas con producto, tienda y provincia.
-- 2. SUM(fs.quantity) muestra el volumen total de ventas.
-- 3. SUM(fs.total_amount) da los ingresos generados.
-- 4. AVG(fs.total_amount) proporciona ticket medio por venta.
-- 5. Esta vista es útil para identificar provincias y categorías más rentables.

-- =====================================================
-- FUNCION: Total ventas por tienda
-- =====================================================
-- Objetivo: Devuelve el total de ingresos (total_amount) de una tienda concreta
-- Parámetro: p_store_id -> ID de la tienda
-- Uso: SELECT fn_total_ventas_tienda(3);
-- =====================================================

DELIMITER $$

CREATE FUNCTION fn_total_ventas_tienda(p_store_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT SUM(total_amount) INTO total
    FROM fact_sales
    WHERE store_id = p_store_id;

    RETURN total;
END $$

DELIMITER ;

-- =====================================================
-- TEST: Verificar que la función devuelve resultados
-- =====================================================
-- Ejecutar en un bloque separado después de cargar el script
SELECT fn_total_ventas_tienda(5);
