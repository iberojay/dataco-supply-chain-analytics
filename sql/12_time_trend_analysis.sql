-- Task: Monthly performance trend
-- Business question: How did order volume, net sales, and profit change each month 

-- Summary: Monthly sales remained relatively stable through September 2018, peaking at approximately $1.03 million. Beginning in October 2017,
-- orders increasily contained fewer units and revenue declined, indicating a major shift in product mix or order composition. Profitability 
-- remained positive throughout the period, although monthly margins flucutated between 9.98% and 14.54%
SELECT 
	dd.calendar_year,
    dd.month_number,
    dd.month_name,
    COUNT(DISTINCT fol.order_id) AS unique_orders,
    FORMAT(SUM(fol.order_item_quantity),0) AS total_units_sold,
    FORMAT(SUM(fol.net_line_sales),2) AS total_net_sales,
    FORMAT(SUM(fol.line_profit), 2) AS total_profit,
    ROUND( (SUM(fol.line_profit) / SUM(fol.net_line_sales) * 100.0),2 ) AS profit_margin_percentage
FROM fact_order_lines fol
INNER JOIN dim_date dd ON dd.date_key = fol.order_date_key

GROUP BY dd.calendar_year, dd.month_number, dd.month_name
ORDER BY dd.calendar_year ASC, dd.month_number ASC
;



-- Task: Monthly order-composition analysis 
-- Business Question: Did monthly revenue decine becuase customers placed fewer orders, purchased feewer units per order, or purchased
-- lower-value products

-- Conclusion: Revenue declined becuase units per order fell from approximately six to one, not becuase fewer orders were placed
-- Changes: 
-- 	September 2017: 1,723 order, 5,189 order lines, 10,502 units, 6.10 units per order, $596.12 average order value
-- 	Novermber 2017: 2,055 order, 2,055 order lines, 2,055 units, 1 unit per order, $274.16 average order values
-- So orders increased BUT each order became much smaller
-- October: Had 1.19 units per order, but net sales rose to $387.98 average order value. Can suggest customers shifted toward higher-priced 
-- products 

-- Revenue decline had two causes
-- 	1. Customers went from buying roughly six units per order to only one
-- 	2. The average value of that one unit declined after Octoer

SELECT 
	dd.calendar_year,
    dd.month_number,
    dd.month_name,
	FORMAT(COUNT(DISTINCT fol.order_id),0) AS unique_orders,
    FORMAT(COUNT(*),0) AS total_order_lines,
    FORMAT(SUM(fol.order_item_quantity),0) AS total_units_sold,
    ROUND((SUM(fol.order_item_quantity) / COUNT(DISTINCT fol.order_id)),2) AS average_units_per_order,
    ROUND((SUM(fol.net_line_sales) / COUNT(DISTINCT fol.order_id)),2) AS average_order_value,
    ROUND((SUM(fol.net_line_sales) / SUM(fol.order_item_quantity) ),2) AS average_net_sales_per_unit
    
FROM fact_order_lines fol
INNER JOIN dim_date dd ON dd.date_key = fol.order_date_key

WHERE dd.full_date >= '2017-09-01' AND dd.full_date < '2018-02-01'

GROUP BY dd.calendar_year, dd.month_number, dd.month_name
ORDER BY dd.calendar_year, dd.month_number
;


-- Task: Compare category mix before and after the change
-- Business Question: Whihc product categories caused the major drop in units per order between September and October 
-- Comparison should tell us whether October's change happened becuase previously popular, high quanity categories disappeared or becuase
-- cusotmers shifted toward different products

-- Conclusion: Revenue decline was not caused by fewer orders. Instead, the contents of those orders changed dramtically
-- 	September: 1,723 orders and 10,502 units 
-- 	October: 2,101 orders and only 2,490 units 
-- Customers went from buying 6.10 units per order to only 1.19 units per order

