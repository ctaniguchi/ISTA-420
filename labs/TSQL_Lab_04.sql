--Name: Chase Taniguchi
--File: ch04-lab.sql
--Date: February 3, 2020

use tsqlv4;
--1. What is our highest priced product? Report the product id, product name, and unit price. Use a
--self-contained, scalar valued subquery
select productid, productname, unitprice
	from Production.Products
	where unitprice = 
		(select max(unitprice) from Production.products);

	go 


--2. What is our most popular product in terms of quantity sold? 
--Report the product name and productid. Use a self-contained, scalar valued subquery.
 select productname, productid 
  from Production.Products
  where productid = 
  (select top 1 productid 
	from Sales.OrderDetails
	group by productid
	order by sum(qty) desc);
  go

  --3. Who is our top salesperson overall? Include the employee id, title, first name, and last name. 
  --Use a self-contained, scalar valued subquery.
   select empid, title, firstname, lastname
  from HR.Employees
  where empid = 
  (select top 1 empid
	from Sales.Orders
	group by empid
	order by count(orderid) desc);
go


--4. I want to examine the individual orders. 
--Specifically, I want to look at each order and compare the
--total of each order line with the average total of all order lines in the order. 
--Report the order id, the total of each order line, and the average of all order lines for each order.
--Use a correlated, scalar valued subquery.
select od.orderid, (od.unitprice * od.qty) as line_total, (
	select avg(unitprice * ood.qty)
		from Sales.OrderDetails ood
		where ood.orderid = od.orderid
    ) as order_avg
    from Sales.OrderDetails od;


--5. What is the largest quantity ordered by a customer for every order? 
--Report the order id, the productid, and the quantity ordered. 
--Use a correlated subquery in the WHERE clause.
select od.orderid, od.productid, OD.qty
	 from Sales.OrderDetails od
	 where qty = (
	  select max(ood.qty)
	  from Sales.OrderDetails OOD
	   where OOD.orderid = OD.orderid)
	   order by od.orderid;

