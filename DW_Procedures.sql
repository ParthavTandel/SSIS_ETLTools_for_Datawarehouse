USE AWN_DW_Demo;
GO

Create Procedure [dbo].[Refresh_DimCurrency]

as
begin


set nocount on 
Insert into [dbo].[DimCurrency]

(
[CurrencyAlternateKey]
,[CurrencyName]
)


SELECT [CurrencyCode]
      ,[Name]    
  FROM [AWN_STG_Demo].[erp].[Currency] stg (nolock)
    left join [dbo].[DimCurrency] Dim  (nolock)
  on stg.CurrencyCode = Dim.CurrencyAlternateKey
    where Dim.CurrencyAlternateKey is null


  Update Dim

  Set [CurrencyName] = Name
  from [dbo].[DimCurrency] Dim  (nolock)
  inner join [AWN_STG_Demo].[erp].[Currency] stg  (nolock)
  on stg.CurrencyCode = Dim.CurrencyAlternateKey


   set nocount off


end 

GO
/****** Object:  StoredProcedure [dbo].[Refresh_DimCustomer]      ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Procedure [dbo].[Refresh_DimCustomer]

as
begin


set nocount on 


Merge into [dbo].[DimCustomer] cus
using [AWN_STG_Demo].[dbo].[Stg_vw_Erp_Customer] stg
on cus.[CustomerAlternateKey] = stg.CustomerID

when Matched and  ( cus.EmailAddress <> stg.[EmailPromotion] or  cus.[AddressLine1] <> stg.[AddressLine1] or cus.AddressLine2 <> stg.City) 
then

update set cus.EmailAddress =stg.[EmailPromotion] ,
	       cus.[AddressLine1] = stg.[AddressLine1] ,
           cus.AddressLine2 =  stg.City


when Not Matched by Target then 

insert   ( 
       [CustomerAlternateKey]      ,[Title]      ,[FirstName]           ,[LastName]
      ,[NameStyle]
     , EmailAddress
	 ,[AddressLine1]
	 ,AddressLine2
	 )
 Values(stg.CustomerID,
        stg.[Title],		stg.[FirstName],		stg.[LastName],
		stg.[NameStyle],
		stg.[EmailPromotion],
		stg.[AddressLine1],
		stg.City)
        
   ;


   
set nocount off 
end 

GO
/****** Object:  StoredProcedure [dbo].[Refresh_DimDate]      ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[Refresh_DimDate]
as
Begin

declare @startdate date = '2005-01-01',
    @enddate date = '2014-12-31'

IF @startdate IS NULL
    BEGIN
        Select Top 1 @startdate = FulldateAlternateKey
        From DimDate 
        Order By DateKey ASC 
    END

Declare @datelist table (FullDate date)

while @startdate <= @enddate

Begin 
    Insert into @datelist (FullDate)
    Select @startdate

    Set @startdate = dateadd(dd,1,@startdate)

end 

 Insert into dbo.DimDate 
    (DateKey, 
        FullDateAlternateKey, 
        DayNumberOfWeek, 
        EnglishDayNameOfWeek, 
      
        DayNumberOfMonth, 
        DayNumberOfYear, 
        WeekNumberOfYear, 
        EnglishMonthName, 
     
        MonthNumberOfYear, 
        CalendarQuarter, 
        CalendarYear, 
        CalendarSemester, 
        FiscalQuarter, 
        FiscalYear, 
        FiscalSemester)


select convert(int,convert(varchar,dl.FullDate,112)) as DateKey,
    dl.FullDate,
    datepart(dw,dl.FullDate) as DayNumberOfWeek,
    datename(weekday,dl.FullDate) as EnglishDayNameOfWeek,
    
    
    datepart(d,dl.FullDate) as DayNumberOfMonth,
    datepart(dy,dl.FullDate) as DayNumberOfYear,
    datepart(wk, dl.FUllDate) as WeekNumberOfYear,
    datename(MONTH,dl.FullDate) as EnglishMonthName,
   
   
    Month(dl.FullDate) as MonthNumberOfYear,
    datepart(qq, dl.FullDate) as CalendarQuarter,
    year(dl.FullDate) as CalendarYear,
    case datepart(qq, dl.FullDate)
        when 1 then 1
        when 2 then 1
        when 3 then 2
        when 4 then 2
    end as CalendarSemester,
    case datepart(qq, dl.FullDate)
        when 1 then 3
        when 2 then 4
        when 3 then 1
        when 4 then 2
    end as FiscalQuarter,
    case datepart(qq, dl.FullDate)
        when 1 then year(dl.FullDate)
        when 2 then year(dl.FullDate)
        when 3 then year(dl.FullDate) + 1
        when 4 then year(dl.FullDate) + 1
    end as FiscalYear,
    case datepart(qq, dl.FullDate)
        when 1 then 2
        when 2 then 2
        when 3 then 1
        when 4 then 1
    end as FiscalSemester

from @datelist dl left join 
    DimDate dd 
        on dl.FullDate = dd.FullDateAlternateKey
Where dd.FullDateAlternateKey is null 


End
GO
/****** Object:  StoredProcedure [dbo].[Refresh_DimProduct]      ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[Refresh_DimProduct]

as
begin


set nocount on 
Insert into [dbo].[DimProduct]

(

       [ProductAlternateKey]
      ,[EnglishProductName]
      ,[StandardCost]
      ,[Color]
      ,[Size]
      ,[SizeRange]
      ,[EnglishDescription]
      ,[FrenchDescription]
      ,[ArabicDescription]
      ,[ProductSubcategoryCode]
      ,[ProductcategoryCode]
      ,[Status]
)


SELECT stg.[ProductNumber]
      ,stg.[Name]
      ,stg.[StandardCost]
      ,Isnull(stg.[Color],'NA')
      ,stg.[Size]
      ,stg.[SizeRange]
      ,stg.[EnglishDescription]
	  ,null 
      ,null
	  ,stg.[ProductSubcategoryCode]
      ,stg.[ProductCategory]   
	  ,null [Status]
  FROM [AWN_STG_Demo].[dbo].[Stg_vw_Erp_Product] stg (nolock)
    left join [dbo].[DimProduct] Dim  (nolock)
  on Dim.[ProductAlternateKey] = stg.[ProductNumber]
    where Dim.[ProductAlternateKey] is null


  Update Dim
  set Dim.[EnglishDescription]= stg.[EnglishDescription]

   
  from  [dbo].[DimProduct] Dim   (nolock)
  inner join [AWN_STG_Demo].[dbo].[Stg_vw_Erp_Product] stg (nolock)
  on Dim.[ProductAlternateKey] = stg.[ProductNumber]


   set nocount off


end 


GO
/****** Object:  StoredProcedure [dbo].[Refresh_DimSalesTerritory]      ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[Refresh_DimSalesTerritory]

as
begin


set nocount on 
Insert into [dbo].[DimSalesTerritory]

(
[SalesTerritoryAlternateKey],
[SalesTerritoryRegion],
[SalesTerritoryCountry],
[SalesTerritoryGroup]

)




SELECT  
[TerritoryID]
,[Name]
,[CountryRegionCode]
,[Group]
  FROM [AWN_STG_Demo].[erp].[SalesTerritory] stg (nolock)
    left join [dbo].[DimSalesTerritory] Dim  (nolock)
  on Dim.[SalesTerritoryAlternateKey] = stg.[TerritoryID]
    where Dim.[SalesTerritoryAlternateKey] is null


  Update Dim

  Set [SalesTerritoryRegion]=[Name]
,[SalesTerritoryCountry]=[CountryRegionCode]
,[SalesTerritoryGroup]=[Group]
  from [dbo].[DimSalesTerritory] Dim (nolock)
  inner join [AWN_STG_Demo].[erp].[SalesTerritory] stg  (nolock)
  on Dim.[SalesTerritoryAlternateKey] = stg.[TerritoryID]


   set nocount off


end 


GO