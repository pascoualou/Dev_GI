/*------------------------------------------------------------------------
File        : zecr.i
Purpose     : Fichier pour creation des ecritures 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttZecr
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field an-jou-cd    as character  initial ? 
    field an-piece     as integer    initial ? 
    field ana1-cd      as character  initial ? 
    field bur-cd       as integer    initial ? 
    field cdaech       as character  initial ? 
    field cdaecr       as character  initial ? 
    field coll-cle     as character  initial ? 
    field cpt-aux      as character  initial ? 
    field cpt-cd       as character  initial ? 
    field cpt-gen      as integer    initial ? 
    field csens        as character  initial ? 
    field daech        as date       initial ? 
    field daecr        as date       initial ? 
    field dev-cd       as character  initial ? 
    field devetr-cd    as character  initial ? 
    field etab-cd      as integer    initial ? 
    field jou-cd       as character  initial ? 
    field lib          as character  initial ? 
    field libcat-cd    as integer    initial ? 
    field liberr       as character  initial ? 
    field libimp-cd    as integer    initial ? 
    field libtier-cd   as integer    initial ? 
    field libtype-cd   as integer    initial ? 
    field lig-tmp      as integer    initial ? 
    field mt           as decimal    initial ?  decimals 2
    field mtdev        as decimal    initial ?  decimals 2
    field natjou-cd    as integer    initial ? 
    field numchq       as character  initial ? 
    field piece-compta as integer    initial ? 
    field piece-int    as integer    initial ? 
    field prd-cd       as integer    initial ? 
    field prd-num      as integer    initial ? 
    field ref-fac      as character  initial ? 
    field ref-num      as character  initial ? 
    field regl-cd      as integer    initial ? 
    field sens         as logical    initial ? 
    field soc-cd       as integer    initial ? 
    field sscoll-cle   as character  initial ? 
    field taux         as decimal    initial ?  decimals 8
    field taxe-cd      as integer    initial ? 
    field type-cle     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
