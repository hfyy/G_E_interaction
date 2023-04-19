
clear all
set maxvar 32767



global data **** /* declare the location of the sample file generarted from file 1. data cleaning to generate sample */ 
global log ****  /* decalre the location to store the output files */ 


/*****************************************************/
/*     obe  --- T2D                                  */ 
/*                                                   */ 
/*****************************************************/
use "$data/working/sample10092021",clear

  /// first calculate BMI and obesity in counterfactuals
   sum bmi_giant15 
	 replace bmi_giant15 = bmi_giant15-r(min)
	 
	    g bmi_cf1 = rbmi - 0.57 * bmi_giant15   // HRS estimate
		g bmi_cf2 = rbmi-1.2*bmi_giant15   
		g bmi_cf3 = rbmi-0.18*bmi_giant15
		g bmi_cf4 = rbmi-0.06*bmi_giant15
		
	
		g obe_cf1= 1 if bmi_cf1 >=30 & bmi_cf1 <.
		 replace obe_cf1 =0 if bmi_cf1 <30
		 
		 g obe_cf2 = 1 if bmi_cf2 >=30 & bmi_cf2 <.
		 replace obe_cf2 =0 if bmi_cf2 <30
		 
		 g obe_cf3 = 1 if bmi_cf3 >=30 & bmi_cf3 <.
		 replace obe_cf3 =0 if bmi_cf3 <30
		 
		 		 
		 g obe_cf4 = 1 if bmi_cf4 >=30 & bmi_cf4 <.
		 replace obe_cf4 =0 if bmi_cf4 <30
		 
		 save "$data/working/sample10092021_cf",replace
		 
		/////////////////////////////////////////
		
		// first decile, as observed
use "$data/working/sample10092021_cf",clear

   sort hhidpn wave
    drop n
    bys hhidpn: g n=_n

xtile decile = bmi_giant15 if  n==1, n(10)
 tab decile if n==1, sum(bmi_giant15) 
 
 bys hhidpn: egen decile2 = mean(decile)
  drop decile 
  rename decile2 decile
  
	      bys  hhidpn:  g age1992 = age if n ==1
	  bys hhidpn: egen age1992_2 = mean(age1992)
	  drop age1992
	  rename age1992_2 age1992
	  
	  rename GENDER MYGENDER
	    replace MYGENDER =0 if MYGENDER ==2 
	  tab raeduc, gen(MYEDUC)
	  
	  
	g year = 1992 + (wave -1) *2   
	g dead = 0 if year < radyear
	 replace dead =1 if year>=radyear-1

	 drop N
	 bys hhidpn wave:  g N = _N 
	  replace dead =1 if n ==N & year ==radyear -2 
	  

	 replace age = age-50 
	   stset age, failure(rdiab) id(hhidpn)
      streg age1992 MYGENDER MYEDUC1 MYEDUC3 i.obe if cohort ==4 & age>=0 , dist(gompertz) nohr  
	      outreg2 using "$log/haz_12152022.xls", append dec(3) sideway
	   
	 
	 rename obe obe_cf0 
	 sum obe_cf0 if cohort ==4 & decile ==1
   local obe r(mean)   
