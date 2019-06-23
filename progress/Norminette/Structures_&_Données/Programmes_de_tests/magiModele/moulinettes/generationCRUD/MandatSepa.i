/*------------------------------------------------------------------------
File        : MandatSepa.i
Purpose     : Mandats de prélèvement SEPA
Fiche 0511/0023
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMandatsepa
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bicod         as character  initial ? 
    field cdChgBqu      as character  initial ? 
    field cdcsy         as character  initial ? 
    field cddur         as character  initial ? 
    field cdext         as character  initial ? 
    field cdmsy         as character  initial ? 
    field cdori         as character  initial ? 
    field cdstatut      as character  initial ? 
    field codeRUM       as character  initial ? 
    field Domicil       as character  initial ? 
    field dtcsy         as date       initial ? 
    field dtdeb         as date       initial ? 
    field dtEchNotif    as date       initial ? 
    field dtfin         as date       initial ? 
    field dtmsy         as date       initial ? 
    field dtNotif       as date       initial ? 
    field dtresil       as date       initial ? 
    field dtsig         as date       initial ? 
    field dtUtilisation as date       initial ? 
    field dtValide      as date       initial ? 
    field FgValide      as logical    initial ? 
    field hecsy         as integer    initial ? 
    field hemsy         as integer    initial ? 
    field iban          as character  initial ? 
    field lbdiv         as character  initial ? 
    field lbdiv2        as character  initial ? 
    field lbdiv3        as character  initial ? 
    field lbdiv4        as character  initial ? 
    field lbnom         as character  initial ? 
    field lisig         as character  initial ? 
    field lnom2         as character  initial ? 
    field Motifresil    as character  initial ? 
    field MtNotif       as decimal    initial ?  decimals 2
    field nbdur         as integer    initial ? 
    field noave         as integer    initial ? 
    field noblc         as integer    initial ? 
    field nocon         as int64      initial ? 
    field NoMandat      as int64      initial ? 
    field NomContact    as character  initial ? 
    field nomdt         as integer    initial ? 
    field noMPrelSEPA   as int64      initial ? 
    field NomReclam     as character  initial ? 
    field noord         as integer    initial ? 
    field norol         as int64      initial ? 
    field ntcon         as character  initial ? 
    field tpcon         as character  initial ? 
    field tpfin         as character  initial ? 
    field TpMandat      as character  initial ? 
    field tprol         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
