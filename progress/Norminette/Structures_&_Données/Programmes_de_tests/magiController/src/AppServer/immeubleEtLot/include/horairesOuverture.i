/*------------------------------------------------------------------------
File        : horairesOuverture.i
Description : 
Author(s)   : KANTENA - 2016/12/20
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
/*** LISTE OUVERTURE SERIE 1 ***/
define temp-table ttHorairesOuv{1}Serie1 no-undo serialize-name 'ttHorairesOuv{2}Serie1'
    field iNumeroIdentifiant as integer
    field lJourOuverture     as logical extent 7 initial ?   /* Initialisé à ? pour que l'instruction write-json exporte toujours les données */
    field cHeureDebut1       as character
    field cHeureFin1         as character
    field cHeureDebut2       as character
    field cHeureFin2         as character
.
/*** LISTE OUVERTURE SERIE 2 ***/
define temp-table ttHorairesOuv{1}Serie2 no-undo serialize-name 'ttHorairesOuv{2}Serie2'
    field iNumeroIdentifiant as integer
    field lJourOuverture     as logical extent 7 initial ?   /* Initialisé à ? pour que l'instruction write-json exporte toujours les données */
    field cHeureDebut1       as character
    field cHeureFin1         as character
    field cHeureDebut2       as character
    field cHeureFin2         as character
.
