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


global path "C:\Users\ALOP\Inter-American Development Bank Group\Angela - General\WB"
global output "${path}\HFPS"



/*==================================================
              1: Variables Definition 
==================================================*/

/*==================================================
              2: populations numbers 
==================================================*/

*use "$input_\latam_ph2_complete.dta", clear
*keep if pais==507
g total = 1
g hombre 	= (u03_04==1)
g mujer 	= (u03_04==2)
g urbano	= (u03_08==1)
g rural		= (u03_08==2)
g jefe_h	= (u03_01==1)
g comarcas = inlist(u03_05,507011, 507012, 507014) if pais==507
g provincias = (comarcas==0) if pais==507
g afro_indigena = (u03_11==1) 


gen ninos_00_05 =1 if (u07_19 >=0 & u07_19 <=5)
egen ninos_00_05_h = count(ninos_00_05), by(folio) 

gen ninos_06_17 =1 if (u07_19 >=6 & u07_19 <=17)
egen ninos_06_17_h = count(ninos_06_17), by(folio) 

gen ninos_12_17 =1 if (u07_19 >=12 & u07_19 <=17)
egen ninos_12_17_h = count(ninos_12_17), by(folio) 
sort folio
*drop if id_nna>0 & w_cha_r1==.

g mujer_hijos_0_17 = (u07_20==1) if  mujer==1
g mujer_hijos_6_17 = mujer_hijos_0_17
g mujer_hijos_12_17 = inrange(u07_19,12,17) if mujer_hijos_0_17==1

**************** education ********************************************

***** education level 

*individual 
gen chil =(w_cha_r1 != .)
g e_hasta_primaria_completa_i = inlist(u03_09a,50701, 50702, 50703) if pais==507

g e_secundaria_completa_i = inlist(u03_09a,50704,50705,50706) if pais==507 // vocacional y normal 3 presonas
g e_terciaria_i = inlist(u03_09a,50707, 50708) if pais==507

g asiste_pre =inlist(u08_02,1,2)
g asiste = u08_03==1 & ((u08_05==1 | u08_05==2 & u08_06==1) | (u08_08==1 | u08_08==2 & u08_10==1))

g dropper = (asiste==0) if asiste_pre==1



* HH's head


      g e_hasta_primaria_completa_h = inlist(u03_10a,50701, 50702, 50703) if pais==507
replace e_hasta_primaria_completa_h = 1 if inlist(u03_09a,50701, 50702, 50703) & pais==507 & jefe_h==1
replace e_hasta_primaria_completa_h = . if inlist(u03_10a,50798) & pais==507

	  g e_secundaria_completa_h = inlist(u03_10a,50704,50705,50706) if pais==507  
replace e_secundaria_completa_h = 1 if inlist(u03_09a,50704,50705,50706) & pais==507 & jefe_h==1
replace e_secundaria_completa_h = . if inlist(u03_10a,50798) & pais==507

	  g e_terciaria_h = inlist(u03_10a,50707, 50708) if pais==507 
replace e_terciaria_h = 1 if inlist(u03_09a,50707, 50708) & pais==507 & jefe_h==1
replace e_terciaria_h = . if inlist(u03_10a,50798) & pais==507


* HH variables 

g limitations_some_h = inlist(u02_13,2,3,4)
g limitations_high_h = inlist(u02_13,3,4)

*********** health *************************************************************
g h_vaccinated				= (u02_09==1)
g h_unvaccinated		   = (h_vaccinated==0)
g h_unvaccinated_no_intent = inlist(u02_10,2,3) if h_unvaccinated ==1

g h_unvac_not_effective = 0 if h_unvaccinated_no_intent ==1
replace h_unvac_not_effective	= 1 if (u02_11==1) & h_unvaccinated_no_intent ==1

g h_unvac_not_safe = 0 if h_unvaccinated_no_intent ==1
replace h_unvac_not_safe = 1 if (u02_11==2) & h_unvaccinated_no_intent ==1

