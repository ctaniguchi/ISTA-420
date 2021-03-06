--Name: Chase Taniguchi
--File: lab-ch08a.sql
--Date: February 18, 2020

---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 08 - Data Modification
-- © Itzik Ben-Gan 
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Inserting Data
---------------------------------------------------------------------

---------------------------------------------------------------------
-- INSERT VALUES
---------------------------------------------------------------------

USE TSQLV4;

DROP TABLE IF EXISTS dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid   INT         NOT NULL
    CONSTRAINT PK_Orders PRIMARY KEY,
  orderdate DATE        NOT NULL
    CONSTRAINT DFT_orderdate DEFAULT(SYSDATETIME()),
  empid     INT         NOT NULL,
  custid    VARCHAR(10) NOT NULL
);

select sysdatetime();
INSERT INTO dbo.Orders (orderid, orderdate, empid, custid)
  VALUES (10001, '20160212', 3, 'A');

INSERT INTO dbo.Orders(orderid, empid, custid)
  VALUES(10002, 5, 'B');

INSERT INTO dbo.Orders
  (orderid, orderdate, empid, custid)
VALUES
  (10003, '20160213', 4, 'B'),
  (10004, '20160214', 1, 'A'),
  (10005, '20160213', 1, 'C'),
  (10006, '20160215', 3, 'C');

  select * from dbo.orders;

SELECT *
FROM ( VALUES
         (10003, '20160213', 4, 'B'),
         (10004, '20160214', 1, 'A'),
         (10005, '20160213', 1, 'C'),
         (10006, '20160215', 3, 'C') )
     AS O(orderid, orderdate, empid, custid);

---------------------------------------------------------------------
-- INSERT SELECT
---------------------------------------------------------------------

select * from dbo.orders;
INSERT INTO dbo.Orders(orderid, orderdate, empid, custid)
  SELECT orderid, orderdate, empid, custid
  FROM Sales.Orders
  WHERE shipcountry = N'UK';

---------------------------------------------------------------------
-- INSERT EXEC
---------------------------------------------------------------------

DROP PROC IF EXISTS Sales.GetOrders;
GO

CREATE PROC Sales.GetOrders
  @country AS NVARCHAR(40)
AS
SELECT orderid, orderdate, empid, custid
FROM Sales.Orders
WHERE shipcountry = @country;
GO

EXEC Sales.GetOrders @country = N'France';

INSERT INTO dbo.Orders (orderid, orderdate, empid, custid)
  EXEC Sales.GetOrders @country = N'France';

  select * from dbo.orders;
---------------------------------------------------------------------
-- SELECT INTO
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Orders;

SELECT orderid, orderdate, empid, custid
INTO dbo.Orders
FROM Sales.Orders;

-- SELECT INTO with Set Operations
DROP TABLE IF EXISTS dbo.Locations;

SELECT country, region, city
INTO dbo.Locations
FROM Sales.Customers

EXCEPT

SELECT country, region, city
FROM HR.Employees;
GO

---------------------------------------------------------------------
-- BULK INSERT
---------------------------------------------------------------------

BULK INSERT dbo.Orders FROM 'c:\temp\orders.txt'
  WITH 
    (
       DATAFILETYPE    = 'char',
       FIELDTERMINATOR = ',',
       ROWTERMINATOR   = '\n'
    );
GO
--use presidents short file
drop table if exists dbo.shortpresidents;
create table dbo.shortpresidents (
president varchar(50) not null,
tookoffice varchar(50) not null,
leftoffice varchar(50) not null,
party varchar(50)not null,
homestate varchar(50) not null
);
go

BULK insert dbo.shortpresidents FROM 'D:\shortpresidents.csv'
WITH
(
	DATAFILETYPE = 'CHAR',
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\N'
	);

	select * from dbo.shortpresidents;
---------------------------------------------------------------------
-- The IDENTITY Property and Sequence Object
---------------------------------------------------------------------

---------------------------------------------------------------------
-- IDENTITY
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.T1;

CREATE TABLE dbo.T1
(
  keycol  INT         NOT NULL IDENTITY(1, 1)
    CONSTRAINT PK_T1 PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
    CONSTRAINT CHK_T1_datacol CHECK(datacol LIKE '[A-Z]%')
);
GO
--primary key is a combination of 
--not null, unique, index
insert into dbo.t1 values ('8abcd'); 
INSERT INTO dbo.T1(datacol) VALUES('AAAAA'),('CCCCC'),('BBBBB');

SELECT * FROM dbo.T1;

SELECT $identity FROM dbo.T1; 

-- Using SCOPE_IDENTITY
DECLARE @new_key AS INT;

INSERT INTO dbo.T1(datacol) VALUES('vvvvv');
select * from dbo.t1;
SET @new_key = SCOPE_IDENTITY();

SELECT @new_key AS new_key

-- Run from another connection
SELECT
  SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
  @@identity AS [@@identity],
  IDENT_CURRENT(N'dbo.T1') AS [IDENT_CURRENT];
GO

-- Run insert statements
INSERT INTO dbo.T1(datacol) VALUES('12345');
GO
INSERT INTO dbo.T1(datacol) VALUES('EEEEE');
GO

SELECT * FROM dbo.T1;

-- Using IDENTITY_INSERT 
SET IDENTITY_INSERT dbo.T1 ON;
INSERT INTO dbo.T1(keycol, datacol) VALUES(5, 'FFFFF');
SET IDENTITY_INSERT dbo.T1 OFF;

