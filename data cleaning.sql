--Cleaning data using SQL queries

--Standardize date formart
Select SaleDate, convert(date, SaleDate)
From Data_cleaning_HousingProject..NashvilleHousing

--Changing date format directly from the columnn
Update NashvilleHousing
SET SaleDate = convert(date, SaleDate)


--Creating a new column for the converted date format
ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

Update NashvilleHousing
SET SaleDateConverted = convert(date, SaleDate)


Select SaleDateConverted
From Data_cleaning_HousingProject..NashvilleHousing

Select *
from Data_cleaning_HousingProject..NashvilleHousing


--Populate PropertAddress data where null but with similar ParcelID
Select *
from Data_cleaning_HousingProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID



Select i.ParcelID,i.PropertyAddress,ii.ParcelID,ii.PropertyAddress, 
	ISNULL(i.PropertyAddress, ii.PropertyAddress)
from Data_cleaning_HousingProject..NashvilleHousing i
join Data_cleaning_HousingProject..NashvilleHousing ii
	ON i.ParcelID = ii.ParcelID
	AND i.[UniqueID] <> ii.[UniqueID]
Where i.PropertyAddress is null


Update i
SET i.PropertyAddress = ISNULL(i.PropertyAddress, ii.PropertyAddress)
from Data_cleaning_HousingProject..NashvilleHousing i
join Data_cleaning_HousingProject..NashvilleHousing ii
	ON i.ParcelID = ii.ParcelID
	AND i.[UniqueID] <> ii.[UniqueID]
Where i.PropertyAddress is null




--Breaking Addresses into individual columns (Address, city, state)
Select PropertyAddress
from Data_cleaning_HousingProject..NashvilleHousing


Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from Data_cleaning_HousingProject..NashvilleHousing


Alter table Data_cleaning_HousingProject..NashvilleHousing
ADD PropertyAddress_Seperated nvarchar (255)

UPDATE Data_cleaning_HousingProject..NashvilleHousing
SET PropertyAddress_Seperated = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)




Alter table Data_cleaning_HousingProject..NashvilleHousing
ADD PropertyCity_Seperated nvarchar (255)

UPDATE Data_cleaning_HousingProject..NashvilleHousing
SET PropertyCity_Seperated = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))








--Using PARSENAME to seperate OwnerAddress into Address, State & City
Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Data_cleaning_HousingProject..NashvilleHousing




Alter table Data_cleaning_HousingProject..NashvilleHousing
ADD OwnerAddress_Seperated nvarchar (255)

UPDATE Data_cleaning_HousingProject..NashvilleHousing
SET OwnerAddress_Seperated = PARSENAME(REPLACE(OwnerAddress,',','.'),3)




Alter table Data_cleaning_HousingProject..NashvilleHousing
ADD OwnerCity_Seperated nvarchar (255)

UPDATE Data_cleaning_HousingProject..NashvilleHousing
SET OwnerCity_Seperated = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


Alter table Data_cleaning_HousingProject..NashvilleHousing
ADD OwnerState_Seperated nvarchar (255)

UPDATE Data_cleaning_HousingProject..NashvilleHousing
SET OwnerState_Seperated = PARSENAME(REPLACE(OwnerAddress,',','.'),1)







--Replace 'Y' and 'N' to 'Yes' and 'No' in 'SoldAsVacant' column
Select
	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from Data_cleaning_HousingProject..NashvilleHousing
Group by (SoldAsVacant)



Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'N' THEN 'No'
		 WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 ELSE SoldAsVacant
		 END
From Data_cleaning_HousingProject..NashvilleHousing
--WHERE SoldAsVacant = 'y' or SoldAsVacant = 'N'

UPDATE Data_cleaning_HousingProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
		 WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 ELSE SoldAsVacant
		 END



Select DISTINCT(SoldAsVacant)
from Data_cleaning_HousingProject..NashvilleHousing







--Remove unused columns
ALTER TABLE Data_cleaning_HousingProject..NashvilleHousing
DROP COLUMN OwnerAddress


ALTER TABLE Data_cleaning_HousingProject..NashvilleHousing
DROP COLUMN TaxDistrict, PropertyAddress, SaleDate