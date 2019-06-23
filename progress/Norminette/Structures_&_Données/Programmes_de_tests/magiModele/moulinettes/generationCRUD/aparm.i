/*------------------------------------------------------------------------
File        : aparm.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAparm
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdpar    as character  initial ? 
    field dacrea   as date       initial ? 
    field damod    as date       initial ? 
    field etab-cd  as integer    initial ? 
    field ihcrea   as integer    initial ? 
    field ihmod    as integer    initial ? 
    field lib      as character  initial ? 
    field nome1    as integer    initial ? 
    field nome2    as integer    initial ? 
    field soc-cd   as integer    initial ? 
    field tppar    as character  initial ? 
    field usrid    as character  initial ? 
    field usridmod as character  initial ? 
    field zone1    as decimal    initial ?  decimals 2
    field zone2    as character  initial ? 
    field zone3    as character  initial ? 
    field zone4    as character  initial ? 
    field zone5    as character  initial ? 
    field zone6    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
