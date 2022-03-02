{smcl}
{* *! version 1.0 2mar2022 }{...}
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


{marker description}{...}
{title:Description}

{pstd}
{cmd:gld_to_local} Evaluates whether a) the files in the GLD server are present in the local copy (e..g, alerts if there are newer files not yet in the local copy) and b) there are differences between the files of the same filename.

	
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
	 

{marker examples}{...}
{title:Examples}

{phang}{cmd:. gld_to_local, gld(Y:/GLD) lokal(C:/Users/wb123456/OneDrive - WBG/Documents/Country Work)}{p_end}

{phang}{cmd:. gld_to_local, gld(Y:/GLD) lokal(C:/Users/wb123456/OneDrive - WBG/Documents/Country Work) clear countries(IND)}{p_end}
