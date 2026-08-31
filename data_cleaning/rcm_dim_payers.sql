
/* ============================================================
   DIM_PAYERS — DATA QUALITY & CLEANING
   ============================================================ */

/* 1. Initial Data Quality Checks
------------------------------------------------------------ */
-- row_count
SELECT
COUNT(*) AS total_rows,
COUNT(DISTINCT payer_id) AS unique_payers,
COUNT(*) - COUNT(DISTINCT payer_id) AS duplicates
FROM dim_payers

-- Length check on IDs
SELECT
payer_id,
LEN(payer_id) AS length_id
FROM dim_payers
GROUP BY payer_id

-- Distincts
SELECT DISTINCT  
payer_name, -- 144 payers
payer_type, -- 7 payer_type
payer_state, -- 15 states
contract_type, -- 4 contracts 1 NULL
days_to_pay_avg, -- 6 days (14,21,30,45,60,90)
clearinghouse -- 5 houses 1 NULL
FROM dim_payers

-- random sampling
SELECT TOP 20
*
FROM dim_payers
ORDER BY NEWID()

-- Trailing/ leading spaces
SELECT
*
FROM dim_payers
WHERE payer_name <> TRIM(payer_name)
OR payer_type <> TRIM(payer_type)
OR payer_state <> TRIM(payer_state)
OR contract_type <> TRIM(contract_type)
OR clearinghouse <> TRIM(clearinghouse)

-- Check for NULLs
SELECT * FROM dim_payers
WHERE contract_type IS NULL
-- 40 NULLs 

SELECT * FROM dim_payers
WHERE clearinghouse IS NULL
-- 24 NULLs

/* 2. Date Standardization
------------------------------------------------------------ */
-- Date Formatting
SELECT
created_date,
CASE
WHEN created_date LIKE '____/__/__' THEN TRY_CONVERT(DATE, created_date, 111)
WHEN created_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, created_date, 101)
WHEN created_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, created_date, 23)
WHEN created_date LIKE '__-__-____' THEN TRY_CONVERT(DATE, created_date, 110)
ELSE NULL
END AS clean_created_date
FROM dim_payers

-- Update
ALTER TABLE dim_payers ADD clean_created_date DATE 

UPDATE dim_payers
SET clean_created_date = 
CASE
WHEN created_date LIKE '____/__/__' THEN TRY_CONVERT(DATE, created_date, 111)
WHEN created_date LIKE '__/__/____' THEN TRY_CONVERT(DATE, created_date, 101)
WHEN created_date LIKE '____-__-__' THEN TRY_CONVERT(DATE, created_date, 23)
WHEN created_date LIKE '__-__-____' THEN TRY_CONVERT(DATE, created_date, 110)
ELSE NULL
END







