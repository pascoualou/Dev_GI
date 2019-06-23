/*------------------------------------------------------------------------
File        : pclie.i
Purpose     : 
Author(s)   : GGA - 2017/10/27
Notes       :
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPclie 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field tppar       as character initial ?
    field zon01       as character initial ?
    field zon02       as character initial ?
    field zon03       as character initial ?
    field zon04       as character initial ?
    field zon05       as character initial ?
    field zon06       as character initial ?
    field zon07       as character initial ?
    field zon08       as character initial ?
    field zon09       as character initial ?
    field zon10       as character initial ?
    field fgact       as character initial ?
    field cddev       as character initial ?
    field lbdiv       as character initial ?
    field lbdiv2      as character initial ?
    field lbdiv3      as character initial ?
    field mnt01       as decimal   initial ? decimals 2
    field mnt02       as decimal   initial ? decimals 2
    field mnt03       as decimal   initial ? decimals 2
    field mnt04       as decimal   initial ? decimals 2
    field mnt05       as decimal   initial ? decimals 2
    field mnt01-dev   as decimal   initial ? decimals 2
    field mnt02-dev   as decimal   initial ? decimals 2
    field mnt03-dev   as decimal   initial ? decimals 2
    field mnt04-dev   as decimal   initial ? decimals 2
    field mnt05-dev   as decimal   initial ? decimals 2
    field tau01       as decimal   initial ? decimals 2
    field tau02       as decimal   initial ? decimals 2
    field tau03       as decimal   initial ? decimals 2
    field tau04       as decimal   initial ? decimals 2
    field tau05       as decimal   initial ? decimals 2
    field int01       as int64     initial ?
    field int02       as int64     initial ?
    field int03       as int64     initial ?
    field int04       as int64     initial ?
    field int05       as int64     initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
