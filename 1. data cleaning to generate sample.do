/* this do file reflects the data cleaning and anlaysis as of March 22, 2021 */
clear all
set maxvar 32767


global raw /Users/yiyuehuangfu/Desktop/PGS_early condition/data
global log /Users/yiyuehuangfu/Desktop/PGS_early condition/log
/* please modify the file path for the global "raw" to reflect the the position to store 
    (1) RAND langitudinal HRS 1992-2016 file, 
    (2) PGS file for European and African ancestry (PGENSCORE3A_R and PGENSCORE3E_R), 
	(3) the tracker file (TRK2016TR_R) 
	(4) the HRS fiel from Global Aging Gateway Harmonized HRS(H_HRS_b) */ 


/************1. prepare data for the analysis ************************************/
use "$raw/randhrs1992_2016v2",clear
   rename hhid HHID 
   rename pn PN 
 
 merge 1:1 HHID PN using "$raw/PGENSCORE3A_R"  // merge with PGS of European ancestry 
   drop _merge 
  
 merge 1:1 HHID PN using "$raw/PGENSCORE3E_R", update  // merge with PGS of African ancestry 
   drop _merge
   
 merge 1:1 HHID PN using "$raw/TRK2016TR_R"  // merge with the track file 
 drop if _merge ==2 
   drop _merge

   tempfile randhrs
   save `randhrs' 
   
 use "$raw/H_HRS_b",clear /*get father's occupation, financial condition while 
  growing up, and health condition during childhood from Gateway harmonized file */ 
  keep hhid pn radadoccup rafinanch r*healthch  h*rural r*momeft r*momatt r*momgrela ralhchild 
   rename hhid HHID
   rename pn PN 
   merge 1:1 HHID PN using `randhrs'
    drop if _merge ==1 
    drop _merge 
	
   
 /********* 2. generate/recode  variables *********************/
   g bmi_giant15 = EA_PGS3_BMI_GIANT15     
    replace bmi_giant15 = AA_PGS3_BMI_GIANT15  if bmi_giant15==.
	
	sum bmi_giant15  // 15,190 respondents have BMI PGS 
	tab RACE, sum(bmi_giant15) // 12,090 white, 3,100 black 
	
  g t2b_pgs = EA_PGS3_T2D_DIAGRAM12 
   replace t2b_pgs = AA_PGS3_T2D_DIAGRAM12 if t2b_pgs==.
      
	     label var bmi_giant15 "BMI PGS" 
 /*construct childhood condition indicator with  mother's education, father's education
  childhood health, father's occupation when 16, and financial condition while growing up */ 
  
 egen healthch = rowmax(r*healthch)
     label define healthch 1"excellent" 2"very good" 3"above average" 4"fair" 5"poor"
	 label values healthch healthch
	 
 recode healthch (1=5) (2=4) (3=3) (4=2) (5=1), gen(healthch_recode)
recode rafinanch (1=3) (2=2) (3=1), gen(rafinanch_recode)
recode radadoccup (1=2) (2 3=1), gen(fatherocc2)

 recode rafeduc (0/11=1) (12=2) (13/max=3) 
 recode rameduc (0/11=1) (12=2) (13/max=3) 
 recode raeduc (1 =1) (2 3=2) (4 5=3)
  label define edu 1"less than HS" 2"HS" 3">HS" 
  label values raeduc edu 
     
g ec =rafeduc+rameduc+healthch_recode+rafinanch_recode + fatherocc2 
 xtile ec_q = ec if n==1, n(3)
 tab ec_q, sum(ec)
 
 label define ec 1"worst" 2"median" 3"best" 
   label values ec_q ec 
   
   /* construct a differnt childhood condition indicator with childhood health, financial 
  condition while growing up, mother's effort, mother's attention, good relationship with mother, 
  parental warmth */ 
 recode r*momeft (1=4) (2=3) (3=2) (4=1)
  egen momeft = rowmax(r9momeft r10momeft r11momeft)
  
 recode r*momatt (1=4) (2=3) (3=2) (4=1)
  egen momatt = rowmax(r*momatt)
  
 egen momgrela = rowmax(r*momgrela)
 
 recode ralhchild (0=3) (1=2) (2=1) (3=0), gen(ralhchild_recode)
 
   mvpatterns rafinanch_recode momeft momatt momgrela ralhchild healthch_recode rafeduc rameduc 

   g ecalt = rafinanch_recode+momeft+momatt+momgrela+healthch_recode
     xtile ecalt_q = ecalt,n(3)
	  tab ecalt_q, sum(ecalt)
	  
   
  /* cohort dummies  */
