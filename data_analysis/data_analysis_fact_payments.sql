
-- Data analysis (rcm_fact_payments)

-- What the payer should have paid and what the patient should have paid, 
-- based on known expectations.
-- 1. expected payer payment = allowed_amount
-- 2. expected patient payment = AVG(patient_payment/allowed_amount) patient_share based on payer_type/ cpt_code

SELECT
p.payer_type,
AVG(patient_payment/ allowed_amount) AS avg_patient_share
FROM fact_payments AS fp
INNER JOIN fact_claims AS fc
	ON fp.claim_id = fc.claim_id
INNER JOIN dim_payers AS p
	ON fc.payer_id = p.payer_id
WHERE fc.allowed_amount > 0 AND fp.patient_payment >0
GROUP BY p.payer_type
;
-- Column for responsible party
WITH payer_type_benchmark AS (
    SELECT
        p.payer_type,
        AVG(fp.patient_payment / fc.allowed_amount) AS avg_patient_share
    FROM fact_payments fp
    JOIN fact_claims fc ON fp.claim_id = fc.claim_id
    JOIN dim_payers p ON fc.payer_id = p.payer_id
    WHERE fc.allowed_amount > 0 AND fp.patient_payment > 0
    GROUP BY p.payer_type
),
claims_with_balance AS (
    SELECT
        fp.claim_id,
        p.payer_type,
        fc.allowed_amount,
        fp.payer_payment,
        fp.patient_payment,
        fp.remaining_balance,
        fp.eob_received,
        fp.era_matched,
        b.avg_patient_share
    FROM fact_payments fp
    JOIN fact_claims fc ON fp.claim_id = fc.claim_id
    JOIN dim_payers p ON fc.payer_id = p.payer_id
    JOIN payer_type_benchmark b ON p.payer_type = b.payer_type
    WHERE fp.remaining_balance > 0
      AND fc.allowed_amount > 0
)
SELECT
    claim_id,
    payer_type,
    allowed_amount,
    payer_payment,
    ROUND(allowed_amount * (1 - avg_patient_share), 2) AS expected_payer_payment,
    ROUND(allowed_amount * (1 - avg_patient_share) - payer_payment, 2) AS payer_shortfall,
    patient_payment,
    ROUND(allowed_amount * avg_patient_share, 2) AS expected_patient_payment,
    ROUND(allowed_amount * avg_patient_share - patient_payment, 2) AS patient_shortfall,
    remaining_balance,
    eob_received,
    era_matched,
    CASE
        WHEN eob_received = 'False' OR era_matched = 'False'
            THEN 'Likely Payer Responsible (processing incomplete)'
        WHEN (allowed_amount * (1 - avg_patient_share) - payer_payment)
             > (allowed_amount * avg_patient_share - patient_payment)
            THEN 'Likely Payer Responsible'
        WHEN (allowed_amount * avg_patient_share - patient_payment)
             > (allowed_amount * (1 - avg_patient_share) - payer_payment)
            THEN 'Likely Patient Responsible'
        ELSE 'Unclear / Investigate'
    END AS likely_responsible_party
FROM claims_with_balance;

-- No. of claims owed by each party, amount and percentage

