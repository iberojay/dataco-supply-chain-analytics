-- Location Financial Performance 

-- Task: "Which market generates the most net sales and profit?"
-- Note: Don't reduce fact table to distinct orders before summing units, sales, or profit. ONLY order count should use distinct

-- Conclusion: Europe is the company's largest market by revenue and total profit, while USCA is the most profitable relative to its sales. 
-- Profit margins are fairly consistent across markets-ranging only from 11.54% to 12.39% margin. So the difference in total profit are mainly
-- by sales volumn rather than major differences in profitablitly
 
-- Calcualtes each market's unique orders, units sold, net sales, profit, and profit margin
SELECT 
	FORMAT(COUNT(DISTINCT fol.order_id),0) AS total_unique_orders,
    dl.market,
    FORMAT(SUM(fol.order_item_quantity),0) AS total_units_sold,
    FORMAT(SUM(fol.net_line_sales),2) AS total_net_sales,
    FORMAT(SUM(fol.line_profit), 2) AS total_profit,
    ROUND( (SUM(fol.line_profit) / SUM(fol.net_line_sales) * 100.0),2 ) AS profit_margin_percentage -- profit / revenue
    
FROM fact_order_lines fol
INNER JOIN dim_location dl ON dl.location_id = fol.location_id

GROUP BY dl.market
ORDER BY total_net_sales DESC
;


-- Task: Find the top 10 countries by net sales
-- Business Question: Which countries generate the most net sales, and how profitable are they?

-- Conclusion: United states is the company's largest country market by both net sales and total profit. However, Brazil delivers the highest profit
-- margin  among the leading countries. Germany's comparatively low margin may warrent investigation into discounts, product mix, or operating
-- costs.
SELECT 
	dl.order_country,
    FORMAT(COUNT(DISTINCT fol.order_id),0) AS total_unique_orders,
    FORMAT(SUM(fol.order_item_quantity),0) AS total_units_sold,
    FORMAT(SUM(fol.net_line_sales),2) AS total_net_sales,
    FORMAT(SUM(fol.line_profit), 2) AS total_profit,
    ROUND( (SUM(fol.line_profit) / SUM(fol.net_line_sales) * 100.0),2 ) AS profit_margin_percentage
	
FROM fact_order_lines fol
INNER JOIN dim_location dl ON dl.location_id = fol.location_id

GROUP BY dl.order_country
ORDER BY SUM(fol.net_line_sales) DESC
LIMIT 10
;

