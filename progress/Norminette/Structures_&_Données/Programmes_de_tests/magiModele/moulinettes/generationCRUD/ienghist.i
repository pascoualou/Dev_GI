/*------------------------------------------------------------------------
File        : ienghist.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIenghist
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field action-cd as character  initial ? 
    field ana-cd    as character  initial ? 
    field art-cle   as character  initial ? 
    field daaction  as date       initial ? 
    field etab-cd   as integer    initial ? 
    field haction   as integer    initial ? 
    field lig       as integer    initial ? 
    field mt        as decimal    initial ?  decimals 2
    field mtrevise  as decimal    initial ?  decimals 2
    field niv-num   as integer    initial ? 
    field num-int   as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field usrid     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
