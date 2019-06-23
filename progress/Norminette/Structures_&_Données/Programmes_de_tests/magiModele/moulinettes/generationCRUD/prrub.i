/*------------------------------------------------------------------------
File        : prrub.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPrrub
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdaff     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cdfam     as integer    initial ? 
    field cdgen     as character  initial ? 
    field cdirf     as character  initial ? 
    field cdlib     as integer    initial ? 
    field cdlng     as integer    initial ? 
    field cdmsy     as character  initial ? 
    field cdrub     as integer    initial ? 
    field cdsfa     as integer    initial ? 
    field cdsig     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbcab     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbrub     as character  initial ? 
    field MsQtt     as integer    initial ? 
    field NoLoc     as int64      initial ? 
    field noloc-dec as decimal    initial ?  decimals 0
    field nome1     as integer    initial ? 
    field noqtt     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
