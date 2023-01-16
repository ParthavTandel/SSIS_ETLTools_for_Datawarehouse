 USE AWN_STG_Demo;
 GO
 
 
 Create view [dbo].[Stg_vw_Erp_Customer]
  as

  select c.CustomerID,
         p.[Title],
	p.[FirstName],
	p.[LastName],
	p.[NameStyle],
	p.[EmailPromotion],
	pa.[AddressLine1],
	pa.City

         from [erp].[Customer] c
  inner join [erp].[Person] p
  on c.PersonID = p.BusinessEntityID

  left join [erp].[PersonAddress] pa
  on p.BusinessEntityID = pa.BusinessEntityID

GO
/****** Object:  View [dbo].[Stg_vw_Erp_Employee]    Script Date: 25-09-2021 13:26:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[Stg_vw_Erp_Employee]
as

select  NationalIDNumber 
       ,[FirstName]
      ,[LastName]
	  ,null [NameStyle]
	  ,[Title]
	  ,[HireDate]
      ,[BirthDate]
	  ,LoginID [EmailAddress]
	  ,N'' [Phone]
	  ,[MaritalStatus]
	  ,[DepartmentName]
	  ,[StartDate]
	  ,[EndDate]
from [hr].[Employee] e

left join [erp].[Person]  p
on e.BusinessEntityID = p.BusinessEntityID

left join [hr].[EmployeeDepartmentHistory] d
on e.BusinessEntityID = d.BusinessEntityID

GO
/****** Object:  View [dbo].[Stg_vw_Erp_Fact_InternetSales]    Script Date: 25-09-2021 13:26:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[Stg_vw_Erp_Fact_InternetSales]
as
select h.[SalesOrderID],
 row_number() over(partition by h.[SalesOrderID] order by h.modifieddate) as saleLineNumber,
p.ProductNumber,
cast(h.[OrderDate] as date) [OrderDate] ,
cast(h.[DueDate] as Date) [DueDate],
cast(h.[ShipDate] as date) [ShipDate],
[CustomerID],
[TerritoryID],
N'USD' Currency,  
null [RevisionNumber],
[OrderQty],
[UnitPrice],
[UnitPriceDiscount],
[LineTotal],
0 [TaxAmt]

 from [erp].[SalesHeader] h
left join [erp].[SalesOrderDetail]  o
on h.SalesOrderID = o.SalesOrderID

left join [erp].[Product] p 
on o.[ProductID] = p.ProductID
where OnlineOrderFlag =1 -- This is to filer Internet Sales

GO

/****** Object:  View [dbo].[Stg_vw_Erp_Product]    Script Date: 25-09-2021 13:26:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create View [dbo].[Stg_vw_Erp_Product]
as

select  p.[ProductNumber],
        p.[Name],
		p.[StandardCost],
p.[Color],
p.[Size],
null SizeRange,
p.[Name] [EnglishDescription],
sc.[Name]  as [ProductSubcategoryCode],
c.[Name]   as  [ProductCategory]

 from [erp].[Product] p

left join [erp].[ProductSubCategory] sc
on p.ProductSubcategoryID = sc.ProductSubcategoryID

left join [erp].[ProductCategory] c
on sc.ProductCategoryID = c.ProductCategoryID

GO
