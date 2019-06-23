/*------------------------------------------------------------------------
File        : pndfsai.i
Purpose     : Fichier entete notes de frais
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPndfsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field coll-cle    as character  initial ? 
    field cours       as decimal    initial ?  decimals 8
    field cpt-cd      as character  initial ? 
    field daech       as date       initial ? 
    field dandf       as date       initial ? 
    field dev-cd      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field lib         as character  initial ? 
    field mtdev       as decimal    initial ?  decimals 2
    field mtdev-EURO  as decimal    initial ?  decimals 2
    field ndf-num     as integer    initial ? 
    field num-int     as integer    initial ? 
    field regl-cd     as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field sscoll-cle  as character  initial ? 
    field tva-enc-deb as logical    initial ? 
    field valid       as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
