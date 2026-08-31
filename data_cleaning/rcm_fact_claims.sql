
/* ============================================================
   FACT_CLAIMS — DATA QUALITY & CLEANING
   Purpose: Standardize claim identifiers, dates, categorical
            fields, and data-quality exceptions.
   ============================================================ */

 /* 1. Initial Data Quality Checks
------------------------------------------------------------ */

-- Check Leading and Trailing whitespaces
SELECT 
*
FROM fact_claims
WHERE claim_id <> TRIM(claim_id)
OR patient_id <> TRIM(patient_id)
OR provider_id <> TRIM(provider_id)
OR payer_id <> TRIM(payer_id)
OR place_of_service_name <> TRIM(place_of_service_name)
OR claim_status <> TRIM(claim_status)
OR denial_reason <> TRIM(denial_reason)
;

-- Check duplicates

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT claim_id) AS unique_claims,
       COUNT(*) - COUNT(DISTINCT claim_id) AS duplicate_count
FROM fact_claims;

SELECT 
is_duplicate_flag
FROM fact_claims
WHERE is_duplicate_flag >0
-- There are 10022 claims that are duplicates


SELECT DISTINCT
cpt_code, -- 15 cpt_codes
icd10_primary,-- 20 diagnosis code
icd10_secondary,-- 20 secondary diagnosis codes with 1 NULL
place_of_service_code, -- 10 service code
place_of_service_name, -- 11 service name 
claim_status, -- 7 status
denial_code, -- 14 denial_code with 1 NULL
denial_reason -- 14 denial_reason with 1 NULL
FROM fact_claims 


-- Check for NULLs
SELECT 
claim_id
FROM fact_claims
WHERE claim_id IS NULL;


-- Length check on ID columns
SELECT
claim_id,
LEN(claim_id) AS id_len
FROM fact_claims
GROUP BY claim_id
;

/* 2. Identifier Standardization
------------------------------------------------------------ */

-- Check for Text Casing and hyphens
SELECT 
UPPER(REPLACE(claim_id, '-','')) AS claim_id
FROM fact_claims;
-- hyphens = 9747 IDs

/* 3. Date Standardization
------------------------------------------------------------ */

-- Date formating for service_date
SELECT 
service_date,
CASE
	WHEN service_date LIKE '____-__-__' AND TRY_CONVERT(DATE, service_date, 23) IS NOT NULL
	THEN TRY_CONVERT(DATE, service_date, 23)
	WHEN service_date LIKE '__-__-____' AND TRY_CONVERT(DATE, service_date, 110) IS NOT NULL
	THEN TRY_CONVERT(DATE, service_date, 110)
	WHEN service_date LIKE '____/__/__' AND TRY_CONVERT(DATE, service_date, 111) IS NOT NULL
	THEN TRY_CONVERT(DATE, service_date, 111)
	WHEN service_date LIKE '__/__/____' AND TRY_CONVERT(DATE, service_date, 101) IS NOT NULL
	THEN TRY_CONVERT(DATE, service_date, 101)
ELSE NULL
END AS fixed_service_date
FROM fact_claims;

-- Date formating for submit_date
SELECT
submit_date,
CASE 
	WHEN submit_date LIKE '____-__-__' AND TRY_CONVERT(DATE, submit_date, 23) IS NOT NULL
	THEN TRY_CONVERT(DATE, submit_date, 23)
	WHEN submit_date LIKE '__-__-____' AND TRY_CONVERT(DATE, submit_date, 110) IS NOT NULL
	THEN TRY_CONVERT(DATE, submit_date, 110)
	WHEN submit_date LIKE '____/__/__' AND TRY_CONVERT(DATE, submit_date, 111) IS NOT NULL
	THEN TRY_CONVERT(DATE, submit_date, 111)
	WHEN submit_date LIKE '__/__/____' AND TRY_CONVERT(DATE, submit_date, 101) IS NOT NULL
	THEN TRY_CONVERT(DATE, submit_date, 101)
ELSE NULL
END AS fixed_submit_date
FROM fact_claims;


/* 4. Data Corrections
------------------------------------------------------------ */

-- Populate missing place-of-service names
SELECT 
place_of_service_code,
place_of_service_name, 
CASE place_of_service_code
	WHEN '23' THEN 'Emergency Room'
	WHEN '32' THEN 'Nursing Facility'
	WHEN '21' THEN 'Inpatient Hospital'
	WHEN '81' THEN 'Independent Lab'
	WHEN '41' THEN 'Ambulance Land'
	WHEN '65' THEN 'End Stage Renal'
	WHEN '22' THEN 'Outpatient Hospital'
	WHEN '31' THEN 'Skilled Nursing'
	WHEN '51' THEN 'Inpatient Psych'
	WHEN '11' THEN 'Office'
