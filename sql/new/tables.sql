DROP SCHEMA cz CASCADE;
CREATE SCHEMA cz;
SET search_path TO cz;

---------------------
-- Solvers & Sims
---------------------
CREATE TABLE solvers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(20) NOT NULL,
  tag VARCHAR(8) NOT NULL,
  UNIQUE (tag)
);
CREATE TABLE simulators (
  id SERIAL PRIMARY KEY,
  name VARCHAR(20) NOT NULL,
  tag VARCHAR(8) NOT NULL,
  authors VARCHAR[] NOT NULL,
  UNIQUE (tag)
);

------------------------------
-- Event types
------------------------------
CREATE TABLE event_types (
  id SMALLINT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  simulator_id INT NOT NULL,
  FOREIGN KEY (simulator_id) REFERENCES simulators (id) ON UPDATE CASCADE
);
-- TODO: do we need these anymore?
CREATE TABLE action_types (
  id SMALLINT PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  simulator_id INT NOT NULL,
  FOREIGN KEY (simulator_id) REFERENCES simulators (id) ON UPDATE CASCADE
);
------------------------------
-- Parameters
------------------------------
CREATE TABLE param_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  type VARCHAR(200) NOT NULL,
  -- TODO: should this support multiple solvers?
  solver_id INT,
  FOREIGN KEY (solver_id) REFERENCES solvers (id) ON UPDATE CASCADE
);

-----------------
-- Tenants
-----------------
CREATE TABLE tenants (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  -- Should be user's Ford CDSID
  username VARCHAR(8) NOT NULL,
  passwd VARCHAR(500),
  unverified_email VARCHAR(140),
  email VARCHAR(140),
  email_token_activate VARCHAR(200),
  email_token_pw_reset VARCHAR(200),
  UNIQUE (name),
  UNIQUE (username),
  UNIQUE (email),
  UNIQUE (unverified_email)
);

CREATE TABLE tenant_solvers (
  tenant_id INT NOT NULL,
  solver_id INT NOT NULL,
  UNIQUE (tenant_id, solver_id),
  FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON UPDATE CASCADE,
  FOREIGN KEY (solver_id) REFERENCES solvers (id) ON UPDATE CASCADE
);
-----------------
-- Clients
-----------------
CREATE TABLE clients (
  id BIGSERIAL PRIMARY KEY,
  tenant_id INT NOT NULL,
  name VARCHAR(200),
  UNIQUE (tenant_id, name),
  FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON UPDATE CASCADE
);

--------------------------------
-- (Synthetic) Data Set IDs
--------------------------------
CREATE TABLE req_srcs (
  id BIGSERIAL PRIMARY KEY,
  tenant_id INT NOT NULL,
  is_synthetic BOOLEAN NOT NULL,
  name VARCHAR(200) NOT NULL,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  UNIQUE (tenant_id, name),
  FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON UPDATE CASCADE
);

------------------------------
-- Scenario descriptions
------------------------------
CREATE TABLE scen_descs (
  id BIGINT PRIMARY KEY DEFAULT (random()*9*10^18),
  tenant_id INT NOT NULL,
  client_id BIGINT,
  title VARCHAR(200) NOT NULL,
  description VARCHAR(200),
  created_at INT DEFAULT extract(epoch FROM NOW()),
  -- Parameters
  time_traffic INT,
  cost_matrix SMALLINT[][],
  idle_policy VARCHAR(100) DEFAULT 'DEPOT',
  allow_veh_reassign BOOLEAN NOT NULL,
  encourage_sharing BOOLEAN NOT NULL,
  -- RIDE_HAIL=min(completion_time + transport_time) ... GOODS=min(transport_time)
  -- see: https://docs.graphhopper.com/#operation/solveVRP/body/json/objectives/type
  -- TODO: put four objective function values
  optimize_config VARCHAR(100) NOT NULL,
  -- @Override params
  duration_load INT NOT NULL,
  duration_unload INT NOT NULL,
  allowed_lateness INT NOT NULL,
  time_open INT NOT NULL,
  time_close INT NOT NULL,
  compan_perc float NOT NULL,
  FOREIGN KEY (client_id) REFERENCES clients (id) ON UPDATE CASCADE,
  FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON UPDATE CASCADE
);

