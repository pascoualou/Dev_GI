/*-----------------------------------------------------------------------------
File        : type2bareme.i
Purpose     : Variables pr�processeur des types de bareme et autres param�tres pour assurance  
Author(s)   : RF 10/11/2017
Notes       : Utilis� dans le param�trage des assurances garantie loyer (GLo, GRL, PNO...)
-----------------------------------------------------------------------------*/
// Commercial et usage professionnel, ou habitation
&GLOBAL-DEFINE TYPEBAREME-Commercial    "00001"
&GLOBAL-DEFINE TYPEBAREME-Habitation    "00002"
// bar�me au forfait (montant) ou au taux
&GLOBAL-DEFINE BAREME-TAUX              "TX"
&GLOBAL-DEFINE BAREME-FORFAIT           "MT"
// TVA sur...
&GLOBAL-DEFINE TVABAREME-COTIS-ET-HONO  "1"
&GLOBAL-DEFINE TVABAREME-HONORAIRE      "2"

