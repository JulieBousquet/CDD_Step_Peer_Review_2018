
	*Statistics for analysis

	*a = Autre 
	*b = Ne sait pas
	*c = Non applicable
	*d = Refuse de répondre
	
	*Part 2: Descriptive Statistics	
	global G1_cdd_type				0
	global G6_social_cohesion		0
	global G9_cleavages				0		
	global G11_conflict_intensity 	0
	global G14_conflict_resolwho_hh	0
	

	global hist		0

	*Gen graph options
	global graph_opts ///
		title(, justification(left) color(black) span pos(11)) ///
		graphregion(color(white) lc(white) lw(med)) /// 
		ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) ///
		yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))

	global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'
	*		ylab($pct) ///
	*		${graph_opts} ///
	


	if $G1_cdd_type{
	
	*Pie chart showing the Sous Projet by sector
		
		*ExAnte Household
		use "$final/EA_HH.dta", clear
		*Keep only the village level info
		bys cddid: gen n = _n
		drop if n != 1
		drop n
		*Merge with ExAnte Chief
		merge 1:1 cddid using "$final/EA_CH.dta", force gen(exante_ch)
		*Merge with ExPost Household
		merge 1:m cddid using "$final/EP_HH.dta", force gen(expost_hh)
		*Keep only the village level info
		bys cddid: gen n = _n
		drop if n != 1
		*Merge with ExPost Chief
		merge 1:1 cddid using "$final/EP_CH.dta", force gen(expost_ch)

		*Graph
		graph pie, 	over(cdd_sector) ///
				pie(_all, explode(tiny)) ///
				plabel(_all percent, size(small) format(%4.0g))  ///
				name(cdd_sector, replace) ///
				title("Sectors of CDD projects") ///
				note("Sample size: 161 CDDs" "The pie displays all the CDDs where the data was collected")
		
		graph export "$out/01_Sector_STEP.png", width(4000) replace	
	}
	*-* 
	
	if $G6_social_cohesion{
	
	*Show the trust that individuals hold on each other
	*Sense of social cohesion 
	
	*ExAnte Household
	use "$final/EA_HH.dta", clear
	*Append to ExPost Household
	append using "$final/EP_HH.dta"	, force
	*Keep variables of interest
	keep 	q60_trustfamily q61_trustvillage q62_trustothervillage q63_trustethnic ///
			q64_trustotherethnic q65_trustexsoldier cdd_var hhid cddid data_type

	tab q60_trustfamily, m 
	tab q61_trustvillage, m 
	tab q62_trustothervillage, m 
	tab q63_trustethnic, m 
	tab q64_trustotherethnic, m 
	tab q65_trustexsoldier, m
	codebook q61_trustvillage
	
	*Aggregate
	*Recode for graph
	*0 No 1 Maybe 2 Prob 3 Certain
	*1 Maybe 2 Yes 3 No
	local trust q60_trustfamily q61_trustvillage q62_trustothervillage q63_trustethnic ///
				q64_trustotherethnic q65_trustexsoldier
	foreach var of local trust{
	rename `var' `var'_1
	recode `var'_1 	(0 = 3) ///
					(1 = 1) ///
					(2 3 = 2) ///
					, gen(`var') 
		
		lab def yesnomaybe 1 "Maybe" 2 "Yes" 3 "No" , modify
		lab val `var' yesnomaybe 
	drop `var'_1 
	}
		
	*FIRST WAY 

	*As it is difficult to display all the variables in one,
	*I issue individual graphs
	
	
	*Trust in family members
	bys data_type: tab q60_trustfamily
	graph hbar , over(q60_trustfamily, label(labcolor(black))) ///
				by(data_type) over(cdd_var) asyvars stack showyvars ///
				yvaroptions(axis(off)) bar(3,color(white)) blabel(bar, color(white) ///
				position(center) size(small) format(%4.0g)) ///
				ytitle("Var: q60_trustfamily", size(small)) yscale(noline) ///
				ylabel(none, labels labsize(zero) ///
				labcolor(white) angle(zero) labgap(zero) ///
				noticks nogrid) ymtick(, valuelabel) ///
				yscale(alt) legend(order(1 "Maybe" 2 "Yes"))  ///
				by(,title("Trust in family members (percent)")) ///	
				by(,subtitle("Would you lend money to a family member to do your pruchases?", size(small))) ///
				by(,note("Sample size: 1596 HHs (161 CDDs) EA and 675 hhs (68 CDDs) EP" "Yes = certainly and probably" "ExAnte and ExPost Household dataset")) ///
				name(q60_trustfamily, replace) 				
	graph 	export 	"$out/06_1_Trust_family.png", width(4000) replace
	
	*Trust in village
	bys data_type: tab q61_trustvillage
	graph hbar , over(q61_trustvillage, label(labcolor(black))) ///
				by(data_type) over(cdd_var) asyvars stack showyvars ///
				yvaroptions(axis(off)) bar(3,color(white)) blabel(bar, color(white) ///
				position(center) size(small) format(%4.0g)) ///
				ytitle("Var: q61_trustvillage", size(small)) yscale(noline) ///
				ylabel(none, labels labsize(zero) ///
				labcolor(white) angle(zero) labgap(zero) ///
				noticks nogrid) ymtick(, valuelabel) ///
				yscale(alt) legend(order(1 "Maybe" 2 "Yes")) ///
				by(,title("Trust in village members (percent)")) ///	
				by(,subtitle("Would you lend money to a village member to do your pruchases?", size(small))) ///
				by(,note("Sample size: 1582 HHs (161 CDDs) EA and 677 hhs (68 CDDs) EP" "Yes = certainly and probably" "ExAnte and ExPost Household dataset")) ///
				name(q61_trustvillage, replace) 				
	graph 	export 	"$out/06_2_Trust_village.png", width(4000) replace	
	
	*Trust in Other Village
	bys data_type: tab q62_trustothervillage	
	graph hbar , over(q62_trustothervillage, label(labcolor(black))) ///
				by(data_type) over(cdd_var) asyvars stack showyvars ///
				yvaroptions(axis(off)) bar(3,color(white)) blabel(bar, color(white) ///
				position(center) size(small) format(%4.0g)) ///
				ytitle("Var: q62_trustothervillage", size(small)) yscale(noline) ///
				ylabel(none, labels labsize(zero) ///
				labcolor(white) angle(zero) labgap(zero) ///
				noticks nogrid) ymtick(, valuelabel) ///
				yscale(alt) legend(order(1 "Maybe" 2 "Yes")) ///
				by(,title("Trust in members of other villages (percent)")) ///	
				by(,subtitle("Would you lend money to other village members to do your pruchases?", size(small))) ///
				by(,note("Sample size: 1582 HHs (161 CDDs) EA and 676 hhs (68 CDDs) EP" "Yes = certainly and probably" "ExAnte and ExPost Household dataset")) ///
				name(q62_trustothervillage, replace) 				
	graph 	export 	"$out/06_3_Trust_other_village.png", width(4000) replace
	
	*Trust in Ethnic
	bys data_type: tab q63_trustethnic	
	graph hbar , over(q63_trustethnic, label(labcolor(black))) ///
				by(data_type) over(cdd_var) asyvars stack showyvars ///
				yvaroptions(axis(off)) bar(3,color(white)) blabel(bar, color(white) ///
				position(center) size(small) format(%4.0g)) ///
				ytitle("Var: q63_trustethnic", size(small)) yscale(noline) ///
				ylabel(none, labels labsize(zero) ///
				labcolor(white) angle(zero) labgap(zero) ///
				noticks nogrid) ymtick(, valuelabel) ///
				yscale(alt) legend(order(1 "Maybe" 2 "Yes")) ///
				by(,title("Trust people of own ethnic in other village (in percent)", size(med))) ///	
				by(,subtitle("Would you lend money to people of your own ethnic in other village to do your pruchases?", size(small))) ///
				by(,note("Sample size: 1579 HHs (161 CDDs) EA and 674 hhs (68 CDDs) EP" "Yes = certainly and probably" "ExAnte and ExPost Household dataset"))  ///
				name(q63_trustethnic, replace) 				
	graph 	export 	"$out/06_4_Trust_ethnic.png", width(4000) replace		
	
	*Trust in Other Ethnics
	bys data_type: tab q64_trustotherethnic		
	graph hbar , over(q64_trustotherethnic, label(labcolor(black))) ///
				by(data_type) over(cdd_var) asyvars stack showyvars ///
				yvaroptions(axis(off)) bar(3,color(white)) blabel(bar, color(white) ///
				position(center) size(small) format(%4.0g)) ///
				ytitle("Var: q64_trustotherethnic", size(small)) yscale(noline) ///
				ylabel(none, labels labsize(zero) ///
				labcolor(white) angle(zero) labgap(zero) ///
				noticks nogrid) ymtick(, valuelabel) ///
				yscale(alt) legend(order(1 "Maybe" 2 "Yes")) ///
				by(,title("Trust people of another ethnic (percent)")) ///	
				by(,subtitle("Would you lend money to people of another ethnic to do your pruchases?", size(small))) ///
				by(,note("Sample size: 1556 HHs (161 CDDs) EA and 670 hhs (68 CDDs) EP" "Yes = certainly and probably" "ExAnte and ExPost Household dataset")) ///
				name(q64_trustotherethnic, replace) 				
	graph 	export 	"$out/06_5_Trust_other_ethnic.png", width(4000) replace
	
	*Trust in ExSoldier
	bys data_type: tab q65_trustexsoldier	
	graph hbar , over(q65_trustexsoldier, label(labcolor(black))) ///
				by(data_type) over(cdd_var) asyvars stack showyvars ///
				yvaroptions(axis(off)) bar(3,color(white)) blabel(bar, color(white) ///
				position(center) size(small) format(%4.0g)) ///
				ytitle("Var: q65_trustexsoldier", size(small)) yscale(noline) ///
				ylabel(none, labels labsize(zero) ///
				labcolor(white) angle(zero) labgap(zero) ///
				noticks nogrid) ymtick(, valuelabel) ///
				yscale(alt) legend(order(1 "Maybe" 2 "Yes")) ///
				by(,title("Trust in ex soliders (percent)")) ///	
				by(,subtitle("Would you lend money to ex soldiers to do your pruchases?", size(small))) ///
				by(,note("Sample size: 1596 HHs (161 CDDs) EA and 675 hhs (68 CDDs) EP" "Yes = certainly and probably" "ExAnte and ExPost Household dataset")) ///
				name(q65_trustexsoldier, replace) 				
	graph 	export 	"$out/06_7_Trust_ex_soldier.png", width(4000) replace
	
	*--------------------*
*/	
	*SECOND WAY
	
	local trust q60_trustfamily q61_trustvillage q62_trustothervillage q63_trustethnic ///
				q64_trustotherethnic q65_trustexsoldier
				
		foreach var of local trust{
			graph hbar, over(`var', ///
				label(labcolor(black))) by(cdd_var) by(data_type , legend(off)) asyvars stack showyvars ///
				yvaroptions(axis(off)) blabel(bar, color(white) ///
				position(center) size(medsmall) format(%4.0g)) bar(3,color(white)) ///
				ytitle("Var: `var'", size(medsmall)) yscale(noline) ///
				ylabel(none, labels labsize(tiny) ///
				labcolor(white) angle(zero) labgap(zero) ///
				noticks nogrid) ymtick(, valuelabel) ///
				yscale(alt) legend(off) legend(order(1 "Maybe" 2 "Yes")) ///
				name(`var', replace) by(,note("")) subtitle(, size(zero) color(ltblue) nobox)
		}
		graph close _all
		
		set graph on
        graph dir, memory // These named graphs are now in memory
						
		grc1leg2 	q60_trustfamily q61_trustvillage q62_trustothervillage q63_trustethnic ///
					q64_trustotherethnic q65_trustexsoldier ///
		, cols(2) imargin(0 0 0 0) ycommon xcommon ///
		legendfrom(q60_trustfamily) ///
		title("Level of Trust (percent)") ///
		subtitle("Would you lend money to the following groups to do your pruchases?" "ExAnte                        ExPost                                ExAnte                                ExPost", size(medsmall)) ///
		note("Sample size over the 6 variables: 1604 hhs EA (161 CDDs) and 678 hhs EP (68 CDDs)" "Yes = certainly and probably" "ExAnte and ExPost Household dataset") 
		
		graph export 	"$out/06_0_Trust_overall.png", width(4000) replace
	
	}
	*-* 
	
	if $G9_cleavages { 
	
	*Divisions within village
	*Indiiduals rank their level of feeling of divisions between rich and 
	*poor, etc.
	
	use "$final/EA_HH.dta", clear
	append using "$final/EP_HH.dta", force	
	
	keep 	q67a_divisionranking q67b_divisionranking q67c_divisionranking ///
			q67d_divisionranking q67e_divisionranking q67f_divisionranking ///
			q67g_divisionranking  ///
			cdd_var hhid cddid data_type
	
	local cleavages q67a_divisionranking q67b_divisionranking q67c_divisionranking ///
					q67d_divisionranking q67e_divisionranking q67f_divisionranking ///
					q67g_divisionranking   
	foreach var of local cleavages{
		tab `var', m
		replace `var' = . if `var' == .c
	}
	
	*Conflict WITHIN and BETWEEN villages on real estate
	foreach var of local cleavages{ 
		preserve
		keep cddid hhid `var'
		drop if `var' == .
		tab `var'
		distinct cddid
		distinct hhid
		restore
	}
	
	
	*The top cleavage for each individual will be stored
	*in this variable
	gen cleavage_n1 = 1 if q67a_divisionranking == 1
	replace cleavage_n1 = 2 if q67b_divisionranking == 1
	replace cleavage_n1 = 3 if q67c_divisionranking == 1
	replace cleavage_n1 = 4 if q67d_divisionranking == 1
	replace cleavage_n1 = 5 if q67e_divisionranking == 1
	replace cleavage_n1 = 6 if q67f_divisionranking == 1
	replace cleavage_n1 = 7 if q67g_divisionranking == 1
	
	tab cleavage_n1, m

	*The second cleavage for each individual will be stored
	*in this variable	
	gen cleavage_n2 = 1 if q67a_divisionranking == 2
	replace cleavage_n2 = 2 if q67b_divisionranking == 2
	replace cleavage_n2 = 3 if q67c_divisionranking == 2
	replace cleavage_n2 = 4 if q67d_divisionranking == 2
	replace cleavage_n2 = 5 if q67e_divisionranking == 2
	replace cleavage_n2 = 6 if q67f_divisionranking == 2
	replace cleavage_n2 = 7 if q67g_divisionranking == 2

	tab cleavage_n2, m

	*The third cleavage for each individual will be stored
	*in this variable	
	gen cleavage_n3 = 1 if q67a_divisionranking == 3
	replace cleavage_n3 = 2 if q67b_divisionranking == 3
	replace cleavage_n3 = 3 if q67c_divisionranking == 3
	replace cleavage_n3 = 4 if q67d_divisionranking == 3
	replace cleavage_n3 = 5 if q67e_divisionranking == 3
	replace cleavage_n3 = 6 if q67f_divisionranking == 3
	replace cleavage_n3 = 7 if q67g_divisionranking == 3

	tab cleavage_n3, m	
	
	lab def rank 	1 "rich/poor" 2 "men/women" 3 "young/old" 4 "indigen/new" 5 "diff rel" ///
					6 "diff ethn" 7 "elites" , modify
					
	label val cleavage_n1 rank
	label val cleavage_n2 rank
	label val cleavage_n3 rank

	tab cleavage_n1, m		
	tab cleavage_n2, m		
	tab cleavage_n3, m	
	
	*The question is: 3 OPTIONS LES PLUS IMPORTANTES, so people answered only three
	tab cleavage_n1 data_type		
	graph hbar , over(cleavage_n1, label(labcolor(black) labsize(small))) ///
				by(data_type cdd_var, legend(off))  ///
				asyvars showyvars ///
				yvaroptions(axis(off)) blabel(bar, color(white) ///
				position(center) size(tiny) format(%4.0g)) ///
				ytitle("Var: q67*_divisionranking", size(small)) yscale(noline) ///
				ylabel(none, labels labsize(tiny) ///
				labcolor(white) angle(zero) labgap(zero) ///
				noticks nogrid) ymtick(, valuelabel) ///
				yscale(alt) legend(off) ///
				by(,title("Cleavages (percent)")) ///	
				by(,subtitle("Most important cleavages in the village according to individuals", size(small))) ///
				by(,note("Sample size: 413 hhs EA and 177 hhs EP" "Variables q67*_divisionranking asked individuals to rank the 3 most prevalent cleavages" "Graph shows only rank number one, the first most prevalent cleavage" "ExAnte and ExPost Household dataset", size(small))) ///
				name(number1, replace) 

	graph 	export 	"$out/09_Cleavages_number_one.png", width(4000) replace

	}
	*-* 
	
	if $G11_conflict_intensity {
	
	*Measure and represenation of conflict intensity (meaning the number
	*of conflict) within the village or between village
	
	use "$final/EA_HH.dta", clear
	append using "$final/EP_HH.dta"	, force
	
	keep 	cdd_var hhid cddid data_type ///
			q69_conflictrealestate q69b_conflictrealestate_many q69d_conflictrealestate_mpwho ///
			q69c_conflictrealestate_manypeac q70_conflictdowry q70b_conflictdowry_many ///
			q70c_conflictdowry_manypeace q70d_conflictdowry_manypeacewho q71_conflictethnic ///
			q71b_conflictethnic_many q71c_conflictethnic_manypeace q71d_conflictethnic_manypeacewho ///
			q72_conflictburglary q72b_conflictburglary_many q72c_conflictburglary_manypeace ///
			q72d_conflictburglary_manypeacew q73_conflictphysical q73b_conflictphysical_many ///
			q73c_conflictphysical_manypeace q73d_conflictphysical_manypeacew q74_conflictdomestic ///
			q74b_conflictdomestic_many q74c_conflictdomestic_manypeace q74d_conflictdomestic_manypeacew ///
			q75_conflictmurder q75b_conflictmurder_many q75c_conflictmurder_manypeace ///
			q75d_conflictmurder_manypeacewho q76_conflictrealestate q76b_conflictrealestate_many ///
			q76d_conflictrealestate_mpwho q76c_conflictrealestate_manypeac q77_conflictdowry ///
			q77b_conflictdowry_many q77c_conflictdowry_manypeace q77d_conflictdowry_manypeacewho ///
			q78_conflictethnic q78b_conflictethnic_many q78c_conflictethnic_manypeace ///
			q78d_conflictethnic_manypeacewho q79_conflictburglary q79b_conflictburglary_many ///
			q79c_conflictburglary_manypeace q79d_conflictburglary_manypeacew q80_conflictphysical ///
			q80b_conflictphysical_many q80c_conflictphysical_manypeace q80d_conflictphysical_manypeacew ///
			q81_conflictmurder q81b_conflictmurder_many q81c_conflictmurder_manypeace ///
			q81d_conflictmurder_manypeacewho
		
		
	lab var q69b_conflictrealestate_many "Within village conflict : Real Estate"
	lab var q70b_conflictdowry_many "Within village conflict : Dowry"
	lab var q71b_conflictethnic_many "Within village conflict : Ethnics"
	lab var q72b_conflictburglary_many "Within village conflict : Burglary"
	lab var q73b_conflictphysical_many "Within village conflict : Physical"
	lab var q74b_conflictdomestic_many "Within village conflict : Domestic"
	lab var q75b_conflictmurder_many "Within village conflict : Murder"
	lab var q76b_conflictrealestate_many "Between village conflict : Real Estate"
	lab var q77b_conflictdowry_many "Between village conflict : Dowry"
	lab var q78b_conflictethnic_many "Between village conflict : Ethnic"
	lab var q79b_conflictburglary_many "Between village conflict : Burglary"
	lab var q80b_conflictphysical_many "Between village conflict : Physical"
	lab var q81b_conflictmurder_many "Between village conflict : Murder"

	***********
	*FIRST WAY*
	***********
	
	*1 Conflict intensity	
	local conflict_many 	q69b_conflictrealestate_many q70b_conflictdowry_many q71b_conflictethnic_many ///
							q72b_conflictburglary_many q73b_conflictphysical_many q74b_conflictdomestic_many ///
							q75b_conflictmurder_many ///
							q76b_conflictrealestate_many q77b_conflictdowry_many q78b_conflictethnic_many ///
							q79b_conflictburglary_many q80b_conflictphysical_many q81b_conflictmurder_many	

	*Replace by 0 if na
	foreach var of local conflict_many {
		tab `var', m
		replace `var' = 0 if `var' == .c		
	}
	
	foreach var of local conflict_many {
		tab `var' data_type
	}
	
		foreach var of local conflict_many {	
			histogram 	`var', bin(20) fcolor(sand) lcolor(white) ///
			normal normopts(lcolor(erose)) ytitle(, color(navy)) yscale(noline) ///
			ylabel(, labsize(vsmall) labcolor(navy) noticks nogrid) ymtick(none, nolabels noticks nogrid) ///
			ytitle("") xtitle(Var: `var') ///
			xtitle(, size(tiny) color(navy)) xscale(noline) xlabel(none) ///
			xmtick(none, labcolor(navy) noticks nogrid) ///
			by(, legend(off)) by(data_type cdd_var) subtitle(, size(vsmall) color(navy) nobox) ///
			by(,note("")) name(`var', replace)
		}

		graph close _all
		
		set graph on
        graph dir, memory // These named graphs are now in memory
		
		*Within
		grc1leg2 	q69b_conflictrealestate_many q70b_conflictdowry_many q71b_conflictethnic_many ///
					q73b_conflictphysical_many q74b_conflictdomestic_many q75b_conflictmurder_many ///
		, cols(2) imargin(0 0 0 0) ycommon xcommon ///
		legendfrom(q69b_conflictrealestate_many) ///
		title("Conflict Intensity within village", size(vsamll)) ///
		subtitle("Distribution of Conflict by cdd variation and type of survey", size(tiny)) ///
		note("Sample size: 1604 HHs for 161 CDDs" "Real Estate: 278 EA & 178 EP ; Dowry: 89 EA & 32 EP ; Ethnics: 43 EA & 32 EP  ; Physical: 138 EA & 77 EP ; Murder: 112 EA & 67 EP" "Domestic: 105 EA & 47 EP" "ExAnte and ExPost Household dataset", size(tiny)) 
					
		graph export 	"$out/11_1_Conflict_within_distrib.png", width(4000) replace	
		
		*Between
		grc1leg2	q76b_conflictrealestate_many q77b_conflictdowry_many q78b_conflictethnic_many ///
					q79b_conflictburglary_many q80b_conflictphysical_many q81b_conflictmurder_many ///
		, cols(3) imargin(0 0 0 0) ycommon xcommon ///
		legendfrom(q76b_conflictrealestate_many) ///
		title("Conflict Intensity between villages", size(vsmall)) ///
		subtitle("Distribution of Conflict by cdd variation and type of survey", size(tiny)) ///
		note("Real Estate: 111 EA & 51 EP ; Dowry: 23 EA & 13 EP ; Ethnics: 41 EA & 9 EP ; Burglary: 126 EA & 76 EP ; Physical: 40 EA & 20 EP ; Murder: 94 EA & 62 EP" "ExAnte and ExPost Household dataset", size(tiny)) 
		
		graph export 	"$out/11_2_Conflict_between_distrib.png", width(4000) replace	
		
		
	************
	*SECOND WAY*
	************
	
		local conflict_many 	q69b_conflictrealestate_many q70b_conflictdowry_many q71b_conflictethnic_many ///
								q72b_conflictburglary_many q73b_conflictphysical_many q74b_conflictdomestic_many ///
								q75b_conflictmurder_many ///
								q76b_conflictrealestate_many q77b_conflictdowry_many q78b_conflictethnic_many ///
								q79b_conflictburglary_many q80b_conflictphysical_many q81b_conflictmurder_many	
		
		*Weighted average by project
		foreach var of local conflict_many {
			egen 	su_`var' = sum(`var') if `var' != . & `var' != .d & `var' != .c & `var' != .b , by(cddid)
			egen 	su_cddid = count(cddid) if `var' != . & `var' != .d & `var' != .c & `var' != .b , by(cddid)
			gen 	w_`var' = su_`var' / su_cddid
			lab var w_`var' "Weighted Average `var'"
			drop 	su_`var' su_cddid
		}
		
		local conflict_many_w 	w_q69b_conflictrealestate_many w_q70b_conflictdowry_many ///
								w_q71b_conflictethnic_many ///
								w_q72b_conflictburglary_many w_q73b_conflictphysical_many ///
								w_q74b_conflictdomestic_many w_q75b_conflictmurder_many ///
								w_q76b_conflictrealestate_many w_q77b_conflictdowry_many ///
								w_q78b_conflictethnic_many w_q79b_conflictburglary_many ///
								w_q80b_conflictphysical_many w_q81b_conflictmurder_many
		
		
		foreach var of local conflict_many_w {
			preserve		
			bys cddid: gen n = _n
			drop if n != 1
			keep `var' hhid data_type cddid cdd_var
			reshape wide `var', i(cddid) j(cdd_var)
	
			graph hbar (mean) `var'1 `var'2 `var'3, ///
			by(data_type) blabel(bar, color(white) position(center) size(medsmall) format(%5.0g))	///
			graphregion(color(white) lc(white) lw(med)) ///
			ylabel(none, labels labsize(zero) ///
			labcolor(white) angle(zero) labgap(zero) ///
			noticks nogrid)	///
			ymtick(, valuelabel) yscale(noline) ///
			by(,legend(off)) by(,note("")) legend(order(1 "CDD" 2 "CDD +" 3 "Ctrl")) ///
			ytitle("Var: `var'", size(small)) ///
			name(`var', replace) subtitle(, size(zero) color(ltblue) nobox)	
			
			restore 
		}

		graph close _all
		
		set graph on
        graph dir, memory // These named graphs are now in memory
						
		grc1leg2 	w_q69b_conflictrealestate_many /// 
					w_q70b_conflictdowry_many ///
					w_q72b_conflictburglary_many ///
					w_q73b_conflictphysical_many ///
					w_q74b_conflictdomestic_many ///
					w_q75b_conflictmurder_many ///
					w_q76b_conflictrealestate_many  ///
					w_q79b_conflictburglary_many ///
					w_q81b_conflictmurder_many ///
		, cols(3) imargin(0 0 0 0) ycommon xcommon ///
		legendfrom(w_q70b_conflictdowry_many) ///
		title("Conflict Intensity", size(small)) ///
		subtitle("Weighted Average (per CDDID) of number of conflicts" "ExAnte                        ExPost                          ExAnte                              ExPost                                  ExAnte                             ExPost", size(vsmall)) ///
		note("ExAnte and ExPost Household dataset", size(vsmall)) 
		
		graph export 	"$out/11_3_Conflict_nb_w_average.png", width(4000) replace		

	}
	*-*  
	
	if $G14_conflict_resolwho_hh {
	
	*Who resolved these conflicts 
	
	use "$final/EA_HH.dta", clear
	append using "$final/EP_HH.dta", force	
	
	keep 	cdd_var hhid cddid data_type ///
			q69_conflictrealestate q69b_conflictrealestate_many q69d_conflictrealestate_mpwho ///
			q69c_conflictrealestate_manypeac q70_conflictdowry q70b_conflictdowry_many ///
			q70c_conflictdowry_manypeace q70d_conflictdowry_manypeacewho q71_conflictethnic ///
			q71b_conflictethnic_many q71c_conflictethnic_manypeace q71d_conflictethnic_manypeacewho ///
			q72_conflictburglary q72b_conflictburglary_many q72c_conflictburglary_manypeace ///
			q72d_conflictburglary_manypeacew q73_conflictphysical q73b_conflictphysical_many ///
			q73c_conflictphysical_manypeace q73d_conflictphysical_manypeacew q74_conflictdomestic ///
			q74b_conflictdomestic_many q74c_conflictdomestic_manypeace q74d_conflictdomestic_manypeacew ///
			q75_conflictmurder q75b_conflictmurder_many q75c_conflictmurder_manypeace ///
			q75d_conflictmurder_manypeacewho q76_conflictrealestate q76b_conflictrealestate_many ///
			q76d_conflictrealestate_mpwho q76c_conflictrealestate_manypeac q77_conflictdowry ///
			q77b_conflictdowry_many q77c_conflictdowry_manypeace q77d_conflictdowry_manypeacewho ///
			q78_conflictethnic q78b_conflictethnic_many q78c_conflictethnic_manypeace ///
			q78d_conflictethnic_manypeacewho q79_conflictburglary q79b_conflictburglary_many ///
			q79c_conflictburglary_manypeace q79d_conflictburglary_manypeacew q80_conflictphysical ///
			q80b_conflictphysical_many q80c_conflictphysical_manypeace q80d_conflictphysical_manypeacew ///
			q81_conflictmurder q81b_conflictmurder_many q81c_conflictmurder_manypeace ///
			q81d_conflictmurder_manypeacewho
	
	
	ren q69d_conflictrealestate_mpwho q69d_conf_realestate_mpw 
	ren q70d_conflictdowry_manypeacewho q70d_conf_dowry_mpw 
	ren q71d_conflictethnic_manypeacewho q71d_conf_ethnic_mpw 
	ren q72d_conflictburglary_manypeacew q72d_conf_burglary_mpw 
	ren q73d_conflictphysical_manypeacew q73d_conf_physical_mpw 
	ren q74d_conflictdomestic_manypeacew q74d_conf_domestic_mpw
	ren q75d_conflictmurder_manypeacewho q75d_conf_murder_mpw 
	ren q76d_conflictrealestate_mpwho q76d_conf_realestate_mpw 
	ren q77d_conflictdowry_manypeacewho q77d_conf_dowry_mpw 
	ren q78d_conflictethnic_manypeacewho q78d_conf_ethnic_mpw 
	ren q79d_conflictburglary_manypeacew q79d_conf_burglary_mpw
	ren q80d_conflictphysical_manypeacew q80d_conf_physical_mpw
	ren q81d_conflictmurder_manypeacewho q81d_conf_murder_mpw
	
	local conflict_mp_who 	q69d_conf_realestate_mpw q70d_conf_dowry_mpw q71d_conf_ethnic_mpw ///
							q72d_conf_burglary_mpw q73d_conf_physical_mpw q74d_conf_domestic_mpw ///
							q75d_conf_murder_mpw q76d_conf_realestate_mpw q77d_conf_dowry_mpw ///
							q78d_conf_ethnic_mpw q79d_conf_burglary_mpw q80d_conf_physical_mpw ///
							q81d_conf_murder_mpw
	
	*Transfrom and reshape
	foreach var of local conflict_mp_who {
		tab `var', m
		replace `var' = . if `var' == 0			
	}
	forvalues i = 1/19	{						
		foreach var in `conflict_mp_who' {
			gen `var'_`i' = .
			levelsof q69d_conf_realestate_mpw, local(levels)
			foreach level in `levels'{			
				replace `var'_`i' = 1 if `var' == `level' & `level' == `i'
			}
		}
		egen conf_resolv_`i' = rowtotal(q69d_conf_realestate_mpw_`i' q70d_conf_dowry_mpw_`i' ///
			q71d_conf_ethnic_mpw_`i' q72d_conf_burglary_mpw_`i' q73d_conf_physical_mpw_`i' ///
			q74d_conf_domestic_mpw_`i' q75d_conf_murder_mpw_`i' q76d_conf_realestate_mpw_`i' ///
			q77d_conf_dowry_mpw_`i' q78d_conf_ethnic_mpw_`i' q79d_conf_burglary_mpw_`i' ///
			q80d_conf_physical_mpw_`i' q81d_conf_murder_mpw_`i')	
		}
	
	keep 	hhid cddid cdd_var data_type conf_resolv_1 conf_resolv_2 conf_resolv_3 conf_resolv_4 ///
			conf_resolv_5 conf_resolv_6 conf_resolv_7 conf_resolv_8 conf_resolv_9 conf_resolv_10 ///
			conf_resolv_11 conf_resolv_12 conf_resolv_13 conf_resolv_14 conf_resolv_15 conf_resolv_16 ///
			conf_resolv_17 conf_resolv_18 conf_resolv_19
	
	preserve
		*1 st graph
		forvalues i = 1/19	{
			egen t_conf_resolv_`i' = count(conf_resolv_`i') if conf_resolv_`i' != 0, by(data_type)
		}
		
		collapse (count) t*, by(data_type)
		egen tot_conflict = rsum(t*)
		reshape long t_conf_resolv_, i(data_type) j(type_conflict) 
		bys data_type: gen pct_confl_resolv = (t_conf_resolv_ / tot_conflict)*100
		lab def type_conflict 	1 "Chief" 2 "Governor" 3 "Chief Territory" 4 "Chief Chieftancy" ///
								5 "Chief Government" 6 "Cheif Locality" 7 "Inhabitants" 8 "Sages" ///
								9 "Notables" 10 "Religious Authority" 11 "NGO" 12 "Deputy Province" ///
								13 "Deputy National" 14 "Government Kin" 15 "Police" 16 "Army" ///
								17 "Monusco" 18 "Armed Group" 19 "Other" , modify
		lab val type_conflict type_conflict
		
		graph hbar (mean) pct_confl_resolv, over(type_conflict, label(labcolor(navy) ///
				labsize(small)) axis(lcolor(navy))) by(data_type) blabel(bar, size(vsmall) ///
				color(navy) format(%4.0g)) ytitle(percent) yscale(noline) ///
				ylabel(, labcolor(navy) noticks nogrid) ytitle("") ///
				by(,title("Who solved the conflicts?")) ///
				by(,subtitle("Proportion of conflict solved by category")) ///
				by(,note("On a total of 758 conflicts reported" "ExAnte and ExPost Household dataset")) ///
	
		graph export 	"$out/14_1_Conflict_who_resolv_hh.png", width(4000) replace		
	restore
	*------*
		
	}
	*-* 
