-- nutra-db, a database for nutratracker clients
-- Copyright (C) 2020  Nutra, LLC. [Shane & Kyle] <nutratracker@gmail.com>

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.


------------------------
-- init schemas
------------------------
DROP SCHEMA nt CASCADE;
CREATE SCHEMA nt;
SET search_path TO nt;


--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
-- Main users table
--++++++++++++++++++++++++++++

CREATE TABLE users(
  id SERIAL PRIMARY KEY,
  username VARCHAR(18) NOT NULL,
  passwd VARCHAR(300) NOT NULL,
  unverified_email VARCHAR(140),
  email VARCHAR(140),
  email_token_activate VARCHAR(200),
  email_token_pw_reset VARCHAR(200),
  -- Need to discuss necessity of below fields
  accept_eula BOOLEAN NOT NULL DEFAULT FALSE,
  stripe_id VARCHAR(200) NOT NULL,
  certified_beta_tester BOOLEAN DEFAULT FALSE,
  certified_beta_trainer_tester BOOLEAN DEFAULT FALSE,
  passed_onboarding_tutorial BOOLEAN DEFAULT FALSE,
  gender VARCHAR(20),
  name VARCHAR(90),
  dob DATE,
  height SMALLINT,
  height_units VARCHAR(2),
  weight SMALLINT,
  weight_units VARCHAR(3),
  activity_level SMALLINT,
  weight_goal SMALLINT,
  bmr_equation SMALLINT,
  bodyfat_method SMALLINT,
  UNIQUE(username),
  UNIQUE(email),
  UNIQUE(unverified_email)
);


--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
-- USDA SR Database
--++++++++++++++++++++++++++++

---------------------------
-- Nutrient definitions
---------------------------
CREATE TABLE nutr_def(
  id INT PRIMARY KEY,
  rda float,
  units VARCHAR(10),
  tagname VARCHAR(10) NOT NULL,
  nutr_desc VARCHAR(80) NOT NULL,
  -- user_id BIGINT,
  -- shared BOOLEAN NOT NULL,
  -- weighting?
  UNIQUE (tagname)
  -- FOREIGN KEY (user_id) REFERENCES users (id) ON UPDATE CASCADE
);

---------------------------
-- Food groups
---------------------------
CREATE TABLE fdgrp(
  id INT PRIMARY KEY,
  fdgrp_desc VARCHAR(200),
  UNIQUE(fdgrp_desc)
);

---------------------------
-- Food names
---------------------------
CREATE TABLE food_des(
  id SERIAL PRIMARY KEY,
  fdgrp_id INT NOT NULL,
  long_desc VARCHAR(400) NOT NULL,
  shrt_desc VARCHAR(200) NOT NULL,
  comm_name VARCHAR(200),
  manufacturer VARCHAR(300),
  -- gtin_UPC DECIMAL,
  -- ingredients TEXT,
  ref_desc VARCHAR(150),
  refuse INT,
  sci_name VARCHAR(200),
  -- user_id INT,
  -- shared BOOLEAN DEFAULT TRUE,
  -- UNIQUE(gtin_UPC),
  FOREIGN KEY (fdgrp_id) REFERENCES fdgrp (id) ON UPDATE CASCADE
);

---------------------------
-- Food-Nutrient data
---------------------------
CREATE TABLE nut_data(
  food_id INT NOT NULL,
  nutr_id INT NOT NULL,
  nutr_val float,
  -- TODO: data_src_id as composite key?
  PRIMARY KEY (food_id, nutr_id),
  FOREIGN KEY (food_id) REFERENCES food_des (id) ON UPDATE CASCADE,
  FOREIGN KEY (nutr_id) REFERENCES nutr_def (id) ON UPDATE CASCADE
);

------------------------------
-- Servings
------------------------------
CREATE TABLE serving_id(
  id SERIAL PRIMARY KEY,
  msre_desc VARCHAR(200) NOT NULL,
  UNIQUE(msre_desc)
);
CREATE TABLE servings(
  food_id INT NOT NULL,
  msre_id INT NOT NULL,
  grams float NOT NULL,
  PRIMARY KEY(food_id, msre_id),
  FOREIGN KEY (food_id) REFERENCES food_des(id) ON UPDATE CASCADE,
  FOREIGN KEY (msre_id) REFERENCES serving_id(id) ON UPDATE CASCADE
);


--++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++
-- Users Database
--++++++++++++++++++++++++++++

