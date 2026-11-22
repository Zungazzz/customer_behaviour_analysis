-- Customer shopping behaviour: business questions and SQL
-- Table: shopping (one row per customer purchase, 3,900 rows)
-- Columns: customer_id, age, gender, item_purchased, category, purchase_amount,
--          location, size, color, season, review_rating, subscription_status,
--          shipping_type, discount_applied, previous_purchases, payment_method,
--          frequency_of_purchases, age_group, purchase_frequency_days

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'shopping_behavior'
ORDER BY ordinal_position;

-- Q1. What is the overall business snapshot?
SELECT COUNT(*)                          AS orders,
       SUM(purchase_amount)              AS total_revenue,
       ROUND(CAST(AVG(purchase_amount) AS NUMERIC), 2)    AS avg_order_value,
       ROUND(CAST(AVG(review_rating) AS NUMERIC), 2)      AS avg_rating
FROM shopping_behavior;

-- Q2. Which categories drive revenue, and is it volume or order size?
SELECT category,
       COUNT(*)                                                    AS orders,
       SUM(purchase_amount)                                        AS revenue,
       ROUND(100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER (), 1) AS revenue_share_pct,
       ROUND(CAST(AVG(purchase_amount) AS NUMERIC), 2)                              AS avg_order_value
FROM shopping_behavior
GROUP BY category
ORDER BY revenue DESC;

-- Q3. Is there seasonality in revenue or spend per order?
SELECT season,
       COUNT(*)                        AS orders,
       SUM(purchase_amount)            AS revenue,
       ROUND(CAST(AVG(purchase_amount) AS NUMERIC), 2)  AS avg_order_value
FROM shopping_behavior
GROUP BY season
ORDER BY revenue DESC;

-- Q4. Which items earn the most, and which are the weakest on revenue and rating?
SELECT item_purchased,
       COUNT(*)                        AS orders,
       SUM(purchase_amount)            AS revenue,
       ROUND(CAST(AVG(review_rating) AS NUMERIC), 2)    AS avg_rating
FROM shopping_behavior
GROUP BY item_purchased
ORDER BY revenue DESC;

-- Q5. Who are our customers, and does any age group or gender spend more?
SELECT age_group,
       gender,
       COUNT(*)                        AS orders,
       SUM(purchase_amount)            AS revenue,
       ROUND(CAST(AVG(purchase_amount) AS NUMERIC), 2)  AS avg_order_value
FROM shopping_behavior
GROUP BY age_group, gender
ORDER BY revenue DESC;

-- Q6. Do subscribers spend more or rate us higher than non-subscribers?
SELECT subscription_status,
       COUNT(*)                        AS orders,
       SUM(purchase_amount)            AS revenue,
       ROUND(CAST(AVG(purchase_amount) AS NUMERIC), 2)  AS avg_order_value,
       ROUND(CAST(AVG(review_rating) AS NUMERIC), 2)    AS avg_rating,
       ROUND(CAST(AVG(previous_purchases) AS NUMERIC), 1) AS avg_previous_purchases
FROM shopping_behavior
GROUP BY subscription_status;

-- Q7. Do discounts increase spend, or just give away margin?
SELECT discount_applied,
       subscription_status,
       COUNT(*)                        AS orders,
       ROUND(CAST(AVG(purchase_amount) AS NUMERIC), 2)  AS avg_order_value,
       SUM(purchase_amount)            AS revenue
FROM shopping_behavior
GROUP BY discount_applied, subscription_status
ORDER BY discount_applied, subscription_status;

-- Q8. Which states bring in the most revenue, and which have the highest spend per order?
SELECT location,
       COUNT(*)                        AS orders,
       SUM(purchase_amount)            AS revenue,
       ROUND(CAST(AVG(purchase_amount) AS NUMERIC), 2)  AS avg_order_value,
       ROUND(CAST(AVG(review_rating) AS NUMERIC), 2)    AS avg_rating
FROM shopping_behavior
GROUP BY location
ORDER BY revenue DESC
LIMIT 10;

-- Q9. Does shipping type affect spend or satisfaction?
SELECT shipping_type,
       COUNT(*)                        AS orders,
       ROUND(CAST(AVG(purchase_amount) AS NUMERIC), 2)  AS avg_order_value,
       ROUND(CAST(AVG(review_rating) AS NUMERIC), 2)    AS avg_rating
FROM shopping_behavior
GROUP BY shipping_type
ORDER BY avg_rating DESC;

-- Q10. Do frequent buyers spend more per order?
-- (purchase_frequency_days already merges duplicate labels: Bi-Weekly = Fortnightly, Every 3 Months = Quarterly)
SELECT purchase_frequency_days          AS days_between_purchases,
       COUNT(*)                         AS orders,
       ROUND(CAST(AVG(purchase_amount) AS NUMERIC), 2)   AS avg_order_value,
       SUM(purchase_amount)             AS revenue
FROM shopping_behavior
GROUP BY purchase_frequency_days
ORDER BY purchase_frequency_days;

-- Q11. Does a longer purchase history mean bigger orders?
SELECT CASE WHEN previous_purchases <= 10 THEN '1-10'
            WHEN previous_purchases <= 20 THEN '11-20'
            WHEN previous_purchases <= 30 THEN '21-30'
            WHEN previous_purchases <= 40 THEN '31-40'
            ELSE '41-50' END            AS purchase_history,
       COUNT(*)                         AS orders,
       ROUND(CAST(AVG(purchase_amount) AS NUMERIC), 2)   AS avg_order_value
FROM shopping_behavior
GROUP BY purchase_history
ORDER BY MIN(previous_purchases);

-- Q12. Which age groups are worth the most per year? (order value x purchases per year)
SELECT age_group,
       COUNT(*)                                                       AS customers,
       ROUND(CAST(AVG(purchase_amount) AS NUMERIC), 2)                AS avg_order_value,
       ROUND(CAST(AVG(365.0 / purchase_frequency_days) AS NUMERIC), 1) AS avg_purchases_per_year,
       ROUND(CAST(AVG(purchase_amount * 365.0 / purchase_frequency_days) AS NUMERIC), 0) AS est_annual_value
FROM shopping_behavior
GROUP BY age_group
ORDER BY est_annual_value DESC;

-- Q13. Do subscribers buy more often, making them worth more per year?
SELECT subscription_status,
       COUNT(*)                                                       AS customers,
       ROUND(CAST(AVG(365.0 / purchase_frequency_days) AS NUMERIC), 1) AS avg_purchases_per_year,
       ROUND(CAST(AVG(purchase_amount * 365.0 / purchase_frequency_days) AS NUMERIC), 0) AS est_annual_value
FROM shopping_behavior
GROUP BY subscription_status;

-- Q14. Which categories and seasons combine to the highest revenue?
SELECT category,
       season,
       SUM(purchase_amount)             AS revenue,
       COUNT(*)                         AS orders
FROM shopping_behavior
GROUP BY category, season
ORDER BY revenue DESC
LIMIT 8;