

/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/
-- Check for Nulls or Duplciates in the primary key
-- Expectation : No result

SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces
-- Expectation : No result

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Data Standardization & Consistency

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

-- Data Standardization & Consistency

SELECT DISTINCT cst_material_status
FROM silver.crm_cust_info

SELECT * FROM
silver.crm_cust_info
--------------------------
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted Spaces
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for NULLs or Negative Numbers
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for NULLs or Negative Numbers
-- Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

SELECT *
FROM silver.crm_prd_info

----------Clean and transform the sales details table

-- Check for Invalid Dates
SELECT 
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) != 8
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101;

   -- OR

 -- Check for Invalid Dates in the Silver Tier
SELECT 
    sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL 
   OR sls_order_dt > '2050-01-01'
   OR sls_order_dt < '1900-01-01';

   -- Check for Invalid Date Orders
SELECT
    *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Between Sales, Quantity, and Price
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative.

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

SELECT * FROM silver.crm_sales_details

-- Clean and transform the ERP location table

-- Identify Out-of-Range Dates
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT gen
FROM silver.erp_cust_az12;


-- Clean and transform the ERP location table2  

-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

SELECT * FROM silver.erp_loc_a101

-- Clean and transform the ERP product category table

-- Check for unwanted Spaces across all text columns
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2


EXEC silver.load_silver;
EXEC bronze.load_bronze;
