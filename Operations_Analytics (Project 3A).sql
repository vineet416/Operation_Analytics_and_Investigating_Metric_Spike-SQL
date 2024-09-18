CREATE DATABASE job_db;
USE job_db;

CREATE TABLE job_data
(
job_id INT,
actor_id INT,
event VARCHAR(50),
language VARCHAR(50),
time_spent TIME,
org VARCHAR(100),
ds DATE 
);
INSERT INTO job_data (job_id, actor_id, event, language, time_spent, org, ds)
VALUES
('21',	'1001',	'skip',	'English',	'15',	'A', '2020-11-30'),
('22',	'1006',	'transfer',	'Arabic',	'25',	'B', '2020-11-30'),
('23',	'1003',	'decision',	'Persian',	'20', 'C', '2020-11-29'),
('23',	'1005',	'transfer',	'Persian',	'22',	'D', '2020-11-28'),
('25',	'1002',	'decision',	'Hindi',	'11',	'B','2020-11-28'),
('11',	'1007',	'decision',	'French',	'104',	'D', '2020-11-27'),
('23',	'1004',	'skip',	'Persian',	'56',	'A', '2020-11-26'),
('20',	'1003',	'transfer',	'Italian',	'45',	'C', '2020-11-25')
;
SELECT * FROM job_data;

# A.	Number of jobs reviewed: Amount of jobs reviewed over time. 
# My task: Calculate the number of jobs reviewed per hour per day for November 2020?

SELECT 
	COUNT(distinct job_id)/(30*24) as num_jobs_reviewed
FROM 
	job_data
WHERE 
	ds BETWEEN '2020-11-01' AND '2020-11-30';

# B.	Throughput: It is the no. of events happening per second. 
# My task: Let’s say the above metric is called throughput. 
# Calculate 7 day rolling average of thoroughput. For throughput, do you prefer daily metric or 7-day rolling and why?


SELECT 
	ds, jobs_reviewed,
	AVG(jobs_reviewed)OVER(ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS throughput_7_rolling_avg
FROM (
	SELECT 
		ds, COUNT(DISTINCT job_id) AS jobs_reviewed
	From 
		job_data
	WHERE 
		ds BETWEEN '2020-11-01' AND '2020-11-30'
	GROUP BY 
		ds
	ORDER BY 
		ds
)a;

# C.	Percentage share of each language: Share of each language for different contents. 
# My task: Calculate the percentage share of each language in the last 30 days?


SELECT
	language, num_jobs,
	100.0* num_jobs/total_jobs as pct_share_jobs
FROM (
	SELECT 
		language, COUNT( job_id) AS num_jobs
	FROM 
		job_data
	GROUP BY 
		language 
)a
CROSS JOIN (
	SELECT 
		COUNT(job_id) AS total_jobs
	FROM 
		job_data
)b;

# D.	Duplicate rows: Rows that have the same value present in them. 
# My task: Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?


SELECT 
	* 
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY job_id) AS rownum
	FROM 
    job_data
)a
WHERE 
	rownum>1;