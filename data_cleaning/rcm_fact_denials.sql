
/* ============================================================
   FACT_DENIALS — DATA QUALITY & CLEANING
   Purpose: Standardize claim identifiers, dates, categorical
            fields, and data-quality exceptions.
   ============================================================ */

/* 1. Initial Data Quality Checks
------------------------------------------------------------ */
 
-- Row count and basic shape
SELECT
COUNT(*),
COUNT (DISTINCT denial_id) AS unique_rows,
COUNT(*) - COUNT (DISTINCT denial_id) AS duplicates
FROM fact_denials

-- Length check on ID columns
SELECT
denial_id,
LEN(denial_id) AS len_id
FROM fact_denials
GROUP BY denial_id

-- Random sample rows check
SELECT TOP 20
*
FROM fact_denials
ORDER BY NEWID()

-- Text Casing 
SELECT 
UPPER(claim_id) AS claim_id
FROM fact_denials;


-- Distinct for each column
SELECT DISTINCT
denial_code, -- 14 codes
denial_reason, -- 14 reasons
denial_category, -- 6 categories
appeal_filed, -- T/F
appeal_result -- 4 results and 1 NULL
FROM fact_denials

-- NULL appeal_result corresponds to non-filed appeals
-- NULL counts
SELECT
*,
appeal_filed,
appeal_date
FROM fact_denials
WHERE appeal_date IS NULL
-- 56340 claims with appeal dates NULL

SELECT
appeal_date,
appeal_result,
COALESCE(appeal_result,'Not Filed') AS clean_result
FROM fact_denials

/* 2. Date Standardization
------------------------------------------------------------ */
-- Date Formatting
SELECT
denial_date,
CASE WHEN denial_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, denial_date, 101)
	 WHEN denial_date LIKE '__-__-____' THEN TRY_CONVERT(DATE, denial_date, 110)
	 WHEN denial_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, denial_date, 23)
	 WHEN denial_date LIKE '____/__/__' THEN TRY_CONVERT(DATE, denial_date, 111)
ELSE NULL
END AS clean_denial_date
FROM fact_denials

SELECT
appeal_date,
CASE WHEN appeal_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, appeal_date,101)
	 WHEN appeal_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, appeal_date,23)
	 WHEN appeal_date LIKE '____/__/__' THEN TRY_CONVERT(DATE, appeal_date, 111)
ELSE appeal_date
END AS clean_appeal_date
FROM fact_denials

SELECT
overturn_date,
CASE WHEN overturn_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, overturn_date,101)
	 WHEN overturn_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, overturn_date,23)
	 WHEN overturn_date LIKE '____/__/__' THEN TRY_CONVERT(DATE, overturn_date, 111)
ELSE overturn_date
END AS clean_overturn_date
FROM fact_denials


-- UPDATE
-- Text Casing 
UPDATE fact_denials
SET claim_id = UPPER(claim_id)

-- Date columns
-- create new column
ALTER TABLE fact_denials ADD clean_denial_date DATE
ALTER TABLE fact_denials ADD clean_appeal_date DATE
ALTER TABLE fact_denials ADD clean_overturn_date DATE

UPDATE fact_denials
SET clean_denial_date = 
CASE WHEN denial_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, denial_date, 101)
	 WHEN denial_date LIKE '__-__-____' THEN TRY_CONVERT(DATE, denial_date, 110)
	 WHEN denial_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, denial_date, 23)
	 WHEN denial_date LIKE '____/__/__' THEN TRY_CONVERT(DATE, denial_date, 111)
ELSE NULL
END

UPDATE fact_denials
SET clean_appeal_date =
CASE WHEN appeal_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, appeal_date,101)
	 WHEN appeal_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, appeal_date,23)
	 WHEN appeal_date LIKE '____/__/__' THEN TRY_CONVERT(DATE, appeal_date, 111)
ELSE appeal_date
END 

UPDATE fact_denials
SET clean_overturn_date = 
CASE WHEN overturn_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, overturn_date,101)
	 WHEN overturn_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, overturn_date,23)
	 WHEN overturn_date LIKE '____/__/__' THEN TRY_CONVERT(DATE, overturn_date, 111)
ELSE overturn_date
END

/* 3. Validation
------------------------------------------------------------ */

-- Check date columns
SELECT
clean_denial_date,
clean_appeal_date,
clean_overturn_date
FROM fact_denials
WHERE clean_denial_date > clean_appeal_date
-- 34233 claims
OR clean_appeal_date > clean_overturn_date
-- 14839 claims
-- Total claims 124685 - bad claims 49072

-- Filling in NULLs
UPDATE fact_denials
SET appeal_result = 
COALESCE(appeal_result,'Not Filed')








