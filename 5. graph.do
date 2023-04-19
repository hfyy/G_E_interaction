global data /Users/yiyuehuangfu/Desktop/PGS_early condition/data

/**********************************
******    prob of surviving to age 100 with no T2D, single decrement 
**********************************/ 

use "$data/obe_diab",clear

 
sort GE  decile age 

bys GE decile : g p100 = diabSx[51]

		
 twoway (line p100 decile if GE ==1) || ///
        (line p100 decile if GE ==2 ,lp(dash)) || ///
		(line p100 decile if GE==3, lp(dash))  || ///
		(line p100 decile if GE ==4, lp(dash))  || ///
		(line p100 decile if GE == 0),  ///
		legend(order(1 "CF1: GxE = 0.57(HRS)"  2 "CF2: GxE =1.2" 3 "CF3: GxE =0.18" 4 "CF4: GxE =0.06"  5 "Observed" )) ///
		xtitle("Deciles of BMI PRS") ytitle("Pr. surviving to age 100 w/o T2D")  ///
		ylab(0(0.05)0.4, angle(0)) ///
		xlabel(1(1)10) xline(5 10, lpattern(dot) lcolor(grey) ) 
	
	********
******    prob of surviving to age 100 with no disability, single decrement 
**********************************/ 

use "$data/obe_adl",clear
sort GE  decile age 

drop if decile ==0

bys GE decile : g p100 = adlSx[51]

 twoway (line p100 decile if GE ==1) || ///
        (line p100 decile if GE ==2 ,lp(dash)) || ///
		(line p100 decile if GE==3, lp(dash))  || ///
		(line p100 decile if GE ==4, lp(dash))  || ///
		(line p100 decile if GE == 0),  ///
		legend(order(1 "CF1: GxE = 0.57(HRS)"  2 "CF2: GxE =1.2" 3 "CF3: GxE =0.18" 4 "CF4: GxE =0.06"  5 "Observed" )) ///
		xtitle("Deciles of BMI PRS") ytitle("Pr. surviving to age 100 w/o disability") ///
		ylab(0(0.05)0.4 , angle(0)) ///
		xlabel(1(1)10) xline(5 10, lpattern(dot) lcolor(grey) )
		
		
/**********************************
******    exp yrs to live with/out T2D
**********************************/ 

use "$data/diabmort_joint",clear

 twoway (line diabEx decile if GE ==1  & age ==50) || ///
        (line diabEx decile if GE ==2  & age ==50,lp(dash)) || ///
		(line diabEx decile if GE ==3  & age ==50, lp(dash))  || ///
		(line diabEx decile if GE==4  & age ==50, lp(dash))  || ///
		(line diabEx decile if GE ==0 & age ==50) , ///
		legend(order(1 "CF1: GxE = 0.57(HRS)"  2 "CF2: GxE =1.2" 3 "CF3: GxE =0.18" 4 "CF4: GxE =0.06"  5 "Observed" )) ///
		xtitle("Deciles of BMI PRS")   ///
		ylab(28(1)40, angle(0)) ytitle("Exp. years of life at age 50 w/o T2D ") ///
		xlabel(1(1)10) xline(5 10, lpattern(dot) lcolor(grey) ) 
		
		
 twoway (line meanEx_withdiab decile if GE ==1  & age ==50) || ///
        (line meanEx_withdiab decile if GE ==2  & age ==50,lp(dash)) || ///
		(line meanEx_withdiab decile if GE ==3  & age ==50, lp(dash))  || ///
		(line meanEx_withdiab decile if GE==4  & age ==50, lp(dash))  || ///
		(line meanEx_withdiab decile if GE ==0 & age ==50) , ///
		legend(order(1 "CF1: GxE = 0.57(HRS)"  2 "CF2: GxE =1.2" 3 "CF3: GxE =0.18" 4 "CF4: GxE =0.06"  5 "Observed" )) ///
		xtitle("Deciles of BMI PRS")  ///
		 ylab(10(1)20, angle(0)) ytitle("Exp. years of life to live with T2D after age 50")  ///
		xlabel(1(1)10) xline(5 10, lpattern(dot) lcolor(grey) )
	
	
/**********************************
******    exp yrs to live with/out adl
**********************************/ 

use "$data/adlmort_joint",clear

 twoway (line adlEx	 decile if GE ==1  & age ==50) || ///
        (line adlEx decile if GE ==2  & age ==50,lp(dash)) || ///
		(line adlEx decile if GE ==3  & age ==50, lp(dash))  || ///
		(line adlEx decile if GE==4  & age ==50, lp(dash))  || ///
		(line adlEx decile if GE ==0 & age ==50) , ///
		legend(order(1 "CF1: GxE = 0.57(HRS)"  2 "CF2: GxE =1.2" 3 "CF3: GxE =0.18" 4 "CF4: GxE =0.06"  5 "Observed" )) ///
		xtitle("Deciles of BMI PRS")   ///
		ylab(28(1)40,angle(0)) ytitle("Exp. years of life at age 50 w/o disability ") ///
		xlabel(1(1)10) xline(5 10, lpattern(dot) lcolor(grey) )
	
		
		
 twoway (line meanEx_withadl decile if GE ==1  & age ==50) || ///
        (line meanEx_withadl decile if GE ==2  & age ==50,lp(dash)) || ///
		(line meanEx_withadl decile if GE ==3  & age ==50, lp(dash))  || ///
		(line meanEx_withadl decile if GE==4  & age ==50, lp(dash))  || ///
		(line meanEx_withadl decile if GE ==0 & age ==50) , ///
		legend(order(1 "CF1: GxE = 0.57(HRS)"  2 "CF2: GxE =1.2" 3 "CF3: GxE =0.18" 4 "CF4: GxE =0.06"  5 "Observed" )) ///
		xtitle("Deciles of BMI PRS")  ///
		 ylab(10(1)20, angle(0)) ytitle("Exp. years to live w/ disability after age 50") ///
		xlabel(1(1)10) xline(5 10, lpattern(dot) lcolor(grey) )
