{% snapshot customer_snapshot %}

{{ 
    config(
        schema ='silver'
        ,unique_key = 'customer_id'
        ,strategy = 'check'
        ,check_cols = [
            'customer_name'
            ,'customer_address'
            ,'customer_city'
            ,'customer_state'
            ,'customer_postal'
            ,'customer_risk_score'
        ]
    )
}}


SELECT customer_sk
    ,customer_id
    ,customer_name
    ,customer_address
    ,customer_city
    ,customer_state
    ,customer_postal
    ,customer_risk_score
    ,last_loaded
FROM {{ ref('dim_customer') }}

{% endsnapshot %}