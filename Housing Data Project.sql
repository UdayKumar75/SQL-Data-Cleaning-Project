--DATA CLEANING 


select * from [dbo].[Nashville Housing Data for Data Cleaning]




--NULL VALUES FROM "PropertyAddress" COLUMN ARE REPLACED USING JOIN 

select a.UniqueID ,a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from [dbo].[Nashville Housing Data for Data Cleaning] a join [dbo].[Nashville Housing Data for Data Cleaning] b
on a.ParcelID=b.ParcelID and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null 

Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from [dbo].[Nashville Housing Data for Data Cleaning] a join [dbo].[Nashville Housing Data for Data Cleaning] b
on a.ParcelID=b.ParcelID and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null 




--SPLITTING "PropertyAddress" COLUMN INTO TWO COLUMNS BASED ON ADDRESS & CITY

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress)) as City
from [dbo].[Nashville Housing Data for Data Cleaning]

alter table [dbo].[Nashville Housing Data for Data Cleaning] 
add PropertySplitAddress nvarchar(255), PropertySplitCity nvarchar(255)

update [dbo].[Nashville Housing Data for Data Cleaning]
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1),
PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress))





--SPLITTING "OwnerAddress" COLUMN INTO 3 DIFFERENT COLUMNS
select
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from [dbo].[Nashville Housing Data for Data Cleaning]

alter table [dbo].[Nashville Housing Data for Data Cleaning]
add OwnerSplitAddress nvarchar(255),OwnerSplitCity nvarchar(255),OwnerSplitState nvarchar(255)
update [dbo].[Nashville Housing Data for Data Cleaning]
set OwnerSplitAddress=parsename(replace(OwnerAddress,',','.'),3),
OwnerSplitCity=parsename(replace(OwnerAddress,',','.'),2),
OwnerSplitState=parsename(replace(OwnerAddress,',','.'),1)




--CHANGING DATA TYPE OF "SoldAsVacant" COLUMN AND UPDATING COLUMN DATA FROM NUMERIC DATA TO DESCRIPTIVE TEXT

ALter table [dbo].[Nashville Housing Data for Data Cleaning] alter column SoldAsVacant varchar(10)

select SoldAsVacant,
case when SoldAsVacant = 0 then 'No'
     when SoldAsVacant = 1 then 'Yes'
	 else SoldAsVacant
	 end
from [dbo].[Nashville Housing Data for Data Cleaning]

update [dbo].[Nashville Housing Data for Data Cleaning]
set SoldAsVacant = case when SoldAsVacant = 0 then 'No'
     when SoldAsVacant = 1 then 'Yes'
	 else SoldAsVacant
	 end




--DELETING DUPLICATE ENTRIES 

with RowNumCTE as(
select *,ROW_NUMBER() over(partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference order by UniqueID) rowno
from [dbo].[Nashville Housing Data for Data Cleaning]
)
delete from RowNumCTE 
where rowno>1
select * from RowNumCTE
where rowno>1 order by ParcelID





alter table [dbo].[Nashville Housing Data for Data Cleaning]
drop column PropertyAddress,OwnerAddress,TaxDistrict

select * from [dbo].[Nashville Housing Data for Data Cleaning]