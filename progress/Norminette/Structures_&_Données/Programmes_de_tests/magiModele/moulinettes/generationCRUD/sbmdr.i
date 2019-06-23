/*------------------------------------------------------------------------
File        : sbmdr.i
Purpose     : Substitution du mode de règlement lors des demandes de tirage.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSbmdr
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field diman  as decimal    initial ?  decimals 2
    field dimdg  as decimal    initial ?  decimals 2
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field mdreg  as character  initial ? 
    field mdsub  as character  initial ? 
    field mttrt  as decimal    initial ?  decimals 2
    field nocop  as integer    initial ? 
    field noman  as integer    initial ? 
    field nomdg  as integer    initial ? 
    field nomds  as integer    initial ? 
    field noref  as character  initial ? 
    field nostr  as integer    initial ? 
    field notrt  as integer    initial ? 
    field tcdiv  as character  initial ? 
    field tpstr  as character  initial ? 
    field tptir  as character  initial ? 
    field tptrt  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
