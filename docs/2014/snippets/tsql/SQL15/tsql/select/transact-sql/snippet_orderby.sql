-- ORDER BY examples

--<snippetOrderBy1>
USE AdventureWorks2012;
GO
SELECT ProductID, Name FROM Production.Product
WHERE Name LIKE 'Lock Washer%'
ORDER BY ProductID;

--</snippetOrderBy1>


--<snippetOrderBy2>
USE AdventureWorks2012;
GO
SELECT ProductID, Name, Color
FROM Production.Product
ORDER BY ListPrice;

--</snippetOrderBy2>


--<snippetOrderBy3>
USE AdventureWorks2012;
GO
SELECT name, SCHEMA_NAME(schema_id) AS SchemaName
FROM sys.objects
WHERE type = 'U'
ORDER BY SchemaName;

--</snippetOrderBy3>


--<snippetOrderBy4>
USE AdventureWorks2012;
Go
SELECT BusinessEntityID, JobTitle, HireDate
FROM HumanResources.Employee
ORDER BY DATEPART(year, HireDate);

--</snippetOrderBy4>


--<snippetOrderBy5>
USE AdventureWorks2012;
GO
SELECT ProductID, Name FROM Production.Product
WHERE Name LIKE 'Lock Washer%'
ORDER BY ProductID DESC;

--</snippetOrderBy5>


--<snippetOrderBy6>
USE AdventureWorks2012;
GO
SELECT ProductID, Name FROM Production.Product
WHERE Name LIKE 'Lock Washer%'
ORDER BY Name ASC ;

--</snippetOrderBy6>


--<snippetOrderBy7>
USE AdventureWorks2012;
GO
SELECT LastName, FirstName FROM Person.Person
WHERE LastName LIKE 'R%'
ORDER BY FirstName ASC, LastName DESC ;

--</snippetOrderBy7>


--<snippetOrderBy8>
USE tempdb;
GO
CREATE TABLE #t1 (name nvarchar(15) COLLATE Latin1_General_CI_AI)
GO
INSERT INTO #t1 VALUES(N'Sánchez'),(N'Sanchez'),(N'sánchez'),(N'sanchez');

-- This query uses the collation specified for the column 'name' for sorting.
SELECT name
FROM #t1
ORDER BY name;
-- This query uses the collation specified in the ORDER BY clause for sorting.
SELECT name
FROM #t1
ORDER BY name COLLATE Latin1_General_CS_AS;

--</snippetOrderBy8>


--<snippetOrderBy9>
USE AdventureWorks2012;
GO
SELECT p.FirstName, p.LastName
    ,ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS "Row Number"
    ,RANK() OVER (ORDER BY a.PostalCode) AS "Rank"
    ,DENSE_RANK() OVER (ORDER BY a.PostalCode) AS "Dense Rank"
    ,NTILE(4) OVER (ORDER BY a.PostalCode) AS "Quartile"
    ,s.SalesYTD, a.PostalCode
FROM Sales.SalesPerson AS s 
    INNER JOIN Person.Person AS p 
        ON s.BusinessEntityID = p.BusinessEntityID
    INNER JOIN Person.Address AS a 
        ON a.AddressID = p.BusinessEntityID
WHERE TerritoryID IS NOT NULL AND SalesYTD <> 0;

--</snippetOrderBy9>

--<snippetOrderBy10>

USE AdventureWorks2012;
GO
-- Return all rows sorted by the column DepartmentID.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID;

-- Skip the first 5 rows from the sorted result set and return all remaining rows.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID OFFSET 5 ROWS;

-- Skip 0 rows and return only the first 10 rows from the sorted result set.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID 
    OFFSET 0 ROWS
    FETCH NEXT 10 ROWS ONLY;
--</snippetOrderBy10>


--<snippetOrderBy11>
USE AdventureWorks2012;
GO
-- Specifying variables for OFFSET and FETCH values  
DECLARE @StartingRowNumber tinyint = 1
      , @FetchRows tinyint = 8;
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID ASC 
    OFFSET @StartingRowNumber ROWS 
    FETCH NEXT @FetchRows ROWS ONLY;

--</snippetOrderBy11>


--<snippetOrderBy12>
USE AdventureWorks2012;
GO

-- Specifying expressions for OFFSET and FETCH values    
DECLARE @StartingRowNumber tinyint = 1
      , @EndingRowNumber tinyint = 8;
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID ASC 
    OFFSET @StartingRowNumber - 1 ROWS 
    FETCH NEXT @EndingRowNumber - @StartingRowNumber + 1 ROWS ONLY
OPTION ( OPTIMIZE FOR (@StartingRowNumber = 1, @EndingRowNumber = 20) );

--</snippetOrderBy12>


--<snippetOrderBy13>
-- Specifying a constant scalar subquery
USE AdventureWorks2012;
GO
CREATE TABLE dbo.AppSettings (AppSettingID int NOT NULL, PageSize int NOT NULL);
GO
INSERT INTO dbo.AppSettings VALUES(1, 10);
GO
DECLARE @StartingRowNumber tinyint = 1;
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID ASC 
    OFFSET @StartingRowNumber ROWS 
    FETCH NEXT (SELECT PageSize FROM dbo.AppSettings WHERE AppSettingID = 1) ROWS ONLY;

--</snippetOrderBy13>


--<snippetOrderBy14>
USE AdventureWorks2012;
GO

-- Ensure the database can support the snapshot isolation level set for the query.
IF (SELECT snapshot_isolation_state FROM sys.databases WHERE name = N'AdventureWorks2012') = 0
    ALTER DATABASE AdventureWorks2012 SET ALLOW_SNAPSHOT_ISOLATION ON;
GO

-- Set the transaction isolation level  to SNAPSHOT for this query.
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
GO

-- Beging the transaction
BEGIN TRANSACTION;
GO
-- Declare and set the variables for the OFFSET and FETCH values.
DECLARE @StartingRowNumber int = 1
      , @RowCountPerPage int = 3;

-- Create the condition to stop the transaction after all rows have been returned.
WHILE (SELECT COUNT(*) FROM HumanResources.Department) >= @StartingRowNumber
BEGIN

-- Run the query until the stop condition is met.
SELECT DepartmentID, Name, GroupName
FROM HumanResources.Department
ORDER BY DepartmentID ASC 
    OFFSET @StartingRowNumber - 1 ROWS 
    FETCH NEXT @RowCountPerPage ROWS ONLY;

-- Increment @StartingRowNumber value.
SET @StartingRowNumber = @StartingRowNumber + @RowCountPerPage;
CONTINUE
END;
GO
COMMIT TRANSACTION;
GO
--</snippetOrderBy14>

--<snippetOrderBy15>
USE AdventureWorks2012;
GO
SELECT Name, Color, ListPrice
FROM Production.Product
WHERE Color = 'Red'
-- ORDER BY cannot be specified here.
UNION ALL
SELECT Name, Color, ListPrice
FROM Production.Product
WHERE Color = 'Yellow'
ORDER BY ListPrice ASC;

--</snippetOrderBy15>