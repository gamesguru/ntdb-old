-- nutra-db, a database for nutratracker clients
-- Copyright (C) 2020  Nutra, LLC. [Shane & Kyle] <nutratracker@gmail.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
--
--
------------------------
-- SET search_path
------------------------
SET
  search_path TO nt;
--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
-- #1   SHOP
--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
--
--
--
-- 1.a
-- Get product reviews (with username)
--
CREATE
OR REPLACE FUNCTION get_product_reviews(product_id_in VARCHAR) RETURNS TABLE(
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
  rv.product_id = product_id_in $$ LANGUAGE SQL;
--
--
--
-- 1.b
-- Get products with avg_ratings
--
CREATE
OR REPLACE FUNCTION get_products_ratings() RETURNS TABLE(
  id VARCHAR, name VARCHAR, price_min SMALLINT,
  price_max SMALLINT, shippable BOOLEAN,
  avg_rating REAL, inventory_stocks JSONB
) AS $$
SELECT
  DISTINCT prod.id,
  prod.name,
  price_min,
  price_max,
  shippable,
  avg(rv.rating):: REAL,
  jsonb_agg(
    json_build_object(sk.id, sk.inventory_stock)
  )
FROM
  products prod
  INNER JOIN reviews AS rv ON rv.product_id = prod.id
  INNER JOIN skus AS sk ON sk.product_id = prod.id
GROUP BY
  prod.id $$ LANGUAGE SQL;
--
--
--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
-- #2   Public DATA
--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
--
--
--
-- 2.a
-- Get all nutrients by food_id
--
CREATE
OR REPLACE FUNCTION get_nutrients_by_food_ids(food_id_in INT[]) RETURNS TABLE(
  food_id INT, fdgrp_id INT, long_desc VARCHAR,
  manufacturer VARCHAR, nutrients JSON
) AS $$
SELECT
  des.id,
  des.fdgrp_id,
  long_desc,
  manufacturer,
  json_agg(
    json_build_object(
      'nutr_id', val.nutr_id, 'nutr_desc',
      nutr_desc, 'tagname', tagname, 'nutr_val',
      nutr_val, 'units', units
    )
  ) AS nutrients
FROM
  food_des des
  LEFT JOIN nut_data val ON val.food_id = des.id
  LEFT JOIN nutr_def def ON def.id = val.nutr_id
WHERE
  des.id = any(food_id_in)
GROUP BY
  des.id,
  long_desc $$ LANGUAGE SQL;
--
--
--
-- 2.b
-- Return 100 foods highest in a given nutr_id
--
CREATE
OR REPLACE FUNCTION sort_foods_by_nutrient_id(nutr_id_in INT) RETURNS TABLE(
  nutr_id INT, units VARCHAR, tagname VARCHAR,
  nutr_desc VARCHAR, foods JSON
) AS $$
SELECT
  def.id,
  def.units,
  def.tagname,
  def.nutr_desc,
  json_agg(
    json_build_object(
      'food_id', des.id, 'long_desc', des.long_desc,
      'nutr_val', val.nutr_val
    )
    ORDER BY
      val.nutr_val DESC
  ) AS foods
FROM
  (
    SELECT
      food_id,
      nutr_val,
      nutr_id
    FROM
      nut_data val
    WHERE
      val.nutr_id = nutr_id_in
    ORDER BY
      val.nutr_val DESC FETCH FIRST 100 ROWS ONLY
  ) val
  LEFT JOIN nutr_def def ON def.id = val.nutr_id
  LEFT JOIN food_des des ON val.food_id = des.id
GROUP BY
  def.id,
  def.units,
  def.tagname,
  def.nutr_desc $$ LANGUAGE SQL;
--
--
--
-- 2.c
-- Get servings for food
--
CREATE
OR REPLACE FUNCTION get_food_servings(food_id_in INT) RETURNS TABLE(
  msre_id INT, msre_desc VARCHAR,
  grams REAL
) AS $$
SELECT
  serv.msre_id,
  serv_id.msre_desc,
  serv.grams
FROM
  servings serv
  LEFT JOIN serving_id serv_id ON serv.msre_id = serv_id.id
WHERE
  serv.food_id = food_id_in $$ LANGUAGE SQL;
--
--
--
-- 2.d
-- Get food[] analysis
--
CREATE
OR REPLACE FUNCTION get_foods_by_food_id(
  food_id_in INT[], fdgrp_id_in INT[]
) RETURNS TABLE(
  food_id INT, fdgrp_desc VARCHAR,
  long_desc VARCHAR, manufacturer VARCHAR
) AS $$
SELECT
  des.id,
  grp.fdgrp_desc,
  long_desc,
  manufacturer
FROM
  food_des des
  LEFT JOIN fdgrp grp ON grp.id = des.fdgrp_id
  LEFT JOIN (
    SELECT
      *
    FROM
      unnest(food_id_in) WITH ORDINALITY
  ) arr_data (id, ordering) ON arr_data.id = des.id
WHERE
  des.id = any(food_id_in)
  AND (
    fdgrp_id_in IS NULL
    OR des.fdgrp_id = any(fdgrp_id_in)
  )
ORDER BY
  arr_data.ordering $$ LANGUAGE SQL;
--
--
--
-- 2.e
-- Search food names --> {food_id, long_desc}
--
CREATE
OR REPLACE FUNCTION search_foods_by_name(
  ts_search_expression VARCHAR, like_search_expression VARCHAR
) RETURNS TABLE(
  food_id INT, fdgrp_desc VARCHAR,
  long_desc VARCHAR, score REAL
) AS $$
SELECT
  fdes.id,
  fgrp.fdgrp_desc AS fdgrp_desc,
  long_desc,
  ts_rank_cd(
    textsearch_desc,
    to_tsquery(ts_search_expression)
  ) score
FROM
  food_des AS fdes
  INNER JOIN fdgrp AS fgrp ON fgrp.id = fdes.fdgrp_id
WHERE
  textsearch_desc @@ to_tsquery(ts_search_expression)
ORDER BY
  score DESC;
$$ LANGUAGE SQL;
--
--
--
-- 2.f
-- Search food names --> [ALL NUTRIENTS]
--
CREATE
OR REPLACE FUNCTION search_foods_by_name_with_nutrients(search_expression varchar) RETURNS TABLE(
  food_id INT, fdgrp_id INT, long_desc VARCHAR,
  nutrients JSON, score REAL
) AS $$
SELECT
  des.id,
  fdgrp_id,
  long_desc,
  json_agg(
    json_build_object(
      'nutr_id', val.nutr_id, 'nutr_desc',
      nutr_desc, 'tagname', tagname, 'nutr_val',
      nutr_val, 'units', units
    )
  ) as nutrients,
  ts_rank_cd(
    textsearch_desc,
    to_tsquery(search_expression)
  ) score
FROM
  food_des des
  LEFT JOIN nut_data val ON val.food_id = des.id
  LEFT JOIN nutr_def def ON def.id = val.nutr_id
WHERE
  textsearch_desc @@ to_tsquery(search_expression)
GROUP BY
  des.id,
  long_desc,
  score
ORDER BY
  score DESC;
$$ LANGUAGE SQL;
--
--
--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
-- #3   Private DATA
--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
--
--
--
-- 3.a
-- Get user RDAs
--
CREATE
OR REPLACE FUNCTION get_user_rdas(user_id_in int) RETURNS TABLE(
  nutr_id INT, rda REAL, units VARCHAR,
  tagname VARCHAR, nutr_desc VARCHAR
) AS $$
SELECT
  rda.id,
  COALESCE(urda.rda, rda.rda) as rda,
  rda.units,
  rda.tagname,
  rda.nutr_desc
FROM
  nutr_def rda
  LEFT JOIN rda urda ON rda.id = urda.nutr_id
  AND urda.user_id = user_id_in $$ LANGUAGE SQL;
--
--
--
-- 3.b
-- Get user favorite foods
--
CREATE
OR REPLACE FUNCTION get_user_favorite_foods(user_id_in INT) RETURNS TABLE(food_id INT, long_desc VARCHAR) AS $$
SELECT
  food_id,
  fdes.long_desc
FROM
  favorite_foods ff
  INNER JOIN food_des fdes ON fdes.id = ff.food_id
WHERE
  ff.user_id = user_id_in $$ LANGUAGE SQL;
