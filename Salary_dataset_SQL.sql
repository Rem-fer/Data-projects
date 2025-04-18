--Create and import data

CREATE TABLE salary_job_country(
	id SERIAL PRIMARY KEY,
	age NUMERIC,
	gender VARCHAR(50),
	ed_level VARCHAR(100),
	job_title VARCHAR (100),
	exp_in_years NUMERIC,
	salary NUMERIC,
	country VARCHAR(100),
	race VARCHAR(100)
)

SELECT * FROM salary_job_country;

	
CREATE TABLE salary_job_country_copy AS TABLE  salary_job_country;

--1 --CLEANING -- 

--1.1 Remove duplicates

WITH raw_numCTE AS
(
SELECT *,
ROW_NUMBER()OVER(PARTITION BY age, ed_level, job_title, exp_in_years, salary, country, race) AS row_num
FROM salary_job_country
)

SELECT * FROM raw_numCTE
WHERE row_num > 1;

--No duplicates really

-- 1.2 DELETING null vales( I am just deleting them)

SELECT * FROM salary_job_country;

DELETE FROM salary_job_country
WHERE gender IS NULL;

SELECT * FROM salary_job_country
WHERE gender IS NULL;

--1.3 Formating data
--1.3.1 Ed level
--Bachelor degree example( did the same with the rest)

SELECT DISTINCT ed_level
FROM salary_job_country

SELECT * 
FROM salary_job_country 
WHERE ed_level LIKE 'Bachelor''s'
	
UPDATE salary_job_country SET ed_level = 'Bachelor''s Degree'
WHERE ed_level LIKE 'Bachelor''s';


--1.3.2 Check race categories

SELECT DISTINCT race
FROM salary_job_country;

SELECT race, count(*)
FROM salary_job_country
GROUP BY  race;
 
-- Merging welsh, australian, white into White

SELECT * 
FROM salary_job_country
WHERE race LIKE 'Welsh';

UPDATE salary_job_country SET race ='White'
WHERE race LIKE 'Australian';

UPDATE salary_job_country SET race ='White'
WHERE race LIKE 'Welsh';

--Merging black and African american into Black

SELECT * 
FROM salary_job_country
WHERE race LIKE 'Afric%';

UPDATE salary_job_country SET race ='Black'
WHERE race LIKE 'Afric%';

SELECT DISTINCT race
FROM salary_job_country;

SELECT * FROM salary_job_country;

-- Merging Chinese, Korean into Asian

SELECT * 
FROM salary_job_country
WHERE race LIKE 'Ko%';

UPDATE salary_job_country SET race = 'Asian'
WHERE race LIKE 'Ch%';

UPDATE salary_job_country SET race = 'Asian'
WHERE race LIKE 'Ko%';

SELECT DISTINCT race
FROM salary_job_country;

-- 2 --EXPLORATORY ANALYSIS--

-- Ranges:

-- Years of experience

SELECT min(exp_in_years), MAX(exp_in_years)
FROM salary_job_country;

SELECT id, exp_in_years, salary, av_sal
FROM
(
SELECT * , 
AVG(salary) OVER(PARTITION BY exp_in_years ORDER BY AVG(salary) ) as av_sal
FROM salary_job_country
) 
ORDER by av_sal DESC


-- Exploring age column and creating age range categories

SELECT COUNT(*)
FROM salary_job_country
WHERE age <= 24;

SELECT min(age), Max(age)
FROM salary_job_country;

--Age range: 1(18-24), 2(25-34), 3(35-44), 4(45-54),5(55 and more)

SELECT *,
CASE 
WHEN age <= 24 THEN 1
WHEN age > 24 AND age <= 34 THEN 2
WHEN age > 34 AND age <= 44 THEN 3
WHEN age > 44 AND age <= 54 THEN 4
ELSE 5
END AS age_range
FROM salary_job_country;


--Count per age range 

SELECT 
SUM (CASE WHEN age <= 24 THEN 1 ELSE 0 END ) AS under_24,
SUM (CASE WHEN age > 24 AND age <= 34 THEN 1 ELSE 0 END ) AS twenty_five_to_34,
SUM (CASE WHEN age > 34 AND age <= 44 THEN 1 ELSE 0 END ) AS thirty_five_to_44,
SUM (CASE WHEN age > 44 AND age <= 54 THEN 1 ELSE 0 END ) AS fourty_five_to_54,
SUM (CASE WHEN age > 54 AND age <= 64 THEN 1 ELSE 0 END ) AS fifty_five_to_64
FROM salary_job_country;


--Just adding an age_range column to the original table

ALTER TABLE salary_job_country
ADD COLUMN age_range INT;


