📊 Retail Sales Analytics – Proyecto SQL

📌 Descripción general

Este repositorio contiene un proyecto completo de análisis de datos (EDA) sobre un sistema de ventas minoristas, desarrollado íntegramente en SQL (MySQL). El objetivo es analizar el rendimiento del negocio durante diciembre de 2025, extrayendo métricas clave, rankings, comparativas y patrones temporales que ayuden a la toma de decisiones.

El proyecto sigue una estructura profesional y modular, similar a la que se utiliza en entornos reales de análisis de datos y Business Intelligence.

🎯 Objetivos del proyecto

Analizar el rendimiento global del negocio (ventas e ingresos).

Evaluar el desempeño por tienda y provincia, incluyendo rankings.

Comparar el comportamiento de productos frente a la media de su categoría.

Estudiar la evolución temporal de las ventas durante el mes.

Crear vistas reutilizables para análisis estratégico.

Implementar una función SQL para cálculo de ingresos por tienda.

🗂️ Estructura del repositorio

retail-sales-analytics/
│
├── 01_schema.sql        # Creación de la base de datos y tablas (modelo estrella)
├── 02_data.sql          # Inserción de datos de ejemplo
├── 03_eda.sql           # Análisis exploratorio de datos (EDA)
├── README.md            # Documentación del proyecto

🧱 Modelo de datos

El proyecto utiliza un modelo en estrella, habitual en entornos analíticos:

Tabla de hechos

fact_sales: ventas, importes, cantidades, fechas, productos y tiendas

Tablas de dimensiones

dim_product

dim_category

dim_store

dim_province

dim_calendar

Este diseño permite consultas analíticas eficientes y escalables.

📈 Contenido del análisis (03_eda.sql)

🔹 Objetivo 1: Rendimiento global

Total de ventas

Ingresos totales

Ticket medio por categoría

🔹 Objetivo 2: Rendimiento por tienda y provincia

Ventas e ingresos por tienda

Ranking de tiendas mediante RANK()

🔹 Objetivo 3: Producto vs media de su categoría

Uso de CTEs (WITH)

Comparación con CASE

Identificación de productos por encima / debajo de la media

🔹 Objetivo 4: Evolución temporal

Análisis diario de ventas

Clasificación por periodos: Pre-Navidad, Navidad y Fin de Año

🔹 Objetivo 5: Vista agregada

Vista vw_resumen_ventas

Resumen por provincia y categoría

🔹 Función SQL

fn_total_ventas_tienda(p_store_id)

Devuelve el total de ingresos de una tienda concreta

🧮 Función incluida

SELECT fn_total_ventas_tienda(5);

Permite reutilizar lógica de negocio y ejemplifica el uso de funciones en MySQL.
