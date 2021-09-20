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
global input "${path}\Panama\data\HFPS 2021\LAC Folder\WAVE 1\Data Final"
global output "${path}\HFPS"



/*==================================================
              1: Variables Definition 
==================================================*/

/*==================================================
              2: populations numbers 
==================================================*/

*use "$input_\latam_ph2_complete.dta", clear
keep if pais==507
g total = 1
g hombre 	= (u03_04==1)
g mujer 	= (u03_04==2)
g urbano	= (u03_08==1)
g rural		= (u03_08==2)
g jefe_h	= (u03_01==1)
g comarcas = inlist(u03_05,507011, 507012, 507014) if pais==507
g provincias = (comarcas==0) if pais==507
g afro_indigena = (u03_11==1) if pais==507


gen ninos_00_05 =1 if (u07_19 >=0 & u07_19 <=5)
egen ninos_00_05_h = count(ninos_00_05), by(folio) 

gen ninos_06_17 =1 if (u07_19 >=6 & u07_19 <=17)
egen ninos_06_17_h = count(ninos_06_17), by(folio) 

gen ninos_12_17 =1 if (u07_19 >=12 & u07_19 <=17)
egen ninos_12_17_h = count(ninos_12_17), by(folio) 
sort folio
*drop if id_nna>0 & w_cha_r1==.

g mujer_hijos_0_17 = (u07_20==1) if pais==507 & mujer==1
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

g h_unvac_not_effective	= (u02_11==1) 
replace h_unvac_not_effective =. if h_vaccinated==1

g h_unvac_not_safe		= (u02_11==2) 
replace h_unvac_not_safe =. if h_vaccinated==1
	
g h_unvac_not_risk		= (u02_11==3)
replace h_unvac_not_risk =. if h_vaccinated==1
 
g h_other				= inlist(u02_11,4,5,6,8,9,10,97) 
replace h_other =. if h_vaccinated==1

g h_anxious				= (u02_12b==1)

g h_need_doctor			= (u02_02==1)




/*==================================================
                    EMPLOYMENT
==================================================*/

*--- SITUACIÓN ACTUAL ---*

* Empleo actual comparable con HFPS 2020
gen 	ocupado1 = u05_01 == 1 
replace ocupado1 = 1 if u05_01 == 2 & inlist(u05_06,1,3)
lab var ocupado1 "Ocupado actual comparable con HFPS 2020"
lab val ocupado1 yn

* Empleo actual re-definido 2021
gen		ocupa1 = u05_01 == 1 
replace ocupa1 = 1 if u05_01 == 2 & u05_06 == 1	// Es ocupado si está seguro de volver
lab var ocupa1 "Ocupado actual definicion 2021" 
lab val ocupa1 yn

* Ausente temporal
// Seguro de volver
gen		aus_seg = u05_01 == 2 & u05_06 == 1 
lab var aus_seg "No trabajó pero tiene trabajo y está seguro"
lab val aus_seg yn

// No seguro de volver
gen		aus_noseg = u05_01 == 2 & u05_06 == 3 
lab var aus_noseg "No trabajó y no está seguro de volver"
lab val aus_noseg yn

// Variable comparable con fase 2020 
gen		ausente = u05_01 == 2 & inlist(u05_06,1,3) 
lab var ausente "Ausente temporal comparable HFPS 2020"
lab val ausente yn

* Trabajo actual desagregado comparable con HFPS 2020
gen 	trabajo1 = 3
replace trabajo1 = 1 if u05_01 == 1
replace trabajo1 = 2 if u05_01 == 2 & inlist(u05_06,1,3) 
lab def trab 1 "Si trabajó" 2 "Ausente temporal ampliado" 3 "No trabajó"
lab val trabajo1 trab
lab var trabajo1 "Descomposición del trabajo comparable HFPS 2020"

* Desocupación actual: no ocupado + buscó y está disponible para trabajar
gen		desocupado1 = ocupado1 == 0 & u05_12 == 1 & u05_15 == 1	// busca y está disponible
lab val desocupado1 yn

