SET SQL_SAFE_UPDATES = 0;
SET SESSION wait_timeout        = 28800;
SET SESSION interactive_timeout = 28800;
SET SESSION net_read_timeout    = 3600;
SET SESSION net_write_timeout   = 3600;


-- 1. Tidy (customer IDs and addresses) so cities and states look consistent,
--    and IDs are properly stored

UPDATE olist_customers
SET
    customer_unique_id = LOWER(TRIM(customer_unique_id)),
    customer_city      = CONCAT(
                             UPPER(LEFT(TRIM(customer_city), 1)),
                             LOWER(SUBSTRING(TRIM(customer_city), 2))
                         ),
    customer_state     = UPPER(TRIM(customer_state));


UPDATE olist_geolocation
SET
    geolocation_city  = CONCAT(
                            UPPER(LEFT(TRIM(geolocation_city), 1)),
                            LOWER(SUBSTRING(TRIM(geolocation_city), 2))
                        ),
    geolocation_state = UPPER(TRIM(geolocation_state));


-- 2. Delivery dates show before the purchase date, which can't be true.

UPDATE olist_orders
SET order_delivered_customer_date = NULL
WHERE order_delivered_customer_date < order_purchase_timestamp;


-- 3. Some product prices and freight charges are recorded as negative or blank.
--    That's not possible. Make sure those values are corrected.

UPDATE olist_order_items
SET
    price = CASE
				WHEN price < 0         THEN NULL
				ELSE price
			END,
            
    freight_value = CASE
                        WHEN freight_value < 0 THEN NULL
                        ELSE freight_value
                    END;


-- 4. Some text columns contain empty strings (''), handle these values so they don't take
--    a space in the memory.

UPDATE olist_orders
SET
    order_id = NULLIF(TRIM(order_id), ''),
    customer_id = NULLIF(TRIM(customer_id), ''),
    order_status = NULLIF(TRIM(order_status), '');

UPDATE olist_order_items
SET
    order_id = NULLIF(TRIM(order_id), ''),
    order_item_id = NULLIF(TRIM(order_item_id), ''),
    product_id = NULLIF(TRIM(product_id), '');

UPDATE olist_customers
SET
    customer_id = NULLIF(TRIM(customer_id), ''),
    customer_unique_id = NULLIF(TRIM(customer_unique_id), ''),
    customer_city = NULLIF(TRIM(customer_city), ''),
    customer_state = NULLIF(TRIM(customer_state), ''),
    customer_zip_code_prefix = NULLIF(TRIM(customer_zip_code_prefix), '');

UPDATE olist_reviews
SET
    review_id = NULLIF(TRIM(review_id), ''),
    order_id = NULLIF(TRIM(order_id), ''),
    review_score = NULLIF(TRIM(review_score), '');

UPDATE olist_geolocation
SET
    geolocation_zip_code_prefix = NULLIF(TRIM(geolocation_zip_code_prefix), ''),
    geolocation_lat = NULLIF(TRIM(geolocation_lat), ''),
    geolocation_lng = NULLIF(TRIM(geolocation_lng), ''),
    geolocation_city = NULLIF(TRIM(geolocation_city), ''),
    geolocation_state = NULLIF(TRIM(geolocation_state), '');


-- 5. We see duplicate items in the same order.

DELETE FROM olist_order_items
WHERE (order_id, order_item_id, product_id) NOT IN (
    SELECT order_id, order_item_id, product_id
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY order_id, order_item_id
                   ORDER BY product_id
               ) AS rn
        FROM olist_order_items
    ) t
    WHERE rn = 1
);


-- 6. There are items linked to orders that don't exist in the orders table. That doesn't
--    make sense.

DELETE FROM olist_order_items
WHERE order_id NOT IN (SELECT order_id FROM olist_orders);


-- 7. All reviews must have a rating. If any review comes in without a score, it shouldn't
--    be in the system.

DELETE FROM olist_reviews
WHERE review_score IS NULL;


-- 8. Canceled orders should not appear in our KPIs. Please make sure they're excluded.

DELETE FROM olist_orders AS o
WHERE order_status = 'canceled';

SET SQL_SAFE_UPDATES = 0;


-- 9. Show us how much each customer has spent across their entire history so we can
--    identify our best customers.

CREATE TABLE customer_lifetime AS
SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(i.price) AS total_revenue,
    SUM(i.price) / COUNT(DISTINCT o.order_id) as avg_order_value
FROM olist_orders AS o
JOIN olist_order_items AS i USING (order_id)
GROUP BY o.customer_id
ORDER BY total_revenue DESC;


-- 10. Make sure every review is linked to a valid order before we trust it in reporting.

DELETE FROM olist_reviews AS r
WHERE r.order_id NOT IN (
    SELECT order_id
    FROM olist_orders
);


-- 1. What are our monthly sales?

SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(price), 2) AS total_sales,
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_order_items
JOIN olist_orders USING (order_id)
GROUP BY month
ORDER BY month;


-- 2. Which 10 products bring in the most money? And how many unique customers
--    bought each one?

SELECT
    product_id,
    ROUND(SUM(price) + SUM(freight_value), 2) AS total_sales,
    COUNT(DISTINCT customer_id)               AS total_customers
FROM olist_order_items
JOIN olist_orders USING (order_id)
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;


-- 3. On average, how many days does delivery take each month? Which months had the
--    worst delays?

SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)) AS average_delay
FROM olist_orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY month
ORDER BY month;


-- 4. What's our average review score per month? Highlight months where it drops below 3.

SELECT
    DATE_FORMAT(review_creation_date, '%Y-%m') AS month,
    ROUND(AVG(review_score), 2) AS score
FROM olist_reviews
GROUP BY month
HAVING score < 3;


-- 5. Which states or cities generate the highest revenue per customer?

SELECT
    customer_city,
    AVG(price) AS avg_revenue
FROM olist_customers
JOIN olist_orders USING (customer_id)
JOIN olist_order_items USING (order_id)
GROUP BY customer_city
ORDER BY avg_revenue DESC;


-- 6. Does paying higher freight charges mean faster delivery?

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS sale_month,
    ROUND(AVG(i.freight_value), 2) AS avg_freight,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)), 2) AS avg_delay_days
FROM olist_orders AS o
JOIN olist_order_items i USING (order_id)
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY sale_month
ORDER BY sale_month;


-- 7. Show us how much each customer has spent across their entire history so we can
--    identify our best customers.

SELECT *
FROM customer_lifetime c
ORDER BY c.total_price DESC;


-- 8. Which day of week receives the most orders?

SELECT
    DAYNAME(order_purchase_timestamp) AS day,
    COUNT(*) AS total_orders
FROM olist_orders
GROUP BY day
ORDER BY total_orders DESC;


-- 9. How many customers made more than one order? What share of all customers is that?

WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM olist_customers c
    JOIN olist_orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(order_count >= 2) AS repeated_customers,
    ROUND(100.0 * SUM(order_count > 1) / COUNT(*), 2) AS percentage
FROM customer_order_counts;