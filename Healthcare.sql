create database Healthcare_Analysis;
use Healthcare_Analysis;

CREATE TABLE patients (
Patient_ID	int DEFAULT NULL,
First_Name	text,
Last_Name	text,
Gender	text,
Date_Of_Birth	date DEFAULT NULL,
Age	int DEFAULT NULL,
Blood_Type	text,
Phone_Number	varchar(50),
Alternate_Phone_Number	varchar(50),
Address	 text,
State	text,
City	text,
Country	text,
Insurance_Provider	text,
Policy_Number	text,
Marital_Status	text,
Race	text,
Ethnicity	text,
Chronic_Conditions	text,
Allergies	text,
Medical_History	  text,
Patient_Status	text,
Registration_Date	date DEFAULT NULL,
Emergency_Contact_Name	varchar(50),
Emergency_Contact_Phone varchar(50)
) ;

SET NAMES utf8mb4;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Patient.csv'
INTO TABLE patients
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from patients;

CREATE TABLE treatment (
Treatment_ID	int DEFAULT NULL,
Visit_ID	int DEFAULT NULL,
Treatment_Type	text,
Treatment_Name	text,
Medication_Prescribed	text,
Dosage	text,
Instructions	text,
Treatment_Start_Date	date DEFAULT NULL,
Treatment_End_Date	date DEFAULT NULL,
Duration_Days	int DEFAULT NULL,
Status	text,
Outcome	 text,
Direct_Treatment_Cost 	int DEFAULT NULL,
Total_Episode_Cost	int DEFAULT NULL,
Treatment_Description  text
) ;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Treatment.csv'
INTO TABLE treatment
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from treatment;

CREATE TABLE Visit (
Visit_ID	int DEFAULT NULL,
Patient_ID	int DEFAULT NULL,
Doctor_ID	int DEFAULT NULL,
Visit_Date	date DEFAULT NULL,
Visit_Year	int DEFAULT NULL,
Visit_Month	 int DEFAULT NULL,
Visit_Month_Name	text,
Visit_Quarter	int DEFAULT NULL,
Visit_Type	text,
Visit_Status	text,
Diagnosis	text,
Diagnosis_Code	text,
Reason_for_Visit	text,
Follow_Up_Required	text,
Prescribed_Medications	text,
Visit_Duration_Minutes  int DEFAULT NULL
) ;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Visit.csv'
INTO TABLE Visit
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from Visit;

CREATE TABLE Billing (
Bill_ID	int DEFAULT NULL,
Visit_ID	int DEFAULT NULL,
Patient_ID	int DEFAULT NULL,
Amount_Billed_Dollar	int DEFAULT NULL,
Insurance_Covered_Dollar	int DEFAULT NULL,
Patient_Paid_Dollar	int DEFAULT NULL,
Outstanding_Dollar	int DEFAULT NULL,
Payment_Status	text,
Bill_Date	date DEFAULT NULL,
Payment_Date  date DEFAULT NULL
) ;


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Billing.csv'
INTO TABLE Billing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Bill_ID, Visit_ID, Patient_ID, 
Amount_Billed_Dollar, Insurance_Covered_Dollar, Patient_Paid_Dollar, Outstanding_Dollar, Payment_Status, Bill_Date, @payment_date)
SET Payment_Date = NULLIF(@payment_date, '');

select * from Billing;

CREATE TABLE Department (
Department_ID	int DEFAULT NULL,
Department_Name	text,
Specialty_Covered	text,
Location	text,
Department_Type  text
) ;


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Department.csv'
INTO TABLE Department 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from Department ;

CREATE TABLE Doctor (
Doctor_ID	int DEFAULT NULL,
Doctor_Name	text,
Gender	text,
Specialty	text,
Department_ID	int DEFAULT NULL,
Years_Of_Experience	 int DEFAULT NULL,
Hospital_Affiliation	text,
Clinic_Name	text,
Phone_Number	varchar(50),
Email	text,
License_Number	text,
Is_Active  text
) ;


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Doctor.csv'
INTO TABLE Doctor 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from Doctor ;

CREATE TABLE LabTest (
Lab_Result_ID	int DEFAULT NULL,
Visit_ID	int DEFAULT NULL,
Ordered_By_DoctorID	 int DEFAULT NULL,
Test_Name	text,
Test_Date	date DEFAULT NULL,
Test_Year	int DEFAULT NULL,
Test_Month	int DEFAULT NULL,
Test_Month_Name	text,
Test_Result	text,
Numeric_Result_Value int DEFAULT NULL,
Units	text,
Reference_Range	text,
Comments text
) ;


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\LabTest.csv'
INTO TABLE LabTest 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Lab_Result_ID,	Visit_ID,	Ordered_By_DoctorID,	Test_Name,	Test_Date,	Test_Year,	Test_Month,	Test_Month_Name,	
Test_Result,	@Numeric_Result_Value,	Units,	Reference_Range,	Comments) -- List all your columns here
SET Numeric_Result_Value = NULLIF(@numeric_Result_Value, '');

select * from LabTest;

#KPI-1
#Total Patients
SELECT COUNT(*) AS Total_Patients
FROM patients;

#KPI-2
#Total Doctors
SELECT COUNT(*) AS Total_Doctors
FROM Doctor;

#KPI-3
#Total Visit
SELECT COUNT(*) AS Total_Visits
FROM Visit;

#KPI-4
#Average age of Patients
SELECT AVG(Age) AS Average_Age
FROM patients;

#KPI-5
# Top 5 Diagnosed Conditions
SELECT 
    Diagnosis,
    COUNT(*) AS Total_Cases
FROM Visit
GROUP BY Diagnosis
ORDER BY Total_Cases DESC
LIMIT 5;

#KPI-6
#Follow-up Rate
SELECT 
    (SUM(CASE WHEN Follow_Up_Required = 'Yes' THEN 1 ELSE 0 END) * 100.0 
     / COUNT(*)) AS Follow_Up_Rate_Percentage
FROM Visit;

#KPI-7
#Treatment Cost per Visit
SELECT 
    Visit_ID,
    SUM(Direct_Treatment_Cost) AS Total_Treatment_Cost_Per_Visit,
    SUM(Total_Episode_Cost) AS Total_Episode_Cost_Per_Visit
FROM treatment
GROUP BY Visit_ID;

#KPI-8
#Total Lab Test Conducted
SELECT COUNT(*) AS Total_Lab_Tests_Conducted
FROM LabTest;

#KPI-9
#Percentage of Abnormal Results
SELECT 
    (SUM(CASE WHEN Test_Result = 'Abnormal' THEN 1 ELSE 0 END) * 100.0 
     / COUNT(*)) AS Percentage_Abnormal_Results
FROM LabTest;

#KPI-10
#Doctor Workload
SELECT 
    Doctor_ID,
    COUNT(*) AS Total_Visits
FROM Visit
GROUP BY Doctor_ID
ORDER BY Total_Visits DESC;

#KPI-11
#Gender wise Patients
SELECT 
    Gender,
    COUNT(*) AS Total_Patients
FROM patients
GROUP BY Gender;

#KPI-12
#Gender wise Diagnosis
SELECT 
    p.Gender,
    v.Diagnosis,
    COUNT(*) AS Total_Cases
FROM Visit v
JOIN patients p 
    ON v.Patient_ID = p.Patient_ID
GROUP BY 
    p.Gender,
    v.Diagnosis
ORDER BY 
    gender DESC;


