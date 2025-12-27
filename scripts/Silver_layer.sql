/* =========================================================
   SILVER LAYER – TABLE CREATION
   ========================================================= */

DROP TABLE IF EXISTS Silver.crm_cust_info;
CREATE TABLE Silver.crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS Silver.crm_prd_info;
CREATE TABLE Silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS Silver.crm_sales_details;
CREATE TABLE Silver.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS Silver.erp_cust_az12;
CREATE TABLE Silver.erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS Silver.erp_loc_a101;
CREATE TABLE Silver.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS Silver.erp_px_cat_g1v2;
CREATE TABLE Silver.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


/* =========================================================
   SILVER LAYER – DATA LOAD WITH AUDIT COLUMN
   ========================================================= */

TRUNCATE TABLE Silver.crm_cust_info;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE Silver.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SET dwh_create_date = CURRENT_TIMESTAMP;

TRUNCATE TABLE Silver.crm_prd_info;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE Silver.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SET dwh_create_date = CURRENT_TIMESTAMP;

TRUNCATE TABLE Silver.crm_sales_details;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE Silver.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SET dwh_create_date = CURRENT_TIMESTAMP;

TRUNCATE TABLE Silver.erp_cust_az12;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
INTO TABLE Silver.erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    cid,
    bdate,
    gen
)
SET dwh_create_date = CURRENT_TIMESTAMP;

TRUNCATE TABLE Silver.erp_loc_a101;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_erp/loc_a101.csv'
INTO TABLE Silver.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    cid,
    cntry
)
SET dwh_create_date = CURRENT_TIMESTAMP;

TRUNCATE TABLE Silver.erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_erp/px_cat_g1v2.csv'
INTO TABLE Silver.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    id,
    cat,
    subcat,
    maintenance
)
SET dwh_create_date = CURRENT_TIMESTAMP;

-- ============================================================ crm_cust_info ==========================================================================



-- Null Check and Duplicates in Primary Key
SELECT * FROM Bronze.crm_cust_info


-- CHECK FOR DUPLICATE AND NULL cst_id
SELECT cst_id, COUNT(*)
FROM Bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- SELECT cst_id, COUNT(*)
-- FROM Silver.crm_cust_info
-- GROUP BY cst_id
-- HAVING COUNT(*) > 1;

-- List duplicate rows (keeping the latest by cst_create_date)
SELECT *
FROM (
    SELECT 
        c.*,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id 
            ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM Bronze.crm_cust_info c
) t
WHERE flag_last <> 1
   OR cst_id IS NULL;


-- Unwanted spaces in all varchar fields

SELECT crm_cust_info.cst_firstname
FROM Bronze.crm_cust_info
WHERE crm_cust_info.cst_firstname <> TRIM(crm_cust_info.cst_firstname);

-- SELECT crm_cust_info.cst_firstname
-- FROM Silver.crm_cust_info
-- WHERE crm_cust_info.cst_firstname <> TRIM(crm_cust_info.cst_firstname);

-- TRIM FOR first name and last name
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM Bronze.crm_cust_info;


-- Data Standardization and Consistency
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM Bronze.crm_cust_info;

-- INSERT INTO Main Table

INSERT INTO Silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT 
        c.*,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM Bronze.crm_cust_info c
) t
WHERE t.flag_last = 1
  AND t.cst_id IS NOT NULL;


-- ============================================================ crm_prd_info ==========================================================================

SELECT * FROM crm_prd_info;

-- No Duplicates
SELECT prd_id, COUNT(*)
FROM Bronze.crm_prd_info
GROUP BY prd_id 
HAVING COUNT(*) > 1;

-- No Null values
SELECT * FROM Bronze.crm_prd_info WHERE prd_id IS NULL;



INSERT INTO Silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT 
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7) AS prd_key,
    prd_nm,
    IFNULL(prd_cost, 0) AS prd_cost,
    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(
        DATE_SUB(
            LEAD(prd_start_dt) OVER (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ),
            INTERVAL 1 DAY
        ) AS DATE
    ) AS prd_end_dt
FROM Bronze.crm_prd_info;




-- check unwanted whitespaces in product name
SELECT prd_nm
FROM Bronze.crm_prd_info
WHERE TRIM(prd_nm) <> prd_nm;





-- =================================== crm_sales_details ===========================================
INSERT INTO Silver.crm_sales_details(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
 SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE 
        WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) <> 8 THEN NULL
        ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
    END AS sls_order_dt,

    CASE 
        WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) <> 8 THEN NULL
        ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
    END AS sls_ship_dt,

    CASE 
        WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) <> 8 THEN NULL
        ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
    END AS sls_due_dt,

    CASE
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> sls_quantity * ABS(sls_price)
        THEN  sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0 
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM Bronze.crm_sales_details;

-- ======================================= erp_cust_az12 =========================================

UPDATE Silver.erp_cust_az12
SET gen = NULLIF(REGEXP_REPLACE(gen, '[^A-Za-z]', ''),'');

INSERT INTO Silver.erp_cust_az12(
    cid, bdate, gen
)
SELECT 
    CASE
        WHEN cid LIKE 'NAS%'
        THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid,
    CASE
        WHEN bdate > CURDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM Bronze.erp_cust_az12;

SELECT TRIM(gen) FROM Silver.erp_cust_az12 GROUP BY gen;

SELECT * FROM Bronze.erp_cust_az12;

TRUNCATE TABLE Silver.erp_cust_az12;

UPDATE Silver.erp_cust_az12
SET
    cid = CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
        ELSE cid
    END,
    bdate = CASE
        WHEN bdate > CURDATE() THEN NULL
        ELSE bdate
    END,
    gen = CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END;


-- ============================= erp_loc_a101 ============================================================


UPDATE Bronze.erp_loc_a101
SET cntry = NULLIF(REGEXP_REPLACE(cntry, '[^A-Za-z]', ''),'');

TRUNCATE TABLE Silver.erp_loc_a101;
INSERT INTO Silver.erp_loc_a101 (cid, cntry)
SELECT
REPLACE (cid, '-','') cid,
CASE 
    WHEN TRIM(cntry) = 'DE' THEN 'Germany'
    WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
    WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
    ELSE TRIM(cntry)
END AS cntry
FROM Bronze.erp_loc_a101;

-- ============================== erp_px_cat_g1v2 ==================================================

DROP TABLE IF EXISTS Silver.erp_px_cat_g1v2;
CREATE TABLE Silver.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50),
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintenance
)

SELECT 
id,
cat,
subcat,
maintenance
FROM Bronze.erp_px_cat_g1v2;

UPDATE Bronze.erp_px_cat_g1v2
SET cat = NULLIF(REGEXP_REPLACE(cat, '[^A-Za-z]', ''),'');

UPDATE Bronze.erp_px_cat_g1v2
SET subcat = NULLIF(REGEXP_REPLACE(subcat, '[^A-Za-z]', ''),'');

UPDATE Bronze.erp_px_cat_g1v2
SET maintenance = NULLIF(REGEXP_REPLACE(maintenance, '[^A-Za-z]', ''),'');

UPDATE Bronze.erp_px_cat_g1v2
SET maintenance = NULLIF(REGEXP_REPLACE(maintenance, '[^A-Za-z]', ''),'');

-- All Silver layer tables are clean, structured and properly maintained.