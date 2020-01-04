-- init schemas
CREATE SCHEMA data;
CREATE SCHEMA users;
CREATE SCHEMA shop;


-- Main users table --
CREATE TABLE users.users(
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(8) NOT NULL,
    passwd VARCHAR(300) NOT NULL,
    unverified_email VARCHAR(140),
    email VARCHAR(140),
    email_token_activate VARCHAR(200),
    email_token_pw_reset VARCHAR(200),
    -- accept_eula BOOLEAN NOT NULL DEFAULT FALSE,
    -- stripe_id VARCHAR(200) NOT NULL,
    -- certified_beta_tester BOOLEAN DEFAULT FALSE,
    -- certified_beta_trainer_tester BOOLEAN DEFAULT FALSE,
    -- passed_onboarding_tutorial BOOLEAN DEFAULT FALSE,
    -- gender VARCHAR(20),
    -- name VARCHAR(90),
    -- dob DATE,
    -- height SMALLINT,
    -- height_units VARCHAR(2),
    -- weight SMALLINT,
    -- weight_units VARCHAR(3),
    -- activity_level SMALLINT,
    -- weight_goal SMALLINT,
    -- bmr_equation SMALLINT,
    -- bodyfat_method SMALLINT,
    UNIQUE(username),
    UNIQUE(email),
    UNIQUE(unverified_email)
);



--              --
--     DATA     --
--              --

-- Nutrient definitions --
CREATE TABLE data.nutr_def(
    nutr_no INT PRIMARY KEY,
    rda float,
    units VARCHAR(10) ,
    is_anti BOOLEAN NOT NULL,
    tagname VARCHAR(10) NOT NULL,
    nutr_desc VARCHAR(80) NOT NULL,
    user_id BIGINT,
    shared BOOLEAN NOT NULL,
    -- weighting?
    UNIQUE (tagname),
    FOREIGN KEY (user_id) REFERENCES users.users (user_id)
);


-- Food groups, Custom Food Tags, and Data sources --
CREATE TABLE data.fdgrp(
    fdgrp_id INT PRIMARY KEY,
    fdgrp_desc VARCHAR(200),
    UNIQUE(fdgrp_desc)
);
CREATE TABLE data.tag_id(
    tag_id BIGSERIAL PRIMARY KEY,
    tag_desc VARCHAR(200) NOT NULL,
    shared BOOLEAN DEFAULT TRUE NOT NULL,
    approved BOOLEAN DEFAULT FALSE NOT NULL,
    UNIQUE(tag_desc)
);
CREATE TABLE data.data_src(
    data_src_id INT PRIMARY KEY,
    data_src VARCHAR(10) NOT NULL,
    searchable BOOLEAN NOT NULL,
    UNIQUE(data_src)
);


