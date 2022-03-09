
*******************************************************************
** Program to compare GLD server data with local copy
*******************************************************************

program define gld_to_local

syntax, Gld(string) Lokal(string) [clear Countries(string) Detailed]


*******************************************************************
** Step 1 - Read in, evaluate arguments
*******************************************************************

* -- 1.1 Clear data if requested
if `"`clear'"' == "clear" {
	clear
} 


* -- 1.2 Evaluate arguments gld and lokal
* To do this, try to set the path as working directory
* Capture will just try it. If it fails, folder does not exist
capture cd "`gld'"
if _rc != 0 {
	display in red "The path to the GLD server you have specified does not seem to exist, please review"
	exit
}

capture cd "`lokal'"
if _rc != 0 {
	display in red "The path to the local server you have specified does not seem to exist, please review"
	exit
}


* -- 1.3 Evaluate countries are CCC
if "`countries'"!="" {
	
	* Loop over each element of countries
	foreach country of local countries{
		* Evaluate each is an upper case three letter code
		local check = regexm("`country'", "^[A-Z][A-Z][A-Z]$")
		* If any one is not, alert user
		if `check' != 1 {
			display in red "The code `country' is not a three capital letter code (like IND, ESP), please review"
			exit
		}
	}		
}


* -- 1.4 Evaluate paths are with forward slashes
local check = regexm("`gld'", "\\")
if `check' == 1 {
	display in red "Please write the GLD path with forward slashes (/), not backward ones (\)"
	exit
}
local check = regexm("`lokal'", "\\")
if `check' == 1 {
	display in red "Please write the local path with forward slashes (/), not backward ones (\)"
	exit
}


* -- 1.5 Evaluate paths do not end on "/"
local check = regexm("`gld'", "/$")
if `check' == 1 {
	display in red "Please write the GLD path without the last forward slash (/)"
	exit
}
local check = regexm("`lokal'", "/$")
if `check' == 1 {
	display in red "Please write the local path without the last forward slash (/)"
	exit
}


*******************************************************************
** Step 2 - Check local has latest files if no countries --> All folders
*******************************************************************

if "`countries'" == "" {
* if no country specified, do all    	
	
	* Run filelist to recursively get all files with .dta extension
	quietly: filelist, dir("`gld'") pat("*.dta")
		
	* Create check to only look at files in the harmonized data folder of GLD server
	gen check = regexm(dirname, "GLD/Data/Harmonized$")
	quietly: keep if check == 1
	drop check
	
	* Create var that takes out survey core (i.e., without version numbers)
	gen survey_core = regexs(1) if regexm(filename, "(^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_[a-zA-Z0-9-]+)(_[vV][0-9][0-9]_M_[vV][0-9][0-9]_A)_[a-zA-Z_]+\.dta")
	gen country = substr(survey_core,1,3)
		
	* By construction of the name (surveycore_v##_M_v##_A), the alphanumeric order will
	* put the most recent one last. Thus, surveycore_v01_M_v03_A is after surveycore_v01_M_v02_A,
	* both are before surveycore_v02_M_v01_A.
	sort filename
	bys survey_core: gen survey_number = _n
	bys survey_core: egen survey_numb_max = max(survey_number)
	quietly: keep if survey_numb_max == survey_number
		
	gen gld_path = dirname + "/" + filename
	gen lokal_path = "`lokal'" + "/" + country + "/" + filename
	
	* Go through files (each file defined in each row), confirm they exist in local
	forvalues row = 1/`=_N'{
		
		local lokal_path_row = lokal_path[`row']
		local gld_path_row	 = gld_path[`row']
	
		cap confirm	file "`lokal_path_row'"
		if _rc != 0 {
			di as error "The file "
			di _n "`gld_path_row'"
			di as error _n "is on the GLD server but not present on your local copy"
			* Add an assertion that will stop in a way that exit won't
			qui: assert _rc == 0
		* Close if _rc != 0
		}
	* Close forvalues 1/N	
	}
* Close if no countries defined
}


*******************************************************************
** Step 3 -  Check local has latest files of specified countries 
*******************************************************************

