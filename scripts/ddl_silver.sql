--EXEC Silver.load_silver
/* 
=============================================================================
Stored procedure: Load Silveer Layer (Bronze --> Silvee)
This is stored procedure performs the ETL process to populate the silver schema tables from the bronze schema. 
*/

CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
	declare @START_TIME DATETIME, @end_time DATETIME, @batch_start_time datetime, @batch_end_time Datetime;
	BEGIN TRY
	--set  @batch_start_time = GETDATE();
	print '=================================';
	print 'Loading Silver Layers';
	print '=================================';

	print '=================================';
	print('Loading CRM Layers');
	print '=================================';

	SET @start_time = GETDATE();

	/*IF object_id('silver.crm_cust_info','U') is not null
		drop table silver.crm_cust_info
	GO
	CREATE TABLE silver.crm_cust_info(
		cst_id int,
		cst_key nvarchar(50),
		cst_firstname nvarchar(50),
		cst_lastname nvarchar(50),
		cst_marital_status varchar(50),
		cst_gndr nvarchar(50),
		cst_create_date date,
		dwl_create_date datetime2 default getdate()
	)*/

	print '>> Truncating Table: SILVER.CRM_CUST_INFO '
	TRUNCATE TABLE SILVER.CRM_CUST_INFO
	PRINT '>> Inserting Data into: SILVER.CRM_CUST_INFO'
	INSERT INTO SILVER.CRM_CUST_INFO(
		CST_ID,
		CST_KEY,
		CST_FIRSTNAME,
		CST_LASTNAME,
		CST_MARITAL_STATUS,
		CST_GNDR,
		CST_CREATE_DATE)

	select
	CST_ID,
		CST_KEY,
		TRIM(cst_firstname) AS CST_FIRSTNAME,
		TRIM(CST_LASTNAME) AS CST_LASTNAME,
		CASE WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'M' THEN 'Married'
			ELSE 'n/a'
		END CST_MARITAL_STATUS,

		CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
			ELSE 'n/a'
		END CST_GNDR,
		CST_CREATE_DATE  
	from(
	select 
	* ,
	row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
	from BRONZE.crm_cust_info)t where flag_last = 1
	set @end_time = GETDATE();

	---------------------------------------------
	---------------------------------------------
	-- silver.product table
	/*IF object_id('silver.crm_prd_info','U') is not null
		drop table silver.crm_prd_info
	GO
	CREATE TABLE silver.crm_prd_info(
		prd_id int,
		cat_id nvarchar(50),
		prd_key nvarchar(50),
		prd_nm nvarchar(50),
		prd_cost int,
		prd_line nvarchar(50),
		prd_start_dt datetime,
		prd_end_dt datetime,
		dwl_create_date datetime2 default getdate()
	) */
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------';


	--2
	SET @start_time = GETDATE();
	
	print '>> Truncating Table: silver.crm_prd_info '
	TRUNCATE TABLE silver.crm_prd_info
	PRINT '>> Inserting Data into: silver.crm_prd_info'
	insert into silver.crm_prd_info (
		prd_id,
		cat_id,
		prd_key,
		prd_cost,
		prd_line,
		prd_nm,
		prd_start_dt,
		prd_end_dt
	)


	select 
	prd_id,
	replace(substring(prd_key,1,5),'-','_') as cat_id,
	substring(prd_key,7,len(prd_key)) as prd_key,
	isnull(prd_cost,0) as prd_cost,
	prd_line,
	case UPPER(TRIM(PRD_LINE))
		when 'M' THEN 'MOUNTAINS'
		WHEN 'R' THEN 'ROAD'
		WHEN 'S' THEN 'OTHER SALES'
		WHEN 'T' THEN 'TOURING'
		ELSE 'n/a'
	END AS PRD_LINE,
	cast(prd_start_dt as date) as prd_start_date,
	cast(lead(prd_start_dt) over(partition by prd_key ORDER BY PRD_START_DT)-1 as date) AS PRD_END_DT
	from BRONZE.crm_prd_info


	--select * from SILVER.crm_prd_info

	---------------------------------------------------------
	--------------------------------------------------------
	--			silver crm sales table

	/*
	IF object_id('silver.crm_sales_details','U') is not null
		drop table silver.crm_sales_details
	GO
	CREATE TABLE silver.crm_sales_details(
		sls_ord_num nvarchar(50),
		sls_prd_key nvarchar(50),
		sls_cust_id int,
		sls_order_dt date,
		sls_ship_dt date,
		sls_due_dt date,
		sls_sales int,
		sls_quantity int,
		sls_price int,
		dwl_create_date datetime2 default getdate()
	)*/set @end_time = GETDATE();
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------';

	--3
	SET @start_time = GETDATE();

	print '>> Truncating Table: silver.crm_sales_details '
	TRUNCATE TABLE silver.crm_sales_details
	PRINT '>> Inserting Data into: silver.crm_sales_details'
	insert into silver.crm_sales_details(
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
	select 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case when sls_order_dt = 0 or len(sls_order_dt) !=8 THEN NULL
		ELSE CAST(CAST(sls_order_dt as varchar) as date)
	end as sls_order_dt,
	case when sls_ship_dt = 0 or len(sls_ship_dt) !=8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt as varchar) as date)
	end as sls_ship_dt,
	case when sls_due_dt = 0 or len(sls_due_dt) !=8 THEN NULL
		ELSE CAST(CAST(sls_due_dt as varchar) as date)
	end as sls_due_dt,

	case when sls_sales is null or sls_sales<0 or sls_sales != sls_quantity * abs(sls_price) 
			then sls_quantity*ABS(sls_price)
		else sls_sales
	end as sls_sales,
	sls_quantity,
	case when sls_price is null or sls_price <= 0
			then sls_sales / nullif(sls_quantity,0)
		else sls_price
	end as sls_price
	from BRONZE.crm_sales_details 

	set @end_time = GETDATE();
	
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------';


	--------------------------------------
	-- silver erp customer details
	SET @start_time = GETDATE();
	print '>> Truncating Table:silver.erp_cust_az12'
	TRUNCATE TABLE silver.erp_cust_az12
	PRINT '>> Inserting Data into: silver.erp_cust_az12'

	insert into silver.erp_cust_az12(cid,bdate,gen)

	SELECT
	CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
		ELSE CID
	END AS CID,
	CASE WHEN BDATE > GETDATE() THEN NULL
		ELSE BDATE
	END AS BDATE,
	CASE WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'FEMALE'
		 WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'MALE' 
		 ELSE 'n/a'
	end as gen
	FROM BRONZE.erp_cust_az12
	set @end_time = GETDATE();
	
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------';
	--select * from silver.erp_cust_az12
	--------------------------------------------------------------
	SET @start_time = GETDATE();
	print '>> Truncating Table:silver.erp_loc_a101'
	TRUNCATE TABLE silver.erp_loc_a101
	PRINT '>> Inserting Data into: silver.erp_loc_a101'
	insert into silver.erp_loc_a101
	(cid,cntry)

	select
		replace(cid,'-','') cid, 
		case when trim(cntry) = 'DE' THEN 'Germany'
			when TRIM(CNTRY) IN ('US','USA','United States') THEN 'United States'
			when TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
			else TRIM(cntry)
		end cntry
	from BRONZE.erp_loc_a101
	set @end_time = GETDATE();
	
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------';

	--select * from silver.erp_loc_a101
	----------------------------------------------------------
	SET @start_time = GETDATE();
	print '>> Truncating Table: Silver.erp_px_cat_g1v2'
	TRUNCATE TABLE  Silver.erp_px_cat_g1v2
	PRINT '>> Inserting Data into:  Silver.erp_px_cat_g1v2'

	INSERT INTO Silver.erp_px_cat_g1v2
	(ID, CAT, SUBCART, MAINTENANCE)
	SELECT 
	ID,
	CAT,
	SUBCART,
	MAINTENANCE
	FROM BRONZE.erp_px_cat_g1v2
	set @end_time = GETDATE();
	
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------';

	
	SET @batch_end_time = GETDATE();
	PRINT '===================================================================='
	PRINT 'lOADING Silver LAYER IS COMPLETED'
	PRINT '    - TOTAL LOAD DURATION: '+CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)+ 'seconds';
	print '===================================================================='

	END TRY 
	BEGIN CATCH
		PRINT '=======================================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
		PRINT 'ERROR MESSAGES' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGES' +CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGES' +CAST(ERROR_STATE() AS NVARCHAR)

	END CATCH
END

	--select * from Silver.erp_px_cat_g1v2
	--checks for nulls or duplicates in primary key
	--expectations ; no results

