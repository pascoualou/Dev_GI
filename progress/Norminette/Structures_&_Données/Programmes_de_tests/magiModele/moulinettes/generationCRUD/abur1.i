/*------------------------------------------------------------------------
File        : abur1.i
Purpose     : Historique taxe de bureau (entete)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAbur1
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cddpt     as character  initial ? 
    field cdexe     as integer    initial ? 
    field cdmsy     as character  initial ? 
    field cdpos     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbcdi     as character  initial ? 
    field lbcdr     as character  initial ? 
    field lbcme     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbdpt     as character  initial ? 
    field noarr     as integer    initial ? 
    field noman     as integer    initial ? 
    field nomdt     as integer    initial ? 
    field sftt1     as integer    initial ? 
    field sftt2     as integer    initial ? 
    field tarf1     as decimal    initial ?  decimals 2
    field tarf1-dev as decimal    initial ?  decimals 2
    field tarf2     as decimal    initial ?  decimals 2
    field tarf2-dev as decimal    initial ?  decimals 2
    field tttax     as decimal    initial ?  decimals 2
    field tttax-dev as decimal    initial ?  decimals 2
    field tttx1     as decimal    initial ?  decimals 2
    field tttx1-dev as decimal    initial ?  decimals 2
    field tttx2     as decimal    initial ?  decimals 2
    field tttx2-dev as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
