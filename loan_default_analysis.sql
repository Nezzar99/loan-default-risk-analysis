/*
===========================================================
LOAN DEFAULT RISK ANALYSIS
SQL SERVER ANALYSIS
===========================================================
*/


/*
===========================================================
Q1A. WHAT IS THE OVERALL DEFAULT RATE?
===========================================================
*/

SELECT
    COUNT(*) AS total_loans,
    SUM(CAST(defaulted AS INT)) AS total_defaults,
    CAST(SUM(CAST(defaulted AS INT)) * 100.0 / COUNT(*)AS DECIMAL(10,2)) AS default_percent
FROM loan_applications;


/*
===========================================================
Q1B. DEFAULT RATE BY CREDIT SCORE RANGE
===========================================================
*/

SELECT
    CASE
        WHEN bp.credit_score BETWEEN 520 AND 599 THEN '520-599'
        WHEN bp.credit_score BETWEEN 600 AND 649 THEN '600-649'
        WHEN bp.credit_score BETWEEN 650 AND 699 THEN '650-699'
        WHEN bp.credit_score BETWEEN 700 AND 749 THEN '700-749'
        WHEN bp.credit_score >= 750 THEN '750+'
        ELSE 'below 520'
    END AS credit_score_bucket,
    COUNT(*) AS total_loans,
    SUM(CAST(la.defaulted AS INT)) AS total_defaults,
    CAST(SUM(CAST(la.defaulted AS INT)) * 100.0 / COUNT(*)AS DECIMAL(10,2)) AS default_percent
FROM loan_applications la
JOIN borrower_profiles bp ON la.borrower_id = bp.borrower_id
GROUP BY
    CASE
        WHEN bp.credit_score BETWEEN 520 AND 599 THEN '520-599'
        WHEN bp.credit_score BETWEEN 600 AND 649 THEN '600-649'
        WHEN bp.credit_score BETWEEN 650 AND 699 THEN '650-699'
        WHEN bp.credit_score BETWEEN 700 AND 749 THEN '700-749'
        WHEN bp.credit_score >= 750 THEN '750+'
        ELSE 'below 520'
    END
ORDER BY credit_score_bucket;


/*
===========================================================
Q2A.IS THERE A RELATIONSHIP BETWEEN A BORROWER'S DEBT-TO-INCOME (DTI) RATIO AND THE LIKELIHOOD OF DEFAULTING?
===========================================================
*/

select
    case
        when dti_ratio <20 then '0-19' 
        when dti_ratio between 20 and 29 then '20-29'
        when dti_ratio between 30 and 39 then '30-39'
        when dti_ratio between 40 and 49 then '40-49'
        else '50+'
        end as dti_ratio_bucket,
    COUNT(*) AS total_loans,
    SUM(CAST(la.defaulted AS INT)) AS total_defaults,
    CAST(SUM(CAST(la.defaulted AS INT)) * 100.0 / COUNT(*)AS DECIMAL(10,2)) AS default_percent
from loan_applications la
group by 
    CASE
        WHEN la.dti_ratio < 20 THEN '0-19'
        WHEN la.dti_ratio BETWEEN 20 AND 29 THEN '20-29'
        WHEN la.dti_ratio BETWEEN 30 AND 39 THEN '30-39'
        WHEN la.dti_ratio BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END
order by dti_ratio_bucket;


/*
===========================================================
Q3A. WHICH LOAN PURPOSES HAVE THE HIGHEST DEFAULT RATES?
===========================================================
*/

select
    loan_purpose,
    COUNT(*) AS total_loans,
    SUM(CAST(la.defaulted AS INT)) AS total_defaults,
    CAST(SUM(CAST(la.defaulted AS INT)) * 100.0 / COUNT(*)AS DECIMAL(10,2)) AS default_percent
from loan_applications la
group by loan_purpose
order by default_percent desc;


