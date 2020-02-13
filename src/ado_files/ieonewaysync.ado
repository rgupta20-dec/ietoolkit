*! version Analytics dimeanalytics@worldbank.org

	capture program drop 	ieonewaysync
			program define 	ieonewaysync , rclass

	qui {

		syntax ,  FROMfolder(string) TOfolder(string)

		version 11.0
		
		
		******************************
		*	Test input: fromfolder

		mata : st_numscalar("r(dirExist)", direxists("`fromfolder'"))

		if (`r(dirExist)' == 0) | (length("`fromfolder'")<=10) {

			noi di as error `"{phang}The folder used in [fromfolder(`fromfolder')] does not exist or you have not entered the full path. For example, full paths on most Windows computers it starts with {it:C:/} and on most Mac computers with {it:/user/}.{p_end}"'
			error 693
			exit
		}

	
		******************************
		*	Test input: tofolder	
		
		mata : st_numscalar("r(dirExist)", direxists("`tofolder'"))

		if (`r(dirExist)' == 0) | (length("`tofolder'")<=10) {

			noi di as error `"{phang}The folder used in [tofolder(`tofolder')] does not exist or you have not entered the full path. For example, full paths on most Windows computers it starts with {it:C:/} and on most Mac computers with {it:/user/}.{p_end}"'
			error 693
			exit
		}		
		

		******************************
		*	Standardize folder paths
		local fromfolderStd	= subinstr(`"`fromfolder'"',"\","/",.)
		local tofolderStd	= subinstr(`"`tofolder'"',"\","/",.)
		
		*Get the name of the last folder in fromfolder()
		local fromLastSlash  = strpos(strreverse(`"`fromfolderStd'"'),"/")
		local fromLastFolder = substr(`"`fromfolderStd'"', (-1 * `fromLastSlash')+1 ,.)
		
		*Get the name of the last folder in fromfolder()
		local toLastSlash  = strpos(strreverse(`"`tofolderStd'"'),"/")
		local toLastFolder = substr(`"`tofolderStd'"', (-1 * `toLastSlash')+1 ,.)		
		

		*The last folder name should always be the same for folder() and comparefolder() 
		* otherwise there it is likely that the to paths point to differnet starting 
		* points in the two fodler trees that are to be compared.
		if ("`fromLastFolder'" != "`toLastFolder'") {
			noi di as error `"{phang}The last folder [`fromLastFolder'] in [fromfolder(`fromfolder')] is not identical to the last folder [`toLastFolder'] in [tofolder(`tofolder')]. This is not a technical restriction, but a built in test to mitage the risk of misspecification.{p_end}"'
			error 693
			exit
		}

	}	
	end	


	capture program drop 	ieonewaysync_function
			program define 	ieonewaysync_function , rclass


	end
