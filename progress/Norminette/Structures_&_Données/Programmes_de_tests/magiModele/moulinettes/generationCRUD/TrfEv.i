/*------------------------------------------------------------------------
File        : TrfEv.i
Purpose     : Envois en attente 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTrfev
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy    as character  initial ? 
    field cddev    as character  initial ? 
    field cddtx    as character  initial ? 
    field cdmsy    as character  initial ? 
    field cdreg    as character  initial ? 
    field cdtir    as character  initial ? 
    field dtapp    as date       initial ? 
    field dtcsy    as date       initial ? 
    field dtmsy    as date       initial ? 
    field dttrt    as date       initial ? 
    field FgErreur as logical    initial ? 
    field FgSel    as logical    initial ? 
    field FgSpe    as logical    initial ? 
    field FgTrtOk  as logical    initial ? 
    field FgTxt    as logical    initial ? 
    field hecsy    as integer    initial ? 
    field hemsy    as integer    initial ? 
    field hetrt    as integer    initial ? 
    field lbdiv    as character  initial ? 
    field lbdiv2   as character  initial ? 
    field lbdiv3   as character  initial ? 
    field noapp    as integer    initial ? 
    field noapr    as integer    initial ? 
    field noexe    as integer    initial ? 
    field noexr    as integer    initial ? 
    field nomdt    as integer    initial ? 
    field noreg    as integer    initial ? 
    field TpApp    as character  initial ? 
    field TpApr    as character  initial ? 
    field TpTrf    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
