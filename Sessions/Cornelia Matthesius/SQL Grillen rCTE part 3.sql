USE cte_recursion;
-------------------------------------------------------------------------------
-- demo 3: simple bom explosion
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
	  ,('E', 'H');
--*/
/* BOM overview----------------------------------------------------------------
level
0		X			A
		|			/\
1		Y		  B	   C
		|		  |	   /\
2		H		  D	  E   F
					 /\	
3					G  H
*/

/* view data-------------------------------------------------------------------
SELECT [line_id]
      ,[parent]
      ,[child]
FROM [dbo].[parent_child]
ORDER BY line_id;
--*/	

/* cte-------------------------------------------------------------------------
WITH cte_BOM_explosion (line_id, header, component, bom_level, bom_path, information)
AS
	(	--anchor member definition
		SELECT pc.line_id
			  ,pc.parent AS header
			  ,pc.child AS component
			  ,0 AS bom_level
			  ,CAST(pc.parent + ' -> ' + pc.child AS VARCHAR(20)) AS bom_path
			  ,CAST('anchor member' AS VARCHAR(20)) AS information
		FROM dbo.parent_child AS pc

		UNION ALL
		--recursive member definition
		SELECT cte.line_id
			  ,cte.header 
			  ,pc.child AS component
			  ,cte.bom_level + 1 AS bom_level
			  ,CAST(cte.bom_path + ' -> ' + pc.child AS VARCHAR(20)) AS bom_path
			  ,CAST('recursive member' AS VARCHAR(20)) AS information
		FROM cte_BOM_explosion AS cte
		INNER JOIN dbo.parent_child AS pc
			ON cte.component = pc.parent
	)
--invocation
SELECT line_id, header, component, bom_level, bom_path, information
FROM cte_BOM_explosion
--WHERE component NOT IN (SELECT DISTINCT parent FROM dbo.parent_child)
ORDER BY bom_path, bom_level;
--*/	

/* cleanup---------------------------------------------------------------------
DROP TABLE dbo.parent_child;
--*/