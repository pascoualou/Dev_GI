/*------------------------------------------------------------------------
File        : apreln.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttApreln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bic           as character  initial ? 
    field bque          as character  initial ? 
    field cdfic         as character  initial ? 
    field cours         as decimal    initial ?  decimals 2
    field cpt           as character  initial ? 
    field cptg-cd       as character  initial ? 
    field daech         as date       initial ? 
    field devetr-cd     as character  initial ? 
    field domiciliation as character  initial ? 
    field dtder         as date       initial ? 
    field dtree         as date       initial ? 
    field dtsig         as date       initial ? 
    field dtSolde       as date       initial ? 
    field etab-cd       as integer    initial ? 
    field guichet       as character  initial ? 
    field iban          as character  initial ? 
    field ics           as character  initial ? 
    field lbdiv1        as character  initial ? 
    field lbdiv2        as character  initial ? 
    field lbdiv3        as character  initial ? 
    field lib-ecr1      as character  initial ? 
    field lib-ecr2      as character  initial ? 
    field ListeDatMtEch as character  initial ? 
    field mt            as decimal    initial ?  decimals 2
    field mt-EURO       as decimal    initial ?  decimals 2
    field mtdev         as decimal    initial ?  decimals 2
    field mtsolde       as decimal    initial ?  decimals 2
    field nbech         as integer    initial ? 
    field norol         as int64      initial ? 
    field norum         as character  initial ? 
    field norum-anc     as character  initial ? 
    field ref-num       as character  initial ? 
    field rib-cle       as character  initial ? 
    field SMNDA         as logical    initial ? 
    field soc-cd        as integer    initial ? 
    field sscpt-cd      as character  initial ? 
    field titulaire     as character  initial ? 
    field tp-trait      as integer    initial ? 
    field tprol         as character  initial ? 
    field tpseq         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
