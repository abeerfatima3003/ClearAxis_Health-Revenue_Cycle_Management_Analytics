
/* ============================================================
   FACT_PAYMENTS — DATA QUALITY & CLEANING
   Purpose: Standardize claim identifiers, dates, categorical
            fields, and data-quality exceptions.
   ============================================================ */

/* 1. Initial Data Quality Checks
------------------------------------------------------------ */

-- Check Leading and Trailing whitespaces
SELECT 
*
FROM fact_payments
WHERE payment_id <> TRIM(payment_id)
	OR claim_id <> TRIM(claim_id)
	OR payment_type <> TRIM(payment_type);
-- Validation result: no leading/trailing whitespace detected


-- Check for duplicate payment/claim combinations
WITH ranked AS (
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY payment_id, claim_id
	ORDER BY payment_id
	) AS row_num 
FROM fact_payments
)
SELECT row_num FROM ranked
WHERE row_num > 1;
-- Validation result: no duplicates detected


/* 2. Identifier Standardization
------------------------------------------------------------ */ 

-- Standardize payment and claim IDs 
SELECT
UPPER(payment_id) AS payment_id,
UPPER(REPLACE(claim_id, '-', '')) AS claim_id
FROM fact_payments;


SELECT *,
claim_id
FROM fact_payments
WHERE claim_id LIKE '%ORPHAN%';


/* 3. Date Standardization
------------------------------------------------------------ */

-- Standardize payment dates
SELECT 
payment_date,
CASE 
	WHEN payment_date LIKE '____-__-__' AND TRY_CONVERT(DATE, payment_date,23) IS NOT NULL
		THEN TRY_CONVERT(DATE, payment_date,23)
	WHEN payment_date LIKE '__/__/____' AND TRY_CONVERT(DATE, payment_date,101) IS NOT NULL
		THEN TRY_CONVERT(DATE, payment_date,101)
	WHEN payment_date LIKE '__-__-____' AND TRY_CONVERT(DATE, payment_date,110) IS NOT NULL
		THEN TRY_CONVERT(DATE, payment_date,110)
	WHEN payment_date LIKE '____/__/__' AND TRY_CONVERT(DATE, payment_date,111) IS NOT NULL
		THEN TRY_CONVERT(DATE, payment_date,111)
	ELSE NULL
END AS fixed_payment_date
FROM fact_payments

-- Standardize posting dates
SELECT 
posting_date,
CASE 
	WHEN posting_date LIKE '____-__-__' AND TRY_CONVERT(DATE,posting_date,23) IS NOT NULL
		THEN TRY_CONVERT(DATE,posting_date,23)
	ELSE posting_date
END AS fixed_posting_date
FROM fact_payments


-- Fixing the billing month data type

-- check if column has multi-format issue
SELECT
billing_month,
LEN(billing_month)
FROM fact_payments
ORDER BY 1;

-- Populating NULL writeoff reasons where there is an amount in writeoff amount
SELECT
claim_id,
writeoff_amount,
writeoff_reason
FROM fact_payments
WHERE writeoff_amount > 0
AND writeoff_reason IS NULL

SELECT
'N/A' AS corrected_writeoff_reason
FROM fact_payments
WHERE writeoff_amount > 0
AND writeoff_reason IS NULL 
-- 7255 rows affected

/* 5. Derived Fields
------------------------------------------------------------ */

-- Adding new column
ALTER TABLE fact_payments ADD billing_month_date DATE;

UPDATE fact_payments
SET billing_month_date = TRY_CONVERT(DATE,billing_month + '-01',23); 

SELECT * FROM fact_payments;

-- Updating changes

UPDATE fact_payments
SET payment_id = UPPER(payment_id),
	claim_id = UPPER(REPLACE(claim_id, '-', ''));

