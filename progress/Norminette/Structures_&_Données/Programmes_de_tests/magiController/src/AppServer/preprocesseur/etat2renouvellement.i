/*------------------------------------------------------------------------
File        : etat2renouvellement.i
Purpose     : Variables préprocesseur pour le module optionnel "procedures de renouvellement"
              Etat de la procedure de renouvellement
Author(s)   : GI SPo - 2018/08/01
Notes       : sys_pr "RNETA" tache 04160 zone tache.tpfin
------------------------------------------------------------------------*/
&GLOBAL-DEFINE ETATPROCRENOU-aucuneProcedure       "00"
&GLOBAL-DEFINE ETATPROCRENOU-procedureEnCours      "10"
&GLOBAL-DEFINE ETATPROCRENOU-quittanceAValider     "20"
&GLOBAL-DEFINE ETATPROCRENOU-attenteRenouvellement "30"
&GLOBAL-DEFINE ETATPROCRENOU-congeEnCours          "40"
&GLOBAL-DEFINE ETATPROCRENOU-renouvellementTermine "50"

