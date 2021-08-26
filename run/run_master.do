
/*******************************************************************************
    PART 1:  Folder paths
*******************************************************************************/

    * Add the path to your local clone of the [ietoolkit] repo
    if "`c(username)'" == "WB462869" {
        global ietoolkit_clone   "C:\Users\wb462869\GitHub\ietoolkit"
    }

	* Creaet paths to the subfolders in the repo
	global 	runfiles  "${ietoolkit_clone}/run"
	global 	runoutput "${runfiles}/output"
	

/*******************************************************************************
    PART 2: Switches
*******************************************************************************/

    local iegitaddmd = 0
	local iekdensity = 0
	local iesave     = 1

/*******************************************************************************
    PART 3: iegitaddmd
*******************************************************************************/

		if `iegitaddmd' == 1 {
			do "${runfiles}/iegitaddmd.do"
		}

/*******************************************************************************
    PART 3: iekdensity
*******************************************************************************/

		if `iekdensity' == 1 {
			do "${runfiles}/iekdensity.do"
		} 

/*******************************************************************************
    PART 3: iesave
*******************************************************************************/

		if `iesave' == 1 {
			do "${runfiles}/iesave.do"
		} 