UPDATE fact_payments
SET payment_date = 
CASE 
	WHEN payment_date LIKE '____-__-__' AND TRY_CONVERT(DATE, payment_date,23) IS NOT NULL
		THEN TRY_CONVERT(DATE, payment_date,23)
	WHEN payment_date LIKE '__/__/____' AND TRY_CONVERT(DATE, payment_date,101) IS NOT NULL
		THEN TRY_CONVERT(DATE, payment_date,101)
	WHEN payment_date LIKE '__-__-____' AND TRY_CONVERT(DATE, payment_date,110) IS NOT NULL
		THEN TRY_CONVERT(DATE, payment_date,110)
	WHEN payment_date LIKE '____/__/__' AND TRY_CONVERT(DATE, payment_date,111) IS NOT NULL
		THEN TRY_CONVERT(DATE, payment_date,111)
	ELSE payment_date
END;

UPDATE fact_payments
SET posting_date = 
CASE 
	WHEN posting_date LIKE '____-__-__' AND TRY_CONVERT(DATE,posting_date,23) IS NOT NULL
		THEN TRY_CONVERT(DATE,posting_date,23)
	ELSE posting_date
END;

-- Altering date column types
-- Check
SELECT *,
payment_date
FROM fact_payments
WHERE TRY_CONVERT(DATE, payment_date,23) IS NULL
	AND payment_date IS NOT NULL;

ALTER TABLE fact_payments 
ALTER COLUMN payment_date DATE;

--Check
SELECT *,
posting_date
FROM fact_payments
WHERE TRY_CONVERT(DATE,posting_date,23) IS NULL
	AND posting_date IS NOT NULL;

ALTER TABLE fact_payments
ALTER COLUMN posting_date DATE;

/* 6. Validation
------------------------------------------------------------ */

SELECT 
payment_date,
posting_date
FROM fact_payments
WHERE payment_date > posting_date

SELECT * FROM fact_payments;

SELECT
    fc.claim_id,
    fc.clean_service_date,
    fp.payment_date,
    DATEDIFF(DAY, fc.clean_service_date, 
             TRY_CONVERT(DATE, fp.payment_date, 101)) AS days_gap
FROM fact_claims fc
JOIN fact_payments fp ON fc.claim_id = fp.claim_id
WHERE fc.claim_status IN ('Paid', 'Partially Paid')
  AND fc.is_duplicate_flag = 0
  AND fc.clean_service_date IS NOT NULL
ORDER BY days_gap;
-- 293341 rows

SELECT
    fc.claim_id,
    fc.clean_service_date,
    fp.payment_date,
    DATEDIFF(DAY, fc.clean_service_date, 
             TRY_CONVERT(DATE, fp.payment_date, 101)) AS days_gap
FROM fact_claims fc
JOIN fact_payments fp ON fc.claim_id = fp.claim_id
WHERE fc.claim_status IN ('Paid', 'Partially Paid')
  AND fc.is_duplicate_flag = 0
  AND fc.clean_service_date IS NOT NULL
ORDER BY days_gap;

-- About 5% of posting_date were missing and 90% of the writeoff_reason was also missing.
-- However these are not critical to this analysis, so they were left as is. 

-- Populate NULLs in writeoff_reason
UPDATE fact_payments
SET writeoff_reason = 'N/A'
WHERE writeoff_amount > 0
AND writeoff_reason IS NULL 
;

-- Augmentation

-- Number of days between payment_date and posting_date (Update table)
SELECT
payment_date,
posting_date,
DATEDIFF(DAY,payment_date, posting_date) AS days_between
FROM fact_payments;

-- Highest days_between
WITH days_calc AS (
SELECT
payment_date,
posting_date,
DATEDIFF(DAY,payment_date, posting_date) AS days_between
FROM fact_payments
)
SELECT 
days_between, 
COUNT(*) AS occurrences
FROM days_calc
GROUP BY days_between
ORDER BY occurrences DESC;


-- Update table for augmentation
-- Days between column
ALTER TABLE fact_payments ADD days_between INT;

UPDATE fact_payments
SET days_between = DATEDIFF(DAY,payment_date, posting_date);

