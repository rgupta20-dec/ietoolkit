*iecompressall testfile

cd "[directory]\DIME\iecompressall test"

foreach n of numlist 1/2 {
copy "data`n'.dta" "[directory]\DIME\iecompressall test\Test\file`n'.dta", replace
}

foreach n of numlist 3/4 {
copy "data`n'.dta" "[directory]\DIME\iecompressall test\Test\subfolder\file`n'.dta", replace
}


* For error of no obs datafile, also run:
copy "data6.dta" "[directory]\DIME\iecompressall test\Test\file6.dta", replace
*rm "[directory]\DIME\iecompressall test\Test\file6.dta"

* For error of non-stata datafile, also run:
copy "data5.dta" "[directory]\DIME\iecompressall test\Test\file5.dta", replace
*rm "[directory]\DIME\iecompressall test\Test\file5.dta"

qui do "C:\Users\Saori\Documents\Github\ietoolkit-main\src\ado_files\iecompressall.ado"
qui do "C:\Users\Saori\Documents\Github\ietoolkit-main\src\ado_files\ieddtab.ado"


iecompressall, folder("[directory]\DIME\iecompressall test\Test") 

*[RECursive]
*r(610)   = not stata format