-- Solvers
CREATE TABLE scend_solvers (
  scen_desc_id BIGINT NOT NULL,
  solver_id INT NOT NULL,
  UNIQUE (scen_desc_id, solver_id),
  FOREIGN KEY (scen_desc_id) REFERENCES scen_descs (id) ON UPDATE CASCADE,
  FOREIGN KEY (solver_id) REFERENCES solvers (id) ON UPDATE CASCADE
);
------------------------------
-- Scenarios (clones)
------------------------------
CREATE TABLE scens (
  id BIGINT PRIMARY KEY DEFAULT (random()*9*10^18),
  client_id BIGINT,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  -- @Override: scen_descs.*
  title VARCHAR(200),
  description VARCHAR(200),
  -- @Override: params
  cost_matrix SMALLINT[][],
  time_traffic INT,
  idle_policy VARCHAR(100),
  allow_veh_reassign BOOLEAN,
  encourage_sharing BOOLEAN,
  optimize_config VARCHAR(100),
  duration_load INT,
  duration_unload INT,
  allowed_lateness INT,
  time_open INT,
  time_close INT,
  compan_perc float,
  FOREIGN KEY (client_id) REFERENCES clients (id) ON UPDATE CASCADE
);

-- Params
CREATE TABLE scen_params (
  scen_id BIGINT NOT NULL,
  --@Override: scen_id
  scen_desc_id BIGINT,
  param_type_id INT NOT NULL,
  value float NOT NULL,
  step_size BIGINT,
  stop_value BIGINT,
  FOREIGN KEY (scen_id) REFERENCES scens (id) ON UPDATE CASCADE,
  FOREIGN KEY (scen_desc_id) REFERENCES scen_descs (id) ON UPDATE CASCADE,
  FOREIGN KEY (param_type_id) REFERENCES param_types (id) ON UPDATE CASCADE
);

------------------------------
-- Customer requests
------------------------------
CREATE TABLE reqs (
  id DECIMAL PRIMARY KEY,
  src_id INT NOT NULL,
  name VARCHAR(300),
  scen_id BIGINT,
  --@Override: scen_id
  scen_desc_id BIGINT,
  -- Waypoints
  orig_lat float NOT NULL,
  orig_lon float NOT NULL,
  dest_lat float,
  dest_lon float,
  -- Timing windows (inherits from scens.lateness)
  time_pu_beg INT NOT NULL,
  time_pu_end INT,
  time_do_beg INT,
  time_do_end INT,
  -- Constraints
  capacities float[] NOT NULL,
  private_ride BOOLEAN DEFAULT FALSE,
  duration_load INT,
  duration_unload INT,
  FOREIGN KEY (src_id) REFERENCES req_srcs (id) ON UPDATE CASCADE,
  FOREIGN KEY (scen_id) REFERENCES scens (id) ON UPDATE CASCADE,
  FOREIGN KEY (scen_desc_id) REFERENCES scen_descs (id) ON UPDATE CASCADE
);

------------------------------
-- Simulation Runs
------------------------------
CREATE TABLE runs (
  id BIGINT PRIMARY KEY DEFAULT (random()*9*10^18),
  scen_id BIGINT NOT NULL,
  name VARCHAR(200),
  status VARCHAR(200) DEFAULT 'CREATED',
  created_at INT DEFAULT extract(epoch FROM NOW()),
  finished_at INT,
  hpc_base_directory VARCHAR(300),
  output_content TEXT,
  FOREIGN KEY (scen_id) REFERENCES scens (id) ON UPDATE CASCADE
);

-- Params
CREATE TABLE run_params (
  run_id BIGINT NOT NULL,
  param_type_id INT NOT NULL,
  value float NOT NULL,
  UNIQUE (run_id, param_type_id),
  FOREIGN KEY (run_id) REFERENCES runs (id) ON UPDATE CASCADE,
  FOREIGN KEY (param_type_id) REFERENCES param_types (id) ON UPDATE CASCADE
);
------------------------------
-- OutputFiles (KPIs, playback, etc)
------------------------------
CREATE TABLE files (
  id BIGSERIAL PRIMARY KEY,
  run_id BIGINT NOT NULL,
  filename VARCHAR(300),
  hpc_filepath VARCHAR(300),
  s3_key VARCHAR(500),
  FOREIGN KEY (run_id) REFERENCES runs (id) ON UPDATE CASCADE
);

