/*------------------------------------------------------------------------
File        : iprtspool.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIprtspool
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field da-edi       as date       initial ? 
    field fg-AppSv     as logical    initial ? 
    field form-cle     as character  initial ? 
    field heure-edi    as integer    initial ? 
    field info-fichier as character  initial ? 
    field lib          as character  initial ? 
    field order-num    as integer    initial ? 
    field page-garde   as logical    initial ? 
    field prg-name     as character  initial ? 
    field printer-name as character  initial ? 
    field type-prt     as character  initial ? 
    field util-num     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
