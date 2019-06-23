/*------------------------------------------------------------------------
File        : tacheGarantLocataire.i
Purpose     : 
Author(s)   : SPo - 2018/06/05
Notes       : Gestion Roles annexes ("00013") couplée avec tache Garants du locataire ("04131")
              Tache mixte car 2 Tables impactées : intnt + tache
derniere revue: 2018/07/24 - spo: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLienGarantLocataire
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat          as character initial ? label "tpcon"
    field iNumeroContrat        as int64     initial ? label "nocon"
    field iNumeroGarant         as int64     initial ? label "noidt" 
    field cTypeRole             as character initial ? label "tpidt" 
    field cLienParente          as character initial ? label "lipar" 
    field cLibModeReglement     as character initial ? label "lbdiv3#1"         // entry(1, intnt.lbdiv3, SEPAR[1]) - libellé : Chèque ou Virement ou vide
    field cLbdiv3               as character initial ? label "lbdiv3"
    field dtTimestamp           as datetime
    field CRUD                  as character
    field rRowid                as rowid
    .
&if defined(nomTableTache)  = 0 &then &scoped-define nomTableTache ttTacheGarantLocataire
&endif
&if defined(serialNameTache) = 0 &then &scoped-define serialNameTache {&nomTableTache}
&endif
define temp-table {&nomTableTache} no-undo serialize-name '{&serialNameTache}'
    field cTypeContrat          as character initial ? label "tpcon"
    field iNumeroContrat        as int64     initial ? label "nocon"
    field iNumeroGarant         as int64     initial ? label "notac"
    field iNumeroTache          as int64     initial ? label 'noita'
    field cTypeTache            as character initial ? label "tptac"
    field daDebutGarant         as date                label "dtdeb"
    field daFinGarant           as date                label "dtfin"
    field cNumeroEnregistrement as character initial ? label "tpfin"
    field iDelaiPreavis         as integer   initial ? label "duree"   // en mois
    field daSignature           as date                label "ntges"
    field cLieuSignature        as character initial ? label "tpges"
    field cTypeActe             as character initial ? label "pdges"
    field cLibelleTypeActe      as character initial ?
    field iNombreJoursRelance   as integer   initial ? label "cdreg"
    field dMontantCaution       as decimal   initial ? label "mtreg"
    field dtTimestamp           as datetime
    field CRUD                  as character
    field rRowid                as rowid
.
