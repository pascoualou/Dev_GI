/*------------------------------------------------------------------------
File        : param2dispositifFiscal.i
Purpose     : Variables préprocesseur des paramètres du dispositif fiscal des investisseurs étrangers
Author(s)   : GI SPo - 2018/10/18
Notes       : Module spécifique Baux FL BNP STUDELITE - local.lbdiv6
------------------------------------------------------------------------*/
// ENTRY(1,local.lbdiv6,separ[1]) : Nature bail investisseur du lot
&GLOBAL-DEFINE TYPEBAILINVESTISSEUR-aucun             "00000"
&GLOBAL-DEFINE TYPEBAILINVESTISSEUR-bailCivil         "00001"
&GLOBAL-DEFINE TYPEBAILINVESTISSEUR-bailCommercial    "00002"
&GLOBAL-DEFINE TYPEBAILINVESTISSEUR-bailProportionnel "00003"
&GLOBAL-DEFINE TYPEBAILINVESTISSEUR-mandatGestion     "00004"

// ENTRY(5,local.lbdiv6,separ[1]) : Domiciliation fiscale
&GLOBAL-DEFINE DOMICILIATIONFISCALE-france       "00001"
&GLOBAL-DEFINE DOMICILIATIONFISCALE-CEhorsFrance "00002"
&GLOBAL-DEFINE DOMICILIATIONFISCALE-horsCE       "00003"
