/*------------------------------------------------------------------------
File        : iftsai.i
Purpose     : 
Author(s)   : generation automatique le 08/08/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIftsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annul       as character initial ?
    field cdenr       as character initial ?
    field cours       as decimal   initial ? decimals 8
    field dacompta    as date
    field dacpta      as date
    field dacrea      as date
    field daech       as date
    field dafac       as date
    field damod       as date
    field dev-cd      as character initial ?
    field etab-cd     as integer   initial ?
    field fac-num     as integer   initial ?
    field fg-edifac   as logical   initial ?
    field fg-scen     as logical   initial ?
    field gestva-cd   as integer   initial ?
    field ihcpta      as integer   initial ?
    field ihcrea      as integer   initial ?
    field ihmod       as integer   initial ?
    field lib         as character initial ?
    field lib-ecr     as character initial ?
    field mt          as decimal   initial ? decimals 2
    field mt-dginit   as decimal   initial ? decimals 2
    field mt-euro     as decimal   initial ? decimals 2
    field mttva       as decimal   initial ? decimals 2
    field mttva-euro  as decimal   initial ? decimals 2
    field num-int     as integer   initial ?
    field regl-cd     as integer   initial ?
    field scen-cle    as character initial ?
    field soc-cd      as integer   initial ?
    field sscptg-cd   as character initial ?
    field tauxtvaqt   as decimal   initial ? decimals 3
    field tprole      as integer   initial ?
    field tx-dg       as decimal   initial ? decimals 2
    field type-cle    as integer   initial ?
    field typefac-cle as character initial ?
    field usrid       as character initial ?
    field usridmod    as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
