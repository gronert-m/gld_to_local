
*******************************************************************
** Program to compare GLD server data with local copy
*******************************************************************

program define gld_to_local

syntax, Gld(string) Lokal(string) [clear Countries(string)]


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
** Step 2 - Check if no countries --> All folders
*******************************************************************

if "`countries'" == "" {
* if no country specified, do all    	
	
	filelist, dir("`gld'") pat("*.dta")
		
	* Create var that checks we are in harmonized directory, use to cut
	gen check = regexm(dirname, "GLD/Data/Harmonized$")
	keep if check == 1
	drop check
	
	* Create var that takes out survey core (i.e., without version numbers)
	gen survey_core = regexs(1) if regexm(filename, "(^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_[a-zA-Z0-9-]+)(_[vV][0-9][0-9]_M_[vV][0-9][0-9]_A)_[a-zA-Z_]+\.dta")
		
	* By construction of the name (surveycore_v##_M_v##_A), the alphanumeric order will
	* put the most recent one last. Thus, surveycore_v01_M_v03_A is after surveycore_v01_M_v02_A,
	* both are before surveycore_v02_M_v01_A.
	bys survey_core: gen survey_number = _n
	bys survey_core: egen survey_numb_max = max(survey_number)
	keep if survey_numb_max == survey_number
		
	gen gld_path = dirname + "/" + filename
	gen common_path = regexs(1) if regexm(gld_path, "`gld'([^.]*)")
	gen lokal_path = "`lokal'" + common_path + ".dta"
	
	* -- 2.1 Check whether files exist in local copy
	* This does not require reading in data and thus is quicker to load
	forvalues row = 1/`=_N'{
		
		local lokal_path_row = lokal_path[`row']
		local gld_path_row	 = gld_path[`row']
	
		cap confirm	file `lokal_path_row'
		if _rc != 0 {
			di as error "There is a file on the GLD server not present on your local copy"
			di as error _n "File on GLD is "
			di _n "`gld_path_row'"
			di as error _n "File on local is"
			di _n "`lokal_path_row'"
			* Add an assertion that will stop in a way that exit won't
			qui: assert _rc == 0
		}
	* Close forvalues 1/N	
	}
	
	* -- 2.2 Compare files between local and server 
	* Provided they exist - step 2.1)
	forvalues row = 1/`=_N'{
		
		local lokal_path_row = lokal_path[`row']
		local gld_path_row	 = gld_path[`row']
		
		preserve
		use `gld_path_row', clear
		capture cf _all using `lokal_path_row'
		if _rc != 0 {
			di as error "There are differences between GLD server and local copy"
			di as error _n "File on GLD"
			di _n "`gld_path_row'"
			di as error _n "is unequal to file on local"
			di _n "`lokal_path_row'"
			* Add an assertion that will stop in a way that exit won't
			qui: assert _rc == 0
		}
		restore
	* Close forvalues 1/N
	}	
* Close if no countries defined
}


*******************************************************************
** Step 3 - Check specific countries
*******************************************************************

if "`countries'" != "" {
* There is content (and it has been vetted in step 1.3)

	* Loop through each country
	foreach country of local countries {
	    
	    
		local gld_folder "`gld'/`country'"
		filelist, dir("`gld_folder'") pat("*.dta")
		
		* Create var that checks we are in harmonized directory, use to cut
		gen check = regexm(dirname, "GLD/Data/Harmonized$")
		keep if check == 1
		drop check
		
		* Create var that takes out survey core (i.e., without version numbers)
		gen survey_core = regexs(1) if regexm(filename, "(^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_[a-zA-Z0-9-]+)(_[vV][0-9][0-9]_M_[vV][0-9][0-9]_A)_[a-zA-Z_]+\.dta")
		
		* By construction of the name (surveycore_v##_M_v##_A), the alphanumeric order will
		* put the most recent one last. Thus, surveycore_v01_M_v03_A is after surveycore_v01_M_v02_A,
		* both are before surveycore_v02_M_v01_A.
		bys survey_core: gen survey_number = _n
		bys survey_core: egen survey_numb_max = max(survey_number)
		keep if survey_numb_max == survey_number
		
		gen gld_path = dirname + "/" + filename
		gen common_path = regexs(1) if regexm(gld_path, "`gld_folder'([^.]*)")
		gen lokal_path = "`lokal'/`country'" + common_path + ".dta"

		* First go through files to see if they exist in local
		* This does not require reading in data and thus is quicker to load
		forvalues row = 1/`=_N'{
		    
			local lokal_path_row = lokal_path[`row']
			local gld_path_row	 = gld_path[`row']
	
			cap confirm	file `lokal_path_row'
			if _rc != 0 {
			    di as error "There is a file on the GLD server not present on your local copy"
				di as error _n "File on GLD is "
				di _n "`gld_path_row'"
				di as error _n "File on local is"
				di _n "`lokal_path_row'"
				* Add an assertion that will stop in a way that exit won't
				qui: assert _rc == 0
			}
		}
		
		* Second go through to compare files (provided they exist - previous step)
		forvalues row = 1/`=_N'{
			
			local lokal_path_row = lokal_path[`row']
			local gld_path_row	 = gld_path[`row']
			
			preserve
			use `gld_path_row', clear
			capture cf _all using `lokal_path_row'
			if _rc != 0 {
				di as error "There are differences between GLD server and local copy"
				di as error _n "File on GLD"
				di _n "`gld_path_row'"
				di as error _n "is unequal to file on local"
				di _n "`lokal_path_row'"
				* Add an assertion that will stop in a way that exit won't
				qui: assert _rc == 0
			}
			restore
		}

	}
}

end
