if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, writexl, dplyr, sp, rworldmap)
languages <- read_excel("C:/Users/sphsc/OneDrive - UW/GitHub/Gendered-language/grambank raw data/languages.xlsx")
parameters <- read_excel("C:/Users/sphsc/OneDrive - UW/GitHub/Gendered-language/grambank raw data/parameters.xlsx")
values <- read_excel("C:/Users/sphsc/OneDrive - UW/GitHub/Gendered-language/grambank raw data/values.xlsx")

##Merge grammatical gender variables (GB051, GB030) with language dataframe:
#create GB051 subset (GB051=dummy variable for sex-based grammatical gender)
values_GB051_only <- filter(values, 
                            values$Parameter_ID=="GB051") 
values_GB051_only <- subset(values_GB051_only, 
                            select = -c(ID))
names(values_GB051_only)[names(values_GB051_only) == 'Language_ID'] <- 'ID'
lang_GB051 <- inner_join(languages, values_GB051_only)
lang_GB051_na <- anti_join(languages, values_GB051_only) # these are languages missing GB051 data
names(lang_GB051)[names(lang_GB051) == 'Parameter_ID'] <- 'GB051'
names(lang_GB051)[names(lang_GB051) == 'Value'] <- 'GB051_Value'
names(lang_GB051)[names(lang_GB051) == 'Comment'] <- 'GB051_Comment'
names(lang_GB051)[names(lang_GB051) == 'Source'] <- 'GB051_Source'
names(lang_GB051)[names(lang_GB051) == 'Source_comment'] <- 'GB051_Source_comment'
names(lang_GB051)[names(lang_GB051) == 'Coders'] <- 'GB051_Coders'
lang_GB051 <- subset(lang_GB051, 
                     select = -c(Code_ID))
#create GB030 subset (GB030=dummy variable for gender distinction in third-person pronoun)
values_GB030_only <- filter(values, 
                            values$Parameter_ID=="GB030") 
values_GB030_only <- subset(values_GB030_only, 
                            select = -c(ID))
names(values_GB030_only)[names(values_GB030_only) == 'Language_ID'] <- 'ID'
lang_GB030 <- inner_join(languages, values_GB030_only)
lang_GB030_na <- anti_join(languages, values_GB030_only) # these are languages missing GB030 data
names(lang_GB030)[names(lang_GB030) == 'Parameter_ID'] <- 'GB030'
names(lang_GB030)[names(lang_GB030) == 'Value'] <- 'GB030_Value'
names(lang_GB030)[names(lang_GB030) == 'Comment'] <- 'GB030_Comment'
names(lang_GB030)[names(lang_GB030) == 'Source'] <- 'GB030_Source'
names(lang_GB030)[names(lang_GB030) == 'Source_comment'] <- 'GB030_Source_comment'
names(lang_GB030)[names(lang_GB030) == 'Coders'] <- 'GB030_Coders'
lang_GB030 <- subset(lang_GB030, 
                    select = -c(Code_ID))
#Join GB051 and GB030
lang_GB051_GB030 <- inner_join(lang_GB051, lang_GB030)
lang_GB051_GB030_na <- anti_join(lang_GB051, lang_GB030) # these have GB051 data but missing GB030 data

##Add country variable based on language coordinates:
lang_coord <- data.frame(languages$Longitude, languages$Latitude)
row_coord_na <- which(is.na(lang_coord), arr.ind=TRUE) # these are rows with NA's in lang_coord
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
coords2ISO3 = function(points)
{  
  countriesSP <- getMap(resolution='low')
  pointsSP = SpatialPoints(points, proj4string=CRS(proj4string(countriesSP)))  # convert our list of points to a SpatialPoints object; setting CRS directly to that from rworldmap
  indices = over(pointsSP, countriesSP) # use 'over' to get indices of the Polygons object containing each point
  #indices$ADMIN # return the ADMIN names of each country
  indices$ISO3 #returns the ISO3 code; 
  #indices$continent returns the continent (6 continent model); 
  #indices$REGION returns the continent (7 continent model).
}
lang_coord_full_raw <- lang_coord_full
lang_coord_full$country <- coords2country(lang_coord_full_raw)
lang_coord_full$ISO3 <- coords2ISO3(lang_coord_full_raw)
lang_coord_full$ID <- languages$ID #replicate ID column to lang_coord_full

##Join datasets:
lang_GB051_GB030_country <- inner_join(lang_GB051_GB030, lang_coord_full)
lang_GB051_GB030_country_filtered <- lang_GB051_GB030_country[!(lang_GB051_GB030_country$ID %in% lang_coord_na$ID),] #remove any row with fake coordinates
gendlang <- subset(lang_GB051_GB030_country_filtered, 
                   select = -c(languages.Longitude, languages.Latitude)) #remove duplicate coordinate columns to get final dataset
write_xlsx(gendlang, 'C:/Users/sphsc/OneDrive - UW/GitHub/Gendered-language/grambank raw data/gendlang.xlsx') #create merged dataset in local drive


#Create national subsets (optional)
table(gendlang$country, useNA = 'always')
gendlang_Nigeria <- filter(gendlang, country=="Nigeria")
gendlang_Uganda <- filter(gendlang, country=="Uganda")
gendlang_Ethiopia <- filter(gendlang, country=="Ethiopia")
gendlang_Kenya <- filter(gendlang, country=="Kenya")
gendlang_Malawi <- filter(gendlang, country=="Malawi")
gendlang_Tanzania <- filter(gendlang, country=="United Republic of Tanzania")