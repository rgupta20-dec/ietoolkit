{smcl}
{* 5 Nov 2019}{...}
{hline}
help for {hi:ieonewaysync}
{hline}

{title:Title}

{cmd:ieonewaysync} {hline 2} Copies the content of one folder to another folder. Similar to syncing two folder but only one-way.

{phang2}For a more descriptive discussion on the intended usage and work flow of this
command please see the {browse "https://dimewiki.worldbank.org/wiki/Ieonewaysync":DIME Wiki}.

{title:Syntax}

{phang} {cmdab:ieonewaysync} , {opt from:folder(file_path)} {opt to:folder(file_path)} [{opt shortok}]

{marker opts}{...}
{synoptset 23}{...}
{synopthdr:options}
{synoptline}
{synopt :{opt from:folder(file_path)}}Specifies the path to the folder where the content will be copied {bf:from}.{p_end}
{synopt :{opt to:folder(file_path)}}Specifies the path to the folder where the content will be copied {bf:to}.{p_end}
{synopt :{opt shortok}}Allows the file fromfolder() to be short, otherwise not allowed to prevent coping all of {it:C:\}{p_end}
{synoptline}

{marker desc}
{title:Description}

{marker optslong}
{title:Options}

{phang}{opt from:folder(file_path)}{p_end}

{phang}{opt to:folder(file_path)}{p_end}

{phang}{opt shortok}{p_end}


{title:Example}

{title:Acknowledgements}

{title:Author}

{phang}All commands in ietoolkit is developed by DIME Analytics at DECIE, The World Bank's unit for Development Impact Evaluations.

{phang}Main author: Kristoffer Bjarkefur, DIME Analytics, The World Bank Group

{phang}Please send bug-reports, suggestions and requests for clarifications
		 writing "ietoolkit ieonewaysync" in the subject line to:{break}
		 dimeanalytics@worldbank.org

{phang}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through {browse "https://github.com/worldbank/ietoolkit":the GitHub repository of ietoolkit}.{p_end}
