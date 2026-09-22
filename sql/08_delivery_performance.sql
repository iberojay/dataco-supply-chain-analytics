-- First delivery
--  1. Determine how many unique orders fall under each delivery status 
SELECT 
	delivery_status, 
    COUNT(DISTINCT order_id) AS number_of_orders
FROM fact_order_lines
GROUP BY delivery_status
ORDER BY number_of_order DESC;


-- Percentage by delivery status 
SELECT 
	delivery_status, 
    COUNT(DISTINCT order_id) AS number_of_orders,
    
    ROUND(
		COUNT(DISTINCT order_id) * 100 
        / 
		(
			SELECT COUNT(DISTINCT order_id)
            FROM fact_order_lines
        ),2
	) AS percentage_of_orders,
    
    (
		SELECT COUNT(DISTINCT order_id)
        FROM fact_order_lines
    ) AS total_orders
    
FROM fact_order_lines
GROUP BY delivery_status
ORDER BY number_of_orders DESC;

-- Returned:
-- 	54.82% were delivered late
-- 	23.01% delievered early
-- 	17.83% delivered on time 
-- 	4.34% canceled

-- 40.84% were either early or on time, whiule more than half were late


-- Shipping-time performance
-- 	Determine: Average actual shipping days, average scheduled shipping days
SELECT 
	ROUND(AVG(days_for_shipping_real),2) AS avg_actual_shipping_days, 
    ROUND(AVG(days_for_shipment_scheduled),2) AS avg_scheduled_shipping_days
FROM (
	SELECT DISTINCT
		order_id,
        days_for_shipping_real,
        days_for_shipment_scheduled
	FROM fact_order_lines
) AS unique_orders;

-- Average actual shipping time: 3.50 days
-- Average scheduled shipping time: 2.93 days
-- Orders took approximately: 0.57 additional days

-- Average shipping variance 
SELECT 
	COUNT(*) AS all_order_types,
	ROUND(AVG(days_for_shipping_real),2) AS avg_actual_shipping_days, 
    ROUND(AVG(days_for_shipment_scheduled),2) AS avg_scheduled_shipping_days,
    ROUND( 
		AVG( CAST(days_for_shipping_real AS SIGNED) - CAST(days_for_shipment_scheduled AS SIGNED)
        ),2
	) AS avg_shipping_variance_days
FROM (
	SELECT DISTINCT
		order_id,
        days_for_shipping_real,
        days_for_shipment_scheduled
	FROM fact_order_lines
) AS unique_orders;

-- 65,752 total orders
-- 3.50: average time orders actually took to ship
-- 2.93: average time orders were scheduled to take
-- 0.57: average difference between actual and sheduled shipping time
-- "Orders took an average of 0.57 days longer then scheduled"


-- Calculate shipping-time excluding cancled orders
--  Why? 
SELECT 
	COUNT(*) AS included_orders,
	ROUND(AVG(days_for_shipping_real),2) AS avg_actual_shipping_days, 
    ROUND(AVG(days_for_shipment_scheduled),2) AS avg_scheduled_shipping_days,
    ROUND( 
		AVG( CAST(days_for_shipping_real AS SIGNED) - CAST(days_for_shipment_scheduled AS SIGNED)
        ),2
	) AS avg_shipping_variance_days
FROM (
	SELECT DISTINCT
		order_id,
        days_for_shipping_real,
        days_for_shipment_scheduled
	FROM fact_order_lines
    WHERE delivery_status <> 'Shipping canceled'
) AS unique_orders;

-- 62,897 delivered/non-canceled orders
-- Actual shipping: 3.50 -> 3.50
-- Scheduled shipping: 2.93 -> 2.94
-- Variance: 0.57 - 0.57
-- Removing cancled orders did not change the averages becuase cancleded orders had shhipping values similar to the rest of the dataset


-- Task: Determine which shipping_mode performs best or worst
--  Calculates the shipping averages once per UNIQUE order
--  Groups result by shipping mode and ranks the modes from the largest average dely to the smallest 
SELECT 
	shipping_mode,
    COUNT(*) AS included_orders, -- Orders that have been delivered/non-canceled orders
	ROUND(AVG(days_for_shipping_real),2) AS avg_actual_shipping_days, 
    ROUND(AVG(days_for_shipment_scheduled),2) AS avg_scheduled_shipping_days,
    ROUND( 
		AVG( CAST(days_for_shipping_real AS SIGNED) - CAST(days_for_shipment_scheduled AS SIGNED)
        ),2
	) AS avg_shipping_variance_days
    
FROM (
	SELECT DISTINCT
		order_id,
        shipping_mode,
        days_for_shipping_real,
        days_for_shipment_scheduled
	FROM fact_order_lines
    WHERE delivery_status <> 'Shipping canceled'
) AS unique_orders

GROUP BY shipping_mode
ORDER BY avg_shipping_variance_days DESC
;

