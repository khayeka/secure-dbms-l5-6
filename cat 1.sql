
CREATE DATABASE kwacha_test;
GO

USE kwacha_test;
GO


CREATE LOGIN admin_user WITH PASSWORD = 'AdminSecure2026!';
GO

CREATE USER admin_user FOR LOGIN admin_user;
GO

ALTER ROLE db_owner ADD MEMBER admin_user;
GO

CREATE LOGIN readonly_user WITH PASSWORD = 'ReadOnly2026!';
GO
CREATE USER readonly_user FOR LOGIN readonly_user;
GO

ALTER ROLE db_datareader ADD MEMBER readonly_user;
GO


CREATE LOGIN data_entry_user WITH PASSWORD = 'InsertUpdate2026!';
GO
CREATE USER data_entry_user FOR LOGIN data_entry_user;
GO

ALTER ROLE db_datawriter ADD MEMBER data_entry_user;
DENY DELETE TO data_entry_user;
GO

CREATE TABLE students (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);
GO

INSERT INTO students (id, name)
VALUES
(1, 'Kimani Emmah'),
(2, 'Lukor Stevo'),
(3, 'Livio Sam');

SELECT * FROM students;
GO


CREATE TRIGGER BlockDropOnStudents
ON DATABASE
FOR DROP_TABLE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EventData XML = EVENTDATA();
    DECLARE @TableName NVARCHAR(100) = @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)');
    
    IF @TableName = 'students'
    BEGIN
        PRINT 'DROP TABLE operations on "students" are strictly prohibited!';
        ROLLBACK TRANSACTION;
    END
END;
GO

--block Delete querrys


CREATE TRIGGER BlockDeleteOnStudents
ON students
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    RAISERROR ('DELETE operations on the "students" table are strictly prohibited!', 16, 1);
    ROLLBACK TRANSACTION;
END;
GO
--testing block
DELETE FROM students WHERE id=1;
--testing drop
DROP TABLE students;
--allowed querry
SELECT * FROM students;
GO
--backup
BACKUP DATABASE kwacha_test
TO DISK = '/var/opt/mssql/backups/kwacha_test_backup.bak'
WITH FORMAT, NAME = 'Full Backup of kwacha_test';
GO

-- Create new restoring database
CREATE DATABASE kwacha_test_restore;
GO

-- Restore data into the new database 
RESTORE DATABASE kwacha_test_restore
FROM DISK = '/var/opt/mssql/backups/kwacha_test_decrypted.bak'
WITH REPLACE,
MOVE 'kwacha_test' TO '/var/opt/mssql/data/kwacha_test_restore.mdf',
MOVE 'kwacha_test_log' TO '/var/opt/mssql/data/kwacha_test_restore_log.ldf';
GO
