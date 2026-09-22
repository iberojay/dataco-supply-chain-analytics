SELECT 
	COUNT(*) AS total_rows,
    COUNT(DISTINCT order_item_id) AS distinct_order_item_ids,
    COUNT(DISTINCT order_id) AS distinct_orders,
    SUM(
		CASE 
			WHEN order_item_id IS NULL or TRIM(order_item_id) = ''
            THEN 1 
            ELSE 0
		END
	) AS missing_order_item_ids
FROM dataco_operations.stg_dataco_order_lines;

SELECT COUNT(*) AS imported_rows
FROM dataco_operations.stg_dataco_order_lines;

SET GLOBAL local_infile = OFF;

SELECT COUNT(*) AS rows_with_bad_characters
FROM stg_dataco_order_lines
WHERE CONCAT_WS(
    '',
    category_name,
    customer_city,
    customer_country,
    customer_segment,
    customer_state,
    delivery_status,
    market,
    order_city,
    order_country,
    order_region,
    order_state,
    order_status,
    product_name,
    shipping_mode
) LIKE '%�%';