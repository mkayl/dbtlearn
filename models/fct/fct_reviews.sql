{{
    config(
        materialized = 'incremental',
        on_schema_change='fail'
    )
}}

WITH src_hosts AS (
    SELECT * FROM {{ ref('src_reviews') }}
)
SELECT 
    *
FROM src_hosts
WHERE review_text IS NOT NULL
{% if dbt.is_incremental() %}
    AND review_date > (SELECT MAX(review_date) FROM {{ this }})
{% endif %}
