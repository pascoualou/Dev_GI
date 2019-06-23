/*------------------------------------------------------------------------
File        : cecrln.i
Purpose     : Fichier des lignes d'ecritures
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCecrln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num       as integer    initial ? 
    field analytique       as logical    initial ? 
    field anclettre        as character  initial ? 
    field appel-num        as character  initial ? 
    field appel-rgrp       as character  initial ? 
    field cmthono          as character  initial ? 
    field coll-cle         as character  initial ? 
    field cpt-cd           as character  initial ? 
    field daaff            as date       initial ? 
    field dacompta         as date       initial ? 
    field dadoss           as date       initial ? 
    field daech            as date       initial ? 
    field dalettrage       as date       initial ? 
    field datecr           as date       initial ? 
    field dev-cd           as character  initial ? 
    field devetr-cd        as character  initial ? 
    field ecrln-jou-cd     as character  initial ? 
    field ecrln-lig        as integer    initial ? 
    field ecrln-piece-int  as integer    initial ? 
    field ecrln-prd-cd     as integer    initial ? 
    field ecrln-prd-num    as integer    initial ? 
    field etab-cd          as integer    initial ? 
    field fg-ana100        as logical    initial ? 
    field fg-eq            as logical    initial ? 
    field fg-man           as logical    initial ? 
    field fg-prorata       as logical    initial ? 
    field fg-reac          as logical    initial ? 
    field fg-reg           as logical    initial ? 
    field fg-sci           as logical    initial ? 
    field flag-lettre      as logical    initial ? 
    field fourn-cpt-cd     as character  initial ? 
    field fourn-sscoll-cle as character  initial ? 
    field id-fich          as int64      initial ? 
    field jou-cd           as character  initial ? 
    field lettre           as character  initial ? 
    field lib              as character  initial ? 
    field lib-ecr          as character  initial ? 
    field lien-adb         as character  initial ? 
    field lien-lig         as integer    initial ? 
    field lig              as integer    initial ? 
    field mandat-cd        as integer    initial ? 
    field mandat-prd-cd    as integer    initial ? 
    field mandat-prd-num   as integer    initial ? 
    field moiscpt          as integer    initial ? 
    field mt               as decimal    initial ?  decimals 2
    field mt-EURO          as decimal    initial ?  decimals 2
    field mtdev            as decimal    initial ?  decimals 2
    field mtinit           as decimal    initial ?  decimals 2
    field mtinit-EURO      as decimal    initial ?  decimals 2
    field mtreg            as decimal    initial ?  decimals 2
    field mtreg-EURO       as decimal    initial ?  decimals 2
    field mttva            as decimal    initial ?  decimals 2
    field mttva-dev        as decimal    initial ?  decimals 2
    field mttva-EURO       as decimal    initial ?  decimals 2
    field natscen-cd       as integer    initial ? 
    field noexo            as integer    initial ? 
    field num-crg          as integer    initial ? 
    field paie-regl        as logical    initial ? 
    field piece-int        as integer    initial ? 
    field prd-cd           as integer    initial ? 
    field prd-num          as integer    initial ? 
    field profil-cd        as integer    initial ? 
    field ref-num          as character  initial ? 
    field regl-cd          as integer    initial ? 
    field repart-ana       as character  initial ? 
    field sens             as logical    initial ? 
    field soc-cd           as integer    initial ? 
    field sscoll-cle       as character  initial ? 
    field statut           as integer    initial ? 
    field taux             as decimal    initial ?  decimals 8
    field taxe-cd          as integer    initial ? 
    field taxeinit         as integer    initial ? 
    field tot-det          as integer    initial ? 
    field tva-enc-deb      as logical    initial ? 
    field type-cle         as character  initial ? 
    field type-ecr         as integer    initial ? 
    field zone1            as character  initial ? 
    field zone2            as character  initial ? 
    field zone3            as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
