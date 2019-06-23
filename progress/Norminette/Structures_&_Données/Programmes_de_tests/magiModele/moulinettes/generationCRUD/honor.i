/*------------------------------------------------------------------------
File        : honor.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttHonor
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field afpro     as decimal    initial ?  decimals 2
    field anirv     as integer    initial ? 
    field art-cle   as character  initial ? 
    field BoMax     as decimal    initial ?  decimals 2
    field BoMin     as decimal    initial ?  decimals 2
    field bs2hon    as character  initial ? 
    field bs3hon    as character  initial ? 
    field bshon     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdhon     as integer    initial ? 
    field cdirv     as integer    initial ? 
    field cdmsy     as character  initial ? 
    field cdtot     as character  initial ? 
    field cdtva     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dtrev     as date       initial ? 
    field fam-cle   as character  initial ? 
    field fgrev     as logical    initial ? 
    field fguti     as logical    initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbcom     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbhon     as character  initial ? 
    field mthon     as decimal    initial ?  decimals 2
    field mthon-dev as decimal    initial ?  decimals 2
    field mtmin     as decimal    initial ?  decimals 2
    field nocon     as integer    initial ? 
    field nohon     as integer    initial ? 
    field noirv     as integer    initial ? 
    field nt2hon    as character  initial ? 
    field nt3hon    as character  initial ? 
    field nthon     as character  initial ? 
    field pdhon     as character  initial ? 
    field sfam-cle  as character  initial ? 
    field surfo     as decimal    initial ?  decimals 2
    field surfo-dev as decimal    initial ?  decimals 2
    field tpcon     as character  initial ? 
    field tphon     as character  initial ? 
    field TxBor     as decimal    initial ?  decimals 2
    field txhon     as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
