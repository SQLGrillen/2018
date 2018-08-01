USE cte_recursion;
-------------------------------------------------------------------------------
-- demo 4: BOM explosion with circular reference
-------------------------------------------------------------------------------

/* create example--------------------------------------------------------------
CREATE TABLE [dbo].[parent_child](
	[line_id] [int] IDENTITY(1,1) NOT NULL,
	[parent] [char](1) NOT NULL,
	[child] [char](1) NOT NULL
) ON [PRIMARY];
-- insert values
INSERT INTO [dbo].[parent_child]
(parent, child)
VALUES --level 1
	   ('X', 'Y')
	  ,('A', 'B')
	  ,('A', 'C')
	   --level 2
	  ,('Y', 'H')
	  ,('B', 'D')
	  ,('C', 'E')
	  ,('C', 'F')
	   --level 3
	  ,('E', 'G')
	  ,('E', 'H')
	  ,('F', 'C'); --show circular reference
--*/

/* BOM overview----------------------------------------------------------------
level
0		X			A
		|			/\
1		Y		  B	   C
		|		  |	   /\
2		H		  D	  E   F
					 /\	  |
3					G  H (C)
*/

/* view data-------------------------------------------------------------------
SELECT [line_id]
      ,[parent]
      ,[child]
FROM [dbo].[parent_child]
ORDER BY line_id;
--*/	

/* solving the problem from upside down----------------------------------------
WITH cte_catch_circles AS (
	--anchor member definition (children + parents)
    SELECT  
        pc.line_id AS base_line_id,
        pc.parent AS parent, 
        pc.line_id,
        CAST(pc.child + ' <- ' + pc.parent AS VARCHAR(8000))  AS cycle_path,
        0 AS is_circle
    FROM dbo.parent_child AS pc

    UNION ALL
    --recursive member definition (finding grandparents)
    SELECT  
        r.base_line_id, 
        pc.parent, 
        pc.line_id,
        CAST(r.cycle_path + ' <- ' + pc.parent AS VARCHAR(8000)) AS cycle_path,
        CASE 
            WHEN r.cycle_path LIKE '%' + pc.parent + '%' 
            THEN 1               -- flag if node already hit in this run
            ELSE 0 
        END AS is_circle       
    FROM cte_catch_circles AS r
    INNER JOIN dbo.parent_child AS pc
		 ON r.parent = pc.child  -- work back towards root ancestor
    WHERE r.is_circle = 0        -- termination check
)
SELECT parent, cycle_path from cte_catch_circles
WHERE is_circle = 1              -- filter to children that loop back on themselves
ORDER BY base_line_id, line_id
OPTION (MAXRECURSION 10)         -- error out if it recurses too much
--*/

/* cleanup---------------------------------------------------------------------
DROP TABLE [dbo].[parent_child];
--*/
