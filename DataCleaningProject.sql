/*Cleaning Data in SQL Queries*/

SELECT *
FROM [dbo].[NashvilleHousing];
------------------------------------------------------------------------------------------------
/*Standardize Date format*/

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM [dbo].[NashvilleHousing]

Update [dbo].[NashvilleHousing]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [dbo].[NashvilleHousing]
ADD SaleDateConverted Date;

Update [dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)
-------------------------------------------------------------------------------------------------
/*Populate Property address data*/

SELECT PropertyAddress
FROM [dbo].[NashvilleHousing]


 
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM Portfolio_Project.[dbo].[NashvilleHousing] a
JOIN Portfolio_Project.[dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project.[dbo].[NashvilleHousing] a
JOIN Portfolio_Project.[dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
-------------------------------------------------------------------------------------------

/*Splitting Address into individual columns (address, city, state)*/

SELECT PropertyAddress
FROM Portfolio_Project.[dbo].[NashvilleHousing]

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM Portfolio_Project.[dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
ADD PropertySplitAddress  NVARCHAR(255);

UPDATE [dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE [dbo].[NashvilleHousing]
ADD PropertySplitCity  NVARCHAR(255);

UPDATE [dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM Portfolio_Project.[dbo].[NashvilleHousing]

SELECT
PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME (REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)
FROM Portfolio_Project.[dbo].[NashvilleHousing]


UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.'), 3)

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'), 2)

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
FROM [dbo].[NashvilleHousing]
-------------------------------------------------------------------------------------------------------

/*Change Y and N to yes and no in "sold as vacant' field*/

SELECT DISTINCT(SoldAsVacant)
FROM [dbo].[NashvilleHousing]

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant ='Y'THEN 'Yes'
	  WHEN SoldAsVacant = 'N'THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM [dbo].[NashvilleHousing]

UPDATE [dbo].[NashvilleHousing]
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y'THEN 'Yes'
	  WHEN SoldAsVacant = 'N'THEN 'No'
	  ELSE SoldAsVacant
	  END


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2
------------------------------------------------------------------------------------------------------
/*REMOVE DUPLICATES*/

WITH RowNumCTE AS(
SELECT *
, ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	ORDER BY UniqueID
		) row_num
FROM [dbo].[NashvilleHousing]
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
----------------------------------------------------------------------------------------------
--Delete unused columns

SELECT * 
FROM [dbo].[NashvilleHousing]

ALTER TABLE  [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 ALTER TABLE  [dbo].[NashvilleHousing]
DROP COLUMN SaleDate