------------------------------
-- Depots
------------------------------
CREATE TABLE depots (
  id BIGSERIAL PRIMARY KEY,
  scen_id BIGINT NOT NULL,
  tenant_id INT NOT NULL,
  --@Override: scen_id
  scen_desc_id BIGINT,
  lat float NOT NULL,
  lon float NOT NULL,
  -- Optional fields
  name VARCHAR(200),
  city VARCHAR(200),
  state VARCHAR(200),
  street VARCHAR(200),
  zip VARCHAR(20),
  -- Unused fields
  time_open INT,
  time_close INT,
  capacity INT,
  FOREIGN KEY (scen_id) REFERENCES scens (id) ON UPDATE CASCADE,
  FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON UPDATE CASCADE,
  FOREIGN KEY (scen_desc_id) REFERENCES scen_descs (id) ON UPDATE CASCADE
);
------------------------------
-- Vehicles
------------------------------
CREATE TABLE veh_types(
  id BIGSERIAL PRIMARY KEY,
  tenant_id INT NOT NULL,
  profile VARCHAR(100) NOT NULL,
  capacities float[] NOT NULL,
  -- TODO: @Override scenario or tenant?
  cost_minimum float NOT NULL,
  cost_per_meter float NOT NULL,
  cost_per_second float NOT NULL,
  cost_per_activation float NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON UPDATE CASCADE
);

-- Vehicles
CREATE TABLE vehicles (
  id BIGINT PRIMARY KEY DEFAULT (random()*9*10^18),
  type_id BIGINT NOT NULL,
  scen_id BIGINT NOT NULL,
  --@Override: scen_id
  scen_desc_id BIGINT,
  depot_id BIGINT NOT NULL,
  -- @Override default to depot
  time_open INT,
  time_close INT,
  orig_lat float,
  orig_lon float,
  dest_lat float,
  dest_lon float,
  -- Constraints and costs
  max_meters INT,
  -- @Override default to vehicle_type
  capacities float[],
  cost_minimum float,
  cost_per_meter float,
  cost_per_second float,
  cost_per_activation float,
  FOREIGN KEY (type_id) REFERENCES veh_types (id) ON UPDATE CASCADE,
  FOREIGN KEY (scen_id) REFERENCES scens (id) ON UPDATE CASCADE,
  FOREIGN KEY (scen_desc_id) REFERENCES scen_descs (id) ON UPDATE CASCADE,
  FOREIGN KEY (depot_id) REFERENCES depots (id) ON UPDATE CASCADE
);
-----------------------------
-- Blacklisted vehicles
-----------------------------
CREATE TABLE req_veh_blist (
  -- @Clonable
  scen_desc_id BIGINT,
  req_id BIGINT NOT NULL,
  vehicle_id BIGINT NOT NULL,
  FOREIGN KEY (scen_desc_id) REFERENCES scen_descs (id) ON UPDATE CASCADE,
  FOREIGN KEY (req_id) REFERENCES reqs (id) ON UPDATE CASCADE,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON UPDATE CASCADE
);

------------------------------
-- Events
------------------------------
CREATE TABLE events (
  event_type_id SMALLINT NOT NULL,
  run_id BIGINT NOT NULL,
  veh_id BIGINT,
  req_id BIGINT,
  created_at INT DEFAULT extract(epoch FROM NOW()),
  -- TODO: which should be NOT NULL ?
  -- TODO: should we mix rider & vehicle ?
  -- TODO: should we use sim_time at all?
  creation_time BIGINT NOT NULL,
  sim_time BIGINT NOT NULL,
  action_type_id SMALLINT,
  capacities float[],
  lat float,
  lon float,
  -- TODO: do we need this?  Only potentially bulky thing on here
  ride_request JSON,
  -- TODO: ask Max, do we need these two at all?  sim_time?
  offer_id INT,
  action_id INT,
  FOREIGN KEY (event_type_id) REFERENCES event_types (id) ON UPDATE CASCADE,
  FOREIGN KEY (action_type_id) REFERENCES action_types (id) ON UPDATE CASCADE,
  FOREIGN KEY (run_id) REFERENCES runs (id) ON UPDATE CASCADE,
  FOREIGN KEY (veh_id) REFERENCES vehicles (id) ON UPDATE CASCADE,
  FOREIGN KEY (req_id) REFERENCES reqs (id) ON UPDATE CASCADE
);