g h_unvac_not_risk = 0 if h_unvaccinated_no_intent ==1
replace h_unvac_not_risk = 1 if (u02_11==3) & h_unvaccinated_no_intent ==1
 
g h_other = 0 if  h_unvaccinated_no_intent ==1
replace h_other	= 1 if inlist(u02_11,4,5,6,8,9,10,97)  & h_unvaccinated_no_intent ==1


g h_anxious				= (u02_12b==1)

g h_need_doctor			= (u02_02==1)




/*==================================================
                    EMPLOYMENT
==================================================*/

*--- SITUACI??N ACTUAL ---*

* Empleo actual comparable con HFPS 2020
gen 	ocupado1 = u05_01 == 1 
replace ocupado1 = 1 if u05_01 == 2 & inlist(u05_06,1,3)
lab var ocupado1 "Ocupado actual comparable con HFPS 2020"
lab val ocupado1 yn

* Empleo actual re-definido 2021
gen		ocupa1 = u05_01 == 1 
replace ocupa1 = 1 if u05_01 == 2 & u05_06 == 1	// Es ocupado si est?? seguro de volver
lab var ocupa1 "Ocupado actual definicion 2021" 
lab val ocupa1 yn

* Ausente temporal
// Seguro de volver
gen		aus_seg = u05_01 == 2 & u05_06 == 1 
lab var aus_seg "No trabaj?? pero tiene trabajo y est?? seguro"
lab val aus_seg yn

// No seguro de volver
gen		aus_noseg = u05_01 == 2 & u05_06 == 3 
lab var aus_noseg "No trabaj?? y no est?? seguro de volver"
lab val aus_noseg yn

// Variable comparable con fase 2020 
gen		ausente = u05_01 == 2 & inlist(u05_06,1,3) 
lab var ausente "Ausente temporal comparable HFPS 2020"
lab val ausente yn

* Trabajo actual desagregado comparable con HFPS 2020
gen 	trabajo1 = 3
replace trabajo1 = 1 if u05_01 == 1
replace trabajo1 = 2 if u05_01 == 2 & inlist(u05_06,1,3) 
lab def trab 1 "Si trabaj??" 2 "Ausente temporal ampliado" 3 "No trabaj??"
lab val trabajo1 trab
lab var trabajo1 "Descomposici??n del trabajo comparable HFPS 2020"

* Desocupaci??n actual: no ocupado + busc?? y est?? disponible para trabajar
gen 	desocupado1 = 0 if ocupado1 == 1
replace	desocupado1 = 1 if ocupado1 == 0 & u05_12 == 1 & u05_15 == 1	// busca y est?? disponible
lab val desocupado1 yn

* Poblaci??n fuera de la fuerza laboral actual (inactividad) 
* https://ilostat.ilo.org/es/persons-outside-the-labour-force-how-inactive-are-they-really/
gen		inactivo1 = ocupado1 == 0 & u05_12 == 2 & u05_15 == 2	// no busca y no est?? disponible
replace inactivo1 = 1 if ocupado1 == 0 & u05_12 == 1 & u05_15 == 2	// busca pero no disponible
replace inactivo1 = 1 if ocupado1 == 0 & u05_12 == 2 & u05_15 == 1	// no busca y disponible
lab val inactivo1 yn

* Poblaci??n en la fuerza laboral actual
gen		activo1 = (ocupado1 == 1 | desocupado1 == 1)
lab val activo1 yn

* Condicion de actividad actual
gen 	condact1 = 1 if ocupado1 == 1
replace condact1 = 2 if desocupado1 == 1
replace condact1 = 3 if inactivo1 == 1
lab def condact	1 "Ocupado" 2 "Desocupado" 3 "Inactivo"
lab val condact1 condact
lab var condact1 "Condicion actividad actual"

* Tasa empleo / poblaci??n activa actual
gen 	ocu_pea1 = 0 if ocupado1 == 0 & activo1 == 1 
replace ocu_pea1 = 1 if ocupado1 == 1 & activo1 == 1 
lab def ocu_pea 0 "desocupado" 1 "ocupado"
lab val ocu_pea1 ocu_pea

