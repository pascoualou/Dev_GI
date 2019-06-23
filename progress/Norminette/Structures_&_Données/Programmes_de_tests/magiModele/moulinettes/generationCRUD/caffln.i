/*------------------------------------------------------------------------
File        : caffln.i
Purpose     : Lignes d'ecritures (conservation apres raz exercice)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCaffln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num   as integer    initial ? 
    field analytique   as logical    initial ? 
    field anclettre    as character  initial ? 
    field coll-cle     as character  initial ? 
    field cours        as decimal    initial ?  decimals 8
    field cpt-cd       as character  initial ? 
    field daaff        as date       initial ? 
    field dacompta     as date       initial ? 
    field daech        as date       initial ? 
    field dalettrage   as date       initial ? 
    field datecr       as date       initial ? 
    field dev-cd       as character  initial ? 
    field devetr-cd    as character  initial ? 
    field etab-cd      as integer    initial ? 
    field flag-lettre  as logical    initial ? 
    field jou-cd       as character  initial ? 
    field lettre       as character  initial ? 
    field lib          as character  initial ? 
    field lig          as integer    initial ? 
    field mt           as decimal    initial ?  decimals 2
    field mt-EURO      as decimal    initial ?  decimals 2
    field mtdev        as decimal    initial ?  decimals 2
    field paie-regl    as logical    initial ? 
    field piece-compta as integer    initial ? 
    field prd-cd       as integer    initial ? 
    field prd-num      as integer    initial ? 
    field ref-num      as character  initial ? 
    field sens         as logical    initial ? 
    field soc-cd       as integer    initial ? 
    field sscoll-cle   as character  initial ? 
    field taux         as decimal    initial ?  decimals 8
    field taxe-cd      as integer    initial ? 
    field tot-det      as integer    initial ? 
    field tva-enc-deb  as logical    initial ? 
    field type-cle     as character  initial ? 
    field zone1        as character  initial ? 
    field zone2        as character  initial ? 
    field zone3        as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
