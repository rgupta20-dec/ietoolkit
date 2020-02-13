*! version Analytics dimeanalytics@worldbank.org

	capture program drop ieonewaysync
			program define 	 ieonewaysync , rclass

	qui {

		syntax ,  FROMfolder(string) TOfolder(string) [shortok]

		version 11.0

		******************************
		*	Test input: fromfolder
		mata : st_numscalar("r(dirExist)", direxists("`fromfolder'"))
		if (`r(dirExist)' == 0) {
			noi di as error `"{phang}The folder used in [fromfolder(`fromfolder')] does not exist or you have not entered the full path. For example, full paths on most Windows computers it starts with {it:C:/} and on most Mac computers with {it:/user/}.{p_end}"'
			error 693
			exit
		}

		if (length("`fromfolder'")<=20) & missing("`shortok'") {
			noi di as error `"{phang}The folder used in [fromfolder(`fromfolder')] is too short. This is not a technical limitation but it is a built-in test to make sure you are not copying your whole computer somewhere. You can supress this error using the command {cmd : shortok}.{p_end}"'
			error 693
			exit
		}

		******************************
		*	Test input: tofolder
		mata : st_numscalar("r(dirExist)", direxists("`tofolder'"))
		if (`r(dirExist)' == 0) {
			noi di as error `"{phang}The folder used in [tofolder(`tofolder')] does not exist or you have not entered the full path. For example, full paths on most Windows computers it starts with {it:C:/} and on most Mac computers with {it:/user/}.{p_end}"'
			error 693
			exit
		}

		******************************
		*	Standardize folder paths
		local fromfolderStd	= subinstr(`"`fromfolder'"',"\","/",.)
		local tofolderStd	= subinstr(`"`tofolder'"',"\","/",.)

		*The last folder name should always be the same for folder() and comparefolder()
		* otherwise there it is likely that the to paths point to differnet starting
		* points in the two fodler trees that are to be compared.
		if ("`fromfolderStd'" == "`tofolderStd'") {
			noi di as error `"{phang}The folder in [fromfolder(`fromfolder')] is the same folder as in [tofolder(`tofolder')]. This is not allowed as the command is copying content from one folder to another folder.{p_end}"'
			error 693
			exit
		}

		*Get the name of the last folder in fromfolder()
		local fromLastSlash  = strpos(strreverse(`"`fromfolderStd'"'),"/")
		local fromLastFolder = substr(`"`fromfolderStd'"', (-1 * `fromLastSlash')+1 ,.)

		*Get the name of the last folder in tofolder()
		local toLastSlash  = strpos(strreverse(`"`tofolderStd'"'),"/")
		local toLastFolder = substr(`"`tofolderStd'"', (-1 * `toLastSlash')+1 ,.)

		*The last folder name should always be the same for folder() and comparefolder()
		* otherwise there it is likely that the to paths point to differnet starting
		* points in the two fodler trees that are to be compared.
		if ("`fromLastFolder'" != "`toLastFolder'") {
			noi di as error `"{phang}The last folder [`fromLastFolder'] in [fromfolder(`fromfolder')] is not identical to the last folder [`toLastFolder'] in [tofolder(`tofolder')]. This is not a technical restriction, but a built in test to mitage the risk of misspecifications.{p_end}"'
			error 693
			exit
		}

		* Start syncing the folder and all its content
		noi ie1sync_syncfolder , ffold("`fromfolderStd'") tfold("`tofolderStd'")

	}
	end

	*Sync all content of a folder, recursive call on subfolders
	capture program drop 	 ie1sync_syncfolder
				  program define ie1sync_syncfolder
  qui {
		syntax ,  ffold(string) tfold(string)

		*If tfold does not exist, start by createing it
		mata : st_numscalar("r(dirExist)", direxists("`tfold'"))
		if (`r(dirExist)' == 0) mkdir "`tfold'"

		noi di ""
		noi di as result `"{pstd}Syncing folder `ffold'{p_end}"'

		******************************
		*	List all files and folders

		*List files, directories and other files
		local dlist : dir `"`ffold'"' dirs  "*" , respectcase
		local flist : dir `"`ffold'"' files "*"	, respectcase
		local olist : dir `"`ffold'"' other "*"	, respectcase

		*Loop over all files and sync them
		local allfiles "`flist' `olist'"
		foreach file of local allfiles {
			*Sync each file
			noi ie1sync_syncfile , ffold("`ffold'") tfold("`tfold'") file("`file'")
		}

		*Loop recursivily over all sub-folders
		foreach dir of local dlist {
			*Recursive call on each subfolder
			noi ie1sync_syncfolder , ffold("`ffold'/`dir'") tfold("`tfold'/`dir'")
		}

	}
	end

	capture program drop 	 ie1sync_syncfile
				  program define ie1sync_syncfile
	qui {
		syntax ,  ffold(string) tfold(string) file(string)

		noi di as result `"{pstd}- Syncing file `file' {p_end}"'
		copy "`ffold'/`file'" "`tfold'/`file'" , replace
  }
	end
