/*------------------------------------------------------------------------
File        : lotlocat.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLotlocat
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdbat         as character  initial ? 
    field cdcsy         as character  initial ? 
    field cdesc         as character  initial ? 
    field cdeta         as character  initial ? 
    field cdmsy         as character  initial ? 
    field cdprin        as character  initial ? 
    field cdpte         as character  initial ? 
    field dtcsy         as date       initial ? 
    field dtmsy         as date       initial ? 
    field fgdiv         as logical    initial ? 
    field fgsup         as logical    initial ? 
    field hecsy         as integer    initial ? 
    field hemsy         as integer    initial ? 
    field lbdiv         as character  initial ? 
    field lbdiv2        as character  initial ? 
    field lbdiv3        as character  initial ? 
    field nbpie         as integer    initial ? 
    field nofiche       as integer    initial ? 
    field noimm         as integer    initial ? 
    field noloc         as integer    initial ? 
    field noloc-GI      as integer    initial ? 
    field nolot         as integer    initial ? 
    field noord         as integer    initial ? 
    field ntlot         as character  initial ? 
    field pcQuoPCHall   as decimal    initial ?  decimals 2
    field pcQuoPCPalier as decimal    initial ?  decimals 2
    field pcQuoPCPorte  as decimal    initial ?  decimals 2
    field pcsfannexe    as decimal    initial ?  decimals 2
    field pcsfutipriv   as decimal    initial ?  decimals 2
    field quoPCHall     as decimal    initial ?  decimals 2
    field quoPCPalier   as decimal    initial ?  decimals 2
    field quoPCPorte    as decimal    initial ?  decimals 2
    field sfannexe      as decimal    initial ?  decimals 2
    field SfTotPondm2   as decimal    initial ?  decimals 2
    field sfutipriv     as decimal    initial ?  decimals 2
    field surfpond      as decimal    initial ?  decimals 2
    field surfutile     as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
