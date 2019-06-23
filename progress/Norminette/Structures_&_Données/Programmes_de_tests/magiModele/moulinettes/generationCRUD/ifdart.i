/*------------------------------------------------------------------------
File        : ifdart.i
Purpose     : Table des articles
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdart
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field art-cle    as character  initial ? 
    field autrelang  as logical    initial ? 
    field categ-cle  as character  initial ? 
    field dacreat    as date       initial ? 
    field damodif    as date       initial ? 
    field desig1     as character  initial ? 
    field desig2     as character  initial ? 
    field desigcomp  as logical    initial ? 
    field dev-cd     as character  initial ? 
    field fg-texte   as logical    initial ? 
    field pr         as decimal    initial ?  decimals 2
    field pr-EURO    as decimal    initial ?  decimals 2
    field puht       as decimal    initial ?  decimals 2
    field puht-EURO  as decimal    initial ?  decimals 2
    field rgt-cle    as character  initial ? 
    field soc-cd     as integer    initial ? 
    field tarif      as decimal    initial ?  decimals 2
    field tarif-EURO as decimal    initial ?  decimals 2
    field taxe-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