* Empleo formal actual
gen		formal1 = u05_08 == 1 if ocupado1==1
lab val formal1 yn

* empleo informal actual 

gen		informal1 = u05_08 == 2 if ocupado1==1
lab val informal1 yn 
 
* Empleo por tama??o de empresa actual

gen emp_tam1_micro 	= 0 if ocupado1==1
replace	emp_tam1_micro = 1 if inlist(u05_10,1,2) & ocupado1==1

gen emp_tam1_pequena 	= 0  if ocupado1==1
replace emp_tam1_pequena = 1 if u05_10==3 & ocupado1==1 

gen emp_tam1_mediana 	= 0  if ocupado1==1
replace emp_tam1_mediana = 1 if u05_10==4 & ocupado1==1 

gen emp_tam1_grande 	= 0  if ocupado1==1
replace emp_tam1_grande = 1 if u05_10==5 & ocupado1==1 


* Tipo empleo actual comparable con HFPS 2020
gen 	tipoe1 = .
replace tipoe1 = 0 if inrange(u05_09,1,3) & ocupado1 == 1
replace tipoe1 = 1 if inrange(u05_09,4,5) & ocupado1 == 1
lab def tipoe_g 0 "independiente" 1 "asalariado"
lab val tipoe1 tipoe_g
lab var tipoe1 "Tipo empleo actual comparable HFPS 2020"

* Tipo empleo actual definici??n HFPS 2021

gen tipoe_new1_cuentap = 0 if ocupado1 == 1
replace tipoe_new1_cuentap = 1 if u05_09 == 1 & u05_10 == 1 & ocupado1 == 1

gen tipoe_new1_empleador = 0 if ocupado1 == 1
replace tipoe_new1_empleador = 1 if u05_09 == 1 & inrange(u05_10,2,5) & ocupado1 == 1

gen tipoe_new1_asalariado = 0 if ocupado1 == 1
replace tipoe_new1_asalariado = 1 if u05_09 == 4 & ocupado1 == 1

gen tipoe_new1_otros = 0 if ocupado1 == 1
replace tipoe_new1_otros =1 if inlist(u05_09,2,3,5) & ocupado1 == 1

// Revisi??n de ubicaci??n de propia actividad agr??cola
gen		tipoe_n1 = .
replace tipoe_n1 = 1 if u05_09 == 1 & u05_10 == 1 & ocupado1 == 1
replace tipoe_n1 = 1 if u05_09 == 3 & u05_10 == 1 & ocupado1 == 1
replace tipoe_n1 = 2 if u05_09 == 1 & inrange(u05_10,2,5) & ocupado1 == 1
replace tipoe_n1 = 2 if u05_09 == 3 & inrange(u05_10,2,5) & ocupado1 == 1
replace tipoe_n1 = 3 if u05_09 == 4 & ocupado1 == 1
replace tipoe_n1 = 4 if inlist(u05_09,2,5) & ocupado1 == 1
lab val tipoe_n1 tipoe_new 
lab var tipoe_n1 "Tipo empleo actual definicion 2021 revisada"
 
* Horas de trabajo
gen		horas1 = u05_03 if ocupado1 == 1
lab var horas1 "Horas de trabajo semana actual"

gen		hremo1 = u05_04 if ocupado1 == 1 
lab var horas1 "Horas trabajo remoto semana actual"

gen		workhome = u05_04 / u05_03 if (u05_03 > 0 & u05_03 != .) & ocupado1 == 1
lab var workhome "Proporcion horas de trabajo en casa "

* rama de actividad 

g rama_agricultura   = inlist(u05_11,1)
g rama_industria     = inlist(u05_11,2,3,5)
g rama_construccion  = inlist(u05_11,6)
g rama_servicios     = inlist(u05_11,7,4,8,9,10,11,12,13,14,15,16,17,18,19,20)


