*! version x.x DATEDATE DIME Analytics dimeanalytics@worldbank.org


cap program drop 	iecompressall
	program define	iecompressall, rclass

	qui {
	syntax , Folder(string) [RECursive]

	*Run the part of the command that may be recurisive
	noi iecompressall_rec, folder("`folder'/`dir'") `recursive'

	*Display the aggregated result
	noi di ""
	noi di "Total before: `r(ret_before)'"
	noi di "Total after: `r(ret_after)'"
	noi di "Total gain: `r(ret_gain)'"

	local total_before  = substr("`r(ret_before)'" ,1 ,6) + "MB"
	local total_after  	= substr("`r(ret_after)'" ,1 ,6) + 	"MB"
	local total_gain  	= substr("`r(ret_gain)'" ,1 ,6) + 	"MB"

	* SI_NOTE: Designed for 8 digit numbers (6 numeric +"MB", "KB", etc.)
	* SI_NOTE: There still needs to be code for the result that is less than 6 digits
	noi di as text	"{c TLC}{hline 10}{c TT}{hline 10}{c TT}{hline 10}{c TT}{hline 60}"
	noi di as text  "{c |}{dup 2: }Total{dup  3: }{c |}{dup 2: }Total{dup 3: }{c |}{dup 2: }Total{dup 3: }{c |}"
	noi di as text  "{c |}{dup 2: }before{dup 2: }{c |}{dup 2: }after{dup 3: }{c |}{dup 2: }gain{dup  4: }{c |}"
	noi di as text	"{c |}{hline 10}{c |}{hline 10}{c |}{hline 10}{c |}{hline 60}"
	noi di as text  "{c |}{dup 1: }`total_before'{dup 1: }{c |}{dup 1: }`total_after'{dup 1: }{c |}{dup 1: }`total_gain'{dup 1: }{c |}"
	noi di as text	"{c BLC}{hline 10}{c BT}{hline 10}{c BT}{hline 10}{c BT}{hline 60}"

}

end

*local x=112123333
*local simp=	round(`x'/1000000, .2)
*di "`simp' GB"

******************************************
******************************************
******************************************

* This subroutine is made to be suitable for
* a recursive call on all subfolders
cap program drop 	iecompressall_rec
	program define	iecompressall_rec, rclass

qui {
	syntax , Folder(string) [RECursive]

	*Set up locals summing the total
	local sum_before	0
	local sum_after 	0
	local sum_gain		0

	********************
	*
	*	Compress files in this folder
	*
	********************

	*Create a list of all the .dta files in this folder
	local flist : dir `"`folder'"' files "*.dta" ,respectcase

	noi di "In folder `folder':"

	*Loop over all files in this folder
	foreach file of local flist {

		*Open and compress the data file
		cap use "`folder'/`file'", clear

		*File was possible to open, proceed as normal
		if _rc == 0 {

			*Get file size of file before compressing
			filesize , file("`folder'/`file'")
			local before = `r(filesize)'

			*Only include data sets wioth at least 1 observation
			if _N > 0 {

				*Compress the data set
				compress

				*Replace the original file
				save "`folder'/`file'", replace


				*Get file size of file after compressing
				filesize , file("`folder'/`file'")
				local after = `r(filesize)'

				*Calculate desk space gain (unit is byte)
				local gain = `before' - `after'

				noi di "BEFORE: `before' ; AFTER: `after' ; GAIN: `gain' ; FILE: `file'"

			}
			else {

				*Calculate desk space gain (unit is byte)
				local gain = 0
				local after = `before'

				noi di as error "FILE: `file' cannot be compresses as it has no observations and is therefore skipped"
			}

			*Add the stats for this file
			local sum_before	= `sum_before' 	+ `before'
			local sum_after 	= `sum_after' 	+ `after'
			local sum_gain		= `sum_gain' 	+ `gain'
		}

		*File was not possible to open, perhaps illegal chars like ` and $ in name
		*SI_NOTE: Isn't this when stata cannot find the file due to typo etc? :  search r(601), local
		else if _rc == 601 {

			noi di as error "FILE: `file' ; cannot be opened and is therefore skipped"

		}

		else if _rc == 610 {

			noi di as error "FILE: `file' is not Stata format. The file is skipped"

		}
		*For all other error codes, throw and uncaught error.
		else {

			local rc = _rc
			noi di as error "FILE: `file' ; Uncaught error when opening file `file'. Error code: `rc'."

		}

	}

	********************
	*
	*	If recursive is used apply to all sub-directories as well
	*
	********************

	*If recursive is used, list all sub-folders and run on them
	if "`recursive'" != "" {
		local dlist : dir `"`folder'"' dirs "*"

		*Loop over all sub-folders
		foreach dir of local dlist {

			*Recursive call
			noi iecompressall_rec, folder("`folder'/`dir'") `recursive'

			*Aggregate byte data from recursive call
			local sum_before	= `sum_before' 	+ `r(ret_before)'
			local sum_after 	= `sum_after' 	+ `r(ret_after)'
			local sum_gain		= `sum_gain' 	+ `r(ret_gain)'
		}
	}

	********************
	*
	*	Return data
	*
	********************

	*REturn the data up the recursive chain
	return local ret_before `sum_before'
	return local ret_after 	`sum_after'
	return local ret_gain 	`sum_gain'
}
end

******************************************
******************************************
******************************************

* This subroutine is a very quick way to
* get the file size of a file saved to desk
cap program drop 	filesize
	program define	filesize, rclass

	syntax , file(string)

	file open fh using  "`file'", read binary
	file seek fh eof
	file close fh

	return local filesize `r(loc)'

end
