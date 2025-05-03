-- Cleaning Data in sql queries

Select *
From NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted , CONVERT(Date, SaleDate)
From NashvilleHousing

update NashvilleHousing
SET SaleDate  = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date ;

update NashvilleHousing
SET SaleDateConverted  = CONVERT(Date, SaleDate)


--Populate Property Adress data

Select PropertyAddress
From NashvilleHousing
--where PropertyAddress is Null
order by ParcelID

--so when we check the parce id there are different ids for the same address and different rows so what this does is does not include the property address in the one of the 2 or more parce ids, so then we get null
-- to remove these null values we are doing a combined property address data by using separate tables A and B for combined single table property address without null values
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

-- so this has created a seperate column where the property adress is populated and is in one column without null values
-- now we will update it using alias 
Update a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- after updating it there will be no null values in it using the set method and isnull

--Now breaking out Address into Individual columns City, State using the delimiter

Select PropertyAddress
from NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address -- to get rid of the comma at the end of the adress we did -1
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address -- puting +1 gets us into after the comma address into next column seperated
From NashvilleHousing

-- so now we have got two new addresses that we need to separate into 2 new columns

Alter Table NashvilleHousing  -- first run this
Add PropertySplitAddress Nvarchar(255) ;

update NashvilleHousing -- Second run this
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing -- third run this
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing -- fourth run this
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select* -- now run this and see new added columns in the table in the last
From NashvilleHousing

-- now same with the owner address
select OwnerAddress
from NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
From NashvilleHousing

Alter Table NashvilleHousing  -- first run this
Add OwnerSplitState Nvarchar(255) ;

update NashvilleHousing -- Second run this
SET OwnerSplitState = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing  -- first run this
Add OwnerSplitCity Nvarchar(255) ;

update NashvilleHousing -- Second run this
SET OwnerSplitCity = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing  -- first run this
Add OwnerSplitAddress Nvarchar(255) ;

update NashvilleHousing -- Second run this
SET OwnerSplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)


Select*
from NashvilleHousing

-- Change Y and N to Yes and No in 'SoldAsVacant' column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
 case when SoldAsVacant= 'Y' THEN 'Yes'
     when SoldAsVacant='N' THEN 'No'
	 Else SoldAsVacant
	 END
from NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant=case when SoldAsVacant= 'Y' THEN 'Yes'
     when SoldAsVacant='N' THEN 'No'
	 Else SoldAsVacant
	 END
From NashvilleHousing

--Remove Duplicates

;WITH RowNumCTE AS( 
Select*,
    Row_Number() Over(
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				    UniqueID
				  )row_num
From NashvilleHousing
)
Select*
FROM   RowNumCTE
where row_num>1;
--order by PropertyAddress


-- Delete Unused Columns

Select *
From NashvilleHousing

Alter table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
Drop Column SaleDate