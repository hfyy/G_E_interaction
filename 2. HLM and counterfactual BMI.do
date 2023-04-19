

clear all
set maxvar 32767


global data /Users/yiyuehuangfu/Desktop/PGS_early condition/data/working
   /* declare the location of the sample file generarted from 
      file 1. data cleaning to generate sample */ 
global log ****  
   /* decalre the location to store the output files */ 

/*****************************************************************************/

use "$data/sample10092021",clear

   
xtile pgs_q = bmi_giant15 if  n==1, n(10)
 tab pgs_q if n==1, sum(bmi_giant15) 
 
 bys hhidpn: egen pgs_q2 = mean(pgs_q)
  drop pgs_q 
  rename pgs_q2 pgs_q
  
  label define cohort 1"before 1925" 2 "1925-1934" 3 "1935-1944" 4 "1945-1959",modify
   label values cohort cohort


	 /* this is Walter's model + some controls 
	   mixed rbmi  bmi_giant15 i.cohort i.cohort#c.bmi_giant15   ///
  age_mc   age_mc2 i.raeduc i.GENDER   i.ec_q ///
     i.cohort#c.age_mc i.cohort#c.age_mc2  i.cohort#i.GENDER  ///
     c.bmi_giant15#c.age_mc  i.GENDER#c.age_mc  ///
      PC*  ||hhidpn: age_mc age_mc2   if RACE ==1   */ 
	  
	     
	
	 
	   
	 /* this is the model where cohort and PGS are interacted with all controls */ 
	 
  mixed rbmi  bmi_giant15 i.cohort i.cohort#c.bmi_giant15   ///
  age_mc   age_mc2 i.raeduc i.GENDER   i.ec_q ///
     i.cohort#c.age_mc i.cohort#c.age_mc2  i.cohort#i.raeduc  i.cohort#i.GENDER i.cohort#i.ec_q ///
     c.bmi_giant15#c.age_mc c.bmi_giant15#c.age_mc2 c.bmi_giant15#i.raeduc c.bmi_giant15#i.GENDER c.bmi_giant15#i.ec_q ///
      PC*  ||hhidpn: age_mc age_mc2   if RACE==1
	
	predict bmi_pdct 
  mark sample if e(sample)==1
	  
	 
	  twoway lfit bmi_pdct pgs_q if cohort ==1 || ///
	         lfit bmi_pdct pgs_q if cohort ==2 || ///
			 lfit bmi_pdct pgs_q if cohort == 3 || ///
			 lfit bmi_pdct pgs_q if cohort ==4, legend(order (1 "before 1925" 2 "1925-1934" 3 "1935-1944" 4 "1945-1959")) ///
			  xlabel(1(1)10) ytitle("Predicted BMI")  ylabel(24(1)32, angle(0)) xtitle("Deciles of BMI PRS")
 
	  
	  
	  
	  predict bmi_pdct
	  twoway qfit bmi_pdct age if cohort ==1 || ///
	         qfit bmi_pdct age if cohort ==2 || ///
			 qfit bmi_pdct age if cohort == 3 || ///
			 qfit bmi_pdct age if cohort ==4, legend(order (1 "before 1925" 2 "1925-1934" 3 "1935-1944" 4 "1945-1959")) ///
			  ytitle("Predicted BMI") ylabel(,angle(0))

	   outreg2 using "$log/bmi_01072023.xls", append dec(3) sideway
	   
	 
	 /* rescale PRS by setting the lowest score as 0. This is to subtract a constant from 
	 all PRS and will not change the coefficient on GxE */ 
	   sum bmi_giant15 
	 replace bmi_giant15 = bmi_giant15-r(min)
	 
	
	 /* to create counterfactual BMI */ 
	    g bmi_cf1 = rbmi - 0.568 * bmi_giant15 
		g bmi_cf2 = rbmi - 1.2*bmi_giant15
		g bmi_cf3 = rbmi - 0.18*bmi_giant15
		g bmi_cf4 = rbmi - 0.06*bmi_giant15

		
	
		g obe_cf1= 1 if bmi_cf1 >=30 & bmi_cf1 <.
		 replace obe_cf1 =0 if bmi_cf1 <30
		 
		 g obe_cf2 = 1 if bmi_cf2 >=30 & bmi_cf2 <.
		 replace obe_cf2 =0 if bmi_cf2 <30
		 
		 g obe_cf3 = 1 if bmi_cf3 >=30 & bmi_cf3 <.
		 replace obe_cf3 =0 if bmi_cf3 <30
		 
		 		 
		 g obe_cf4 = 1 if bmi_cf4 >=30 & bmi_cf4 <.
		 replace obe_cf4 =0 if bmi_cf4 <30
		 
		 
		
		save "$data/working/sample10092021_cf",replace
		
		 /* to plot counterfactual BMI */ 
twoway lfit rbmi pgs_q if cohort ==4   || ///
	         (lfit bmi_cf1 pgs_q if cohort ==4 ) , ///
			 legend(order ( 1 "Observed" 2 "CF: GxE = 0.57(HRS)" )) ///
			 ytitle("Observed and Counterfactual BMI") xtitle("Deciles of BMI PRS") xlabel(1(1)10)  ///
			 ylabel(24(1)32, angle(0))  ///
		xlabel(1(1)10) xline(5 10, lpattern(dot) lcolor(grey) )
			  
			  
		
		 twoway lfit rbmi pgs_q if cohort ==4   || ///
	         (lfit bmi_cf1 pgs_q if cohort ==4 ) || ///
			 (lfit bmi_cf2 pgs_q if cohort ==4, lpattern(dash)) || ///
			 (lfit bmi_cf3 pgs_q if cohort ==4, lpattern(dash)) || ///
			 (lfit bmi_cf4 pgs_q if cohort ==4, lpattern(dash)), ///
			 legend(order ( 1 "Observed" 2 "CF: GxE = 0.568(HRS)" 3 "CF: GxE =1.2" ///
			 4 "CF: GxE = 0.18" 5 "CF: GxE= 0.06" )) ytitle("BMI") xtitle("Deciles of BMI PRS")   ///
		  xtitle("Deciles of BMI PRS") ylabel(22(1)32,angle(0)) xlabel(1(1)10)
			
			
			
	   tabstat  rbmi bmi_cf1 bmi_cf2 bmi_cf3 bmi_cf4  if cohort ==4 & sample==1, by(pgs_q)
	   tabstat  obe obe_cf1 obe_cf2 obe_cf3 obe_cf4 if cohort ==4 & sample==1, by(pgs_q)
	   

	
	 
	
