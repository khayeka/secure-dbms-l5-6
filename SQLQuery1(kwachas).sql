CREATE DATABASE kwachas_test;
GO

USE kwachas_test;
GO

--CREATE LOGINS--
CREATE LOGIN admin_user WITH PASSWORD = 'Admin@1234';
GO
CREATE LOGIN readonly_user WITH PASSWORD = 'Random@1234';
GO
CREATE LOGIN insertupdate_user WITH PASSWORD = 'Insert@1234';
GO

--CREATE USERS--
CREATE USER admin_user FOR LOGIN admin_user;
GO
CREATE USER readonly_user FOR LOGIN readonly_user;
GO
CREATE USER insertupdate_user FOR LOGIN insertupdate_user;
GO

GRANT CONTROL ON DATABASE:: kwachas_test TO admin_user;
GO
GRANT SELECT ON SCHEMA:: dbo TO readonly_user;
GO
GRANT SELECT, INSERT, UPDATE ON SCHEMA::dbo TO insertupdate_user;
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
(1, 'LIVIO'),
(2, 'VICTOR');


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

BACKUP DATABASE kwachas_test
TO DISK = 'C \BACKUP\kwachas_test.bak'
WITH FORMAT,
     NAME = 'kwachas_test Full Backup',
     DESCRIPTION = 'Full backup of kwachas_test database';
GO
 
 --ENCYPTION--
 USE master;
 GO
 CREATE MASTER KEY ENCYPTION BY PASSWORD = 'Admin@1234';
 GO
  
  --CREATE CERTIFICATE-
  CREATE CERTIFICATE BackupCert WITH SUBJECT = 'Backup Encryption Certificate';
  GO
   
   --Backup the certificate
 BACKUP CERTIFICATE BackupCert TO FILE = 'C: \Backup\BackupCert.cer' WITH PRIVATE KEY
   (   
      FILE = 'C:\Backup\BackupCert.pvk',
      ENCRYPTION BY PASSWORD = 'Admin@1234'
    );
    GO

--Backup with encryption
BACKUP DATABASE kwachas_test
TO DISK = 'C:\Backup\kwachas_test_encrypted.bak'
WITH FORMAT,
     NAME = 'Encrypted Backup',
     ENCRYPTION
     (
        ALGORITHM =AES_256,
        SERVER CERTIFICATE = BackupCert
        );
    GO

--RESTORE FROM ENCRYPTED DATA
USE master;
GO
RESTORE  DATABASE kwachas_test
FROM DISK ='C:\Backup\kwachas_test_encrypted.bak'
with REPLACE;
GO
 
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








