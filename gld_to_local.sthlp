{smcl}
{* *! version 1.0 7mar2022 }{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "gld_to_local##syntax"}{...}
{viewerjumpto "Description" "gld_to_local##description"}{...}
{viewerjumpto "Options" "gld_to_local##options"}{...}
{viewerjumpto "Examples" "gld_to_local##examples"}{...}
{title:Title}

{phang}
{bf:gld_to_local} {hline 2} Evaluate equality between GLD files on server and local copies


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:gld_to_local}, {it:gld(str) lokal(str) [clear countries(str)]}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main arguments}
{synopt:{opt g:ld(string)}}Path to the GLD server{p_end}
{synopt:{opt l:okal(string)}}Path to the local file system{p_end}

{syntab:Optional arguments}
{synopt:{opt clear}}Clear data in memory before starting{p_end}
{synopt:{opt c:ountries(string)}}List of three letter country codes of specific countries to evaluate{p_end}
{synopt:{opt d:etailed}}Additionally check whether each variable of either location are the same{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:gld_to_local} Evaluates a) whether the files in the GLD server are present in the local copy (e..g, alerts if there are newer files not yet in the local copy - standard behaviour) and b) whether there are differences between the files of the same filename (if option it:detailed selected).

	
{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt gld(string)} Path to the GLD server. Please use forward slashes “/” and do not end on one. For example, use Y:/GLD and not Y:\GLD or Y:/GLD/.

{phang}
{opt lokal(string)} Path to the local main directory containing the GLD server copy. Same rules as for gld.

{dlgtab:Optional arguments}

{phang}
{opt clear} Clear command will clear memory.

{phang}
{opt countries(string)} List of three letter ISO country codes for countries to compare so as to not evaluate the whole server. Each country should be in upper case letters (as per GLD server structure) and separated by space. For example countries(IND KOR ESP), not countries(ind Kor spain) or countries(IND_KOR_ESP)
	 
{phang}
{opt detailed} Do not just compare filenames (i.e., whether file [path_gld]/A.dta can be found in [path_lokal]/A.dta) but check in depth whether each variable of either file are the same (e.g., if, despite the same filename content is different)



{marker examples}{...}
{title:Examples}

{phang}{cmd:. gld_to_local, gld(Y:/GLD) lokal(C:/Users/wb123456/OneDrive - WBG/Documents/Country Work)}{p_end}

{phang}{cmd:. gld_to_local, gld(Y:/GLD) lokal(C:/Users/wb123456/OneDrive - WBG/Documents/Country Work) clear countries(IND)}{p_end}

{phang}{cmd:. gld_to_local, gld(Y:/GLD) lokal(C:/Users/wb123456/OneDrive - WBG/Documents/Country Work) clear countries(IND) detailed}{p_end}

{pstd} The same example as above can be reduced using the command shortcuts{p_end}
{phang}{cmd:. gld_to_local, g(Y:/GLD) l(C:/Users/wb123456/OneDrive - WBG/Documents/Country Work) clear c(IND) d}{p_end}
