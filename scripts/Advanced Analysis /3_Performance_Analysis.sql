-- comparing current value and target value.

-- Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previous year's sales.

/* Analyze yearly product performance by comparing:
   1) yearly sales vs product average yearly sales
   2) yearly sales vs previous year's sales */

SELECT
    product_key,
    sales_year,
    yearly_sales,

    AVG(yearly_sales) OVER (
        PARTITION BY product_key
    ) AS avg_yearly_sales,

    CASE
        WHEN yearly_sales 
             > AVG(yearly_sales) OVER (PARTITION BY product_key)
        THEN 'Above Average'
        WHEN yearly_sales 
             < AVG(yearly_sales) OVER (PARTITION BY product_key)
        THEN 'Below Average'
        ELSE 'At Average'
    END AS avg_performance_flag,

    LAG(yearly_sales) OVER (
        PARTITION BY product_key
        ORDER BY sales_year
    ) AS prev_year_sales,

    yearly_sales
        - LAG(yearly_sales) OVER (
            PARTITION BY product_key
            ORDER BY sales_year
        ) AS yoy_change,

    CASE
        WHEN LAG(yearly_sales) OVER (
                PARTITION BY product_key
                ORDER BY sales_year
             ) IS NULL
        THEN 'No Prior Year'
        WHEN yearly_sales 
             > LAG(yearly_sales) OVER (
                    PARTITION BY product_key
                    ORDER BY sales_year
               )
        THEN 'Growth'
        WHEN yearly_sales 
             < LAG(yearly_sales) OVER (
                    PARTITION BY product_key
                    ORDER BY sales_year
               )
        THEN 'Decline'
        ELSE 'No Change'
    END AS yoy_trend

FROM (
    SELECT
        product_key,
        YEAR(order_date) AS sales_year,
        SUM(sales_amount) AS yearly_sales
    FROM Gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY product_key, YEAR(order_date)
) AS yearly_product_sales
ORDER BY product_key, sales_year;
