*! version 6.2 31JAN2019 DIME Analytics dimeanalytics@worldbank.org

cap program drop 	ieaddfolder
	program define	ieaddfolder

qui {

	syntax anything, PROJectfolder(string)  folders(string) [ABBreviation(string) SUBfolder(string)]

	version 11

	***Todo
	*give error message if divisor is changed

	*Create an empty line before error message or output
	noi di ""

	/***************************************************

		Parse input

	***************************************************/

	*Parse out the sub-command
	gettoken itemType itemName : anything

	*Make sure that the item name is only one word
	gettoken itemName rest : itemName

	*Clean up the input
	local itemType 		= trim("`itemType'")
	local itemName 		= trim("`itemName'")

	noi di "ItemType 	`itemType'"
	noi di "ItemName	`itemName'"
	noi di "Rest		`itemName'"
	noi di "Folders		`folders'"

	 /***************************************************

		Test input

	***************************************************/

	*Test that the type is correct
	local itemTypes "project round unitofobs subfolder"

	*Test if subcommand is valid
	if `:list subcommand in sub_commands' == 0 {

		noi di as error `"{phang}You have not used a valid subcommand. You entered "`subcommand'". See the {help iefolder:help file} for details.{p_end}"'
		error 198
	}

	*Test if item type is valid
	if `:list itemType in itemTypes' == 0 {

		noi di as error `"{phang}You have not used a valid item type. You entered "`itemType'". See the {help iefolder:help file} for details.{p_end}"'
		error 198
	}

	*Test that item name is used when item type is anything but project
	else if ("`itemType'" != "project" & "`itemName'" == "" ) {

		noi di as error `"{phang}You must specify a name of the `itemType'. See the {help iefolder:help file} for details.{p_end}"'
		error 198
	}


	*test that there is no space in itemname
	local space_pos = strpos(trim("`itemName'"), " ")
	if "`rest'" != ""  | `space_pos' != 0 {

		noi di as error `"{pstd}You have specified too many words in: [{it:iefolder `subcommand' `itemType' `itemName'`rest'}] or used a space in {it:itemname}. Spaces are not allowed in the {it:itemname}. Use under_scores or camelCase.{p_end}"'
		error 198
	}


	**Only rounds can be put in a sufolder, so if subfolder is used the itemtype must be
	if ("`subfolder'" != "" & "`itemType'" != "round") {

		noi di as error `"{pstd}The option subfolder() can only be used together with item type "round" as only "round" folders can be organized in subfolders.{p_end}"'
		error 198
	}

	*test that there is no space in subfolder option
	local space_pos = strpos(trim("`subfolder'"), " ")
	if "`subfolder'" != ""  & `space_pos' != 0 {

		noi di as error `"{pstd}You have specified too many words in: [{it:subfolder(`subfolder')}]. Spaces are not allowed, use under_scores or camelCase instead.{p_end}"'
		error 198
	}
	
	*Creating a new project
	if "`itemType'" == "project" {

	}
	*Creating a new round
	else if "`itemType'" == "round" {

	}
	*Creating a new level of observation for master data set
	else if "`itemType'" == "unitofobs" {

	}
	*Creating a new subfolder in which rounds can be organized
	else if "`itemType'" == "subfolder" {

	}

	*Create a global pointing to the main data folder
	local projectFolder		"`projectfolder'"
	local dataWorkFolder 	"$projectFolder/DataWork"
	local encryptFolder 	"$dataWorkFolder/EncryptedData"

	/***************************************************

		Parsing and testing input

	***************************************************/
	

	local oldcounter = 0
	local olderrors = ""
	local newerrors = ""
	
	*Loop over exisint folder for which one or several folders will be created in
	while "`folders'" != "" {
		
		*Counters
		local ++oldcounter  	//increment the counter for old folder
		local newcounter = 0	//Reset the counter for new folders for this old folder
		
		*Parsing one folder string at the time
		gettoken folderString folders : folders, parse("&")
		local folders = subinstr("`folders'" ,"&","",1) //Remove parse char from gettoken remainder

		*Splitting existing folder from new folder(s)
		gettoken oldFolder newFolders : folderString , parse(":")
		local newFolders = subinstr("`newFolders'" ,":","",1) //Remove parse char from gettoken remainder
		
		*Forward and back slash means the same but are not the same in string comparison
		local oldFolder_`oldcounter' = trim(subinstr("`dataWorkFolder'/`itemName'/`oldFolder'" , "\", "/", .))	
		
		*Test that the old folder is valid
		noi oldfolder_test , oldfolder("`oldFolder_`oldcounter''")
		
		if `r(existerror)' == 1 local olderrors "`olderrors' `oldFolder_`oldcounter'' {break}"
		

		*Loop over the new folder(s) to be created in this folder
		while "`newFolders'" != "" {
		
			local ++newcounter
			
			*Parse one new fodler at the time
			gettoken newFolder newFolders : newFolders, parse(",")
			local newFolders = subinstr("`newFolders'" ,",","",1) //Remove parse char from gettoken remainder
		
			*Forward and back slash means the same but are not the same in string comparison
			local newFolder_`oldcounter'_`newcounter' = trim(subinstr("`oldFolder_`oldcounter''/`newFolder'" , "\", "/", .))	
			
			*Test that the old folder is valid
			noi newfolder_test , newfolder("`newFolder_`oldcounter'_`newcounter''")
			
			if `r(existerror)' == 1 local newerrors "`newerrors' `newFolder_`oldcounter'_`newcounter'' {break}"
			
		}
		
		local oldFolder_`oldcounter'_newCount = `newcounter'
	}
	
	if "`olderrors'`newerrors'" != "" {
		
		if "`olderrors'" != "" noi di as error "{phang}The following old folders to create folders in does not exist: {break} `olderrors'{p_end}"
		if "`newerrors'" != "" noi di as error "{phang}The following new folders to be created already exist: {break} `newerrors'{p_end}"
		
		error 198
	}
}
	
	/***************************************************

		Start making updates to the project folder

	***************************************************/
	
	forvalue oldcount = 1/`oldcounter' {
		forvalue newcount = 1/`oldFolder_`oldcount'_newCount' {
			noi di "newFolder_`oldcount'_`newcount'"
			noi di "`newFolder_`oldcount'_`newcount''"
		}
		
	}




end

cap program drop 	oldfolder_test
	program define	oldfolder_test, rclass
	
	syntax ,oldfolder(string)
	
	*Test that the folder exists
	mata : st_numscalar("r(dirExist)", direxists("`oldfolder'"))	
	
	if `r(dirExist)' == 1 {
		return local existerror 0 //folder exist, not an error
	}
	else {
		return local existerror 1 //folder does not exist, ERROR
	}
	
end

cap program drop 	newfolder_test
	program define	newfolder_test, rclass
	
	syntax ,newfolder(string)
	
	*TODO test valid name
	
	*Test that the folder exists
	mata : st_numscalar("r(dirExist)", direxists("`newfolder'"))	
	
	if `r(dirExist)' == 1 {
		return local existerror 1 //folder exist, ERROR
	}
	else {
		return local existerror 0 //folder does not exist, not an error
	}
	
end
