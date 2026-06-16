SELECT HASH(
        claim_id,
        claim_status,
        claim_type,
        severity,
        loss_date,
        report_date,
        close_date
    ) AS claim_sk,
    claim_id,
    claim_status,
    claim_type,
    severity,
    loss_date,
    report_date,
    close_date
FROM {{ ref('stg_claims_extract') }}
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY claim_id
    ORDER BY stg_loaded_at DESC
) = 1