-- Beginning in October 2017, the dataset shifted from: orders containing multiple lower-priced sporting goods TO order containing approximately
-- one higher-priced product 
SELECT 
	dd.calendar_year,
    dd.month_number,
    dd.month_name,
    dp.category_id,
    dp.category_name,
	FORMAT(COUNT(DISTINCT fol.order_id),0) AS unique_orders,
    FORMAT(SUM(fol.order_item_quantity),0) AS total_units_sold,
    FORMAT(SUM(fol.net_line_sales),2) AS total_net_sales,
    ROUND((SUM(fol.net_line_sales) / SUM(fol.order_item_quantity) ),2) AS average_net_sales_per_unit

FROM fact_order_lines fol 
INNER JOIN dim_date dd ON fol.order_date_key = dd.date_key
INNER JOIN dim_product dp ON fol.product_card_id = dp.product_card_id

WHERE dd.full_date >= '2017-09-01' AND dd.full_date < '2017-11-01'

GROUP BY dd.calendar_year, dd.month_number, dd.month_name, dp.category_id, dp.category_name
ORDER BY dd.calendar_year ,dd.month_number, SUM(fol.net_line_sales) DESC
;



-- Task: Confirm when each product category appears
-- Business Question: When did each product catgeory first and last appear in the sales data
-- Results: COnfirm that October 20017 chnage was a real product catelouge transition, not just ordinary monthly fluctuations 

-- Conclusion: Structural change in the dataset beginning in October 2017. Traditional sporting-goods categoires were replaced by broader retail
-- categories, whhile average units per order declined from 6.10 in September to 1.19 in October and 1.00 afterwards.
SELECT 
    dp.category_id,
    dp.category_name,
	MIN(dd.full_date) AS first_order_date, -- Finds the earliest date the category appeared in an oder
    MAX(dd.full_date) AS last_order_date,  -- Finds the latest date that category appeared in an order
    FORMAT(COUNT(DISTINCT fol.order_id),0) AS unique_orders,
    FORMAT(SUM(fol.order_item_quantity),0) AS total_units_sold,
    FORMAT(SUM(fol.net_line_sales),2) AS total_net_sales
    
FROM fact_order_lines fol 
INNER JOIN dim_date dd ON fol.order_date_key = dd.date_key
INNER JOIN dim_product dp ON fol.product_card_id = dp.product_card_id

GROUP BY dp.category_id, dp.category_name
ORDER BY first_order_date, dp.category_id
;


-- Task: Calculate month-over-month performance changes 
-- Business Question: How much did orders, net sales, and profit increase or decrease compared with the previous month
WITH monthly_performance AS (
	SELECT 
		dd.calendar_year,
		dd.month_number,
		dd.month_name,
        COUNT(DISTINCT fol.order_id) AS unique_orders,
        SUM(fol.net_line_sales) AS total_net_sales,
        SUM(fol.line_profit) AS total_profit
    FROM fact_order_lines fol
    INNER JOIN dim_date dd ON fol.order_date_key = dd.date_key
	GROUP BY dd.calendar_year, dd.month_number, dd.month_name
),
monthly_comparison AS (
	SELECT 
		calendar_year,
		month_number,
		month_name,
		unique_orders,
		total_net_sales,
		LAG(total_net_sales) OVER (
			ORDER BY calendar_year, month_number
		) AS previous_month_net_sales,
		total_profit,
    
		LAG(total_profit) OVER (
			ORDER BY calendar_year, month_number
		) AS previous_month_profit
	FROM monthly_performance
)

SELECT 
	calendar_year,
	month_number,
	month_name,
    FORMAT(unique_orders, 0) AS unique_orders,
    FORMAT(total_net_sales, 2) AS total_net_sales,
    FORMAT(previous_month_net_sales, 2) AS previous_month_net_sales,
    ROUND( ( (total_net_sales - previous_month_net_sales) / NULLIF(previous_month_net_sales,0) ) * 100, 2) AS month_over_month_net_sales_percentage,
    FORMAT(total_profit, 2) AS total_profit,
    FORMAT(previous_month_profit, 2) AS previous_month_profit

FROM monthly_comparison
ORDER BY calendar_year, month_number
;

