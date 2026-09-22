TRUNCATE TABLE dataco_operations.dim_customer;

-- Create the Customer dimension table 
CREATE TABLE dim_customer (
	customer_id INT UNSIGNED PRIMARY KEY,
    customer_segment VARCHAR(25) NOT NULL,
    customer_city VARCHAR(100) NOT NULL,
    customer_state VARCHAR(100) NOT NULL,
    customer_country VARCHAR(100) NOT NULL 
);

-- Populate dim_customer
INSERT INTO dim_customer(
	customer_id,
    customer_segment,
    customer_city,
    customer_state,
    customer_country
)
SELECT DISTINCT 
	CAST(customer_id AS UNSIGNED), 
    customer_segment, 
    customer_city, 
    customer_state,
    customer_country
FROM stg_dataco_order_lines;

-- Validation 
-- Raw source table "staging" contains 20,652 unique customers
-- dim_customers contains 20,652 customer records
-- Every unique staging custeomer was transferred to the dimensions
SELECT 
	(SELECT COUNT(*)
     FROM dim_customer) AS dimension_customers,
	(SELECT COUNT(DISTINCT customer_id)
	 FROM stg_dataco_order_lines) AS staging_customers;
SELECT DISTINCT
    CAST(customer_id AS UNSIGNED),
    customer_segment,
    customer_city,
    customer_state,
    customer_country
FROM dataco_operations.stg_dataco_order_lines;
     
     
-- CREATE tabke dim_product 
-- Product status was removed becuase all rows contain 0
CREATE TABLE dim_product(
	product_card_id INT UNSIGNED PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INT UNSIGNED NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    department_id INT UNSIGNED NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    product_price DECIMAL(6,2) NOT NULL
);

-- Populate dim_product
INSERT INTO dim_product (
	product_card_id,
    product_name, 
    category_id, 
    category_name, 
    department_id, 
    department_name, 
    product_price)
SELECT DISTINCT 
	CAST(product_card_id AS UNSIGNED), 
    product_name, 
    CAST(category_id AS UNSIGNED), 
    category_name, 
    CAST(department_id AS UNSIGNED),
    department_name, 
    CAST(product_price AS DECIMAL(6,2))
FROM stg_dataco_order_lines;

-- Validation, confirm every unique product from the staging table was inserted exaactly once into the product dimension
SELECT 
	(SELECT COUNT(*)
     FROM dim_product) AS dimension_products,
	(SELECT COUNT(DISTINCT product_card_id)
     FROM stg_dataco_order_lines) AS staging_products;
     
     
-- Create table dim_location
CREATE TABLE dim_location (
	location_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    market VARCHAR(100) NOT NULL,
    order_region VARCHAR(100) NOT NULL,
    order_country VARCHAR(100) NOT NULL,
    order_state VARCHAR(100) NOT NULL,
    order_city VARCHAR(100) NOT NULL 
);

INSERT INTO dim_location(
	market,
    order_region,
    order_country,
    order_state,
    order_city
)
SELECT DISTINCT 
    market, 
    order_region, 
    order_country,
    order_state,
    order_city
FROM stg_dataco_order_lines;

--
SELECT 
	(SELECT COUNT(*)
     FROM dim_location) AS dimension_location,
	(SELECT COUNT(*)
     FROM (
         SELECT DISTINCT
             market,
             order_region,
             order_country,
             order_state,
             order_city
         FROM stg_dataco_order_lines
     ) AS unique_staging_locations) AS staging_locations;
     
     
-- Create date dimension, analyize performance based on year, quarter, month, day, day of the week
CREATE TABLE dim_date (
	date_key INT UNSIGNED PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    calendar_year YEAR NOT NULL,
    calendar_quarter INT UNSIGNED NOT NULL,
    month_number INT UNSIGNED NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    day_of_month INT UNSIGNED NOT NULL,
    day_name VARCHAR(10) NOT NULL
);

SET SESSION cte_max_recursion_depth = 2000;

