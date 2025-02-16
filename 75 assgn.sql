use AdventureWorks2022;


--Q1. find the average currency rate conversion from USD to Algerian Dinar and Australian Dollar 
select CONCAT_WS('  To  ',FromCurrencyCode,ToCurrencyCode) Currency_Conversion,
avg(AverageRate)
from Sales.CurrencyRate 
where FromCurrencyCode='USD' and ToCurrencyCode in('DZD','AUD')
group by FromCurrencyCode,ToCurrencyCode;

------------------------------------------------------------------------------
--Q2. Find the products having offer on it and display product name , safety Stock Level, Listprice,
--and product model id, type of discount,  percentage of discount,  offer start date and offer end date
select 
p.ProductModelID as Prdt_model_ID,
p.Name as Prdt_name,
p.SafetyStockLevel as Safe_stocklevel,
p.ListPrice as listprice,
sp.DiscountPct as discount_percent,
sp.Type as discount_type,
CONCAT_WS(' and ', sp.StartDate, sp.EndDate) as start_enddate
from sales.SpecialOfferProduct sop
join Production.Product p on p.ProductID = sop.ProductID
join sales.SpecialOffer sp on sp.SpecialOfferID = sop.SpecialOfferID;

-----------------------------------------------------------------------------------------------
--Q3. create  view to display Product name and Product review
select p.Name,r.Comments
from Production.Product p
join Production.ProductReview r on p.ProductID = r.ProductID;
---------------------------------------------------------------

--Q4. find out the vendor for product  paint, Adjustable Race and blade
select
pv.BusinessEntityID, 
v.Name as vendor_name, 
p.Name as prdt_name
from Purchasing.ProductVendor pv
join Purchasing.Vendor v ON v.BusinessEntityID = pv.BusinessEntityID
join Production.Product p ON p.ProductID = pv.ProductID
where p.Name like '%Paint%' 
or p.Name like '%Blade%' 
or p.Name = 'Adjustable Race';
------------------------------------------------------------------------------------------

--Q5. find product details shipped through ZY - EXPRESS
select 
p.Name as ProductName, 
p.ProductNumber as ProductNumber, 
sm.ShipMethodID as ShipID, 
sm.Name as ShipName
from Purchasing.PurchaseOrderDetail pd
join Purchasing.PurchaseOrderHeader ph on pd.PurchaseOrderID = ph.PurchaseOrderID
join Production.Product p on p.ProductID = pd.ProductID
join Purchasing.ShipMethod sm on sm.ShipMethodID = ph.ShipMethodID
where sm.Name like 'ZY - EXPRESS';
---------------------------------------------------------------------------

--Q6. find the tax amt for products where order date and ship date are on the same day
select 
(select p.Name from Production.Product p where p.ProductID=pd.ProductID) as Prdt_name,
ph.TaxAmt as Tax_amt
from Purchasing.PurchaseOrderDetail pd
join Purchasing.PurchaseOrderHeader ph 
on pd.PurchaseOrderID = ph.PurchaseOrderID
where day(ph.OrderDate)=day(ph.ShipDate);

---------------------------------------------------------------------------------------------
--Q7. find the average days required to ship the product based on shipment type
select 
ps.Name as Shipment_Type, 
avg(DATEDIFF(DAY, ph.OrderDate, ph.ShipDate)) as Avg_shipp_days
from Purchasing.PurchaseOrderHeader ph
join Purchasing.ShipMethod ps on ph.ShipMethodID = ps.ShipMethodID
where ph.ShipDate is not null
group by ps.Name
order by Avg_shipp_days desc;

---------------------------------------------------------------------------------------------------
--Q8. find the name of employees currently working in day shift
select CONCAT_WS(' ',FirstName,MiddleName,LastName) as emp_name 
from Person.Person
where BusinessEntityID in 
(select BusinessEntityID from HumanResources.EmployeeDepartmentHistory 
where ShiftID in (select ShiftID from HumanResources.Shift where Name='DAY'));


