USE cte_recursion;
-------------------------------------------------------------------------------
-- demo 2: recursive CTE
-------------------------------------------------------------------------------

/* recursive cte syntax--------------------------------------------------------
;WITH cte_name (column1, column2, ... columnN)
AS
(
	anchor member query definition (executed first, run once)
	UNION ALL
	recursive member query definition (referencing cte_name)
) 
statement using cte_name;
--*/

/* cte with termination check--------------------------------------------------
WITH cte_sum_parts (count_no, sum_parts)
AS
	(	--anchor member definition
		SELECT 1 AS count_no
			  ,1 AS sum_parts

		UNION ALL
		--recursive member definition
		SELECT cte.count_no + 1
			  ,sum_parts + cte.count_no + 1
		FROM cte_sum_parts AS cte
		WHERE count_no < 5 --termination check
	)
--invocation
SELECT count_no, sum_parts
FROM cte_sum_parts
--WHERE count_no = 5;
--*/

/* cte without termination check-----------------------------------------------
WITH cte_sum_parts (count_no, sum_parts)
AS
	(	--anchor member definition
		SELECT 1 AS count_no
			  ,1 AS sum_parts

		UNION ALL
		--recursive member definition
		SELECT cte.count_no + 1
			  ,sum_parts + cte.count_no + 1
		FROM cte_sum_parts AS cte
	)
--invocation
SELECT count_no, sum_parts
FROM cte_sum_parts
OPTION (MAXRECURSION 50);
--*/	