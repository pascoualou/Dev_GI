/*------------------------------------------------------------------------
File        : parspool.i
Purpose     : Parametrage Spool G.I.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParspool
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field specifique     as logical    initial ? 
    field specifique-cle as character  initial ? 
    field spool-descr    as character  initial ? 
    field spool-form     as character  initial ? 
    field spool-pref     as character  initial ? 
    field spool-prog     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