UPDATE salary_job_country
SET age_range = 
(SELECT a_g.age_range
FROM
	(
	SELECT id,
	CASE 
	WHEN age <= 24 THEN 1
	WHEN age > 24 AND age <= 34 THEN 2
	WHEN age > 34 AND age <= 44 THEN 3
	WHEN age > 44 AND age <= 54 THEN 4
	ELSE 5
	END AS age_range
	FROM salary_job_country
	) a_g
WHERE a_g.id = salary_job_country.id)

SELECT *
FROM salary_job_country;

SELECT age_range, ROUND(AVG(salary))
FROM salary_job_country
GROUP BY age_range
ORDER BY 2 DESC;


-- OPTION 2. Updating table age_range column with a CTE for readability

WITH a_g_CTE AS
(
	SELECT id,
		CASE 
		WHEN age <= 24 THEN 1
		WHEN age > 24 AND age <= 34 THEN 2
		WHEN age > 34 AND age <= 44 THEN 3
		WHEN age > 44 AND age <= 54 THEN 4
		ELSE 5
		END AS age_range
	FROM salary_job_country
)
UPDATE salary_job_country
	SET age_range = 
	(SELECT a_g_CTE.age_range
		FROM a_g_CTE
				WHERE a_g_CTE.id = salary_job_country.id);

SELECT  *
FROM salary_job_country;


------Creating an exp_in_years range column--------

SELECT * FROM salary_job_country
WHERE salary < 20000;

SELECT max(exp_in_years)
FROM salary_job_country;


-- in 5 years increments

SELECT *,
CASE 
WHEN exp_in_years <= 5 THEN 1
WHEN exp_in_years > 5 AND exp_in_years <= 10 THEN 2
WHEN exp_in_years > 10 AND exp_in_years <= 15 THEN 3
WHEN exp_in_years > 15 AND exp_in_years <= 20 THEN 4
WHEN exp_in_years > 20 AND exp_in_years <= 25 THEN 5
WHEN exp_in_years > 25 AND exp_in_years <= 30 THEN 6
WHEN exp_in_years > 30 AND exp_in_years <= 35 THEN 7
ELSE 8
END AS exp_range
FROM salary_job_country;

ALTER TABLE salary_job_country
ADD COLUMN exp_range INT;


WITH exp_CTE as
(
	SELECT id,
		CASE 
		WHEN exp_in_years <= 5 THEN 1
		WHEN exp_in_years > 5 AND exp_in_years <= 10 THEN 2
		WHEN exp_in_years > 10 AND exp_in_years <= 15 THEN 3
		WHEN exp_in_years > 15 AND exp_in_years <= 20 THEN 4
		WHEN exp_in_years > 20 AND exp_in_years <= 25 THEN 5
		WHEN exp_in_years > 25 AND exp_in_years <= 30 THEN 6
		WHEN exp_in_years > 30 AND exp_in_years <= 35 THEN 7
		ELSE 8
		END AS exp_range
	FROM salary_job_country
)
UPDATE  salary_job_country
	SET exp_range =
		(	
		SELECT exp_CTE.exp_range
			FROM exp_CTE
			WHERE exp_CTE.id = salary_job_country.id)



-- 2.1 Total COUNT per:

--Country

SELECT country, COUNT(*)
FROM salary_job_country
GROUP BY country
ORDER BY 2 DESC;

--Race

SELECT race, COUNT(*)
FROM salary_job_country
GROUP BY race
ORDER BY 2 DESC;

--Gender

SELECT gender, COUNT(*)
FROM salary_job_country
GROUP BY gender
ORDER BY 2 DESC;

--Job titles

SELECT job_title, COUNT(*)
FROM salary_job_country
GROUP BY job_title
ORDER BY 2 DESC;

--2.2 AVG salery per..

-- Country
SELECT country, ROUND(AVG(salary))
FROM salary_job_country
GROUP BY country
ORDER BY 2 DESC;

--Race

SELECT race, ROUND(AVG(salary))
FROM salary_job_country
GROUP BY race
ORDER BY 2 DESC;

-- Gender
SELECT gender, ROUND(AVG(salary))
FROM salary_job_country
GROUP BY gender
ORDER BY 2 DESC;

-- Ed level

SELECT ed_level, ROUND(AVG(salary))
FROM salary_job_country
GROUP BY ed_level
ORDER BY 2 DESC;

SELECT * FROM salary_job_country;

--Age range

SELECT age_range, ROUND(AVG(salary))
FROM salary_job_country
GROUP BY age_range
ORDER BY 2 DESC;

--Years of exp

SELECT exp_in_years, ROUND(AVG(salary))
FROM salary_job_country
GROUP BY exp_in_years
ORDER BY 2 DESC;

-- Job title, 20 highest