g cohort = 1 if BIRTHYR >0 & BIRTHYR <= 1924 
replace cohort = 2 if BIRTHYR >= 1925 & BIRTHYR <= 1934
 replace cohort = 3 if BIRTHYR >=1935 & BIRTHYR <=1944
 replace cohort = 4 if BIRTHYR >=1945 & BIRTHYR <1960
 
 label define cohort 1"before 1924" 2 "1925-1934" 3"1935-1944" 4"1945-1960",modify 
   label values cohort cohort 
 
   
   
   /* average BMI, both measured and self-reported */ 
  egen srbmi = rowmean(r1bmi-r13bmi)
  egen pmbmi = rowmean(r8pmbmi-r13pmbmi) 
  
   label var srbmi "average self-reported BMI" 
   label var pmbmi "average measured BMI" 

   /*** in order to run the multi level modeling, the data need to be shaped in long
 format */ 
 keep  r*bmi t2b_pgs bmi_giant15  rabplace cohort  r*diab BIRTHYR ///
   RACE GENDER raeduc PC*_* HHID hhidpn  srbmi pmbmi r*pmhghts r*heart h*rural ec* ///
   r*cancr r*shlt r*cenreg r*cendiv *educ rafinanch* healthch* mom*  ralhchild* radyear  ///
   r*adla r*iadla r*dstat r*iwstat 
   
   
//  drop if bmi_giant15 ==.
  
  rename r?bmi rbmi?
  rename r??bmi rbmi??
  
  rename r?pmbmi rmbmi?
  rename r??pmbmi rmbmi??
  
  rename r?pmhghts rpmhghts? 
  rename r??pmhghts rpmhghts??
  
  rename r?heart rheart?
  rename r??heart rheart??
  rename r?cancr rcancr?
  rename r??cancr rcancr??
  rename r?shlt rshlt?
  rename r??shlt rshlt??
  
  rename r?diab rdiab?
  rename r??diab rdiab??
  
  rename r?cenreg rcenreg? 
  rename r??cenreg rcenreg??
  rename r*cendiv rcendiv* 
  rename h*rural hrural* 
  
  rename r*iadla riadla*
  rename r*adla radla*,i

  
  rename r*dstat rdstat* 
  rename r*iwstat riwstat* 

  
  reshape long rmbmi rbmi rpmhghts rheart rcancr rshlt rdiab rcenreg rcendiv hrural radla riadla rdstat riwstat, i(hhidpn radyear) j(wave)
   label var rmbmi "measured BMI" 
   label var rbmi "self-reported BMI" 
   
 g age = 1992+ (wave-1)*2 -BIRTHYR 
  g age2 = age*age
  sum age if bmi_giant15 < . & BIRTHYR <1956,d 
   g age_mc = age -66
   g age_mc2 = age_mc * age_mc
    
 // drop if rbmi ==. | rbmi==.s | rbmi==.n | rbmi==.m | rbmi==.i | rbmi==.d | rbmi==.x

  bys hhidpn: g n=_n
    label var n "nth interview" 
  bys hhidpn: g N=_N
    label var N "total number of intervew an individual has" 
  
  tab N if n==1 
  
  /* disease */ 
  recode rheart (0 4 5=0) (1 3 6=1)
    label var rheart "report heart disease this wave" 
  recode rcancr (0 4 5 =0) (1 3 6=1)
     label var rcancr "report cancer this wave" 
  recode rdiab (0 4 5 =0) (1 3 =1) 
    label var rdiab "report diabetes this wave" 
	 
	 bys hhidpn: egen heart = max(rheart) 
bys hhidpn: egen cancer = max(rcancr) 
bys hhidpn: egen srh = max(rshlt) 
bys hhidpn: egen diab =max(rdiab)
  label var heart "ever had heart disease"
  label var cancer "ever had cancer" 
  label var srh "worst self-rated health" 
  label var diab "ever had diab" 
  
  /* obesity status */ 
  mark obe if rbmi >=30 
   bys hhidpn: egen obe_any = max(obe)
  mark overweight if rbmi >=25 
   bys hhidpn: egen ow_any = max(overweight) 
   
   
   /*interview status */ 
   recode riwstat (0=0) (1 =1) (4 7 9=2) (5 6=3)  ,gen(status) 
    label var status "interview status of the current wave" 
	
    label define status 0 "not yet enter the sample" 1"respond" 2"not respond" 3"dead" ,modify
	label values status status 
   
    /* first wave of interview */ 
	sort hhidpn wave
	 by hhidpn: g first = 1 if (status[_n-1] ==0 & status[_n]==1) | status[1] ==1 | (status[_n-1] ==2 & status[_n]==1)
	 replace first = wave if first <.
	 
	 by hhidpn: egen firstwave = min(first)
	  drop first
	  
	  replace firstwave = 1992+(firstwave-1) * 2
	  rename firstwave firstyear 
	  
	  label var firstyear "the year a respondent was first interviewed"
	 
   save "$data/working/sample10092021",replace
  
  
	  
	
