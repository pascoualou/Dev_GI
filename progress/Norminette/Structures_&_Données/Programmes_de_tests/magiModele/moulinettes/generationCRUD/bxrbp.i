/*------------------------------------------------------------------------
File        : bxrbp.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttBxrbp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field aslib as integer    initial ? 
    field asrub as integer    initial ? 
    field cdcsy as character  initial ? 
    field cdfam as integer    initial ? 
    field cdgen as character  initial ? 
    field cdmsy as character  initial ? 
    field cdsfa as integer    initial ? 
    field cdsig as character  initial ? 
    field dtcsy as date       initial ? 
    field dtmsy as date       initial ? 
    field hecsy as integer    initial ? 
    field hemsy as integer    initial ? 
    field nolib as integer    initial ? 
    field noord as integer    initial ? 
    field norub as integer    initial ? 
    field ntbai as character  initial ? 
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
