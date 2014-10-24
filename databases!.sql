-- :set scrollbind

-- Databases!

-- Expressions

SELECT 1;






SELECT 1 AS number;
SELECT 1 + 2 AS sum;

SELECT 1, 2, 3;

-- Values

VALUES (1);
VALUES (1, 'one');
VALUES (1, 'one'), (2, 'two');

-- Fail :(
-- names vs strings

VALUES (1, "one");

-- SELECT + VALUES


SELECT * FROM (VALUES (1, 'one'), (2, 'two')) AS t;




SELECT * FROM (VALUES (1, 'one'), (2, 'two')) AS t (num, word);

SELECT t.num FROM (VALUES (1, 'one'), (2, 'two')) AS t (num, word);


SELECT t.num, t.num * -1 AS neg
FROM (VALUES (1, 'one'), (2, 'two')) AS t (num, word);

SELECT num, num * -1 AS neg
FROM (VALUES (1, 'one'), (2, 'two')) AS t (num, word)
WHERE num > 1;

-- Cross product




SELECT * FROM (VALUES (1), (2)) AS v;

WITH v AS (
      VALUES (1), (2)
    )
SELECT * FROM v;


WITH v1 AS (
        VALUES (1), (2)
    ), v2 AS (
        VALUES (1), (2)
    )
SELECT * FROM v1, v2;


WITH v1 AS (
        VALUES (1), (2)
    ), v2 AS (
        VALUES (1), (2)
    )
SELECT * FROM v1 CROSS JOIN v2;


WITH v AS (
        VALUES (1), (2)
    )
SELECT * FROM v AS v1, v AS v2;


-- More joins!

CREATE TABLE departments
(
 id INT,
 name VARCHAR(20)
);

CREATE TABLE employees
(
 last_name VARCHAR(20),
 department_id INT,
 salary INT
);

INSERT INTO departments VALUES(31, 'Sales');
INSERT INTO departments VALUES(33, 'Engineering');
INSERT INTO departments VALUES(34, 'Clerical');
INSERT INTO departments VALUES(35, 'Marketing');

INSERT INTO employees VALUES('Rafferty', 31, 95000);
INSERT INTO employees VALUES('Jones', 33, 85000);
INSERT INTO employees VALUES('Heisenberg', 33, 120000);
INSERT INTO employees VALUES('Robinson', 34, 65000);
INSERT INTO employees VALUES('Smith', 34, 100000);
INSERT INTO employees VALUES('Williams', NULL, 75000);


-- INNER JOIN

-- Next 4 are equivalent

SELECT * FROM departments
INNER JOIN employees ON departments.id = employees.department_id;

-- SELECT in a different form

SELECT departments.*, employees.* FROM departments
INNER JOIN employees ON departments.id = employees.department_id;

-- CROSS JOIN with WHERE

SELECT * FROM departments
CROSS JOIN employees
WHERE departments.id = employees.department_id;

-- Implicit CROSS JOIN with WHERE

SELECT * FROM departments, employees
WHERE departments.id = employees.department_id;


-- SELECT some columns, condition on others

SELECT employees.* FROM employees
INNER JOIN departments ON employees.department_id = departments.id
WHERE departments.name = 'Engineering';

-- ORDER BY

SELECT employees.* FROM employees
INNER JOIN departments ON employees.department_id = departments.id
WHERE departments.name = 'Engineering'
ORDER BY employees.salary DESC;

-- LIMIT

SELECT employees.* FROM employees
INNER JOIN departments ON employees.department_id = departments.id
WHERE departments.name = 'Engineering'
ORDER BY employees.salary DESC
LIMIT 1;


-- LEFT JOIN

SELECT * FROM employees
LEFT JOIN departments ON employees.department_id = departments.id;

SELECT * FROM departments
LEFT JOIN employees ON employees.department_id = departments.id;

-- RIGHT JOIN

SELECT * FROM employees
RIGHT JOIN departments ON employees.department_id = departments.id;


-- Aggregate functions

SELECT COUNT(*) FROM employees;


-- Grouping

SELECT employees.department_id, COUNT(*) FROM employees GROUP BY department_id;

-- Aggregate functions return aggregate columns

-- It would be nice to have the name. JOINS to the rescue!

SELECT departments.name, COUNT(*) FROM employees
LEFT JOIN departments ON employees.department_id = departments.id
GROUP BY employees.department_id;

-- :(. departments.name must appear in GROUP BY

SELECT departments.name, COUNT(*) FROM employees
LEFT JOIN departments ON employees.department_id = departments.id
GROUP BY departments.name;


-- Could we ignore Williams and get a 0 for the count of Marketing?
-- Changes in last query: LEFT JOIN -> INNER JOIN
-- Subqueries! Selecting one column in a subquery is special.

WITH at_least_one AS (
        SELECT departments.name, COUNT(*) FROM employees
        INNER JOIN departments ON employees.department_id = departments.id
        GROUP BY departments.name
    )
SELECT * FROM at_least_one

UNION

SELECT departments.name, 0 AS count FROM departments
WHERE departments.name NOT IN (SELECT name FROM at_least_one);

-- Is there a better way to do this? Maybe. Not sure.
-- Other set operations too (INTERSECT, EXCEPT)

-- Conditioning on the aggregate rows: HAVING.
-- WHERE happens before the GROUP BY. HAVING happens after.

SELECT departments.name, COUNT(*) AS employee_count FROM employees
LEFT JOIN departments ON employees.department_id = departments.id
GROUP BY departments.name
HAVING employee_count > 1;

-- Can't refer to the captured COUNT(*) :(

SELECT departments.name, COUNT(*) AS employee_count FROM employees
LEFT JOIN departments ON employees.department_id = departments.id
GROUP BY departments.name
HAVING COUNT(*) > 1;

-- More aggregation. How about aggregate salary by department?

SELECT departments.name, avg(employees.salary)
FROM employees
INNER JOIN departments ON employees.department_id = departments.id
GROUP BY departments.name;


-- But what if we don't want aggregate rows? Can we get the average salary along with each individual row? Yes we can!

-- Window functions and PARTITION BY

SELECT
    employees.last_name,
    departments.name,
    employees.salary,
    avg(salary) OVER (PARTITION BY departments.id)
FROM employees
INNER JOIN departments ON employees.department_id = departments.id;

-- Do we beat the average?

SELECT
    employees.last_name,
    departments.name,
    employees.salary,
    avg(salary) OVER (PARTITION BY departments.id) AS average_salary,
    employees.salary > average_salary AS beats_the_average
FROM employees
INNER JOIN departments ON employees.department_id = departments.id;

-- Why can't we use average_salary? Not quite sure. SQL is finicky. Some things have order, other things don't. If you want to get good, you have to understand what is going on inside.

SELECT
    employees.last_name,
    departments.name,
    employees.salary,
    avg(salary) OVER (PARTITION BY departments.id),
    employees.salary > avg(salary) OVER (PARTITION BY departments.id) AS beats_the_average
FROM employees
INNER JOIN departments ON employees.department_id = departments.id;

-- In these cases avg() became a window function automatically. There are other things that are just window functions.

-- *************
-- Look at subforum_group_index_query.rb.
-- Look at threads_with_visited_status view.
-- *************


-- EXPLAIN

EXPLAIN SELECT * FROM employees;

EXPLAIN SELECT * FROM employees
LEFT JOIN departments ON employees.department_id = departments.id;


-- A more complicated table

CREATE TABLE random_numbers
(
    id SERIAL PRIMARY KEY,
    number INT
);

SELECT generate_series(1, 10);

SELECT round(random() * 1000);

SELECT round(random() * 1000)
FROM (
    SELECT generate_series(1,100000)
) AS range;

-- We can average them

SELECT avg(num)
FROM (
    SELECT round(random() * 1000) AS num
    FROM (
        SELECT generate_series(1,100000)
    ) AS range)
AS numbers;


INSERT into random_numbers(number) (
    SELECT round(random() * 1000)
    FROM (
        SELECT generate_series(1,100000)
    ) AS range
);

EXPLAIN SELECT * FROM random_numbers;

EXPLAIN SELECT * FROM random_numbers WHERE number = 900;

EXPLAIN ANALYZE SELECT * FROM random_numbers WHERE number = 900;

CREATE INDEX index_random_numbers_on_number ON random_numbers (number);

EXPLAIN SELECT * FROM random_numbers WHERE number = 900;

EXPLAIN ANALYZE SELECT * FROM random_numbers WHERE number = 900;
