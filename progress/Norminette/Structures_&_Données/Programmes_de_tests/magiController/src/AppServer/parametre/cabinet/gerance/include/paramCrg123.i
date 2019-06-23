/*------------------------------------------------------------------------
File        : paramCrg123.i
Purpose     : 
Author(s)   : OFA  -  2018/01/25
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttScenarioCrg123 no-undo  //alimentée par pclie "RBCRG"
    field tppar            as character
    field cCodeScenario    as character label "zon10"
    field cLibelleScenario as character label "lbdiv"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttRubriquesQuitScenarioCrg123 no-undo //alimentée par pclie "RBCRG"
    field tppar               as character
    field cCodeScenario       as character label "zon10"
    field cCodeFamille        as character label "int01"
    field cCodeSousFamille    as character label "int02"
    field cCodeRubrique       as character label "zon02"
    field cCodeLibelle        as character label "zon03"
    field cLibelleSousFamille as character
    field cLibelleRubrique    as character
    field cNumeroReleve       as character label "int03"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttRubriquesAnaScenarioCrg123 no-undo //alimentée par pclie "RBCRG"
    field tppar                as character
    field cCodeScenario        as character label "zon10"
    field cCodeRubrique        as character label "zon02"
    field cCodeSousRubrique    as character label "zon03"
    field cCodeFiscalite       as character label "zon04"
    field cLibelleRubrique     as character 
    field cLibelleSousRubrique as character 
    field cNumeroReleve        as character label "int03"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttFamillesRubriquesQuitt no-undo
    field cCodeFamille         as character
    field cCodeSousFamille     as character
    field cLibelleSousFamille  as character
.
define temp-table ttRubriquesQuitt no-undo
    field cCodeRubrique    as character
    field cCodeLibelle     as character
    field cLibelleRubrique as character
.
