/*------------------------------------------------------------------------
File        : scfic.i
Purpose     : 0110/0169 : Fichiers joints liés à une société , à une opération et à une date
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttScfic
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy   as character  initial ? 
    field cdmsy   as character  initial ? 
    field dtcsy   as date       initial ? 
    field dthist  as date       initial ? 
    field dtmsy   as date       initial ? 
    field hecsy   as integer    initial ? 
    field hemsy   as integer    initial ? 
    field NmFic   as character  initial ? 
    field nosoc   as integer    initial ? 
    field nosui03 as integer    initial ? 
    field RpFic   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
