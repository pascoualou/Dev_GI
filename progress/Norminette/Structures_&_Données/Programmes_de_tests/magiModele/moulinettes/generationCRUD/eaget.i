/*------------------------------------------------------------------------
File        : eaget.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEaget
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy              as character  initial ? 
    field cddev              as character  initial ? 
    field cdmsy              as character  initial ? 
    field cdpos              as character  initial ? 
    field clep2              as character  initial ? 
    field clep3              as character  initial ? 
    field clep4              as character  initial ? 
    field clep5              as character  initial ? 
    field clep6              as character  initial ? 
    field clgen              as character  initial ? 
    field cLienNouveauModule as character  initial ? 
    field cTypeSaisie        as character  initial ? 
    field dtass              as date       initial ? 
    field dtcsy              as date       initial ? 
    field dtemi              as date       initial ? 
    field dtmsy              as date       initial ? 
    field dtnot              as date       initial ? 
    field hecsy              as integer    initial ? 
    field hemsy              as integer    initial ? 
    field hrass              as character  initial ? 
    field lbdiv              as character  initial ? 
    field lbdiv2             as character  initial ? 
    field lbdiv3             as character  initial ? 
    field lbdiv4             as character  initial ? 
    field lbdiv5             as character  initial ? 
    field lbvil              as character  initial ? 
    field lieu1              as character  initial ? 
    field lieu2              as character  initial ? 
    field lieu3              as character  initial ? 
    field lSimplifiee        as logical    initial ? 
    field noblc              as integer    initial ? 
    field nocon              as integer    initial ? 
    field nocon-dec          as decimal    initial ?  decimals 0
    field noint              as integer    initial ? 
    field tpass              as character  initial ? 
    field tpcon              as character  initial ? 
    field viemi              as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
