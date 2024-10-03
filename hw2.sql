--  1.How many products can you find in the Production.Product table?

SELECT COUNT(DISTINCT ProductID) AS NumOfProducts
FROM Production.Product;

-- 2. Write a query that retrieves the number of products in the Production.
-- Product table that are included in a subcategory. The rows that have NULL 
-- in column ProductSubcategoryID are considered to not be a part of any 
-- subcategory.
SELECT COUNT(DISTINCT ProductSubcategoryID) AS NumOfProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL;

-- 3. How many Products reside in each SubCategory? Write a query to display 
--the results with the following titles.

-- ProductSubcategoryID CountedProducts

SELECT ProductSubcategoryID, COUNT(DISTINCT ProductID) AS "CountedProducts"
FROM Production.Product
GROUP BY ProductSubcategoryID;


-- 4. How many products that do not have a product subcategory.
SELECT COUNT(DISTINCT ProductID) AS CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL;

-- 5.Write a query to list the sum of products quantity in the 
-- Production.ProductInventory table.
SELECT SUM(Quantity) AS SumOfQuantity
FROM Production.ProductInventory;

-- 6.Write a query to list the sum of products in the 
-- Production.ProductInventory table and LocationID set to 40 and 
-- limit the result to include just summarized quantities less than 100.
    -- ProductID    TheSum


SELECT ProductID, COUNT(ProductID) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY ProductID
HAVING SUM(Quantity) < 100;

-- 7.Write a query to list the sum of products with the shelf information 
-- in the Production.ProductInventory table and LocationID set to 40 and 
-- limit the result to include just summarized quantities less than 100
    -- Shelf      ProductID    TheSum

SELECT Shelf, ProductID, SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY Shelf, ProductID
HAVING SUM(Quantity)<100

-- 8. Write the query to list the average quantity for products where 
-- column LocationID has the value of 10 from the table 
-- Production.ProductInventory table.
SELECT ProductID, AVG(Quantity)
FROM Production.ProductInventory
WHERE LocationID = 10
GROUP BY ProductID;

-- 9.Write query  to see the average quantity  of  products by shelf  
-- from the table Production.ProductInventory
    -- ProductID   Shelf      TheAvg

SELECT ProductID, Shelf, AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
GROUP BY ProductID, Shelf;

-- 10.Write query  to see the average quantity  of  products by shelf 
-- excluding rows that has the value of N/A in the column Shelf from 
-- the table Production.ProductInventory
    -- ProductID   Shelf      TheAvg

SELECT ProductID, Shelf, AVG(Quantity)
FROM Production.ProductInventory
WHERE Shelf IS NOT NULL AND Shelf != 'N/A'
GROUP BY ProductID, Shelf;

-- 11.List the members (rows) and average list price in the 
-- Production.Product table. This should be grouped independently 
-- over the Color and the Class column. Exclude the rows where Color or 
-- Class are null.
    -- Color   Class  TheCount AvgPrice
SELECT Color, Class, COUNT(*) AS TheCount, AVG(ListPrice) AS AvgPrice
FROM Production.Product
WHERE Color IS NOT NULL AND Class IS NOT NULL
GROUP BY Color, Class;

-- Joins:

-- 12.Write a query that lists the country and province names from 
-- person. CountryRegion and person. StateProvince tables. Join them 
-- and produce a result set similar to the following.
-- Country                        Province

SELECT c.Name AS "Country", s.Name AS "Province"
FROM Person.CountryRegion AS "c"
INNER JOIN Person.StateProvince AS "s" ON c.CountryRegionCode = s.CountryRegionCode;

-- 13.Write a query that lists the country and province names from 
-- person. CountryRegion and person. StateProvince tables and list the 
-- countries filter them by Germany and Canada. Join them and produce a 
-- result set similar to the following.
-- Country   Province
SELECT c.Name AS "Country", s.Name AS "Province"
FROM Person.CountryRegion AS "c"
INNER JOIN Person.StateProvince AS "s" ON c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name IN ('Germany','Canada');


-- Using Northwnd Database: (Use aliases for all the Joins)

USE Northwind
-- 14.  List all Products that has been sold at least once in last 27 years.
SELECT od.ProductID,o.OrderDate
FROM Orders AS o INNER JOIN [Order Details] AS od ON o.OrderID = od.OrderID
WHERE o.OrderDate>='1997-01-01';

