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
global input "${path}\Panama\data\HFPS 2021\LAC Folder\WAVE 1\Data Final 20210914"
global output "${path}\HFPS"
global do "C:\Users\ALOP\Inter-American Development Bank Group\Angela - General\WB\calculo_HFPS_indicators_LAC"


/*==================================================
              1: Appending datasets from ALC
==================================================*/

* ejemplo: Ecuador 268 501 502 507 520 540 591 592 593 595 758 767 876
foreach pais in 268 501 502 503 504 505 507 509 520 540 591 592 593 595 598 758 767 876 {
    
	* Encuestas 

	if `pais' != 509   local status CT
	if `pais' != 509   local final 
	
	if `pais' == 509   local status CP
	if `pais' == 509   local final  _F
	
	use "$input\\`pais'_PH2W1_`status'_Ninos`final'.dta", clear
	cap destring stratum folio, replace 
	save "$input\\`pais'_PH2W1_`status'_Ninos`final'.dta", replace 
	clear
	use "$input\\`pais'_PH2W1_`status'_Casos`final'.dta", clear
	destring stratum folio, replace force
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
	*joinby folio using "$input\\`x'_PH2W1_RD_Ninos_roster.dta", replace update _merge(join)
	* agregando data de niños (si es necesario)
	merge 1:1 folio using "$input\\`pais'_PH2W1_`status'_Ninos`final'.dta", force 
	*cap destring stratum, replace force
	
	* peso muestral
	* NNA
	capture: qui: describe w_cha_ph2w1
	if _rc==111{
		gen w_cha_r1 = 1
	}
	if _rc!=111{
		rename w_cha_ph2w1 w_cha_r1
	}

	
	save "$input\temp_`pais'.dta", replace
}
* append
use "$input\temp_268.dta", clear
*destring stratum, replace force
foreach pais in 501 502 503 504 505 507 509 520 540 591 592 593 595 598 758 767 876 {
    
	append using "$input\temp_`pais'.dta", force
	erase "$input\temp_`pais'.dta"
}


*********** Variables *******************************************************

 do "${do}\1. variables_definition_HFPS_Panama_LAC.do"

save "$input\latam_ph2_complete.dta", replace

*===============================================================================================================
*   Dataset with indicators 
*===============================================================================================================




preserve
					
	tempfile tablas
	tempname ptablas
	

	postfile `ptablas' str25(Pais Tipo_indicador Nivel Indicador Corte) valor ee cv muestra using `tablas', replace

