--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=DATA FOLDER - PATH CONFIGURATION=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

IF OBJECT_ID('tempdb..#TempPathTable') IS NOT NULL 
	DROP TABLE #TempPathTable

DECLARE @DataFolderPath AS VARCHAR(250)

SET @DataFolderPath = 'C:\Users\Public\Documents\Axes\SQL-Movie-Database-main2\Data'

SELECT 
	@DataFolderPath AS VarVal
INTO #TempPathTable

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=REMOVE OLD DATABASE=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

USE master
GO

--Kill all sessions of queries that use the database
DECLARE @Sql VARCHAR(1000) = ''
DECLARE @databasename VARCHAR(100) = 'RobertStanMovieDatabase' 

SELECT  @Sql = @Sql + 'kill ' + CONVERT(CHAR(10), spid) + ' ' 
FROM    master.dbo.sysprocesses 
WHERE   db_name(dbid) = @databasename
     and 
     dbid <> 0 
     and 
     spid <> @@spid 

EXEC(@Sql)

GO

DROP DATABASE IF EXISTS RobertStanMovieDatabase
GO

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=CREATE NEW DATABASE=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

CREATE DATABASE RobertStanMovieDatabase
GO

USE RobertStanMovieDatabase
GO

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=CREATE TABLES=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

CREATE TABLE dbo.People
(
	NameID VARCHAR(10) NOT NULL,
	Name NVARCHAR(100) NOT NULL,
	Birth SMALLINT,
	Death SMALLINT,
	Profession NVARCHAR(75),
	TitleID VARCHAR(100)
)
GO

--CREATE TABLE dbo.Title
--(
--	TitleID VARCHAR(10) PRIMARY KEY,
--	Type VARCHAR(50) NOT NULL,
--	PrimaryTitle NVARCHAR(300),
--	OriginalTitle NVARCHAR(300),
--	IsAdult BIT,
--	StartYear SMALLINT,
--	EndYear SMALLINT,
--	RuntimeMinutes SMALLINT,
--	Genres VARCHAR(150)
--)
--GO

--CREATE TABLE dbo.Creator
--(
--	TitleID VARCHAR(10) PRIMARY KEY,
--	DirectorID VARCHAR(MAX),
--	WriterID VARCHAR(MAX)
--)
--GO

--CREATE TABLE dbo.Episode
--(
--	TitleID VARCHAR(10) PRIMARY KEY,
--	ParentTitleID VARCHAR(10),
--	Season SMALLINT,
--	Episode INT
--)
--GO

--CREATE TABLE dbo.Biography
--(
--	TitleID VARCHAR(10),
--	Ordering TINYINT,
--	NameID VARCHAR(10) NOT NULL,
--	Category VARCHAR(50) NOT NULL,
--	Job VARCHAR(300),
--	Characters VARCHAR(500)
--	PRIMARY KEY(TitleID,Ordering)
--)
--GO

--CREATE TABLE dbo.Rating
--(
--	TitleID VARCHAR(10) PRIMARY KEY,
--	Rating DECIMAL(3,1),
--	Votes INT
--)
--GO

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=ADD PRIMARY KEY CONSTRAINTS=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
Alter table dbo.People
Add constraint PK_People_Table
primary key (NameID, Name)
GO


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=ADD FOREGIN KEY CONSTRAINTS=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

--ALTER TABLE dbo.Rating ADD FOREIGN KEY (TitleID) REFERENCES dbo.Title (TitleID)
--ALTER TABLE dbo.Episode ADD FOREIGN KEY (ParentTitleID) REFERENCES dbo.Title (TitleID)
--ALTER TABLE dbo.Biography ADD FOREIGN KEY (TitleID) REFERENCES dbo.Title (TitleID)
--ALTER TABLE dbo.Biography ADD FOREIGN KEY (NameID) REFERENCES dbo.People (NameID)
--ALTER TABLE dbo.Creator ADD FOREIGN KEY (TitleID) REFERENCES dbo.Title (TitleID)

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=ADD DATA TO TABLES=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

IF OBJECT_ID('AddDataToTable') IS NOT NULL
	DROP PROCEDURE AddDataToTable
GO

