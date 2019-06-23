/*------------------------------------------------------------------------
File        : famqt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttFamqt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdfam as integer    initial ? 
    field cdsfa as integer    initial ? 
    field nome1 as integer    initial ? 
    field prg00 as character  initial ? 
    field prg01 as character  initial ? 
    field prg02 as character  initial ? 
    field prg03 as character  initial ? 
    field prg04 as character  initial ? 
    field prg05 as character  initial ? 
    field prg06 as character  initial ? 
    field prg07 as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
