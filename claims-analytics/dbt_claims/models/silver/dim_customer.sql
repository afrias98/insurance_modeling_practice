{{ config(materialized='table', schema='silver' )}}

WITH deduped AS(
    SELECT customer_id
        ,customer_name
        ,customer_address
        ,customer_city
        ,customer_state
        ,customer_postal
        ,customer_risk_score
        ,MAX(stg_loaded_at) AS last_loaded
    FROM {{ ref('stg_claims_extract') }}
    GROUP BY ALL
)

SELECT HASH(
        customer_id
        ,customer_name
        ,customer_address
        ,customer_city
        ,customer_state
        ,customer_postal
        ,customer_risk_score
        ) AS customer_sk
    , customer_id
    ,customer_name
    ,customer_address
    ,customer_city
    ,customer_state
    ,customer_postal
    ,customer_risk_score
    ,last_loaded
FROM deduped