* Población fuera de la fuerza laboral actual (inactividad) 
* https://ilostat.ilo.org/es/persons-outside-the-labour-force-how-inactive-are-they-really/
gen		inactivo1 = ocupado1 == 0 & u05_12 == 2 & u05_15 == 2	// no busca y no está disponible
replace inactivo1 = 1 if ocupado1 == 0 & u05_12 == 1 & u05_15 == 2	// busca pero no disponible
replace inactivo1 = 1 if ocupado1 == 0 & u05_12 == 2 & u05_15 == 1	// no busca y disponible
lab val inactivo1 yn

* Población en la fuerza laboral actual
gen		activo1 = (ocupado1 == 1 | desocupado1 == 1)
lab val activo1 yn

* Condicion de actividad actual
gen 	condact1 = 1 if ocupado1 == 1
replace condact1 = 2 if desocupado1 == 1
replace condact1 = 3 if inactivo1 == 1
lab def condact	1 "Ocupado" 2 "Desocupado" 3 "Inactivo"
lab val condact1 condact
lab var condact1 "Condicion actividad actual"

* Tasa empleo / población activa actual
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
 
* Empleo por tamaño de empresa actual
gen	emp_tam1_micro 	 =  inlist(u05_10,1,2) & ocupado1==1
gen emp_tam1_pequena =  u05_10==3 & ocupado1==1 
gen emp_tam1_mediana =  u05_10==4 & ocupado1==1 
gen emp_tam1_grande  =  u05_10==5 & ocupado1==1 


* Tipo empleo actual comparable con HFPS 2020
gen 	tipoe1 = .
replace tipoe1 = 0 if inrange(u05_09,1,3) & ocupado1 == 1
replace tipoe1 = 1 if inrange(u05_09,4,5) & ocupado1 == 1
lab def tipoe_g 0 "independiente" 1 "asalariado"
lab val tipoe1 tipoe_g
lab var tipoe1 "Tipo empleo actual comparable HFPS 2020"

* Tipo empleo actual definición HFPS 2021

gen tipoe_new1_cuentap =  u05_09 == 1 & u05_10 == 1 & ocupado1 == 1

gen tipoe_new1_empleador = u05_09 == 1 & inrange(u05_10,2,5) & ocupado1 == 1

gen tipoe_new1_asalariado = u05_09 == 4 & ocupado1 == 1

gen tipoe_new1_otros = inlist(u05_09,2,3,5) & ocupado1 == 1

 

// Revisión de ubicación de propia actividad agrícola
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

*--- SITUACIÓN PREPANDEMIA ---*

* Ocupación pre pandemia 
gen 	ocupado0 = u05_16==1
lab var	ocupado0 "Ocupado pre-pandemia"
lab val ocupado0 yn

* Desocupación pre pandemia // Si en razón de no trabajo menciona que estaba buscando
gen		desocupado0 = ocupado0 == 0 & u05_28 == 8
lab var desocupado0 "Desocupado pre-pandemia"
lab val desocupado0 yn

// Revisar si se incluye opción de no había trabajo
gen		desocupado0b = ocupado0 == 0 & inlist(u05_28,7,8)
lab var desocupado0b "Desocupado pre-pandemia alt"
lab val desocupado0b yn

* Población fuera de la fuerza laboral pre pandemia (inactividad) 
gen		inactivo0 = ocupado0 == 0 & inrange(u05_28,1,7)
lab var inactivo0 "Inactivo pre-pandemia"
lab val inactivo0 yn

* Población en la fuerza laboral pre pandemia
gen		activo0 = (ocupado0 == 1 | desocupado0 == 1)
lab val activo0 yn

* Condicion de actividad pre pandemia
gen 	condact0 = 1 if ocupado0 == 1
replace condact0 = 2 if desocupado0 == 1
replace condact0 = 3 if inactivo0 == 1
lab val condact0 condact
lab var condact0 "Condicion actividad pre-pandemia"

