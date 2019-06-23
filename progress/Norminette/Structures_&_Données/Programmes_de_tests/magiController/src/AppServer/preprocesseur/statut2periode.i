/*------------------------------------------------------------------------
File        : statut2periode.i
Purpose     : Variables préprocesseur des statuts de traitement des périodes de charges (perio.cdtrt)
Author(s)   : GI SPo - 2018/04/03
Notes       : paramètre sys_pr "CDTRT" 
------------------------------------------------------------------------*/
// antériorité
&GLOBAL-DEFINE STATUTPERIODE-Historique  "00000"
// non traité
&GLOBAL-DEFINE STATUTPERIODE-EnCours     "00001"
// retirage demandé
&GLOBAL-DEFINE STATUTPERIODE-Retirage    "00002"
// traité
&GLOBAL-DEFINE STATUTPERIODE-Traite      "00003"
