/*-----------------------------------------------------------------------------
File        : honor.i
Purpose     : 
Author(s)   : DM  -  2017/10/19
Notes       : 
derniere revue: 2018/08/08 - phm: 
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttHonor
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field nohon       as integer   initial ?
    field tphon       as character initial ?
    field cdhon       as integer   initial ?
    field nthon       as character initial ?
    field bshon       as character initial ?
    field mthon       as decimal   initial ? decimals 2
    field txhon       as decimal   initial ? decimals 2
    field cdtot       as character initial ?
    field lbhon       as character initial ?
    field cdtva       as character initial ?
    field pdhon       as character initial ?
    field fguti       as logical
    field lbcom       as character initial ?
    field surfo       as decimal   initial ? decimals 2 extent 5
    field afpro       as decimal   initial ? decimals 2
    field surfo-dev   as decimal   initial ? decimals 2 extent 5
    field mthon-dev   as decimal   initial ? decimals 2
    field cddev       as character initial ?
    field lbdiv       as character initial ?
    field lbdiv2      as character initial ?
    field lbdiv3      as character initial ?
    // tranche d'honoraire non utilisées (BoMin, BoMax, TxBor), utilisation de la table fille trhon
    field BoMin       as decimal   initial ? decimals 2 extent 20
    field BoMax       as decimal   initial ? decimals 2 extent 20
    field TxBor       as decimal   initial ? decimals 2 extent 20
    field tpcon       as character initial ?
    field nocon       as integer   initial ?
    field dtdeb       as date
    field mtmin       as decimal   initial ? decimals 2
    field fam-cle     as character initial ?
    field sfam-cle    as character initial ?
    field art-cle     as character initial ?
    field fgrev       as logical
    field dtrev       as date
    field cdirv       as integer   initial ?
    field anirv       as integer   initial ?
    field noirv       as integer   initial ?
    field dtfin       as date
    field bs2hon      as character initial ?
    field bs3hon      as character initial ?
    field nt2hon      as character initial ?
    field nt3hon      as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    .
