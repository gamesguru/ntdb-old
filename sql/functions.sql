/**
 * Copyright (C) Nutra, LLC - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Kyle Hooks <kthprog@gmail.com> and Shane Jaroch <mathmuncher11@gmail.com>, May 2019
*/


--
--
-- #1
-- Search foods by name, respond {food_id, long_desc} --
--
-- CREATE OR REPLACE
-- FUNCTION data.search_foods_by_name(ts_search_expression varchar, like_search_expression varchar, source_ids varchar, food_group_ids varchar)
-- RETURNS TABLE(food_id bigint, fdgrp_desc varchar, data_src varchar, long_desc varchar, score real)
-- AS $$
-- SELECT
--   food_id,
--   fdgrp_desc,
--   data_src.data_src,
--   long_desc,
--   ts_rank_cd(textsearch_desc, to_tsquery(ts_search_expression)) score
--   FROM
--   (
--     SELECT
--       food_id,
--       data_src_id,
--       fdgrp_id,
--       long_desc,
--       textsearch_desc
--     FROM data.food_des
--     WHERE long_desc ILIKE ANY(string_to_array(like_search_expression, ','))
--   ) like_results
--   LEFT JOIN data.fdgrp ON
--     data.fdgrp.fdgrp_id = like_results.fdgrp_id
--   LEFT JOIN data.data_src ON
--     data.data_src.data_src_id = like_results.data_src_id
-- WHERE textsearch_desc @@ to_tsquery(ts_search_expression)
--   AND (
--     source_ids = '' OR
--     data.data_src.data_src_id = ANY(cast(string_to_array(source_ids, ',') as int[]))
--   )
--   AND (
--     food_group_ids = '' OR
--     data.fdgrp.fdgrp_id = ANY(cast(string_to_array(food_group_ids, ',') as int[]))
--   )
-- ORDER BY score DESC;
-- $$
-- LANGUAGE SQL;



--
--
--
-- #2
-- Search foods by name, respond food, [ALL NUTRIENTS] --
--
-- CREATE OR REPLACE
-- FUNCTION data.search_foods_by_name_with_nutrients(search_expression varchar)
-- RETURNS TABLE(food_id bigint, fdgrp_id int, long_desc varchar, nutrients json, score real)
-- AS $$
-- SELECT
--    des.food_id,
--    fdgrp_id,
--    long_desc,
--    json_agg(json_build_object(
--      'nutr_no', val.nutr_no,
--      'nutr_desc', nutr_desc,
--      'tagname', tagname,
--      'nutr_val', nutr_val,
--      'units', units
--    )) as nutrients,
--    ts_rank_cd(textsearch_desc, to_tsquery(search_expression)) score
-- FROM data.food_des des
--    LEFT JOIN data.nut_data val
--       ON val.food_id = des.food_id
--    LEFT JOIN data.nutr_def def
--       ON def.nutr_no = val.nutr_no
-- WHERE textsearch_desc @@ to_tsquery(search_expression)
-- GROUP BY des.food_id, long_desc, score
-- ORDER BY score DESC;
-- $$
-- LANGUAGE SQL;



--
--
--
-- #3
-- Get all nutrients by food_id
--
CREATE OR REPLACE
FUNCTION data.get_nutrients_by_food_ids(food_id_in int[])
RETURNS TABLE(food_id bigint, fdgrp_id int, long_desc varchar, manufacturer varchar, gtin_upc numeric, nutrients json)
AS $$
SELECT
   des.food_id,
   des.fdgrp_id,
   long_desc,
   manufacturer,
   gtin_upc,
   json_agg(json_build_object(
     'nutr_no', val.nutr_no,
     'nutr_desc', nutr_desc,
     'tagname', tagname,
     'nutr_val', nutr_val,
     'units', units
   )) as nutrients
