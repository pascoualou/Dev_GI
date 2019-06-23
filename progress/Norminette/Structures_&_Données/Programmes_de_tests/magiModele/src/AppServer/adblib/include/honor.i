/*-----------------------------------------------------------------------------
File        : honor.i
Purpose     : 
Author(s)   : DM  -  2017/10/19
Notes       : 
derniere revue: 2018/05/17 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttHonor
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dtcsy     as date
    field hecsy     as integer
    field cdcsy     as character
    field dtmsy     as date
    field hemsy     as integer
    field cdmsy     as character
    field nohon     as integer
    field tphon     as character
    field cdhon     as integer
    field nthon     as character
    field bshon     as character
    field mthon     as decimal      decimals 2
    field txhon     as decimal      decimals 2
    field cdtot     as character
    field lbhon     as character
    field cdtva     as character
    field pdhon     as character
    field fguti     as logical
    field lbcom     as character
    field surfo     as decimal      decimals 2 extent 5
    field afpro     as decimal      decimals 2
    field surfo-dev as decimal      decimals 2 extent 5
    field mthon-dev as decimal      decimals 2
    field cddev     as character
    field lbdiv     as character
    field lbdiv2    as character
    field lbdiv3    as character
    field BoMin     as decimal      decimals 2 extent 20
    field BoMax     as decimal      decimals 2 extent 20
    field TxBor     as decimal      decimals 2 extent 20
    field tpcon     as character
    field nocon     as integer
    field dtdeb     as date
    field mtmin     as decimal      decimals 2
    field fam-cle   as character
    field sfam-cle  as character
    field art-cle   as character
    field fgrev     as logical
    field dtrev     as date
    field cdirv     as integer
    field anirv     as integer
    field noirv     as integer
    field dtfin     as date
    field bs2hon    as character
    field bs3hon    as character
    field nt2hon    as character
    field nt3hon    as character

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
