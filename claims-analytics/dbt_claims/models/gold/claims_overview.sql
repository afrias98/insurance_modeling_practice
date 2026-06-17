{{ config(
    materialized='table'
) }}

WITH fact AS (
    SELECT *
    FROM {{ ref('fact_claims') }}
),

dim_claim AS (
    SELECT
        claim_sk,
        claim_id,
        claim_status,
        claim_type,
        severity,
        loss_date,
        report_date,
        close_date
    FROM {{ ref('dim_claim') }}
),

dim_customer AS (
    SELECT
        customer_sk,
        customer_id,
        customer_name,
        customer_city,
        customer_state,
        customer_postal
    FROM {{ ref('customer_snapshot') }}
    WHERE dbt_valid_to IS NULL
),

dim_policy AS (
    SELECT
        policy_sk,
        policy_id,
        policy_product_type,
        policy_state,
        policy_effective_date,
        policy_expiration_date
    FROM {{ ref('policy_snapshot') }}
    WHERE dbt_valid_to IS NULL
),

dim_adjuster AS (
    SELECT
        adjuster_sk,
        adjuster_id,
        adjuster_name,
        adjuster_region
    FROM {{ ref('dim_adjuster') }}
),

final AS (
    SELECT
        -- Claim identifiers
        f.claim_id,
        c.claim_status,
        c.claim_type,
        c.severity,

        -- Dates
        c.loss_date,
        c.report_date,
        c.close_date,
        f.time_to_report,
        f.time_to_close,

        -- Customer attributes
        cu.customer_id,
        cu.customer_name,
        cu.customer_city,
        cu.customer_state,
        cu.customer_postal,

        -- Policy attributes
        p.policy_id,
        p.policy_product_type,
        p.policy_state,
        p.policy_effective_date,
        p.policy_expiration_date,

        -- Adjuster attributes
        a.adjuster_id,
        a.adjuster_name,
        a.adjuster_region,

        -- Measures
        f.payment_count,
        f.total_paid_amount

    FROM fact f
    LEFT JOIN dim_claim c ON f.claim_sk = c.claim_sk
    LEFT JOIN dim_customer cu ON f.customer_sk = cu.customer_sk
    LEFT JOIN dim_policy p ON f.policy_sk = p.policy_sk
    LEFT JOIN dim_adjuster a ON f.adjuster_sk = a.adjuster_sk
)

SELECT *
FROM final