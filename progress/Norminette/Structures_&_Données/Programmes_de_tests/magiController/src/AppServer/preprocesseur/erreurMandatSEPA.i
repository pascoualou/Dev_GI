/*------------------------------------------------------------------------
File        : erreurMandatSEPA.i
Purpose     : Variables préprocesseur des erreurs pour le mandat de prélèvement SEPA
              et délai d'inutilisation maximal : 36 mois sans être utilisé rend un mandat SEPA caduque (expiré)
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

