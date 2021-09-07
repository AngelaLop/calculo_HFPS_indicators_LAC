/*==================================================
project:       
Author:        ALOP 
E-email:       
url:           
Dependencies:  
----------------------------------------------------
Creation Date:     6 Sep 2021 - 11:55:45
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
version 17
drop _all
clear all
set more off

global path "C:\Users\ALOP\Inter-American Development Bank Group\Angela - General\WB"
global input "${path}\Panama\data\HFPS 2021\LAC Folder\WAVE 1\Data Final"
global output "${path}\HFPS"



/*==================================================
              1: Appending datasets from ALC
==================================================*/

* ejemplo: Ecuador
foreach x in 268 501 502 507 520 540 591 592 593 595 758 767 876{
	use "$input\\`x'_PH2W1_CP_Casos_F.dta", clear
	
	* peso muestral
	* hogar
	capture: qui: describe w_hh_ph2w1
	if _rc==111{
	    gen w_hh_r1 = 1
	}
	if _rc!=111{
	    rename w_hh_ph2w1 w_hh_r1
	}
	* individuo
	capture: qui: describe w_ind_ph2w1
	if _rc==111{
	    gen w_ind_r1 = 1
	}
	if _rc!=111{
	    rename w_ind_ph2w1 w_ind_r1
	}
	* agregando data de niños (si es necesario)
	merge 1:1 folio using "$input\\`x'_PH2W1_CP_Ninos_F.dta", nogenerate
	* peso muestral
	* NNA
	capture: qui: describe w_cha_ph2w1
	if _rc==111{
		gen w_cha_r1 = 1
	}
	if _rc!=111{
		rename w_cha_ph2w1 w_cha_r1
	}

	cap destring stratum, replace force
	save "$input\temp_`x'.dta", replace
}
* append
use "$input\temp_268.dta", clear
destring stratum, replace force
foreach x in 501 502 507 520 540 591 592 593 595 758 767 876{
    
	append using "$input\temp_`x'.dta"
	erase "$input\temp_`x'.dta"
}

save "$input\latam_ph2_complete.dta", replace

/*==================================================
              2: populations numbers 
==================================================*/

use "$input_\latam_ph2_complete.dta", clear

g total = 1
g hombre 	= (u03_04==1)
g mujer 	= (u03_04==2)
g urbano	= (u03_08==1)
g rural		= (u03_08==2)
g jefe_h	= (u03_01==1)
g comarcas = inlist(u03_05,507011, 507012, 507014) if pais==507
g provincias = (comarcas==0) if pais==507
g afro_indigena = (u03_11==1) if pais==507

g ocupado1 = u05_01 == 1 
replace ocupado1 = 1 if u05_01 == 2 & inlist(u05_06,1,3)
lab var ocupado1 "Ocupado actual comparable con HFPS 2020"
lab val ocupado1 yn


g mujer_hijos_0_17 = (u07_20==1) if pais==507 & mujer==1
g mujer_hijos_6_17 = mujer_hijos_0_17
g mujer_hijos_12_17 = inrange(u07_19,12,17) if mujer_hijos_0_17==1

**************** education level

*individual 

g e_hasta_primaria_completa_i = inlist(u03_09a,50701, 50702, 50703) if pais==507

g e_secundaria_completa_i = inlist(u03_09a,50704,50705,50706) if pais==507 // vocacional y normal 3 presonas
g e_terciaria_i = inlist(u03_09a,50707, 50708) if pais==507

* HH's head


      g e_hasta_primaria_completa_h = inlist(u03_10a,50701, 50702, 50703) if pais==507
replace e_hasta_primaria_completa_h = 1 if inlist(u03_09a,50701, 50702, 50703) & pais==507 & jefe_h==1

	  g e_secundaria_completa_h = inlist(u03_10a,50704,50705,50706) if pais==507  
replace e_secundaria_completa_h = 1 if inlist(u03_09a,50704,50705,50706) & pais==507 & jefe_h==1

	  g e_terciaria_h = inlist(u03_10a,50707, 50708) if pais==507 
replace e_secundaria_completa_h = 1 if inlist(u03_09a,50707, 50708) & pais==507 & jefe_h==1

g ninos_06_17_h = (u07_16>=1)






/*==================================================
              3: tables representatitivy 
==================================================*/


preserve
					
	tempfile tablas
	tempname ptablas
	
	postfile `ptablas' str25(Pais Tipo_indicador Corte) valor ee cv muestra_d muestra_n  using `tablas', replace

* at individual level 
	local pais Panama 
	svyset [w=w_ind_r1]
	
	local cuts total hombre mujer urbano rural comarcas provincias afro_indigena ocupado1 mujer_hijos_0_17 e_hasta_primaria_completa_i e_secundaria_completa_i e_terciaria_i
	foreach cut of local cuts{
	cap svy:total `cut'  if pais == 507
     
    mat temp=e(b)
    mat muestra = e(N)
   
	local valor = temp[1,1]
	local muestra = `e(N)'
   
	estat cv 
	mat cova= r(cv)
	mat ste= r(se)

	local cv = cova[1,1]
	local se = ste[1,1]
  

	post `ptablas' ("`pais'") ("Nivel") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
	
	
	local cuts hombre mujer urbano rural comarcas provincias afro_indigena ocupado1  e_hasta_primaria_completa_i e_secundaria_completa_i e_terciaria_i
	
	foreach cut of local cuts{
	cap svy:ratio `cut'/total  if pais == 507
	
	mat valores=r(table)
	local valor =valores[1,1] *100
	
	estat cv
	mat error_standar=r(se)
	local se = error_standar[1,1] *100
	
	mat cv=r(cv)
	local cv = cv[1,1] 
	
	estat size
	mat muestra=r(_N)
	local muestra = muestra[1,1] 
	
	post `ptablas' ("`pais'") ("Proporcion") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
	}
	
	postclose `ptablas'
use `tablas', clear
*destring value, replace
*recode value 0=.
save `tablas', replace 

export excel using "${output}/00. HFPS.xlsx", sh("cortes", replace)  firstrow(var)

restore
	
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