END AS name_to_be_filled
FROM fact_claims
WHERE place_of_service_name IS NULL
ORDER BY place_of_service_code
-- (39670 rows)


SELECT
claim_status,
denial_code,
denial_reason
FROM fact_claims
WHERE claim_status NOT IN ('Paid','Void','Written Off','Pending','Partially Paid') 
AND denial_code IS NULL 
AND denial_reason IS NULL;

-- List of causes with NULL Paid, Void, Written Off, Pending, Partially Paid


SELECT 
days_in_ar 
FROM fact_claims
WHERE days_in_ar IS NULL;
-- total NULL days_in_ar = 44798

SELECT
resubmission_count
FROM fact_claims
WHERE resubmission_count >0;
-- claims with resubmissions = 34815


-- random rows check
SELECT TOP 20
*
FROM fact_claims
ORDER BY NEWID();

-- Populate missing denial code
SELECT
claim_status,
CASE claim_status
	WHEN 'Paid' THEN 'N/A'
	WHEN 'Partially Paid' THEN 'N/A'
	WHEN 'Pending' THEN 'PENDING'
	WHEN 'Void' THEN 'VOIDED'
	WHEN 'Written Off' THEN 'N/A'
	ELSE NULL
END AS filled_denial_code
FROM fact_claims
WHERE claim_status IN ('Paid', 'Partially Paid','Pending','Void','Written Off') 
AND denial_code IS NULL
GROUP BY claim_status
;


-- Populate missing denial reason
SELECT
claim_status,
CASE claim_status
	WHEN 'Paid' THEN 'No denial - claim paid'
	WHEN 'Partially Paid' THEN 'No denial - claim partially paid'
	WHEN 'Pending' THEN 'Pending adjudication'
	WHEN 'Void' THEN 'Claim voided before adjudication'
	WHEN 'Written Off' THEN 'No denial - direct write-off'
	ELSE NULL
END AS filled_denial_reason
FROM fact_claims
WHERE claim_status IN ('Paid', 'Partially Paid','Pending','Void','Written Off') 
AND denial_reason IS NULL
GROUP BY claim_status
;

-- Update
--Text Casing and hyphens
UPDATE fact_claims
SET
claim_id = UPPER(REPLACE(claim_id, '-',''))
;

/* 5. Derived Fields
------------------------------------------------------------ */

-- Create new service_date column and populate it
ALTER TABLE fact_claims ADD clean_service_date DATE
;
UPDATE fact_claims
SET
clean_service_date = 
CASE
	WHEN service_date LIKE '____-__-__'  
	THEN TRY_CONVERT(DATE, service_date, 23)
	WHEN service_date LIKE '__-__-____'  
	THEN TRY_CONVERT(DATE, service_date, 110)
	WHEN service_date LIKE '____/__/__' 
	THEN TRY_CONVERT(DATE, service_date, 111)
	WHEN service_date LIKE '__/__/____' 
	THEN TRY_CONVERT(DATE, service_date, 101)
ELSE NULL 
END;

-- 1 column with NULL (check other columns as well)
SELECT 
*
FROM fact_claims
WHERE clean_service_date IS NULL;


SELECT 
*
FROM fact_claims
WHERE YEAR(clean_service_date) IN (2025)
AND fiscal_year IN (2024);
-- 2281 new date column have 2012,2013,2014,2026,2027

-- Since the dataset has years from (2021 to 2025), 2027 is an invalid date and the correct
-- date to replace it would be 2024
SELECT
service_date,
CASE 
	WHEN service_date LIKE '%2012%' THEN REPLACE(service_date,'2012', '2022')
	WHEN service_date LIKE '%2013%' THEN REPLACE(service_date,'2013', '2023')
	WHEN service_date LIKE '%2014%' THEN REPLACE(service_date,'2014', '2024')
	WHEN service_date LIKE '%2027%' THEN REPLACE(service_date,'2027', '2024')
END AS corrected_string
FROM fact_claims
WHERE service_date LIKE '%2012%'
OR service_date LIKE '%2013%'
OR service_date LIKE '%2014%'
OR service_date LIKE '%2027%'

-- Updating
UPDATE fact_claims
SET service_date = 
CASE 
	WHEN service_date LIKE '%2012%' THEN REPLACE(service_date,'2012', '2022')
	WHEN service_date LIKE '%2013%' THEN REPLACE(service_date,'2013', '2023')
	WHEN service_date LIKE '%2014%' THEN REPLACE(service_date,'2014', '2024')
	WHEN service_date LIKE '%2027%' THEN REPLACE(service_date,'2027', '2024')