*--- SITUACI??N PREPANDEMIA ---*

* Ocupaci??n pre pandemia 
gen 	ocupado0 = u05_16==1
lab var	ocupado0 "Ocupado pre-pandemia"
lab val ocupado0 yn

* Desocupaci??n pre pandemia // Si en raz??n de no trabajo menciona que estaba buscando
gen 	desocupado0 = 0 if ocupado0 == 1
replace	desocupado0 = 1 if ocupado0 == 0 & u05_28 == 8
lab var desocupado0 "Desocupado pre-pandemia"
lab val desocupado0 yn

// Revisar si se incluye opci??n de no hab??a trabajo
gen 	desocupado0b = 0 if ocupado0 == 1
replace	desocupado0b = 1 if ocupado0 == 0 & inlist(u05_28,7,8)
lab var desocupado0b "Desocupado pre-pandemia alt"
lab val desocupado0b yn

* Poblaci??n fuera de la fuerza laboral pre pandemia (inactividad) 
gen		inactivo0 = ocupado0 == 0 & inrange(u05_28,1,7)
lab var inactivo0 "Inactivo pre-pandemia"
lab val inactivo0 yn

* Poblaci??n en la fuerza laboral pre pandemia
gen		activo0 = (ocupado0 == 1 | desocupado0 == 1)
lab val activo0 yn

* Condicion de actividad pre pandemia
gen 	condact0 = 1 if ocupado0 == 1
replace condact0 = 2 if desocupado0 == 1
replace condact0 = 3 if inactivo0 == 1
lab val condact0 condact
lab var condact0 "Condicion actividad pre-pandemia"

* Tasa empleo / poblaci??n activa pre pandemia
gen 	ocu_pea0 = 0 if ocupado0 == 0 & activo0 == 1 
replace ocu_pea0 = 1 if ocupado0 == 1 & activo0 == 1 
lab val ocu_pea0 ocu_pea

* Empleo formal pre pandemia
gen		formal0 = u05_18 == 1 if ocupado0 == 1 
replace formal0 = 1 if u05_22 == 1 & ocupado0 == 1
lab val formal0 yn

* Empleo informal pre pandemia 
g informal0 = (formal0==0) if ocupado0 == 1 


* Empleo por tama??o de empresa COMPLETAR
// Completamos variable
clonevar tam0 = u05_19 if ocupado0 == 1
replace	 tam0 = u05_23 if ocupado0 == 1 & tam0 == . 

gen emp_tam0_micro = 0 if ocupado0==1
replace	emp_tam0_micro 	= 1 if inlist(tam0,1,2) & ocupado0==1

gen emp_tam0_peque = 0 if ocupado0==1
replace emp_tam0_peque  = 1 if tam0==3 & ocupado0==1 

gen emp_tam0_mediana = 0 if ocupado0==1
replace emp_tam0_mediana = 1 if tam0==4 & ocupado0==1 

gen emp_tam0_grande = 0 if ocupado0==1
replace emp_tam0_grande = 1 if tam0==5 & ocupado0==1 


* Tipo empleo pre-pandemia comparable con HFPS 2020
// Completamos variable
clonevar u05_25_ = u05_25 if ocupado0 == 1
replace  u05_25_ = u05_09 if ocupado0 == 1 & u05_17 == 1 & u05_25_ == .

gen 	tipoe0 = .
replace tipoe0 = 0 if inrange(u05_25_,1,3) & ocupado0 == 1
replace tipoe0 = 1 if inrange(u05_25_,4,5) & ocupado0 == 1
lab val tipoe0 tipoe_g
lab var tipoe0 "Tipo empleo pre-pandemia comp. HFPS 2020"

* Tipo empleo pre-pandemia definici??n 2021

	g tipoe_new0_cuentap = 0 if ocupado0 == 1
replace tipoe_new0_cuentap = 1 if u05_25_ == 1 & tam0 == 1 & ocupado0 == 1

	g tipoe_new0_empleador = 0 if ocupado0 == 1
