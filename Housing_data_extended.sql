select *
From Sample_project.dbo.NashvilleHousing

--Standardize date format

Select SaleDate, CONVERT(date, SaleDate)
From Sample_project.dbo.NashvilleHousing

update Sample_project.dbo.NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

Alter Table Sample_project.dbo.NashvilleHousing
Add SaleDateConver date;

update Sample_project.dbo.NashvilleHousing
set SaleDateConver = CONVERT(date, SaleDate)

--property address

select *
From Sample_project.dbo.NashvilleHousing
Where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Sample_project.dbo.NashvilleHousing a
JOIN Sample_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Sample_project.dbo.NashvilleHousing a
JOIN Sample_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out address into individual columns

select PropertyAddress
From Sample_project.dbo.NashvilleHousing
--Where PropertyAddress is null

Select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address

From Sample_project.dbo.NashvilleHousing

Alter Table Sample_project.dbo.NashvilleHousing
Add Propertysplit_Address Nvarchar(255);

update Sample_project.dbo.NashvilleHousing
set PropertySplit_Address = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1 )

Alter Table Sample_project.dbo.NashvilleHousing
Add PropertySplit_City nvarchar(255)

update Sample_project.dbo.NashvilleHousing
set PropertySplit_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) 

select *
From Sample_project.dbo.NashvilleHousing

Select 
Parsename(REPLACE(OwnerAddress,',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Sample_project.dbo.NashvilleHousing

Alter Table Sample_project.dbo.NashvilleHousing
Add OwnerSplit_Address nvarchar(255);

update Sample_project.dbo.NashvilleHousing
set OwnerSplit_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter Table Sample_project.dbo.NashvilleHousing
Add OwnersplitCity nvarchar(255);

update Sample_project.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter Table Sample_project.dbo.NashvilleHousing
Add OwnersplitState nvarchar(255);

update Sample_project.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select *
From Sample_project.dbo.NashvilleHousing

--Change Y and N to yes and no

Select Distinct(SoldasVacant), count(SoldasVacant)
From Sample_project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldasVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From Sample_project.dbo.NashvilleHousing

update Sample_project.dbo.NashvilleHousing
set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End


--Remove Duplicates

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalRefrence,
				 order by UniqueID
					)row_num

From Sample_project.dbo.NashvilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


--Delete Columns

select *
From Sample_project.dbo.NashvilleHousing

Alter Table Sample_Project.dbo.NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, SaleDateConverted, PropertySplitCity, OwnresplitAddress, Ownresplit_Address

Alter Table Sample_Project.dbo.NashvilleHousing
Drop Column TaxDistrict, SaleDate

Alter Table Sample_Project.dbo.NashvilleHousing
Drop Column PropertysplitAddress

--Average price by land use

select LandUse, AVG(SalePrice) as Price_averaged
From Sample_project.dbo.NashvilleHousing
Where SalePrice is not null
Group By LandUse

--No of Property by city and address

select PropertySplit_City, Propertysplit_Address, Count(Propertysplit_Address) as Total_properties
From Sample_project.dbo.NashvilleHousing
Where PropertySplit_City is not null
Group By Propertysplit_Address, PropertySplit_City

--Differency between sale price and total value

select PropertySplit_City, Propertysplit_Address, LandUse, SalePrice, TotalValue, SalePrice -TotalValue as differ
From Sample_project.dbo.NashvilleHousing
Where TotalValue is not null
--Group By LandUse
order by 3,6 desc



