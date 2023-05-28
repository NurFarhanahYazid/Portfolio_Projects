/*

Cleaning Data in SQL

*/

Select *
from Project1.dbo.NashvilleHousing

--Date format

select SaleDateConverted, convert(date, Saledate)
from Project1.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

alter table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

--Populate Property Address

select *
from Project1.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress, b.PropertyAddress)
from Project1.dbo.NashvilleHousing a
join Project1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Project1.dbo.NashvilleHousing a
join Project1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into individual

select PropertyAddress
from Project1.dbo.NashvilleHousing 

select
substring (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
substring (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))  as Address
from Project1.dbo.NashvilleHousing 

alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))

select*
from Project1.dbo.NashvilleHousing 

--/using parsename
select PropertyAddress
from Project1.dbo.NashvilleHousing 

select
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from Project1.dbo.NashvilleHousing 

alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

select*
from Project1.dbo.NashvilleHousing 

-- change Y and N to Yes and No in "Sold as Vacant" field
--case statement

select distinct (SoldAsVacant), count(SoldAsVacant)
from Project1.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from Project1.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

--remove duplicates
--using cte
--identify row num
--partition on things that should be unique

with RowNumCTE as (
select *, 
ROW_NUMBER() over(partition by ParcelID,
							 PropertyAddress,
							 SalePrice,
							 SaleDate,
							 LegalReference
							 order by
								UniqueID
								) row_num
from Project1.dbo.NashvilleHousing
--order by ParcelID
)
select * --delete 
from RowNumCTE
where row_num > 1
order by PropertyAddress 

select *
from Project1.dbo.NashvilleHousing

--delete unused column

alter table Project1.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