FROM data.food_des des
   LEFT JOIN data.nut_data val
      ON val.food_id = des.food_id
   LEFT JOIN data.nutr_def def
      ON def.nutr_no = val.nutr_no
WHERE des.food_id = any(food_id_in)
GROUP BY des.food_id, long_desc
$$
LANGUAGE SQL;



--
--
--
-- #4
-- Return 100 foods highest in a given Nutr_No
--
CREATE OR REPLACE
FUNCTION data.sort_foods_by_nutrient_id(nutr_no_in int)
RETURNS TABLE(nutr_no int, units varchar, tagname varchar, nutr_desc varchar, foods json)
AS $$
SELECT
   def.nutr_no,
   def.units,
   def.tagname,
   def.nutr_desc,
   json_agg(json_build_object(
     'food_id', des.food_id,
     'long_desc', des.long_desc,
     'nutr_val', val.nutr_val
   ) ORDER BY val.nutr_val desc) as foods
FROM (
  SELECT food_id, nutr_val, nutr_no
  FROM data.nut_data val
  WHERE val.nutr_no = nutr_no_in
  ORDER BY val.nutr_val desc
  FETCH FIRST 100 ROWS ONLY
) val
LEFT JOIN data.nutr_def def
  ON def.nutr_no = val.nutr_no
LEFT JOIN data.food_des des
  ON val.food_id = des.food_id
GROUP BY def.nutr_no,
   def.units,
   def.tagname,
   def.nutr_desc
$$
LANGUAGE SQL;



--
--
--
-- #5
-- Return 100 foods highest in a given nutrient TAGNAME
-- TODO: fix this
/*
CREATE OR REPLACE
FUNCTION data.sort_foods_by_nutrient_tagname(tagname_in int)
RETURNS TABLE(food_id bigint, long_desc varchar, nutr_val float)
AS $$
SELECT
   val.food_id,
   long_desc,
   val.nutr_val
FROM data.food_des des
   JOIN data.nut_data val
      ON val.food_id = des.food_id
WHERE val.tagname = tagname_in
ORDER BY val.nutr_val desc
FETCH FIRST 100 ROWS ONLY;
$$
LANGUAGE SQL;
*/



--
--
--
-- #6
-- Get recipes for a user
--
-- CREATE OR REPLACE
-- FUNCTION data.get_recipes_for_user(user_id_in int)
-- RETURNS TABLE(recipe_id bigint, recipe_name varchar, foods json)
-- AS $$
-- SELECT
--    rdes.recipe_id,
--    rdes.recipe_name,
--    json_agg(json_build_object(
--      'food_id', rdat.food_id,
--      'long_desc', COALESCE(fdes.long_desc, ufdes.food_name),
--      'msre_id', serv.msre_id,
--      'msre_desc', serv.msre_desc,
--      'food_amt', rdat.food_amt
--    )) as foods
-- FROM users.recipe_des rdes
--    LEFT JOIN users.recipe_dat rdat
--       ON rdat.recipe_id = rdes.recipe_id
--    LEFT JOIN data.serving serv
--       ON serv.msre_id = rdat.msre_id
--    LEFT JOIN data.food_des fdes
--       ON fdes.food_id = rdat.food_id
--    LEFT JOIN users.food_des ufdes
--       ON ufdes.food_id = rdat.food_id
-- WHERE rdes.user_id = user_id_in
-- GROUP BY
--    rdes.recipe_id,
--    rdes.recipe_name;
-- $$
-- LANGUAGE SQL;



--
--
--
-- #7
-- Get measures for foods
--
-- CREATE OR REPLACE
-- FUNCTION data.get_measures_for_foods(food_id_in int[])
-- RETURNS TABLE(is_custom boolean, msre_id bigint, msre_desc varchar)
-- AS $$
-- SELECT
--    is_custom,
--    msre_id,
--    msre_desc
-- FROM (
--    SELECT
--       TRUE as is_custom,
--       userv.msre_id,
--       userv.msre_desc
--    FROM data.serving userv
--    WHERE userv.food_id = any(food_id_in)
--    UNION ALL
--    SELECT
--       FALSE as is_custom,
--       serv.seq,
--       serv.msre_desc as msre_desc
--    FROM data.serving serv
--    WHERE serv.food_id = any(food_id_in)
-- ) servs
-- $$
-- LANGUAGE SQL;