INSERT INTO dim_date (
    date_key,
    full_date,
    calendar_year,
    calendar_quarter,
    month_number,
    month_name,
    day_of_month,
    day_name
)
WITH RECURSIVE date_series AS (
    SELECT DATE('2015-01-01') AS full_date

    UNION ALL

    SELECT DATE_ADD(full_date, INTERVAL 1 DAY)
    FROM date_series
    WHERE full_date < '2018-02-06'
)
SELECT
    CAST(DATE_FORMAT(full_date, '%Y%m%d') AS UNSIGNED),
    full_date,
    YEAR(full_date),
    QUARTER(full_date),
    MONTH(full_date),
    MONTHNAME(full_date),
    DAY(full_date),
    DAYNAME(full_date)
FROM date_series;

SELECT COUNT(*) AS dimension_date
FROM dim_date;

-- Validation check: boundaries and uniqueness
SELECT
    MIN(full_date) AS earliest_date,
    MAX(full_date) AS latest_date,
    COUNT(*) AS total_dates,
    COUNT(DISTINCT full_date) AS distinct_dates
FROM dim_date;
     
-- Create fact_order_lines
-- Connect the four previous tables and store the numerical values we want to analyze
-- Each records will reprsent one "order item/ine"
CREATE TABLE fact_order_lines(
	order_item_id INT UNSIGNED PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL,
    customer_id INT UNSIGNED NOT NULL,
    product_card_id INT UNSIGNED NOT NULL,
    location_id INT UNSIGNED NOT NULL,
    order_date_key INT UNSIGNED NOT NULL,
    shipping_date_key INT UNSIGNED NOT NULL,
    record_type VARCHAR(20) NOT NULL,
    order_datetime DATETIME NOT NULL,
    shipping_datetime DATETIME NOT NULL,
    days_for_shipping_real INT UNSIGNED NOT NULL,
    days_for_shipment_scheduled INT UNSIGNED NOT NULL,
    delivery_status VARCHAR(25) NOT NULL,
    late_delivery_risk TINYINT UNSIGNED NOT NULL,
    order_status VARCHAR(25) NOT NULL,
    shipping_mode VARCHAR(25) NOT NULL,
    order_item_quantity INT UNSIGNED NOT NULL,
    order_item_product_price DECIMAL(10,2) NOT NULL,
    gross_line_sales DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    order_item_discount_rate DECIMAL(8,6) NOT NULL,
    net_line_sales DECIMAL(10,2) NOT NULL,
    line_profit DECIMAL(10,2) NOT NULL,
    line_profit_ratio DECIMAL(8,6) NOT NULL,
    
    CONSTRAINT fk_fact_customer
    FOREIGN KEY (customer_id) 
    REFERENCES dim_customer(customer_id),
    
    CONSTRAINT fk_fact_product_card_id
    FOREIGN KEY (product_card_id) 
    REFERENCES dim_product(product_card_id),
    
    CONSTRAINT fk_fact_location_id
    FOREIGN KEY (location_id) 
    REFERENCES dim_location(location_id),
    
    CONSTRAINT fk_fact_order_date_key
    FOREIGN KEY (order_date_key) 
    REFERENCES dim_date(date_key),
    
    CONSTRAINT fk_fact_shipping_date_key
    FOREIGN KEY (shipping_date_key) 
    REFERENCES dim_date(date_key)
    
);

SELECT 
	CAST(s.order_item_id AS UNSIGNED) AS order_item_id, 
    CAST(s.order_id AS UNSIGNED) AS order_id, 
    c.customer_id,
    p.product_card_id, 
    l.location_id, 
    od.date_key AS order_date_key, 
    sd.date_key AS shipping_date_key
    
FROM stg_dataco_order_lines AS s 

JOIN dim_customer AS c ON CAST(s.customer_id AS UNSIGNED) = c.customer_id

JOIN dim_product AS p ON CAST(s.product_card_id AS UNSIGNED) = p.product_card_id

JOIN dim_location AS l on s.market = l.market
    AND s.order_region = l.order_region
    AND s.order_country = l.order_country
    AND s.order_state = l.order_state
    AND s.order_city = l.order_city
    
