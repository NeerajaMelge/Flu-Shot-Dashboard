/* About Database:
Data is collected from Data Wizardry https://datawizardry.academy/sql-basics-healthcare/
Data is generated from Synthea Database(Modified Synthetic patient database) https://github.com/synthetichealth/synthea..*/

/* Objectives:
Create a Patient database, upload and query patient data.
Build the  Flu shot Dashboard(Interactive) using the data to show the following.
1.) Total % of patients getting flu shots stratified by
   a.) Age
   b.) Race
   c.) County (On a Map)
   d.) Overall
2.) Running Total of Flu Shots over the course of 2022
3.) Total number of Flu shots given in 2022
4.) A list of Patients that show whether or not they received the flu shots.

Requirements:Patients(6 months and above) must have been "Active at hospital" */
 

/* Creating Table for data*/
CREATE TABLE conditions(
START DATE
,STOP DATE
,PATIENT VARCHAR(1000)
,ENCOUNTER VARCHAR(1000)
,CODE VARCHAR(1000)
,DESCRIPTION VARCHAR(200)
);

CREATE TABLE encounters(
Id VARCHAR(100)
,START TIMESTAMP
,STOP TIMESTAMP
,PATIENT VARCHAR(100)
,ORGANIZATION VARCHAR(100)
,PROVIDER VARCHAR(100)
,PAYER VARCHAR(100)
,ENCOUNTERCLASS VARCHAR(100)
,CODE VARCHAR(100)
,DESCRIPTION VARCHAR(100)
,BASE_ENCOUNTER_COST FLOAT
,TOTAL_CLAIM_COST FLOAT
,PAYER_COVERAGE FLOAT
,REASONCODE VARCHAR(100)
--,REASONDESCRIPTION VARCHAR(100)
);

CREATE TABLE immunizations
(
DATE TIMESTAMP
,PATIENT VARCHAR(100)
,ENCOUNTER VARCHAR(100)
,CODE int
,DESCRIPTION VARCHAR(500)
--,BASE_COST float
);

CREATE TABLE patients
(
 Id VARCHAR(100)
,BIRTHDATE date
,DEATHDATE date
,SSN VARCHAR(100)
,DRIVERS VARCHAR(100)
,PASSPORT VARCHAR(100)
,PREFIX VARCHAR(100)
,FIRST VARCHAR(100)
,LAST VARCHAR(100)
,SUFFIX VARCHAR(100)
,MAIDEN VARCHAR(100)
,MARITAL VARCHAR(100)
,RACE VARCHAR(100)
,ETHNICITY VARCHAR(100)
,GENDER VARCHAR(100)
,BIRTHPLACE VARCHAR(100)
,ADDRESS VARCHAR(100)
,CITY VARCHAR(100)
,STATE VARCHAR(100)
,COUNTY VARCHAR(100)
,FIPS INT 
,ZIP INT
,LAT float
,LON float
,HEALTHCARE_EXPENSES float
,HEALTHCARE_COVERAGE float
,INCOME int
,Mrn int
);

/* Upload Data to the tables */

/* Import Data to coniditions table*/
select * from public.conditions
/* Import Data  to encounters table*/
select * from public.encounters
/* Import Data  to immunizations table*/
select * from public.immunizations
/* Import Data  to patients table*/
select * from public.patients

/* Extracting active patients from above tables*/

/* 3. Check for active patients
(Moved to top to avoid errors) */
with active_patients as
(
	select distinct patient
	from encounters as e
	join patients as pat
	  on e.patient = pat.id
	where start between '2020-01-01 00:00' and '2022-12-31 23:59'
	  and pat.deathdate is null
	  and extract(month from age('2022-12-31',pat.birthdate)) >= 6
),


/* 2.Select the flu shot details from immunizations table
(Moving to top of patients table to avoid errors and duplicates)*/

flu_shot_2022 as
(
select patient, min(date) as earliest_flu_shot_2022 
from immunizations
	where code = '5302' 
 	and date between '2022-01-01 00:00' and '2022-12-31 23:59'
	group by patient 
)
	

/*1. Select the requirements from patient table*/ 
select pat.birthdate
      ,pat.race
	  ,pat.county
	  ,pat.id
	  ,pat.first
	  ,pat.last
	 /*Show only patients who recieved flu shots*/ 
	  ,flu.earliest_flu_shot_2022 
	  ,flu.patient
	  ,case when flu.patient is not null then 1 
	   else 0
	   end as flu_shot_2022
	   from patients as pat
	 /*Join the tables with patient id */
	   left join flu_shot_2022 as flu
       on pat.id = flu.patient
	 /*Join the table for active patient*/
		where 1=1
  		and pat.id in (select patient from active_patients)

/* Results :
The Result file has been downloaded and worked into Dashboard: Flu Shot Results
Link to dashboard view :

https://public.tableau.com/app/profile/neeraja.melge/viz/FluShotsDashboard_16958364721620/Dashboard1 */