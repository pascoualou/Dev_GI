/*------------------------------------------------------------------------
File        : tacheCrl.i
Purpose     : 
Author(s)   : GGA  -  2017/11/08
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheCrl
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache      as int64     initial ? label "noita"
    field cTypeContrat      as character initial ? label "tpcon"
    field iNumeroContrat    as int64     initial ? label "nocon"
    field cTypeTache        as character initial ? label "tptac"
    field iChronoTache      as integer   initial ? label "notac"
    field daActivation      as date                label "dtdeb"
    field cEncaissePar      as character initial ? label "ntges"
    field cLibEncaissePar   as character initial ?
    field cDeclaration      as character initial ? label "tpges"
    field cLibDeclaration   as character initial ? 
    field cCentreImpot      as character initial ? label "dcreg"
    field cPeriode          as character initial ? label "pdges"
    field cLibPeriode       as character initial ? 
    field lComptabilisation as logical   initial ? label "cdreg" format {&CODEREGLEMENT-ouiNon}
    field cCentreRecette    as character initial ? label "utreg"
    field cTypeHonoraire    as character initial ? label "tphon"
    field cLibTypeHonoraire as character initial ?
    field cCodeHonoraire    as character initial ? label "cdhon"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
