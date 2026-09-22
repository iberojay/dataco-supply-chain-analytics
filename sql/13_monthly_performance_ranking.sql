-- Task: Rank monthly performance 
-- Business Question: Which months generated the most net sales, and did sales increase or decrease and compared with the previous month?
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
    RANK () OVER (ORDER BY total_net_sales DESC) AS net_sales_rank,
    CASE
		WHEN previous_month_net_sales IS NULL THEN 'No Previous month'
        WHEN total_net_sales > previous_month_net_sales THEN 'Sales increased'
        WHEN total_net_sales < previous_month_net_sales THEN 'Sales decreased'
        ELSE 'No Change'
	END AS monthly_performance_status
    
FROM monthly_comparison
ORDER BY calendar_year, month_number
;
