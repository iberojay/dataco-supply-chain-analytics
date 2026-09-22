-- SELECT order_date, shipping_date, order_item_quantity, gross_line_sales, product
-- FROM stg_dataco_order_lines
-- LIMIT 5;


-- TASK: Converting text to SQL DATA types
-- SELECT 
-- 	order_date,
--     CAST(order_date AS DATETIME) AS converted_order_date,
-- 	shipping_date,
--     CAST(shipping_date AS DATETIME) AS converted_shipping_date,
--     order_item_quantity,
--     CAST(order_item_quantity AS UNSIGNED) AS converted_order_item_quanitity,
--     gross_line_sales,
--     CAST(gross_line_sales AS DECIMAL(12,2)) AS converted_gross_line_sales
-- FROM stg_dataco_order_lines
-- LIMIT 5;


-- TASK: Inspecting numerical ranges
-- SELECT 
-- 	MIN(CAST(order_item_quantity AS UNSIGNED)) AS minimum_quantity,
--     MAX(CAST(order_item_quantity AS UNSIGNED)) AS maximum_quantity,
--     MIN(CAST(gross_line_sales AS DECIMAL(12,2))) AS minimum_gross_line_sales,
--     MAX(CAST(gross_line_sales AS DECIMAL(12,2))) AS maximum_gross_line_sales
-- FROM stg_dataco_order_lines;

-- Task: Profile the remaining finacnial feilds 
-- SELECT
-- 	MIN(CAST(discount_amount AS DECIMAL(18,6))) AS minimum_discount_amount,
--     MAX(CAST(discount_amount AS DECIMAL(18,6))) AS maximum_discount_amount,
--     MIN(CAST(order_item_discount_rate AS DECIMAL(18,6))) AS minimum_order_item_discount_rate,
--     MAX(CAST(order_item_discount_rate AS DECIMAL(18,6))) AS maximum_order_item_discount_rate,
--     MIN(CAST(net_line_sales AS DECIMAL(18,6))) AS minimum_net_line_sales,
--     MAX(CAST(net_line_sales AS DECIMAL(18,6))) AS maximum_net_line_sales,
--     MIN(CAST(line_profit AS DECIMAL(18,6))) AS minimum_line_profit,
--     MAX(CAST(line_profit AS DECIMAL(18,6))) AS maximum_line_profit,
--     MIN(CAST(line_profit_ratio AS DECIMAL(18,6))) AS minimum_line_profit_ratio,
--     MAX(CAST(line_profit_ratio AS DECIMAL(18,6))) AS maximum_line_profit_ratio

-- FROM stg_dataco_order_lines;

-- TASK: Profile Date Ranges
SELECT 
	MIN(CAST(order_date AS DATETIME)) AS minimum_order_date,
    MAX(CAST(order_date AS DATETIME)) AS maximum_order_date,
    MIN(CAST(shipping_date AS DATETIME)) AS minimum_shipping_date,
    MAX(CAST(shipping_date AS DATETIME)) AS maximum_shipping_date
FROM stg_dataco_order_lines;

SELECT 
    MAX(CHAR_LENGTH(delivery_status)) AS max_delivery_status_text_length
FROM stg_dataco_order_lines;

SHOW VARIABLES LIKE 'default_storage_engine';

SELECT 
	MAX(CAST(product_price AS DECIMAL(18,6))) AS maximum_product_price,
	MIN(CAST(product_price AS DECIMAL(18,6))) AS minimum_product_price,
    MAX(CAST(product_status AS UNSIGNED)) AS maximum_product_status,
	MIN(CAST(product_status AS UNSIGNED)) AS minimum_product_status
FROM stg_dataco_order_lines;

SELECT
    product_status,
    COUNT(*) AS row_count
FROM stg_dataco_order_lines
GROUP BY product_status;
    
    
    
    






