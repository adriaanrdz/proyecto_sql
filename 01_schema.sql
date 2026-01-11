-- =====================================================
-- PROYECTO SQL - MODELO RELACIONAL DE VENTAS RETAIL
-- Motor: MySQL
-- Modelo estrella (Star Schema)
-- =====================================================

-- -----------------------------------------------------
-- Creación del esquema
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS retail_sales_db;
CREATE SCHEMA IF NOT EXISTS retail_sales_db;
USE retail_sales_db;

-- -----------------------------------------------------
-- Eliminación de tablas en orden inverso a las FK
-- Permite ejecutar el script desde cero sin errores
-- -----------------------------------------------------
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_calendar;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_category;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_province;

-- -----------------------------------------------------
-- DIMENSION: Provincia
-- Nivel geográfico superior
-- -----------------------------------------------------
CREATE TABLE dim_province (
    province_id INT AUTO_INCREMENT PRIMARY KEY,
    province_name VARCHAR(100) NOT NULL UNIQUE
) COMMENT='Dimensión geográfica: provincias';

-- -----------------------------------------------------
-- DIMENSION: Tienda
-- Cada tienda pertenece a una provincia
-- -----------------------------------------------------
CREATE TABLE dim_store (
    store_id INT AUTO_INCREMENT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    province_id INT NOT NULL,
    opening_date DATE,
    CONSTRAINT fk_store_province
        FOREIGN KEY (province_id)
        REFERENCES dim_province(province_id)
) COMMENT='Dimensión de tiendas físicas';

-- -----------------------------------------------------
-- DIMENSION: Categoría
-- Clasificación lógica de productos
-- -----------------------------------------------------
CREATE TABLE dim_category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
) COMMENT='Dimensión de categorías de producto';

-- -----------------------------------------------------
-- DIMENSION: Producto
-- Precio base del producto (puede variar en el tiempo)
-- -----------------------------------------------------
CREATE TABLE dim_product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES dim_category(category_id),
    CONSTRAINT chk_product_price CHECK (unit_price > 0)
) COMMENT='Dimensión de productos';

-- -----------------------------------------------------
-- DIMENSION: Calendario
-- Permite análisis temporal por día, mes y año
-- -----------------------------------------------------
CREATE TABLE dim_calendar (
    date_id DATE PRIMARY KEY,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    CONSTRAINT chk_day CHECK (day BETWEEN 1 AND 31),
    CONSTRAINT chk_month CHECK (month BETWEEN 1 AND 12)
) COMMENT='Dimensión temporal';

-- -----------------------------------------------------
-- FACT TABLE: Ventas
-- Granularidad: 1 fila = 1 producto vendido en una tienda y fecha
-- Incluye el precio unitario para mantener histórico de precios
-- -----------------------------------------------------
CREATE TABLE fact_sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    store_id INT NOT NULL,
    date_id DATE NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_id)
        REFERENCES dim_product(product_id),
    CONSTRAINT fk_sales_store
        FOREIGN KEY (store_id)
        REFERENCES dim_store(store_id),
    CONSTRAINT fk_sales_calendar
        FOREIGN KEY (date_id)
        REFERENCES dim_calendar(date_id),
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_unit_price CHECK (unit_price > 0),
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0)
) COMMENT='Tabla de hechos de ventas';

-- -----------------------------------------------------
-- ÍNDICE
-- Mejora el rendimiento de consultas por fecha
-- Especialmente útil en análisis temporales y EDA
-- -----------------------------------------------------
CREATE INDEX idx_fact_sales_date ON fact_sales(date_id);
