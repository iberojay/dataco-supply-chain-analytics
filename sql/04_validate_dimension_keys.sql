-- Task: Validate Customer Attribute consistency 
-- Check whether the same customer_id is associated with conflicitng segment or location
-- information across differnt order lines.
-- No rows returned means every customer_id has consistent attributes

-- Groups all order-line records by customer_id
-- For each CUSTOMER, counts the number of distinct segments, cities, states, and countries associated with that specific customer.
-- HAVING returns only customers with more than one value of any attribute, indicating potentially inconsistent customer information

-- NO RETURNED rows means every customer has only one disctinct segment, city, state, and country
SELECT customer_id 
FROM stg_dataco_order_lines
GROUP BY customer_id
HAVING 
	COUNT(DISTINCT 	customer_segment) > 1
    OR COUNT(DISTINCT customer_city) > 1
    OR COUNT(DISTINCT customer_state) > 1
    or COUNT(DISTINCT customer_country) > 1;


-- Validate the prodcut dimension, confirm that each product_card_id consitentyl identifies one product 
-- No rows returned. each product_card_id has one consistent set of product attributes 
SELECT product_card_id
FROM stg_dataco_order_lines
GROUP BY product_card_id
HAVING 
	COUNT(DISTINCT product_name) > 1
    OR COUNT(DISTINCT category_id) > 1
    OR COUNT(DISTINCT category_name) > 1
    OR COUNT(DISTINCT department_id) > 1
    OR COUNT(DISTINCT department_name) > 1
    OR COUNT(DISTINCT product_price) > 1
    OR COUNT(DISTINCT product_status) > 1;
    
SELECT MAX(CAST(product_price AS DECIMAL(10,2))) AS max_product_price
FROM stg_dataco_order_lines;


-- PLan the location dimension
SELECT
    market,
    order_region,
    order_country,
    order_state,
    order_city,
    COUNT(*) AS occurrence_count
FROM stg_dataco_order_lines
GROUP BY
    market,
    order_region,
    order_country,
    order_state,
    order_city
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;
    
    
    