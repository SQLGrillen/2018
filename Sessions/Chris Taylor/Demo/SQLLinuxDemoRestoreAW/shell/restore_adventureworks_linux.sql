RESTORE DATABASE [AdventureWorks2016CTP3] FROM  DISK = N'/usr/src/sqlscript/AdventureWorks2016CTP3.bak' WITH  FILE = 1,  
MOVE N'AdventureWorks2016CTP3_Data' TO N'/var/opt/mssql/data/AdventureWorks2016CTP3_Data.mdf',  
MOVE N'AdventureWorks2016CTP3_Log' TO N'/var/opt/mssql/data/AdventureWorks2016CTP3_Log.ldf',  
MOVE N'AdventureWorks2016CTP3_mod' TO N'/var/opt/mssql/data/AdventureWorks2016CTP3_mod',  
NOUNLOAD,  STATS = 5
GO
USE Master;
GO
ALTER DATABASE [AdventureWorks2016CTP3] SET COMPATIBILITY_LEVEL = 140
GO