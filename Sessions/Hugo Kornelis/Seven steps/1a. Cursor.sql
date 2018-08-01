USE SevenSteps;
go
SET NOCOUNT ON;

/* ==================================================== */
/* Problem: Find "store" customers who ordered in 2010, */
/*          but did not order anything in 2011.         */
/* ==================================================== */



DECLARE @StartTime datetime;
SET @StartTime = CURRENT_TIMESTAMP;

DECLARE @CustomerID int;
DECLARE @Results TABLE (CustomerID int NOT NULL PRIMARY KEY);

-- Cursor (with good options) for "store" customers
DECLARE CustCurs CURSOR LOCAL FAST_FORWARD
FOR SELECT   CustomerID
    FROM     dbo.Customer
    WHERE    StoreID IS NOT NULL
    AND      CustomerID < 40000     -- Only the first 1/10th of all customers
                                    -- (Processing all customers would take over 7 minutes)
    ORDER BY CustomerID;

OPEN CustCurs;

-- Get first customer
FETCH NEXT FROM CustCurs
INTO @CustomerID;

-- Repeat until cursor exhausted
WHILE @@FETCH_STATUS = 0
BEGIN
  -- We could do a nested cursor here,
  -- reading sales for the customer and tracking
  -- two booleans for sales in 2010 and in 2011
  -- But let's do more efficient - a single query works
  -- (Select all sales in 2010 and 2011, check that maximum is 2010;
  --  that implies there were sales in 2010, but not in 2011)
  IF (SELECT MAX(YEAR(OrderDate))
      FROM   dbo.SalesOrderHeader
      WHERE  CustomerID = @CustomerID
      AND    YEAR(OrderDate) IN (2010, 2011)) = 2010
  BEGIN
    INSERT INTO @Results
    VALUES (@CustomerID);
  END;

  -- Get next customer
  FETCH NEXT FROM CustCurs
  INTO @CustomerID;
END;

-- Clean up
CLOSE CustCurs;
DEALLOCATE CustCurs;

-- Show results
SELECT   CustomerID
FROM     @Results
ORDER BY CustomerID;

SELECT DATEDIFF(ms, @StartTime, CURRENT_TIMESTAMP);
go
