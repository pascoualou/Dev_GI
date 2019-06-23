/*------------------------------------------------------------------------
File        : afps.i
Purpose     : lignes de detail prestations
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAfps
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana4-cd          as character  initial ? 
    field appel-num        as character  initial ? 
    field cours            as decimal    initial ?  decimals 2
    field cptg-cd          as character  initial ? 
    field daech            as date       initial ? 
    field datecr           as date       initial ? 
    field datir            as date       initial ? 
    field detail           as integer    initial ? 
    field devetr-cd        as character  initial ? 
    field etab-cd          as integer    initial ? 
    field fisc-cle         as integer    initial ? 
    field fourn-cpt-cd     as character  initial ? 
    field fourn-sscoll-cle as character  initial ? 
    field lib-ecr          as character  initial ? 
    field lig              as integer    initial ? 
    field mandat-cd        as integer    initial ? 
    field mt               as decimal    initial ?  decimals 2
    field mt-EURO          as decimal    initial ?  decimals 2
    field mtdev            as decimal    initial ?  decimals 2
    field mttot            as decimal    initial ?  decimals 2
    field mttot-dev        as decimal    initial ?  decimals 2
    field mttot-EURO       as decimal    initial ?  decimals 2
    field mttva            as decimal    initial ?  decimals 2
    field mttva-dev        as decimal    initial ?  decimals 2
    field mttva-EURO       as decimal    initial ?  decimals 2
    field mttvatot         as decimal    initial ?  decimals 2
    field mttvatot-dev     as decimal    initial ?  decimals 2
    field mttvatot-EURO    as decimal    initial ?  decimals 2
    field natjou-gi        as character  initial ? 
    field nolot            as integer    initial ? 
    field pos              as integer    initial ? 
    field ref-num          as character  initial ? 
    field rub-cd           as integer    initial ? 
    field sens             as logical    initial ? 
    field sens-tot         as logical    initial ? 
    field soc-cd           as integer    initial ? 
    field sscpt-cd         as character  initial ? 
    field ssrub-cd         as integer    initial ? 
    field taxe-cd          as integer    initial ? 
    field total            as integer    initial ? 
    field typapp           as character  initial ? 
    field type-cle         as character  initial ? 
    field type-ecr         as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
