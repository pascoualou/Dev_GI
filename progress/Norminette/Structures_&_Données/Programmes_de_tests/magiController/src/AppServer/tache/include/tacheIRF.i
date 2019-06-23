/*------------------------------------------------------------------------
File        : tacheIRF.i
Purpose     : 
Author(s)   : DM 20180124
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheIRF
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache     as int64     initial ? label "noita"
    field cTypeContrat     as character initial ? label "tpcon"
    field iNumeroContrat   as int64     initial ? label "nocon"
    field cTypeTache       as character initial ? label "tptac"
    field iChronoTache     as integer   initial ? label "notac"
    field daActivation     as date                label "dtdeb" // Tache activé le 
    field cTypeDeclaration as character initial ? label "tpges" // CdDtaReg/HwDtaDec       Combo Déclaration "-" ou "Encaissement"
    field lMicroFoncier    as logical   initial ?               // pdreg/CdDtaMic/HwDtaMic Combo Micro Foncier en char
    field lDeclaration2072 as logical   initial ?               // dcreg/CdDtaDe2/HwDtaDe2 Combo Déclaration 2042 en char 
    field iCodeHonoraire   as integer   initial ?               // tache.cdhon en char

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
