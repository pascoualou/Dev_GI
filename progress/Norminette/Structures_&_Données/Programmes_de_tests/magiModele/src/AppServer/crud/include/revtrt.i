/*------------------------------------------------------------------------
File        : revtrt.i
Purpose     : 0908/0110 - révisions legales / conventionnelles
Author(s)   : generation automatique le 04/27/18
Notes       : champs techniques utiles pour cette table
derniere revue: 2018/08/08 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRevtrt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field anirv     as integer    initial ?
    field cdact     as character  initial ?
    field cdirv     as integer    initial ?
    field cdsta     as character  initial ?
    field cdtrt     as character  initial ?
    field dtdeb     as date
    field dtfin     as date
    field dthis     as date
    field fghis     as logical    initial ?
    field fgloyref  as logical    initial ?
    field inotrtrev as integer    initial ?
    field lbcom     as character  initial ?
    field lbdiv     as character  initial ?
    field lbdiv2    as character  initial ?
    field lbdiv3    as character  initial ?
    field msqtt     as integer    initial ?
    field mtloyann  as decimal    initial ? decimals 2
    field nocon     as int64      initial ?
    field noeve     as integer    initial ?
    field noirv     as integer    initial ?
    field norol     as integer    initial ?
    field notrt     as integer    initial ?
    field tpcon     as character  initial ?
    field tphis     as character  initial ?
    field tprol     as character  initial ?
    field usrhis    as character  initial ?
    field vlirv     as decimal    initial ? decimals 2

    field cdcsy     as character  initial ?
    field cdmsy     as character  initial ?
    field dtcsy     as date
    field dtmsy     as date
    field hecsy     as integer    initial ?
    field hemsy     as integer    initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
