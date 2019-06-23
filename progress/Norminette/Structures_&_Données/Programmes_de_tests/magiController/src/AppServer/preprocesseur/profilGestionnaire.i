/*------------------------------------------------------------------------
File        : profilGestionnaire.i
Purpose     : Variables préprocesseur des action utilisateur
Author(s)   : Kantena - 2016/09/12
Notes       : GlGesUse
     0 : Administrateur         ==> Vision de toute les agences
     1 : Gestionnaire           ==> Vision de ses agences
     2 : Collaborateur de site  ==> Vision de ses agences
     3 : Collaborateur d'agence ==> Vision que sur une agence
     4 : Pas d'agence
------------------------------------------------------------------------*/

&GLOBAL-DEFINE PROFILGESTIONNAIRE-administrateur       0
&GLOBAL-DEFINE PROFILGESTIONNAIRE-gestionnaire         1
&GLOBAL-DEFINE PROFILGESTIONNAIRE-collaborateur2site   2
&GLOBAL-DEFINE PROFILGESTIONNAIRE-collaborateur2agence 3
&GLOBAL-DEFINE PROFILGESTIONNAIRE-pas2agence           4