* Tasa empleo / población activa pre pandemia
gen 	ocu_pea0 = 0 if ocupado0 == 0 & activo0 == 1 
replace ocu_pea0 = 1 if ocupado0 == 1 & activo0 == 1 
lab val ocu_pea0 ocu_pea

* Empleo formal pre pandemia
gen		formal0 = u05_18 == 1 if ocupado0 == 1 
replace formal0 = 1 if u05_22 == 1 & ocupado0 == 1
lab val formal0 yn

* Empleo informal pre pandemia 
g informal0 = (formal0==0) if ocupado0 == 1 


* Empleo por tamaño de empresa COMPLETAR
// Completamos variable
clonevar tam0 = u05_19 if ocupado0 == 1
replace	 tam0 = u05_23 if ocupado0 == 1 & tam0 == . 

gen		emp_tam0_micro 	=  inlist(tam0,1,2) & ocupado0==1
gen emp_tam0_peque  =  tam0==3 & ocupado0==1 
gen emp_tam0_mediana = tam0==4 & ocupado0==1 
gen emp_tam0_grande = tam0==5 & ocupado0==1 


* Tipo empleo pre-pandemia comparable con HFPS 2020
// Completamos variable
clonevar u05_25_ = u05_25 if ocupado0 == 1
replace  u05_25_ = u05_09 if ocupado0 == 1 & u05_17 == 1 & u05_25_ == .

gen 	tipoe0 = .
replace tipoe0 = 0 if inrange(u05_25_,1,3) & ocupado0 == 1
replace tipoe0 = 1 if inrange(u05_25_,4,5) & ocupado0 == 1
lab val tipoe0 tipoe_g
lab var tipoe0 "Tipo empleo pre-pandemia comp. HFPS 2020"

* Tipo empleo pre-pandemia definición 2021

g tipoe_new0_cuentap = u05_25_ == 1 & tam0 == 1 & ocupado0 == 1

g tipoe_new0_empleador = u05_25_ == 1 & inrange(tam0,2,5) & ocupado0 == 1

g tipoe_new0_asalariado = u05_25_ == 4 & ocupado0 == 1

g tipoe_new0_otros = inlist(u05_25_,2,3,5) & ocupado0 == 1


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


* rama de actividad 

g rama_agricultura = inlist(u05_11,1)
g rama_industria   = inlist(u05_11,2,3,5)
g rama_construccion  = inlist(u05_11,6)
g rama_servicios  = inlist(u05_11,7,4,8,9,10,11,12,13,14,15,16,17,18,19,20)


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

* Transición de ocupado formal a informal
gen		for0_inf1 = 0 if ocupado0==1 & ocupado1==1
replace for0_inf1 = 1 if (formal0==1 & formal1==0) & (ocupado0==1 & ocupado1==1)
lab var for0_inf1 "Ocupados que pasaron de formal a informal"

* Transición de ocupado asalariado a otros tipos de empleo
gen		wage0_oth1 = 0 if ocupado0==1 & ocupado1==1
replace wage0_oth1 = 1 if (tipoe_new0_asalariado==1 & inlist(tipoe_n1,1,2,4)) & (ocupado0==1 & ocupado1==1)
lab var wage0_oth1 "Ocupados que pasaron de asalariados a otros tipos empleo"

* Ocupados que mantienen el mismo trabajo de pre-pandemia pero trabajan solo desde casa
gen		remotew = 0 if ocupado0==1 & ocupado1==1
replace remotew = 1 if (workhome==1 & u05_17==1) & (ocupado0==1 & ocupado1==1)
lab var remotew "Ocupados que mantienen su trabajo prepandemia pero es remoto"

*ocupados que pasaron de 


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


* Ingresos por negocio propio o familiar no agrícola
tab u06_08 if u06_07==1, g(businessinc_)		// Validación OK
gen		businessinc_loss = businessinc_3


* Ingresos por actividad agricola, ganadería o pesca
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

