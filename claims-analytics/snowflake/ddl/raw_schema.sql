CREATE OR REPLACE SCHEMA INSURANCE_DB.RAW;

CREATE OR REPLACE TABLE INSURANCE_DB.RAW.CLAIMS_EXTRACT (
    claim_id            STRING,
    policy_id           STRING,
    customer_id         STRING,
    adjuster_id         STRING,
    loss_date           TIMESTAMP_NTZ,
    report_date         TIMESTAMP_NTZ,
    close_date          TIMESTAMP_NTZ,
    claim_status        STRING,
    claim_type          STRING,
    severity            STRING,
    policy_effective_date TIMESTAMP_NTZ,
    policy_expiration_date TIMESTAMP_NTZ,
    policy_product_type STRING,
    policy_state        STRING,
    customer_name       STRING,
    customer_address    STRING,
    customer_city       STRING,
    customer_state      STRING,
    customer_postal     STRING,
    customer_risk_score NUMBER(5,2),
    adjuster_name       STRING,
    adjuster_region     STRING,
    adjuster_experience_years NUMBER(5,2),
    payment_count       NUMBER,
    total_paid_amount   NUMBER(12,2)
);
