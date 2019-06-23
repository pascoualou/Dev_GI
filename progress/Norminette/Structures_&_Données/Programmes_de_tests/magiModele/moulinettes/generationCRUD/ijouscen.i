/*------------------------------------------------------------------------
File        : ijouscen.i
Purpose     : Scenario de journal
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIjouscen
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr-cd           as integer    initial ? 
    field affair-num       as decimal    initial ?  decimals 0
    field analytique       as logical    initial ? 
    field coll-cle         as character  initial ? 
    field contrat-num      as character  initial ? 
    field cpt-cd           as character  initial ? 
    field etab-cd          as integer    initial ? 
    field fg-ana100        as logical    initial ? 
    field fourn-cpt-cd     as character  initial ? 
    field fourn-sscoll-cle as character  initial ? 
    field jou-cd           as character  initial ? 
    field lib              as character  initial ? 
    field lib-ecr          as character  initial ? 
    field lien-lig         as integer    initial ? 
    field mandat-cd        as integer    initial ? 
    field mt               as decimal    initial ?  decimals 2
    field mt-EURO          as decimal    initial ?  decimals 2
    field mttva            as decimal    initial ?  decimals 2
    field mttva-EURO       as decimal    initial ?  decimals 2
    field natjou-cd        as integer    initial ? 
    field ordre-num        as integer    initial ? 
    field profil-cd        as integer    initial ? 
    field regl-cd          as integer    initial ? 
    field scen-cle         as character  initial ? 
    field sens             as logical    initial ? 
    field soc-cd           as integer    initial ? 
    field sscoll-cle       as character  initial ? 
    field taxe-cd          as integer    initial ? 
    field tva-enc-deb      as logical    initial ? 
    field type-cle         as character  initial ? 
    field type-ecr         as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
