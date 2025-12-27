
-- ========================================== CUSTOMER ==============================================

DROP VIEW IF EXISTS Gold.dim_customers;

CREATE VIEW Gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
   CASE 
        WHEN la.cntry IS NULL OR TRIM(la.cntry) = '' THEN 'n/a'
        ELSE la.cntry
    END AS country,
    ci.cst_marital_status AS marital_status,
    CASE 
        WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ce.gen, 'n/a')
    END AS gender,
    ce.bdate AS birthdate,
    ci.cst_create_date AS created_date
FROM Silver.crm_cust_info AS ci
LEFT JOIN Silver.erp_cust_az12 AS ce
    ON ci.cst_key = ce.cid
LEFT JOIN Silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;


--  We have 2 columns for gender so here we are merging into one. So CRM is superior so first if we have Male or Female in crm then we will consider that otherwise we will look into erp else we will put n/a. 
SELECT DISTINCT
    ci.cst_gndr,
    ce.gen,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ce.gen, 'n/a')
    END AS new_gen
FROM Silver.crm_cust_info AS ci 
LEFT JOIN Silver.erp_cust_az12 AS ce 
ON ci.cst_key = ce.cid; 


-- ======================= Quality Check ===================================

SELECT DISTINCT gender from Gold.dim_customers;



-- ========================================== PRODUCT ==============================================
DROP VIEW IF EXISTS Gold.dim_products;
CREATE VIEW Gold.dim_products AS
SELECT
    ROW_NUMBER() OVER(ORDER BY pr.prd_start_dt, pr.prd_key) AS product_key,
    pr.prd_id AS product_id,
    pr.prd_key AS product_number,
    pr.prd_nm AS product_name,
    pr.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance AS maintenance,
    pr.prd_cost AS cost,
    pr.prd_line AS product_line,
    pr.prd_start_dt AS start_date
FROM Silver.crm_prd_info AS pr
LEFT JOIN Silver.erp_px_cat_g1v2 AS pc
ON pr.cat_id = pc.id 
WHERE pr.prd_end_dt IS NULL; -- filter out all historical data

-- ==================================== SALES =========================================================

CREATE VIEW Gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;

-- EDA

SELECT DISTINCT country FROM Gold.dim_customers;

SELECT DISTINCT category FROM Gold.dim_products; 

SELECT DISTINCT category, subcategory FROM Gold.dim_products ORDER BY category;