g para = exp(.007*51.54+.239*.42 + .055*.051 + .635*-.254+`obe'*1.12-5)
 
  
range agelt 50 100 51 
sort agelt

g diabhazx = para *exp((agelt-50)*.027)

gen diabcumSx=.
gen diabSx=.
gen diabIntx=.
gen diabEx=.
gen diabcumx=.

sort agelt
replace diabcumx=sum(diabhazx)
replace diabIntx=cond(_n>1, diabcumx[_n-1],0)
replace diabSx=exp(-diabIntx) // surviving at age x, l(x) 
 drop if agelt==. 
replace diabcumSx=sum(diabSx) // cumulative PY lived at age x 
replace diabEx=cond(_n>1, diabcumSx[_N]-diabcumSx[_n-1],diabcumSx[_N])
replace diabEx=diabEx/diabSx


keep agelt diabhazx diabcumSx diabSx diabIntx diabEx diabcumx 
 rename agelt age 
 drop if age==. 
 
 g decile = 1
 g GE = 0 // GxE =0 means as observed 
 
 save obe_diab,replace

 //other deciles for GE = 0 , as observed 
 
	   forvalues q = 2(1)10 {

    
use "$data/working/sample10092021_cf",clear

   sort hhidpn wave
    drop n
    bys hhidpn: g n=_n

xtile decile = bmi_giant15 if  n==1, n(10)
 tab decile if n==1, sum(bmi_giant15) 
 
 bys hhidpn: egen decile2 = mean(decile)
  drop decile 
  rename decile2 decile
  
  rename obe obe_cf0 
  
  sum obe_cf0 if cohort ==4 & decile ==`q'
   local obe r(mean)
   
g para = exp(.007*51.54+.239*.42 + .055*.051 + .635*-.254+`obe'*1.12-5)
 
  
range agelt 50 100 51 
sort agelt

g diabhazx = para *exp((agelt-50)*.027)

gen diabcumSx=.
gen diabSx=.
gen diabIntx=.
gen diabEx=.
gen diabcumx=.

sort agelt
replace diabcumx=sum(diabhazx)
replace diabIntx=cond(_n>1, diabcumx[_n-1],0)
replace diabSx=exp(-diabIntx) // surviving at age x, l(x) 
  drop if agelt==. 
replace diabcumSx=sum(diabSx) // cumulative PY lived at age x 
replace diabEx=cond(_n>1, diabcumSx[_N]-diabcumSx[_n-1],diabcumSx[_N])
replace diabEx=diabEx/diabSx


keep agelt diabhazx diabcumSx diabSx diabIntx diabEx diabcumx 
 rename agelt age 
 drop if age==. 
 
 g decile = `q'
 g GE = 0

 append using obe_diab 
 save obe_diab.dta,replace
 }

//*** all others ***/ 

	
   forvalues q = 1(1)10 {
 forvalues k = 1(1)4 {
    
use "$data/working/sample10092021_cf",clear

   sort hhidpn wave
    drop n
    bys hhidpn: g n=_n

xtile decile = bmi_giant15 if  n==1, n(10)
 tab decile if n==1, sum(bmi_giant15) 
 
 bys hhidpn: egen decile2 = mean(decile)
  drop decile 
  rename decile2 decile
  
  rename obe obe_cf0 
  
  sum obe_cf`k' if cohort ==4 & decile ==`q'
   local obe r(mean)
   
g para = exp(.007*51.54+.239*.42 + .055*.051 + .635*-.254+`obe'*1.12-5)
 
  
range agelt 50 100 51 
sort agelt

g diabhazx = para *exp((agelt-50)*.027)

gen diabcumSx=.
gen diabSx=.
gen diabIntx=.
gen diabEx=.
gen diabcumx=.

sort agelt
replace diabcumx=sum(diabhazx)
replace diabIntx=cond(_n>1, diabcumx[_n-1],0)
replace diabSx=exp(-diabIntx) // surviving at age x, l(x) 
  drop if agelt==. 
replace diabcumSx=sum(diabSx) // cumulative PY lived at age x 
replace diabEx=cond(_n>1, diabcumSx[_N]-diabcumSx[_n-1],diabcumSx[_N])
replace diabEx=diabEx/diabSx


keep agelt diabhazx diabcumSx diabSx diabIntx diabEx diabcumx 
 rename agelt age 
 drop if age==. 
 
 g decile = `q'
 g GE = `k'

 append using obe_diab 
 save obe_diab.dta,replace
 }
}

bys GE decile age: drop if _n >1

 save obe_diab.dta,replace

/*****************************************************/
/*     T2D --- death                                 */ 
/*                                                   */ 
/*****************************************************/
use "$data/working/sample10092021",clear

   sort hhidpn wave
    drop n
    bys hhidpn: g n=_n

xtile decile = bmi_giant15 if  n==1, n(10)
 tab decile if n==1, sum(bmi_giant15) 
 
 bys hhidpn: egen decile2 = mean(decile)
  drop decile 
  rename decile2 decile

	  
	      bys  hhidpn:  g age1992 = age if n ==1
	  bys hhidpn: egen age1992_2 = mean(age1992)
	  drop age1992
	  rename age1992_2 age1992
	  
	  rename GENDER MYGENDER
	    replace MYGENDER =0 if MYGENDER ==2 
	  tab raeduc, gen(MYEDUC)
	  
	  
	g year = 1992 + (wave -1) *2   
	g dead = 0 if year < radyear
	 replace dead =1 if year>=radyear-1

	 drop N
	 bys hhidpn wave:  g N = _N 
	  replace dead =1 if n ==N & year ==radyear -2 
	  

	 replace age = age-50 
	   stset age, failure(dead) id(hhidpn)
      streg age1992 MYGENDER MYEDUC1 MYEDUC3 i.rdiab if cohort ==4 & age>=0 , dist(gompertz) nohr  
	       outreg2 using "$log/haz_mort2152022.xls", append dec(3) sideway
	 
	 sum age1992 if e(sample)==1
	  local age r(mean)
sum MYGENDER if e(sample)==1
 local gender r(mean)
sum MYEDUC1 if e(sample)==1
 local educ1 r(mean)
sum MYEDUC3 if e(sample)==1
 local educ3 r(mean)
sum rdiab if  e(sample)==1
 local rdiab r(mean) 

  mat coef=e(b)
   local ageb coef[1,1]
   local genderb coef[1,2]
   local educ1b coef[1,3]
   local educ3b coef[1,4]
   local rdiabb coef[1,6] 
   local cons coef[1,7]
   local ga coef[1,8]
   
g para_nodiab = exp(`age'*`ageb'+`gender'*`genderb'+`educ1'*`educ1b'+`educ3'*`educ3b'+`cons')
g para_diab = exp(`age'*`ageb'+`gender'*`genderb'+`educ1'*`educ1b'+`educ3'*`educ3b'+ `rdiab'*`rdiabb'+`cons')
  
range agelt 50 100 51 
sort agelt

gen hazx_diab=para_diab*exp((agelt-50)*`ga' )
gen hazx_nodiab=para_nodiab*exp((agelt-50)*`ga' )
 
gen cumx_diab=.
gen cumx_nodiab=.
gen cumSx_diab=.
gen cumSx_nodiab=.
gen Intx_diab=.					
gen Intx_nodiab=.
gen Sx_diab=.
gen Sx_nodiab=.
gen Ex_diab=.
gen Ex_nodiab=.

 
drop if agelt==.
 drop age
 rename agelt age 
 
 
replace cumx_diab=sum(hazx_diab)
replace Intx_diab=cond(_n>1, cumx_diab[_n-1],0)
replace Sx_diab=exp(-Intx_diab)
replace cumSx_diab=sum(Sx_diab)
replace Ex_diab=cond(_n>1, cumSx_diab[_N]-cumSx_diab[_n-1],cumSx_diab[_N])


replace cumx_nodiab=sum(hazx_nodiab)
replace Intx_nodiab=cond(_n>1, cumx_nodiab[_n-1],0)
replace Sx_nodiab=exp(-Intx_nodiab)
replace cumSx_nodiab=sum(Sx_nodiab)
replace Ex_nodiab=cond(_n>1, cumSx_nodiab[_N]-cumSx_nodiab[_n-1],cumSx_nodiab[_N])

keep age -Ex_nodiab

save diab_mort.dta, replace					//Life tables with and without T2D
												

/*****************************************************/
/*    /Begins construction of joint                  */
/*    mortality and T2D life table                   */           
/*                                                   */ 
/*****************************************************/												
												
use obe_diab.dta,clear

merge m:1 age using diab_mort
 drop _merge


sort GE decile age			

gen Dx_withdiab=.			 //# of cases of diabetes among survivros non diabets								
gen cumDx_withdiab=.         //# of cumulated cases of diabetes among survivros non diabetes					
gen numx_withdiab=.
gen denx_withdiab=.
gen Ex_withdiab=.		     //Expected residual time to live with T2D						
gen cumEx_withdiab=.		//Cumulated expected residual time to live with T2D						
													
gen meanEx_withdiab=.

			
by GE decile: replace Dx_withdiab=(diabSx*Sx_nodiab)*diabhazx // individuals without T2D entering age x * nodiab alive at age x  * haz
by GE decile:replace Ex_withdiab=Dx_withdiab*Ex_diab 
by GE decile:replace cumDx_withdiab=sum(Dx_withdiab)
by GE decile:replace cumEx_withdiab=sum(Ex_withdiab)
by GE decile:replace numx_withdiab=cond(_n>1,cumEx_withdiab[_N]-cumEx_withdiab[_n-1],cumEx_withdiab[_N])
by GE decile:replace denx_withdiab=cond(_n>1,cumDx_withdiab[_N]-cumDx_withdiab[_n-1],cumDx_withdiab[_N])
by GE decile:replace meanEx_withdiab=numx_withdiab/denx_withdiab
g meanEx_withoutdiab = 50-meanEx_withdiab

label variable age "age from 50 to 100"
label variable Sx_diab "prob of surviving to age x if T2D=1"
label variable Sx_nodiab "prob of surviving to age x if T2D=0"
label variable Ex_diab "residual life at age x if T2D=1"
label variable Ex_nodiab "residual life at age x if T2D=0"
label variable diabSx "single decrement prob of surviving to age x with no T2D"
label variable diabEx "single decrement expected residual life at age x with no T2D"
label variable meanEx_withdiab "Multiple decrement expected years of life lived from age 50 on with T2D"
 
  save diabmort_joint.dta, replace 
