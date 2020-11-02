PRINT 'Now running... report any issues to Tim @ tfrasier@varonis.com'

PRINT ''

-- Populating variables

-- Declare the FilerName variable to be used
DECLARE @FilerName VARCHAR(128);
-- Initialize the FilerName variable
SET @FilerName = 'FS63'; /* ← Update this with the hostname you are interested in running this query against*/
PRINT 'The @FilerName is ' + @FilerName
PRINT ''
PRINT '----------------------------------------'

-- Declare @GetFilerID
DECLARE @GetFilerID AS VARCHAR (1000)
-- Initialize @GetFilerID variable
SET @GetFilerID = 'SELECT filer_id FROM varonis.dbo.filers WHERE filer_hostname = ''' + @FilerName + ''''

PRINT '@GetFilerID query written as: ' + @GetFilerID
PRINT ''
PRINT '----------------------------------------'

Print 'Pulling Filer_ID for ' + @FilerName + ' and writing to @FilerID...'
-- Declare the @FilerID variable
DECLARE @FilerID VARCHAR (1000);
-- Create a temp table to hold results
CREATE TABLE #FilerID (FilerID INT)
-- Run @GetFilerID and write results to #FilerID table
INSERT INTO #FilerID EXEC (@GetFilerID)
-- Set the Filer_ID value saved in #FilerID Table to the @FilerID variable
SET @FilerID = (SELECT * FROM #FilerID)
-- Print the variable #FilerID, which should be the Filer_ID of @FilerName
PRINT ''
PRINT '@FilerID is ' + @FilerID
PRINT ''
PRINT '----------------------------------------'
--Dropping #FilerID Table
DROP TABLE #FilerID

--Variables are now populated. Now we run our queries to collect data

PRINT 'Populating query strings with variables...'
PRINT ''

-- Declare @DCF_Files variable
DECLARE @DCF_Files AS VARCHAR(MAX)
-- Initialize @DCF_Files variable
SET @DCF_Files = 'SELECT * FROM Varonis.dbo.DCF_Files_' + @FilerID 
-- Print @DCF_Files
PRINT 'Varonis.dbo.DCF_Files_' + @FilerID + ' query reads: ' + @DCF_Files

PRINT ''

-- Declare @DCF_Log variable
DECLARE @DCF_Log AS VARCHAR(MAX)
-- Initialize @DCF_Log variable
SET @DCF_Log = 'SELECT * FROM Varonis.dbo.DCF_Log_' + @FilerID
-- Print @DCF_Log
PRINT 'Varonis.dbo.DCF_Log_' + @FilerID + ' query reads: ' + @DCF_Log

PRINT ''

-- Declare @DCF_Results_Varonis Variable
DECLARE @DCF_Results_Varonis AS VARCHAR(MAX)
-- Initialize @DCF_Results_Varonis Variable
SET @DCF_Results_Varonis = 'SELECT * FROM Varonis.dbo.DCF_Results_' + @FilerID
-- Print @DCF_Results_Varonis
PRINT 'Varonis.dbo.DCF_Results_' + @FilerID + ' query reads: ' + @DCF_Results_Varonis

PRINT ''

-- Declare @DCF_Priorities variable
DECLARE @DCF_Priorities AS VARCHAR(MAX)
-- Initialize @DCF_Priorities variable
SET @DCF_Priorities = 'SELECT * FROM ' + @FilerName +'.dbo.DCF_Priorities'
--PRINT @DCF_Priorities
PRINT @FilerName + '.dbo.DCF_Priorities query reads: ' + @DCF_Priorities

PRINT ''

-- Declare @DCF_Priorities_3_5 variable
DECLARE @DCF_Priorities_3_5 AS VARCHAR(MAX)
-- Initialize @DCF_Priorities_5_3 variable
SET @DCF_Priorities_3_5 = 'SELECT COUNT (*) FROM ' + @FilerName +'.dbo.DCF_Priorities WHERE STATUS IN (3,5)'
--PRINT @DCF_Priorities_3_5
PRINT @FilerName + '.dbo.DCF_Priorities WHERE STATUS IS 3 or 5 query reads: ' + @DCF_Priorities_3_5

PRINT ''

-- Declare @DCF_Results_Shadow variable
DECLARE @DCF_Results_Shadow AS VARCHAR(MAX)
-- Initialize @DCF_Results_Shadow variable
SET @DCF_Results_Shadow = 'SELECT * FROM ' + @FilerName +'.dbo.DCF_Results'
--PRINT @DCF_Results_Shadow
PRINT @FilerName + '.dbo.DCF_Results query reads: ' + @DCF_Results_Shadow

PRINT ''

PRINT '----------------------------------------'

-- Executing queries

PRINT 'Executing queries...'
PRINT ''

-- Execute Varonis.dbo.DCF_FIles_@FilerID Query
PRINT 'Executing ' + @DCF_Files + '...'
PRINT ''
EXEC (@DCF_Files)
PRINT ''
-- Execute Varonis.dbo.DCF_Log_@FilerID Query
PRINT 'Executing ' + @DCF_Log + '...'
PRINT ''
EXEC (@DCF_Log)
PRINT ''
-- Execute Varonis.dbo.DCF_Log_@FilerID Query
PRINT 'Executing ' + @DCF_Results_Varonis + '...'
PRINT ''
EXEC (@DCF_Results_Varonis)
PRINT ''
-- Execute @FilerName.dbo.DCF_Priorities Query
PRINT 'Executing ' + @DCF_Priorities + '...'
PRINT ''
EXEC (@DCF_Priorities)
PRINT ''
-- Execute @FilerName.dbo.DCF_Priorities_3_5 Query
PRINT 'Executing ' + @DCF_Priorities_3_5 + '...'
PRINT ''
EXEC (@DCF_Priorities_3_5)
PRINT ''
PRINT 'Status 3 is ''In progress - Directory has been sent to the engine for scanning.'''
PRINT 'Status 5 is ''In progress - Directory has not yet been to the engine for scanning.'''
PRINT ''
-- Execute @FilerName.dbo.DCF_Results Query
PRINT 'Executing ' + @DCF_Results_Shadow + '...'
PRINT ''
EXEC (@DCF_Results_Shadow)
PRINT ''

-- Execute static queries
PRINT 'Executing SELECT * FROM VrnsDomainDB.dbo.DCF_Hresult...'
PRINT ''
SELECT * FROM VrnsDomainDB.dbo.DCF_Hresult
PRINT ''
PRINT 'Executing SELECT * FROM Varonis.dbo.DCF_MonitorSnapshot...'
PRINT ''
SELECT * FROM Varonis.dbo.DCF_MonitorSnapshot

PRINT ''

PRINT 'Queries complete!'
PRINT ''
PRINT '----------------------------------------'
PRINT 'DONE!'
