CREATE TABLE [dbo].[Log] (
    [OrigAcct] int,
    [LogDateTime] DateTime,
    [RecAcct] int,
    [Amount] Money NOT NULL
	CONSTRAINT PK_LOG PRIMARY KEY (OrigAcct,LogDateTime),
	FOREIGN KEY (OrigAcct) REFERENCES Account(AcctNo)
);