-- Results:
-- Second class: scheduled a average of 2 days but takes an average of 4 days, causing a average delay of 2 days. "Worst performing mode"
-- First class: Scheduled an average of 1 day, takes an average of 2 days, causing a average delay of 1 day. 
-- Same day: Scheduled 0 days but took 0.48 days. Average delay of 0.48 days
-- Standard Class: Scheduled 4 days and took 3.99 days. Average of 0.01 days EARLIER. Mkaing it the only mode that generally met its promise

-- "Second class, has the largest gap between customer expecations and actual performance"


-- Task: Calculate the late-delivery rate for each shipping mode 
-- Answers: What percentage of orders using each shipping mode were delivered late
-- Late delivery risk: 0 = order was not delivered late, 1 = order was delivered late

-- Query understanding: 
--  For each shipping mode, count the non canceleed orders (hence delivery status is NOT EQUAL to 'shipping canceled', count how many were late,
--  and calulate the percentage that were late
SELECT 
	shipping_mode,  -- One row for each shipping mode due to GROUP BY
    COUNT(*) AS included_orders, -- Count rows in each shipping mode, subquery reduces to orders that were not canceled
    -- late delivery is 1 (order was late) and 0 (not late), summing them counts how many orders were late
	SUM(late_delivery_risk) as late_orders, 
    -- Calculate percentage of late deliveries for each shipping mode:
    --   - Divides late orders by the number of total late orders in each shipping mode
    ROUND((SUM(late_delivery_risk) / COUNT(*)) * 100.0 , 2) AS late_delivery_percentage
    

FROM (
	SELECT DISTINCT -- Removes duplciate combinations of the selcted columns, necessray becuase fact_order_llines row i per product, NOT per order_date_key
		order_id,  -- Hence distincy order_id will show multiple time for each order line but we only need the one recipt
        shipping_mode,
        late_delivery_risk
	FROM fact_order_lines
    WHERE delivery_status <> 'Shipping canceled'
) AS unique_orders

GROUP BY shipping_mode 
ORDER BY late_delivery_percentage DESC -- Go from largest to smallest late delivery percentage
;


-- Order late delivery from highest to lowest percentage:
--  First class had the highest delay frequency, with every included order classified as late. Second class had the largest average delay at two
--  days, meaning First class was late more consistently, while Second Class missed its scheudle by a greater amount
SELECT 
	shipping_mode,  -- One row for each shipping mode due to GROUP BY
    COUNT(*) AS included_orders, -- Count rows in each shipping mode, subquery reduces to orders that were not canceled
    -- late delivery is 1 (order was late) and 0 (not late), summing them counts how many orders were late
	SUM(late_delivery_risk) as late_orders, 
    -- Calculate percentage of late deliveries for each shipping mode:
    --   - Divides late orders by the number of total late orders in each shipping mode
    ROUND((SUM(late_delivery_risk) / COUNT(*)) * 100.0 , 2) AS late_delivery_percentage
    

FROM (
	SELECT DISTINCT -- Removes duplciate combinations of the selcted columns, necessray becuase fact_order_llines row i per product, NOT per order_date_key
		order_id,  -- Hence distincy order_id will show multiple time for each order line but we only need the one recipt
        shipping_mode,
        late_delivery_risk
	FROM fact_order_lines
    WHERE delivery_status <> 'Shipping canceled'
) AS unique_orders

GROUP BY shipping_mode 
ORDER BY late_delivery_percentage DESC -- Go from largest to smallest late delivery percentage
;


-- Task: compare late-delivery performance by market 
-- Business question: Which markets have the highest percentage of late orders
-- Key insights:
--  Pacific Asia highest late-delivery rate 57.68%, Europe has the most late orders '10,199' becuase it has the greatest order volumn 
--  Aftrica has the lowest late-delivery rate, but still very high at 56.55%
--  All 5 markets fall within a narrow range of 56.55%-57.68%

-- Late-delivery rates are consistently high across all five markets, with only a 1.13 percentage-point difference between the highest and lowest
-- markets. This suggest that late delivery is probably a company-wide shipping-process problem rather than an issue isloated to once geographical
-- market.

-- Remember: 
--  Late orders measures volume 
--  Late-delivery percentage measures performace relative to the number of orders in that market
SELECT 
	dl.market,
    COUNT(*) AS included_orders,
    SUM(late_delivery_risk) AS late_orders,
    ROUND((SUM(late_delivery_risk) / COUNT(*)) * 100.0 , 2) AS late_delivery_percentage
    
FROM (
	SELECT DISTINCT -- Removes duplciate combinations of the selcted columns, necessray becuase fact_order_llines row i per product, NOT per order_date_key
		order_id,  -- Hence distincy order_id will show multiple time for each order line but we only need the one recipt
        late_delivery_risk,
        location_id
	FROM fact_order_lines
    WHERE delivery_status <> 'Shipping canceled'
) AS unique_orders 
JOIN dim_location dl ON dl.location_id = unique_orders.location_id

GROUP BY dl.market
ORDER BY late_delivery_percentage DESC
;

