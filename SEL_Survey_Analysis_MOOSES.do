*############################################################################### 
*LOAD DATA
*############################################################################### 
import excel "C:\Users\clair\Downloads\SEL_Survey_Analysis_7.17.2020.xlsx", sheet("Outcome Coding") firstrow

*############################################################################### 
*CREATE UNIQUE ID
*############################################################################### 
gen ES_ID = _n

egen Study_ID =group(APA)

*############################################################################### 
*DROP IRRELEVANT COLUMNS & OBSERVATIONS 
*############################################################################### 
drop AD AE AF AG AH AI AJ ReversecodedN Notes Order Descriptionofm SecondReviewer Reviewer StudyNo IncludedinRAND Composite Outcomemeasure Outcomedescri OutcomecategoryCognitiveE WebsiteSubcategory  SelfReport

drop if Grade=="Mixed"
drop if  TypeofMeasure=="Physiological Test"  

*############################################################################### 
*CLEAN MOOSES
*############################################################################### 
rename MOOSESrating1 MOOSES 
replace MOOSES="4" if MOOSES=="4b" | MOOSES=="4a"
replace MOOSES="3" if MOOSES=="3b"
drop if MOOSES!="1" & MOOSES!="2"  & MOOSES!="3"  & MOOSES!="4"  & MOOSES!="5" 
drop if MOOSES=="1" | MOOSES=="2"

*############################################################################### 
*MORE DATA CLEANING  
*############################################################################### 
replace TxCluster="5" if TxCluster=="5 total"
replace TxCluster="1" if TxCluster==""

replace ControlCluster="1" if ControlCluster==""
replace ControlCluster="1" if ControlCluster=="1 (same school)"
replace ControlCluster="5" if ControlCluster=="5 total"

replace Grade="1" if Grade=="Primary"
replace Grade="2" if Grade=="Middle"
replace Grade="3" if Grade=="High" 

*############################################################################### 
*ASSIGN VARIABLES
*############################################################################### 
gen MOOSES_Rating_3 =0
replace MOOSES_Rating_3=1 if MOOSES=="3"

gen MOOSES_Rating_4 =0
replace MOOSES_Rating_4=1 if MOOSES=="4"

gen MOOSES_Rating_5 =0
replace MOOSES_Rating_5=1 if MOOSES=="5"

count if MOOSES_Rating_3
drop MOOSES_Rating_3
drop if MOOSES=="3"
*ONLY TWO MOOSES RATINGS 3, SO DROPPED

gen Student_report=0
replace Student_report=1 if TypeofMeasure=="student-report" | TypeofMeasure=="student self-report" | TypeofMeasure=="student self report" | TypeofMeasure=="student report" | TypeofMeasure=="Student self-report" | TypeofMeasure=="Self-report"

gen Other_report=0
replace Other_report=1 if TypeofMeasure=="parent-report" | TypeofMeasure=="parent self-report" | TypeofMeasure=="parent report" | TypeofMeasure=="Parent self-report" | TypeofMeasure=="parental report" | TypeofMeasure=="parent-report" | TypeofMeasure=="peer-report" | TypeofMeasure=="peer report" | TypeofMeasure=="teacher-report" | TypeofMeasure=="teacher report" | TypeofMeasure== "teaher report" | TypeofMeasure== "teacher self-report" | TypeofMeasure=="Teacher self-report" | TypeofMeasure=="Teacher self report" | TypeofMeasure=="teacher self report" | TypeofMeasure=="teacher/parent report"

gen Standardized_assessment=0
replace Standardized_assessment=1 if TypeofMeasure=="assessment" | TypeofMeasure=="standardized assessment" | TypeofMeasure=="Standardized assessment" | TypeofMeasure=="Standardized test" | TypeofMeasure=="Assessment" | TypeofMeasure=="Standardized assessment" | TypeofMeasure=="observer-report" | TypeofMeasure=="official report" | TypeofMeasure== "observation" | TypeofMeasure=="observation" | TypeofMeasure=="observer-report" | TypeofMeasure=="outside consultant" | TypeofMeasure=="Observation" | TypeofMeasure=="official report" | TypeofMeasure=="school_record" | TypeofMeasure=="school records" | TypeofMeasure=="arrest records" | TypeofMeasure=="school record" 

*############################################################################### 
*CREATE DUMMY VARIABLES
*############################################################################### 

gen Targeted_n = 0
replace Targeted_n=1 if Targeted == "Yes" | Targeted=="Y" | Targeted=="yes"
drop Targeted
rename Targeted_n Targeted 

