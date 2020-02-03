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
-- init schemas
------------------------
DROP SCHEMA nt CASCADE;
CREATE SCHEMA nt;
SET search_path TO nt;
--
--
--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
-- Main users table
--++++++++++++++++++++++++++++
--
CREATE TABLE users(
  id SERIAL PRIMARY KEY,
  username VARCHAR(18),
  passwd TEXT,
  stripe_id TEXT,
  certified_beta_tester BOOLEAN DEFAULT FALSE,
  certified_beta_trainer_tester BOOLEAN DEFAULT FALSE,
  accept_eula BOOLEAN NOT NULL DEFAULT FALSE,
  passed_onboarding_tutorial BOOLEAN DEFAULT FALSE,
  gender TEXT,
  name_first VARCHAR(20),
  name_last VARCHAR(30),
  dob DATE,
  height SMALLINT,
  height_units VARCHAR(2),
  weight SMALLINT,
  weight_units VARCHAR(2),
  activity_level SMALLINT,
  weight_goal SMALLINT,
  bmr_equation SMALLINT,
  bodyfat_method SMALLINT,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE(username),
  UNIQUE(stripe_id)
);
--
CREATE TABLE emails(
  email VARCHAR(140) PRIMARY KEY,
  user_id INT NOT NULL,
  activated BOOLEAN DEFAULT FALSE,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE(user_id, activated),
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE
);
--
CREATE TABLE tokens(
  user_id INT NOT NULL,
  token TEXT NOT NULL,
  -- email_token_activate
  -- email_token_pw_reset
  type TEXT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE(token),
  UNIQUE(user_id, type),
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE
);
CREATE TABLE countries(
  id INT NOT NULL PRIMARY KEY,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  has_zip BOOLEAN NOT NULL,
  requires_state BOOLEAN NOT NULL,
  UNIQUE(code),
  UNIQUE(name)
);
CREATE TABLE states(
  id INT PRIMARY KEY,
  country_id INT NOT NULL,
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  UNIQUE(country_id, name),
  -- UNIQUE(country_id, code),
  FOREIGN KEY (country_id) REFERENCES countries (id)
);
CREATE TABLE addresses(
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  company_name VARCHAR(70),
  street_address VARCHAR(90) NOT NULL,
  apartment_unit VARCHAR(20),
  country_id INT NOT NULL,
  state_id INT,
  zip VARCHAR(20),
  name_first VARCHAR(90) NOT NULL,
  name_last VARCHAR(90) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(80) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (country_id) REFERENCES countries (id),
  FOREIGN KEY (state_id) REFERENCES states (id)
);
--
--
--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
-- USDA SR Database
--++++++++++++++++++++++++++++
--
---------------------------
-- Nutrient definitions
---------------------------
CREATE TABLE nutr_def(
  id INT PRIMARY KEY,
  rda REAL,
  units VARCHAR(10),
  tagname VARCHAR(10) NOT NULL,
  nutr_desc TEXT NOT NULL,
  is_anti BOOLEAN NOT NULL,
  user_id BIGINT,
  is_shared BOOLEAN NOT NULL,
  -- weighting?
  UNIQUE (tagname),
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE
);
CREATE TABLE data_src(
    id INT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    is_searchable BOOLEAN NOT NULL,
    UNIQUE(name)
);
---------------------------
-- Food groups
---------------------------
CREATE TABLE fdgrp(
  id INT PRIMARY KEY,
  fdgrp_desc TEXT,
  UNIQUE(fdgrp_desc)
);
--
---------------------------
-- Food names
---------------------------
CREATE TABLE food_des(
  id SERIAL PRIMARY KEY,
  fdgrp_id INT NOT NULL,
  data_src_id INT NOT NULL,
  long_desc TEXT NOT NULL,
  shrt_desc VARCHAR(200),
  -- TODO: same as sci_name.
  comm_name TEXT,
  manufacturer TEXT,
  -- gtin_UPC DECIMAL,
  -- ingredients TEXT,
  ref_desc TEXT,
  refuse INT,
  sci_name TEXT,
  user_id INT,
  is_shared BOOLEAN NOT NULL,
  -- UNIQUE(gtin_UPC),
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE,
  FOREIGN KEY (fdgrp_id) REFERENCES fdgrp (id) ON UPDATE CASCADE,
  FOREIGN KEY (data_src_id) REFERENCES data_src(id)
);
--
---------------------------
-- Food-Nutrient data
---------------------------
CREATE TABLE nut_data(
  food_id INT NOT NULL,
  nutr_id INT NOT NULL,
  nutr_val REAL,
  -- TODO: data_src_id as composite key?
  PRIMARY KEY (food_id, nutr_id),
  FOREIGN KEY (food_id) REFERENCES food_des (id) ON UPDATE CASCADE,
  FOREIGN KEY (nutr_id) REFERENCES nutr_def (id) ON UPDATE CASCADE
);
--
------------------------------
-- Servings
------------------------------
CREATE TABLE serving_id(
  id SERIAL PRIMARY KEY,
  msre_desc TEXT NOT NULL,
  UNIQUE(msre_desc)
);
CREATE TABLE servings(
  food_id INT NOT NULL,
  msre_id INT NOT NULL,
  grams REAL NOT NULL,
  PRIMARY KEY(food_id, msre_id),
  FOREIGN KEY (food_id) REFERENCES food_des(id) ON UPDATE CASCADE,
  FOREIGN KEY (msre_id) REFERENCES serving_id(id) ON UPDATE CASCADE
);
--
--
--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
-- Users Database
--++++++++++++++++++++++++++++
--
------------------------------
-- Custom RDAs
------------------------------
CREATE TABLE rda(
  nutr_id INT NOT NULL,
  user_id INT NOT NULL,
  rda REAL NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY (user_id, nutr_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE,
  FOREIGN KEY (nutr_id) REFERENCES nutr_def(id) ON UPDATE CASCADE
);
--
------------------------------
-- Custom recipes
------------------------------
CREATE TABLE recipe_des(
  id SERIAL PRIMARY KEY,
  recipe_name VARCHAR(255) NOT NULL,
  user_id INT NOT NULL,
  -- publicly shared ?
  shared BOOLEAN NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
CREATE TABLE recipe_dat(
  recipe_id INT NOT NULL,
  food_id INT NOT NULL,
  -- msre_id == (NULL || 0) ==> grams
  msre_id INT,
  amount REAL NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY (recipe_id, food_id),
  FOREIGN KEY (recipe_id) REFERENCES recipe_des(id) ON UPDATE CASCADE,
  FOREIGN KEY (food_id) REFERENCES food_des(id) ON UPDATE CASCADE
);
-- Recipe Portions
CREATE TABLE portion_id (
  id SERIAL PRIMARY KEY,
  portion_desc VARCHAR(255) NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE(portion_desc)
);
CREATE TABLE portions(
  recipe_id INT NOT NULL,
  portion_id INT NOT NULL,
  percentage REAL NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY(recipe_id, portion_id),
  FOREIGN KEY (recipe_id) REFERENCES recipe_des(id) ON UPDATE CASCADE,
  FOREIGN KEY (portion_id) REFERENCES portion_id(id) ON UPDATE CASCADE
);
--
------------------------------
-- Favorite foods
------------------------------
CREATE TABLE favorite_foods(
  user_id INT NOT NULL,
  food_id INT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY(user_id, food_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE,
  FOREIGN KEY (food_id) REFERENCES food_des(id) ON UPDATE CASCADE
);
--
------------------------------
-- Food logs
------------------------------
CREATE TABLE food_logs(
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  eat_on_date DATE NOT NULL,
  -- TODO: FK and meal TABLE ?
  meal_name TEXT NOT NULL,
  amount REAL NOT NULL,
  msre_id INT,
  recipe_id INT,
  food_id INT,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE,
  FOREIGN KEY (msre_id) REFERENCES serving_id(id) ON UPDATE CASCADE,
  FOREIGN KEY (recipe_id) REFERENCES recipe_des(id) ON UPDATE CASCADE,
  FOREIGN KEY (food_id) REFERENCES food_des(id) ON UPDATE CASCADE
);
------------------------------
-- Exercises
------------------------------
CREATE TABLE exercises(
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  data_src_id INT NOT NULL,
  cals_per_rep REAL,
  cals_per_min REAL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (data_src_id) REFERENCES data_src(id)
);
CREATE TABLE exercise_logs(
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  exercise_id INT NOT NULL,
  date DATE NOT NULL,
  reps INT,
  weight INT,
  duration_min INT,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON UPDATE CASCADE
);
------------------------------
-- Biometrics
------------------------------
CREATE TABLE biometrics(
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  units TEXT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW())
);
CREATE TABLE biometric_logs(
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  biometric_id INT NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  bio_val REAL NOT NULL,
  unit TEXT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE,
  FOREIGN KEY (biometric_id) REFERENCES biometrics(id) ON UPDATE CASCADE
);
--
------------------------------
-- Trainer Roles
------------------------------
CREATE TABLE trainer_users(
  trainer_id INT NOT NULL,
  user_id INT NOT NULL,
  approved BOOLEAN NOT NULL DEFAULT FALSE,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE(trainer_id, user_id),
  FOREIGN KEY (trainer_id) REFERENCES users(id) ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
------------------------------
-- Reports
------------------------------
CREATE TABLE reports(
  user_id INT NOT NULL,
  -- TODO: FK with report_type TABLE ?
  report_type TEXT NOT NULL,
  report_message TEXT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY(user_id, created_at),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
--
--
------------------------------
--++++++++++++++++++++++++++++
-- SHOP
--++++++++++++++++++++++++++++
--
------------------------------
-- Products
------------------------------
CREATE TABLE products(
  id SERIAL PRIMARY KEY,
  stripe_id TEXT NOT NULL,
  name TEXT NOT NULL,
  shippable BOOLEAN NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW())
);
CREATE TABLE variants(
  id SERIAL PRIMARY KEY,
  product_id INT NOT NULL,
  stripe_id TEXT NOT NULL,
  name TEXT NOT NULL,
  price INT NOT NULL,
  size TEXT,
  stock INT,
  interval INT,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE
);
-- Reviews
CREATE TABLE reviews(
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  rating SMALLINT NOT NULL,
  review_text TEXT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE(user_id, product_id),
  FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
-- Coupon codes
CREATE TABLE coupons(
  id SERIAL PRIMARY KEY,
  code TEXT NOT NULL,
  user_id INT,
  expires INT NOT NULL,
  created_at INT NOT NULL,
  UNIQUE(code, user_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
-- Shipping methods
CREATE TABLE shipping_methods(
  id INT PRIMARY KEY,
  -- TODO: only use VARCHAR(n) where abosolutely needed
  shipping_type TEXT NOT NULL,
  provider TEXT NOT NULL,
  name TEXT NOT NULL,
  transit_time TEXT NOT NULL
);
-- Orders
CREATE TABLE orders(
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  shipping_method_id INT NOT NULL,
  shipping_price REAL NOT NULL,
  -- TODO: FKs with payment_method TABLE ?
  payment_method TEXT NOT NULL,
  -- TODO: don't require inputting to DB ?  Guests.
  address_bill INT NOT NULL,
  address_ship INT NOT NULL,
  status TEXT NOT NULL,
  tracking_num VARCHAR(200),
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE,
  FOREIGN KEY (shipping_method_id) REFERENCES shipping_methods(id) ON UPDATE CASCADE,
  FOREIGN KEY (address_bill) REFERENCES addresses(id) ON UPDATE CASCADE,
  FOREIGN KEY (address_ship) REFERENCES addresses(id) ON UPDATE CASCADE
);
CREATE TABLE order_items(
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quanity SMALLINT NOT NULL,
  price REAL NOT NULL,
  UNIQUE(order_id, product_id),
  FOREIGN KEY (order_id) REFERENCES orders(id) ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE
);
-- Views (products)
CREATE TABLE views(
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY (user_id, product_id),
  FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
------------------------------
-- Cart
------------------------------
CREATE TABLE cart(
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  quanity SMALLINT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE(user_id, product_id),
  FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
--
------------------------------
--++++++++++++++++++++++++++++
-- IN PROGRESS
--++++++++++++++++++++++++++++
--
------------------------------
--  Custom Food Tags
------------------------------
CREATE TABLE tag_id(
  id SERIAL PRIMARY KEY,
  tag_desc VARCHAR(255) NOT NULL,
  shared BOOLEAN DEFAULT TRUE NOT NULL,
  approved BOOLEAN DEFAULT FALSE NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE(tag_desc)
);
CREATE TABLE tags(
  food_id INT NOT NULL,
  tag_id INT NOT NULL,
  user_id INT NOT NULL,
  -- votes, approved?
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY (food_id, tag_id),
  FOREIGN KEY (food_id) REFERENCES food_des (id) ON UPDATE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES tag_id (id) ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE
);
--
------------------------------
-- Scratchpad
------------------------------
CREATE TABLE scratchpad(
  user_id INT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
