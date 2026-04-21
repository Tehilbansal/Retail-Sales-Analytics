-- ==============================
-- RETAIL SALES PROJECT (FINAL)
-- ==============================

-- 1. Create Database
CREATE DATABASE IF NOT EXISTS retail_sales_project;
USE retail_sales_project;

-- ==============================
-- 2. Create RAW Table
-- ==============================
DROP TABLE IF EXISTS orders_raw;

CREATE TABLE orders_raw (
    row_id INT,
    order_id VARCHAR(30),
    order_date VARCHAR(30),
    ship_date VARCHAR(30),
    ship_mode VARCHAR(50),
    customer_id VARCHAR(30),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country_region VARCHAR(50),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,4),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,4)
);

-- ==============================
-- 3. Load CSV into RAW Table
-- ==============================
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(row_id, order_id, order_date, ship_date, ship_mode, customer_id, customer_name, segment,
 country_region, city, state_province, postal_code, region, product_id, category,
 sub_category, product_name, sales, quantity, discount, profit);

-- ==============================
-- 4. Create CLEAN Table
-- ==============================
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    row_id INT,
    order_id VARCHAR(30),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(30),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country_region VARCHAR(50),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,4),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,4)
);

-- ==============================
-- 5. Insert Clean Data (Convert Dates)
-- ==============================
INSERT INTO orders
SELECT
    row_id,
    order_id,
    STR_TO_DATE(order_date, '%d-%m-%Y'),
    STR_TO_DATE(ship_date, '%d-%m-%Y'),
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country_region,
    city,
    state_province,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales,
    quantity,
    discount,
    profit
FROM orders_raw;

-- ==============================
-- 6. Validation Checks
-- ==============================
SELECT COUNT(*) AS total_rows FROM orders;

SELECT
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date
FROM orders;

SELECT * FROM orders LIMIT 5;

-- ==============================
-- 7. Overall Business Performance
-- ==============================
SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_quantity
FROM orders;

-- ==============================
-- 8. Monthly Sales Trend
-- ==============================
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(SUM(sales), 2) AS sales
FROM orders
GROUP BY month
ORDER BY month;

-- ==============================
-- 9. Top 10 Products (Revenue)
-- ==============================
SELECT
    product_name,
    ROUND(SUM(sales), 2) AS sales
FROM orders
GROUP BY product_name
ORDER BY sales DESC
LIMIT 10;

-- ==============================
-- 10. Category Profit Analysis
-- ==============================
SELECT
    category,
    ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY category
ORDER BY profit DESC;

-- ==============================
-- 11. Loss-Making Products
-- ==============================
SELECT
    product_name,
    ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY product_name
ORDER BY profit ASC
LIMIT 10;

-- ==============================
-- 12. Profit Margin by Category
-- ==============================
SELECT
    category,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin
FROM orders
GROUP BY category
ORDER BY profit_margin DESC;

-- ==============================
-- 13. Monthly Profit Trend
-- ==============================
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY month
ORDER BY month;

-- ==============================
-- 14. Monthly Sales & Profit Trend
-- ==============================
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY month
ORDER BY month;

-- ==============================
-- 15. Top 5 Customers
-- ==============================
SELECT
    customer_name,
    ROUND(SUM(sales), 2) AS total_sales
FROM orders
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 5;

-- ==============================
-- 16. Region Performance
-- ==============================
SELECT
    region,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY region
ORDER BY sales DESC;

-- ==============================
-- 17. High Sales but Negative Profit Products
-- ==============================
SELECT
    product_name,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY profit ASC;

-- ==============================
-- 18. Create View for Power BI
-- ==============================
DROP VIEW IF EXISTS vw_monthly_sales_profit;

CREATE VIEW vw_monthly_sales_profit AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(SUM(sales), 2) AS sales,
    ROUND(SUM(profit), 2) AS profit
FROM orders
GROUP BY month;