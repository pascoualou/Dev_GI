/*------------------------------------------------------------------------
File        : mpcpt.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMpcpt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcre  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cddeb  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdper  as character  initial ? 
    field cdter  as character  initial ? 
    field cpcre  as character  initial ? 
    field cpdeb  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field fgrep  as logical    initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field jocre  as integer    initial ? 
    field jodeb  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field nofam  as integer    initial ? 
    field nolib  as integer    initial ? 
    field norub  as integer    initial ? 
    field nosfa  as integer    initial ? 
    field ntbai  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
