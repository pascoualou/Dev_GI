/*------------------------------------------------------------------------
File        : adbtva.i
Purpose     : 
Author(s)   : generation automatique le 08/08/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAdbtva
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ccrg            as character initial ?
    field cdivers         as character initial ?
    field chono           as character initial ?
    field cirf            as character initial ?
    field cmthono         as character initial ?
    field cpt-cd          as character initial ?
    field dacompta        as date
    field dacre           as date
    field date-quit       as date
    field date-trt        as date
    field date_decla      as date
    field dmttc           as decimal   initial ? decimals 2
    field dmttc-euro      as decimal   initial ? decimals 2
    field dmttva          as decimal   initial ? decimals 2
    field dmttva-euro     as decimal   initial ? decimals 2
    field ecrln-jou-cd    as character initial ?
    field ecrln-lig       as integer   initial ?
    field ecrln-piece-int as integer   initial ?
    field ecrln-prd-cd    as integer   initial ?
    field ecrln-prd-num   as integer   initial ?
    field etab-cd         as integer   initial ?
    field fg-acompte      as logical   initial ?
    field fg-man          as logical   initial ?
    field fg-regul        as logical   initial ?
    field fg-trait        as logical   initial ?
    field fract           as decimal   initial ? decimals 4
    field ihcre           as integer   initial ?
    field jou-cd          as character initial ?
    field let             as logical   initial ?
    field lib-trt         as character initial ?
    field lig             as integer   initial ?
    field mt              as decimal   initial ? decimals 2
    field mt-euro         as decimal   initial ? decimals 2
    field mtht            as decimal   initial ? decimals 2
    field mtht-euro       as decimal   initial ? decimals 2
    field mttc-ret        as decimal   initial ? decimals 2
    field mttc-ret-euro   as decimal   initial ? decimals 2
    field mtttc-deb       as decimal   initial ? decimals 2
    field mttva           as decimal   initial ? decimals 2
    field mttva-deb       as decimal   initial ? decimals 2
    field mttva-euro      as decimal   initial ? decimals 2
    field mttva-ret       as decimal   initial ? decimals 2
    field mttva-ret-euro  as decimal   initial ? decimals 2
    field ntcon           as character initial ?
    field num-int         as integer   initial ?
    field periode-cd      as integer   initial ?
    field piece-int       as integer   initial ?
    field prd-cd          as integer   initial ?
    field prd-num         as integer   initial ?
    field reactiv         as logical   initial ?
    field rec-dep         as logical   initial ?
    field sens            as logical   initial ?
    field soc-cd          as integer   initial ?
    field taux            as decimal   initial ? decimals 2
    field type-decla      as integer   initial ?
    field usridcre        as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
