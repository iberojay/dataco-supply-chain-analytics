-- Remeber: Use every order line for "financial and quanity sums
-- Use COUNT(DISTINCT order_id) when you specifically want the number of separate recipts

-- Task: Which 10 products generate the most net sales, and how profitable are they?
-- Conclusion: Field & Stream Sportsman is the strongest revenue and profit contributor, while Perfect Fitness Rip Deck is the highest volume 
-- product. High unit volume does not always product the hiest revenue beacuse prodcut prices vary considerably.
SELECT
	dp.product_card_id,
	dp.product_name,
    FORMAT(SUM(fol.order_item_quantity),0) AS total_units_sold,
    FORMAT(SUM(fol.net_line_sales),0) AS total_net_sales,
    FORMAT(SUM(fol.line_profit),0) AS total_profit,
    ROUND( (SUM(fol.line_profit) / SUM(fol.net_line_sales) * 100.0),2 ) AS profit_margin_percentage
FROM fact_order_lines fol 
INNER JOIN dim_product dp ON dp.product_card_id = fol.product_card_id

GROUP BY dp.product_name, dp.product_card_id
ORDER BY SUM(fol.net_line_sales) DESC
LIMIT 10
;


-- Business Question: Which product categories generate the most net sales, and how profitable are they 
SELECT
	COUNT(DISTINCT fol.order_id) AS total_unique_orders,  -- Shows how many orders for each category 
	dp.category_id,
	dp.category_name,
    FORMAT(SUM(fol.order_item_quantity),0) AS total_units_sold,
    FORMAT(SUM(fol.net_line_sales),0) AS total_net_sales,
    FORMAT(SUM(fol.line_profit),0) AS total_profit,
    ROUND( (SUM(fol.line_profit) / SUM(fol.net_line_sales) * 100.0),2 ) AS profit_margin_percentage
FROM fact_order_lines fol 
INNER JOIN dim_product dp ON dp.product_card_id = fol.product_card_id

GROUP BY dp.category_id, dp.category_name
ORDER BY SUM(fol.net_line_sales) DESC
LIMIT 10
;





