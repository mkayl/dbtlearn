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
    {{ dbt_utils.surrogate_key(['listing_id', 'review_date', 'reviewer_name', 'review_text', 'review_sentiment'])}} AS review_id
    , *
FROM src_hosts
WHERE review_text IS NOT NULL
{% if dbt.is_incremental() %}
    AND review_date > (SELECT MAX(review_date) FROM {{ this }})
{% endif %}


