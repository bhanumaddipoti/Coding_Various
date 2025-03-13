SELECT upper(first_name)
FROM employee_demographics;

SELECT CONCAT(UPPER(LEFT(first_name, 2)), LOWER(SUBSTRING(first_name, 3)))
from employee_demographics;


select concat((first_name), ' ' , (last_name)) as 'Full_Name'
from employee_demographics;

# Case Statement
select concat((first_name), ' ' , (last_name)) as 'Full_Name', age,
case
	when age < 30 then 'young'
    when age > 50 then 'old'
    when age between 31 and 50 then 'adult'
end as 'Age_Bracket'
from employee_demographics;

select concat((first_name), ' ' , (last_name)) as 'Full_Name', salary,
case
	when salary < 50000 then salary * 1.05 
    when salary > 50000 then salary * 1.07 
end as 'New_Salary',
case
	when dept_id = 6 then salary * 0.1
    when dept_id != 6 then 0
    when dept_id = null then 0
end as 'bonus'
from employee_salary;

# Sub-Query
select  *
from employee_demographics
where employee_id in 
				(select employee_id
					from employee_salary
                    where dept_id = 1)

;

# Window Functions

# Avg Aggregate
SELECT gender, avg(salary) as avg_salary
From employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id = sal.employee_id
group by Gender;

# Window Over Fuction
SELECT dem.gender, avg(sal.salary) over () 
From employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id = sal.employee_id;

#Window Fuction Partition by
SELECT dem.gender, avg(sal.salary) over (partition by dem.gender) 
From employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id = sal.employee_id;

# Window Function Partition By with Full Name
SELECT (concat(dem.first_name, ' ', dem.last_name)) as 'Full_Name', dem.Gender, avg(sal.salary) over (partition by dem.gender) as Avg_Salary
From employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id = sal.employee_id;

# Window Function Sum of Salaries
SELECT (concat(dem.first_name, ' ', dem.last_name)) as 'Full_Name', dem.Gender, 
		Sum(sal.salary) over (partition by dem.gender) as Sum_Salary
From employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id = sal.employee_id;

# Window Function Rolling Total Sum of Salaries
SELECT (concat(dem.first_name, ' ', dem.last_name)) as 'Full_Name', dem.Gender, 
		Sum(sal.salary) over (partition by dem.gender ORDER BY dem.employee_id) as Rolling_Total
From employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id = sal.employee_id;

# Window Function Row Number
SELECT dem.employee_id, (concat(dem.first_name, ' ', dem.last_name)) as 'Full_Name', dem.Gender, sal.salary,
		row_number () Over (partition by dem.gender) as 'Row_Number'
From employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id = sal.employee_id;

# Window Function Row Number and Order By Salary
SELECT dem.employee_id, (concat(dem.first_name, ' ', dem.last_name)) as 'Full_Name', dem.Gender, sal.salary,
		row_number () Over (partition by dem.gender order by sal.salary desc) as 'Row_Number'
From employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id = sal.employee_id;

# Window Function Row Number and Ranked Salary
SELECT dem.employee_id, (concat(dem.first_name, ' ', dem.last_name)) as 'Full_Name', dem.Gender, sal.salary,
		row_number () Over (partition by dem.gender order by sal.salary desc) as 'Row_Number',
        rank() Over (partition by dem.gender order by sal.salary desc) as 'Rank_Number'
From employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id = sal.employee_id;

# Window Function Row Number, Ranked Salary and Dense Ranked Salary
SELECT dem.employee_id, (concat(dem.first_name, ' ', dem.last_name)) as 'Full_Name', dem.Gender, sal.salary,
		row_number () Over (partition by dem.gender order by sal.salary desc) as 'Row_Number',
        rank() Over (partition by dem.gender order by sal.salary desc) as 'Rank_Number',
        dense_rank() Over (partition by dem.gender order by sal.salary desc) as 'Dense_Rank_Number'
From employee_demographics as dem
JOIN employee_salary as sal
ON dem.employee_id = sal.employee_id;

# Advanced SQL
# CTE - Common Table Expression
# CTE First Example
With CTE_Example as
(Select dem.Gender, avg(sal.Salary) as Avg_Sal, max(sal.Salary) as Max_Sal, min(sal.Salary) as Min_Sal, count(sal.Salary) as Count_Sal
From employee_demographics as dem
Join employee_salary as sal
on dem.employee_id = sal.employee_id
group by Gender)
Select *
From CTE_Example
;

# CTE Second Example
With CTE_Example as
(
Select dem.Gender, avg(sal.Salary) as Avg_Sal, max(sal.Salary) as Max_Sal, min(sal.Salary) as Min_Sal, count(sal.Salary) as Count_Sal
From employee_demographics as dem
Join employee_salary as sal
on dem.employee_id = sal.employee_id
group by Gender
)
Select avg(Avg_Sal) as Total_Avg
From CTE_Example
;

# CTE Third Example
With CTE_Example as
(
Select employee_id, Gender, birth_date
From employee_demographics
where birth_date > '1985-01-01'
),
CTE_Example_2 as
(
Select employee_id, Salary
From employee_salary
where salary > 50000
)
Select *
From CTE_Example
Join CTE_Example_2
on CTE_Example.Employee_id = CTE_Example_2.employee_id
;

# Create Temp Table
Create Temporary Table Salary_Over_50k
Select *
From employee_salary
Where salary >= 50000;

select *
from Salary_Over_50k;

#Stored Procedures
#Stored Procedure Large Salaries
Use Parks_and_Recreation;
Create Procedure Large_Salaries ()
Select *
From employee_salary
Where salary >= 50000;

Call Large_Salaries ()

# Creating Complex Stored Procedures using a Custom Delimiter
Delimiter $$
Create Procedure Large_Salaries_2()
Begin
	Select *
	From employee_salary
	Where salary >= 50000;
	Select *
	From employee_salary
	Where salary >= 10000;
End $$
Delimiter ;

Call Large_Salaries_2 ()

# Creating Parameter Responding Stored Procedures using a Custom Delimiter
Delimiter $$
Create Procedure Large_Salaries_3(id_of_Employee_Param int)
Begin
	Select Salary
	From employee_salary
    where employee_id = id_of_Employee_Param;
	
End $$
Delimiter ;

Call Large_Salaries_3 (1)

# Creating Triggers
# Creating a Trigger for Concurrent Table Data Entry 
Delimiter $$
Create Trigger Employee_Insert
	After Insert ON employee_salary
    for EACH ROW
Begin
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    values (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
Delimiter ;

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (13, 'Jean-Ralphio', 'Sapperstein', 'Entertainment 720 CEO', 1000000, NULL);

Select *
FROM employee_salary;

Select *
FROM employee_demographics

# Creating Events
# Creating Event to Retire Old Employees
Delimiter $$
Create Event delete_retirees
ON SCHEDULE EVERY 30 SECOND
DO
BEGIN
	DELETE
	FROM employee_demographics
    where age >= 60;
END $$
Delimiter ;

