/*------------------------------------------------------------------------
File        : type2charge.i
Purpose     : Variables préprocesseur des types de charge locatives 
              et autres paramètres pour le traitement des charges locatives
Author(s)   : GGA - 2018/01/22
Notes       :
    SPo 31/01/2018 : Ajout paramètre sys_pr : TRCHL, TRCH2, TRCH3
------------------------------------------------------------------------*/

&GLOBAL-DEFINE TYPECHARGE-Chauffage          "00001"
&GLOBAL-DEFINE TYPECHARGE-Locatives          "00010"
&GLOBAL-DEFINE TYPECHARGE-Loc_Chauf          "00011"

// TRCHL Tirage charges locatives (Critères)
// limité aux périodes de charges terminées 
&GLOBAL-DEFINE TYPEEXTRACTION2PERIODE-std   "00001" 
// libre
&GLOBAL-DEFINE TYPEEXTRACTION2PERIODE-libre "00002" 

// TRCH2 Extraction des provisions et consommations à partir des ...
// Quittances dont les dates sont incluses dans la période de charges 
&GLOBAL-DEFINE TYPEEXTRACTION2RUBPROVISION-std    "00001"     
// Quittances dont le Mois de traitement est inclus dans la période de charges
&GLOBAL-DEFINE TYPEEXTRACTION2RUBPROVISION-decale "00002"     

// TRCH3 Présentation des charges locatives
&GLOBAL-DEFINE TYPE2PRESENTATIONCHARGE-mandat    "00001"
&GLOBAL-DEFINE TYPE2PRESENTATIONCHARGE-immeuble  "00002"
