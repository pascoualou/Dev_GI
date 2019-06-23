/*------------------------------------------------------------------------
File        : aspno.i
Purpose     : tables assurance propriétaire non occupant
Author(s)   : GGA - 2017/11/13
Notes       :
derniere revue: 2018/08/07 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAspno
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field tpcon       as character initial ?
    field nocon       as int64     initial ?
    field noord       as integer   initial ?
    field nolot       as integer   initial ?
    field noapp       as integer   initial ?
    field cdcmp       as character initial ?
    field numcontrat  as character initial ?
    field tpgar       as character initial ?
    field nogar       as integer   initial ?
    field nobar       as integer   initial ?
    field dtdebass    as date
    field dtfinass    as date
    field cmotif      as character initial ?
    field dtcotis1    as date
    field mtcotis1    as decimal   initial ? decimals 2
    field Fgtrtcotis1 as logical   initial ?
    field dttrtcotis1 as date
    field lbdiv       as character initial ?
    field lbdiv2      as character initial ?
    field lbdiv3      as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
