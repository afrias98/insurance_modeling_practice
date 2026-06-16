{% snapshot policy_snapshot %}

{{
    config(
        target_schema='SILVER',
        unique_key='policy_id',
        strategy='check',
        check_cols=[
            'policy_effective_date',
            'policy_expiration_date',
            'policy_product_type',
            'policy_state'
        ]
    )
}}

SELECT policy_sk,
    policy_id,
    policy_product_type,
    policy_state,
    policy_effective_date,
    policy_expiration_date,
    last_loaded
FROM {{ ref('dim_policy') }}

{% endsnapshot %}