------------------------------
-- Custom RDAs
------------------------------
CREATE TABLE rda(
  nutr_id INT NOT NULL,
  user_id INT NOT NULL,
  rda float NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY (user_id, nutr_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE,
  FOREIGN KEY (nutr_id) REFERENCES nutr_def(id) ON UPDATE CASCADE
);

------------------------------
-- Custom recipes
------------------------------
CREATE TABLE recipe_des(
  id SERIAL PRIMARY KEY,
  recipe_name VARCHAR(300) NOT NULL,
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
  amount float NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY (recipe_id, food_id),
  FOREIGN KEY (recipe_id) REFERENCES recipe_des(id) ON UPDATE CASCADE,
  FOREIGN KEY (food_id) REFERENCES food_des(id) ON UPDATE CASCADE
);
-- Recipe Portions
CREATE TABLE portion_id (
  id SERIAL PRIMARY KEY,
  portion_desc VARCHAR(200) NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE(portion_desc)
);
CREATE TABLE portions(
  recipe_id INT NOT NULL,
  portion_id INT NOT NULL,
  percentage float NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY(recipe_id, portion_id),
  FOREIGN KEY (recipe_id) REFERENCES recipe_des(id) ON UPDATE CASCADE,
  FOREIGN KEY (portion_id) REFERENCES portion_id(id) ON UPDATE CASCADE
);

------------------------------
--  Custom Food Tags
------------------------------
-- TODO: Tag pairing data
CREATE TABLE tag_id(
  id SERIAL PRIMARY KEY,
  tag_desc VARCHAR(200) NOT NULL,
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

------------------------------
-- Food logs
------------------------------
CREATE TABLE food_logs(
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  eat_on_date DATE NOT NULL,
  meal_name VARCHAR(20) NOT NULL,
  amount float NOT NULL,
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
  exercise_name VARCHAR(300) NOT NULL,
  user_id INT,
  shared BOOLEAN NOT NULL DEFAULT TRUE,
  cals_per_rep float,
  cals_per_min float,
  -- TODO: data_src_id ?
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
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
  -- timestamp TIMESTAMP DEFAULT NOW() NOT NULL,
  report_type varchar(255) NOT NULL,
  report_message varchar(1024) NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY(user_id, created_at),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);


------------------------------
--++++++++++++++++++++++++++++
-- SHOP
--++++++++++++++++++++++++++++

-- Products
CREATE TABLE products(
  id VARCHAR(255) PRIMARY KEY,
  name VARCHAR(300) NOT NULL,
  image VARCHAR(500) NOT NULL,
  price_min SMALLINT NOT NULL,
  price_max SMALLINT NOT NULL,
  shippable BOOLEAN NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW())
);
-- SKUs
CREATE TABLE skus(
  id VARCHAR(255) PRIMARY KEY,
  product_id VARCHAR(255) NOT NULL,
  name VARCHAR(300) NOT NULL,
  image VARCHAR(500) NOT NULL,
  price SMALLINT NOT NULL,
  inventory_stock SMALLINT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE
);

-- Product orders
CREATE TABLE orders(
  id INT PRIMARY KEY,
  user_id INT NOT NULL,
  tracking_num VARCHAR(200),
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
CREATE TABLE order_items(
  order_id INT NOT NULL,
  product_id VARCHAR(255) NOT NULL,
  quanity SMALLINT NOT NULL,
  UNIQUE(order_id, product_id),
  FOREIGN KEY (order_id) REFERENCES orders(id) ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE
);


-- Product reviews
CREATE TABLE reviews(
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  product_id VARCHAR(255) NOT NULL,
  rating SMALLINT NOT NULL,
  review_text VARCHAR(2000) NOT NULL,
  -- timestamp TIMESTAMP DEFAULT NOW() NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE(user_id, product_id),
  FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
-- Product views
CREATE TABLE views(
  user_id INT NOT NULL,
  product_id VARCHAR(255) NOT NULL,
  -- date DATE DEFAULT NOW() NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  PRIMARY KEY (user_id, product_id),
  FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
-- Cart
CREATE TABLE cart(
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  product_id VARCHAR(255) NOT NULL,
  quanity SMALLINT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE(user_id, product_id),
  FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);

------------------------------
--++++++++++++++++++++++++++++
-- IN PROGRESS
--++++++++++++++++++++++++++++

------------------------------
-- Biometrics
------------------------------
CREATE TABLE biometrics(
  id SERIAL PRIMARY KEY,
  user_id INT,
  biometric_name VARCHAR(200) NOT NULL,
  units VARCHAR(400) NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
CREATE TABLE biometric_logs(
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  biometric_id INT NOT NULL,
  timestamp TIMESTAMP NOT NULL,
  bio_val float NOT NULL,
  unit VARCHAR(40) NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE,
  FOREIGN KEY (biometric_id) REFERENCES biometrics(id) ON UPDATE CASCADE
);

------------------------------
-- Scratchpad
------------------------------
CREATE TABLE scratchpad(
  user_id INT NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE
);
