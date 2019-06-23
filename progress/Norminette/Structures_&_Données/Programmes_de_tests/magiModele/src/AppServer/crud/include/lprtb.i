/*------------------------------------------------------------------------
File        : lprtb.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18 + Spo 04/10/2018
Notes       :
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLprtb
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field tpcon     as character initial ?
    field nocon     as integer   initial ?
    field noExe     as integer   initial ?
    field NoPer     as integer   initial ?
    field NoImm     as integer   initial ?
    field TpCpt     as character initial ?
    field NoRlv     as integer   initial ?
    field cdtrt     as character initial ?
    field cddev     as character initial ?
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field nocon-dec as decimal   initial ? decimals 0

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
