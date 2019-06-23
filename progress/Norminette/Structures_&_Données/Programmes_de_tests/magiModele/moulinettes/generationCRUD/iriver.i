/*------------------------------------------------------------------------
File        : iriver.i
Purpose     : Tables des parametres RIVERMAP
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIriver
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cle1      as character  initial ? 
    field cle2      as character  initial ? 
    field cle3      as character  initial ? 
    field nomoption as character  initial ? 
    field nomtable  as character  initial ? 
    field valeurch1 as character  initial ? 
    field valeurch2 as character  initial ? 
    field valeurda1 as date       initial ? 
    field valeurda2 as date       initial ? 
    field valeurde1 as decimal    initial ?  decimals 2
    field valeurde2 as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
