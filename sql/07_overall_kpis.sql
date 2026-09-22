-- Business Ana;ysis 

-- Task 1: Produce one-row summary of the operations 
-- Baseline operational KPIs
-- 	180,519 order lines
-- 	65,752 unique orders 
-- 	384,079 units sold 
SELECT 
	COUNT(*) AS total_order_lines, -- Number of individual product lines processed
    COUNT(DISTINCT order_id) AS total_unique_orders, -- Number of separate customer orders
    SUM(order_item_quantity) AS total_units_sold, -- Total number of physical units ordered
    SUM(gross_line_sales) AS total_value_before_discounts, -- Sales before discounts
    SUM(discount_amount) AS total_discounts_given, -- Discounts
    SUM(net_line_sales) AS total_value_after_discounts, -- ASles after discounts
    SUM(line_profit) AS total_profit, -- Profit 
    ROUND(((SUM(line_profit) / SUM(net_line_sales)) * 100),2) AS profit_margin_percentage

FROM fact_order_lines;

-- Profit margin measure the percentage of net sales retained as profit 
-- 12% profit margin means $0.12 of every $1.00 in net sales was profit 
-- Calcualted from using (total line profit / total net sales) * 100

