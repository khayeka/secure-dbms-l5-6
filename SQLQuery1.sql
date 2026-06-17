-- Create Database
CREATE DATABASE kwacha_test;
GO

-- Use the Database
USE kwacha_test;
GO

-- Create Logins
CREATE LOGIN admin_user WITH PASSWORD = 'JonteAdmin111!';
GO

CREATE LOGIN readonly_user WITH PASSWORD = 'JonteReadonly111!';
GO

CREATE LOGIN data_user WITH PASSWORD = 'JonteData111!';
GO

--  Create Database Users
CREATE USER admin_user FOR LOGIN admin_user;
GO

CREATE USER readonly_user FOR LOGIN readonly_user;
GO

CREATE USER data_user FOR LOGIN data_user;
GO

--  Assign Privileges

-- Full Administrative Privileges
ALTER ROLE db_owner ADD MEMBER admin_user;
GO

-- Read-Only Privileges
ALTER ROLE db_datareader ADD MEMBER readonly_user;
GO

-- Insert/Update Privileges
GRANT INSERT TO data_user;
GRANT UPDATE TO data_user;
GO

-- Verify Users and Roles
SELECT
dp.name AS UserName,
dp.type_desc AS UserType
FROM sys.database_principals dp
WHERE dp.name IN ('admin_user', 'readonly_user', 'data_user');
GO
--DELETE BLOCK --
DENY DELETE ON SCHEMA:: dbo TO readonly_user;
DENY DELETE ON SCHEMA :: dbo TO insertupdate_user;
DENY ALTER ON SCHEMA  :: dbo TO readonly_user;
DENY ALTER ON SCHEMA ::dbo TO inserupdate_user;

CREATE TABLE WORKERS(
  ID INT PRIMARY KEY,
  Name VARCHAR (100));
GO

INSERT INTO  WORKERS(ID,Name)
VALUES
(1, 'JOHN'),
(2, 'NICK');


SELECT * FROM WORKERS
GO

--TEST BLOCKED QUERIES
EXECUTE AS USER = 'readonly_user';
DELETE FROM dbo.WORKERS WHERE ID =1;
REVERT;
GO

EXECUTE AS USER = 'insertupdate_user';
DROP TABLE dbo.WORKERS;
REVERT 
GO

SELECT * FROM WORKERS;

BACKUP DATABASE kwacha_test
TO DISK = 'C:\SQLBackups\kwacha_test.bak'
WITH FORMAT,
     INIT,
     NAME = 'Full Backup of kwacha_test';
 
 --ENCYPTION--
 USE master;
 GO
 CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'StrongPassword@123';
 GO
   --CREATE CERTIFICATE-
 CREATE CERTIFICATE BackupCert WITH SUBJECT = 'Backup Encryption';
 GO
 
   --Backup the certificate/with encryption
BACKUP DATABASE kwacha_test
TO DISK = 'C:\SQLBackups\kwacha_test.bak'
WITH FORMAT,
     INIT,
     NAME = 'Full Backup of kwacha_test';

--RESTORE FROM ENCRYPTED DATA
RESTORE FILELISTONLY
FROM DISK = 'C:\SQLBackups\kwacha_test.bak';
--RESTRICT ACCESS TO ADMIN
ALTER DATABASE kwachas_test
SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE;
GO

--FULL ADMIN CONTROL
USE kwachas_test;
GO
GRANT CONTROL ON DATABASE:: kwachas_test TO admin_user;
GO

--RETURN TO NORMAL MULTI-USER MODE
ALTER DATABASE kwachas_test
SET MULTI_USER;
GO

--VERIFICATION
SELECT name, state_desc
FROM sys.databases
WHERE name = 'kwachas_test';
GO