--Q9. based on product and product cost history find the name , service provider time and average Standardcost  
select 
p.Name as Product_Name,
DATEDIFF_BIG(DAY,MIN(StartDate),MAX(EndDate)) as ser_pvd_time,
AVG(ph.StandardCost)as Average_Standard_Cost
from Production.ProductCostHistory ph
join Production.Product p on ph.ProductID=p.ProductID
group by p.Name;


--Q10. find products with average cost more than 500
select P.Name,
Avg(pc.StandardCost) as avg_std_cost
from Production.ProductCostHistory pc
join Production.Product p on pc.ProductID=p.ProductID
group by p.Name 
having avg(pc.StandardCost)>500;


--Q11. find the employee who worked in multiple territory
select
p.BusinessEntityID,
CONCAT(p.FirstName, ' ', p.LastName) as Emp_name,
COUNT(distinct sth.TerritoryID) as TerritoryCount
from HumanResources.Employee e
join Person.Person p on p.BusinessEntityID = e.BusinessEntityID
join Sales.SalesTerritoryHistory sth on e.BusinessEntityID = sth.BusinessEntityID
group by p.BusinessEntityID, p.FirstName, p.LastName
having COUNT(distinct sth.TerritoryID) > 1
order by TerritoryCount desc;


--Q12. find out the Product model name,  product description for culture as Arabic
select pm.Name as Prdt_modelname,
pd.Description as Prdt_descp
from Production.ProductModel pm
join Production.ProductModelProductDescriptionCulture pdc on pm.ProductModelID=pdc.ProductModelID
join Production.ProductDescription pd on pd.ProductDescriptionID=pd.ProductDescriptionID
join Production.Culture pc on pc.CultureID=pdc.CultureID
where pc.Name like 'Arabic'
group by pm.Name,pd.Description;


--Q13. Find first 20 employees who joined very early in the company
select top 20
e.BusinessentityID,
p.Firstname + ' ' + p.Lastname as emp_name,
e.Hiredate
from HumanResources.Employee e
join person.person p
on e.BusinessentityID = p.BusinessEntityID
order by e.Hiredate asc;


--Q14. Find most trending product based on sales and purchase
select top 1 
p.ProductID,
p.Name AS ProductName,
SUM(sod.OrderQty) as TotalSales,
SUM(pod.OrderQty) as TotalPurchases,
(SUM(sod.OrderQty) + SUM(pod.OrderQty)) as TotalTrendScore
from Production.Product p
left join Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
left join Purchasing.PurchaseOrderDetail pod on p.ProductID = pod.ProductID
group by p.ProductID, p.Name
order by TotalTrendScore desc;


--SUBQUERIES

