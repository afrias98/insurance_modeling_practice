{% snapshot customer_snapshot_lad %}

{{ 
    config(
        schema ='silver'
        ,unique_key = ['customer_id','loss_date']
        ,strategy = 'check'
        ,check_cols = [
            'customer_name'
            ,'customer_address'
        ,'customer_city'
        ,'customer_state'
        ,'customer_postal'
        ,'customer_risk_score'
        ,'loss_date'
        ]
    )
}}


SELECT 
    customer_id
    ,customer_name
    ,customer_address
    ,customer_city
    ,customer_state
    ,customer_postal
    ,customer_risk_score
    ,loss_date
    ,last_loaded
FROM {{ ref('dim_customer_lad') }}

{% endsnapshot %}