/*------------------------------------------------------------------------
File        : pclie.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPclie
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field fgact     as character  initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field int01     as int64      initial ? 
    field int02     as int64      initial ? 
    field int03     as int64      initial ? 
    field int04     as int64      initial ? 
    field int05     as int64      initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field mnt01     as decimal    initial ?  decimals 2
    field mnt01-dev as decimal    initial ?  decimals 2
    field mnt02     as decimal    initial ?  decimals 2
    field mnt02-dev as decimal    initial ?  decimals 2
    field mnt03     as decimal    initial ?  decimals 2
    field mnt03-dev as decimal    initial ?  decimals 2
    field mnt04     as decimal    initial ?  decimals 2
    field mnt04-dev as decimal    initial ?  decimals 2
    field mnt05     as decimal    initial ?  decimals 2
    field mnt05-dev as decimal    initial ?  decimals 2
    field tau01     as decimal    initial ?  decimals 2
    field tau02     as decimal    initial ?  decimals 2
    field tau03     as decimal    initial ?  decimals 2
    field tau04     as decimal    initial ?  decimals 2
    field tau05     as decimal    initial ?  decimals 2
    field tppar     as character  initial ? 
    field zon01     as character  initial ? 
    field zon02     as character  initial ? 
    field zon03     as character  initial ? 
    field zon04     as character  initial ? 
    field zon05     as character  initial ? 
    field zon06     as character  initial ? 
    field zon07     as character  initial ? 
    field zon08     as character  initial ? 
    field zon09     as character  initial ? 
    field zon10     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