--
--
--
-- #8
-- Get food logs of users
--
CREATE OR REPLACE
FUNCTION data.get_logs_for_user(user_id_in int)
RETURNS TABLE(source varchar, meals json)
AS $$
SELECT
   CASE WHEN food_id IS NULL THEN 'recipe' ELSE 'food' END as source,
   json_agg(json_build_object(
     'id', COALESCE(food_id, recipe_id),
     'eat_on_date', eat_on_date
   )) as meals
FROM users.logs dat
WHERE dat.user_id = user_id_in
GROUP BY source
$$
LANGUAGE SQL;



--
--
--
-- #9
-- Get user favorite foods
--
CREATE OR REPLACE
FUNCTION data.get_favorite_foods_for_user(user_id_in int)
RETURNS TABLE(food_id bigint, long_desc varchar, is_custom boolean)
AS $$
SELECT DISTINCT
  food_id,
  long_desc,
  is_custom
FROM (
  SELECT
    fav.user_id,
    fav.food_id,
    desf.long_desc as long_desc,
    false as is_custom
  FROM users.favorite_foods fav
    LEFT JOIN data.food_des desf
      ON desf.food_id = fav.food_id
  WHERE fav.user_id = user_id_in
  UNION ALL
  SELECT
    user_id,
    food_id,
    long_desc,
    true as is_custom
  FROM data.food_des des
  WHERE user_id = user_id_in
) all_favs
$$
LANGUAGE SQL;



--
--
--
-- #10
-- Get user RDAs
--
CREATE OR REPLACE
FUNCTION data.get_user_rdas(user_id_in int)
RETURNS TABLE(
    nutr_no INT,
    rda float,
    units VARCHAR,
    is_anti boolean,
    tagname VARCHAR,
    nutr_desc VARCHAR,
    shared BOOLEAN
)
AS $$
SELECT
  rda.nutr_no,
  COALESCE(urda.rda, rda.rda) as rda,
  rda.units,
  rda.is_anti,
  rda.tagname,
  rda.nutr_desc,
  rda.shared
FROM data.nutr_def rda
    LEFT JOIN users.rda urda
        ON rda.nutr_no = urda.nutr_no
            AND urda.user_id = user_id_in
$$
LANGUAGE SQL;



--
--
--
-- #11
-- Get servings for food
--
CREATE OR REPLACE
FUNCTION data.get_food_servings(food_id_in bigint)
RETURNS TABLE(
  msre_id bigint,
  msre_desc varchar,
  grams float
)
AS $$
SELECT 
  serv.msre_id,
  sid.msre_desc,
  serv.grams
FROM data.serving serv
  LEFT JOIN data.serving_id sid
    ON serv.msre_id = sid.msre_id
WHERE serv.food_id = food_id_in
$$
LANGUAGE SQL;



--
--
--
-- #12
-- Get users for trainer
--
CREATE OR REPLACE
FUNCTION data.get_users_for_trainer(trainer_id_in int)
RETURNS TABLE(
  user_id int,
  username varchar
)
AS $$
SELECT 
  usr.user_id,
  usr.username
FROM users.users usr
  LEFT JOIN users.trainer_users tusr
    ON tusr.user_id = usr.user_id
WHERE tusr.trainer_id = trainer_id_in
$$
LANGUAGE SQL;



--
--
--
-- #13
-- Get trainers for users
--
CREATE OR REPLACE
FUNCTION data.get_trainers_for_user(user_id_in int)
RETURNS TABLE(
  trainer_id int,
  username varchar
)
AS $$
SELECT 
  tusr.trainer_id,
  usr.username
