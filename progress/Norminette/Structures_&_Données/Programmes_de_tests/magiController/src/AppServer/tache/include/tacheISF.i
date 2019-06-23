/*------------------------------------------------------------------------
File        : tacheISF.i
Purpose     : 
Author(s)   : DM 20180111
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheISF
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache        as int64     initial ? label "noita"
    field cTypeContrat        as character initial ? label "tpcon"
    field iNumeroContrat      as int64     initial ? label "nocon"
    field cTypeTache          as character initial ? label "tptac"
    field iChronoTache        as integer   initial ? label "notac"
    field daActivation        as date                label "dtdeb"
    field cTypeDeclaration    as character initial ? label "tpges"
    field cTypePeriode        as character initial ? label "pdges"
    field lCalculSituFi       as logical   initial ?                 // cdreg
    field iCodeHonoraire      as integer   initial ? label "cdhon"
    field iAnneeISF           as integer   initial ?
    field dDepotGarantie      as decimal   initial ?
    field dTaxeFonciere       as decimal   initial ?
    field dTaxeOrdureMenagere as decimal   initial ?
    field dTaxeBalayage       as decimal   initial ?
    field dTaxeBureau         as decimal   initial ?
    field dQuotePart          as decimal   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
&if defined(nomTableSolde)   = 0 &then &scoped-define nomTableSolde ttSoldeProprietaireISF
&endif
&if defined(serialNameSolde) = 0 &then &scoped-define serialNameSolde {&nomTableSolde}
&endif
define temp-table {&nomTableSolde} no-undo serialize-name '{&serialNameSolde}'
    field iNumeroTache     as int64     initial ?
    field cNomProprietaire as character initial ?
    field dSolde           as decimal   initial ?
.
