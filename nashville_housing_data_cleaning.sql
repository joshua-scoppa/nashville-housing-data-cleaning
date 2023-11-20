/*
Cleaning Data in SQL
Skills Used: Changing Data Type, Self-Joins, Separating Strings into Multiple Columns
*/

SELECT *
FROM nashville_housing_db.dbo.nashville_housing_data;


/* Change SaleDate Column Data Type */

SELECT SaleDate
FROM nashville_housing_db.dbo.nashville_housing_data;

--ALTER TABLE nashville_housing_data
--ALTER COLUMN SaleDate datetime;

ALTER TABLE nashville_housing_data
ALTER COLUMN SaleDate date;


/* Populate PropertyAdress Column Using Self-Join */

SELECT *
FROM nashville_housing_db.dbo.nashville_housing_data
WHERE PropertyAddress IS NULL
-- Check if ParcelID matches PropertyAddress
ORDER BY ParcelID;

SELECT a.ParcelID
	, a.PropertyAddress
	, b.ParcelID
	, b.PropertyAddress
FROM nashville_housing_db.dbo.nashville_housing_data a
-- Check if null PropertyAddress values have a matching address
JOIN nashville_housing_db.dbo.nashville_housing_data b 
	ON a.ParcelID = b.ParcelID
		AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Assign values from table b to table a where PropertyAddress is null
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing_db.dbo.nashville_housing_data a
JOIN nashville_housing_db.dbo.nashville_housing_data b 
	ON a.ParcelID = b.ParcelID
		AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


/* Separate PropertyAddress into Separate Columns (Address, City) */

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS PropertyAddressLine1
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertyCity
FROM nashville_housing_db.dbo.nashville_housing_data;

-- Add columns
ALTER TABLE nashville_housing_data
ADD PropertyAddressLine1 nvarchar(255);

ALTER TABLE nashville_housing_data
ADD PropertyCity nvarchar(255);

-- Populate columns
UPDATE nashville_housing_data
SET PropertyAddressLine1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

UPDATE nashville_housing_data
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


/* Separate OwnerAddress into Separate Columns (Address, City, State) */

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM nashville_housing_db.dbo.nashville_housing_data;

-- Add columns
ALTER TABLE nashville_housing_db.dbo.nashville_housing_data
ADD OwnerAddressLine1 nvarchar(255);

ALTER TABLE nashville_housing_db.dbo.nashville_housing_data
ADD OwnerCity nvarchar(255);

ALTER TABLE nashville_housing_db.dbo.nashville_housing_data
ADD OwnerState nvarchar(255);

-- Populate columns
UPDATE nashville_housing_db.dbo.nashville_housing_data
SET OwnerAddressLine1 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE nashville_housing_db.dbo.nashville_housing_data
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE nashville_housing_db.dbo.nashville_housing_data
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);
