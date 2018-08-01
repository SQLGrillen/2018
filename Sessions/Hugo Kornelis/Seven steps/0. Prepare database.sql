USE master;
GO
SET NOCOUNT ON;

-- Remove old version of demo database. Use brute force if necessary.
IF EXISTS (SELECT * FROM sys.databases WHERE name = N'SevenSteps')
  BEGIN;
  ALTER DATABASE SevenSteps SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE SevenSteps;
  END;
GO

-- Create the empty demo database, with sufficient size for the demo tables.
-- To make the script run on all databases, I don't hardcode the directory,
-- but use the directory where the master database lives;
-- this gives me the guarantee that the directory exists
-- and is accessible by SQL Server.
--
-- Unfortunately, this requires the use of dynamic SQL,
-- which I normally avoid. In this case, though, the risk is acceptable.
-- The only way to exploit this dynamic SQL is to install an instance
-- with the master database in a directory with a carefully crafted pathname;
-- whoever can do that must have admin rights
-- and doesn't need the SQL injection attack.
DECLARE @master_directory nvarchar(260);
SET @master_directory =
 (SELECT REPLACE(physical_name, 'master.mdf', '')
  FROM   sys.database_files
  WHERE  name='master'
  AND    type=0);
EXECUTE
 (N'CREATE DATABASE SevenSteps
    ON PRIMARY
      (NAME = SevenSteps,
       FILENAME = ''' + @master_directory + N'SevenSteps.mdf'',
       SIZE = 20MB)
    LOG ON
      (NAME = SevenStepsLog,
       FILENAME = ''' + @master_directory + N'SevenSteps.ldf'',
       SIZE = 15MB)
    COLLATE Latin1_General_CI_AS;');
GO

-- Switch to tempdb before switching to SevenSteps.
-- If SevenSteps was not created, the USE statement fails,
-- but the next batch will still execute.
-- Switching to tempdb first ensures spurious tables will be created there,
-- and not in a parmenent database
USE tempdb;
GO
USE SevenSteps;
GO

-- Create table dbo.Customer (mostly a copy of Sales.Customer in AdventureWorks2012)
CREATE TABLE dbo.Customer
   (CustomerID int NOT NULL,
	StoreID int NULL,
    TerritoryID int NULL,
	AccountNumber  AS (COALESCE('AW'+RIGHT('00000000'+CAST(CustomerID AS varchar(10)), 8),'')),
	rowguid uniqueidentifier ROWGUIDCOL  NOT NULL CONSTRAINT DF_Customer_rowguid  DEFAULT (newid()),
	ModifiedDate datetime NOT NULL CONSTRAINT DF_Customer_ModifiedDate  DEFAULT (getdate()),
    CONSTRAINT PK_Customer_CustomerID PRIMARY KEY (CustomerID),
   );

-- Populate dbo.Customer with 10 copies of the Sales.Customer data from AdventureWorks2012
INSERT INTO dbo.Customer (CustomerID, StoreID, TerritoryID)
SELECT      CustomerID + n, StoreID, TerritoryID
FROM        AdventureWorks2012.Sales.Customer
CROSS JOIN (SELECT      0 UNION ALL SELECT  40000 UNION ALL SELECT  80000 UNION ALL
            SELECT 120000 UNION ALL SELECT 160000 UNION ALL SELECT 200000 UNION ALL
            SELECT 240000 UNION ALL SELECT 280000 UNION ALL SELECT 320000 UNION ALL
            SELECT 360000) AS x(n);
GO

-- Create table dbo.SalesOrderHeader (mostly a copy of Sales.SalesOrderHeader in AdventureWorks2012)
CREATE TABLE dbo.SalesOrderHeader
   (SalesOrderID int NOT NULL,
	RevisionNumber tinyint NOT NULL CONSTRAINT DF_SalesOrderHeader_RevisionNumber  DEFAULT (0),
	OrderDate datetime NOT NULL CONSTRAINT DF_SalesOrderHeader_OrderDate  DEFAULT (CURRENT_TIMESTAMP),
	DueDate datetime NOT NULL,
	ShipDate datetime NULL,
	ShipDateChar char(8) NULL,
	Status tinyint NOT NULL CONSTRAINT DF_SalesOrderHeader_Status  DEFAULT (1),
	OnlineOrderFlag bit NOT NULL CONSTRAINT DF_SalesOrderHeader_OnlineOrderFlag  DEFAULT (CAST(1 AS bit)),
	SalesOrderNumber  AS (ISNULL(N'SO'+CONVERT(nvarchar(23),SalesOrderID,0),N'*** ERROR ***')),
	PurchaseOrderNumber nvarchar(25) NULL,
	AccountNumber nvarchar(15) NULL,
	CustomerID int NOT NULL,
	SalesPersonID int NULL,
	TerritoryID int NULL,
	BillToAddressID int NOT NULL,
	ShipToAddressID int NOT NULL,
	ShipMethodID int NOT NULL,
	CreditCardID int NULL,
	CreditCardApprovalCode varchar(15) NULL,
	CurrencyRateID int NULL,
	SubTotal money NOT NULL CONSTRAINT DF_SalesOrderHeader_SubTotal  DEFAULT (0.00),
	TaxAmt money NOT NULL CONSTRAINT DF_SalesOrderHeader_TaxAmt  DEFAULT (0.00),
	Freight money NOT NULL CONSTRAINT DF_SalesOrderHeader_Freight  DEFAULT (0.00),
	TotalDue  AS (isnull(SubTotal+TaxAmt+Freight,0)),
	Comment nvarchar(128) NULL,
	rowguid uniqueidentifier ROWGUIDCOL  NOT NULL CONSTRAINT DF_SalesOrderHeader_rowguid  DEFAULT (newid()),
	ModifiedDate datetime NOT NULL CONSTRAINT DF_SalesOrderHeader_ModifiedDate  DEFAULT (getdate()),
    CONSTRAINT PK_SalesOrderHeader_SalesOrderID PRIMARY KEY (SalesOrderID),
    CONSTRAINT FK_SalesOrderHeader_Customer_CustomerID FOREIGN KEY(CustomerID) REFERENCES dbo.Customer (CustomerID)
   );
GO

-- Populate dbo.SalesOrderHeader with 10 copies of the Sales.SalesOrderHeader data from AdventureWorks2012
-- (so now each customer has its own set of orders, equal to those in AdventureWorks2012)
INSERT INTO dbo.SalesOrderHeader(SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, ShipDateChar, Status, OnlineOrderFlag, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment)
SELECT      SalesOrderID + n, RevisionNumber, OrderDate, DueDate, ShipDate, CONVERT(char(8), ShipDate, 112), Status, OnlineOrderFlag, PurchaseOrderNumber, AccountNumber, CustomerID + n, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment
FROM        AdventureWorks2012.Sales.SalesOrderHeader
CROSS JOIN (SELECT      0 UNION ALL SELECT  40000 UNION ALL SELECT  80000 UNION ALL
            SELECT 120000 UNION ALL SELECT 160000 UNION ALL SELECT 200000 UNION ALL
            SELECT 240000 UNION ALL SELECT 280000 UNION ALL SELECT 320000 UNION ALL
            SELECT 360000) AS x(n);
GO

-- Make an extra copy of all orders, shifting the date by three years
INSERT INTO dbo.SalesOrderHeader(SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, shipDateChar, Status, OnlineOrderFlag, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment)
SELECT      SalesOrderID + 500000, RevisionNumber, DATEADD(year, 3, OrderDate), DATEADD(year, 3, DueDate), DATEADD(year, 3, ShipDate), CONVERT(char(8), DATEADD(year, 3, ShipDate), 112), Status, OnlineOrderFlag, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, Freight, Comment
FROM        dbo.SalesOrderHeader;
GO

-- Display row counts
SELECT COUNT(*) AS Customers FROM dbo.Customer
SELECT COUNT(*) AS Orders FROM dbo.SalesOrderHeader;
GO