*********************************************************** at individual level 


	* Labour market, health 
	
	local paises 507
	
	svyset [w=w_ind_r1]
	
	local indicadores ocupado0 ocupado1 perdida01 ocu0_desoc1 ocu0_inac1 ausente informal0 informal1 for0_inf1 h_unvaccinated h_unvaccinated_no_intent h_anxious remotew noremotew noremotew_internet noremotew_device noremotew_employer noremotew_job_not_allow noremotew_other emp_tam0_micro emp_tam0_peque emp_tam0_mediana emp_tam0_grande tipoe_new0_cuentap tipoe_new0_empleador tipoe_new0_asalariado tipoe_new0_otros emp_tam1_micro emp_tam1_pequena emp_tam1_mediana emp_tam1_grande tipoe_new1_cuentap tipoe_new1_empleador  tipoe_new1_asalariado tipoe_new1_otros desocupado1  h_unvac_not_effective h_unvac_not_safe h_unvac_not_risk h_other transfer_loss cambio_peque_micro ocup1 rama_agricultura rama_agricultura_pre rama_construccion rama_construccion_pre rama_construccion  rama_industria rama_industria_pre rama_servicios rama_servicios_pre ocu0_ocu1 activo0 activo1 desocupado0 desocupado0b ina0_ocu1 ina0_ocu1_in ina0_desocu1 inactivo0 inactivo1
	local cuts total hombre mujer urbano rural afro_indigena e_hasta_primaria_completa_i e_secundaria_completa_i e_terciaria_i
	
	foreach pais of local paises{
		foreach indicador of local indicadores{
		foreach cut of local cuts{
			cap svy:proportion `indicador'  if `cut' ==1 & `pais' ==pais 
			
			mat valores=r(table)
			local valor =valores[1,colnumb(valores,"1.`indicador'")] *100
			
			estat cv
			mat error_standar=r(se)
			local se = error_standar[1,colnumb(valores,"1.`indicador'")] *100
			
			mat cv=r(cv)
			local cv = cv[1,colnumb(valores,"1.`indicador'")] 
			
			estat size
			mat muestra=r(_N)
			local muestra = muestra[1,colnumb(valores,"1.`indicador'")] 
		
			post `ptablas' ("`pais'") ("Proporcion") ("Individuo") ("`indicador'") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
		}
		}
		

	local indicadores ocupado0 ocupado1 perdida01 ocu0_desoc1 ocu0_inac1 ausente informal0 informal1 for0_inf1 h_unvaccinated h_unvaccinated_no_intent h_anxious remotew noremotew noremotew_internet noremotew_device noremotew_employer noremotew_job_not_allow noremotew_other emp_tam0_micro emp_tam0_peque emp_tam0_mediana emp_tam0_grande tipoe_new0_cuentap tipoe_new0_empleador tipoe_new0_asalariado tipoe_new0_otros emp_tam1_micro emp_tam1_pequena emp_tam1_mediana emp_tam1_grande tipoe_new1_cuentap tipoe_new1_empleador  tipoe_new1_asalariado tipoe_new1_otros desocupado1  h_unvac_not_effective h_unvac_not_safe h_unvac_not_risk h_other transfer_loss cambio_peque_micro ocup1 rama_agricultura rama_agricultura_pre rama_construccion rama_construccion_pre rama_construccion  rama_industria rama_industria_pre rama_servicios rama_servicios_pre ocu0_ocu1 activo0 activo1 desocupado0 desocupado0b ina0_ocu1 ina0_ocu1_in ina0_desocu1 inactivo0 inactivo1
	local cuts total hombre mujer urbano rural afro_indigena e_hasta_primaria_completa_i e_secundaria_completa_i e_terciaria_i
	

		foreach indicador of local indicadores{
		foreach cut of local cuts{
			cap svy:total `indicador'  if `cut' ==1 & `pais' ==pais 
			
			mat valores=r(table)
			local valor =valores[1,1] 
			
			estat cv
			mat error_standar=r(se)
			local se = error_standar[1,1] 
			
			mat cv=r(cv)
			local cv = cv[1,1] 
			
			estat size
			mat muestra=r(_N)
			local muestra = muestra[1,1] 
		
			post `ptablas' ("`pais'") ("Level") ("Individuo") ("`indicador'") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
		}
		}		
		
		
		* horas de trabajo 
		
			local indicadores horas0 horas1
		
		foreach indicador of local indicadores{
		foreach cut of local cuts{
			cap svy:mean `indicador'  if `cut' ==1 & `pais' ==pais
			
			mat valores=r(table)
			local valor =valores[1,1] 
			
			estat cv
			mat error_standar=r(se)
			local se = error_standar[1,1] 
			
			mat cv=r(cv)
			local cv = cv[1,1] 
			
			estat size
			mat muestra=r(_N)
			local muestra = muestra[1,1] 
		
			post `ptablas' ("`pais'") ("Mean") ("Individuo") ("`indicador'") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
		}
		}
		
		
	
	* ================================================================	
	* Household level - income losss, food security 
	* ================================================================	
		
		svyset [w=w_hh_r1]
		
		local indicadores no_food_money no_eat_money no_nutrish_food_money no_food_money_pre i_household_ps_cct i_household_cct_0 i_household_cct_1 income_loss_per income_loss_tot wageinc_loss businessinc_loss agrinc_loss internet_wifi  // 
		local cuts total urbano rural
		
		foreach indicador of local indicadores{
		foreach cut of local cuts{
			cap svy:ratio `indicador'/total  if `cut'==1  & `pais' ==pais
			
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
		
			post `ptablas' ("`pais'") ("Proporcion") ("Hogar") ("`indicador'") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
		}	
		}
		
	* ================================================================	
	* Children level 
	* ================================================================		
	
		 
		svyset [w=w_cha_r1]
		
		
		local cuts total urbano rural 
		local indicadores  dropper asiste asiste_pre
		
		foreach indicador of local indicadores{
			foreach cut of local cuts{
			
			cap svy:ratio `indicador'/chil  if `cut'==1  & `pais' ==pais
			
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
		
			post `ptablas' ("`pais'") ("Proporcion") ("Ninos") ("`indicador'") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
		}		
		}
	}
	
