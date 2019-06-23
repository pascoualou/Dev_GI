/*------------------------------------------------------------------------
File        : erreurMandatSEPA.i
Purpose     : Variables pr�processeur des erreurs pour le mandat de pr�l�vement SEPA
              et d�lai d'inutilisation maximal : 36 mois sans �tre utilis� rend un mandat SEPA caduque (expir�)
Author(s)   : SPo 2018/06/19
Notes       : Variable sys_pr : SAERR
------------------------------------------------------------------------*/
&GLOBAL-DEFINE ERRMANDATSEPA-AbsenceSignature  "00001"
&GLOBAL-DEFINE ERRMANDATSEPA-Resilie           "00002"
&GLOBAL-DEFINE ERRMANDATSEPA-Expire36Mois      "00003"
&GLOBAL-DEFINE ERRMANDATSEPA-AbsenceIBAN       "00004"
&GLOBAL-DEFINE ERRMANDATSEPA-IBANHorsZoneSEPA  "00005"
&GLOBAL-DEFINE ERRMANDATSEPA-AbsenceMandatSepa "00099"
// Non bloquant
&GLOBAL-DEFINE ERRMANDATSEPA-ChangementIBAN    "00501"

&GLOBAL-DEFINE DELAIEXPIRATION-36mois          36

