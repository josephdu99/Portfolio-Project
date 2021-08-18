Select * 
From portfolioproject..NashvilleHousing


-- Standardising date format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From portfolioproject..NashvilleHousing

Update portfolioproject..NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table portfolioproject..NashvilleHousing
Add SaleDateConverted Date;

Update portfolioproject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address

Select *
From portfolioproject..NashvilleHousing
--Where PropertyAddress is null 
Order By ParcelID

Select a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolioproject..NashvilleHousing a 
JOIN portfolioproject..NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolioproject..NashvilleHousing a 
JOIN portfolioproject..NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


-- Breaking Out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From portfolioproject..NashvilleHousing
--Where PropertyAddress is null 
--Order By ParcelID

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From portfolioproject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


Select *
From portfolioproject..NashvilleHousing



Select OwnerAddress
From portfolioproject..NashvilleHousing



Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From portfolioproject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From portfolioproject..NashvilleHousing


-- Change Y and N ot Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From portfolioproject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant 
, Case When SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
From portfolioproject..NashvilleHousing

Update NashvilleHousing 
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
From portfolioproject..NashvilleHousing


-- Remove Duplicates

WITH RowNumCTE AS (
 Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress, 
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
						UniqueID
						) row_num

 From portfolioproject..NashvilleHousing
 --ORDER BY ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-- Delete Unused Column


Select*
From portfolioproject..NashvilleHousing

ALTER TABLE portfolioproject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE portfolioproject..NashvilleHousing
DROP COLUMN SaleDate

