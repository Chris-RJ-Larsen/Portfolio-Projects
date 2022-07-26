-- Cleaning data in SQL Queries


-- View All the Data.
SELECT *
FROM portfolio_project.nashvillehousingdata

------------------------------------------------------------------------------------------------------------------

-- Standardize Date Formate
ALTER TABLE nashvillehousingdata
ADD SaleDateConverted DATE;

UPDATE nashvillehousingdata
SET SaleDateConverted = CONVERT(SaleDate, DATE);

------------------------------------------------------------------------------------------------------------------

-- Investigate rows without Property Address
SELECT *
FROM portfolio_project.nashvillehousingdata
WHERE PropertyAddress is null
ORDER BY ParcelID

-- Populate Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio_project.nashvillehousingdata a
JOIN portfolio_project.nashvillehousingdata b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE portfolio_project.nashvillehousingdata a
JOIN nashvillehousingdata b 
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

------------------------------------------------------------------------------------------------------------------

-- Investigating the Property Address format
SELECT PropertyAddress
FROM portfolio_project.nashvillehousingdata

-- Split the PropertyAddress column into induvidual columns (Adress, City and State)
ALTER TABLE nashvillehousingdata
ADD PropertySplitAddress VARCHAR(255);
UPDATE nashvillehousingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);

ALTER TABLE nashvillehousingdata
ADD PropertySplitCity VARCHAR(255);
UPDATE nashvillehousingdata
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1);

ALTER TABLE nashvillehousingdata
ADD OwnerSplitAddress VARCHAR(255);
UPDATE nashvillehousingdata
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashvillehousingdata
ADD OwnerSplitCity VARCHAR(255);
UPDATE nashvillehousingdata
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE nashvillehousingdata
ADD OwnerSplitState VARCHAR(255);
UPDATE nashvillehousingdata
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

------------------------------------------------------------------------------------------------------------------

-- investigate the unique values of the "Sold as Vacant" column
SELECT DISTINCT(SoldAsVacant)
FROM portfolio_project.nashvillehousingdata

-- Change Y and N to Yes and No in "Sold as Vacant" column
UPDATE nashvillehousingdata
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;

------------------------------------------------------------------------------------------------------------------

-- Remove duplicate row entries
WITH row_numCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
                    SaleDate,
                    LegalReference
                    ) row_num
FROM portfolio_project.nashvillehousingdata)

DELETE original
FROM portfolio_project.nashvillehousingdata original
JOIN row_numCTE CTE ON original.UniqueID = CTE.UniqueID
WHERE row_num > 1;

------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
ALTER TABLE portfolio_project.nashvillehousingdata
	DROP COLUMN OwnerAddress,
	DROP COLUMN SaleDate,
	DROP COLUMN PropertyAddress;

------------------------------------------------------------------------------------------------------------------