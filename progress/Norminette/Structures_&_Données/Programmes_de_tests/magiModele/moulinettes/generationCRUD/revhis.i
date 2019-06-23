/*------------------------------------------------------------------------
File        : revhis.i
Purpose     : 0908/0110 - histo traitements révisions 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRevhis
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field anirv     as integer    initial ? 
    field cdact     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cdirv     as integer    initial ? 
    field cdmsy     as character  initial ? 
    field cdsta     as character  initial ? 
    field cdtrt     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtfin     as date       initial ? 
    field dthis     as date       initial ? 
    field dtmsy     as date       initial ? 
    field fghis     as logical    initial ? 
    field fgloyref  as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field inotrtrev as integer    initial ? 
    field lbcom     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbinf     as character  initial ? 
    field msqtt     as integer    initial ? 
    field mtloyann  as decimal    initial ?  decimals 2
    field nocon     as int64      initial ? 
    field NoEve     as integer    initial ? 
    field nohis     as integer    initial ? 
    field noirv     as integer    initial ? 
    field norol     as integer    initial ? 
    field notrt     as integer    initial ? 
    field tpcon     as character  initial ? 
    field tphis     as character  initial ? 
    field tprol     as character  initial ? 
    field usrhis    as character  initial ? 
    field vlirv     as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
