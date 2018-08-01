USE SevenSteps;
GO
SET NOCOUNT ON;


DECLARE @StartTime datetime = CURRENT_TIMESTAMP;

DECLARE @CustomerID int = 29513;

SELECT MAX(YEAR(OrderDate))
FROM   dbo.SalesOrderHeader
WHERE  CustomerID = @CustomerID
AND    YEAR(OrderDate) IN (2010, 2011)

SELECT DATEDIFF(ms, @StartTime, CURRENT_TIMESTAMP);
GO

-- Show execution plan and runtime
-- Create index, then re-run
/*
CREATE INDEX ix_SalesOrderHeader_CustomerID
       ON    dbo.SalesOrderHeader(CustomerID);
*/
GO