--Q15. display EMP name, territory name, saleslastyear salesquota and bonus
select territoryId,
(select CONCAT(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sp.BusinessEntityID) as Emp_name,
(select Name from sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)as Terri_name,
(select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sp.TerritoryID)as Group_name,
SalesLastYear, SalesQuota, Bonus 
from sales.SalesPerson sp;


--Q16. display EMP name, territory name, saleslastyear salesquota and bonus from Germany and United Kingdom
select TerritoryID,
(select CONCAT(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sp.BusinessEntityID)as Emp_name,
(select Name from sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)as Terri_name,
(select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sp.TerritoryID)as Group_name,
SalesLastYear, SalesQuota, Bonus
from sales.SalesPerson sp
where sp.TerritoryID in (select TerritoryID 
from Sales.SalesTerritory 
where Name IN ('United Kingdom', 'Germany'));


--Q17.Find all employees who worked in all North America territory
select distinct TerritoryId,
(select distinct concat(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=sp.BusinessEntityID) as Emp_Name,
(select name  from Sales.SalesTerritory st where  st.TerritoryID=sp.TerritoryID) as Terri_name,
(select [Group] from Sales.SalesTerritory st1 where st1.TerritoryID=sp.TerritoryID) as Group_name
from Sales.SalesTerritoryHistory sp WHERE sp.TerritoryID in (select TerritoryID 
from Sales.SalesTerritory 
where [Group] IN ('North America'));


--Q18. find all products in the cart
select 
(select Name from Production.Product pp where pp.ProductID=ssci.ProductID) as Prdt_name,
(select ProductNumber from Production.Product pp1 where pp1.ProductID=ssci.ProductID) as Prdt_num, Quantity
from Sales.ShoppingCartItem ssci;


--Q19. find all the products with special offer
select distinct(Name)
from Production.Product pp where pp.ProductID 
in(select ProductID 
from Sales.SpecialOfferProduct);


--Q20. find all employees name , job title, card details whose credit card expired in the month 11 and year as 2008
select(select CONCAT_WS(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=pc.BusinessEntityID)EmpName,
(select JobTitle from HumanResources.Employee  e where e.BusinessEntityID=pc.BusinessEntityID)Job_Description,
(select CONCAT_WS(' : ',ExpMonth,ExpYear )from Sales.CreditCard cc where cc.CreditCardID=pc.CreditCardID)Card_detail
from Sales.PersonCreditCard pc where pc.CreditCardID in(select CreditCardID from Sales.CreditCard cc where cc.ExpMonth=11 and cc.ExpYear=2008);


--Q21. Find the employee whose payment might be revised  (Hint : Employee payment history)
select e.BusinessEntityID, p.FirstName, p.LastName, COUNT(eph.RateChangeDate) as PayRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e on eph.BusinessEntityID = e.BusinessEntityID
join Person.Person p on e.BusinessEntityID = p.BusinessEntityID;


--Q22. Find total standard cost for the active Product. (Product cost history)
select 
pch.ProductID,
p.Name AS ProductName,
SUM(pch.StandardCost) over (partition by pch.ProductID) as Total_std_cost
from Production.ProductCostHistory pch
join Production.Product p on pch.ProductID = p.ProductID
where p.DiscontinuedDate is null 
order by Total_std_cost desc;


--JOINS

--Q23. Find the personal details with address and address type(hint: Business Entiry Address , Address, Address type)
select
CONCAT_WS(' ',p.FirstName,p.LastName)as Emp_name,
a.AddressLine1  Address,
at.Name  Add_Type
from person.person p
join Person.BusinessEntityAddress ba on p.BusinessEntityID=ba.BusinessEntityID
join Person.Address a on a.AddressID=ba.AddressID
join Person.AddressType at on at.AddressTypeID=ba.AddressTypeID;


--Q24. Find the name of employees working in group of North America territory
select TerritoryID,
(select concat(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=sp.BusinessEntityID)Emp_Name,
(select name  from Sales.SalesTerritory st where  st.TerritoryID=sp.TerritoryID) TerritoryName,
(select [Group] from Sales.SalesTerritory st1 where st1.TerritoryID=sp.TerritoryID)Group_NAme,SalesLastYear,SalesQuota
from Sales.SalesPerson sp where sp.TerritoryID in (
select TerritoryID 
from Sales.SalesTerritory 
where [Group] IN ('North America'));


--GROUP BY

--Q25. Find the employee whose payment is revised for more than once
select e.BusinessEntityID, p.FirstName, p.LastName, COUNT(eph.RateChangeDate) as PayRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e on eph.BusinessEntityID = e.BusinessEntityID
join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
group by e.BusinessEntityID, p.FirstName, p.LastName
having COUNT(eph.RateChangeDate) > 1;


--Q26. display the personal details of  employee whose payment is revised for more than once.
select p.BusinessEntityID, p.FirstName, p.LastName, p.EmailPromotion, e.Gender, e.JobTitle, 
       eph.PayFrequency, COUNT(eph.RateChangeDate) as PayRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e on eph.BusinessEntityID = e.BusinessEntityID
join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
group by p.BusinessEntityID, p.FirstName, p.LastName, p.EmailPromotion, e.Gender, e.JobTitle, eph.PayFrequency
having COUNT(eph.RateChangeDate) > 1;


--Q27. Which shelf is having maximum quantity (product inventory)
select top 1  Shelf,
sum(Quantity) as Total_quan
from Production.ProductInventory
group by Shelf
order by Total_quan desc;


--Q28. Which shelf is using maximum bin(product inventory)
select top 1  Shelf,
max(Bin) max_bin
FROM Production.ProductInventory
group by Shelf
order by max_bin desc;


--Q29. Which location is having minimum bin (product inventory)
select top 1 LocationID,
min(Bin) min_bin
from Production.ProductInventory
group by LocationID
order by min_bin desc;


--Q30.Find out the product available in most of the locations (product inventory)
select top 1
p.Name AS ProductName,
count(distinct pi.LocationID) AS total_loc
from Production.ProductInventory pi
join Production.Product p ON p.ProductID = pi.ProductID
group by p.Name
order by total_loc desc;


--Q31.Which sales order is having most order quantity.
select top 1
sod.SalesOrderID,
sum(sod.OrderQty) as TotalOrderQuantity
from Sales.SalesOrderDetail sod
group by sod.SalesOrderID
order by TotalOrderQuantity desc;


--Q32.find the duration of payment revision on every interval (inline view) Output must be as given format 
--## revised time  count of revised salries ## duration  last duration of revision 
--e.g there are two revision date 01-01-2022 and revised in 01-01-2024   so duration here is 2years 
select p.FirstName, p.LastName, SalaryRevisions.RevisedTime, 
       DATEDIFF(YEAR, SalaryRevisions.First_rev_date, SalaryRevisions.Last_rev_date) as Duration
from (select eph.BusinessEntityID, 
count(eph.RateChangeDate)  RevisedTime, 
min(eph.RateChangeDate)  First_rev_date, 
max(eph.RateChangeDate)  Last_rev_date
from HumanResources.EmployeePayHistory eph
group by eph.BusinessEntityID
) as SalaryRevisions
join Person.Person p on p.BusinessEntityID = SalaryRevisions.BusinessEntityID
order by RevisedTime desc;


--Q33.check if any employee from jobcandidate table is having any payment revisions 
select * from HumanResources.JobCandidate j where j.BusinessEntityID
in(select BusinessEntityID from HumanResources.Employee e 
where e.BusinessEntityID in 
(select eph.BusinessEntityID from HumanResources.EmployeePayHistory eph 
group by eph.BusinessEntityID
having COUNT(eph.RateChangeDate)>0));


--Q34.check the department having more salary revision 
select d.Name AS DepartmentName, COUNT(eph.RateChangeDate) as TotalSalaryRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.EmployeeDepartmentHistory edh on eph.BusinessEntityID = edh.BusinessEntityID
join HumanResources.Department d on edh.DepartmentID = d.DepartmentID
group by d.Name
order by TotalSalaryRevisions desc;


--Q35.check the employee whose payment is not yet revised
select e.BusinessEntityID, concat_ws(' ',p.FirstName, p.LastName)as EmployeeName
from HumanResources.Employee e
join Person.Person p 
on e.BusinessEntityID = p.BusinessEntityID
where e.BusinessEntityID not in 
(select distinct BusinessEntityID from HumanResources.EmployeePayHistory);

--36.find the job title having more revised payments 

select distinct(e.JobTitle), count(eph.RateChangeDate) as total_sal
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e on eph.BusinessEntityID = e.BusinessEntityID
group by e.JobTitle
having count(eph.RateChangeDate)>1
order by total_sal desc;


--Q37.find the employee whose payment is revised in shortest duration (inline view)
select BusinessEntityID, FirstName, LastName, min(datediff(day,StartDate, EndDate)) 
as short_dur
from (select e.BusinessEntityID, p.FirstName, p.LastName, eph.StartDate, eph.EndDate
from HumanResources.EmployeeDepartmentHistory eph
join HumanResources.Employee e on eph.BusinessEntityID = e.BusinessEntityID
join Person.Person p on e.BusinessEntityID = p.BusinessEntityID) as Revisions
group by  BusinessEntityID, FirstName, LastName;


--Q38.find the colour wise count of the product (tbl: product)
select Color, count(ProductID) ProductCount
from Production.Product
where Color is not null
group by Color
order  by ProductCount desc;


--Q39.find out the product who are not in position to sell (hint: check the sell start and end date)
select  name from Production.Product
where SellStartDate is null or SellStartDate> GETDATE()
or SellEndDate is  not null or SellEndDate>GETDATE();


--Q40.find the class wise, style wise average standard cost
select class Class,style Style,avg(StandardCost) Avg_cost from Production.Product where
class is not null and Style is not null
group by Class,Style 
order by Avg_cost;


--Q41.check colour wise standard cost 
 select color Color,avg(StandardCost) as color_ac from Production.Product
 where color is not null 
 group by Color
 order by color_ac;


--Q42.find the product line wise standard cost
 select Productline Product_line,avg(StandardCost) as pro_std from Production.Product
 where ProductLine is not null
 group by ProductLine
 order by pro_std;


--Q43.Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince)
select sp.Name AS StateName, sp.StateProvinceCode, str.TaxRate
from Sales.SalesTaxRate str
join Person.StateProvince sp on str.StateProvinceID = sp.StateProvinceID
order by sp.Name ;


--Q44.Find the department wise count of employees
select d.Name as DepartmentName,count(e.BusinessEntityID) as Emp_count
from HumanResources.Employee e
join HumanResources.EmployeeDepartmentHistory edh on e.BusinessEntityID=edh.BusinessEntityID
join HumanResources.Department d on d.DepartmentID=edh.DepartmentID
group by d.Name;


--Q45.Find the department which is having more employees

select d.DepartmentID, d.Name as DepartmentName, COUNT(e.BusinessEntityID) as EmployeeCount
from HumanResources.Employee e
join HumanResources.Department d on e.BusinessEntityID = d.DepartmentID
group by d.DepartmentID, d.Name
order by EmployeeCount desc;


--Q46.Find the job title having more employees
select count(BusinessEntityID)as EmployeeCount,JobTitle from  HumanResources.Employee
group by JobTitle
order by EmployeeCount desc;


--Q47.Check if there is mass hiring of employees on single day
select  Hiredate, count(BusinessEntityID)as Employee_count  From HumanResources.Employee
group by HireDate
Having count(BusinessEntityID)>1
Order by Employee_count desc;


--Q48.Which product is purchased more? (purchase order details)
select  p.ProductID, p.Name as Product_Name, SUM(pd.OrderQty) as total_quan
from Purchasing.PurchaseOrderDetail pd
join Production.Product p on p.ProductID = pd.ProductID
group by p.ProductID, p.Name
order by total_quan desc;


--Q49.Find the territory wise customers count   (hint: customer)
select * from Sales.Customer
select TerritoryID, COUNT(CustomerID) as cust_count
from Sales.Customer
group by TerritoryID
order by cust_count desc;


--Q50.Which territory is having more customers (hint: customer)
select  TerritoryID, COUNT(CustomerID) as CustomerCount
from Sales.Customer
group by TerritoryID
order by CustomerCount desc;


--Q51.Which territory is having more stores (hint: customer)
select TerritoryID, COUNT(StoreID) as Store_count
from Sales.Customer
group by TerritoryID
order by Store_count desc;


--Q52.Is there any person having more than one credit card (hint: PersonCreditCard)
select CONCAT_WS(' ',p.FirstName,p.LastName)as PersonName,COUNT(pc.CreditCardID) as cc_count
from Person.Person p
join sales.PersonCreditCard pc on p.BusinessEntityID=pc.BusinessEntityID
group by p.FirstName,p.LastName
having count(pc.CreditCardID)>1;
 

--Q53.Find the product wise sale price (sales order details)
select p.ProductID, p.Name as prdt_name, 
       SUM(sod.OrderQty * sod.UnitPrice) as total
from Sales.SalesOrderDetail sod
join Production.Product p ON sod.ProductID = p.ProductID
group by p.ProductID, p.Name
order by total desc;


--Q54.Find the total values for line total product having maximum order
 select Top 1 PurchaseOrderID,
 sum(LineTotal)as Total,
 max(OrderQty)as Max_Order
 from Purchasing.PurchaseOrderDetail
 group by PurchaseOrderID
 having max(OrderQty)>1;



--Q55.Calculate the age of employees
 select concat_ws(' ',p.FirstName,p.LastName)as emp_name,
year(getdate())-year(e.BirthDate)as Age
from HumanResources.Employee e
join Person.Person p on e.BusinessEntityID=p.BusinessEntityID;


--Q56.Calculate the year of experience of the employee based on hire date
select concat_ws(' ',p.FirstName,p.LastName)as emp_name,
year(getdate())-year(e.HireDate)Experience
from HumanResources.Employee e
join Person.Person p on e.BusinessEntityID=p.BusinessEntityID;


--Q57.Find the age of employee at the time of joining
select BusinessEntityID,BirthDate, HireDate, 
DATEDIFF(YEAR, BirthDate, HireDate) as joining_age
from HumanResources.Employee;


--Q58.Find the average age of male and female
select Gender,Avg(datediff(YEAR,birthdate,GETDATE())) as avg_Age 
from HumanResources.Employee
group by Gender;


--Q59.Which product is the oldest product as on the date (refer  the product sell start date)
select top 1 name,
max(year(getdate())-year(SellStartDate)) as pdt_age
from Production.Product
group by Name;


--q60.Display the product name, standard cost, and time duration for the same cost. (Product cost history)
 select p.Name,
ph.StandardCost,
DATEDIFF(YEAR,ph.EndDate,ph.StartDate) as Time_dur,
avg(ph.Standardcost)over(partition by DATEDIFF(YEAR,ph.EndDate,ph.StartDate)) as avg_std_cost
from Production.ProductCostHistory ph
join Production.Product p on p.ProductID=ph.ProductID
where ph.EndDate is not null and
ph.StartDate is not null;


--Q61.Find the purchase id where shipment is done 1 month later of order date  
select PurchaseOrderID    
from Purchasing.PurchaseOrderHeader 
where datediff(MONTH,OrderDate,ShipDate)=1 ;


--Q62.Find the sum of total due where shipment is done 1 month later of order date ( purchase order header)
select sum(TotalDue)Total
from Purchasing.PurchaseOrderHeader 
where datediff(MONTH,OrderDate,ShipDate)=1;


--Q63.Find the average difference in due date and ship date based on  online order flag
select OnlineOrderFlag, 
 AVG(DATEDIFF(DAY, ShipDate, DueDate)) as avg_diff
from Sales.SalesOrderHeader
group by OnlineOrderFlag;


--Q64.Display business entity id, marital status, gender, vacationhr, average vacation based on marital status
select BusinessEntityId,MaritalStatus, Gender, VacationHours,
avg(vacationhours)over(partition by maritalstatus) as avg_status
from HumanResources.Employee;


--Q65.Display business entity id, marital status, gender, vacationhr, average vacation based on gender

select BusinessEntityId,MaritalStatus,Gender,VacationHours,
avg(vacationhours)over(partition by gender)  as avg_status
from HumanResources.Employee;
 
--Q66.Display business entity id, marital status, gender, vacationhr, average vacation based on organizational level
select BusinessEntityId,MaritalStatus,Gender,VacationHours,
avg(vacationhours)over(partition by Organizationlevel )  as vac_org
from HumanResources.Employee;


--Q67.Display entity id, hire date, department name and department wise count of employee and count based on organizational level in each dept
select e.BusinessEntityID, e.HireDate, d.Name as DepartmentName, 
COUNT(e.BusinessEntityID) over(partition by d.Name) as DepartmentEmployeeCount,
COUNT(e.BusinessEntityID) over(partition by d.Name, ed.OrganizationLevel) as OrgLevelEmployeeCount,
COALESCE(ed.OrganizationLevel, 0) as OrganizationLevel 
from HumanResources.Employee e
join HumanResources.EmployeeDepartmentHistory ed on e.BusinessEntityID = ed.BusinessEntityID
join HumanResources.Department d on ed.DepartmentID = d.DepartmentID;


--68.Display department name, average sick leave and sick leave per department
select distinct d.Name DepartmentName,
avg (SickLeaveHours) over(Partition by d.departmentID) as SL,
count(SickLeaveHours) over(Partition by d.departmentid) as ORG_SL
from HumanResources.Employee e join HumanResources.EmployeeDepartmentHistory eh
on e.BusinessEntityID=eh.BusinessEntityID
join HumanResources.Department d on  d.DepartmentID=eh.DepartmentID;


--Q69.Display the employee details first name, last name,  with total count of various shift done by the person and shifts count per department
select p.FirstName,
       p.LastName,
	   Count(s.ShiftID)TotalShift,
	   count(*)over(partition by d.departmentid) as dept_shift
from Person.Person p
join HumanResources.Employee e on p.BusinessEntityID=e.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory ed on ed.BusinessEntityID=e.BusinessEntityID
join HumanResources.Department d on d.DepartmentID=ed.DepartmentID
join HumanResources.Shift s on s.ShiftID=ed.ShiftID
group by e.BusinessEntityID,p.FirstName,p.LastName,d.DepartmentID,d.Name;


--Q70.Display country region code, group average sales quota based on territory id
select st.CountryRegionCode,st.[Group],
avg(sp.SalesQuota) as avg_sales
from Sales.SalesTerritory st
join Sales.SalesPerson sp on sp.TerritoryID=st.TerritoryID
where SalesQuota is not null
group by st.CountryRegionCode,st.[Group]
order by st.CountryRegionCode, avg_sales desc;


--Q71.Display special offer description, category and avg(discount pct) per the category
select distinct description,Category,
avg(DiscountPct)over(partition by  category)as avg_cat
from Sales.SpecialOffer so
join Sales.SpecialOfferProduct sp on sp.SpecialOfferID=so.SpecialOfferID;


--Q72.Display special offer description, category and avg(discount pct) per the month
select distinct Description, Category, 
 Month(StartDate) AS OfferMonth,
 AVG(DiscountPct) over(partition by Month(StartDate)) as avg_disc
from Sales.SpecialOffer so
join Sales.SpecialOfferProduct sp on sp.SpecialOfferID = so.SpecialOfferID;


--Q73.Display special offer description, category and avg(discount pct) per the year
select distinct Description, Category, 
YEAR(StartDate) AS OfferYear,
AVG(so.DiscountPct) over(partition by YEAR(so.StartDate),Year(so.Enddate)) as avg_disc
from Sales.SpecialOffer so
join Sales.SpecialOfferProduct sp on sp.SpecialOfferID = so.SpecialOfferID;


--Q74.Display special offer description, category and avg(discount pct) per the type
select distinct description, Category,
avg(DiscountPct) over(partition by  type) as avg_dist
from Sales.SpecialOffer so
join Sales.SpecialOfferProduct sp on sp.SpecialOfferID=so.SpecialOfferID;


--Q75.Using rank and dense rank find territory wise top sales person
select sp.BusinessEntityID, st.TerritoryID,  sp.SalesYTD,
RANK() over(partition by st.TerritoryID order by sp.SalesYTD desc) as Rank_yy,
DENSE_RANK() over(partition by st.TerritoryID order by sp.SalesYTD DESC) as Denserank_yy
from Sales.SalesPerson sp
join HumanResources.Employee e on sp.BusinessEntityID = e.BusinessEntityID
join Sales.SalesTerritory st on sp.TerritoryID = st.TerritoryID
where sp.SalesYTD IS NOT NULL
order by st.TerritoryID, Rank_yy;