CREATE PROCEDURE [dbo].[AddDataToTable] @TableName VARCHAR(50), @DataFolderPath VARCHAR(250), @DataFile VARCHAR(50), @FieldDeterminator VARCHAR(10)
AS
BEGIN
	DECLARE @SQL_SCRIPT NVARCHAR(MAX)
	DECLARE @CurrentColumnNr INT = 2
	DECLARE @TemporaryProcessingTableColumnsNumber INT = (SELECT 
																COUNT(COLUMN_NAME) 
															FROM INFORMATION_SCHEMA.COLUMNS
															WHERE TABLE_NAME = @TableName)
	--Create Temporary Table
	BEGIN
		IF OBJECT_ID('dbo.TemporaryProcessingDatabase') IS NOT NULL
			BEGIN
				DROP TABLE dbo.TemporaryProcessingDatabase
			END

			BEGIN
				SET @SQL_SCRIPT = 'CREATE TABLE dbo.TemporaryProcessingDatabase (Data1 NVARCHAR(4000)'
			
				WHILE @CurrentColumnNr <= @TemporaryProcessingTableColumnsNumber
					BEGIN
						SET @SQL_SCRIPT += ' ,Data' + CAST(@CurrentColumnNr AS VARCHAR(2)) + ' NVARCHAR(4000)'
						SET @CurrentColumnNr += 1
					END

				SET @SQL_SCRIPT += ')'
			
				EXEC (@SQL_SCRIPT)
			END

		SET @SQL_SCRIPT =
			'BULK INSERT '+ 'dbo.TemporaryProcessingDatabase' +'
			FROM '''+ @DataFolderPath + @DataFile +'''
			WITH
			(
				FIRSTROW = 2,
				FIELDTERMINATOR = '''+ @FieldDeterminator +''',
				ROWTERMINATOR = ''0x0A'',
				TABLOCK
			)'
		EXEC (@SQL_SCRIPT)
	END

	--Process and put in database
	BEGIN
		SET @CurrentColumnNr = 1

		SET @SQL_SCRIPT = 'INSERT ' + @TableName

		SET @SQL_SCRIPT += ' SELECT '

		WHILE @CurrentColumnNr <= @TemporaryProcessingTableColumnsNumber
			BEGIN
				SET @SQL_SCRIPT += IIF(@CurrentColumnNr = 1, '', ' ,') + 'IIF(Data' + CAST(@CurrentColumnNr AS VARCHAR(2)) + '.Value = ''' + '\' + 'N' +''', NULL, Data' + CAST(@CurrentColumnNr AS VARCHAR(2)) + '.Value)'
				SET @CurrentColumnNr += 1
			END

		SET @SQL_SCRIPT += ' FROM [dbo].[TemporaryProcessingDatabase] AS MainData'

		SET @CurrentColumnNr = 1

		WHILE @CurrentColumnNr <= @TemporaryProcessingTableColumnsNumber
			BEGIN
				SET @SQL_SCRIPT += ' CROSS APPLY string_split(Data' + CAST(@CurrentColumnNr AS VARCHAR(2)) + ', ''' + ',' + ''') AS Data' + CAST(@CurrentColumnNr AS VARCHAR(2))
				SET @CurrentColumnNr += 1
			END

		EXEC (@SQL_SCRIPT)
	END

END
GO



DECLARE @DataFolderPath AS VARCHAR(250)
SELECT @DataFolderPath = VarVal FROM #TempPathTable

--Actor
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file0.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file1.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file2.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file3.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file4.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file5.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file6.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file7.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file8.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file9.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file10.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file11.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file12.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file13.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file14.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file15.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file16.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file17.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file18.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file19.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file20.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file21.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file22.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file23.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file24.csv','	'
EXEC AddDataToTable 'People',@DataFolderPath,'\title.akas\file25.csv','	'

----Title
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file0.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file1.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file2.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file3.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file4.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file5.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file6.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file7.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file8.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file9.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file10.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file11.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file12.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file13.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file14.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file15.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file16.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file17.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file18.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file19.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file20.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file21.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file22.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file23.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file24.csv','	'
--EXEC AddDataToTable 'dbo.Title',@DataFolderPath,'\title.basics\file25.csv','	'

----Creator
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file0.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file1.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file2.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file3.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file4.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file5.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file6.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file7.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file8.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file9.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file10.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file11.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file12.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file13.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file14.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file15.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file16.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file17.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file18.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file19.csv','	'
--EXEC AddDataToTable 'dbo.Creator',@DataFolderPath,'\title.crew\file20.csv','	'

----Episodes
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file0.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file1.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file2.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file3.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file4.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file5.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file6.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file7.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file8.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file9.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file10.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file11.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file12.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file13.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file14.csv','	'
--EXEC AddDataToTable 'dbo.Episode',@DataFolderPath,'\title.episode\file15.csv','	'

----Biography
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file0.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file1.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file2.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file3.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file4.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file5.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file6.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file7.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file8.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file9.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file10.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file11.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file12.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file13.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file14.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file15.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file16.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file17.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file18.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file19.csv','	'
--EXEC AddDataToTable 'dbo.Biography',@DataFolderPath,'\title.principals\file20.csv','	'

--EXEC AddDataToTable 'dbo.Rating',@DataFolderPath,'\title.ratings\title.ratings.tsv','	'

--akas

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=DROP REDUNDANCIES=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--

IF OBJECT_ID('AddDataToTable') IS NOT NULL
	DROP PROCEDURE AddDataToTable
GO

DROP TABLE IF EXISTS #TempPathTable
GO