/*------------------------------------------------------------------------
File        : tier2.i
Purpose     : complément information tiers
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTier2
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdimp  as character  initial ? 
    field cdlog  as character  initial ? 
    field cdmat  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdniv  as character  initial ? 
    field cdnom  as character  initial ? 
    field cdpai  as character  initial ? 
    field cdpos  as character  initial ? 
    field cdsec  as character  initial ? 
    field cduni  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field inf01  as character  initial ? 
    field inf02  as character  initial ? 
    field inf03  as character  initial ? 
    field inf04  as character  initial ? 
    field inf05  as character  initial ? 
    field inf06  as character  initial ? 
    field inf07  as character  initial ? 
    field inf08  as character  initial ? 
    field inf09  as character  initial ? 
    field inf10  as character  initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field nbenf  as integer    initial ? 
    field notie  as int64      initial ? 
    field pcall  as decimal    initial ?  decimals 2
    field tpmob  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
