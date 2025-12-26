-- DROP TABLE IF EXISTS Bronze.crm_cust_info;
CREATE TABLE Bronze.crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);

-- DROP TABLE IF EXISTS Bronze.crm_prd_info;
CREATE TABLE Bronze.crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

-- DROP TABLE IF EXISTS Bronze.crm_sales_details;
CREATE TABLE Bronze.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

-- DROP TABLE IF EXISTS Bronze.erp_cust_az12;
CREATE TABLE Bronze.erp_cust_az12(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);

-- DROP TABLE IF EXISTS Bronze.erp_loc_a101;
CREATE TABLE Bronze.erp_loc_a101(
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

-- DROP TABLE IF EXISTS Bronze.erp_px_cat_g1v2;
CREATE TABLE Bronze.erp_px_cat_g1v2(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);


--  INSERT DATA FROM CSV TO TABLES;

TRUNCATE TABLE Bronze.crm_cust_info;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE Bronze.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE Bronze.crm_prd_info;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE Bronze.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE Bronze.crm_sales_details;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE Bronze.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE Bronze.erp_cust_az12;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
INTO TABLE Bronze.erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE Bronze.erp_loc_a101;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_erp/loc_a101.csv'
INTO TABLE Bronze.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE Bronze.erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE '/Users/adityadave/sql-data-warehouse-project/datasets/source_erp/px_cat_g1v2.csv'
INTO TABLE Bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
