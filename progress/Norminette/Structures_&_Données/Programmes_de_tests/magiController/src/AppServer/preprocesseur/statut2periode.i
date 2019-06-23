/*------------------------------------------------------------------------
File        : statut2periode.i
Purpose     : Variables pr�processeur des statuts de traitement des p�riodes de charges (perio.cdtrt)
Author(s)   : GI SPo - 2018/04/03
Notes       : param�tre sys_pr "CDTRT" 
------------------------------------------------------------------------*/
// ant�riorit�
&GLOBAL-DEFINE STATUTPERIODE-Historique  "00000"
// non trait�
&GLOBAL-DEFINE STATUTPERIODE-EnCours     "00001"
// retirage demand�
&GLOBAL-DEFINE STATUTPERIODE-Retirage    "00002"
// trait�
&GLOBAL-DEFINE STATUTPERIODE-Traite      "00003"
