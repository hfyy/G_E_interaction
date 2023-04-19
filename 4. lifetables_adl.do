
clear all
set maxvar 32767

global data **** /* declare the location of the sample file generarted from file 1. data cleaning to generate sample */ 
global log ****  /* decalre the location to store the output files */ 
/*****************************************************/
/*     obe  --- ADL                                  */ 
/*                                                   */ 
/*****************************************************/

use "$data/working/sample10092021_cf",clear


	     
  // hazard function of adl by obesity 

	   stset age, failure(adl_bi) id(hhidpn)
      streg age1992 MYGENDER MYEDUC1 MYEDUC3 i.obe if cohort ==4 & age>=0 , dist(gompertz) nohr  
	   outreg2 using "$log/haz_12152022.xls", append dec(3) sideway
	   
	     
	 use "$data/working/sample10092021_cf",clear
	 rename obe obe_cf0
	 
	 sum obe_cf0 if cohort ==4 & decile ==1
   local obe r(mean)
   
g para = exp(-.002*51.54+(-.028)*.42 + .743*.051 + (-.407)*0.648+`obe'*.557-4.089)
 
  
range agelt 50 100 51 
sort agelt

g adlhazx = para *exp((agelt-50)*.017)

gen adlcumSx=.
gen adlSx=.
gen adlIntx=.
gen adlEx=.
gen adlcumx=.

sort agelt
replace adlcumx=sum(adlhazx)
replace adlIntx=cond(_n>1, adlcumx[_n-1],0)
replace adlSx=exp(-adlIntx) // surviving at age x, l(x) 
   drop if agelt==. 
replace adlcumSx=sum(adlSx) // cumulative PY lived at age x 
replace adlEx=cond(_n>1, adlcumSx[_N]-adlcumSx[_n-1],adlcumSx[_N])
replace adlEx=adlEx/adlSx


keep agelt adlhazx adlcumSx adlSx adlIntx adlEx adlcumx 
 rename agelt age 
 drop if age==. 
 
 g decile = 1
 g GE = 0    // GE =0 means as observed (including GxE) 


 save obe_adl.dta,replace
 
 /**** k= 0 , q=2-10 */ 
 	
   forvalues q = 2(1)10 {
    
use "$data/working/sample10092021_cf",clear

   
 
 bys hhidpn: egen decile2 = mean(decile)
  drop decile 
  rename decile2 decile
  
  rename obe obe_cf0 
  
  sum obe_cf0 if cohort ==4 & decile ==`q'
   local obe r(mean)
   
g para = exp(-.002*51.54+(-.028)*.42 + .743*.051 + (-.407)*0.648+`obe'*.557-4.089)
 
  
range agelt 50 100 51 
sort agelt

g adlhazx = para *exp((agelt-50)*.017)

gen adlcumSx=.
gen adlSx=.
gen adlIntx=.
gen adlEx=.
gen adlcumx=.

sort agelt
replace adlcumx=sum(adlhazx)
replace adlIntx=cond(_n>1, adlcumx[_n-1],0)
replace adlSx=exp(-adlIntx) // surviving at age x, l(x) 
 drop if agelt==. 
replace adlcumSx=sum(adlSx) // cumulative PY lived at age x 
replace adlEx=cond(_n>1, adlcumSx[_N]-adlcumSx[_n-1],adlcumSx[_N])
replace adlEx=adlEx/adlSx


keep agelt adlhazx adlcumSx adlSx adlIntx adlEx adlcumx 
 rename agelt age 
 drop if age==. 
 
 g decile = `q'
 g GE = 0

 append using obe_adl 
 save obe_adl.dta,replace
 }


 
 /*** do the rest ***********/
	
   forvalues q = 1(1)10 {
 forvalues k = 1(1)4 {
    
use "$data/working/sample10092021_cf",clear

 
 bys hhidpn: egen decile2 = mean(decile)
  drop decile 
  rename decile2 decile
  
  rename obe obe_cf0 
  
  sum obe_cf`k' if cohort ==4 & decile ==`q'
   local obe r(mean)
   
g para = exp(-.002*51.54+(-.028)*.42 + .743*.051 + (-.407)*0.648+`obe'*.557-4.089)
 
  
range agelt 50 100 51 
sort agelt

g adlhazx = para *exp((agelt-50)*.017)

gen adlcumSx=.
gen adlSx=.
gen adlIntx=.
gen adlEx=.
gen adlcumx=.

sort agelt
replace adlcumx=sum(adlhazx)
replace adlIntx=cond(_n>1, adlcumx[_n-1],0)
replace adlSx=exp(-adlIntx) // surviving at age x, l(x) 
 drop if agelt==. 
replace adlcumSx=sum(adlSx) // cumulative PY lived at age x 
replace adlEx=cond(_n>1, adlcumSx[_N]-adlcumSx[_n-1],adlcumSx[_N])
replace adlEx=adlEx/adlSx


keep agelt adlhazx adlcumSx adlSx adlIntx adlEx adlcumx 
 rename agelt age 
 drop if age==. 
 
 g decile = `q'
 g GE = `k'

 append using obe_adl 
 save obe_adl.dta,replace
 }
}


 save obe_adl.dta,replace

/*****************************************************/
/*     ADL --- death                                 */ 
/*                                                   */ 
/*****************************************************/
use "$data/working/sample10092021_cf",clear

	   stset age, failure(dead) id(hhidpn)
      streg age1992 MYGENDER MYEDUC1 MYEDUC3 i.adl_bi if cohort ==4 & age>=0 , dist(gompertz) nohr  
	          outreg2 using "$log/haz_mort2152022.xls", append dec(3) sideway
			  
	 sum age1992 if e(sample)==1
	  local age r(mean)
sum MYGENDER if e(sample)==1
 local gender r(mean)
sum MYEDUC1 if e(sample)==1
 local educ1 r(mean)
sum MYEDUC3 if e(sample)==1
 local educ3 r(mean)
sum adl_bi if  e(sample)==1
 local radl r(mean) 

  mat coef=e(b)
   local ageb coef[1,1]
   local genderb coef[1,2]
   local educ1b coef[1,3]
   local educ3b coef[1,4]
   local radlb coef[1,6] 
   local cons coef[1,7]
   local ga coef[1,8]
   
g para_noadl = exp(`age'*`ageb'+`gender'*`genderb'+`educ1'*`educ1b'+`educ3'*`educ3b'+`cons')
g para_adl = exp(`age'*`ageb'+`gender'*`genderb'+`educ1'*`educ1b'+`educ3'*`educ3b'+ `radl'*`radlb'+`cons')
  
range agelt 50 100 51 
sort agelt

gen hazx_adl=para_adl*exp((agelt-50)*`ga' )
gen hazx_noadl=para_noadl*exp((agelt-50)*`ga' )
 
gen cumx_adl=.
gen cumx_noadl=.
gen cumSx_adl=.
gen cumSx_noadl=.
gen Intx_adl=.					
gen Intx_noadl=.
gen Sx_adl=.
gen Sx_noadl=.
gen Ex_adl=.
gen Ex_noadl=.

 
drop if agelt==.
 drop age
 rename agelt age 
 
 
replace cumx_adl=sum(hazx_adl)
replace Intx_adl=cond(_n>1, cumx_adl[_n-1],0)
replace Sx_adl=exp(-Intx_adl)
replace cumSx_adl=sum(Sx_adl)
replace Ex_adl=cond(_n>1, cumSx_adl[_N]-cumSx_adl[_n-1],cumSx_adl[_N])


replace cumx_noadl=sum(hazx_noadl)
replace Intx_noadl=cond(_n>1, cumx_noadl[_n-1],0)
replace Sx_noadl=exp(-Intx_noadl)
replace cumSx_noadl=sum(Sx_noadl)
replace Ex_noadl=cond(_n>1, cumSx_noadl[_N]-cumSx_noadl[_n-1],cumSx_noadl[_N])

keep age -Ex_noadl

save adl_mort.dta, replace			
 
 /*****************************************************/
/*    /Begins construction of joint                  */
/*    mortality and T2D life table                   */           
/*                                                   */ 
/*****************************************************/												
												
use obe_adl.dta,clear

merge m:1 age using adl_mort
 drop _merge


sort GE decile age			

gen Dx_withadl=.			 //# of cases of adletes among survivros non adl 								
gen cumDx_withadl=.         //# of cumulated cases of adletes among survivros non adl				
gen numx_withadl=.
gen denx_withadl=.
gen Ex_withadl=.		     //Expected residual time to live with ADL						
gen cumEx_withadl=.		//Cumulated expected residual time to live with ADL						
													
gen meanEx_withadl=.

			
by GE decile: replace Dx_withadl=(adlSx*Sx_noadl)*adlhazx // individuals without ADL entering age x * noadl alive at age x  * haz
by GE decile:replace Ex_withadl=Dx_withadl*Ex_adl 
by GE decile:replace cumDx_withadl=sum(Dx_withadl)
by GE decile:replace cumEx_withadl=sum(Ex_withadl)
by GE decile:replace numx_withadl=cond(_n>1,cumEx_withadl[_N]-cumEx_withadl[_n-1],cumEx_withadl[_N])
by GE decile:replace denx_withadl=cond(_n>1,cumDx_withadl[_N]-cumDx_withadl[_n-1],cumDx_withadl[_N])
by GE decile:replace meanEx_withadl=numx_withadl/denx_withadl
g meanEx_withoutadl = 50-meanEx_withadl

label variable age "age from 50 to 100"
label variable Sx_adl "prob of surviving to age x if ADL=1"
label variable Sx_noadl "prob of surviving to age x if ADL=0"
label variable Ex_adl "residual life at age x if ADL=1"
label variable Ex_noadl "residual life at age x if ADL=0"
label variable adlSx "single decrement prob of surviving to age x with no ADL"
label variable adlEx "single decrement expected residual life at age x with no ADL"
label variable meanEx_withadl "Multiple decrement expected years of life lived from age 50 on with ADL"
 
  save adlmort_joint.dta, replace 
