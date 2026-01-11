# 📊 Retail Sales Analytics – Proyecto SQL

## 📌 Descripción general

Este repositorio contiene un **proyecto de análisis exploratorio de datos (EDA)** desarrollado en **SQL (MySQL)** sobre un sistema de ventas minoristas.

El objetivo del proyecto es **diseñar un modelo relacional coherente**, cargar datos de ejemplo y **extraer insights de negocio mediante consultas SQL**, aplicando los conceptos vistos durante el módulo: joins, agregaciones, CTEs, funciones ventana, vistas y funciones.

El análisis se centra en el **mes de diciembre de 2025**.

---

## 🎯 Objetivos del proyecto

1. Analizar el **rendimiento global del negocio** (ventas e ingresos).
2. Evaluar el **desempeño por tienda y provincia**, incluyendo rankings.
3. Comparar el **rendimiento de cada producto frente a la media de su categoría**.
4. Analizar la **evolución temporal de las ventas**.
5. Crear una **vista resumen** para análisis estratégico.
6. Implementar una **función SQL** reutilizable.

---

## 🗂️ Estructura del repositorio

```
retail-sales-analytics/
│
├── 01_schema.sql        # Creación de la base de datos y tablas (modelo estrella)
├── 02_data.sql          # Inserción de datos de ejemplo
├── 03_eda.sql           # Análisis exploratorio de datos (EDA)
├── README.md            # Documentación del proyecto
```
## 🧱 Modelo de datos

El modelo sigue una estructura **tipo estrella**, habitual en entornos analíticos:

### Tabla de hechos
- `fact_sales`: almacena las ventas individuales (granularidad: una fila por venta).

### Tablas de dimensiones
- `dim_product`
- `dim_category`
- `dim_store`
- `dim_province`
- `dim_calendar`

Este diseño facilita análisis agregados, comparativas y consultas de negocio eficientes.

---

## 📈 Análisis Exploratorio (03_eda.sql)

El archivo `03_eda.sql` es el **núcleo del proyecto** e incluye:

### 🔹 Objetivo 1: Rendimiento global
- Total de ventas
- Ingresos totales
- Ticket medio por categoría

### 🔹 Objetivo 2: Rendimiento por tienda y provincia
- Ventas e ingresos por tienda
- Ranking de tiendas mediante `RANK() OVER ()`

### 🔹 Objetivo 3: Producto vs media de su categoría
- Uso de **CTEs encadenadas (`WITH`)**
- Comparación mediante `CASE`
- Identificación de productos por encima o debajo de la media

### 🔹 Objetivo 4: Evolución temporal
- Análisis diario de ventas
- Clasificación de días en periodos (Pre-Navidad, Navidad, Fin de Año)
- Uso de funciones de fecha y agregaciones

### 🔹 Objetivo 5: Vista resumen
- Creación de la vista `vw_resumen_ventas`
- Agregación por **provincia y categoría**
- Métricas de ventas e ingresos

---

## 🧮 Función SQL incluida

Dentro de `03_eda.sql` se define la función:

```sql
fn_total_ventas_tienda(p_store_id INT)
