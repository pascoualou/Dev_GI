/*------------------------------------------------------------------------
File        : utilisateur.i
Description : dataset utilisateur
Author(s)   : kantena - 2016/03/18
Notes       :
  ----------------------------------------------------------------------*/

&if defined(nomTable)   = 0 &then &scoped-define nomTable ttUtilisateur 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif

define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCode                    as character
    field cCodeProfil              as character
    field cCodeLangue              as character
    field cNom                     as character
    field cEmail                   as character
    field cInitiales               as character
    field cCompte                  as character
    field cAccordMessage           as character
    field cCodeUtilSignataire1     as character /* ? = defaut / code utilisateur gestionnaire */
    field cCodeUtilSignataire2     as character /* ? = defaut / code utilisateur gestionnaire */
    field cCodeUtilSignataireEvent as character
    field cTypeRechercheTiers      as character /* C/T */
    field cTypeRechercheEvent      as character /* R/T/I/C */
    field lActif                   as logical
    field lIdentGiDemat            as logical
    field lGiprint                 as logical
    field cInfosGED                as character
    field iPaletteCouleur          as integer
    field iNumeroTiers             as integer
    field cTypeRole                as character
    field iNumeroRole              as integer
    field cNomRole                 as character
    field cPrenomRole              as character 
    field cImprimante              as character
    field lSelection               as logical initial true
index primaire iNumeroTiers
index secondaire cCode.
