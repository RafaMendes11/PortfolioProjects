SELECT * 
FROM dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

SELECT SaleDateConverted
FROM dbo.NashvilleHousing;

---------------------------------------------------------------------------------------------------------------------------

-- Populate Property Adress Data
SELECT *
FROM dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

---------------------------------------------------------------------------------------------------------------------------

-- Breaking out Adress into Individual Columns (Adress, City, State)
SELECT PropertyAddress
FROM dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Adress
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortifolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) AS State
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



---------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
	SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

SELECT
	OwnerName,
		CASE
			WHEN OwnerName IS NULL THEN 'N/A'
			ELSE OwnerName
		END UpdatedOwnerName
FROM dbo.NashvilleHousing
---------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		LegalReference
		ORDER BY UniqueID
) Row_Num
FROM dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT * 
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN SaleDate

---------------------------------------------------------------------------------------------------------------------------


-- Handling All Null Values


SELECT * 
FROM dbo.NashvilleHousing
WHERE 
   UniqueID IS NULL 
   OR ParcelID IS NULL 
   OR LandUse IS NULL
   OR SalePrice IS NULL
   OR LegalReference IS NULL
   OR SoldAsVacant IS NULL
   OR OwnerName IS NULL
   OR Acreage IS NULL
   OR LandValue IS NULL
   OR BuildingValue IS NULL
   OR TotalValue IS NULL
   OR YearBuilt IS NULL
   OR Bedrooms IS NULL
   OR FullBath IS NULL
   OR HalfBath IS NULL


SELECT
    OwnerName,
    COALESCE(OwnerName, 'N/A') AS UpdatedOwnerName,
    Acreage,
    COALESCE(CAST(Acreage AS VARCHAR), 'N/A') AS UpdatedAcreage,
    LandValue,
    COALESCE(CAST(LandValue AS VARCHAR), 'N/A') AS UpdatedLandValue,
    BuildingValue,
    COALESCE(CAST(BuildingValue AS VARCHAR), 'N/A') AS UpdatedBuildingValue,
    TotalValue,
    COALESCE(CAST(TotalValue AS VARCHAR), 'N/A') AS UpdatedTotalValue,
    YearBuilt,
    COALESCE(CAST(YearBuilt AS VARCHAR), 'N/A') AS UpdatedYearBuilt,
    Bedrooms,
    COALESCE(CAST(Bedrooms AS VARCHAR), 'N/A') AS UpdatedBedrooms,
	FullBath,
	COALESCE(CAST(FullBath AS VARCHAR), 'N/A') AS UpdateFullBath,
	HalfBath,
	COALESCE(CAST(HalfBath AS VARCHAR), 'N/A') AS UpdateHalfBath,
	OwnerSplitAddress,
	COALESCE(OwnerSplitAddress, 'N/A') AS UpdateOwnerSplitAddress,
	OwnerSplitCity,
	COALESCE(OwnerSplitCity, 'N/A') AS UpdateOwnerSplitCity,
	OwnerSplitState,
	COALESCE(OwnerSplitState, 'N/A') AS UpdateOwnerSplitState
FROM dbo.NashvilleHousing