-- payer_type_benchmark CTE
WITH payer_type_benchmark AS (
SELECT
p.payer_type,
AVG(patient_payment/ allowed_amount) AS avg_patient_share
FROM fact_payments AS fp
INNER JOIN fact_claims AS fc
	ON fp.claim_id = fc.claim_id
INNER JOIN dim_payers AS p
	ON fc.payer_id = p.payer_id
WHERE fc.allowed_amount > 0 AND fp.patient_payment >0
GROUP BY p.payer_type
)
-- all claims with remaining balances to know patient_share with payer_type 
, claims_with_balance AS (
SELECT
fp.claim_id,
p.payer_type,
fc.allowed_amount,
fp.payer_payment,
fp.patient_payment,
fp.remaining_balance,
fp.eob_received,
fp.era_matched,
b.avg_patient_share
FROM fact_payments AS fp
INNER JOIN fact_claims AS fc
	ON fp.claim_id = fc.claim_id
INNER JOIN dim_payers AS p
	ON fc.payer_id = p.payer_id
INNER JOIN payer_type_benchmark AS b
	ON p.payer_type = b.payer_type
WHERE fp.remaining_balance > 0 AND fc.allowed_amount > 0  
)
-- responsibility 
, responsibility_assigned AS (
SELECT
claim_id,
remaining_balance,
CASE 
	WHEN eob_received = 'False' OR era_matched = 'False'
		THEN 'Likely Payer Responsible (processing incomplete)' 
	WHEN (allowed_amount * (1 - avg_patient_share) - payer_payment) > (allowed_amount * avg_patient_share - patient_payment)
		THEN 'Likely Payer Responsible'
	WHEN (allowed_amount * avg_patient_share - patient_payment) > (allowed_amount * (1 - avg_patient_share) - payer_payment)
		THEN 'Likely Patient Responsible'
	ELSE 'Unclear'
END AS likely_responsible_party
FROM claims_with_balance
)
SELECT 
likely_responsible_party,
COUNT(*) AS num_claims,
SUM(remaining_balance) AS total_dollars_outstanding,
-- Putting count in float to balance decimal then applying window function 
CAST(COUNT(*) AS FLOAT)* 100 / SUM(COUNT(*)) OVER() AS percentage_of_claims
FROM responsibility_assigned
GROUP BY likely_responsible_party
ORDER BY num_claims
;
-- Based on typical payment patterns, we estimate that the highest % of unresolved balances 
-- are likely under incomplete processing that comes to 50% 
-- which amounts to a total of 19,498,680.30
-- While the the 2nd highest falls likely on the patient which would be around 37%. 
-- And the rest 13% likely under the payer.


-- Update table for augmentation

-- likely_responisble_party column
ALTER TABLE fact_payments ADD likely_responsible_party VARCHAR(60);

-- Populate new column by joining CTE to payments table
WITH payer_type_benchmark AS (
    SELECT
        p.payer_type,
        AVG(fp.patient_payment / fc.allowed_amount) AS avg_patient_share
    FROM fact_payments fp
    JOIN fact_claims fc ON fp.claim_id = fc.claim_id
    JOIN dim_payers p ON fc.payer_id = p.payer_id
    WHERE fc.allowed_amount > 0 AND fp.patient_payment > 0
    GROUP BY p.payer_type
),
claims_with_balance AS (
    SELECT
        fp.claim_id,
        p.payer_type,
        fc.allowed_amount,
        fp.payer_payment,
        fp.patient_payment,
        fp.remaining_balance,
        fp.eob_received,
        fp.era_matched,
        b.avg_patient_share
    FROM fact_payments fp
    JOIN fact_claims fc ON fp.claim_id = fc.claim_id
    JOIN dim_payers p ON fc.payer_id = p.payer_id
    JOIN payer_type_benchmark b ON p.payer_type = b.payer_type
    WHERE fp.remaining_balance > 0
      AND fc.allowed_amount > 0
)
UPDATE fact_payments
SET likely_responsible_party = 
CASE
        WHEN c.eob_received = 'False' OR c.era_matched = 'False'
            THEN 'Likely Payer Responsible (processing incomplete)'
        WHEN (c.allowed_amount * (1 - c.avg_patient_share) - c.payer_payment)
             > (c.allowed_amount * c.avg_patient_share - c.patient_payment)
            THEN 'Likely Payer Responsible'
        WHEN (c.allowed_amount * c.avg_patient_share - c.patient_payment)
             > (c.allowed_amount * (1 - c.avg_patient_share) - c.payer_payment)
            THEN 'Likely Patient Responsible'
        ELSE 'Unclear / Investigate'
    END
FROM fact_payments AS fp
INNER JOIN claims_with_balance AS c
ON fp.claim_id = c.claim_id;