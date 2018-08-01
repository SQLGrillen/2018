USE SevenSteps;
GO
SET NOCOUNT ON;


-- The code below is a common pattern that,
-- allegedly, is "better" than those "slow cursors".

DECLARE @StartTime datetime;
SET @StartTime = CURRENT_TIMESTAMP;


DECLARE @CustomerID int;
DECLARE @Results TABLE (CustomerID int NOT NULL PRIMARY KEY);


-- Read first customer
SET @CustomerID =
 (SELECT TOP (1) CustomerID
  FROM     dbo.Customer
  WHERE    StoreID IS NOT NULL
  AND      CustomerID < 40000     -- Only the first 1/10th of all customers
  ORDER BY CustomerID);

-- Repeat until all customers processed
WHILE @CustomerID IS NOT NULL
BEGIN
  -- Same trick as in "real" cursor code
  IF (SELECT MAX(YEAR(OrderDate))
      FROM   dbo.SalesOrderHeader
      WHERE  CustomerID = @CustomerID
      AND    YEAR(OrderDate) IN (2010, 2011)) = 2010
  BEGIN
    INSERT INTO @Results
    VALUES (@CustomerID);
  END;

  -- Get next customer
  SET @CustomerID =
   (SELECT TOP (1) CustomerID
    FROM     dbo.Customer
    WHERE    StoreID IS NOT NULL
    AND      CustomerID < 40000         -- Only the first 1/10th of all customers
    AND      CustomerID > @CustomerID
    ORDER BY CustomerID);
END;

SELECT   CustomerID
FROM     @Results
ORDER BY CustomerID;

SELECT DATEDIFF(ms, @StartTime, CURRENT_TIMESTAMP);
go
