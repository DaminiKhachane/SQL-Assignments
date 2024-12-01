USE CLASSICMODELS;

/*Q1.a.	Fetch the employee number, first name and last name of those employees who are working as Sales Rep 
reporting to employee with employeenumber 1102 (Refer employee table)*/
SELECT * FROM EMPLOYEES;

SELECT EMPLOYEENUMBER,FIRSTNAME,LASTNAME
FROM EMPLOYEES
WHERE JOBTITLE='SALES REP' AND REPORTSTO=1102;

/*b.Show the unique productline values containing the word cars at the end from the products table*/
SELECT * FROM PRODUCTS;

SELECT  DISTINCT PRODUCTLINE
FROM PRODUCTS
WHERE PRODUCTLINE LIKE '%CARS';

/*Q2. CASE STATEMENTS for Segmentation
a. Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)
                        "North America" for customers from USA or Canada
                        "Europe" for customers from UK, France, or Germany
                        "Other" for all remaining countries
     Select the customerNumber, customerName, and the assigned region as "CustomerSegment"*/
     
     SELECT * FROM CUSTOMERS;
     
     SELECT CUSTOMERNUMBER,CUSTOMERNAME,
     CASE
         WHEN COUNTRY IN('USA','CANADA') THEN 'NORTH AMERICA'
         WHEN COUNTRY IN('UK','FRANCE','GERMANY') THEN 'EUROPE'
	     ELSE 'OTHER'
         END AS CUSTOMERSEGMENT
      FROM CUSTOMERS;
      
/*Q3. Group By with Aggregation functions and Having clause, Date and Time functions
a.Using the OrderDetails table, identify the top 10 products (by productCode) 
with the highest total order quantity across all orders*/
SELECT * FROM ORDERDETAILS;

SELECT PRODUCTCODE,
SUM(QUANTITYORDERED) AS TOTAL_ORDERED
FROM ORDERDETAILS
GROUP BY PRODUCTCODE
ORDER BY TOTAL_ORDERED
DESC
LIMIT 10;

/*b.Company wants to analyse payment frequency by month. Extract the month name from the payment 
date to count the total number of payments for each month and include only those months with a 
payment count exceeding 20. Sort the results by total number of payments in descending order.(Refer Payments table)*/
SELECT * FROM PAYMENTS;

SELECT MONTHNAME(PAYMENTDATE) AS PAYMENT_MONTH,
COUNT(*) AS NUM_PAYMENTS FROM PAYMENTS
GROUP BY MONTHNAME(PAYMENTDATE)
HAVING COUNT(*) > 20
ORDER BY NUM_PAYMENTS DESC;

/*Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
Create a new database named and Customers_Orders and add the following tables as per the description
a.Create a table named Customers to store customer information. Include the following columns*/
CREATE DATABASE CUSTOMERS_ORDERS;

USE CUSTOMERS_ORDERS;

CREATE TABLE CUSTOMERS 
(
CUSTOMER_ID INT NOT NULL 
AUTO_INCREMENT,
FIRST_NAME VARCHAR(50) NOT NULL,
LAST_NAME VARCHAR(50) NOT NULL,
EMAIL VARCHAR(255) UNIQUE,
PHONE_NUMBER VARCHAR(20),
PRIMARY KEY (CUSTOMER_ID)
);

SELECT * FROM CUSTOMERS;

/*b.Create a table named Orders to store information about customer orders. Include the following columns*/
CREATE TABLE ORDERS
(
ORDER_ID INT AUTO_INCREMENT PRIMARY KEY,
CUSTOMER_ID INT,
ORDER_DATE DATE,
TOTAL_AMOUNT DECIMAL(10,2),
FOREIGN KEY (CUSTOMER_ID)
REFERENCES
CUSTOMERS(CUSTOMER_ID),
CHECK (TOTAL_AMOUNT > 0)
);

SELECT * FROM ORDERS;

/*Q5. JOINS
a.List the top 5 countries (by order count) that Classic 
Models ships to. (Use the Customers and Orders tables)*/
SELECT * FROM CUSTOMERS;
SELECT * FROM ORDERS;

