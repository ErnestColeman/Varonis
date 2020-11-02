SELECT *
FROM VrnsDomainDB.dbo.KeyValue
WHERE [Key]
LIKE '%Reports_need%'

UPDATE VrnsDomainDB.dbo.KeyValue
SET Value = 0
WHERE [key] = 'Reports_needToImpersonate'

----------------------------------------

USE Vrnsdomainddb
UPDATE keyvalue 
SET Value=0
WHERE [Key] = 'PreventUpgradeWithPatches'

USE Vrnsdomainddb
UPDATE keyvalue 
SET Value=1
WHERE [Key] = 'PreventUpgradeWithPatches'

--Install your patch and then run the statement with value=1 to turn PreventUpgradeWithPatches back on.

----------------------------------------

ALTER AUTHORIZATION ON DATABASE::VrnsDomainDB TO sa

----------------------------------------

---Select all Windows Domains---

USE VrnsDomainDB
SELECT *
FROM Domains
WHERE serverType = 3

----------------------------------------
--A Join that Works!
SELECT AccessPath, Status, ScanDate, HResult
FROM FS63.dbo.DCF_Priorities
JOIN FS63.dbo.SDT_AccessPaths
on FS63.dbo.DCF_Priorities.DirID = FS63.dbo.SDT_AccessPaths.DirID
WHERE Status = 4