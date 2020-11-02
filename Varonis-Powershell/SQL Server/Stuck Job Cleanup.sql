/* Check for Mutexes on VrnsDomainDB..Mutexes */

USE VrnsDomainDB
SELECT * FROM Mutexes

/* Delete all Mutexes from VrnsDomainDB..Mutexes */

USE VrnsDomainDB
DELETE FROM Mutexes;

/* Verify that the Mutexes have been removed from VrnsDomainDB..Mutexes */

USE VrnsDomainDB
SELECT * FROM Mutexes

/* Check for Mutexes on Varonis..Mutexes */

USE Varonis
SELECT * FROM Mutexes

/* Delete all Mutexes from Varonis..Mutexes */

USE Varonis
DELETE FROM Mutexes;

/* Verify that the Mutexes have been removed from Varonis..Mutexes */

USE Varonis
SELECT * FROM Mutexes

/* Check on Jobs in the Job Executions table which are not marked as completed, ordering by when the jobs where started */

USE VrnsDomainDB
SELECT * FROM JOB_Executions
WHERE IsCompleted = 0
Order By TimeStarted DESC

/* Update each entry in Job_Executions which currently have IsCompeted set to 0, changing this value from 0 to 1 */

Update JOB_Executions
SET IsCompleted = 1
WHERE IsCompleted = 0

/* Verify that there are no more entries in Job_Executions which have IsCompleted set to 0 */

USE VrnsDomainDB
SELECT * FROM JOB_Executions
WHERE IsCompleted = 0
Order By TimeStarted DESC

/* Clear the Dispatching Cache by running the stored procedure 'spJob_ClearDispatchingCache' */

USE VrnsDomainDB
EXEC spJOB_ClearDispatchingCache

/* Refresh the Jobs view in the Management Console and you should have no more stuck jobs! */