SELECT C.COUNTRY,
COUNT(O.ORDERNUMBER) AS ORDER_COUNT
FROM CUSTOMERS C JOIN ORDERS O ON
C.CUSTOMERNUMBER=O.CUSTOMERNUMBER
GROUP BY C.COUNTRY
ORDER BY ORDER_COUNT DESC
LIMIT 5;

/*Q6. SELF JOIN
a.Create a table project with below fields.
●	EmployeeID : integer set as the PRIMARY KEY and AUTO_INCREMENT.
●	FullName: varchar(50) with no null values
●	Gender : Values should be only ‘Male’  or ‘Female’
●	ManagerID: integer 
Add below data into it.
Find out the names of employees and their related managers.*/
CREATE TABLE PROJECT
(
EMPLOYEEID INT AUTO_INCREMENT PRIMARY KEY,
FULLNAME VARCHAR(50) NOT NULL,
GENDER ENUM('MALE','FEMALE') NOT NULL,
MANAGERID INT
);

INSERT INTO PROJECT VALUES(1,'PRANAYA','MALE',3),
						  (2,'PRIYANKA','FEMALE',1),
                          (3,'PREETY','FEMALE',NULL),
                          (4,'ANURAG','MALE',1),
                          (5,'SAMBIT','MALE',1),
                          (6,'RAJESH','MALE',3),
                          (7,'HINA','FEMALE',3);
                          
 SELECT * FROM PROJECT;  
 
 SELECT M.FULLNAME AS MANAGER_NAME,E.FULLNAME AS EMP_NAME
 FROM PROJECT M JOIN PROJECT E
 ON M.EMPLOYEEID = E.MANAGERID
 ORDER BY 
 M.FULLNAME, E.FULLNAME;
 
 /*Q7. DDL Commands: Create, Alter, Rename
a. Create table facility. Add the below fields into it.
●	Facility_ID
●	Name
●	State
●	Country
i) Alter the table by adding the primary key and auto increment to Facility_ID column.
ii) Add a new column city after name with data type as varchar which should not accept any null values.*/

CREATE TABLE FACILITY
(
FACILITY_ID INT,
NAME VARCHAR(100),
STATE VARCHAR(100),
COUNTRY VARCHAR(100)
);
ALTER TABLE FACILITY
CHANGE FACILITY_ID FACILITY_ID INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE FACILITY
ADD COLUMN CITY VARCHAR(100) NOT NULL AFTER NAME;

SELECT * FROM FACILITY;

/*Q8. Views in SQL
a. Create a view named product_category_sales that provides insights into sales performance by product category. 
This view should include the following information:*/

CREATE VIEW product_category_sales AS
SELECT 
    pl.productLine AS productLine, 
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM 
    Products p
JOIN 
    OrderDetails od ON p.productCode = od.productCode
JOIN 
    Orders o ON od.orderNumber = o.orderNumber
JOIN 
    ProductLines pl ON p.productLine = pl.productLine
GROUP BY 
    pl.productLine;

SELECT * FROM product_category_sales;


/*Q9. Stored Procedures in SQL with parameters
a. Create a stored procedure Get_country_payments which takes in year and country as inputs 
and gives year wise, country wise total amount as an output. Format the total amount to nearest thousand unit (K)
Tables: Customers, Payments*/
SELECT * FROM PAYMENTS;
SELECT * FROM CUSTOMERS;

CALL GET_COUNTRY_PAYMENTS(2003, 'FRANCE');

/*
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_COUNTRY_PAYMENTS`(IN INPUT_YEAR INT,
										                           IN INPUT_COUNTRY VARCHAR(100))
BEGIN
  SELECT 'Procedure is executing' AS status;
  SELECT input_year AS input_year, input_country AS input_country;
  SELECT YEAR(p.paymentdate) AS `Year`,
			c.country AS `country`,
           CONCAT(FORMAT(SUM(p.amount) / 1000, 0), 'K') AS `TotalAmount`
    FROM Payments p
    JOIN Customers c ON p.customernumber = c.customernumber
    WHERE YEAR(p.paymentdate) = input_year
      AND c.country = input_country
    GROUP BY YEAR(p.paymentdate), c.country;
END
*/

