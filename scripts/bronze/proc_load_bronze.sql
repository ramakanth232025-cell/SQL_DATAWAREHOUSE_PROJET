/*
--1
=============================================================================
Stored Procedure: Load Broze Layer (Source -> Bronze)
=======================================================================
Script purpose:
	This stored procedure loads data into the 'bronze' schema from external CSV files.
	It performs the following actions:
	-Truncatethe bronze tables before loading data.
	-uses the BULK INSERT command to load data from csv Files to broze tables.

	parameters:
		NONE
		This stored procedure does not accept any parameters or return any values

		Usage Example:
		EXEC bronze.load_bronze;
==========================================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
	declare @START_TIME DATETIME, @end_time DATETIME, @batch_start_time datetime, @batch_end_time Datetime;
	BEGIN TRY
	set  @batch_start_time = GETDATE();
	print '=================================';
	print 'Loading Bronze Layers';
	print '=================================';

	print '=================================';
	print('Loading CRM Layers');
	print '=================================';

	SET @start_time = GETDATE();
	PRINT '>> Truncating Table:bronze.crm_cust_info ';
	TRUNCATE TABLE bronze.crm_cust_info;

	PRINT '>> Inserting Data Table:bronze.crm_cust_info ';
	BULK INSERT bronze.crm_cust_info
	FROM 'C:\SQL\datasets\source_crm\cust_info.csv'
	WITH
	(
		FIELDTERMINATOR = ',',
		TABLOCK,
		FIRSTROW = 2
	);
	set @end_time = GETDATE();
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------';


	--2
	SET @start_time = GETDATE();
	
	PRINT '>> Truncating Table:bronze.crm_prd_info ';
	TRUNCATE TABLE bronze.crm_prd_info;
	PRINT '>> Inserting Data Table:bronze.crm_prd_info';
	BULK INSERT bronze.crm_prd_info
	FROM 'C:\SQL\datasets\source_crm\prd_info.csv'
	WITH
	(
		FIELDTERMINATOR = ',',
		FIRSTROW = 2,
		TABLOCK
	);
	set @end_time = GETDATE();
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------';

	--3
	SET @start_time = GETDATE();

	PRINT '>> Truncating Table:bronze.crm_sales_details';
	TRUNCATE TABLE bronze.crm_sales_details;
	PRINT '>> Inserting Data Table:bronze.crm_sales_details';
	BULK INSERT bronze.crm_sales_details
	FROM 'C:\SQL\datasets\source_crm\sales_details.csv'
	WITH
	(
		FIELDTERMINATOR = ',',
		TABLOCK,
		FIRSTROW = 2
	);
		set @end_time = GETDATE();
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------'


	--4
		print '=================================';
	print('Loading ERP Layers');
	print '================================='
	SET @start_time = GETDATE();
	PRINT '>> Truncating Table:bronze.erp_loc_a101 ';
	TRUNCATE TABLE bronze.erp_loc_a101;
	PRINT '>> Inserting Data Table:bronze.erp_loc_a101';
	BULK INSERT bronze.erp_loc_a101
	FROM 'C:\SQL\datasets\source_erp\loc_a101.csv'
	WITH
	(
		FIELDTERMINATOR = ',',
		TABLOCK,
		FIRSTROW = 2

	);
	set @end_time = GETDATE();
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------';


	--5
	
	PRINT '>> Truncating Table:bronze.erp_cust_az12 ';
	SET @start_time = GETDATE();
	TRUNCATE TABLE bronze.erp_cust_az12;
	PRINT '>> Inserting Data Table:bronze.erp_cust_az12';
	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\SQL\datasets\source_erp\cust_az12.csv'
	WITH
	(
		FIELDTERMINATOR = ',',
		TABLOCK,
		FIRSTROW = 2
	);
	set @end_time = GETDATE();
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------';


	--6
	PRINT '>> Truncating Table:bronze.erp_px_cat_g1v2 ';
	SET @start_time = GETDATE();
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	PRINT '>> Inserting Data Table:bronze.erp_px_cat_g1v2';
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'C:\SQL\datasets\source_erp\px_cat_g1v2.csv'
	WITH
	(
		FIELDTERMINATOR = ',',
		TABLOCK,
		FIRSTROW = 2
	
	);
	set @end_time = GETDATE();
	PRINT '>> Load Duration: '+cast(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';
	print '-----------------------------------------------------------------------';

	SET @batch_end_time = GETDATE();
	PRINT '===================================================================='
	PRINT 'lOADING BRONZE LAYER IS COMPLETED'
	PRINT '    - TOTAL LOAD DURATION: '+CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)+ 'seconds';
	print '===================================================================='

	END TRY 
	BEGIN CATCH
		PRINT '=======================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGES' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGES' +CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR MESSAGES' +CAST(ERROR_STATE() AS NVARCHAR)

	END CATCH
END
