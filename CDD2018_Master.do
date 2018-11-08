
*Master do file, analysis CDD

 clear all

	*Change the data path 
	if c(username)=="Julie" | c(username)=="WB527175" {
		global projectfolder	`"/users/`c(username)'/Dropbox/Peer Review 2018/CDD_project_Step_Julie"'
	}

			
	*********
	**  1  **
	*********
	
	*Master to locate the current folder where I start the analysis
	global master "$projectfolder"
		global 	data "$master/Dataset"
			global 	base 	"$data/01_Base"
			global 	temp 	"$data/02_Temp"
			global 	final 	"$data/03_Final"
		global  do   "$master/Dofiles"
		global  out  "$master/Output"
		
		
	*Globals
	global clean		0 /*Clean the EA HH , EA CH , EP HH and EP CH dataset*/
	global desc			0 /*Desc stat on EA and EP dataset*/
	global map			0 /*Use ACLED data to evaluate the conflict intensity*/
	global analysis		0 /*Not created yet*/
	global power		0 /*Assess the validity of a smaller sample*/
	
	

	if $clean{
		qui do "$do/CDD2018_Cleaning.do"
	}
	*-*		
	
	if $desc{
		qui do "$do/CDD2018_DescStat.do"
	}
	*-*
	
	if $map{
		qui do "$do/CDD2018_Mapping.do"
	}
	*-*	
	
	if $analysis{
		*qui do "$do/CDD2018_Analysis.do"
	}
	*-*	
	
	if $power{
		qui do "$do/CDD2018_PowerC.do"
	}
	*-*	
	
