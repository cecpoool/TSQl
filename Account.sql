 CREATE TABLE [dbo].[Account] (
    [AcctNo] int,
    [Fname] NVARCHAR(50) NOT NULL,
    [Lname] NVARCHAR(50) NOT NULL,
    [CreditLimit] Money CHECK(CreditLimit<0),
    [Balance] Money CHECK(Balance>CreditLimit),
	CONSTRAINT PK_ACC PRIMARY KEY (AcctNo),
	CONSTRAINT UC_Account UNIQUE (Fname,Lname),
);
