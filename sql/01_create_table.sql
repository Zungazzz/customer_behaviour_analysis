-- 01_create_table.sql
-- Creates the shopping_behavior table (PostgreSQL) for the cleaned dataset
-- Source file: data/processed/customer_shopping_behavior_cleaned.csv

DROP TABLE IF EXISTS public.shopping_behavior;

CREATE TABLE public.shopping_behavior (
    customer_id              INT PRIMARY KEY,
    age                      INT,
    gender                   VARCHAR(10),
    item_purchased           VARCHAR(50),
    category                 VARCHAR(50),
    purchase_amount          INT,
    location                 VARCHAR(50),
    size                     VARCHAR(5),
    color                    VARCHAR(30),
    season                   VARCHAR(10),
    review_rating            NUMERIC(2,1),
    subscription_status      VARCHAR(3),
    shipping_type            VARCHAR(30),
    discount_applied         VARCHAR(3),
    previous_purchases       INT,
    payment_method           VARCHAR(30),
    frequency_of_purchases   VARCHAR(30),
    age_group                VARCHAR(20),
    purchase_frequency_days  INT
);

-- Load the cleaned CSV
-- Option 1 (psql): run from the repo root so the relative path works
-- \copy public.shopping_behavior FROM 'data/processed/customer_shopping_behavior_cleaned.csv' CSV HEADER;

-- Option 2 (pgAdmin): right-click the table > Import/Export Data
--   Format: csv | Header: on | Delimiter: ,

-- Quick checks after loading
SELECT COUNT(*) AS total_rows FROM public.shopping_behavior;   -- expect 3900
SELECT * FROM public.shopping_behavior LIMIT 5;
