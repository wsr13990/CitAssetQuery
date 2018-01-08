README

CIT ASSET DATABASE

This database is created to maintain the fiscal database in efficient and integrated way.
This database is also provided with function and procedure necessary to process the record such as calculating depreciation, executing write off etc.

Starting Database:
-To start the database, open XAMPP and start MySQL
-Open SQLyog and select localhost
-Open the `cit_asset` database

STORED PROCEDURE(in alphabetical order):
NOTE: this following procedure affect the database directly so avoid use any of this directly (not using it through another routine query),
unless it's necessary and make sure backup the asset database monthly and before using these procedure
1.	calculate_depre_by_month_year_tableName`(monthperiod INTEGER(2),IN period INTEGER(4), IN tableName VARCHAR(25))
	parameter:
		monthperiod	: month in integer
		period		: year in integer
		tableName	: name of the asset table
	This procedure calculate the depreciation in the parameter table for given year and month (Year to Date)
	example: calculate_depre_by_month_year_tableName(3,2017,'far_depre')
	
2.	calculate_depre_by_year_tableName`(IN parameter_year INTEGER(4), IN tableName VARCHAR(50)
	parameter:
		parameter_year	: year in integer
		tableName		: name of the asset table
	This procedure calculate depreciation in one year full period (12 month) for the given table name.
	It serve as a shorthand to avoid looping for calculating full year depreciation.
	example: calculate_depre_by_year_tableName(2017,'far_depre')

3. calculate_depre_from_1996_to_parameterYear`(IN parameter_year INTEGER(4), IN tableName VARCHAR(50)
	parameter:
		parameter_year	: year in integer
		tableName		: name of the asset table
	This procedure calculate depreciation since 1996 until the parameter year for the given table name.
	It serve as shorthand to avoid looping for calculating.
	example: calculate_depre_by_year_tableName(2017,'far_depre')

4. calculate_depre_from_a_to_b`(IN beginYear INTEGER(4),IN endYear INTEGER(4), IN tableName VARCHAR(50)
	parameter:
		beginYear		: year in integer in which the depreciation calculation begin
		endYear			: year in integer in which the depreciation calculation end
		tableName		: name of the asset table
	This procedure calculate depreciation since begin year until the end year for the given table name.
	It serve as shorthand to avoid looping for calculating.
	example: calculate_depre_by_year_tableName(2005,2017,'far_depre'), which calculate depreciation since 2005 to 2017
	
5. 