INSERT INTO dbo.T1(datacol) VALUES('GGGGG');

SELECT * FROM dbo.T1;

---------------------------------------------------------------------
-- Sequence Object
---------------------------------------------------------------------

-- create sequence and request value
DROP SEQUENCE IF EXISTS dbo.SeqOrderIDs;

CREATE SEQUENCE dbo.SeqOrderIDs AS INT
  MINVALUE 1
  CYCLE;

/*
ALTER SEQUENCE dbo.SeqOrderIDs
  RESTART WITH <constant>
  INCREMENT BY <constant>
  MINVALUE <constant> | NO MINVALUE
  MAXVALUE <constant> | NO MAXVALUE
  CYCLE | NO CYCLE
  CACHE <constant> | NO CACHE;
*/

ALTER SEQUENCE dbo.SeqOrderIDs
  NO CYCLE;

-- use
SELECT NEXT VALUE FOR dbo.SeqOrderIDs;
GO

DROP TABLE IF EXISTS dbo.T1;

CREATE TABLE dbo.T1
(
  keycol  INT         NOT NULL
    CONSTRAINT PK_T1 PRIMARY KEY,
  datacol VARCHAR(10) NOT NULL
);
GO

DECLARE @neworderid AS INT = NEXT VALUE FOR dbo.SeqOrderIDs;
INSERT INTO dbo.T1(keycol, datacol) VALUES(@neworderid, 'a');

SELECT * FROM dbo.T1;
GO


INSERT INTO dbo.T1(keycol, datacol)
  VALUES(NEXT VALUE FOR dbo.SeqOrderIDs, 'b');

SELECT * FROM dbo.T1;
GO

UPDATE dbo.T1
  SET keycol = NEXT VALUE FOR dbo.SeqOrderIDs;

SELECT * FROM dbo.T1;
GO

-- info
SELECT current_value
FROM sys.sequences
WHERE OBJECT_ID = OBJECT_ID(N'dbo.SeqOrderIDs');

-- order
INSERT INTO dbo.T1(keycol, datacol)
  SELECT
    NEXT VALUE FOR dbo.SeqOrderIDs OVER(ORDER BY hiredate),
    LEFT(firstname, 1) + LEFT(lastname, 1)
  FROM HR.Employees;
  go
SELECT * FROM dbo.T1;
GO

ALTER TABLE dbo.T1
  ADD CONSTRAINT DFT_T1_keycol
    DEFAULT (NEXT VALUE FOR dbo.SeqOrderIDs)
    FOR keycol;

INSERT INTO dbo.T1(datacol) VALUES('Q');

SELECT * FROM dbo.T1;
GO

-- range
DECLARE @first AS SQL_VARIANT;

EXEC sys.sp_sequence_get_range
  @sequence_name     = N'dbo.SeqOrderIDs',
  @range_size        = 1000000,
  @range_first_value = @first OUTPUT ;

SELECT @first;
GO

-- cleanup
DROP TABLE IF EXISTS dbo.T1;
DROP SEQUENCE IF EXISTS dbo.SeqOrderIDs;
GO

---------------------------------------------------------------------
-- Deleting Data
---------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Orders, dbo.Customers;

CREATE TABLE dbo.Customers
(
  custid       INT          NOT NULL,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

CREATE TABLE dbo.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid),
  CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid)
    REFERENCES dbo.Customers(custid)
);
GO

INSERT INTO dbo.Customers SELECT * FROM Sales.Customers;
INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;

---------------------------------------------------------------------
-- DELETE Statement
---------------------------------------------------------------------

select * from dbo.orders;
DELETE FROM dbo.Orders
WHERE orderdate < '20150101';
GO

---------------------------------------------------------------------
-- TRUNCATE
---------------------------------------------------------------------

-- Code to create the table T1 (partitioned) if you want to run the examples that follow
DROP TABLE IF EXISTS dbo.T1;
IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = N'PS1') DROP PARTITION SCHEME PS1;
IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = N'PF1') DROP PARTITION FUNCTION PF1;

CREATE PARTITION FUNCTION PF1 (INT) AS RANGE LEFT FOR VALUES (10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120);
CREATE PARTITION SCHEME PS1 AS PARTITION PF1 ALL TO ([PRIMARY]);

CREATE TABLE dbo.T1
(
  keycol INT NOT NULL
    CONSTRAINT PK_T1 PRIMARY KEY,
  datacol INT NOT NULL
) ON PS1(keycol);
GO

-- TRUNCATE statement examples
TRUNCATE TABLE dbo.T1;
GO

TRUNCATE TABLE dbo.T1 WITH ( PARTITIONS(1, 3, 5, 7 TO 10) );
GO

-- Cleanup
DROP TABLE IF EXISTS dbo.T1;
IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = N'PS1') DROP PARTITION SCHEME PS1;
IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = N'PF1') DROP PARTITION FUNCTION PF1;

---------------------------------------------------------------------
-- DELETE Based on Join
---------------------------------------------------------------------

-- Using a join
DELETE FROM O
--select *
FROM dbo.Orders AS O
  INNER JOIN dbo.Customers AS C
    ON O.custid = C.custid
WHERE C.country = N'USA';

-- Using a subquery
DELETE FROM dbo.Orders
WHERE EXISTS
  (SELECT *
   FROM dbo.Customers AS C
   WHERE Orders.custid = C.custid
     AND C.country = N'USA');

-- cleanup
DROP TABLE IF EXISTS dbo.Orders, dbo.Customers;

