/*------------------------------------------------------------------------
File        : type2charge.i
Purpose     : Variables pr�processeur des types de charge locatives 
              et autres param�tres pour le traitement des charges locatives
Author(s)   : GGA - 2018/01/22
Notes       :
    SPo 31/01/2018 : Ajout param�tre sys_pr : TRCHL, TRCH2, TRCH3
------------------------------------------------------------------------*/

&GLOBAL-DEFINE TYPECHARGE-Chauffage          "00001"
&GLOBAL-DEFINE TYPECHARGE-Locatives          "00010"
&GLOBAL-DEFINE TYPECHARGE-Loc_Chauf          "00011"

// TRCHL Tirage charges locatives (Crit�res)
// limit� aux p�riodes de charges termin�es 
&GLOBAL-DEFINE TYPEEXTRACTION2PERIODE-std   "00001" 
// libre
&GLOBAL-DEFINE TYPEEXTRACTION2PERIODE-libre "00002" 

// TRCH2 Extraction des provisions et consommations � partir des ...
// Quittances dont les dates sont incluses dans la p�riode de charges 
&GLOBAL-DEFINE TYPEEXTRACTION2RUBPROVISION-std    "00001"     
// Quittances dont le Mois de traitement est inclus dans la p�riode de charges
&GLOBAL-DEFINE TYPEEXTRACTION2RUBPROVISION-decale "00002"     

// TRCH3 Pr�sentation des charges locatives
&GLOBAL-DEFINE TYPE2PRESENTATIONCHARGE-mandat    "00001"
&GLOBAL-DEFINE TYPE2PRESENTATIONCHARGE-immeuble  "00002"
