-- aggragation function + group by
-- subquery
-- derived table
-- union VS union all 
-- window function
-- cte


-- temp table: store data temporaily

-- local temp table: #
-- lifescope: is within the connection that created it.
-- stored in the 

CREATE TABLE #LocalTemp(
    Num INT
)
DECLARE @Variable INT = 1
WHILE (@Variable <=10)
BEGIN 
INSERT INTO #LocalTemp(Num) VALUES(@Variable)
SET @Variable = @Variable +1
END 

SELECT * 
FROM #LocalTemp

SELECT * 
FROM tempdb.sys.tables

-- global temp table: ##
-- lifescope: can be accessed by different sessions also stored in tempdb.

CREATE TABLE ##GlobalTemp(
    Num INT
)
DECLARE @Variable2 INT = 1
WHILE (@Variable2 <=10)
BEGIN 
INSERT INTO ##GlobalTemp(Num) VALUES(@Variable2)
SET @Variable2 = @Variable2 +1
END 

SELECT * 
FROM ##GlobalTemp

SELECT * 
FROM tempdb.sys.tables

-- table variable: a variable of table type
-- lifescope: submit and use within a single batch
DECLARE @today DATETIME 
SELECT @today = GETDATE()
PRINT @today


DECLARE @WeekDays TABLE(
    DayNum INT,
    DayAbb VARCHAR(20),
    WeekName VARCHAR(20)
)
INSERT INTO @WeekDays VALUES
(1,'Mon','Monday'),
(2,'Tue','Tuesday'),
(3,'Wed','Wednesday'),
(4,'Thus','Thursday'),
(5,'Fri','Friday')

SELECT * 
FROM @WeekDays

-- Temp table VS table variable
-- 1. both are stored in tempdb
-- 2. scope: local/global temp table, table vairable:current batch
-- 3.different size. size:>100 rows go with temp table. size<100 rows then go table variables.
-- 4. we can not use temp table in sp (stored procedures) or udf (user defined function)but can use table variable in sp or udf.
                                
-- View: virtual table that contains data from one or multiple tables. 
USE SepBatch
SELECT *
FROM Employee

INSERT INTO Employee VALUES
(1,'Fred',5000),
(2,'Laura',7000),
(3,'Amy',6000)

CREATE VIEW vwEmp
AS 
SELECT id, EName, Salary
FROM Employee

SELECT * 
FROM vwEmp

-- stored procedures: prepared sql query that we can save in our database and reuse it whenever we want to.
BEGIN 
    PRINT 'hello world'
END 

CREATE PROCEDURE spHello
AS 
BEGIN
PRINT 'Hello world'
END 

EXECUTE spHello

-- advantages of sp: 
-- 1. allow you to reuse the same logic
-- 2. it can be used to prevent sql injection because it can take parameters
    -- if hackers inject malicious code into our sql queries thus, destroying database

SELECT id,Name
FROM User
WHERE id = 1 UNION ALL SELECT id, Password FROM User 

-- input: default type

CREATE PROCEDURE spAddNum
@a INT,
@b INT
AS
BEGIN 
    PRINT @a + @b 
END

EXECUTE spAddNum 1, 4

-- output
CREATE PROCEDURE spGetName
@id INT,
@EName VARCHAR(20) OUT
AS 
BEGIN
    SELECT EName
    FROM Employee
    WHERE Id = @id
END 

BEGIN 
    DECLARE @En VARCHAR(20)
    EXEC spGetName 2, @En OUT
    PRINT @En
END

-- sp can also return tables

CREATE PROC spGetAllEmp
AS
BEGIN 
    SELECT *
    FROM Employee
END 
EXEC spGetAllEmp


-- trigger: special type of stored procedure that will automically run when there is an event that occurs
-- DML trigger
-- DDL trigger
-- LogOn trigger

-- lifescope sp and views: will stay in db forever as long as you dont want to drop them

-- Functions:
-- built-in
-- user defined function: for calculation

CREATE FUNCTION GetTotalRevenue (@price money, @discount real, @quantity int)
RETURNS money
AS 
BEGIN 
    DECLARE @revenue money
    SET @revenue = @price*1+(1-@discount)*@quantity
    RETURN @revenue
END

SELECT UnitPrice, Quantity, Discount,dbo.GetTotalRevenue(UnitPrice, Quantity, Discount) AS revenue
FROM [Order Details]

-- benefit of using udf: complex calculation; can also return a table

-- sp VS udf
-- 1. usage:sp for dml, udf for calculation
-- 2. how to call them: sp called by exec, function must be used in sql statment.
-- 3. input/output: sp may or may not have input or output parameters. udf may or may not have input, but must have output parameter.

-- pagination: 
-- offset: skip
-- fetch next x rows: select
SELECT CustomerID, ContactName, City
FROM Customers
ORDER BY CustomerID
OFFSET 10 ROWS

SELECT CustomerID, ContactName, City
FROM Customers
ORDER BY CustomerID
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY


-- top VS offset, fetch next
-- top: fetch top serval records, use it or without order by
-- offset and fetch: only use it with order by 

DECLARE @pageNum INT
DECLARE @rowsOfPage INT
DECLARE @MaxTablePage FLOAT
SET @pageNum = 1
SET @rowsOfPage = 10
SELECT @MaxTablePage = COUNT(*) FROM Customers
SET @MaxTablePage = CEILING(@MaxTablePage/@rowsOfPage)
WHILE @pageNum <= @MaxTablePage
BEGIN
SELECT CustomerID, ContactName, City
FROM Customers
ORDER BY CustomerID
OFFSET (@pageNum-1)*@rowsOfPage ROWS
FETCH NEXT @rowsOfPage ROWS ONLY
SET @PageNum = @PageNum+1
END 

-- normalization

-- 1nf, 2nf, 3nf, bcnf

-- one to many relationship
-- many to many relationships: create a conjunction table
-- Ex: student and class: enrollment table

-- contraints
USE SepBatch

DROP TABLE Employee
CREATE TABLE Employee(
    id INT PRIMARY KEY,
    EName VARCHAR(20) NOT NULL,
    Age INT NOT NULL
)

INSERT INTO Employee VALUES (1,'Sam',45)
INSERT INTO Employee VALUES (2,'ashd',50)
SELECT *
FROM Employee


-- primary key VS unique constrainst
-- 1. unique key can accept and one and only null value, primary key will not accept any null value
-- 2. one table can have multiple unique keys, but only one primary key.
-- 3. pk will sort data by default, but unique key will not
-- 4. pk will create clustered index by default and unique key will create non clustered index.

DELETE Employee
INSERT INTO Employee VALUES (3,'Sam',45)
INSERT INTO Employee VALUES (1,'Fiona',50)
INSERT INTO Employee VALUES (2,'Fred',55)
INSERT INTO Employee VALUES (4,'Stella',55)