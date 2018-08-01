USE SevenSteps;
GO
SET NOCOUNT ON;


/* ===================================== */
/* Problem: How many orders in May 2010? */
/* ===================================== */

-- Filter is on OrderDate, so this index should work
CREATE INDEX ix_SalesOrderHeader_OrderDate
       ON    dbo.SalesOrderHeader(OrderDate);
GO

-- Run, then show execution plan
DECLARE @StartTime datetime;
SET @StartTime = CURRENT_TIMESTAMP;

DECLARE @YearMonth char(6);
SET @YearMonth = '201005';

SELECT COUNT(*)
FROM   dbo.SalesOrderHeader
WHERE  CONVERT(char(6), OrderDate, 112) = @YearMonth;

SELECT DATEDIFF(ms, @StartTime, CURRENT_TIMESTAMP);
GO






/* This rewrite will make the expression sargable */

DECLARE @StartTime datetime;
SET @StartTime = CURRENT_TIMESTAMP;

DECLARE @YearMonth char(6);
SET @YearMonth = '201005';

SELECT COUNT(*)
FROM   dbo.SalesOrderHeader
WHERE  OrderDate >= CAST(@YearMonth + '01' AS datetime)
AND    OrderDate  < DATEADD(month, 1, CAST(@YearMonth + '01' AS datetime));

SELECT DATEDIFF(ms, @StartTime, CURRENT_TIMESTAMP);
go
