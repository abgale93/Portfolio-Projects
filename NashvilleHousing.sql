-- Project - Cleaning Data in SQL Queries

SELECT *
FROM ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning]

---------------------------------------------------------------------------------------------------------------

-- Standardize Sale Date Format

SELECT SaleDate,CONVERT(Date,SaleDate)
FROM ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning]

UPDATE [Nashville Housing Data for Data Cleaning]
SET SaleDate = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning] b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE [a]
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning] b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

---------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning]
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) AS Address

FROM ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD PropertySplitCity NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))

---------------------------------------------------------------------------------------------------------------

-- Now Breaking Down the Owner Address

SELECT OwnerAddress
FROM ProgrammingProject.Dbo.[Nashville Housing Data for Data Cleaning]

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM ProgrammingProject.Dbo.[Nashville Housing Data for Data Cleaning]



ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
ADD OwnerSplitState NVARCHAR(255);

UPDATE [Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)



SELECT * 
FROM ProgrammingProject.Dbo.[Nashville Housing Data for Data Cleaning]

-------------------------------------------------------------------------------------------------------------------

-- CHANGE Y and N to YES and NO in "Sold As Vacant" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProgrammingProject.Dbo.[Nashville Housing Data for Data Cleaning]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM ProgrammingProject.Dbo.[Nashville Housing Data for Data Cleaning]


UPDATE [Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
   END

---------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER()OVER(
    PARTITION BY ParcelID, 
                 PropertyAddress,  
                 SalePrice, 
                 SaleDate, 
                 LegalReference  
                    ORDER BY UniqueID
                    )row_num
FROM ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning]
)
SELECT *
FROM RowNumCTE
WHERE Row_num > 1 
ORDER BY PropertyAddress


SELECT *
FROM ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning]

------------------------------------------------------------------------------------------------------

-- Delete Unused Columns 

SELECT * 
FROM ProgrammingProject.dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
