CREATE DATABASE if not exists project3;
USE project3;

# CREATE TABLE users
CREATE TABLE users (
    user_id INT,
    created_at VARCHAR(100),
    company_id INT,
    language VARCHAR(50),
    activated_at VARCHAR(100),
    state VARCHAR(50)
);

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

ALTER TABLE users ADD COLUMN temp_created_at DATETIME;
UPDATE users SET temp_created_at = STR_TO_DATE(created_at, '%d-%m-%Y %H:%i') ;
ALTER TABLE users DROP COLUMN created_at;
ALTER TABLE users CHANGE COLUMN temp_created_at created_at DATETIME;

## CREATE TABLE events
CREATE TABLE events (
    user_id INT,
    occurred_at VARCHAR(100),
    event_type VARCHAR(100),
    event_name VARCHAR(100),
    location VARCHAR(100),
    device VARCHAR(100),
    user_type INT
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv"
INTO TABLE events
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

ALTER TABLE events ADD COLUMN temp_occurred_at DATETIME;
UPDATE EVENTS SET temp_occurred_at = STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i') ;
ALTER TABLE events DROP COLUMN occurred_at;
ALTER TABLE events CHANGE COLUMN temp_occurred_at occurred_at DATETIME;

## CREATE TABLE email_events
CREATE TABLE email_events (
    user_id INT,
    occurred_at VARCHAR(100),
    action VARCHAR(100),
    user_type INT
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/email_events.csv"
INTO TABLE email_events
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

ALTER TABLE email_events ADD COLUMN temp_occurred_at DATETIME;
UPDATE email_events SET temp_occurred_at = STR_TO_DATE(occurred_at, '%d-%m-%Y %H:%i') ;
ALTER TABLE email_events DROP COLUMN occurred_at;
ALTER TABLE email_events CHANGE COLUMN temp_occurred_at occurred_at DATETIME;

USE project3;
SELECT * FROM users;
SELECT * FROM events;
SELECT * FROM email_events;


# A. Weekly User Engagement:
# Objective: Measure the activeness of users on a weekly basis.
# Your Task: Write an SQL query to calculate the weekly user engagement.
SELECT * FROM events;

SELECT 
    WEEKOFYEAR(occurred_at) AS week_no,
    COUNT(DISTINCT user_id) AS weekly_user_engagement
FROM
    events
WHERE
    event_type = 'engagement'
GROUP BY week_no;

# B. User Growth Analysis:
# Objective: Analyze the growth of users over time for a product.
# Your Task: Write an SQL query to calculate the user growth for the product.
SELECT * FROM users;

SELECT 
	YEAR(created_at) AS year,
	MONTHNAME(created_at) AS month_name,
	WEEK(created_at) AS week_no,
	COUNT(DISTINCT user_id) AS new_user_count,
	SUM(count(DISTINCT user_id)) OVER (ORDER BY YEAR(created_at), 
	WEEK(created_at), MONTHNAME(created_at)) AS total_new_user
FROM 
	users
GROUP BY 
	year, week_no, month_name
ORDER BY 
	year, week_no;


# C. Weekly Retention: Users getting retained weekly after signing-up for a product.
# My task: Calculate the weekly retention of users-sign up cohort?
select * from users;
select * from events;


WITH user_signup AS (
    SELECT 
        user_id, 
        YEARWEEK(created_at, 1) AS signup_week
    FROM 
        users
), 
user_activity AS (
    SELECT 
        user_id, 
        YEARWEEK(occurred_at, 1) AS activity_week
    FROM 
        events
    UNION ALL
    SELECT 
        user_id, 
        YEARWEEK(occurred_at, 1) AS activity_week
    FROM 
        email_events
), 
user_retention AS (
    SELECT 
        u.user_id, 
        u.signup_week, 
        ua.activity_week
    FROM 
        user_signup u
    LEFT JOIN 
        user_activity ua 
    ON 
        u.user_id = ua.user_id
)
SELECT 
    r.signup_week,
    r.activity_week,
    COUNT(DISTINCT r.user_id) AS retained_users
FROM 
    user_retention r
WHERE 
    r.activity_week IS NOT NULL
GROUP BY 
    r.signup_week, r.activity_week
ORDER BY 
    r.signup_week, r.activity_week;



# D. Weekly Engagement: To measure the activeness of a user. Measuring if the user finds
# quality in a product/service weekly.
# My task: Calculate the weekly engagement per device?
SELECT * FROM events;

SELECT 
	WEEKOFYEAR(occurred_at) AS week_num, device, 
	COUNT(DISTINCT user_id) AS num_of_users
FROM 
	events
WHERE 
	event_type = 'engagement'
GROUP BY 
	week_num, device
ORDER BY 
	week_num, num_of_users desc;

# E.	Email Engagement: Users engaging with the email service. 
# My task: Calculate the email engagement metrics?
SELECT * FROM email_events;
SELECT DISTINCT action FROM email_events;

SELECT
	100* SUM(CASE WHEN email_cat = 'email_open' THEN 1 ELSE 0 end)/
		SUM(CASE WHEN email_cat = 'email_sent' THEN 1 ELSE 0 end) AS email_open_rate,
    100* SUM(CASE WHEN email_cat = 'email_clicked' THEN 1 ELSE 0 end)/
		SUM(CASE WHEN email_cat = 'email_sent' THEN 1 else 0 end) AS email_click_rate
FROM (        
	SELECT *,
		CASE
			WHEN action IN ('sent_weekly_digest', 'sent_reengagement_email') THEN 'email_sent'
			WHEN action IN ('email_open') THEN 'email_open'
			WHEN action IN ('email_clickthrough') THEN 'email_clicked'
		END AS email_cat
	FROM 
		email_events
) sub;