-- Food names --
CREATE TABLE data.food_des(
    food_id BIGSERIAL PRIMARY KEY,
    fdgrp_id INT NOT NULL,
    data_src_id INT NOT NULL,
    long_desc VARCHAR(400) NOT NULL,
    gtin_UPC DECIMAL,
    manufacturer VARCHAR(280),
    ingredients TEXT,
    ref_desc VARCHAR(150),
    refuse INT,
    user_id INT,
    shared BOOLEAN DEFAULT TRUE,
    -- UNIQUE(gtin_UPC),
    FOREIGN KEY (user_id) REFERENCES users.users (user_id),
    FOREIGN KEY (fdgrp_id) REFERENCES data.fdgrp(fdgrp_id),
    FOREIGN KEY (data_src_id) REFERENCES data.data_src(data_src_id)
);
-- Food tags --
CREATE TABLE data.tag_data(
    food_id BIGINT NOT NULL,
    tag_id BIGINT NOT NULL,
    -- votes, approved?
    PRIMARY KEY (food_id, tag_id),
    FOREIGN KEY (food_id) REFERENCES data.food_des(food_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES data.tag_id (tag_id)
);
-- Food Nutrient data --
CREATE TABLE data.nut_data(
    food_id BIGINT NOT NULL,
    nutr_no INT NOT NULL,
    nutr_val float,
    data_src_id INT NOT NULL,
    PRIMARY KEY (food_id, nutr_no, data_src_id),
    FOREIGN KEY (food_id) REFERENCES data.food_des(food_id) ON DELETE CASCADE,
    FOREIGN KEY (nutr_no) REFERENCES data.nutr_def(nutr_no),
    FOREIGN KEY (data_src_id) REFERENCES data.data_src(data_src_id)
);


-- Servings --
CREATE TABLE data.serving_id(
    msre_id BIGSERIAL PRIMARY KEY,
    msre_desc VARCHAR(200) NOT NULL,
    UNIQUE(msre_desc)
);
CREATE TABLE data.serving(
    food_id BIGINT NOT NULL,
    msre_id BIGINT NOT NULL,
    grams float NOT NULL,
    PRIMARY KEY(food_id, msre_id),
    FOREIGN KEY (food_id) REFERENCES data.food_des(food_id) ON DELETE CASCADE,
    FOREIGN KEY (msre_id) REFERENCES data.serving_id(msre_id)
);



--             --
--    USERS    --
--             --

-- Custom RDAs --
CREATE TABLE users.rda(
    user_id INT NOT NULL,
    nutr_no INT NOT NULL,
    rda float NOT NULL,
    PRIMARY KEY (user_id, nutr_no),
    FOREIGN KEY (nutr_no) REFERENCES data.nutr_def(nutr_no),
    FOREIGN KEY (user_id) REFERENCES users.users(user_id)
);



-- Custom recipes --
CREATE TABLE users.recipe_des(
    recipe_id BIGSERIAL PRIMARY KEY,
    recipe_name VARCHAR(300) NOT NULL,
    user_id INT NOT NULL,
    shared BOOLEAN NOT NULL, -- publicly shared ? --
    FOREIGN KEY (user_id) REFERENCES users.users(user_id)
);
CREATE TABLE users.recipe_dat(
    recipe_id BIGINT NOT NULL,
    food_id BIGINT NOT NULL,
    msre_id BIGINT,  -- (NULL || 0 => grams)
    amount float NOT NULL,
    PRIMARY KEY (recipe_id, food_id),
    FOREIGN KEY (recipe_id) REFERENCES users.recipe_des(recipe_id) ON DELETE CASCADE
);
-- Recipe Portions --
CREATE TABLE users.portion_id (
    portion_id BIGSERIAL PRIMARY KEY,
    portion_desc VARCHAR(200) NOT NULL,
    UNIQUE(portion_desc)
);
CREATE TABLE users.portions(
    recipe_id BIGINT NOT NULL,
    portion_id BIGINT NOT NULL,
    percentage float NOT NULL,
    PRIMARY KEY(recipe_id, portion_id),
    FOREIGN KEY (recipe_id) REFERENCES users.recipe_des(recipe_id) ON DELETE CASCADE,
    FOREIGN KEY (portion_id) REFERENCES users.portion_id(portion_id)
);



-- Custom Fields --
CREATE TABLE users.field_des(
    field_id BIGSERIAL PRIMARY KEY,
    source_id INT NOT NULL,
    field_name VARCHAR(300) NOT NULL,
    user_id INT,
    shared BOOLEAN NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users.users(user_id),
    FOREIGN KEY (source_id) REFERENCES data.data_src(data_src_id)
);
CREATE TABLE users.field_dat(
    field_id BIGINT NOT NULL,
    nutr_no INT NOT NULL,
    nutr_val float NOT NULL,
    PRIMARY KEY (field_id, nutr_no),
    FOREIGN KEY (nutr_no) REFERENCES data.nutr_def(nutr_no),
    FOREIGN KEY (field_id) REFERENCES users.field_des(field_id)
);
CREATE TABLE users.field_pairs(
    field_id BIGINT NOT NULL,
    food_id BIGINT NOT NULL,
    PRIMARY KEY (field_id, food_id),
    FOREIGN KEY (food_id) REFERENCES data.food_des(food_id),
    FOREIGN KEY (field_id) REFERENCES users.field_des(field_id)
);
CREATE TABLE users.field_user_votes(
    field_id BIGINT NOT NULL,
    food_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    vote BOOLEAN,  -- NULL is 0, false is -1, and true is 1
    PRIMARY KEY (field_id, food_id, user_id),
    FOREIGN KEY (field_id) REFERENCES users.field_des(field_id),
    FOREIGN KEY (food_id) REFERENCES data.food_des(food_id),
    FOREIGN KEY (user_id) REFERENCES users.users(user_id)
);
-- User verification (upvote vs. downvotes) --
CREATE TABLE users.food_dat_confirmation(
    user_id INT NOT NULL,
    food_id BIGINT NOT NULL,
    nutr_no INT NOT NULL,
    vote BOOL,  -- NULL is 0, false is -1, and true is 1
    PRIMARY KEY (user_id, food_id, nutr_no),
    FOREIGN KEY (user_id) REFERENCES users.users(user_id),
    FOREIGN KEY (food_id) REFERENCES data.food_des(food_id),
    FOREIGN KEY (nutr_no) REFERENCES data.nutr_def(nutr_no)
);



-- Favorite foods --
CREATE TABLE users.favorite_foods(
    user_id INT NOT NULL,
    food_id BIGINT NOT NULL,
    PRIMARY KEY(user_id, food_id),
    FOREIGN KEY (user_id) REFERENCES users.users(user_id),
    FOREIGN KEY (food_id) REFERENCES data.food_des(food_id)
);



-- Food logs --
CREATE TABLE users.logs(
    log_id BIGSERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    eat_on_date DATE NOT NULL,
    meal_name VARCHAR(20) NOT NULL,
    amount float NOT NULL,
    msre_id BIGINT,
    recipe_id BIGINT,
    food_id BIGINT,
    FOREIGN KEY (user_id) REFERENCES users.users(user_id),
    FOREIGN KEY (msre_id) REFERENCES data.serving_id(msre_id),
    FOREIGN KEY (recipe_id) REFERENCES users.recipe_des(recipe_id),
    FOREIGN KEY (food_id) REFERENCES data.food_des(food_id)
);



-- Exercise logs --
CREATE TABLE users.exercises(
    exercise_id BIGSERIAL PRIMARY KEY,
    exercise_name VARCHAR(300) NOT NULL,
    user_id INT,
    shared BOOLEAN NOT NULL DEFAULT TRUE,
    cals_per_rep float,
    cals_per_min float,
    data_src_id INT DEFAULT 5,  -- NTDB_DATA_SRC_ID,
    FOREIGN KEY (data_src_id) REFERENCES data.data_src(data_src_id),
    FOREIGN KEY (user_id) REFERENCES users.users(user_id)
);
CREATE TABLE users.exercise_logs(
    log_id BIGSERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    exercise_id BIGINT NOT NULL,
    date DATE NOT NULL,
    reps INT,
    weight INT,
    duration_min INT,
    FOREIGN KEY (user_id) REFERENCES users.users(user_id),
    FOREIGN KEY (exercise_id) REFERENCES users.exercises(exercise_id)
);



-- Trainer Roles --
CREATE TABLE users.trainer_users(
    trainer_id INT NOT NULL,
    user_id INT NOT NULL,
    approved BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (trainer_id) REFERENCES users.users(user_id),
    FOREIGN KEY (user_id) REFERENCES users.users(user_id),
    UNIQUE(trainer_id, user_id)
);



-- User reports --
CREATE TABLE users.report( --rename to reports
    user_id INT NOT NULL,
    timestamp TIMESTAMP DEFAULT NOW() NOT NULL,
    report_type varchar(255) NOT NULL,
    report_message varchar(1024) NOT NULL,
    PRIMARY KEY(user_id, timestamp),
    FOREIGN KEY (user_id) REFERENCES users.users(user_id)
);

--             --
-- IN PROGRESS --
--             --

-- Biometrics --
CREATE TABLE users.biometrics(
    biometric_id BIGSERIAL PRIMARY KEY,
    user_id INT,
    biometric_name VARCHAR(200) NOT NULL,
    units VARCHAR(400) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users.users(user_id)
);
CREATE TABLE users.biometric_logs(
    log_id BIGSERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    biometric_id BIGINT NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    bio_val float NOT NULL,
    unit VARCHAR(40) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users.users(user_id),
    FOREIGN KEY (biometric_id) REFERENCES users.biometrics(biometric_id)
);



-- Scratchpad --
CREATE TABLE users.scratchpad(
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users.users(user_id)
);




--              --
--     SHOP     --
--              --

-- Product orders --
CREATE TABLE shop.orders(
    stripe_order_id VARCHAR(300) PRIMARY KEY,
    user_id INT NOT NULL,
    tracking_num VARCHAR(200),
    FOREIGN KEY (user_id) REFERENCES users.users(user_id)
);
-- Product reviews --
CREATE TABLE shop.reviews(
    review_id BIGSERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    stripe_product_id VARCHAR(255) NOT NULL,
    rating SMALLINT NOT NULL,
    review_text VARCHAR(2000) NOT NULL,
    timestamp TIMESTAMP DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, stripe_product_id),
    FOREIGN KEY (user_id) REFERENCES users.users(user_id)
);
-- Product views --
CREATE TABLE shop.views(
    user_id INT NOT NULL,
    stripe_product_id VARCHAR(255) NOT NULL,
    date DATE DEFAULT NOW() NOT NULL,
    PRIMARY KEY (user_id, stripe_product_id),
    FOREIGN KEY (user_id) REFERENCES users.users(user_id)
);
-- Products in cart --
CREATE TABLE shop.cart(
    cart_id BIGSERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    stripe_product_id VARCHAR(255) NOT NULL,
    quanity SMALLINT NOT NULL,
    UNIQUE(user_id, stripe_product_id),
    FOREIGN KEY (user_id) REFERENCES users.users(user_id)
);
