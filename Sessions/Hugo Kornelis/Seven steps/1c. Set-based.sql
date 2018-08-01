USE SevenSteps;
go
SET NOCOUNT ON;


-- Alternative 1:

DECLARE @StartTime datetime;
SET @StartTime = CURRENT_TIMESTAMP;

SELECT     c.CustomerID
FROM       dbo.Customer AS c
WHERE      c.StoreID IS NOT NULL
--AND        c.CustomerID < 40000         -- Set-based on full set is even faster than cursor on 1/10th
AND EXISTS
 (SELECT   *
  FROM     dbo.SalesOrderHeader AS s
  WHERE    s.CustomerID = c.CustomerID
  AND      YEAR(s.OrderDate) = 2010)
AND NOT EXISTS
 (SELECT   *
  FROM     dbo.SalesOrderHeader AS s
  WHERE    s.CustomerID = c.CustomerID
  AND      YEAR(s.OrderDate) = 2011)
ORDER BY   CustomerID;

SELECT DATEDIFF(ms, @StartTime, CURRENT_TIMESTAMP);
go



-- Alternative 2:

DECLARE @StartTime datetime;
SET @StartTime = CURRENT_TIMESTAMP;

SELECT     c.CustomerID
FROM       dbo.Customer AS c
INNER JOIN dbo.SalesOrderHeader AS s
      ON   s.CustomerID = c.CustomerID
      AND  YEAR(s.OrderDate) IN (2010, 2011)
WHERE      c.StoreID IS NOT NULL
--AND        c.CustomerID < 40000         -- Set-based on full set is even faster than cursor on 1/10th
GROUP BY   c.CustomerID
HAVING     MAX(YEAR(s.OrderDate)) = 2010
ORDER BY   CustomerID;

SELECT DATEDIFF(ms, @StartTime, CURRENT_TIMESTAMP);
go
