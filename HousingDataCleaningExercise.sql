/*
 
 Data cleaning exercise in SQL
 Author: Izzy Bryant
 Reference: https://www.youtube.com/watch?v=8rO7ztF4NtU&t=471s

*/

Select *
From PortfolioProject..NashvilleHousing

-- This doesn't seem to be working
Update NashvilleHousing
Set SaleDate = Convert(date, SaleDate)

-- So instead, alter table by adding a new column...
Alter table NashvilleHousing
Add SaleDateConverted Date;

-- ...and then fill that column with converted SaleDate value
Update NashvilleHousing
Set SaleDateConverted = Convert(date, SaleDate)

-----------------------------------------------------------------------------------------------

-- 2. Populate Property Address data where null by joining on ParcelID
Select PropertyAddress
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------

-- 3. Break out Property Address into individual columns (Address, City, State)
Select PropertyAddress
From PortfolioProject..NashvilleHousing

-- Isolating each part of address
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))

Select PropertyAddress, PropertySplitAddress, PropertySplitCity
From NashvilleHousing


-- Using OwnerAddress & PARSENAME()
Select OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select *
From PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------

-- 4. Change Y and N to Yes and No in "Sold in Vacant" field

Select Distinct(SoldAsVacant), COUNT(soldasvacant)
From PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing
group by SoldAsVacant


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------

-- 5. Remove duplicates

WITH RowNumCTE AS(
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
From PortfolioProject..NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1

Select *
From PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------

-- Delete unused columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

Select * from PortfolioProject..NashvilleHousing