*==========================================================================================================================================
* Agregado paises 
**==========================================================================================================================================

	local paises 501 502 503 504 505 509 520 540 591 592 593 595 598 758 767 876
	
	foreach pais of local paises{
	
		svyset [w=w_ind_r1]
	
	local indicadores ocupado0 ocupado1 perdida01 ocu0_desoc1 ocu0_inac1 ausente informal0 informal1 for0_inf1 h_unvaccinated h_unvaccinated_no_intent h_anxious remotew noremotew noremotew_internet noremotew_device noremotew_employer noremotew_job_not_allow noremotew_other emp_tam0_micro emp_tam0_peque emp_tam0_mediana emp_tam0_grande tipoe_new0_cuentap tipoe_new0_empleador tipoe_new0_asalariado tipoe_new0_otros emp_tam1_micro emp_tam1_pequena emp_tam1_mediana emp_tam1_grande tipoe_new1_cuentap tipoe_new1_empleador  tipoe_new1_asalariado tipoe_new1_otros desocupado1  h_unvac_not_effective h_unvac_not_safe h_unvac_not_risk h_other transfer_loss cambio_peque_micro ocup1 rama_agricultura rama_agricultura_pre rama_construccion rama_construccion_pre rama_construccion  rama_industria rama_industria_pre rama_servicios rama_servicios_pre ocu0_ocu1 activo0 activo1 desocupado0 desocupado0b ina0_ocu1 ina0_ocu1_in ina0_desocu1 inactivo0 inactivo1
	local cuts total urbano rural 
	
	
		foreach indicador of local indicadores{
		foreach cut of local cuts{
			cap svy:proportion `indicador'  if `cut' ==1 & `pais' ==pais 
			
			mat valores=r(table)
			local valor =valores[1,colnumb(valores,"1.`indicador'")] *100
			
			estat cv
			mat error_standar=r(se)
			local se = error_standar[1,colnumb(valores,"1.`indicador'")] *100
			
			mat cv=r(cv)
			local cv = cv[1,colnumb(valores,"1.`indicador'")] 
			
			estat size
			mat muestra=r(_N)
			local muestra = muestra[1,colnumb(valores,"1.`indicador'")] 
		
			post `ptablas' ("`pais'") ("Proporcion") ("Individuo") ("`indicador'") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
		}
		}
		
		
		* horas de trabajo 
		
			local indicadores horas0 horas1
		
		foreach indicador of local indicadores{
		foreach cut of local cuts{
			cap svy:mean `indicador'  if `cut' ==1 & `pais' ==pais
			
			mat valores=r(table)
			local valor =valores[1,1] 
			
			estat cv
			mat error_standar=r(se)
			local se = error_standar[1,1] 
			
			mat cv=r(cv)
			local cv = cv[1,1] 
			
			estat size
			mat muestra=r(_N)
			local muestra = muestra[1,1] 
		
			post `ptablas' ("`pais'") ("Mean") ("Individuo") ("`indicador'") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
		}
		}
		
		
	
	* ================================================================	
	* Household level - income losss, food security 
	* ================================================================	
		
		svyset [w=w_hh_r1]
		
		local indicadores no_food_money no_eat_money no_nutrish_food_money no_food_money_pre i_household_ps_cct i_household_cct_0 i_household_cct_1 income_loss_per income_loss_tot wageinc_loss businessinc_loss agrinc_loss internet_wifi // 
		
		foreach indicador of local indicadores{
		foreach cut of local cuts{
			cap svy:ratio `indicador'/total  if `cut'==1  & `pais' ==pais
			
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
		
			post `ptablas' ("`pais'") ("Proporcion") ("Hogar") ("`indicador'") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
		}	
		}
		
	* ================================================================	
	* Children level 
	* ================================================================		
	
		 
		svyset [w=w_cha_r1]
		
		
		local cuts total urbano rural 
		local indicadores  dropper asiste asiste_pre
		
		foreach indicador of local indicadores{
			foreach cut of local cuts{
			
			cap svy:ratio `indicador'/chil  if `cut'==1  & `pais' ==pais
			
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
		
			post `ptablas' ("`pais'") ("Proporcion") ("Ninos") ("`indicador'") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
			}		
		}
	}  /*cierro pais */
	

