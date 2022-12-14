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

CREATE TABLE dbo.Creator
(
	TitleID VARCHAR(10) PRIMARY KEY,
	DirectorID VARCHAR(MAX),
	WriterID VARCHAR(MAX)
)
GO

CREATE TABLE dbo.Episode
(
	TitleID VARCHAR(10) PRIMARY KEY,
	ParentTitleID VARCHAR(10),
	Season SMALLINT,
	Episode INT
)
GO

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

CREATE TABLE dbo.Rating
(
	TitleID VARCHAR(10) PRIMARY KEY,
	Rating DECIMAL(3,1),
	Votes INT
)
GO



ALTER TABLE dbo.Rating ADD FOREIGN KEY (TitleID) REFERENCES dbo.Title (TitleID)
ALTER TABLE dbo.Episode ADD FOREIGN KEY (ParentTitleID) REFERENCES dbo.Title (TitleID)
ALTER TABLE dbo.Biography ADD FOREIGN KEY (TitleID) REFERENCES dbo.Title (TitleID)
ALTER TABLE dbo.Biography ADD FOREIGN KEY (NameID) REFERENCES dbo.People (NameID)
ALTER TABLE dbo.Creator ADD FOREIGN KEY (TitleID) REFERENCES dbo.Title (TitleID)



--Add data to table
BULK INSERT dbo.People
FROM 'C:\Users\PC\Desktop\SQL-Movie-Database-main\Data\ImdbName.csv'
WITH
(
	FIRSTROW = 2,			--from 2 because 1 is the header
	FIELDTERMINATOR = ';',	--CSV field delimiter
	ROWTERMINATOR = '0x0A',	--Use to shift the control to the next row (enter)
	TABLOCK
)
GO



--Add data to table
BULK INSERT dbo.Title
FROM 'C:\Users\PC\Desktop\SQL-Movie-Database-main\Data\ImdbTitleBasics.csv'
WITH
(
	FIRSTROW = 2,			--from 2 because 1 is the header
	FIELDTERMINATOR = ';',	--CSV field delimiter
	ROWTERMINATOR = '0x0A',	--Use to shift the control to the next row (enter)
	TABLOCK
)
GO



--Add data to table
BULK INSERT dbo.Creator
FROM 'C:\Users\PC\Desktop\SQL-Movie-Database-main\Data\ImdbTitleCrew.csv'
WITH
(
	FIRSTROW = 2,			--from 2 because 1 is the header
	FIELDTERMINATOR = ';',	--CSV field delimiter
	ROWTERMINATOR = '0x0A',	--Use to shift the control to the next row (enter)
	TABLOCK
)
GO



--Add data to table
BULK INSERT dbo.Episode
FROM 'C:\Users\PC\Desktop\SQL-Movie-Database-main\Data\ImdbTitleEpisode.csv'
WITH
(
	FIRSTROW = 2,			--from 2 because 1 is the header
	FIELDTERMINATOR = ',',	--CSV field delimiter
	ROWTERMINATOR = '0x0A',	--Use to shift the control to the next row (enter)
	TABLOCK
)
GO



--Add data to table
BULK INSERT dbo.Biography
FROM 'C:\Users\PC\Desktop\SQL-Movie-Database-main\Data\ImdbTitlePrincipals.csv'
WITH
(
	FIRSTROW = 2,			--from 2 because 1 is the header
	FIELDTERMINATOR = ';',	--CSV field delimiter
	ROWTERMINATOR = '0x0A',	--Use to shift the control to the next row (enter)
	TABLOCK
)
GO



--Add data to table
BULK INSERT dbo.Rating
FROM 'C:\Users\PC\Desktop\SQL-Movie-Database-main\Data\ImdbTitleRatings.csv'
WITH
(
	FIRSTROW = 2,			--from 2 because 1 is the header
	FIELDTERMINATOR = ';',	--CSV field delimiter
	ROWTERMINATOR = '0x0A',	--Use to shift the control to the next row (enter)
	TABLOCK
)
GO