FROM users.trainer_users tusr
  LEFT JOIN users.users usr
    ON usr.user_id = tusr.trainer_id 
WHERE tusr.user_id = user_id_in
$$
LANGUAGE SQL;



--
--
--
-- #14
-- Get food details based on food_id
--
CREATE OR REPLACE
FUNCTION data.get_foods_by_food_id(food_id_in int[], fdgrp_id_in int[], data_src_id_in int[])
RETURNS TABLE(food_id bigint, fdgrp_desc varchar, data_src varchar, long_desc varchar, manufacturer varchar, gtin_upc numeric)
AS $$
SELECT
   des.food_id,
   grp.fdgrp_desc,
   src.data_src,
   long_desc,
   manufacturer,
   gtin_upc
FROM data.food_des des
   LEFT JOIN data.fdgrp grp
      ON grp.fdgrp_id = des.fdgrp_id
   LEFT JOIN data.data_src src
      ON src.data_src_id = des. data_src_id
    LEFT JOIN (
        SELECT *
        FROM unnest(food_id_in) with ordinality
      ) arr_data (id, ordering)
      ON arr_data.id = des.food_id
WHERE des.food_id = any(food_id_in)
  AND (fdgrp_id_in IS NULL OR des.fdgrp_id = any(fdgrp_id_in))
  AND (data_src_id_in IS NULL OR des.data_src_id = any(data_src_id_in))
ORDER BY arr_data.ordering
$$
LANGUAGE SQL;



--
--
--
-- #15
-- Get nutrients for a recipe_id
--
CREATE OR REPLACE
FUNCTION data.get_nutrients_by_recipe_ids(recipe_id_in int[])
RETURNS TABLE(recipe_id bigint, recipe_name varchar, food_id bigint, long_desc varchar, amount double precision, msre_id bigint, grams float, nutrients json)
AS $$
SELECT
  rdes.recipe_id,
  rdes.recipe_name,
  rdat.food_id,
  fdes.long_desc,
  rdat.amount,
  serv.msre_id,
  serv.grams,
  json_agg(json_build_object(
    'nutr_no', val.nutr_no,
    'nutr_desc', nutr_desc,
    'tagname', tagname,
    'nutr_val', nutr_val,
    'units', units,
    'total', CASE WHEN rdat.msre_id IS NULL THEN (val.nutr_val / 100.0) * rdat.amount ELSE serv.grams * (val.nutr_val / 100.0) * rdat.amount END
  )) as nutrients
FROM users.recipe_des rdes
  RIGHT JOIN users.recipe_dat rdat
    ON rdat.recipe_id = rdes.recipe_id
  LEFT JOIN data.food_des fdes
    ON fdes.food_id = rdat.food_id
  LEFT JOIN data.serving serv
    ON serv.food_id = rdat.food_id
      AND serv.msre_id = rdat.msre_id
  LEFT JOIN data.nut_data val
      ON val.food_id = fdes.food_id
  LEFT JOIN data.nutr_def def
      ON def.nutr_no = val.nutr_no
WHERE rdes.recipe_id = any(recipe_id_in)
GROUP BY rdes.recipe_id,
  rdes.recipe_name,
  rdat.food_id,
  rdat.amount,
  fdes.long_desc,
  serv.msre_id,
  serv.grams;
$$
LANGUAGE SQL;



--
--
--
-- #16
-- Get reviews for a shop product
--
CREATE OR REPLACE
FUNCTION shop.get_reviews_by_product(product_id varchar)
RETURNS TABLE(rating smallint, review_text varchar, username varchar)
AS $$
SELECT
    rating,
    review_text,
    us.username
FROM shop.reviews rev
    LEFT JOIN users.users us
        ON us.user_id = rev.user_id
WHERE rev.stripe_product_id = product_id
$$
LANGUAGE SQL;
