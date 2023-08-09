clear

*Create .dta files for all raw data files
import excel using "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\languages.xlsx", firstrow clear
save "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\languages.dta"
clear
import excel using "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\parameters.xlsx", firstrow clear
save "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\parameters.dta"
clear
import excel using "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\values.xlsx", firstrow clear
save "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\values.dta"
clear

*Reshape values dataset long to wide
use "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\values.dta" 
encode Parameter_ID, gen(Parameter_no)
drop ID Parameter_ID
reshape wide Value Code_ID Comment Source Source_comment Coders, i(Language_ID) j(Parameter_no)

*optional: save reshaped values dataset with all parameters
save "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\values_reshaped.dta", replace

*Save dataset with only parameters related to grammatical gender
keep Language_ID Value10 Code_ID10 Comment10 Source10 Source_comment10 Coders10 Value25 Code_ID25 Comment25 Source25 Source_comment25 Coders25
save "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\values_gg.dta", replace
clear

*Join languages with grammatical gender parameters
use "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\languages.dta"
rename ID Language_ID
merge 1:1 Language_ID using "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\values_gg.dta"

* Find country using coordinates
net get geo2xy, from("http://fmwww.bc.edu/repec/bocode/g")
ssc install dataex
ssc install geoinpoly
geoinpoly Latitude Longitude using "geo2xy_world_coor.dta"
merge m:1 _ID using "geo2xy_world_data.dta", ///
    keep(master match) keepusing(geounit) nogen
drop _merge _ID
rename geounit country

*Save new dataset
save "C:\Users\sphsc\OneDrive - UW\GitHub\Gendered-language\grambank raw data\gendlang.dta", replace
