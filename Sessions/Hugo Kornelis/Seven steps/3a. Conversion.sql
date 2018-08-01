USE SevenSteps;
go
SET NOCOUNT ON;


/* ============================================= */
/* Problem: How many orders ship on Feb 6, 2011? */
/* ============================================= */

-- We filter on ShipDateChar, so let's create that index
CREATE INDEX ix_SalesOrderHeader_ShipDateChar
       ON    dbo.SalesOrderHeader(ShipDateChar);
GO


DECLARE @StartTime datetime;
SET @StartTime = CURRENT_TIMESTAMP;

DECLARE @Date datetime;
SET @Date = CAST('20110206' AS datetime);

SELECT COUNT(*)
FROM   dbo.SalesOrderHeader
WHERE  ShipDateChar = @Date;

SELECT DATEDIFF(ms, @StartTime, CURRENT_TIMESTAMP);
go






/* Without the conversion, a far more efficient seek can be used */

DECLARE @StartTime datetime;
SET @StartTime = CURRENT_TIMESTAMP;

DECLARE @Date char(8);      -- This data type matches the table
SET @Date = '20110206';

SELECT COUNT(*)
FROM   dbo.SalesOrderHeader
WHERE  ShipDateChar = @Date;

SELECT DATEDIFF(ms, @StartTime, CURRENT_TIMESTAMP);
go


/* Alternative (if you cannot change the way the parameter is passed in) */

DECLARE @StartTime datetime;
SET @StartTime = CURRENT_TIMESTAMP;

DECLARE @Date datetime;
SET @Date = CAST('20110206' AS datetime);

SELECT COUNT(*)
FROM   dbo.SalesOrderHeader
WHERE  ShipDateChar = CONVERT(char(8), @Date, 112);     -- Explicit conversion of parameter
                                                        -- (style 112 is yyyymmdd)
SELECT DATEDIFF(ms, @StartTime, CURRENT_TIMESTAMP);
go

