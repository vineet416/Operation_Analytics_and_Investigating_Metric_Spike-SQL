# Operation Analytics & Investigating Metric Spike (MySQL)

SQL analysis of two operational datasets: a job-review log and a product-usage dataset.
It measures throughput, language mix, engagement, growth, retention and email performance.
The goal is to show how a data analyst monitors operations and explains metric spikes and dips.

## Project Files

| File | Description |
|---|---|
| [Operations_Analytics (Project 3A).sql](Operations_Analytics%20%28Project%203A%29.sql) | Case Study 1: creates `job_db`, inserts 8 rows, answers 4 questions |
| [Investigating_Metric_Spike (Project 3B).sql](Investigating_Metric_Spike%20%28Project%203B%29.sql) | Case Study 2: creates `project3`, loads 3 CSVs, answers 5 questions |
| [Operation Analytics and Investigating Metric Spike (Report).pdf](Operation%20Analytics%20and%20Investigating%20Metric%20Spike%20%28Report%29.pdf) | 11-page report with queries, result screenshots and commentary |

## Dataset

| Table | Fields | Description |
|---|---|---|
| `job_data` (inline, 8 rows) | `job_id`, `actor_id`, `event`, `language`, `time_spent`, `org`, `ds` | Review log: job, reviewer, action (`decision`/`transfer`/`skip`), content language, time spent, organisation, review date (25–30 Nov 2020) |
| `users` (CSV) | `user_id`, `created_at`, `company_id`, `language`, `activated_at`, `state` | Sign-up records |
| `events` (CSV) | `user_id`, `occurred_at`, `event_type`, `event_name`, `location`, `device`, `user_type` | Product events (`engagement`, `signup_flow`, …) with device |
| `email_events` (CSV) | `user_id`, `occurred_at`, `action`, `user_type` | Email actions: weekly digest / re-engagement sent, open, clickthrough |

## Approach

1. **Understand the data:** define each field and metric (job, actor, event, engagement, retention).
2. **Clean:** load text timestamps (`dd-mm-yyyy hh:mi`) and convert them to `DATETIME` with `STR_TO_DATE`.
3. **Analyse:** window functions for rolling averages and running totals, CTEs for cohorts, `CASE` pivots for rates.
4. **Interpret:** read each result as a business signal (trend, peak, drop, share).
5. **Report:** document queries, results and commentary in the PDF.

## Key Insights

| # | Metric | Result | Basis |
|---|---|---|---|
| 1 | Jobs reviewed per hour (Nov 2020) | 0.0083 (6 distinct jobs / 720 h) | Recomputed |
| 2 | Daily throughput, 7-day rolling avg | 1–2 jobs/day; rolling avg 1.00 → 1.33 | Recomputed |
| 3 | Language share | Persian 37.5% (3 of 8); five others 12.5% each | Recomputed |
| 4 | Repeated `job_id` | Job 23 appears 3 times; 2 extra rows flagged | Recomputed |
| 5 | Weekly engaged users | Peak week 30: 1,467 users | Report |
| 6 | Decline after peak | −11.5% in week 31; −17.9% by week 34 vs peak | Report table, derived |
| 7 | Sign-up growth | 23 → 57 new users/week; 781 cumulative by week 19 of 2013 | Report |
| 8 | Email open / click rate | 33.58% / 14.79% of emails sent (≈44% of opens clicked) | Report |
| 9 | Top device | MacBook Pro: 143 users (week 17), 322 (week 30) | Report |
| 10 | Week-18 cohort retention | 452 of 615 (73.5%), indicative only (see notes) | Report |

## Tech Stack

- MySQL 8.0 and MySQL Workbench 8.0.36 (per report); Microsoft Word for the report
- Window functions, CTEs, conditional aggregation, joins, `UNION ALL`, date functions, `LOAD DATA INFILE`

## How to Use

1. Install MySQL 8.0 or later (window functions and CTEs are required).
2. Run `Operations_Analytics (Project 3A).sql`. It is self-contained.
3. For `Investigating_Metric_Spike (Project 3B).sql`, supply `users.csv`, `events.csv` and `email_events.csv`. They are not included.
4. Put them in the folder from `SHOW VARIABLES LIKE 'secure_file_priv';` and update the three `LOAD DATA INFILE` paths, then run the script.
5. Open the PDF report for queries, result screenshots and commentary.
