SELECT *
FROM ref('dim_listings_cleansed')
JOIN {{ ref('fct_reviews') }}  USING (listing_id)
WHERE reviews.review_date < listings.created_at
