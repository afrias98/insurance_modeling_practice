{{ config(
    materialized='incremental',
    unique_key='fact_claim_sk'
) }}

WITH base AS (

    SELECT
        claim_id,
        customer_id,
        policy_id,
        adjuster_id,
        loss_date,
        report_date,
        close_date,
        stg_loaded_at,
        total_paid_amount
    FROM {{ ref('stg_claims_extract') }}

),

agg_payments AS (

    SELECT
        claim_id,
        COUNT(*) AS payment_count,
        SUM(total_paid_amount) AS total_paid_amount
    FROM base
    GROUP BY claim_id

),

dim_claim_lookup AS (

    SELECT
        claim_id,
        claim_sk
    FROM {{ ref('dim_claim') }}

),

dim_adjuster_lookup AS (

    SELECT
        adjuster_id,
        adjuster_sk
    FROM {{ ref('dim_adjuster') }}

),

dim_customer_snapshot AS (

    SELECT
        customer_id,
        customer_sk,
        dbt_valid_from,
        dbt_valid_to
    FROM {{ ref('customer_snapshot') }}
    WHERE dbt_valid_to IS NULL   -- current version
),

dim_policy_snapshot AS (

    SELECT
        policy_id,
        policy_sk,
        dbt_valid_from,
        dbt_valid_to
    FROM {{ ref('policy_snapshot') }}
    WHERE dbt_valid_to IS NULL   -- current version
),

dim_date_lookup AS (

    SELECT
        date_key,
        date_id
    FROM {{ ref('dim_date') }}

),

final AS (

    SELECT
        -- Fact surrogate key
        HASH(
            b.claim_id,
            b.stg_loaded_at
        ) AS fact_claim_sk,

        -- Dim surrogate keys
        c.claim_sk,
        cu.customer_sk,
        p.policy_sk,
        a.adjuster_sk,

        -- Date surrogate keys
        d_loss.date_id AS loss_date_id,
        d_report.date_id AS report_date_id,
        d_close.date_id AS close_date_id,
        d_load.date_id AS load_date_id,

        -- Measures
        ap.payment_count,
        ap.total_paid_amount,

        -- Raw business keys
        b.claim_id,
        b.customer_id,
        b.policy_id,
        b.adjuster_id,

        -- Metrics
        DATEDIFF('day', b.loss_date, b.report_date) AS time_to_report,
        DATEDIFF('day', b.loss_date, b.close_date) AS time_to_close

    FROM base b
    LEFT JOIN agg_payments ap ON b.claim_id = ap.claim_id
    LEFT JOIN dim_claim_lookup c ON b.claim_id = c.claim_id
    LEFT JOIN dim_adjuster_lookup a ON b.adjuster_id = a.adjuster_id
    LEFT JOIN dim_customer_snapshot cu ON b.customer_id = cu.customer_id
    LEFT JOIN dim_policy_snapshot p ON b.policy_id = p.policy_id

    LEFT JOIN dim_date_lookup d_loss ON b.loss_date = d_loss.date_key
    LEFT JOIN dim_date_lookup d_report ON b.report_date = d_report.date_key
    LEFT JOIN dim_date_lookup d_close ON b.close_date = d_close.date_key
    LEFT JOIN dim_date_lookup d_load ON CAST(b.stg_loaded_at AS DATE) = d_load.date_key

)

SELECT *
FROM final

{% if is_incremental() %}
WHERE fact_claim_sk NOT IN (SELECT fact_claim_sk FROM {{ this }})
{% endif %}