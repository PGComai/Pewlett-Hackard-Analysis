-- creating tables for PH-EmployeeDB
CREATE TABLE departments (

	dept_no VARCHAR(4) NOT NULL,

	dept_name VARCHAR(40) NOT NULL,

	PRIMARY KEY (dept_no),

	UNIQUE (dept_name)

);

CREATE TABLE employees (
	
	emp_no INT NOT NULL,
	
	birth_date DATE NOT NULL,
	
	first_name VARCHAR NOT NULL,
	
	last_name VARCHAR NOT NULL,
	
	gender VARCHAR NOT NULL,
	
	hire_date DATE NOT NULL,
	
	PRIMARY KEY (emp_no)
	
);

CREATE TABLE dept_manager (

	dept_no VARCHAR(4) NOT NULL,
	
	emp_no INT NOT NULL,
	
	from_date DATE NOT NULL,
	
	to_date DATE NOT NULL,
	
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	
	PRIMARY KEY (emp_no, dept_no)

);

CREATE TABLE salaries (

	emp_no INT NOT NULL,
	
	salary INT NOT NULL,
	
	from_date DATE NOT NULL,
	
	to_date DATE NOT NULL,
	
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	
	PRIMARY KEY (emp_no)

);

CREATE TABLE dept_employee (

	emp_no INT NOT NULL,
	
	dept_no VARCHAR NOT NULL,
	
	from_date DATE NOT NULL,
	
	to_date DATE NOT NULL,
	
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	
	PRIMARY KEY (emp_no, dept_no)

);

CREATE TABLE titles (

	emp_no INT NOT NULL,
	
	title VARCHAR NOT NULL,
	
	from_date DATE NOT NULL,
	
	to_date DATE NOT NULL,
	
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no)

);

SELECT * FROM employees;

-- find employees born between two dates

-- retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

-- number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- retirement eligibility INTO a new table
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

SELECT * FROM retirement_info;

-- remake retirement_info to prepare for join

DROP TABLE retirement_info;

SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- joining depts and dept managers
SELECT d.dept_name,
	de.emp_no,
	de.from_date,
	de.to_date
FROM departments AS d
INNER JOIN dept_manager AS de
ON d.dept_no = de.dept_no;

--joining retirement_info and dept_emp

SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
FROM retirement_info AS ri
LEFT JOIN dept_employee AS de
ON ri.emp_no = de.emp_no;

SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
INTO current_emp
FROM retirement_info AS ri
LEFT JOIN dept_employee AS de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

SELECT * FROM current_emp;

-- employee count by dept no

SELECT COUNT(ce.emp_no), de.dept_no
INTO retiring_by_dept
FROM current_emp AS ce
LEFT JOIN dept_employee AS de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

SELECT * FROM retiring_by_dept;

-- adding salaries

SELECT * FROM salaries
ORDER BY to_date DESC;

SELECT emp_no,
	first_name,
	last_name,
	gender
INTO emp_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

DROP TABLE emp_info;

SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees AS e
INNER JOIN salaries AS s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_employee AS de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	AND (de.to_date = '9999-01-01');

-- list of managers per dept
SELECT dm.dept_no,
	d.dept_name,
	dm.emp_no,
	ce.last_name,
	ce.first_name,
	dm.from_date,
	dm.to_date
INTO manager_info
FROM dept_manager AS dm
	INNER JOIN departments AS d
		ON (dm.dept_no = d.dept_no)
	INNER JOIN current_emp AS ce
		ON (dm.emp_no = ce.emp_no);

SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name
INTO dept_info
FROM current_emp AS ce
	INNER JOIN dept_employee AS de
		ON (ce.emp_no = de.emp_no)
	INNER JOIN departments AS d
		ON (de.dept_no = d.dept_no);

-- list of retiring employees from sales dept

SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	d.dept_name
INTO sales_retiring
FROM retirement_info AS ri
	INNER JOIN dept_employee AS de
		ON (ri.emp_no = de.emp_no)
	INNER JOIN departments AS d
		ON (de.dept_no = d.dept_no)
WHERE d.dept_name = 'Sales'

-- list of retiring employees from sales dept

SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	d.dept_name
INTO sales_dev_retiring
FROM retirement_info AS ri
	INNER JOIN dept_employee AS de
		ON (ri.emp_no = de.emp_no)
	INNER JOIN departments AS d
		ON (de.dept_no = d.dept_no)
WHERE d.dept_name IN ('Sales','Development')




