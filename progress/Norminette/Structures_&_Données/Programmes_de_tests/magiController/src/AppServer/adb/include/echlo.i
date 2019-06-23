/*------------------------------------------------------------------------
File        : echlo.i
Purpose     : 
Author(s)   : KANTENA  2018/01/05
Notes       :
derniere revue: 2018/04/25 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEchlo
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character initial ?
    field cddev     as character initial ?
    field cdmsy     as character initial ?
    field debtc     as decimal   initial ? extent 40 decimals 2
    field debtc-dev as decimal   initial ? extent 40 decimals 2
    field dtcsy     as date
    field dtdeb     as date
    field dtfin     as date
    field dtmsy     as date
    field fintc     as decimal   initial ? extent 40 decimals 2
    field fintc-dev as decimal   initial ? extent 40 decimals 2
    field hecsy     as integer   initial ?
    field hemsy     as integer   initial ?
    field idxfx     as logical   initial ?
    field idxmg     as logical   initial ?
    field idxpl     as logical   initial ?
    field idxtc     as logical   initial ? extent 40
    field jrcom     as integer   initial ?
    field lbact     as character initial ?
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field loyfx     as decimal   initial ? decimals 2
    field loyfx-dev as decimal   initial ? decimals 2
    field loymg     as decimal   initial ? decimals 2
    field loymg-dev as decimal   initial ? decimals 2
    field loypl     as decimal   initial ? decimals 2
    field loypl-dev as decimal   initial ? decimals 2
    field mscom     as integer   initial ?
    field noact     as integer   initial ?
    field nocal     as integer   initial ?
    field nocon     as int64     initial ?
    field nocon-dec as decimal   initial ? decimals 0
    field noper     as integer   initial ?
    field norub     as character initial ?
    field penal     as decimal   initial ? decimals 2
    field penal-dev as decimal   initial ? decimals 2
    field prcpl     as decimal   initial ? decimals 2
    field prctc     as decimal   initial ? extent 40 decimals 2
    field tpcon     as character initial ?

    field CRUD        as character 
    field dtTimestamp as datetime
    field rRowid      as rowid
.
