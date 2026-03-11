/*
======================================================================
DDL Script: Create Bronze Tables
==================================================================
Script purpose:
      This script creates tables in the bronze schema, dropping existing tables
      if the alredy exist.
      Run this script to re-define the DDL structure of bronze Tables
====================================================
*/
IF object_id('bronze.crm_cust_info','U') is not null
	drop table bronze.crm_cust_info
GO
CREATE TABLE bronze.crm_cust_info(
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_material_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date nvarchar(50)
)
GO
IF object_id('bronze.crm_prd_info','U') is not null
	drop table bronze.crm_prd_info
GO
CREATE TABLE bronze.crm_prd_info(
	prd_id int,
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost int,
	prd_line nvarchar(50),
	prd_start_dt datetime,
	prd_end_dt datetime
)
GO
IF object_id('bronze.crm_sales_details','U') is not null
	drop table bronze.crm_sales_details
GO
CREATE TABLE bronze.crm_sales_details(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id int,
	sls_order_dt int,
	sls_ship_dt int,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int,
	sls_price int
)
GO

IF object_id('bronze.erp_loc_a101','U') is not null
	drop table bronze.erp_loc_a101
GO
CREATE TABLE bronze.erp_loc_a101(
	cid nvarchar(50),
	cntry nvarchar(50)
);
GO
IF object_id('bronze.erp_cust_az12','U') is not null
	drop table bronze.erp_cust_az12
CREATE TABLE bronze.erp_cust_az12(
	cid nvarchar(50),
	bdate date,
	gen nvarchar(50)
);
GO

IF object_id('bronze.erp_px_cat_g1v2','U') is not null
	drop table bronze.erp_px_cat_g1v2
GO
CREATE TABLE bronze.erp_px_cat_g1v2(
	id nvarchar(50),
	cat nvarchar(50),
	subcart nvarchar(50),
	maintenance nvarchar(50)
);
GO


BULK INSERT bronze.crm_sales_details
FROM 'C:\SQL\datasets\source_crm\sales_details.csv'
WITH
(
FIELDTERMINATOR = ',',
TABLOCK,
--ROWTERMINATOR = '\n',
FIRSTROW = 2
--FORMAT = 'CSV'
);
