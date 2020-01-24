CREATE TABLE "FD_GROUP" (
	"FdGrp_Cd" DECIMAL NOT NULL, 
	"FdGrp_desc" VARCHAR NOT NULL
);
CREATE TABLE "FOOD_DES" (
	"NDB_No" DECIMAL NOT NULL, 
	"FdGrp_Cd" DECIMAL NOT NULL, 
	"Long_Desc" VARCHAR NOT NULL, 
	"Shrt_Desc" VARCHAR NOT NULL, 
	"Com_Name" VARCHAR, 
	"ManufacName" VARCHAR, 
	"Survey" BOOLEAN, 
	"Ref_Desc" VARCHAR, 
	"Refuse" DECIMAL, 
	"Sci_Name" VARCHAR, 
	"N_FActor" DECIMAL, 
	"Pro_Factor_" DECIMAL, 
	"Fat_Factor_" DECIMAL, 
	"CHO_Factor" DECIMAL
);
CREATE TABLE "NUT_DATA" (
	"NDB_No" DECIMAL NOT NULL, 
	"Nutr_No" DECIMAL NOT NULL, 
	"Nutr_Val" DECIMAL NOT NULL, 
	"Num_Data_Pts" DECIMAL NOT NULL, 
	"Std_Error" DECIMAL, 
	"Src_Cd" DECIMAL NOT NULL, 
	"Deriv_Cd" VARCHAR, 
	"Ref_NDB_No" DECIMAL, 
	"Add_Nutr_Mark" BOOLEAN, 
	"Num_Studies" DECIMAL, 
	"Min" DECIMAL, 
	"Max" DECIMAL, 
	"DF" DECIMAL, 
	"Low_EB" DECIMAL, 
	"Up_EB" DECIMAL, 
	"Stat_Cmt" VARCHAR, 
	"AddMod_Date" DATE
);
CREATE TABLE "NUTR_DEF" (
	"Nutr_no" DECIMAL NOT NULL, 
	"Units" VARCHAR NOT NULL, 
	"Tagname" VARCHAR, 
	"NutrDesc" VARCHAR NOT NULL, 
	"Num_Dec" DECIMAL NOT NULL, 
	"SR_Order" DECIMAL NOT NULL
);
CREATE TABLE "WEIGHT" (
	"NDB_No" DECIMAL NOT NULL, 
	"Seq" DECIMAL NOT NULL, 
	"Amount" DECIMAL NOT NULL, 
	"Msre_Desc" VARCHAR NOT NULL, 
	"Gm_Wgt" DECIMAL NOT NULL, 
	"Num_Data_pts" DECIMAL, 
	"Std_Dev" DECIMAL
);