SELECT job_title, ROUND(AVG(salary))
FROM salary_job_country
GROUP BY job_title
ORDER BY 2 DESC
LIMIT 20;

--GENDER RATIOS

--Per country

SELECT country, COUNT(*) AS male_count
FROM salary_job_country
WHERE gender IN ('Male')
GROUP BY country;

SELECT country, COUNT(*) AS fem_count
FROM salary_job_country
WHERE gender IN ('Female')
GROUP BY country;

-- Comparing the two with JOIN

SELECT m.country, male_count, fem_count
FROM 
(
SELECT country, COUNT(*) AS male_count
FROM salary_job_country
WHERE gender IN ('Male')
GROUP BY country
) AS m

JOIN
(
SELECT country, COUNT(*) AS fem_count
FROM salary_job_country
WHERE gender IN ('Female')
GROUP BY country
) AS f
ON m.country = f.country;

--Using case and subquery

SELECT country, 
ROUND ((CAST (male_count AS decimal)/total)*100,2) AS percent_male,
ROUND ((CAST (female_count AS decimal)/total)*100,2) AS percent_female
FROM
(
SELECT country, COUNT(*) AS total,
SUM (CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
SUM (CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS female_count,
SUM (CASE WHEN gender = 'Other' THEN 1 ELSE 0 END) AS other_count
FROM salary_job_country
GROUP BY country
) AS a;


-- per ed Level

SELECT ed_level, 
ROUND ((CAST (male_count AS decimal)/total)*100,2) AS percent_male,
ROUND ((CAST (female_count AS decimal)/total)*100,2) AS percent_female
FROM
(
SELECT ed_level, COUNT(*) AS total,
SUM (CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
SUM (CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS female_count,
SUM (CASE WHEN gender = 'Other' THEN 1 ELSE 0 END) AS other_count
FROM salary_job_country
GROUP BY ed_level
) AS a
ORDER BY 2 DESC;


--Looking at ratio of ed_level PER GENDER

-- Counting genders for each ed_level
SELECT gender, COUNT(*) AS total,
SUM (CASE WHEN ed_level = 'High School' THEN 1 ELSE 0 END) AS high_school,
SUM (CASE WHEN ed_level = 'Bachelor''s Degree' THEN 1 ELSE 0 END) AS bachelor,
SUM (CASE WHEN ed_level = 'Master''s Degree' THEN 1 ELSE 0 END) AS master,
SUM(CASE WHEN ed_level = 'PhD' THEN 1 ELSE 0 END) AS phd
FROM salary_job_country
GROUP BY gender

--FEMALE
	
SELECT 
	ROUND(CAST (high_school AS DECIMAL)/total * 100,2) AS high_shool_per,
	ROUND(CAST (bachelor AS DECIMAL)/total * 100,2) AS bachelor_per,
	ROUND(CAST (master AS DECIMAL)/total * 100,2) AS master_per,
	ROUND(CAST (phd AS DECIMAL)/total * 100,2) AS phd_per
FROM
	(	
	SELECT gender, COUNT(*) AS total,
	SUM (CASE WHEN ed_level = 'High School' THEN 1 ELSE 0 END) AS high_school,
	SUM (CASE WHEN ed_level = 'Bachelor''s Degree' THEN 1 ELSE 0 END) AS bachelor,
	SUM (CASE WHEN ed_level = 'Master''s Degree' THEN 1 ELSE 0 END) AS master,
	SUM(CASE WHEN ed_level = 'PhD' THEN 1 ELSE 0 END) AS phd
	FROM salary_job_country
	GROUP BY gender
	) AS a
WHERE gender = 'Female';


--MALE

SELECT 
	ROUND(CAST (high_school AS DECIMAL)/total * 100,2) AS high_shool_per,
	ROUND(CAST (bachelor AS DECIMAL)/total * 100,2) AS bachelor_per,
	ROUND(CAST (master AS DECIMAL)/total * 100,2) AS master_per,
	ROUND(CAST (phd AS DECIMAL)/total * 100,2) AS phd_per
FROM
	(	
	SELECT gender, COUNT(*) AS total,
	SUM (CASE WHEN ed_level = 'High School' THEN 1 ELSE 0 END) AS high_school,
	SUM (CASE WHEN ed_level = 'Bachelor''s Degree' THEN 1 ELSE 0 END) AS bachelor,
	SUM (CASE WHEN ed_level = 'Master''s Degree' THEN 1 ELSE 0 END) AS master,
	SUM(CASE WHEN ed_level = 'PhD' THEN 1 ELSE 0 END) AS phd
	FROM salary_job_country
	GROUP BY gender
	) AS a
WHERE gender = 'Male';


SELECT *
FROM salary_job_country;