replace tipoe_new0_empleador = 1 if u05_25_ == 1 & inrange(tam0,2,5) & ocupado0 == 1

	g tipoe_new0_asalariado = 0 if ocupado0 == 1
replace tipoe_new0_asalariado =1 if u05_25_ == 4 & ocupado0 == 1

	g tipoe_new0_otros = 0 if ocupado0 == 1
replace tipoe_new0_otros = 1 if inlist(u05_25_,2,3,5) & ocupado0 == 1


* Horas de trabajo pre pandemia (completa)
clonevar horas0 = u05_20 if ocupado0 == 1
replace  horas0 = u05_24 if ocupado0 == 1 & horas0 == .

* Rama actividad pre pandemia (completa)
clonevar u05_26_ = u05_26 if ocupado0 == 1
replace  u05_26_ = u05_11 if ocupado0 == 1 & u05_17 == 1 & u05_26_ == .



* rama de actividad ( prepandemia)

g rama_agricultura_pre = inlist(u05_26_,1)
g rama_industria_pre   = inlist(u05_26_,2,3,5)
g rama_construccion_pre  = inlist(u05_26_,6)
g rama_servicios_pre  = inlist(u05_26_,7,4,8,9,10,11,12,13,14,15,16,17,18,19,20)

*extra

g rama_health_pre = inlist(u05_26_,12)
g rama_edu_pre = inlist(u05_26_,11)

g rama_health = inlist(u05_11,12)
g rama_edu = inlist(u05_11,11)





*--- TRANSICIONES ---*

* Perdida empleo actual vs pre pandemia (comparable HFPS 2020)
gen		perdida01 = .
replace perdida01 = 0 if ocupado0 == 1 
replace perdida01 = 1 if ocupado0 == 1 & ocupado1 == 0
lab var perdida01 "Perdida empleo pre pandemia"

gen		ocu0_desoc1 = .
replace ocu0_desoc1 = 0 if ocupado0 == 1 
replace ocu0_desoc1 = 1 if ocupado0 == 1 & desocupado1 == 1
lab var ocu0_desoc1 "Del empleo al desempleo"

gen		ocu0_inac1 = .
replace ocu0_inac1 = 0 if ocupado0 == 1 
replace ocu0_inac1 = 1 if ocupado0 == 1 & inactivo1 == 1
lab var ocu0_inac1 "Del empleo a inactividad"
lab val perdida01 ocu0_desoc1 ocu0_inac1 yn

gen		ocu0_ocu1 = .
replace ocu0_ocu1 = 0 if ocupado0 == 1 & ocupado1 == 1
replace ocu0_ocu1 = 1 if ocupado0 == 1 & ocupado1 == 1 & u05_17==2
lab var ocu0_ocu1 "De la inactividad al empleo"
lab val perdida01 ocu0_desoc1 ocu0_inac1 yn
*Transicion inactividad a empleo 
gen		ina0_ocu1 = .
replace ina0_ocu1 = 0 if inactivo0 == 1 
replace ina0_ocu1 = 1 if inactivo0 == 1 & ocupado1 == 1 
lab var ina0_ocu1 "De la inactividad a la ocupacion"

*Trnasicion inactividad a desempleo 
gen		ina0_desocu1 = .
replace ina0_desocu1 = 0 if inactivo0 == 1 
replace ina0_desocu1 = 1 if inactivo0 == 1 & desocupado1 == 1 
lab var ina0_desocu1 "De la inactividad al desempleo"

* Transicion inactividad a empleo informal  
gen		ina0_ocu1_in = .
replace ina0_ocu1_in = 0 if inactivo0 == 1 & ocupado1 == 1 
replace ina0_ocu1_in = 1 if inactivo0 == 1 & ocupado1 == 1 & formal1==0
lab var ina0_ocu1_in "De la inactividad a la ocupacion informal"

