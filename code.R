if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, writexl, dplyr, sp, rworldmap)
languages <- read_excel("C:/Users/sphsc/OneDrive - UW/GitHub/Gendered-language/grambank data files/languages.xlsx")
parameters <- read_excel("C:/Users/sphsc/OneDrive - UW/GitHub/Gendered-language/grambank data files/parameters.xlsx")
values <- read_excel("C:/Users/sphsc/OneDrive - UW/GitHub/Gendered-language/grambank data files/values.xlsx")

#Merge grammatical gender variable with language dataframe:
values_GB051_only <- filter(values, 
                            values$Parameter_ID=="GB051") # create GB051 subset (GB051=dummy variable for sex-based grammatical gender)
values_GB051_only <- subset(values_GB051_only, 
                            select = -c(ID))
names(values_GB051_only)[names(values_GB051_only) == 'Language_ID'] <- 'ID'
lang_GB051 <- inner_join(languages, values_GB051_only)
lang_GB051_na <- anti_join(languages, values_GB051_only) # these are excluded languages due to missing GB051 data

#Add country variable based on language coordinates:
```{r}
lang_coord <- data.frame(languages$Longitude, languages$Latitude)
row_coord_na <- "which(is.na(lang_coord), arr.ind=TRUE)" # these are rows with NA's in lang_coord
lang_coord_na <- languages[row_coord_na[1:4,1], ] # data frame consisting of these rows
lang_coord_full <- data.frame(lang_coord)
lang_coord_full$languages.Longitude[is.na(lang_coord_full$languages.Longitude)] <- 999
lang_coord_full$languages.Latitude[is.na(lang_coord_full$languages.Latitude)] <- 999
coords2country = function(points)
{  
  countriesSP <- getMap(resolution='low')
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  # convert our list of points to a SpatialPoints object; setting CRS directly to that from rworldmap
  indices = over(pointsSP, countriesSP) # use 'over' to get indices of the Polygons object containing each point
  indices$ADMIN # return the ADMIN names of each country
  #indices$ISO3 returns the ISO3 code; 
  #indices$continent returns the continent (6 continent model); 
  #indices$REGION returns the continent (7 continent model).
}
lang_coord_full$country <- coords2country(lang_coord_full)
lang_coord_full$ID <- languages$ID
lang_GB051_country <- inner_join(lang_GB051, lang_coord_full)
gendlang <- subset(lang_GB051_country, 
                   select = -c(languages.Longitude, languages.Latitude))
#create merged dataset in local drive
write_xlsx(gendlang, 'C:/Users/sphsc/OneDrive/Documents/gendlang.xlsx') 

#Create national subsets
table(gendlang$country, useNA = 'always')
gendlang_Nigeria <- filter(gendlang, country=="Nigeria")
gendlang_Uganda <- filter(gendlang, country=="Uganda") 
```