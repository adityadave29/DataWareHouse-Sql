--  This analysis helps to understand whetherrbusiness is growing or declining.

-- calculate the total sales per month
-- and the running total of sales over time

SELECT
    order_month,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM (
    SELECT 
        MONTH(order_date) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM Gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY MONTH(order_date)
) AS monthly_sales
ORDER BY order_month;

--  can find average as well. 