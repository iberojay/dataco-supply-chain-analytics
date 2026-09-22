-- Business Question: Which customer segment generates the most orders, net sales, and profit
-- Analysis: The consumer segemnt is the main driver of revenue and profit becuase of its larger customer and order volume. Corporate customers 
-- have the highest average order value, while difference in order value and profit margin across segments remain relatively small.
SELECT 
	dm.customer_segment,
    FORMAT(COUNT(DISTINCT fol.customer_id),0) AS unique_customers,
    FORMAT(COUNT(DISTINCT fol.order_id),0) AS unique_orders,
    FORMAT(SUM(fol.order_item_quantity),0) AS total_units_sold,
    FORMAT(SUM(fol.net_line_sales),2) AS total_net_sales,
    FORMAT(SUM(fol.line_profit), 2) AS total_profit,
    ROUND( (SUM(fol.line_profit) / SUM(fol.net_line_sales) * 100.0),2 ) AS profit_margin_percentage,
    ROUND( SUM(fol.net_line_sales) / COUNT(DISTINCT fol.order_id), 2 ) AS average_order_value

FROM fact_order_lines fol
INNER JOIN dim_customer dm ON dm.customer_id = fol.customer_id

GROUP BY dm.customer_segment
ORDER BY SUM(fol.net_line_sales)
;



