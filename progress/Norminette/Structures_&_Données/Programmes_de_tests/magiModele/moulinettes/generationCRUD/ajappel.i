/*------------------------------------------------------------------------
File        : ajappel.i
Purpose     : lignes de detail d'appels de fonds
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAjappel
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field aful-jou-cd    as character  initial ? 
    field aful-mandat-cd as integer    initial ? 
    field aful-piece-int as integer    initial ? 
    field aful-prd-cd    as integer    initial ? 
    field aful-prd-num   as integer    initial ? 
    field ana4-cd        as character  initial ? 
    field appel-num      as character  initial ? 
    field appel-rgrp     as character  initial ? 
    field cmpg-mandat-cd as integer    initial ? 
    field cours          as decimal    initial ?  decimals 2
    field cptg-cd        as character  initial ? 
    field daech          as date       initial ? 
    field daeffet        as date       initial ? 
    field datir          as date       initial ? 
    field devetr-cd      as character  initial ? 
    field dtSolde        as date       initial ? 
    field etab-cd        as integer    initial ? 
    field fisc-cle       as integer    initial ? 
    field index-cd       as integer    initial ? 
    field lbdiv1         as character  initial ? 
    field lbdiv2         as character  initial ? 
    field lbdiv3         as character  initial ? 
    field lib-ecr        as character  initial ? 
    field lig            as integer    initial ? 
    field mt             as decimal    initial ?  decimals 2
    field mt-EURO        as decimal    initial ?  decimals 2
    field mtcmps         as decimal    initial ?  decimals 2
    field mtcmps-dev     as decimal    initial ?  decimals 2
    field mtcmps-EURO    as decimal    initial ?  decimals 2
    field mtdev          as decimal    initial ?  decimals 2
    field mtsolde        as decimal    initial ?  decimals 2
    field mttva          as decimal    initial ?  decimals 2
    field mttva-dev      as decimal    initial ?  decimals 2
    field mttva-EURO     as decimal    initial ?  decimals 2
    field natjou-gi      as character  initial ? 
    field nbech          as integer    initial ? 
    field pos            as integer    initial ? 
    field ref-num        as character  initial ? 
    field regl-cle       as character  initial ? 
    field rub-cd         as integer    initial ? 
    field sens           as logical    initial ? 
    field soc-cd         as integer    initial ? 
    field sscpt-cd       as character  initial ? 
    field ssrub-cd       as integer    initial ? 
    field taxe-cd        as integer    initial ? 
    field typapp         as character  initial ? 
    field type-cle       as character  initial ? 
    field type-ecr       as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
