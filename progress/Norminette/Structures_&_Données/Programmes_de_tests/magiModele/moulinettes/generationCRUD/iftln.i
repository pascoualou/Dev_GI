/*------------------------------------------------------------------------
File        : iftln.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIftln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field brwcoll1    as character  initial ? 
    field brwcoll2    as character  initial ? 
    field cleadb      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field fac-num     as integer    initial ? 
    field fg-auto     as logical    initial ? 
    field fg-chgloc   as logical    initial ? 
    field fg-FL       as logical    initial ? 
    field fg-prorata  as logical    initial ? 
    field fg-val      as logical    initial ? 
    field fisc-cle    as character  initial ? 
    field lib-ecr     as character  initial ? 
    field lig         as integer    initial ? 
    field lig-tot     as integer    initial ? 
    field mtcre       as decimal    initial ?  decimals 2
    field mtcre-euro  as decimal    initial ?  decimals 2
    field mtdeb       as decimal    initial ?  decimals 2
    field mtdeb-euro  as decimal    initial ?  decimals 2
    field mtdevcre    as decimal    initial ?  decimals 2
    field mtdevdeb    as decimal    initial ?  decimals 2
    field mtdevtva    as decimal    initial ?  decimals 2
    field mttva       as decimal    initial ?  decimals 2
    field mttva-euro  as decimal    initial ?  decimals 2
    field num-int     as integer    initial ? 
    field rub-cd      as character  initial ? 
    field sens        as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field sscoll-cle  as character  initial ? 
    field sscpt-cd    as character  initial ? 
    field sscptg-cd   as character  initial ? 
    field ssrub-cd    as character  initial ? 
    field tbpun       as decimal    initial ?  decimals 4
    field tbqte       as decimal    initial ?  decimals 4
    field tot-det     as logical    initial ? 
    field tprole      as integer    initial ? 
    field tva-cd      as integer    initial ? 
    field tx-recuptva as decimal    initial ?  decimals 2
    field typecr-cd   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
