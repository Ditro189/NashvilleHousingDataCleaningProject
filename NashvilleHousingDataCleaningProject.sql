/* In this project, we will clean the data to enhance its usability.*/


DROP DATABASE IF exists  nashville_housing_project;
CREATE DATABASE nashville_housing_project;
USE nashville_housing_project;

/* Create a table to introduce the data from our .csv file since
 the import wizard in mysql is not able to import the amount of 
 data required in an acceptable amount of time */
 
drop table if exists nashville_housing_data;
CREATE TABLE nashville_housing_data (
unique_id int,
parcel_id varchar(50),
land_use varchar(50),
property_adress varchar(50),
sale_date varchar(50),
sale_price varchar(50),
legal_reference varchar(50),
sold_as_vacant varchar(50),
owner_name varchar(100),
owner_adress varchar(50),
acreage varchar(50),
taxt_district varchar(50),
land_value varchar(50),
buiding_value varchar(50),
total_value varchar(50),
year_built varchar(50),
bedrooms varchar(50),
full_bath varchar(50),
half_bath varchar(50))
;

/* You will have to save the .csv in the secure_file_priv folder*/
 
SHOW VARIABLES LIKE "secure_file_priv"
;

SHOW VARIABLES LIKE 'local_infile'
;

SHOW VARIABLES LIKE 'log_error'
;

LOAD DATA INFILE 'NashvilleHousingData.csv' INTO TABLE nashville_housing_data
FIELDS TERMINATED BY';'
IGNORE 1 LINES
;

-- Populate Property Address data

Select *
From nashville_housing_data
-- Where property_adress = ''
-- order by parcel_id
;

-- Having blank spaces as null will be helpfull here

update nashville_housing_data 
set property_adress = CASE property_adress WHEN '' THEN NULL 
ELSE property_adress END
;

Select a.parcel_id, a.property_adress, b.parcel_id, b.property_adress, ifnull(a.property_adress,b.property_adress)
From nashville_housing_data a
JOIN nashville_housing_data b
	on a.parcel_id = b.parcel_id
	AND a.unique_id  <> b.unique_id
Where a.property_adress is null
;

update nashville_housing_data as a
JOIN nashville_housing_data b
	on a.parcel_id = b.parcel_id
	AND a.unique_id <> b.unique_id
SET a.property_adress = ifnull(a.property_adress,b.property_adress)
Where a.property_adress is null
;

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT SUBSTRING(property_adress, 1, position(','in property_adress) -1 ) as Address1
, SUBSTRING(property_adress, position(','in property_adress) + 1 , length(property_adress)) as Address2
From nashville_housing_data
;

ALTER TABLE nashville_housing_data
Add property_split_address varchar(50);
;

Update nashville_housing_data
SET property_split_address = SUBSTRING(property_adress, 1, position(','in property_adress) -1 )
;

ALTER TABLE nashville_housing_data
Add property_split_city varchar(50);

Update nashville_housing_data
SET property_split_city = SUBSTRING(property_adress, position(','in property_adress) + 1 , length(property_adress))
;

Select *
From nashville_housing_data
;

-- Breaking out Owner Address using substring now

Select owner_adress
From nashville_housing_data
;

Select SUBSTRING_INDEX(owner_adress, ',', 1)
,SUBSTRING_INDEX(SUBSTRING_INDEX(owner_adress, ',', 2), ',', -1)
,SUBSTRING_INDEX(owner_adress, ',', -1)
From nashville_housing_data
;

ALTER TABLE nashville_housing_data
Add owner_split_address varchar(50)
;

UPDATE nashville_housing_data
SET owner_split_address = SUBSTRING_INDEX(owner_adress, ',', 1)
;

ALTER TABLE nashville_housing_data
Add owner_split_city varchar(50)
;

UPDATE nashville_housing_data
SET owner_split_city = SUBSTRING_INDEX(SUBSTRING_INDEX(owner_adress, ',', 2), ',', -1)
;

ALTER TABLE nashville_housing_data
Add owner_split_state varchar(50)
;

UPDATE nashville_housing_data
SET owner_split_state = SUBSTRING_INDEX(owner_adress, ',', -1)
;

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select sold_as_vacant, Count(sold_as_vacant)
From nashville_housing_data
Group by sold_as_vacant
order by 2
;

Select sold_as_vacant,
CASE When sold_as_vacant = 'Y' THEN 'Yes'
	 When sold_as_vacant = 'N' THEN 'No'
	 ELSE sold_as_vacant
	 END
From nashville_housing_data
;

Update nashville_housing_data
SET sold_as_vacant = CASE When sold_as_vacant = 'Y' THEN 'Yes'
	   When sold_as_vacant = 'N' THEN 'No'
	   ELSE sold_as_vacant
	   END
       ;

-- Showing duplicates (If you run the entire code below, you will observe all the duplicate rows.)

WITH row_num_cte AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY parcel_id,
				 property_adress,
				 sale_price,
				 sale_date,
				 legal_reference
				 ORDER BY unique_id) as row_num

From nashville_housing_data
)
Select *
From row_num_cte
Where row_num > 1
Order by property_adress
;

-- Delete Unused Columns(Although it is normally not good practice to erase original data, this would be how it is done)

Select *
From nashville_housing_data
;

ALTER TABLE nashville_housing_data
DROP COLUMN taxt_district
;