/*
===========================================================
Q3B. DOES THE AVERAGE LOAN AMOUNT DIFFER SIGNIFICANTLY BETWEEN DEFAULTED AND NON-DEFAULTED LOANS?
===========================================================
*/

select
    defaulted,
    count(*) as total_loans,
    round(avg(loan_amount), 0) as avg_loan_amount,
    min(loan_amount) as min_loan,
    max(loan_amount) as max_loan
from loan_applications
group by defaulted;


/*
===========================================================
Q4A. HOW DO EMPLOYMENT STATUS AFFECT DEFAULT RISK?
===========================================================
*/

select
    bp.employment_status,
    COUNT(*) AS total_loans,
    SUM(CAST(la.defaulted AS INT)) AS total_defaults,
    CAST(SUM(CAST(la.defaulted AS INT)) * 100.0 / COUNT(*)AS DECIMAL(10,2)) AS default_percent
FROM loan_applications la
JOIN borrower_profiles bp ON la.borrower_id = bp.borrower_id
GROUP BY employment_status
order by default_percent desc;


/*
===========================================================
Q4B. HOW DO YEARS EMPLOYED AFFECT DEFAULT RISK
===========================================================
*/

SELECT
    CASE
        WHEN bp.years_employed < 2 THEN '<2 years'
        WHEN bp.years_employed BETWEEN 2 AND 5 THEN '2-5 years'
        WHEN bp.years_employed BETWEEN 6 AND 10 THEN '6-10 years'
        ELSE '10+ years'
    END AS employment_tenure,
    COUNT(*) AS total_loans,
    SUM(CAST(la.defaulted AS INT)) AS total_defaults,
    CAST(SUM(CAST(la.defaulted AS INT)) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS default_percent
FROM loan_applications la
JOIN borrower_profiles bp ON la.borrower_id = bp.borrower_id
GROUP BY
    CASE
        WHEN bp.years_employed < 2 THEN '<2 years'
        WHEN bp.years_employed BETWEEN 2 AND 5 THEN '2-5 years'
        WHEN bp.years_employed BETWEEN 6 AND 10 THEN '6-10 years'
        ELSE '10+ years'
    END

ORDER BY
    CASE
        WHEN
            CASE
                WHEN bp.years_employed < 2 THEN '<2 years'
                WHEN bp.years_employed BETWEEN 2 AND 5 THEN '2-5 years'
                WHEN bp.years_employed BETWEEN 6 AND 10 THEN '6-10 years'
                ELSE '10+ years'
            END = '<2 years' THEN 1

        WHEN
            CASE
                WHEN bp.years_employed < 2 THEN '<2 years'
                WHEN bp.years_employed BETWEEN 2 AND 5 THEN '2-5 years'
                WHEN bp.years_employed BETWEEN 6 AND 10 THEN '6-10 years'
                ELSE '10+ years'
            END = '2-5 years' THEN 2

        WHEN
            CASE
                WHEN bp.years_employed < 2 THEN '<2 years'
                WHEN bp.years_employed BETWEEN 2 AND 5 THEN '2-5 years'
                WHEN bp.years_employed BETWEEN 6 AND 10 THEN '6-10 years'
                ELSE '10+ years'
            END = '6-10 years' THEN 3

        ELSE 4
    END;


/*
===========================================================
Q4C. ARE BORROWERS WITH LESS THAN 2 YEARS OF EMPLOYMENT MORE LIKELY TO DEFAULT?
===========================================================
*/

SELECT 
    CASE 
        WHEN bp.years_employed < 2 THEN '<2 years'
        ELSE '2+ years'
    END AS employment_group,
    COUNT(*) AS total_loans,
    SUM(CAST(la.defaulted AS INT)) AS total_defaults,
    CAST(SUM(CAST(la.defaulted AS INT)) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS default_percent
FROM loan_applications la
JOIN borrower_profiles bp ON la.borrower_id = bp.borrower_id
GROUP BY
    CASE 
        WHEN bp.years_employed < 2 THEN '<2 years'
        ELSE '2+ years'
    END;