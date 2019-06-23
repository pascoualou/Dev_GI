/*------------------------------------------------------------------------
File        : codeFinancier2commercialisation.i
Purpose     : Variables préprocesseur des éléments financiers pour la commercialisation
Author(s)   : GI SPo - 12/01/2017
Notes       :
------------------------------------------------------------------------*/
// Familles éléments financiers
&GLOBAL-DEFINE TYPEFINANCE-Loyer                10
&GLOBAL-DEFINE TYPEFINANCE-Depot                20
// Honoraires ou Honoraires ALUR (table de calcul bareme)
&GLOBAL-DEFINE TYPEFINANCE-Honoraire            50

&GLOBAL-DEFINE TYPEFINANCE-Loyer-Lib            101072
&GLOBAL-DEFINE TYPEFINANCE-Depot-Lib            701570
&GLOBAL-DEFINE TYPEFINANCE-Honoraire-Lib        701091

&GLOBAL-DEFINE TYPELOYER-Habitation89           "00001"
&GLOBAL-DEFINE TYPELOYER-commercial             "00002"
&GLOBAL-DEFINE TYPELOYER-Stationnement          "00003"
&GLOBAL-DEFINE TYPELOYER-Habitation             "00004"

// Dépôt de garantie
&GLOBAL-DEFINE TYPEDEPOT-Garantie               1
&GLOBAL-DEFINE TYPEDEPOT-Annexe                 2

&GLOBAL-DEFINE TYPEROLEHONORAIRE                "00001"
&GLOBAL-DEFINE TYPEROLEHONORAIRE-alur           "00002"
// O_ROL Locataire
&GLOBAL-DEFINE TYPEROLEHONORAIRE-locataire      "00019"
// O_ROL mandant
&GLOBAL-DEFINE TYPEROLEHONORAIRE-proprietaire   "00022"
