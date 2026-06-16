{{ config(materialized='table', schema='silver' )}}

SELECT HASH(
        customer_id
        ,customer_name
        ,customer_address
        ,customer_city
        ,customer_state
        ,customer_postal
        ,customer_risk_score
        ,loss_date
        ) AS customer_sk
    , customer_id
    ,customer_name
    ,customer_address
    ,customer_city
    ,customer_state
    ,customer_postal
    ,customer_risk_score
    ,loss_date
    ,stg_loaded_at AS last_loaded
FROM {{ ref('stg_claims_extract') }}
QUALIFY ROW_NUMBER() OVER 
    (PARTITION BY customer_id, loss_date
    ORDER BY stg_loaded_at DESC) = 1