/*Q10. Window functions - Rank, dense_rank, lead and lag
a) Using customers and orders tables, rank the customers based on their order frequency*/
USE CLASSICMODELS;
SELECT * FROM CUSTOMERS;
SELECT * FROM ORDERS;

SELECT C.CUSTOMERNAME,
       COUNT(O.ORDERNUMBER) AS ORDER_COUNT,
       RANK() OVER (ORDER BY COUNT(O.ORDERNUMBER)DESC)AS ORDER_FREQUENCY_RNK
       FROM CUSTOMERS C
       JOIN ORDERS O ON C.CUSTOMERNUMBER = O.CUSTOMERNUMBER 
       GROUP BY C.CUSTOMERNAME
       ORDER BY ORDER_FREQUENCY_RNK;
      
/* b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. 
 Format the YoY values in no decimals and show in % sign.
 Table: Orders*/
 SELECT * FROM ORDERS;
 
 SELECT 
    Year,
    Month,
    Order_Count,
    CONCAT(
        FORMAT(
            (Order_Count - LAG(Order_Count) OVER (PARTITION BY Year ORDER BY Month_Number)) / 
            NULLIF(LAG(Order_Count) OVER (PARTITION BY Year ORDER BY Month_Number), 0) * 100,
            0
        ),
        '%'
    ) AS YoY_Percentage_Change
FROM (
    SELECT 
        YEAR(orderDate) AS Year,
        MONTHNAME(orderDate) AS Month,
        MONTH(orderDate) AS Month_Number,
        COUNT(*) AS Order_Count
    FROM 
        orders
    GROUP BY 
        Year, Month, Month_Number
) AS OrderCounts
ORDER BY 
    Year, Month_Number;

 
 
 
/*Q11.Subqueries and their applications
a. Find out how many product lines are there for which the buy price value is greater 
than the average of buy price value. Show the output as product line and its count.*/

SELECT PRODUCTLINE, COUNT(*) AS PRODUCT_COUNT
FROM PRODUCTS
WHERE BUYPRICE > (SELECT AVG(BUYPRICE)
FROM PRODUCTS )
GROUP BY PRODUCTLINE 
ORDER BY PRODUCT_COUNT DESC;

 /*Q12. ERROR HANDLING in SQL
	Create the table Emp_EH. Below are its fields.
●	EmpID (Primary Key)
●	EmpName
●	EmailAddress
Create a procedure to accept the values for the columns in Emp_EH. Handle the error using exception handling concept.
 Show the message as “Error occurred” in case of anything wrong.*/
 
 CREATE TABLE EMP_EH
 (
 EMPID INT PRIMARY KEY,
 EMPNAME VARCHAR(100),
 EMAILADDRESS VARCHAR(100)
 );
CALL ADDEMPLOYEE_EH(1,'JAY SINGH','jaysingh@example.com');
CALL ADDEMPLOYEE_EH(1,'JAY SINGH','jaysingh@example.com');


/*CREATE DEFINER=`root`@`localhost` PROCEDURE `ADDEMPLOYEE_EH`(IN P_EMPID INT,
								   IN P_EMPNAME VARCHAR(100),
                                   IN P_EMAILADDRESS VARCHAR(100))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
SELECT 'ERROR OCCURED' AS ERRORMSG;
END;
START TRANSACTION;
INSERT INTO EMP_EH(EMPID,EMPNAME,EMAILADDRESS)
VALUES(P_EMPID ,P_EMPNAME,P_EMAILADDRESS);
COMMIT;
END
*/ 
 
/*Q13. TRIGGERS*/

CREATE TABLE EMP_BIT
(
NAME VARCHAR(50),
OCCUPATION VARCHAR(50),
WORKING_DATE DATE,
WORKING_HOURS INT
);

 INSERT INTO EMP_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', -11);  

SELECT * FROM EMP_BIT;

/*
CREATE DEFINER = CURRENT_USER TRIGGER `classicmodels`.`emp_bit_BEFORE_INSERT` BEFORE INSERT ON `emp_bit` FOR EACH ROW
BEGIN
IF NEW.WORKING_HOURS < 0 THEN
SET NEW.WORKING_HOURS =
-NEW.WORKING_HOURS;
END IF;
END
*/
 