* Transici??n de ocupado formal a informal
gen		for0_inf1 = 0 if ocupado0==1 & ocupado1==1
replace for0_inf1 = 1 if (formal0==1 & formal1==0) & (ocupado0==1 & ocupado1==1)
lab var for0_inf1 "Ocupados que pasaron de formal a informal"

* Transici??n de ocupado asalariado a otros tipos de empleo
gen		wage0_oth1 = 0 if ocupado0==1 & ocupado1==1
replace wage0_oth1 = 1 if (tipoe_new0_asalariado==1 & inlist(tipoe_n1,1,2,4)) & (ocupado0==1 & ocupado1==1)
lab var wage0_oth1 "Ocupados que pasaron de asalariados a otros tipos empleo"

* Ocupados que mantienen el mismo trabajo de pre-pandemia pero trabajan solo desde casa
gen		remotew = 0 if ocupado0==1 & ocupado1==1
replace remotew = 1 if (workhome==1 & u05_17==1) & (ocupado0==1 & ocupado1==1)
lab var remotew "Ocupados que mantienen su trabajo prepandemia pero es remoto"

* Ocupados que mantienen el mismo trabajo de pre-pandemia pero no trabajan solo desde casa
gen		noremotew = 0 if ocupado0==1 & ocupado1==1
replace noremotew = 1 if (workhome < 1 | workhome ==.  & u05_17==1) & (ocupado0==1 & ocupado1==1)
lab var remotew "Ocupados que mantienen su trabajo prepandemia pero no es remoto"

* razones para no trabajo remoto 

gen	noremotew_internet = 0 if noremotew==1
replace noremotew_internet =1 if u05_05==1 & noremotew==1

gen	noremotew_device = 0 if noremotew==1
replace noremotew_device =1 if u05_05==2 & noremotew==1

gen	noremotew_employer = 0 if noremotew==1
replace noremotew_employer =1 if u05_05==3 & noremotew==1

gen	noremotew_job_not_allow = 0 if noremotew==1
replace noremotew_job_not_allow =1 if u05_05==4 & noremotew==1

gen	noremotew_other = 0 if noremotew==1
replace noremotew_other =1 if u05_05==97 & noremotew==1

* Ocupados que cambiaron de trabajo y pasaron de 


gen emp_tam0_med_gra = 1 if emp_tam0_mediana==1 | emp_tam0_grande ==1
gen cambio_peque_micro = 1 if emp_tam0_med_gra==1 & (emp_tam1_micro==1 | emp_tam1_peque==1) & ocu0_ocu1==1
*people who change their pre-pandemic job (18+ years old)

*g job_change_pre = (employed_full==1) & (u05_17==2)

*people who were employed pre pandemic and became unemployed

*g job_loss_pre_une = (l_unemployed==1) & (u05_16==1)

*people who were employed pre pandemic and left the labor force

*g job_loss_pre_ina = (activo1==0) & (u05_16==1)

*people who lost their pre-pandemic job (18+ years old)

*g job_loss_pre = (job_change_pre==1) | (job_loss_pre_une==1) | (job_loss_pre_ina==1)

*employed population by type: SELF EMPLOYED (pre pandemic)

*********** Income *************************************************************
g i_household_income= (u06_01==1)
g i_household_buss= (u06_07==1)
g i_household_agri= (u06_09==1)
g i_household_ong= (u06_11==1)
g i_household_rem= (u06_13==1)
g i_household_fam= (u06_15==1)
g i_household_cct_0= (u06_03==1)
g i_household_cct_1= (u06_04==1)
g i_household_ps_cct= (u06_06==1)
g i_income_decline = (u06_02==3)



/*==================================================
                  INCOME LOSS
==================================================*/


* Transferencias habituales del gobierno 

 
tab u06_05, g(transfinc_)
gen		transfer_loss = transfinc_3


* Sueldos/salarios/honorarios 
tab u06_02 if u06_01==1, g(wageinc_)
gen		wageinc_loss = wageinc_3


* Ingresos por negocio propio o familiar no agr??cola
tab u06_08 if u06_07==1, g(businessinc_)		// Validaci??n OK
gen		businessinc_loss = businessinc_3


