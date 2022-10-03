
use northwind_spp;

Which customers have made at least one purchase of 15K+?
SELECT c.customerID ,c.companyname ,o.orderID ,sum(quantity * unitprice) as totalorderamount
FROM customers c join orders o on o.customerID = c.customerID 
join orderdetails od on o.orderID = od.orderID 
WHERE year(orderdate) =2016
GROUP BY c.customerID, c.companyName ,o.orderID
HAVING sum(quantity*unitprice) >=15000;


Generate a random set order IDs of 2% of orders:
SELECT top 2 percent orderID 
FROM orders 
ORDER BY newID();


There was an order accidentally entered twice. Find it.
with potentialduplicates as 
(SELECT orderID 
FROM orderdetails 
WHERE quantity >= 60 
GROUP BY orderID ,quantity 
HAVING COUNT(*) > 1) 
SELECT orderID ,productID ,unitprice ,quantity ,discount 
FROM orderdetails 
WHERE orderID in (Select OrderID from potentialduplicates) 
ORDER BY orderID ,quantity;


Some employees are responsible for orders that end up arriving late. Find them and the total amount of orders they are responsible for.
with lateorders as 
(SELECT employeeID ,COUNT(*) as totalorders
FROM orders 
WHERE requireddate <= shippeddate 
GROUP BY EmployeeID), 
allorders as 
(SELECT employeeID ,COUNT(*) as totalorders 
FROM orders o GROUP BY employeeID) 
SELECT e.employeeID ,lastName , a.totalorders as allorders ,l.totalOrders as lateorders 
FROM employees e join allorders a on a.EmployeeID = e.EmployeeID join lateorders l on l.employeeID = e.employeeID;  
ORDER BY e.employeeID;


Put customers into categories based on order amounts:
with orders2016 as 
(SELECT c.customerID ,c.companyname ,totalorderamount = SUM(Quantity * UnitPrice) 
FROM customers c
join orders o on o.CustomerID = c.customerID join orderdetails od on o.orderID = od.orderID 
WHERE year(orderdate) = 2016 
GROUP BY c.customerID, c.companyname ) 
SELECT customerID,companyname,totalorderamount,
customergroup = CASE 
when totalorderamount >= 0 and totalorderamount  < 1000 then 'Low' 
when totalorderamount >= 1000 and totalorderamount  < 5000 then 'Medium' 
when totalorderamount >= 5000 and totalorderamount  <10000 then 'High' 
when totalorderamount >= 10000 then 'Very High' 
end 
FROM orders2016 
ORDER BY totalorderamount DESC;


Pull together two tables (suppliers and customers) based on country:
SELECT country 
FROM customers 
UNION 
SELECT country 
FROM suppliers 
ORDER BY country;

Find the first order for each country:
with ordersbycountry as 
(SELECT shipcountry ,customerID ,orderID ,orderdate = convert(date, orderdate) ,rownumberpercountry = row_number() 
over (partition by shipcountry ORDER BY shipcountry, orderID) FROM orders) 
SELECT shipcountry ,customerID ,orderID ,orderDate 
FROM ordersbycountry 
WHERE rownumberpercountry = 1 
ORDER BY shipcountry;


Some customers are interested in combining smaller orders into a larger one. Show customers who have made more than one order in a 5 day period.
SELECT io.customerID, initialorderID = io.orderID ,initialorderdate = convert(date, io.orderdate),
nextorderID = no.orderID ,nextorderdate = convert(date, no.orderdate) ,daysbetweenorders = datediff(dd, io.orderdate, 
no.orderdate) 
FROM orders io join orders no on io.customerID = no.customerID 
WHERE io.orderID < no.orderID and datediff(dd, io.orderdate, no.orderdate) <= 5 
ORDER BY io.customerID ,io.OrderID
