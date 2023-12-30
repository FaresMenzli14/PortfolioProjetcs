-- lets see everything and clean the data
select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------
--sales date doesnt look good
select saleDate, convert(Date,SaleDate) as salesDateConverted
From PortfolioProject.dbo.NashvilleHousing

-- lets update it with a date format, no need for time
--Lets add a new column and assign to it the values converted.
ALter table NashvilleHousing
add SaleDateConverted date;

Update PortfolioProject..NashvilleHousing
set SaleDateConverted = Convert(Date,saleDate)


Select * From PortfolioProject..NashvilleHousing
---------------------------------------------------------------------------------------------------------

--Populate Property adress ( there is a lot of NULL values, lets see them first)
Select *
From PortfolioProject..NashvilleHousing
where propertyaddress is null

--lets order by perceID because we think that properties with same parcelID have the same property address
Select *
From PortfolioProject..NashvilleHousing
order By ParcelID

--we are going to assume that when we have a parcelID and an address , and the same parcelID with null value in address,
--THEN we replace null with the that adress

Select  a.ParcelID, b.ParcelID, a.PropertyAddress, b.Propertyaddress, ISNULL(a.PropertyAddress,b.Propertyaddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
ON a.ParcelID= b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

--lets update it

Update a
Set Propertyaddress = ISNULL(a.PropertyAddress,b.Propertyaddress)
FROM PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
ON a.ParcelID= b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

----------------------------------------------------------------------------------
--lets break address into Individual columns (address,city,state)

select propertyaddress
From PortfolioProject..NashvilleHousing

Select
Substring (PropertyAddress, 1, charindex(',',PropertyAddress) -1)As address,
Substring (PropertyAddress, charindex(',',PropertyAddress)+1 , Len(PropertyAddress) ) as City
FROM PortfolioProject..NashvilleHousing

-- lets add two Columns and assign the values we just looked at

alter table NAshvilleHousing
add PropertySplitAddress varchar(255), 
PropertySplitCity varchar(255)



--lets add values to the newwly created columns
Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = Substring (PropertyAddress, 1, charindex(',',PropertyAddress) -1),
PropertySplitCity= Substring (PropertyAddress, charindex(',',PropertyAddress)+1 , Len(PropertyAddress) )

--lets see OwnerAddress and break the address into individual columns

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

select owneraddress, Parsename(replace(owneraddress,',','.'),3), 
Parsename(Replace(Owneraddress,',','.'),2),
Parsename(Replace(Owneraddress,',','.'),1)
From PortfolioProject.dbo.nashvillehousing

--it works , so lets create new columns and add the corresponding values

Alter table portfolioProject.dbo.NashvilleHousing
add OwnersplitAddress varchar(255), 
ownersplitcity varchar(255),
ownersplitState varchar(255)

Update PortfolioProject..NashvilleHousing
Set OwnersplitAddress=Parsename(replace(owneraddress,',','.'),3), 
ownersplitcity=Parsename(Replace(Owneraddress,',','.'),2),
ownersplitState=Parsename(Replace(Owneraddress,',','.'),1)


Select * 
From PortfolioProject..NashvilleHousing

--Lets explore SoldAsVacant data

Select Distinct(SOldasvacant),Count(soldasvacant)
From PortfolioProject..NashvilleHousing
Group By soldasvacant 
order by 2 desc

--we are looking at NO, N , Y, Yes, but it should be just yes, no or Y,N.  Not the four of them
--Yes and no are the most populated, so lets change Y and N to Yes and NO

Select soldasvacant , CASE 
when soldasvacant='Y' then 'Yes'
When Soldasvacant='N' then 'no'
else soldasvacant
end
From PortfolioProject..NashvilleHousing
--where soldasvacant='N'

--lets update it now
Update PortfolioProject..NashvilleHousing
Set SoldAsVacant= 
 CASE 
when soldasvacant='Y' then 'Yes'
When Soldasvacant='N' then 'no'
else soldasvacant
end
----------------------------------------------------------------------------------------------

--Remove duplicates
WITH cte as (
select * , 
Row_number() over ( 
Partition by ParcelID, PropertyAddress, SalePrice,SaleDate, LegalReference order By uniqueID ) rownum  
From PortfolioProject..NashvilleHousing )

Select * From cte 
where rownum>1
-- we created a CTE so we can see how many rows that have the same information(duplicates) / deleted the extra rows


----------------------------------------------------------------------------------------------------
--delete unused columns, lets delete the columns Property address and owneraddress (we already break down into address,city, state in other columns)

Alter table Portfolioproject..nashvilleHousing
Drop column owneraddress, Propertyaddress

Select * 
From PortfolioProject..NashvilleHousing

--also delete the date that we converted earlier
alter table Portfolioproject..nashvilleHousing
Drop Column saleDate