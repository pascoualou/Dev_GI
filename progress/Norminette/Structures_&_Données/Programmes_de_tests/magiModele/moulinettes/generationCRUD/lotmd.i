/*------------------------------------------------------------------------
File        : lotmd.i
Purpose     : Archivage/Historique des cles des lots des mandats
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLotmd
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcle     as character  initial ? 
    field nocon     as integer    initial ? 
    field nocon-dec as decimal    initial ?  decimals 0
    field noimm     as integer    initial ? 
    field nolot     as integer    initial ? 
    field norep     as integer    initial ? 
    field tpcon     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
