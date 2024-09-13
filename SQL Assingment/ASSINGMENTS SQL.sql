-- Q1: SELECT clause with WHERE AND DISTINCT Wild Card (LIKE)
SELECT employeeNumber, firstName, lastName
FROM employees
WHERE jobTitle = 'Sales Rep'
  AND reportsTo = 1102;

SELECT DISTINCT productLine
FROM products
WHERE productLine LIKE '%cars';


-- Q2: CASE Statement for Segmentation
SELECT customerNumber,customerName,
CASE
WHEN country IN ('USA','Canada') THEN 'North America'
WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
        ELSE 'Other'
    END AS CustomerSegment
FROM customers;

-- Q3: Group By with Aggregation Functions and HAVING Clause
-- Task 1: Identify the top 10 products with the highest total order quantity
SELECT productCode, SUM(quantityOrdered) AS totalQuantity
FROM orderdetails
GROUP BY productCode
ORDER BY totalQuantity DESC
LIMIT 10;

-- Task 2: Analyze payment frequency by month
SELECT MONTHNAME(paymentDate) AS month, COUNT(*) AS paymentCount
FROM payments
GROUP BY month
HAVING paymentCount > 20
ORDER BY paymentCount DESC;


-- Q4: Constraints - Primary Key, Foreign Key, Unique, Check, Not Null, Default
CREATE DATABASE Customers_Orders;
USE Customers_Orders;

CREATE TABLE Customers1 (             -- due to customers already exits i created customers1
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);

CREATE TABLE Orders1 (           -- due to Orders already exits i created Orders1
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers1(customer_id),
    CHECK (total_amount > 0)
);

-- Q5: Joins
SELECT c.country, COUNT(o.orderNumber) AS orderCount
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY orderCount DESC
LIMIT 5;

-- Q6: Self Join
CREATE TABLE project (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female') NOT NULL,
    ManagerID INT
);

INSERT INTO Project (FullName, Gender, ManagerID)
VALUES 
('Pranaya', 'Male', 3),
('Priyanka', 'Female', 1),
('Preety', 'Female', NULL),
('Anurag', 'Male', 1),
('Sambit', 'Male', 1),
('Rajesh', 'Male', 3),
('Hina', 'Female', 3);

SELECT e.FullName AS EmployeeName, m.FullName AS ManagerName
FROM project e
LEFT JOIN project m ON e.ManagerID = m.EmployeeID;

select * from project;

-- Q7: DDL Commands: Create, Alter, Rename
CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50)
);

ALTER TABLE facility
MODIFY COLUMN Facility_ID INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE facility
ADD COLUMN City VARCHAR(50) NOT NULL AFTER Name;

-- Q8: Views in SQL
CREATE VIEW product_category_sales AS
SELECT p.productLine,
       SUM(od.quantityOrdered * od.priceEach) AS total_sales,
       COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM productlines p
JOIN products pr ON p.productLine = pr.productLine
JOIN orderdetails od ON pr.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY p.productLine;

-- Q9: Stored Procedures in SQL with Parameters
DELIMITER //

CREATE PROCEDURE Get_country_payments(IN yearInput INT, IN countryInput VARCHAR(50))
BEGIN
    SELECT YEAR(paymentDate) AS year, country, 
           SUM(amount) AS total_amount
    FROM payments p
    JOIN customers c ON p.customerNumber = c.customerNumber
    WHERE YEAR(paymentDate) = yearInput AND country = countryInput
    GROUP BY YEAR(paymentDate), country;
END //

DELIMITER ;

-- Q10: Window Functions - RANK, DENSE_RANK, LEAD, and LAG
-- Task 1: Rank customers based on their order frequency
SELECT customerNumber, 
RANK() OVER (ORDER BY COUNT(orderNumber) DESC) AS orderNumber_rank
FROM orders
GROUP BY customerNumber;

-- Task 2: Calculate year-wise and month-wise count of orders and YoY percentage change
SELECT YEAR(orderDate) AS year, 
       MONTHNAME(orderDate) AS month, 
       COUNT(orderNumber) AS order_count,
       LAG(COUNT(orderNumber)) OVER (ORDER BY YEAR(orderDate)) AS prev_order_count,
       ROUND(((COUNT(orderNumber) - LAG(COUNT(orderNumber)) OVER (ORDER BY YEAR(orderDate)))/LAG(COUNT(orderNumber)) OVER (ORDER BY YEAR(orderDate))) * 100, 0) AS YoY_change
FROM orders
GROUP BY YEAR(orderDate), MONTHNAME(orderDate)
ORDER BY year, month;


-- Q11: Subqueries and Their Applications
SELECT productLine, COUNT(*) AS count
FROM products
WHERE buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY productLine;

-- Q12: Error Handling in SQL
CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50),
    EmailAddress VARCHAR(100)
);

DELIMITER //

CREATE PROCEDURE InsertEmpEH(IN empID INT, IN empName VARCHAR(50), IN email VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle the error
        ROLLBACK;
        SELECT 'Error occurred';
    END;

    START TRANSACTION;

    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (empID, empName, email);

    COMMIT;
END //

DELIMITER ;

-- Q13: Triggers
CREATE TABLE Emp_BIT (
    Name VARCHAR(100),
    Occupation VARCHAR(100),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT (Name, Occupation, Working_date, Working_hours) VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

DELIMITER //
CREATE TRIGGER before_insert_emp_bit
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END //
DELIMITER ;

INSERT INTO Emp_BIT (Name, Occupation, Working_date, Working_hours) VALUES
('John', 'Musician', '2023-09-08', -8);

SELECT * FROM Emp_BIT;




