CREATE TABLE "NUTRIENT AMOUNT" (
	"FoodID" DECIMAL NOT NULL, 
	"NutrientID" DECIMAL NOT NULL, 
	"NutrientValue" DECIMAL NOT NULL, 
	"StandardError" DECIMAL, 
	"NumberofObservations" DECIMAL, 
	"NutrientSourceID" DECIMAL NOT NULL, 
	"NutrientDateOfEntry" DATE NOT NULL
);
CREATE TABLE "FOOD NAME" (
	"FoodID" DECIMAL NOT NULL, 
	"FoodCode" DECIMAL NOT NULL, 
	"FoodGroupID" DECIMAL NOT NULL, 
	"FoodSourceID" DECIMAL NOT NULL, 
	"FoodDescription" VARCHAR NOT NULL, 
	"FoodDescriptionF" VARCHAR NOT NULL, 
	"FoodDateOfEntry" DATE NOT NULL, 
	"FoodDateOfPublication" DATE, 
	"CountryCode" DECIMAL, 
	"ScientificName" VARCHAR
);
CREATE TABLE "CONVERSION FACTOR" (
	"FoodID" DECIMAL NOT NULL, 
	"MeasureID" DECIMAL NOT NULL, 
	"ConversionFactorValue" DECIMAL NOT NULL, 
	"ConvFactorDateOfEntry" DATE NOT NULL
);
CREATE TABLE "MEASURE NAME" (
	"MeasureID" DECIMAL NOT NULL, 
	"MeasureDescription" VARCHAR NOT NULL, 
	"MeasureDescriptionF" VARCHAR NOT NULL, 
	d BOOLEAN, 
	e BOOLEAN
);
CREATE TABLE "NUTRIENT NAME" (
	"NutrientID" DECIMAL NOT NULL, 
	"NutrientCode" DECIMAL NOT NULL, 
	"NutrientSymbol" VARCHAR, 
	"NutrientUnit" VARCHAR NOT NULL, 
	"NutrientName" VARCHAR NOT NULL, 
	"NutrientNameF" VARCHAR NOT NULL, 
	"Tagname" VARCHAR, 
	"NutrientDecimals" DECIMAL NOT NULL
);
CREATE TABLE "FOOD GROUP" (
	"FoodGroupID" DECIMAL NOT NULL, 
	"FoodGroupCode" DECIMAL NOT NULL, 
	"FoodGroupName" VARCHAR NOT NULL, 
	"FoodGroupNameF" VARCHAR NOT NULL
);