-- 15.  List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 ShipPostalCode, COUNT(*) AS CNT
FROM Orders AS o INNER JOIN "Order Details" AS od ON o.OrderID = od.OrderID
WHERE o.ShipPostalCode IS NOT NULL
GROUP BY o.ShipPostalCode
ORDER BY CNT DESC;


-- 16.List top 5 locations (Zip Code) where the products sold most in last 27 years.
SELECT TOP 5 o.ShipPostalCode, COUNT(*) AS CNT
FROM Orders AS o INNER JOIN "Order Details" AS od ON o.OrderId = od.OrderID
WHERE o.OrderDate >='1997-01-01' AND o.ShipPostalCode IS NOT NULL
GROUP BY o.ShipPostalCode
ORDER BY CNT DESC;

-- 17.List all city names and number of customers in that city.
SELECT City, COUNT(CustomerID) AS CNT
FROM Customers
GROUP BY City;

-- 18. List city names which have more than 2 customers, and number of customers in that city
SELECT City, COUNT(CustomerID) AS CNT
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID)>2;

-- 19.  List the names of customers who placed orders after 1/1/98 with order date.
SELECT c.ContactName, dt.OrderDate
FROM Customers AS c
INNER JOIN
(SELECT *
FROM Orders
WHERE OrderDate >= '1998-01-01') AS dt ON c.CustomerID=dt.CustomerID;


-- 20.List the names of all customers with most recent order dates
SELECT c.ContactName, dt.RecentDate
FROM Customers AS c 
INNER JOIN 
(SELECT CustomerID, MAX(OrderDate) AS RecentDate
FROM Orders
GROUP BY CustomerID) AS dt ON c.CustomerID = dt.CustomerID;

-- 21.Display the names of all customers along with the count of products they bought
SELECT c.ContactName, dt.CNT
FROM Customers c
INNER JOIN 
(SELECT CustomerID, COUNT(od.ProductID) CNT
FROM Orders AS o INNER JOIN [Order Details] AS od ON o.OrderID = od.OrderID
GROUP BY CustomerID) AS dt ON c.CustomerID = dt.CustomerID;

-- 22.Display the customer ids who bought more than 100 Products with count of products.
SELECT c.CustomerID, dt.CNT
FROM Customers c
INNER JOIN 
(SELECT CustomerID, COUNT(od.ProductID) CNT
FROM Orders AS o INNER JOIN [Order Details] AS od ON o.OrderID = od.OrderID
GROUP BY CustomerID) AS dt ON c.CustomerID = dt.CustomerID
WHERE dt.CNT>100;


-- 23.List all of the possible ways that suppliers can ship their products. Display the results as below
SELECT DISTINCT "Supplier Company Name","Shipping Company Name"
FROM
(SELECT p.ProductID, s.CompanyName AS "Supplier Company Name", od.OrderID
FROM Products AS p, Suppliers AS s, [Order Details] AS od
WHERE p.ProductID = od.ProductID AND s.SupplierID=p.SupplierID) AS dt1
INNER JOIN
(SELECT o.OrderID,s.CompanyName AS "Shipping Company Name"
FROM Orders AS o
INNER JOIN Shippers AS s ON o.ShipVia = s.ShipperID) AS dt2
ON dt1.OrderID = dt2.OrderID


-- 24.Display the products order each day. Show Order date and Product Name.
SELECT DISTINCT o.OrderDate,p.ProductName
FROM Orders AS o, "Order Details" AS od, Products AS p
WHERE o.OrderID = od.OrderID AND od.ProductID = p.ProductID
ORDER BY o.OrderDate

-- 25.  Displays pairs of employees who have the same job title.

SELECT e1.FirstName+' '+e1.LastName AS "First Employee", e2.FirstName+' '+e2.LastName AS "Second Employee"
FROM Employees AS e1
INNER JOIN Employees AS e2 ON e1.Title = e2.Title AND e1.FirstName+' '+e1.LastName!=e2.FirstName+' '+e2.LastName;


-- 26.  Display all the Managers who have more than 2 employees reporting to them.
SELECT e2.EmployeeID, COUNT(*) AS CNT
FROM Employees AS e1
INNER JOIN Employees AS e2 ON e1.ReportsTo = e2.EmployeeID
GROUP BY e2.EmployeeID
HAVING COUNT(*)>2;


-- 27. Display the customers and suppliers by city. The results should have the following columns
-- City, Name ,Contact Name, Type (Customer or Supplier)
SELECT City, CompanyName,ContactName, 'Customer' AS "Type"
FROM Customers
UNION ALL
SELECT City, CompanyName,ContactName, 'Supplier' AS "Type"
FROM Suppliers