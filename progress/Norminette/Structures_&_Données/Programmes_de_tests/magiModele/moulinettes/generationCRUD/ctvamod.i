/*------------------------------------------------------------------------
File        : ctvamod.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCtvamod
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field coll-cle     as character  initial ? 
    field cpt-cd       as character  initial ? 
    field damod        as date       initial ? 
    field effet        as logical    initial ? 
    field etab-cd      as integer    initial ? 
    field jou-cd       as character  initial ? 
    field let          as logical    initial ? 
    field lig          as integer    initial ? 
    field modif        as logical    initial ? 
    field mt           as decimal    initial ?  decimals 2
    field mt-EURO      as decimal    initial ?  decimals 2
    field noord        as integer    initial ? 
    field piece-compta as integer    initial ? 
    field piece-int    as integer    initial ? 
    field prd-cd       as integer    initial ? 
    field prd-num      as integer    initial ? 
    field ref-num      as character  initial ? 
    field sens         as logical    initial ? 
    field soc-cd       as integer    initial ? 
    field sscoll-cle   as character  initial ? 
    field taxe-cd      as integer    initial ? 
    field tva-enc-deb  as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
