TRUNCATE TABLE dataco_operations.stg_dataco_order_lines;
LOAD DATA LOCAL INFILE
'/Users/jay/Desktop/Unemployed Journey/Data-Analytics-Project/multi-location-operations-analytics/excel/data_clean_utf8.csv'
INTO TABLE dataco_operations.stg_dataco_order_lines
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    record_type,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    delivery_status,
    late_delivery_risk,
    category_id,
    category_name,
    customer_city,
    customer_country,
    customer_id,
    customer_segment,
    customer_state,
    department_id,
    department_name,
    latitude,
    longitude,
    market,
    order_city,
    order_country,
    order_customer_id,
    order_date,
    order_id,
    order_item_cardprod_id,
    discount_amount,
    order_item_discount_rate,
    order_item_id,
    order_item_product_price,
    line_profit_ratio,
    order_item_quantity,
    gross_line_sales,
    net_line_sales,
    line_profit,
    order_region,
    order_state,
    order_status,
    product_card_id,
    product_category_id,
    product_image,
    product_name,
    product_price,
    product_status,
    shipping_date,
    @shipping_mode
)
SET shipping_mode = TRIM(TRAILING '\r' FROM @shipping_mode);