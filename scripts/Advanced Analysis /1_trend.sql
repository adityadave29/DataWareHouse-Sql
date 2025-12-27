-- Sales over years
SELECT YEAR(order_date) AS year, SUM(sales_amount) AS sales
FROM Gold.fact_sales
GROUP BY YEAR(order_date)
ORDER BY sales DESC;

SELECT MONTH(order_date) AS year, SUM(sales_amount) AS sales
FROM Gold.fact_sales
GROUP BY MONTH(order_date)
ORDER BY sales DESC;

-- Here we are visualizing sales trend over years.

