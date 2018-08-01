USE cte_recursion
-------------------------------------------------------------------------------
-- demo 1: simple CTE
-------------------------------------------------------------------------------

/* cte syntax------------------------------------------------------------------
;WITH cte_name (column1, column2, ... columnN)
AS
(SELECT query definition) 
statement using cte_name;
--*/

/* create example table--------------------------------------------------------
CREATE TABLE [dbo].[numbers](
	[number] [int] NOT NULL,
	[label] [varchar](20) NOT NULL
) ON [PRIMARY]
INSERT INTO [numbers]([number],[label])
VALUES(1,'counting')
	 ,(2,'counting')
	 ,(3,'counting')
	 ,(4,'counting');
--*/

/* improve readability, avoid repetition---------------------------------------
SET STATISTICS IO ON;
-- using subqueries (derived tables)
SELECT SUM(number) AS number, 'sum_all' AS label FROM (SELECT number, label from dbo.numbers) AS a
UNION
SELECT SUM(number) AS number, 'sum_odd' AS label FROM (SELECT number, label from dbo.numbers) AS a WHERE number % 2 = 1
UNION
SELECT SUM(number) AS number, 'sum_even' AS label FROM (SELECT number, label from dbo.numbers) AS a WHERE number % 2 = 0; 
--*/
/*--the same with CTE
WITH cte_example (number, label)
AS 
(
SELECT number, label from dbo.numbers
)
SELECT SUM(number) AS number, 'sum_all' AS label FROM cte_example
UNION
SELECT SUM(number) AS number, 'sum_odd' AS label FROM cte_example WHERE number % 2 = 1
UNION
SELECT SUM(number) AS number, 'sum_even' AS label FROM cte_example WHERE number % 2 = 0;
--*/

/* cleanup---------------------------------------------------------------------
DROP TABLE dbo.numbers;
--*/

/* nested CTEs & scope---------------------------------------------------------
;WITH   
nestedCTE1 AS
(SELECT 1 AS number),
nestedCTE2 AS
(SELECT number + 1 AS number FROM nestedCTE1),
nestedCTE3 AS
(SELECT number + 1 AS number FROM nestedCTE2)
SELECT *
FROM nestedCTE3;
--*/	

