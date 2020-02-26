/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [OrderID]
      ,[CustomerID]
      ,[EmployeeID]
      ,[OrderDate]
      ,[RequiredDate]
      ,[ShippedDate]
      ,[ShipVia]
      ,[Freight]
      ,[ShipName]
      ,[ShipAddress]
      ,[ShipCity]
      ,[ShipRegion]
      ,[ShipPostalCode]
      ,[ShipCountry]
  FROM [Northwind].[dbo].[Orders]

  --1
  select * from orders;

  select employeeid from orders;
  select employeeid from orders
  group by employeeid;

  select top(5) employeeid, count(employeeid) as totalsales
  from orders group by employeeid
  order by totalsales desc;

--2
select productid, avg(discount) as avgdiscount
from [Order Details]
where unitprice > 50.0
group by Productid;

select productid, unitprice, avg(discount) as avgdiscount
from [Order Details]where unitprice > 50.0
group by productid, unitprice order by unitprice desc;



  --3 am doing an analysis of which shippers ship to each country, and I need a report showing the number
  --of orders each shipper delivered to each country and the nuber of orders. I don't need the data where
  --the number of orders is ten or less, but I need the report listed by country and the number of orders
  --shipped to that country.
  select shipvia, shipcountry,
  count(orderid) as number_of_orders_delivered
  from orders group by shipvia, shipcountry having count(orderid) > 10
  order by shipcountry, number_of_orders_delivered desc;




  --4 For each order, what was the time lag between the order date and the ship date?
  select orderid, orderdate, shippeddate, ShipVia, DATEDIFF(day, orderdate, shippeddate) as TimeLag
  from Orders order by ShipVia


  --5 Continuing with the previous query, I need the average time lag for each shipper.
 select ShipVia, avg(DATEDIFF(day, orderdate, shippeddate)) as AvgTimeLag
  from Orders group by ShipVia


  --6
  select * from products;

  select productname, unitprice * unitsinstock as producttotalvalue
  from products order by productname asc;


  --7
  select sum(unitprice * unitsinstock) as totalvalue
  from products 


  --8 We have discovered that some customers favor certain employees. I need to know this information. I
--need a report of the most common employee/customer pairs, the nuber of times the employee took
--orders from the customer, and the number of orders. Alphabetize this by customer id. Omit cus-
--tomer/employee pairs whre the number of orders is less than ve.
select * from orders

select customerid, employeeid, count(customerid)  as TotalCustomers from orders 
group by customerid, employeeid
having count(customerid) > 4
order by customerid

--9
select datediff_big(ns, '19900820', getdate()) as nonosecondsold;





--10 Answer these questions using the built in time and date function.
--What is today's date?
-- What was the rst day of the month?
--What will be the rst day of the next month?
--What is the last day of this month?
select getdate();
select datefromparts(year(getdate()), month(getdate()), 1);
select eomonth(getdate() + 30);
select getdate() + 30;
select datefromparts(year(getdate()), month(getdate()) + 1, 1);



