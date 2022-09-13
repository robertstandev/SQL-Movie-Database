--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=DATA FOLDER PATH CONFIGURATION=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

IF OBJECT_ID('tempdb..#TempPathTable') IS NOT NULL DROP TABLE #TempPathTable
DECLARE @DataFolderPath AS VARCHAR(250)

SET @DataFolderPath = 'C:\Users\PC\Desktop\SQL-Movie-Database-main\Data'

SELECT @DataFolderPath AS VarVal INTO #TempPathTable

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=REMOVE OLD DATABASE=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

--Select Master
USE master
GO

--Kill all sessions of queries that use the database
declare @Sql varchar(1000), @databasename varchar(100) 
set @databasename = 'RobertStanMovieDatabase' 
set @Sql = ''  
select  @Sql = @Sql + 'kill ' + convert(char(10), spid) + ' ' 
from    master.dbo.sysprocesses 
where   db_name(dbid) = @databasename
     and 
     dbid <> 0 
     and 
     spid <> @@spid 
exec(@Sql)
GO

--Drop database
DROP DATABASE IF EXISTS RobertStanMovieDatabase
GO

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=DATABASE=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

--Create database
CREATE DATABASE RobertStanMovieDatabase
GO

--Select database
USE RobertStanMovieDatabase
GO


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=CREATE TABLES=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

--Create People table
CREATE TABLE dbo.People
(
	NameID VARCHAR(10) PRIMARY KEY,
	Name NVARCHAR(100) NOT NULL,
	Birth SMALLINT,
	Death SMALLINT,
	Profession NVARCHAR(75),
	TitleID VARCHAR(100)
)
GO

--Create CountriesTitleVariation table
CREATE TABLE dbo.CountriesTitleVariation
(
	TitleID VARCHAR(10),
	Ordering TINYINT,
	Title NVARCHAR(300),
	Region NVARCHAR(15),
	Language NVARCHAR(10),
	Types NVARCHAR(50),
	Attributes VARCHAR(75),
	IsOriginalTitle BIT
	PRIMARY KEY(TitleID,Ordering)
)
GO

--Create Titles table
CREATE TABLE dbo.Title
(
	TitleID VARCHAR(10) PRIMARY KEY,
	Type VARCHAR(50) NOT NULL,
	PrimaryTitle NVARCHAR(300),
	OriginalTitle NVARCHAR(300),
	IsAdult BIT,
	StartYear SMALLINT,
	EndYear SMALLINT,
	RuntimeMinutes SMALLINT,
	Genres VARCHAR(150)
)
GO

--Create Creator table
CREATE TABLE dbo.Creator
(
	TitleID VARCHAR(10) PRIMARY KEY,
	DirectorID VARCHAR(MAX),
	WriterID VARCHAR(MAX)
)
GO

--Create Episode table
CREATE TABLE dbo.Episode
(
	TitleID VARCHAR(10) PRIMARY KEY,
	ParentTitleID VARCHAR(10),
	Season SMALLINT,
	Episode INT
)
GO

--Create Biography table
CREATE TABLE dbo.Biography
(
	TitleID VARCHAR(10),
	Ordering TINYINT,
	NameID VARCHAR(10) NOT NULL,
	Category VARCHAR(50) NOT NULL,
	Job VARCHAR(300),
	Characters VARCHAR(500)
	PRIMARY KEY(TitleID,Ordering)
)
GO

--Create Rating table
CREATE TABLE dbo.Rating
(
	TitleID VARCHAR(10) PRIMARY KEY,
	Rating DECIMAL(3,1),
	Votes INT
)
GO








IF OBJECT_ID('AddDataToTable') IS NOT NULL
DROP PROCEDURE AddDataToTable
GO


CREATE PROCEDURE AddDataToTable @TableName VARCHAR(50), @DataFolderPath VARCHAR(250), @DataFile VARCHAR(50), @FieldDeterminator VARCHAR(10)
AS
BEGIN
DECLARE @SQL_BULK VARCHAR(MAX)
SET @SQL_BULK =
'BULK INSERT '+@TableName+'
FROM '''+@DataFolderPath+@DataFile+'''
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = '''+@FieldDeterminator+''',
	ROWTERMINATOR = ''0x0A'',
	TABLOCK
)'
EXEC (@SQL_BULK)
END
GO






DECLARE @DataFolderPath AS VARCHAR(250)
SELECT @DataFolderPath = VarVal FROM #TempPathTable

EXEC AddDataToTable 'dbo.People',@DataFolderPath,'\ImdbName.csv',';'
EXEC AddDataToTable 'dbo.CountriesTitleVariation',@DataFolderPath,'\ImdbTitleAkas.csv',';'
EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\ImdbTitleBasics.csv',';'
EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\ImdbTitleCrew.csv',';'
EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\ImdbTitleEpisode.csv',','
EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\ImdbTitlePrincipals.csv',';'
EXEC AddDataToTable 'dbo.Rating',@DataFolderPath,'\ImdbTitleRatings.csv',';'


IF OBJECT_ID('AddDataToTable') IS NOT NULL
DROP PROCEDURE AddDataToTable
GO

--Remove DataFolderLocationPath
DROP TABLE #TempPathTable
GO