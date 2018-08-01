USE SevenSteps;
GO
SET NOCOUNT ON;


/* =================================================== */
/* Problem: Find first and last DueDate for all orders */
/*          that were ordered after date X.            */
/* =================================================== */

-- (Same problem as in previous demo!)

-- Check execution plans for variables, and for parameters
DECLARE @StartTime datetime2;
SET @StartTime = SYSDATETIME();

DECLARE @Date datetime;
SET @Date = '20070730';
--SET @Date = '20110730';

SELECT MIN(DueDate), MAX(DueDate)
FROM   dbo.SalesOrderHeader
WHERE  OrderDate >= '20070730';
--WHERE  OrderDate >= '20110730';
--WHERE  OrderDate >= @Date;

SELECT DATEDIFF(ms, @StartTime, SYSDATETIME()) AS "Elapsed time (ms)";
go




-- Same query, but now in a stored procedure
CREATE PROC dbo.MinMaxDueDate
            @Date datetime
AS
SELECT MIN(DueDate), MAX(DueDate)
FROM   dbo.SalesOrderHeader
WHERE  OrderDate >= @Date;
go

-- Execution plan determined in first call, then reused for next call
DECLARE @StartTime datetime2;
SET @StartTime = SYSDATETIME();

EXEC dbo.MinMaxDueDate '20110730';
--EXEC dbo.MinMaxDueDate '20070730';

SELECT DATEDIFF(ms, @StartTime, SYSDATETIME()) AS "Elapsed time (ms)";
go
