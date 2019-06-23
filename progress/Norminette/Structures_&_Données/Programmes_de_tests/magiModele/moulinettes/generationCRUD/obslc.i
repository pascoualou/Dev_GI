/*------------------------------------------------------------------------
File        : obslc.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttObslc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy         as character  initial ? 
    field cddev         as character  initial ? 
    field cdmsy         as character  initial ? 
    field dtcsy         as date       initial ? 
    field dtmaj-max     as integer    initial ? 
    field dtmaj-min     as integer    initial ? 
    field dtmsy         as date       initial ? 
    field hecsy         as integer    initial ? 
    field hemsy         as integer    initial ? 
    field lbdiv         as character  initial ? 
    field lbdiv2        as character  initial ? 
    field lbdiv3        as character  initial ? 
    field lbobs         as character  initial ? 
    field nboff         as integer    initial ? 
    field noapp-max     as integer    initial ? 
    field noapp-min     as integer    initial ? 
    field nocon-max     as integer    initial ? 
    field nocon-max-dec as decimal    initial ?  decimals 0
    field nocon-min     as integer    initial ? 
    field nocon-min-dec as decimal    initial ?  decimals 0
    field noobs         as integer    initial ? 
    field notxt         as integer    initial ? 
    field tbfam-max     as decimal    initial ?  decimals 2
    field tbfam-max-dev as decimal    initial ?  decimals 2
    field tbfam-min     as decimal    initial ?  decimals 2
    field tbfam-min-dev as decimal    initial ?  decimals 2
    field tbfam-moy     as decimal    initial ?  decimals 2
    field tbfam-moy-dev as decimal    initial ?  decimals 2
    field tbfam-tot     as decimal    initial ?  decimals 2
    field tbfam-tot-dev as decimal    initial ?  decimals 2
    field tpcon-max     as character  initial ? 
    field tpcon-min     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
