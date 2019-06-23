/*------------------------------------------------------------------------
File        : specif.i
Purpose     : definition de zones ou traitements specifiques
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSpecif
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field code     as character  initial ? 
    field dacrea   as date       initial ? 
    field damod    as date       initial ? 
    field etab-cd  as integer    initial ? 
    field ihcrea   as integer    initial ? 
    field ihmod    as integer    initial ? 
    field lib      as character  initial ? 
    field ord-num  as integer    initial ? 
    field soc-cd   as integer    initial ? 
    field usrid    as character  initial ? 
    field usridmod as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