gen Primary=0
replace Primary=1 if Grade=="1"

gen Middle=0
replace Middle=1 if Grade=="2"

gen High=0
replace High=1 if Grade=="3"

gen Significant_n=0 
replace Significant_n=1 if Significant=="Yes" | Significant=="yes" | Significant=="Y" 
drop Significant
rename Significant_n Significant
drop if Significant==0

replace TypeofMeasure="1" if Other_report==1
replace TypeofMeasure="2" if Student_report==1
replace TypeofMeasure="3" if Standardized_assessment==1
* CANNOT CONTROL FOR RANDOMIZATION BECAUSE NOT CODED

*############################################################################### 
*DESTRING VARIABLES 
*############################################################################### 
destring TxN, gen(TxN_n)
drop TxN
rename TxN_n TxN

destring ControlN, gen(ControlN_n)
drop ControlN
rename ControlN_n ControlN

destring TxCluster, gen(TxCluster_n)
drop TxCluster
rename TxCluster_n TxCluster

destring ControlCluster, gen(ControlCluster_n)
drop ControlCluster
rename ControlCluster_n ControlCluster

destring ES, gen(ES_n) 
drop ES
rename ES_n ES

destring MOOSES, gen(MOOSES_n)
drop MOOSES
rename MOOSES_n MOOSES
replace MOOSES=0 if MOOSES==4
replace MOOSES=1 if MOOSES==5

destring Grade, gen(Grade_n)
drop Grade
rename Grade_n Grade

destring TypeofMeasure, gen(TypeofMeasure_n)
drop TypeofMeasure
rename TypeofMeasure_n TypeofMeasure
*############################################################################### 
*CENTERING VARIABLES
*############################################################################### 
sum MOOSES_Rating_4
gen MOOSES_Rating_4_c=MOOSES_Rating_4 - r(mean)

sum MOOSES_Rating_5
gen MOOSES_Rating_5_c=MOOSES_Rating_5 - r(mean)

sum Targeted
gen Targeted_c=Targeted- r(mean)

sum Primary
gen Primary_c=Primary- r(mean)

sum Middle
gen Middle_c=Middle- r(mean)

sum High
gen High_c=High- r(mean)


sum Student_report
gen Student_report_c=Student_report - r(mean) 

sum Other_report
gen Other_report_c=Other_report - r(mean) 

sum Standardized_assessment
gen Standardized_assessment_c=Standardized_assessment - r(mean)

*############################################################################### 
*TOTAL SAMPLE SIZES
*############################################################################### 
gen Full_Sample = TxN + ControlN
gen Clusters_Total= TxCluster + ControlCluster

*############################################################################### 
*ADJUST ES FOR CLUSTERING
*############################################################################### 
gen TxN_squared=TxN^2
gen Tx_m= TxN/TxCluster
gen Tx_Cluster_summation=Tx_m*TxN_squared
gen Tx_m_df=Tx_m - 1
gen TxN_adjust=TxN_squared- Tx_Cluster_summation/(TxN*Tx_m_df)

gen ControlN_squared=ControlN^2
gen Control_m= ControlN/ControlCluster
gen Control_Cluster_summation=Control_m*ControlN_squared
gen Control_m_df=Control_m-1
gen ControlN_adjust=ControlN_squared- Control_Cluster_summation/(ControlN*Control_m_df)

gen ES_adjusted= ES * sqrt(.8*(Full_Sample-TxN_adjust-ControlN_adjust+TxN_adjust+ControlN_adjust-2)/(Full_Sample-2))

replace Primary=ES_adjusted if Grade==1

replace Middle=ES_adjusted if Grade==2

replace High=ES_adjusted if Grade==3
*############################################################################### 
*CALCULATE VARIANCES
*############################################################################### 
gen ES_prime= ES * (1-(3/(4*Full_Sample-9)))
gen SE = sqrt((Full_Sample/(TxN*ControlN))+(ES_prime)/(2*(Full_Sample)))
drop ES_prime

*############################################################################### 
*ADJUST VARIANCE FOR CLUSTERING
*############################################################################### 

gen Tx_A=(TxN_squared* (Tx_m*TxCluster^2)) + (Tx_m*((TxCluster^2)^2)) - ((2*TxN)*(Tx_m*TxCluster^3))

gen Control_A=(ControlN_squared* (Control_m*ControlCluster^2)) + (Control_m*((ControlCluster^2)^2)) - ((2*ControlN)*(Control_m*ControlCluster^3))

