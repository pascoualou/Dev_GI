/*------------------------------------------------------------------------
File        : abail.i
Purpose     : Historique Droit de Bail
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAbail
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field daanx     as decimal    initial ?  decimals 2
    field daanx-dev as decimal    initial ?  decimals 2
    field daloy     as decimal    initial ?  decimals 2
    field daloy-dev as decimal    initial ?  decimals 2
    field dtcsy     as date       initial ? 
    field dtdpr     as date       initial ? 
    field dtems     as date       initial ? 
    field dtfpr     as date       initial ? 
    field dtmsy     as date       initial ? 
    field ExDba     as character  initial ? 
    field ExTad     as character  initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field msqui     as integer    initial ? 
    field mtanx     as decimal    initial ?  decimals 2
    field mtanx-dev as decimal    initial ?  decimals 2
    field mtdba     as decimal    initial ?  decimals 2
    field mtdba-dev as decimal    initial ?  decimals 2
    field mtloy     as decimal    initial ?  decimals 2
    field mtloy-dev as decimal    initial ?  decimals 2
    field mttad     as decimal    initial ?  decimals 2
    field mttad-dev as decimal    initial ?  decimals 2
    field mttoa     as decimal    initial ?  decimals 2
    field mttoa-dev as decimal    initial ?  decimals 2
    field mttol     as decimal    initial ?  decimals 2
    field mttol-dev as decimal    initial ?  decimals 2
    field noexe     as integer    initial ? 
    field noimm     as integer    initial ? 
    field noloc     as int64      initial ? 
    field noloc-dec as decimal    initial ?  decimals 0
    field nomdt     as integer    initial ? 
    field ntbai     as character  initial ? 
    field TxDba     as decimal    initial ?  decimals 2
    field TxTad     as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
