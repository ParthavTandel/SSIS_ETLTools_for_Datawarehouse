# SSIS_ETLTools_for_Datawarehouse
ETL tools for loading data into Data warehouse via staging from OLTP database using SSIS and SQL.

Source: AdventureWorks2014 OLTP Database.

Step 1: Creating schema and tables for staging areas (refer STG_Tables script).

<img width="951" alt="STG_Diagram" src="https://user-images.githubusercontent.com/118220804/212742462-0c363198-9790-4a9d-ac2d-6450f89a7ea3.png">

Step 2: Creating schema and tables for Data Warehouse (refer DW_Tables script).

<img width="647" alt="DW_Diagram" src="https://user-images.githubusercontent.com/118220804/212742657-f163c45c-facc-479a-88b8-44ed57a0e913.png">

Step 3: Populating Staging tables (Dimensions) from OLTP database. For Customers, Business Entity, SalesTerritory, Person, and Store tables, simple data flow from source (OLTP) to destination (Staging). For one of the tables (Currency) we are adding derived columns SSIS_ID (@[System::ServerExecutionID]) and Created_Dt (GETDATE()) for debugging purposes.

<img width="756" alt="ERP" src="https://user-images.githubusercontent.com/118220804/212743454-7aa9fdf7-eef0-4d26-86bd-7eb37ddf8541.png">

For PersonAddress, we will merge join (Inner join by addressID) data from Person.address and Person.BusinessEntityAddress tables.

<img width="376" alt="PersonAddress" src="https://user-images.githubusercontent.com/118220804/212744994-f194fae1-6b97-4392-b1c9-e89b651c6e53.png">

Same way for EmployeeHistory, We will join department history and department name (Inner join by DepartmentID)

<img width="488" alt="HR_Employee" src="https://user-images.githubusercontent.com/118220804/212745672-d869d418-9ed0-47da-84e7-bf33e619de31.png">

<img width="521" alt="DepartmentHistory" src="https://user-images.githubusercontent.com/118220804/212745983-9e9967e7-39bc-4062-be9f-5864d6af3d7b.png">

Step 4: Populating SalesData(Fact).

<img width="842" alt="ERP_Incremental" src="https://user-images.githubusercontent.com/118220804/212746312-ac9eaf6d-d96e-4ced-ad44-986d20bdc970.png">

For Incremental Loads, we will get last sale date from data warehouse factInternetSales table, and store it into a variable

<img width="442" alt="GetLastSale" src="https://user-images.githubusercontent.com/118220804/212747454-096162fc-a73f-4484-bfec-5b90c55b51cc.png">

Then, we will only load new data (where OrderDate > LastSaleDate)

<img width="467" alt="SalesHeaderOrderDate" src="https://user-images.githubusercontent.com/118220804/212747686-96426812-eb62-4063-824d-2eae928861d1.png">

Step 5: Creating required views for data warehouse loading (Refer STG_Views Scripts) and Dimensions tables procedures (refer DW_Procedures scripts).

Step 6: Populating Data Warehouse tables (Dim). For DimCurrency, DimDate, DimCustomers, DimProducts and DimTerritory we will simply execute stored procedure created in last step.

<img width="638" alt="DW_Load" src="https://user-images.githubusercontent.com/118220804/212749898-35c03c0e-98a9-49c2-895f-e1ae131b2201.png">

For DimEmployee, we use Slowly Changing Dimension (SCD) as some employees changed department.

<img width="368" alt="DimEmployee_Load" src="https://user-images.githubusercontent.com/118220804/212750723-d27d9325-4be5-43d8-b7e1-5e9da67c185b.png">

<img width="203" alt="SCD_12" src="https://user-images.githubusercontent.com/118220804/212751080-51aa59dc-1651-4bc2-866b-fae5482136cb.png">

<img width="310" alt="SCD_Start_End" src="https://user-images.githubusercontent.com/118220804/212751180-23a9542f-16e5-479d-9cf4-3e3ae4284952.png">

For FactInternetSales, we use staging area fact tables as source. Then we use lookup from different Dim tables and adding id colunm for matching records. Finally, we load it into Data Warehouse FactInternetSales table.

<img width="618" alt="FactInternetSales_loading" src="https://user-images.githubusercontent.com/118220804/212752798-47ba89cf-0021-4aaf-8368-e2862d044e4d.png">

<img width="406" alt="Lookup" src="https://user-images.githubusercontent.com/118220804/212752834-f38b68ca-e4d9-4572-afe3-fa2857c9621a.png">

Step 7: Creating main package to perform above steps one by one. We can use this package in Integration Services Catalog and SQL Server Agent to schedule and automate the whole process.

<img width="461" alt="EndtoEndDW" src="https://user-images.githubusercontent.com/118220804/212753072-09784d2c-9b7c-4740-8fae-3e0cf3c8b93f.png">
