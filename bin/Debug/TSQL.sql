﻿/*
Deployment script for TSQL

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar LoadTestData "false"
:setvar DatabaseName "TSQL"
:setvar DefaultFilePrefix "TSQL"
:setvar DefaultDataPath "C:\Users\cjmco\AppData\Local\Microsoft\VisualStudio\SSDT\TSQL"
:setvar DefaultLogPath "C:\Users\cjmco\AppData\Local\Microsoft\VisualStudio\SSDT\TSQL"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                CURSOR_DEFAULT LOCAL 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET PAGE_VERIFY NONE,
                DISABLE_BROKER 
            WITH ROLLBACK IMMEDIATE;
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 367)) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
PRINT N'Creating [dbo].[Account]...';


GO
CREATE TABLE [dbo].[Account] (
    [AcctNo]      INT           NOT NULL,
    [Fname]       NVARCHAR (50) NOT NULL,
    [Lname]       NVARCHAR (50) NOT NULL,
    [CreditLimit] MONEY         NULL,
    [Balance]     MONEY         NULL,
    CONSTRAINT [PK_ACC] PRIMARY KEY CLUSTERED ([AcctNo] ASC),
    CONSTRAINT [UC_Account] UNIQUE NONCLUSTERED ([Fname] ASC, [Lname] ASC)
);


GO
PRINT N'Creating [dbo].[Log]...';


GO
CREATE TABLE [dbo].[Log] (
    [OrigAcct]    INT      NOT NULL,
    [LogDateTime] DATETIME NOT NULL,
    [RecAcct]     INT      NULL,
    [Amount]      MONEY    NOT NULL,
    CONSTRAINT [PK_LOG] PRIMARY KEY CLUSTERED ([OrigAcct] ASC, [LogDateTime] ASC)
);


GO
PRINT N'Creating unnamed constraint on [dbo].[Log]...';


GO
ALTER TABLE [dbo].[Log] WITH NOCHECK
    ADD FOREIGN KEY ([OrigAcct]) REFERENCES [dbo].[Account] ([AcctNo]);


GO
PRINT N'Creating unnamed constraint on [dbo].[Account]...';


GO
ALTER TABLE [dbo].[Account] WITH NOCHECK
    ADD CHECK (CreditLimit>0);


GO
PRINT N'Creating unnamed constraint on [dbo].[Account]...';


GO
ALTER TABLE [dbo].[Account] WITH NOCHECK
    ADD CHECK (Balance>CreditLimit);


GO
IF '$(LoadTestData)' = 'true'

BEGIN

DELETE FROM Account;
DELETE FROM Log;

INSERT INTO Account(AcctNo, Fname,Lname,CreditLimit,Balance) VALUES
(123123, 'Aubrey', 'Graham',5000.00, 4950.00),
(123234, 'Whiz', 'Khalifa', 10000,7777.77),
(123345, 'Blac', 'Chyna', 8000,350.99),
(123456, 'Tokio','Toni', 3000, 50.00);

INSERT INTO Log(OrigAcct,LogDateTime,RecAcct,Amount) VALUES
(123123,'2019-01-23 12:00:00.000',123345,800.00),
(123123,'2019-01-24 11:00:00.000',123345,20.00),
(123345,'2019-02-04 15:00:00.000',123456,70);

END;
GO

GO
PRINT N'Checking existing data against newly created constraints';


GO
USE [$(DatabaseName)];


GO
CREATE TABLE [#__checkStatus] (
    id           INT            IDENTITY (1, 1) PRIMARY KEY CLUSTERED,
    [Schema]     NVARCHAR (256),
    [Table]      NVARCHAR (256),
    [Constraint] NVARCHAR (256)
);

SET NOCOUNT ON;

DECLARE tableconstraintnames CURSOR LOCAL FORWARD_ONLY
    FOR SELECT SCHEMA_NAME([schema_id]),
               OBJECT_NAME([parent_object_id]),
               [name],
               0
        FROM   [sys].[objects]
        WHERE  [parent_object_id] IN (OBJECT_ID(N'dbo.Log'), OBJECT_ID(N'dbo.Account'))
               AND [type] IN (N'F', N'C')
                   AND [object_id] IN (SELECT [object_id]
                                       FROM   [sys].[check_constraints]
                                       WHERE  [is_not_trusted] <> 0
                                              AND [is_disabled] = 0
                                       UNION
                                       SELECT [object_id]
                                       FROM   [sys].[foreign_keys]
                                       WHERE  [is_not_trusted] <> 0
                                              AND [is_disabled] = 0);

DECLARE @schemaname AS NVARCHAR (256);

DECLARE @tablename AS NVARCHAR (256);

DECLARE @checkname AS NVARCHAR (256);

DECLARE @is_not_trusted AS INT;

DECLARE @statement AS NVARCHAR (1024);

BEGIN TRY
    OPEN tableconstraintnames;
    FETCH tableconstraintnames INTO @schemaname, @tablename, @checkname, @is_not_trusted;
    WHILE @@fetch_status = 0
        BEGIN
            PRINT N'Checking constraint: ' + @checkname + N' [' + @schemaname + N'].[' + @tablename + N']';
            SET @statement = N'ALTER TABLE [' + @schemaname + N'].[' + @tablename + N'] WITH ' + CASE @is_not_trusted WHEN 0 THEN N'CHECK' ELSE N'NOCHECK' END + N' CHECK CONSTRAINT [' + @checkname + N']';
            BEGIN TRY
                EXECUTE [sp_executesql] @statement;
            END TRY
            BEGIN CATCH
                INSERT  [#__checkStatus] ([Schema], [Table], [Constraint])
                VALUES                  (@schemaname, @tablename, @checkname);
            END CATCH
            FETCH tableconstraintnames INTO @schemaname, @tablename, @checkname, @is_not_trusted;
        END
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH

IF CURSOR_STATUS(N'LOCAL', N'tableconstraintnames') >= 0
    CLOSE tableconstraintnames;

IF CURSOR_STATUS(N'LOCAL', N'tableconstraintnames') = -1
    DEALLOCATE tableconstraintnames;

SELECT N'Constraint verification failed:' + [Schema] + N'.' + [Table] + N',' + [Constraint]
FROM   [#__checkStatus];

IF @@ROWCOUNT > 0
    BEGIN
        DROP TABLE [#__checkStatus];
        RAISERROR (N'An error occurred while verifying constraints', 16, 127);
    END

SET NOCOUNT OFF;

DROP TABLE [#__checkStatus];


GO
PRINT N'Update complete.';


GO
