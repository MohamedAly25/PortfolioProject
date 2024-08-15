/*

Cleaning Data in SQL Queries

*/

SELECT*
FROM PortfolioProject0..NashvilleHousing

--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*

-- Standardize Data Format

SELECT SaleDate_CONVERTED , CONVERT(DATE , SaleDate)
FROM PortfolioProject0..NashvilleHousing

UPDATE PortfolioProject0..NashvilleHousing
SET SaleDate = CONVERT(DATE , SaleDate)

ALTER TABLE PortfolioProject0..NashvilleHousing
ADD SaleDate_CONVERTED DATE;

UPDATE PortfolioProject0..NashvilleHousing
SET SaleDate_CONVERTED = CONVERT(DATE , SaleDate)

--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*

-- Populate Property Address data

SELECT *
FROM PortfolioProject0..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID , a.PropertyAddress ,b.ParcelID , b.PropertyAddress
,ISNULL(a.PropertyAddress,b.PropertyAddress) AS PropertyAddress_CONVERTED
FROM PortfolioProject0..NashvilleHousing a
JOIN PortfolioProject0..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject0..NashvilleHousing a
JOIN PortfolioProject0..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*

-- Show property addresses that appear more than 100 times
SELECT a.PropertyAddress, COUNT(a.PropertyAddress) AS AddressCount
FROM PortfolioProject0..NashvilleHousing a
JOIN PortfolioProject0..NashvilleHousing b
    ON a.PropertyAddress = b.PropertyAddress
    AND a.[UniqueID ] <> b.[UniqueID ]
GROUP BY a.PropertyAddress
HAVING COUNT(a.PropertyAddress) > 100;


--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*

--Breaking out Address into individual Columns  (Address, City, State)

SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM PortfolioProject0..NashvilleHousing


ALTER TABLE PortfolioProject0..NashvilleHousing
ADD  Address  VARCHAR(255), City  VARCHAR(60)


UPDATE PortfolioProject0..NashvilleHousing
SET Address_PropertyAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)
,City_PropertyAddress = SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


SELECT OwnerName
,PARSENAME(REPLACE( OwnerAddress,',' ,'.'),3) AS Address_Owner
,PARSENAME(REPLACE( OwnerAddress,',' ,'.'),2) AS City_Owner
,PARSENAME(REPLACE( OwnerAddress,',' ,'.'),1) AS State_Owner
FROM PortfolioProject0..NashvilleHousing


ALTER TABLE PortfolioProject0..NashvilleHousing
ADD  Address_Owner  NVARCHAR(255), City_Owner  NVARCHAR(60), State_Owner NVARCHAR(255);


UPDATE PortfolioProject0..NashvilleHousing
SET Address_Owner = PARSENAME(REPLACE( OwnerAddress,',' ,'.'),3)
,City_Owner = PARSENAME(REPLACE( OwnerAddress,',' ,'.'),2)
,State_Owner = PARSENAME(REPLACE( OwnerAddress,',' ,'.'),1);


SELECT OwnerName,Address_Owner,City_Owner,State_Owner
FROM PortfolioProject0..NashvilleHousing

--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*

-- Change Y and N Yes and NO in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) as CountSoldAsVacant
FROM PortfolioProject0..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY CountSoldAsVacant


SELECT SoldAsVacant
,CASE
	WHEN SoldAsVacant='Y'  THEN  'Yes'
	WHEN SoldAsVacant='N'  THEN  'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject0..NashvilleHousing


UPDATE PortfolioProject0..NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant='Y'  THEN  'Yes'
	WHEN SoldAsVacant='N'  THEN  'No'
	ELSE SoldAsVacant
END

SELECT DISTINCT SoldAsVacant
FROM PortfolioProject0..NashvilleHousing

--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY [UniqueID]
        ) AS row_num
    FROM PortfolioProject0..NashvilleHousing
	--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
Where row_num > 1
--ORDER BY PropertyAddress

--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*

--Delete Unused Columns

SELECT OwnerAddress, PropertyAddress, TaxDistrict ,SaleDate
FROM PortfolioProject0..NashvilleHousing

ALtER TABLE PortfolioProject0..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate
