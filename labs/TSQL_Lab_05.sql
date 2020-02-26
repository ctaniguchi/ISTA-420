--Name: Chase Taniguchi
--File: TSQL_Lab_05.sql
--Date: February 4, 2020

use tsqlv4;


--1. 
--Write a report returning the order id, the shipper name,
--the order date and the city shipped to using a derived table
select so.orderid, so.shippername, so.orderdate, so.shipcity
 from (
 select s.companyname as shippername, s.shipperid, o.orderid, o.orderdate, o.shipcity
	from Sales.Orders o join Sales.Shippers s 
	on o.shipperid = s.shipperid
 ) so;

--2.
--I need a report showing how many orders each customer made during each year. Return the customer
--id, the year, and the number of orders the customer placed during that year. Use a derived table.
select ria.custid, ria.custyear, ria.totalorders
  from (
  select o.custid, year(o.orderdate) as custyear, count(o.orderid) as totalorders
	from Sales.Orders o
	group by o.custid, year(o.orderdate) 
  ) ria
  order by ria.custid, custyear;

 --3.
 -- What is the growth or decline in the number of orders taken year by year? 
 --Your report should contain the year, this years order's, last year's orders, 
 --and the difference between the two. Join two derived tables.
 select this_year, cur_orders, prev_orders, (cur_orders - prev_orders) as diff
  from (
   select year(orderdate) this_year, count(orderid) cur_orders
   from Sales.orders 
   group by year(orderdate)) cy
   left join
   (select year(orderdate) as last_year, count(orderid) as prev_orders from Sales.orders
   group by year(orderdate)) py
   on cy.this_year = py.last_year + 1;


 --6
-- Create a view that aggregates the number of orders per customer per year. Then run a query against 
--e view sorting the customers by customer id. Don't forget to drop the view if one exists before you
--eate it. Use the DBO schema.
 DROP VIEW IF EXISTS dbo.bob;
 go
 CREATE VIEW dbo.bob
 AS
 select custid, year(orderdate) as custyear, count(orderid) as order_count
	from sales.Orders
	group by custid, year(orderdate)
--rder by custid, year(orderdate)
GO
select custid, custyear, order_count from dbo.bob
 order by custid, custyear;

 --7.
--reate a view similar to the Production.Products table, but include the category name as a column.
--e the DBO schema. This is an example of denormalizing a database table. After going to all the
--ouble of normalizing a database, can you think of a good reason to denormalize it?
DROP VIEW IF EXISTS dbo.prodcat;
go
create view dbo.prodcat
as 
select p.productid, p.productname, p.unitprice, c.categoryname
 from Production.Products p
 join Production.Categories c
 on p.categoryid = c.categoryid
 go
 select * from dbo.prodcat;