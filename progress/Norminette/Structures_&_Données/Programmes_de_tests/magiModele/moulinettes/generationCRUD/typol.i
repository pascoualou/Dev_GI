/*------------------------------------------------------------------------
File        : typol.i
Purpose     : Typologie
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTypol
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdTrt  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtini  as character  initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lbpro  as character  initial ? 
    field nbfre  as integer    initial ? 
    field nbrev  as integer    initial ? 
    field nodot  as integer    initial ? 
    field noidt  as int64      initial ? 
    field nomod  as integer    initial ? 
    field ntcon  as character  initial ? 
    field utfre  as character  initial ? 
    field utrev  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
