/*------------------------------------------------------------------------
File        : assat.i
Description : toutes les valeurs initiales à ?
Author(s)   : kantena - 2016/10/10
Notes       : champs techniques utiles pour cette table
derniere revue: 2018/08/07 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAssat
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cddev     as character  initial ?
    field dtfin     as date
    field dtdeb     as date
    field dtrcp     as date
    field lbdiv     as character  initial ?
    field lbdiv2    as character  initial ?
    field lbdiv3    as character  initial ?
    field noatt     as integer    initial ?
    field nocon     as integer    initial ?
    field nocon-dec as decimal    initial ?
    field tpcon     as character  initial ?
    field tptac     as character  initial ?

    field cdcsy     as character  initial ?
    field cdmsy     as character  initial ?
    field dtcsy     as date
    field dtmsy     as date
    field hecsy     as integer    initial ?
    field hemsy     as integer    initial ?

    field CRUD        as character
    field dtTimestamp as datetime
    field rRowid      as rowid
.
