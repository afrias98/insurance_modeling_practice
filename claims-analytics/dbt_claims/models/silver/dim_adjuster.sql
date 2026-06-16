{{ config(materialized='table', schema='silver' )}}

SELECT HASH(
        adjuster_id
        ,adjuster_name
        ,adjuster_region
        ,adjuster_experience_years
        ) AS adjuster_sk
    ,adjuster_id
    ,adjuster_name
    ,adjuster_region
    ,adjuster_experience_years
    ,stg_loaded_at AS last_loaded
FROM {{ ref('stg_claims_extract') }}
QUALIFY ROW_NUMBER() OVER 
    (PARTITION BY adjuster_id
    ORDER BY stg_loaded_at DESC) = 1