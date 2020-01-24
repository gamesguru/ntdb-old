CREATE TABLE "Nutrient" (
	"NDB_No" DECIMAL NOT NULL, 
	"Nutrient_Code" DECIMAL NOT NULL, 
	"Nutrient_name" VARCHAR NOT NULL, 
	"Derivation_Code" VARCHAR NOT NULL, 
	"Output_value" DECIMAL NOT NULL, 
	"Output_uom" VARCHAR NOT NULL
);
CREATE TABLE "Products" (
	"NDB_Number" DECIMAL NOT NULL, 
	long_name VARCHAR NOT NULL, 
	data_source VARCHAR NOT NULL, 
	gtin_upc VARCHAR NOT NULL, 
	manufacturer VARCHAR, 
	date_modified VARCHAR NOT NULL, 
	date_available VARCHAR NOT NULL, 
	ingredients_english VARCHAR
);
CREATE TABLE "Serving_Size" (
	"NDB_No" DECIMAL NOT NULL, 
	"Serving_Size" DECIMAL, 
	"Serving_Size_UOM" VARCHAR NOT NULL, 
	"Household_Serving_Size" DECIMAL, 
	"Household_Serving_Size_UOM" VARCHAR, 
	"Preparation_State" VARCHAR
);
