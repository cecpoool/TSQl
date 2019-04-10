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