if "`countries'" != "" {
* There is content (and it has been vetted in step 1.3)

	* Loop through each country
	foreach country of local countries {
	    
	    * Create local with path to country folder
		local gld_folder "`gld'/`country'"
		
		* Run filelist to recursively get all files with .dta extension
		quietly: filelist, dir("`gld_folder'") pat("*.dta")
		
		* Create check to only look at files in the harmonized data folder of GLD server
		gen check = regexm(dirname, "GLD/Data/Harmonized$")
		quietly: keep if check == 1
		drop check
		
		* Create var that takes out survey core (i.e., without version numbers)
		gen survey_core = regexs(1) if regexm(filename, "(^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_[a-zA-Z0-9-]+)(_[vV][0-9][0-9]_M_[vV][0-9][0-9]_A)_[a-zA-Z_]+\.dta")
		gen country = substr(survey_core,1,3)
		
		* By construction of the name (surveycore_v##_M_v##_A), the alphanumeric order will
		* put the most recent one last. Thus, surveycore_v01_M_v03_A is after surveycore_v01_M_v02_A,
		* both are before surveycore_v02_M_v01_A.
		sort filename
		bys survey_core: gen survey_number = _n
		bys survey_core: egen survey_numb_max = max(survey_number)
		quietly: keep if survey_numb_max == survey_number
		
		gen gld_path = dirname + "/" + filename
		gen lokal_path = "`lokal'" + "/" + country + "/" + filename

		* Go through files (each file defined in each row), confirm they exist in local
		forvalues row = 1/`=_N'{
		    
			local lokal_path_row = lokal_path[`row']
			local gld_path_row	 = gld_path[`row']
	
			cap confirm	file "`lokal_path_row'"
			if _rc != 0 {
			    di as error "The file "
				di _n "`gld_path_row'"
				di as error _n "is on the GLD server but not present on your local copy"
				* Add an assertion that will stop in a way that exit won't
				qui: assert _rc == 0
			* Close if _rc != 0
			}
		* Close forvalues row = 1/`=_N'	
		}
	* Close foreach country
	}
* Close if "`countries'" != ""
}


*******************************************************************
** Step 4 -  Compare file contents if no country defined 
*******************************************************************

if "`detailed'" != "" & "`countries'" == "" {
* detailed option requested but no countries specified    
	
	* Run filelist to recursively get all files with .dta extension
	quietly: filelist, dir("`gld'") pat("*.dta")
		
	* Create check to only look at files in the harmonized data folder of GLD server
	gen check = regexm(dirname, "GLD/Data/Harmonized$")
	quietly: keep if check == 1
	drop check
	
	* Create var that takes out survey core (i.e., without version numbers)
	gen survey_core = regexs(1) if regexm(filename, "(^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_[a-zA-Z0-9-]+)(_[vV][0-9][0-9]_M_[vV][0-9][0-9]_A)_[a-zA-Z_]+\.dta")
	gen country = substr(survey_core,1,3)
	
	* By construction of the name (surveycore_v##_M_v##_A), the alphanumeric order will
	* put the most recent one last. Thus, surveycore_v01_M_v03_A is after surveycore_v01_M_v02_A,
	* both are before surveycore_v02_M_v01_A.
	sort filename
	bys survey_core: gen survey_number = _n
	bys survey_core: egen survey_numb_max = max(survey_number)
	quietly: keep if survey_numb_max == survey_number
		
	gen gld_path = dirname + "/" + filename
	gen lokal_path = "`lokal'" + "/" + country + "/" + filename
	
	* Go through files comparing server with local
	forvalues row = 1/`=_N'{
		
		local lokal_path_row = lokal_path[`row']
		local gld_path_row	 = gld_path[`row']
		
		preserve
		use `gld_path_row', clear
		capture cf _all using "`lokal_path_row'"
		if _rc != 0 {
			di as error "There are differences between GLD server and local copy"
			di as error _n "File on GLD"
			di _n "`gld_path_row'"
			di as error _n "is unequal to file on local"
			di _n "`lokal_path_row'"
			* Add an assertion that will stop in a way that exit won't
			qui: assert _rc == 0
		* Close if _rc != 0
		}
		restore
	* Close forvalues 1/N
	}
* Close if detailed and no countries
}

*******************************************************************
** Step 5 -  Compare file contents for specified countries
*******************************************************************

if "`detailed'" != "" & "`countries'" != "" {
* detailed option requested and country/countries specified
    
	* Loop through each country
	foreach country of local countries {
	    
	    * Create local with path to country folder
		local gld_folder "`gld'/`country'"
		
		* Run filelist to recursively get all files with .dta extension
		quietly: filelist, dir("`gld_folder'") pat("*.dta")
		
		* Create check to only look at files in the harmonized data folder of GLD server
		gen check = regexm(dirname, "GLD/Data/Harmonized$")
		quietly: keep if check == 1
		drop check
		
		* Create var that takes out survey core (i.e., without version numbers)
		gen survey_core = regexs(1) if regexm(filename, "(^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_[a-zA-Z0-9-]+)(_[vV][0-9][0-9]_M_[vV][0-9][0-9]_A)_[a-zA-Z_]+\.dta")
		gen country = substr(survey_core,1,3)
		
		* By construction of the name (surveycore_v##_M_v##_A), the alphanumeric order will
		* put the most recent one last. Thus, surveycore_v01_M_v03_A is after surveycore_v01_M_v02_A,
		* both are before surveycore_v02_M_v01_A.
		sort filename
		bys survey_core: gen survey_number = _n
		bys survey_core: egen survey_numb_max = max(survey_number)
		quietly: keep if survey_numb_max == survey_number
		
		gen gld_path = dirname + "/" + filename
		gen lokal_path = "`lokal'" + "/" + country + "/" + filename

		* Go through files comparing server with local
		forvalues row = 1/`=_N'{
			
			local lokal_path_row = lokal_path[`row']
			local gld_path_row	 = gld_path[`row']
			
			preserve
			use `gld_path_row', clear
			capture cf _all using "`lokal_path_row'"
			if _rc != 0 {
				di as error "There are differences between GLD server and local copy"
				di as error _n "File on GLD"
				di _n "`gld_path_row'"
				di as error _n "is unequal to file on local"
				di _n "`lokal_path_row'"
				* Add an assertion that will stop in a way that exit won't
				qui: assert _rc == 0
			* Close if _rc != 0
			}
			restore
		* Close forvalues 1/N
		}
		
	* Close foreach country
	}
* Close detailed with countries	
}


dis " " _newline
dis "Your local server seems updated with latest versions on the server."	
dis "          _" _newline "         //" _newline "   _    //" _newline "   \\  //" _newline "    \\//" _newline "     ‾‾" _newline 
dis "Please proceed with the data work"
clear
	
	
end
