--Provider=SQLNCLI11;Server=.;Initial Catalog=BimlDemo_Live;Integrated Security=SSPI;
--Provider=SQLNCLI11;Server=.;Initial Catalog=AdventureWorks2014;Integrated Security=SSPI;
USE master
GO
DROP DATABASE [BimlDemo_Live]
GO
CREATE DATABASE [BimlDemo_Live]
GO
USE [BimlDemo_Live]
GO
CREATE TABLE [dbo].[MyBimlMeta_Tables](
    [TableName] [nvarchar](50) NULL
) ON [PRIMARY]
GO
INSERT INTO [dbo].[MyBimlMeta_Tables]
SELECT NAME FROM AdventureWorks2014.dbo.sysobjects where name like 'Person%' and type = 'U'
SELECT * FROM [MyBimlMeta_Tables]

GO
TRUNCATE TABLE [MyBimlMeta_Tables]
INSERT INTO [dbo].[MyBimlMeta_Tables]
SELECT NAME FROM AdventureWorks2014.dbo.sysobjects where name like 'Sales%' and type = 'U'
SELECT * FROM [MyBimlMeta_Tables]