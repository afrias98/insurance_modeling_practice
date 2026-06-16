{{ config(materialized = 'view' )}}

SELECT CLAIM_ID::VARCHAR AS claim_id
    ,POLICY_ID::VARCHAR AS policy_id
    ,CUSTOMER_ID::VARCHAR AS customer_id
    ,ADJUSTER_ID::VARCHAR AS adjuster_id
    ,LOSS_DATE::DATE AS loss_date
    ,REPORT_DATE::DATE AS report_date
    ,CLOSE_DATE::DATE AS close_date
    ,UPPER(TRIM(CLAIM_STATUS)) AS claim_status
    ,UPPER(TRIM(CLAIM_TYPE)) AS claim_type
    ,UPPER(TRIM(SEVERITY)) AS severity
    ,POLICY_EFFECTIVE_DATE::DATE AS policy_effective_date
    ,POLICY_EXPIRATION_DATE::DATE AS policy_expiration_date
    ,UPPER(TRIM(POLICY_PRODUCT_TYPE)) AS policy_product_type
    ,UPPER(POLICY_STATE) AS policy_state
    ,TRIM(CUSTOMER_NAME)::VARCHAR AS customer_name
    ,TRIM(CUSTOMER_ADDRESS)::VARCHAR AS customer_address
    ,TRIM(CUSTOMER_CITY)::VARCHAR AS customer_city
    ,UPPER(CUSTOMER_STATE) AS customer_state
    ,CUSTOMER_POSTAL::VARCHAR AS customer_postal
    ,CUSTOMER_RISK_SCORE::NUMBER(5,2) AS customer_risk_score
    ,TRIM(ADJUSTER_NAME)::VARCHAR AS adjuster_name
    ,UPPER(TRIM(ADJUSTER_REGION)) AS adjuster_region
    ,ADJUSTER_EXPERIENCE_YEARS::NUMBER(5,1) AS adjuster_experience_years
    ,PAYMENT_COUNT::NUMBER AS payment_count
    ,TOTAL_PAID_AMOUNT::NUMBER(18,2) AS total_paid_amount
    ,CURRENT_TIMESTAMP() AS stg_loaded_at
FROM {{ source('raw','claims_extract') }}