END 
WHERE service_date LIKE '%2012%'
OR service_date LIKE '%2013%'
OR service_date LIKE '%2014%'
OR service_date LIKE '%2027%' 
;
-- Update the clean_service_date

-- Create new submit_date column and populate it
ALTER TABLE fact_claims ADD clean_submit_date DATE
;
UPDATE fact_claims
SET
clean_submit_date = 
CASE
	WHEN submit_date LIKE '____-__-__'  
	THEN TRY_CONVERT(DATE, submit_date, 23)
	WHEN submit_date LIKE '__-__-____'  
	THEN TRY_CONVERT(DATE, submit_date, 110)
	WHEN submit_date LIKE '____/__/__' 
	THEN TRY_CONVERT(DATE, submit_date, 111)
	WHEN submit_date LIKE '__/__/____' 
	THEN TRY_CONVERT(DATE, submit_date, 101)
ELSE NULL 
END;

/* 6. Validation
------------------------------------------------------------ */

-- Checking if service_date is greater than submit_date

SELECT
billing_month,
fiscal_quarter,
fiscal_year,
service_date,
clean_service_date,
submit_date,
clean_submit_date
FROM fact_claims
WHERE clean_service_date > clean_submit_date;
-- 2290 rows

-- fixing years
SELECT
clean_service_date,
fiscal_year,
YEAR(clean_service_date) AS current_year,
CASE 
	WHEN YEAR(clean_service_date) != fiscal_year 
	-- DATEADD(what_to_add, how_much, which_date)
	THEN DATEADD(YEAR,fiscal_year - YEAR(clean_service_date),clean_service_date)
	ELSE clean_service_date
END AS corrected_year
FROM fact_claims
WHERE clean_service_date > clean_submit_date
AND clean_service_date IS NOT NULL
AND clean_submit_date IS NOT NULL;

-- Update
UPDATE fact_claims
SET clean_service_date = 
CASE 
	WHEN YEAR(clean_service_date) != fiscal_year 
	THEN DATEADD(YEAR,fiscal_year - YEAR(clean_service_date),clean_service_date)
	ELSE clean_service_date
END
WHERE clean_service_date > clean_submit_date
AND clean_service_date IS NOT NULL
AND clean_submit_date IS NOT NULL;

SELECT
fiscal_year,
clean_service_date,
clean_submit_date
FROM fact_claims
WHERE clean_service_date > clean_submit_date
-- 1164 rows bad (1126 fixed)

-- Check 
SELECT *
FROM fact_claims
WHERE clean_submit_date IS NULL

UPDATE fact_claims
SET place_of_service_name = 
CASE place_of_service_code
	WHEN '23' THEN 'Emergency Room'
	WHEN '32' THEN 'Nursing Facility'
	WHEN '21' THEN 'Inpatient Hospital'
	WHEN '81' THEN 'Independent Lab'
	WHEN '41' THEN 'Ambulance Land'
	WHEN '65' THEN 'End Stage Renal'
	WHEN '22' THEN 'Outpatient Hospital'
	WHEN '31' THEN 'Skilled Nursing'
	WHEN '51' THEN 'Inpatient Psych'
	WHEN '11' THEN 'Office'
END 
WHERE place_of_service_name IS NULL;


-- Update
UPDATE fact_claims
SET denial_code = 
CASE claim_status
	WHEN 'Paid' THEN 'N/A'
	WHEN 'Partially Paid' THEN 'N/A'
	WHEN 'Pending' THEN 'PENDING'
	WHEN 'Void' THEN 'VOIDED'
	WHEN 'Written Off' THEN 'N/A'
	ELSE NULL
END
WHERE claim_status IN ('Paid', 'Partially Paid','Pending','Void','Written Off') 
AND denial_code IS NULL
;
-- 375315 rows filled

UPDATE fact_claims 
SET denial_reason = 
CASE claim_status
	WHEN 'Paid' THEN 'No denial - claim paid'
	WHEN 'Partially Paid' THEN 'No denial - claim partially paid'
	WHEN 'Pending' THEN 'Pending adjudication'
	WHEN 'Void' THEN 'Claim voided before adjudication'
	WHEN 'Written Off' THEN 'No denial - direct write-off'
	ELSE NULL
END
WHERE claim_status IN ('Paid', 'Partially Paid','Pending','Void','Written Off') 
AND denial_reason IS NULL
;
-- 375315 rows filled

-- Check
SELECT * FROM fact_claims
WHERE denial_reason IS NULL







