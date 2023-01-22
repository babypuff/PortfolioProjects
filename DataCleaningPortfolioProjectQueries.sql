-- Cleaning Data in SQL Queries
select * from PortfolioProject..NashvilleHousing;


--------------------------------------------------------
-- Standardize Date format
alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date, saledate);

select SaleDateConverted, convert(date, saledate)
from PortfolioProject..NashvilleHousing;

-- update NashvilleHousing
-- set saledate = convert(date, saledate)




-----------------------------------------------------------
-- Populate Property Address Data
select *
from PortfolioProject..NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]


--------------------------------------------------------------------------
-- Breaking out address into individual colums (Address, city, state)
select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing;

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress))

select * from PortfolioProject..NashvilleHousing





select OwnerAddress from PortfolioProject..NashvilleHousing


select PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) -- PARSENAME does things backwards
from PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProject.dbo.NashvilleHousing






-----------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




----------------------------------------------------------
-- remove duplicates
with RowNumCTE AS(
select *, 
ROW_NUMBER() over (partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

with RowNumCTE AS(
select *, 
ROW_NUMBER() over (partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
--delete 
From RowNumCTE
Where row_num > 1
-- Order by PropertyAddress



----------------------------------------------------
-- delete unused columns
Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate