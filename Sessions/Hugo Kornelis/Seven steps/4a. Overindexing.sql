USE SevenSteps;
go
SET NOCOUNT ON;


/* =================================================== */
/* Problem: Purge orders older than 2007               */
/*          What is the performance effect of indexes? */
/* =================================================== */

-- Use a transaction and roll back afterwards - so we can compare
BEGIN TRAN;

DECLARE @StartTime datetime2;
SET @StartTime = SYSDATETIME();

DELETE dbo.SalesOrderHeader
WHERE  OrderDate < '20070101';

SELECT DATEDIFF(ms, @StartTime, SYSDATETIME()) AS "Elapsesd time (ms)";
go

ROLLBACK TRAN;
go


BEGIN TRAN;

-- Drop all those indexes, then see how fast the delete becomes
DROP INDEX ix_SalesOrderHeader_OrderDate ON dbo.SalesOrderHeader;
DROP INDEX ix_SalesOrderHeader_ShipDateChar ON dbo.SalesOrderHeader;
DROP INDEX ix_SalesOrderHeader_CustomerID ON dbo.SalesOrderHeader;

DECLARE @StartTime datetime2;
SET @StartTime = SYSDATETIME();

DELETE dbo.SalesOrderHeader
WHERE  OrderDate < '20070101';

SELECT DATEDIFF(ms, @StartTime, SYSDATETIME()) AS "Elapsesd time (ms)";
go

ROLLBACK TRAN;
go
