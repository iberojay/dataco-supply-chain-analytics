-- Validate fact_table 

-- Total quantity
SELECT 
	(SELECT SUM(CAST(order_item_quantity AS UNSIGNED))
    FROM stg_dataco_order_lines) as staging_total_quantity,
    
    (SELECT SUM(order_item_quantity)
    FROM fact_order_lines) as fact_total_quantity;


SELECT 
	(SELECT SUM(CAST(gross_line_sales AS DECIMAL(10,2)))
    FROM stg_dataco_order_lines) as staging_total_gross_line_sales,
    
    (SELECT SUM(gross_line_sales)
    FROM fact_order_lines) as fact_total_gross_line_sales;
    
    
SELECT 
	(SELECT SUM(CAST(gross_line_sales AS DECIMAL(10,2)))
    FROM stg_dataco_order_lines) as staging_total_gross_line_sales,
    
    (SELECT SUM(gross_line_sales)
    FROM fact_order_lines) as fact_total_gross_line_sales;

SELECT 
	(SELECT SUM(CAST(discount_amount AS DECIMAL(10,2)))
    FROM stg_dataco_order_lines) as staging_total_discount_amount,
    
    (SELECT SUM(discount_amount)
    FROM fact_order_lines) as fact_total_discount_amount,
    
    (SELECT SUM(CAST(line_profit AS DECIMAL(10,2)))
    FROM stg_dataco_order_lines) as staging_total_line_profit,
    
    (SELECT SUM(line_profit)
    FROM fact_order_lines) as fact_total_line_profit;
    

    
SELECT COUNT(*) AS mismatched_discount_rates
FROM stg_dataco_order_lines AS s
JOIN fact_order_lines AS f
    ON CAST(s.order_item_id AS UNSIGNED) = f.order_item_id
WHERE CAST(s.order_item_discount_rate AS DECIMAL(8,6))
      <> f.order_item_discount_rate;
      
SELECT COUNT(*) AS mismatched_profit_rates
FROM stg_dataco_order_lines AS s
JOIN fact_order_lines AS f
    ON CAST(s.order_item_id AS UNSIGNED) = f.order_item_id
WHERE CAST(s.line_profit_ratio AS DECIMAL(8,6))
      <> f.line_profit_ratio;