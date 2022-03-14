
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
** Step 2 - Obtain list of files, reduce to necessary
*******************************************************************

* Obtain all *dta in GLD

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

* Create variables with full paths
gen gld_path = dirname + "/" + filename
gen lokal_path = "`lokal'" + "/" + country + "/" + filename

* If countries specified, reduce to those countries only
if "`countries'" != "" {

  * Generate variable to denote requested countries
  quietly: gen requested_countries = .

  * Loop through countries and give value 1 to requested_countries
  foreach country of local countries {
    quietly: replace requested_countries = 1 if country == "`country'"
  }

  * Keep ony requested_countries
  quietly: keep if requested_countries == 1
  drop requested_countries

}

* Create variables for missing and unequal files
quietly: gen missing_files = .
quietly: gen unequal_files = .


*******************************************************************
** Step 3 - Check local has latest files
*******************************************************************

* Go through files (each file defined in each row), confirm they exist in local
* if they do not exist, assign value 1 to variable detect_missing
forvalues row = 1/`=_N'{

	* Create locals that contain the row's value 
	local lokal_path_row = lokal_path[`row']
	local gld_path_row	 = gld_path[`row']

	cap confirm	file "`lokal_path_row'"
	if _rc != 0 {
		quietly: replace missing_files = 1 in `row'
	* Close if _rc != 0
	}
* Close forvalues 1/N
}

* Now obtain gld_path of cases with missing_files == 1
quietly: levelsof gld_path if missing_files == 1, local(missing_cases)
local n : word count `missing_cases'
forvalues i = 1/`n' {

	* Create a local with the individual missing case
	local missing_case : word `i' of `missing_cases'

	if `i' == 1 {

		* If first, put info text
		dis as error "The following file(s) from the GLD server is(are) not present on your local copy"
		di _n "`missing_case'"
	}
	else {
		* If there are more, just list them
		di "`missing_case'"
	}

	* If last run, exit
	if `i' == `n' {
		exit
	}
* Close forvalues 1/`n'
}


*******************************************************************
** Step 4 - Check local has *same* files - if detailed option requested
*******************************************************************

if "`detailed'" != "" {

	* Go through files comparing server with local
	forvalues row = 1/`=_N'{

		* Create locals that contain the row's value 
		local lokal_path_row = lokal_path[`row']
		local gld_path_row	 = gld_path[`row']
		
		* Create a local that we'll set to 1 if files are unequal
		local unequal_detector = 0	
		
		* Since comparing requires opening the file, checking it to other, 
		* we need to set a preserve command to come back
		preserve
		use `gld_path_row', clear
		capture cf _all using "`lokal_path_row'"
		if _rc != 0 {
			local unequal_detector = 1
		* Close if _rc != 0
		}
		restore
		quietly: replace unequal_files = 1 if `unequal_detector' == 1 in `row'
	* Close forvalues 1/N
	}


	* Now obtain gld_path of cases with unequal_files == 1
	quietly: levelsof gld_path if unequal_files == 1, local(unequal_cases)
	local n : word count `unequal_cases'
	forvalues i = 1/`n' {

		* Create a local with the individual unequal case
		local unequal_case : word `i' of `unequal_cases'

		if `i' == 1 {

			* If first, put info text
			dis as error "The following file(s) from the GLD server is(are) *unequal* your local copy"
			di _n "`unequal_case'"
		}
		else {
			* If there are more, just list them
			di "`unequal_case'"
		}

		* If last run, exit
		if `i' == `n' {
			exit
		}
	* Close forvalues 1/`n'
	}

* Close if detailed requested 
}


*******************************************************************
** Step 5 - Report all good at end if all tests passed
*******************************************************************

dis " " _newline
dis "Your local server seems updated with latest versions on the server."	
dis "          _" _newline "         //" _newline "   _    //" _newline "   \\  //" _newline "    \\//" _newline "     ‾‾" _newline 
dis "Please proceed with the data work"
clear


end