postclose `ptablas'
use `tablas', clear
*destring value, replace
*recode value 0=.
save `tablas', replace 
do "${do}\2. formats.do"

export excel using "${output}/02. HFPS.xlsx", sh("indicadores", replace)  firstrow(var)

restore

/*==================================================
              3: tables representatitivy 
==================================================*/

/*
preserve
					
	tempfile tablas
	tempname ptablas
	
	postfile `ptablas' str25(Pais Tipo_indicador Nivel Corte) valor ee cv muestra using `tablas', replace

* at individual level 
	local pais Panama 
	svyset [w=w_ind_r1]

	
	local cuts total hombre mujer urbano rural provincias afro_indigena mujer_hijos_0_17 e_hasta_primaria_completa_i e_secundaria_completa_i e_terciaria_i
	

	foreach cut of local cuts{
		cap svy:total `cut'  if  `pais' =="pais"

		mat temp=e(b)
		 
		mat muestra = e(N)
	   
		local valor = temp[1,1]
		local muestra = `e(N)'	   
		estat cv 
		mat cova= r(cv)
		mat ste= r(se)
		local cv = cova[1,1]
		local se = ste[1,1]
  

	post `ptablas' ("`pais'") ("Proporcion") ("individuo") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
	}	
	
	

	
	local cuts hombre mujer urbano rural comarcas provincias afro_indigena ocupado1  e_hasta_primaria_completa_i e_secundaria_completa_i e_terciaria_i
	
	foreach cut of local cuts{
		cap svy:ratio `cut'/total  if  `pais' =="pais"
		
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
	
		post `ptablas' ("`pais'") ("Proporcion") ("individuo") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
	}

	svyset [w=w_hh_r1]
	
	local cuts total ninos_06_17_h limitations_some_h limitations_high_h e_hasta_primaria_completa_h e_secundaria_completa_h e_terciaria_h
	foreach cut of local cuts{
		cap svy:total `cut'  if  `pais' =="pais"
				
		
		mat temp=e(b)
		 
		mat muestra = e(N)
	   
		local valor = temp[1,1]
		local muestra = `e(N)'	   
		estat cv 
		mat cova= r(cv)
		mat ste= r(se)
		local cv = cova[1,1]
		local se = ste[1,1]
  

	post `ptablas' ("`pais'") ("Nivel") ("hogar") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
	
	}	
	local cuts ninos_06_17_h limitations_some_h limitations_high_h e_hasta_primaria_completa_h e_secundaria_completa_h e_terciaria_h
	
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
	
		post `ptablas' ("`pais'") ("Proporcion") ("hogar") ("`cut'") (`valor') (`se') (`cv') (`muestra') 
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


