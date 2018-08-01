USE SevenSteps;
GO
SET NOCOUNT ON;


/* =================================================== */
/* Problem: Find first and last DueDate for all orders */
/*          that were ordered after date X.            */
/* =================================================== */

-- We already created an index on OrderDate!!


DECLARE @StartTime datetime2;
SET @StartTime = SYSDATETIME();

SELECT MIN(DueDate), MAX(DueDate)
FROM   dbo.SalesOrderHeader
--WHERE  OrderDate >= '20070730';
WHERE  OrderDate >= '20110730';

SELECT DATEDIFF(ms, @StartTime, SYSDATETIME()) AS "Elapsed time (ms)";
GO



-- INCLUDE DueDate to existing index - this makes it a covering index
-- (Unfortunately, this can only be done by dropping and recreating the index)
DROP INDEX dbo.SalesOrderHeader.ix_SalesOrderHeader_OrderDate;
GO
CREATE INDEX    ix_SalesOrderHeader_OrderDate
       ON       dbo.SalesOrderHeader(OrderDate)
       INCLUDE (DueDate);
GO

DECLARE @StartTime datetime2;
SET @StartTime = SYSDATETIME();

SELECT MIN(DueDate), MAX(DueDate)
FROM   dbo.SalesOrderHeader
--WHERE  OrderDate >= '20070730';
WHERE  OrderDate >= '20110730';

SELECT DATEDIFF(ms, @StartTime, SYSDATETIME()) AS "Elapsed time (ms)";
GO


-- Recreate index as it was before this demo
-- (Needed for next demo!)
DROP INDEX dbo.SalesOrderHeader.ix_SalesOrderHeader_OrderDate;
GO
CREATE INDEX    ix_SalesOrderHeader_OrderDate
       ON       dbo.SalesOrderHeader(OrderDate);
GO