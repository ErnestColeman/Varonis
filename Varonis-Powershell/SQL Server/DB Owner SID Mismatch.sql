--Declare the Database variable
DECLARE @database VARCHAR(128);
--Initialize the Database variable
SET @database = 'VrnsDomainDB'; /* ← Update this with the database you are interested in running this query against */

--Declare the Database variable
DECLARE @owner VARCHAR(128);
--Initialize the Database variable
SET @owner = 'CHARLIE\vrnssvc'; /* ← Update this with the database you are interested in running this query against */

--Alter Authorization on Database::@database to @owner /* ← Uncomment this line to set @owner as Database Owner of @database. Please run the query once with this line commented out to see what the values where before making any changes.*/

--Query the Master database's SysDatabases table to see which account it has on record as the DBOwner, returning the accounts Name and SID
SELECT  SD.[SID]
       ,SL.Name as [LoginName]
  FROM  master..sysdatabases SD inner join master..syslogins SL
    on  SD.SID = SL.SID
 Where  SD.Name = @database

/*Query the @database to retrieve the SID of the DBOwner (dbo). Compare this SID with the one returned by the query above. 
They are supposed to match. If they do not, you can use the Alter Authorization command below to correct the error.*/

--Declare @getdbosid Variable
DECLARE @getdbosid AS VARCHAR(MAX)
--Initialize @getdbosid Variable
SET @getdbosid = 'SELECT [SID] From ' + @database + '.sys.database_principals WHERE Name = ''dbo'''
--Execute @getdbosid
EXEC (@getdbosid)
