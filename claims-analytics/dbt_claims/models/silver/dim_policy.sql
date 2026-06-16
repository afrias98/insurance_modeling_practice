{{ config(materialized='table', schema='silver' )}}

SELECT HASH(
        policy_id
        ,policy_product_type
        ,policy_state
        ,policy_effective_date
        ,policy_expiration_date
        ) AS policy_sk
    ,policy_id
    ,policy_product_type
    ,policy_state
    ,policy_effective_date
    ,policy_expiration_date
    ,stg_loaded_at AS last_loaded
FROM {{ ref('stg_claims_extract') }}
QUALIFY ROW_NUMBER() OVER 
    (PARTITION BY policy_id
    ORDER BY stg_loaded_at DESC) = 1