﻿/*
Deployment script for TSQLTASK

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar LoadTestData "true"
:setvar DatabaseName "TSQLTASK"
:setvar DefaultFilePrefix "TSQLTASK"
:setvar DefaultDataPath ""
:setvar DefaultLogPath ""

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
IF '$(LoadTestData)' = 'true'

BEGIN

DELETE FROM Account;
DELETE FROM Log;

INSERT INTO Account(AcctNo, Fname,Lname,CreditLimit,Balance) VALUES
(123123, 'Aubrey', 'Graham',-5000.00, 4950.00),
(123234, 'Whiz', 'Khalifa', -10000,7777.77),
(123345, 'Blac', 'Chyna', -8000,350.99),
(123456, 'Tokio','Toni', -3000, 50.00);

INSERT INTO Log(OrigAcct,LogDateTime,RecAcct,Amount) VALUES
(123123,'2019-01-23 12:00:00',123345,800.00),
(123123,'2019-01-24 11:00:00',123345,20.00),
(123345,'2019-02-04 15:00:00',123456,70);

END;
GO

GO
PRINT N'Update complete.';


GO
