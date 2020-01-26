
-- use default search_path for this project
SET search_path TO nt;

--
--
--
-- #1
-- Get product reviews (with username)
--
CREATE
OR REPLACE FUNCTION get_product_reviews(product_id VARCHAR) RETURNS TABLE(
  username VARCHAR, rating SMALLINT,
  review_text VARCHAR, created_at INT
) AS $$
SELECT
  u.username AS username,
  rv.rating,
  rv.review_text,
  rv.created_at
FROM
  reviews AS rv
  INNER JOIN users AS u ON rv.user_id = u.id
WHERE
  rv.stripe_product_id = product_id $$ LANGUAGE SQL;

--
--
--
-- #2
-- Nothing
--