gen A= Tx_A + Control_A
gen B= TxN_adjust*(Tx_m-1) + ControlN_adjust*(Control_m-1)

gen n_tilda_part_1= (ControlN*(Tx_m*(TxCluster^2)))/(TxN*Full_Sample)
gen n_tilda_part_2= (TxN*(Control_m*(ControlCluster^2)))/(ControlN*Full_Sample)
gen n_tilda= n_tilda_part_1 + n_tilda_part_2

gen variance_part_1= (Full_Sample/(TxN*ControlN))*(1+(n_tilda - 1)*.2) 
gen variance_part_2= (((Full_Sample-2)*(.64))+ (A*.64)+(2*B*.2*(.8)))*ES^2
gen variance_part_3= 2*(Full_Sample-2)*((Full_Sample-2)-.2*(Full_Sample-2-B))

gen variance= variance_part_1 + (variance_part_2/variance_part_3)

*############################################################################### 
*DROP IRRELEVANT VARIABLES 
*############################################################################### 
drop TxN_squared Tx_m Tx_Cluster_summation Tx_m_df TxN_adjust ControlN_squared Control_m Control_Cluster_summation Control_m_df ControlN_adjust Tx_A Control_A A B n_tilda_part_1 n_tilda_part_2 n_tilda variance_part_1 variance_part_2 variance_part_3

*############################################################################### 
*DESCRIPTIVE STATISTICS
*############################################################################### 
count if WebsiteCategor=="Academic" & Student_report==1
count if WebsiteCategor=="Emotional Well-being" & Student_report==1
count if WebsiteCategor=="Social Relationships" & Student_report==1
count if WebsiteCategor=="Problem Behaviors" & Student_report==1

count if WebsiteCategor=="Academic" & Other_report==1
count if WebsiteCategor=="Emotional Well-being" & Other_report==1
count if WebsiteCategor=="Social Relationships" & Other_report==1
count if WebsiteCategor=="Problem Behaviors" & Other_report==1

count if WebsiteCategor=="Academic" & Standardized_assessment==1
count if WebsiteCategor=="Emotional Well-being" & Standardized_assessment==1
count if WebsiteCategor=="Social Relationships" & Standardized_assessment==1
count if WebsiteCategor=="Problem Behaviors" & Standardized_assessment==1

count if WebsiteCategor=="Academic" & Targeted==1
count if WebsiteCategor=="Emotional Well-being" & Targeted==1
count if WebsiteCategor=="Social Relationships" & Targeted==1
count if WebsiteCategor=="Problem Behaviors" & Targeted==1

count if WebsiteCategor=="Academic" & Targeted==0
count if WebsiteCategor=="Emotional Well-being" & Targeted==0
count if WebsiteCategor=="Social Relationships" & Targeted==0
count if WebsiteCategor=="Problem Behaviors" & Targeted==0

count if WebsiteCategor=="Academic" & Grade==1
count if WebsiteCategor=="Emotional Well-being" & Grade==1
count if WebsiteCategor=="Social Relationships" & Grade==1
count if WebsiteCategor=="Problem Behaviors" & Grade==1

count if WebsiteCategor=="Academic" & Grade==2
count if WebsiteCategor=="Emotional Well-being" & Grade==2
count if WebsiteCategor=="Social Relationships" & Grade==2
count if WebsiteCategor=="Problem Behaviors" & Grade==2

count if WebsiteCategor=="Academic" & Grade==3
count if WebsiteCategor=="Emotional Well-being" & Grade==3
count if WebsiteCategor=="Social Relationships" & Grade==3
count if WebsiteCategor=="Problem Behaviors" & Grade==3
*############################################################################### 
*CREATE FOUR MODELS
*############################################################################### 
/*
save "C:\Users\clair\Downloads\Survey_Analysis.dta"

keep if WebsiteCategor=="Academic"
save "C:\Users\clair\Downloads\Survey_Analysis_academic.dta"

keep if WebsiteCategor=="Social Relationships"
save "C:\Users\clair\Downloads\Survey_Analysis_social.dta"

keep if WebsiteCategor=="Emotional Well-being"
save "C:\Users\clair\Downloads\Survey_Analysis_emotional.dta"
*/
keep if WebsiteCategor=="Problem Behaviors"
save "C:\Users\clair\Downloads\Survey_Analysis_problem.dta"

*############################################################################### 
*CREATE TABLES - CHANGE WITHIN DOC
*############################################################################### 
* For table template
*asdoc pwcorr Middle Significant Targeted TxCluster TxN ControlCluster ControlN, replace