JOIN dim_date AS od ON DATE(CAST(s.order_date AS DATETIME)) = od.full_date
JOIN dim_date AS sd on DATE(CAST(s.shipping_date AS DATETIME)) = od.date_key
LIMIT 5
;

SELECT 
	COUNT(*) AS joined_rows,
    COUNT(DISTINCT s.order_item_id) AS distinct_joined_order_items,
    (SELECT COUNT(*)
     FROM stg_dataco_order_lines) AS staging_rows
    
FROM stg_dataco_order_lines AS s 

JOIN dim_customer AS c ON CAST(s.customer_id AS UNSIGNED) = c.customer_id

JOIN dim_product AS p ON CAST(s.product_card_id AS UNSIGNED) = p.product_card_id

JOIN dim_location AS l on s.market = l.market
    AND s.order_region = l.order_region
    AND s.order_country = l.order_country
    AND s.order_state = l.order_state
    AND s.order_city = l.order_city
    
JOIN dim_date AS od
    ON CAST(s.order_date AS DATE) = od.full_date

JOIN dim_date AS sd
    ON CAST(s.shipping_date AS DATE) = sd.full_date;
;

-- Populate fact_order_lines
INSERT INTO fact_order_lines (
    order_item_id,
    order_id,
    customer_id,
    product_card_id,
    location_id,
    order_date_key,
    shipping_date_key,
    record_type,
    order_datetime,
    shipping_datetime,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    delivery_status,
    late_delivery_risk,
    order_status,
    shipping_mode,
    order_item_quantity,
    order_item_product_price,
    gross_line_sales,
    discount_amount,
    order_item_discount_rate,
    net_line_sales,
    line_profit,
    line_profit_ratio
)
SELECT
    CAST(s.order_item_id AS UNSIGNED),
    CAST(s.order_id AS UNSIGNED),
    c.customer_id,
    p.product_card_id,
    l.location_id,
    od.date_key,
    sd.date_key,
    s.record_type,
    CAST(s.order_date AS DATETIME),
    CAST(s.shipping_date AS DATETIME),
    CAST(s.days_for_shipping_real AS UNSIGNED),
    CAST(s.days_for_shipment_scheduled AS UNSIGNED),
    s.delivery_status,
    CAST(s.late_delivery_risk AS UNSIGNED),
    s.order_status,
    s.shipping_mode,
    CAST(s.order_item_quantity AS UNSIGNED),
    CAST(s.order_item_product_price AS DECIMAL(10,2)),
    CAST(s.gross_line_sales AS DECIMAL(10,2)),
    CAST(s.discount_amount AS DECIMAL(10,2)),
    CAST(s.order_item_discount_rate AS DECIMAL(8,6)),
    CAST(s.net_line_sales AS DECIMAL(10,2)),
    CAST(s.line_profit AS DECIMAL(10,2)),
    CAST(s.line_profit_ratio AS DECIMAL(8,6))

FROM stg_dataco_order_lines AS s
JOIN dim_customer AS c
    ON CAST(s.customer_id AS UNSIGNED) = c.customer_id
JOIN dim_product AS p
    ON CAST(s.product_card_id AS UNSIGNED) = p.product_card_id
JOIN dim_location AS l
    ON s.market = l.market
    AND s.order_region = l.order_region
    AND s.order_country = l.order_country
    AND s.order_state = l.order_state
    AND s.order_city = l.order_city
JOIN dim_date AS od
    ON CAST(s.order_date AS DATE) = od.full_date
JOIN dim_date AS sd
    ON CAST(s.shipping_date AS DATE) = sd.full_date;
    
-- Validation Query:
-- Validate the fact table load
SELECT
    (SELECT COUNT(*)
     FROM fact_order_lines) AS fact_rows,

    (SELECT COUNT(DISTINCT order_item_id)
     FROM fact_order_lines) AS distinct_fact_order_items,

    (SELECT COUNT(*)
     FROM stg_dataco_order_lines) AS staging_rows;
     
     