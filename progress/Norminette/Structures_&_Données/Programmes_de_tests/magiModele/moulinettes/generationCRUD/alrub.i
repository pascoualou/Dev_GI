/*------------------------------------------------------------------------
File        : alrub.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAlrub
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cfb-cd     as character  initial ? 
    field cpt-cd     as character  initial ? 
    field dafin      as date       initial ? 
    field fg-999     as logical    initial ? 
    field fg-use     as logical    initial ? 
    field fisc-cle   as character  initial ? 
    field honodas    as character  initial ? 
    field honoraires as character  initial ? 
    field profil-cd  as integer    initial ? 
    field rub-cd     as character  initial ? 
    field rub-old    as character  initial ? 
    field soc-cd     as integer    initial ? 
    field ssrub-cd   as character  initial ? 
    field tx-fisc    as decimal    initial ?  decimals 2
    field type-chg   as character  initial ? 
    field type-rub   as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
