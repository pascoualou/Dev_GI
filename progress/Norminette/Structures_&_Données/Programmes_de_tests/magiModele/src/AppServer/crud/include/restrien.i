/*------------------------------------------------------------------------
File        : restrien.i
Purpose     : 
Author(s)   : generation automatique le 08/08/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRestrien
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dtresil   as date
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field nbanndur  as integer   initial ?
    field nbjoudur  as integer   initial ?
    field nbmoisdur as integer   initial ?
    field nocon     as int64     initial ?
    field noord     as integer   initial ?
    field tpcon     as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
