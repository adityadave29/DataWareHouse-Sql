-- Find Youngest and Oldest customer
SELECT 
MAX(birthdate) AS youngest_customer,
MIN(birthdate) AS oldest_customer
FROM Gold.dim_customers;

-- In years as well
SELECT 
    TIMESTAMPDIFF(YEAR, MAX(birthdate), CURDATE()) AS youngest_customer,
    TIMESTAMPDIFF(YEAR, MIN(birthdate), CURDATE()) AS oldest_customer 
FROM Gold.dim_customers;

-- Measures (Total Sales and all)
-- Find total Sales

SELECT SUM(sales_amount) AS total_sale
FROM Gold.fact_sales;

-- Find how many items are sold

SELECT SUM(quantity) AS total_quantity
FROM Gold.fact_sales;

-- Find the average selling price
SELECT ROUND(AVG(price)) AS avg_price
FROM Gold.fact_sales;

-- Find the Total number of Orders
SELECT COUNT(order_number) AS total_orders
FROM Gold.fact_sales;

SELECT COUNT(DISTINCT order_number) AS total_orders
FROM Gold.fact_sales;

-- Find the total number of products
SELECT COUNT(product_id) AS total_products
FROM Gold.dim_products;

-- Find total number of customers
SELECT COUNT(customer_key) AS total_customers
FROM Gold.dim_customers;

SELECT COUNT(DISTINCT customer_key) AS unique_customers
FROM Gold.fact_sales;

-- Generate KPI report
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value
FROM Gold.fact_sales

UNION ALL
SELECT 'Total Quantity', SUM(quantity)
FROM Gold.fact_sales

UNION ALL
SELECT 'Average Price', ROUND(AVG(price))
FROM Gold.fact_sales

UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number)
FROM Gold.fact_sales

UNION ALL
SELECT 'Total Products', COUNT(product_key)
FROM Gold.dim_products

UNION ALL
SELECT 'Total Customers', COUNT(customer_key)
FROM Gold.dim_customers

UNION ALL
SELECT 'Unique Customers', COUNT(DISTINCT customer_key)
FROM Gold.fact_sales;


-- Find total customers by country
SELECT country, COUNT(*) AS total_customers
FROM Gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;


-- Find total customer by gender
SELECT gender, COUNT(*) AS total_customers
FROM Gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Find total products by category
SELECT category, COUNT(*) AS total_products 
FROM Gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Average cost in each category
SELECT category, AVG(cost) AS average_price
FROM Gold.dim_products
GROUP BY category
ORDER BY average_price DESC;

-- Total revenue generated for each category
SELECT p.category, SUM(s.sales_amount) AS total_sales
FROM Gold.fact_sales AS s 
JOIN Gold.dim_products AS p 
ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;

-- Total revenue generate by each customer print custome id, name and total revenue
SELECT 
c.customer_key,
c.first_name,
c.last_name,
SUM(s.sales_amount) AS total_purchase
FROM Gold.fact_sales AS s 
LEFT JOIN Gold.dim_customers AS c 
ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_purchase DESC LIMIT 10;