* Ingresos por actividad agricola, ganader??a o pesca
tab u06_10 if u06_09==1, g(agrinc_)
gen		agrinc_loss = agrinc_3


* Ingresos por ayuda ONGs, fundaciones, iglesia
tab u06_12 if u06_11==1, g(onginc_)
cap gen		onginc_loss = onginc_3


* Ingresos por remesas del exterior
tab u06_14 if u06_13==1, g(remitinc_)
gen		remitinc_loss = remitinc_3


* Ingresos por ayuda de familiares en el pais
tab u06_14 if u06_13==1, g(famtransfer_)
gen		famtransfer_loss = famtransfer_3


* Ingreso total del hogar
g income_loss_per = (u06_17==3)
g income_loss_tot = wageinc_loss==1| businessinc_loss==1| agrinc_loss==1| remitinc_loss==1 | (famtransfer_loss==1)



********** Food insecurity *****************************************************

g no_food_money = (u04_01==1)
g no_eat_money = (u04_02==1)
g no_nutrish_food_money = (u04_03==1)
g no_food_money_pre = (u04_04==1)

*===============================================================================
*					GEnder 
*===============================================================================

* ---- Gender ---- *
* gen1. Increase in the amount of domestic work you do, like washing, cooking, and cleaning
* numerator: all respondents that declare the amount of domestic work like washing, cooking, and cleaning has increased during the pandemic
* denominator: all respondents
gen gen1 = u09_01==1
lab val gen1 yn

* gen2. Increase in the amount of childcare you do such as feeding, playing with them, and caring for them
* numerator: all respondents that declare the amount of childcare they do such as feeding, playing with them, and caring for them has increased during the pandemic
* denominator: all respondents who live in hhs with at least one child aged 0 to 17 years
gen gen2 = .
replace gen2 = 1 if u09_02==1
replace gen2 = 0 if u09_02!=1 & u09_02!=.
lab val gen2 yn

* gen3. Increase in the amount you do in education and schoolwork accompaniment of children
* numerator: all respondents who declare the amount of time spent in education and schoolwork accompaniment of children has increased during the pandemic
* denominator: all respondents who live in hhs with at least one child in school age who has not completed secondary education (6 yo 17 years old)
gen gen3 = .
replace gen3 = 1 if u09_03==1
replace gen3 = 0 if u09_03!=1 & u09_03!=.
lab val gen3 yn

* gen4. Increase in the amount of work you do caring for the elderly, the sick, or people with disabilities
* numerator: all respondents that declare the amount of work they do caring for the elderly, the sick, or people with disabilities has increased during the pandemic
* denominator: all respondents
gen gen4 = u09_04==1
lab val gen4 yn

* gen5. uneven treatment because of kids (all, women versus men)
* numerator: all respondents who say they experienced an uneven treatment because of having kids
* denominator: all respondents who live in a hh with at least one child and are working now or before the pandemic
gen gen5 = u09_10==1
replace gen5 = . if u09_10==.
lab val gen5 yn

*===============================================================================
*					Connectivity 
*===============================================================================

* con1. Internet access
* note: we combine information from two variables: 11.02) Of these [11.01] smart phones, how many paid for mobile data or had a data plan in the month of [month_ant] of 2021, including yours?; and 11.08) Does your household have internet by network cable and / or WiFi?
* numerator: union of 11.02 and 11.08
* denominator: all hhs
recode u11_08 (97=.)
gen x1 = .
replace x1 = 0 if u11_02==0
replace x1 = 1 if u11_02>=1 & u11_02<=15
gen con1 = .
replace con1 = 1 if x1==1 | u11_08==1
replace con1 = 0 if x1==0 & u11_08==2
replace con1 = . if x1==. & u11_08==2
replace con1 = . if x1==0 & u11_08==.
replace con1 = . if x1==. & u11_08==.
drop x1
* wifi 
gen internet_wifi = u11_08



