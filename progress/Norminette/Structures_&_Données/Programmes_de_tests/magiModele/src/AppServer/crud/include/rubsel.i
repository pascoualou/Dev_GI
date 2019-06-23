/*------------------------------------------------------------------------
File        : rubsel.i
Purpose     :
Author(s)   : DM 2017/10/03
Notes       :  
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRubsel
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ixd01 as character initial ?
    field cdrub as character initial ?
    field cdlib as character initial ?
    field tpmdt as character initial ?
    field nomdt as integer   initial ?
    field tpct2 as character initial ?
    field noct2 as int64     initial ?
    field tptac as character initial ?
    field tprub as character initial ?
    field notri as integer   initial ?
    field lbdiv as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
