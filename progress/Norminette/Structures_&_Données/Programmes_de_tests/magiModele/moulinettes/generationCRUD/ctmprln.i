/*------------------------------------------------------------------------
File        : ctmprln.i
Purpose     : Fichier Reglements (Gestion des Encaissements)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCtmprln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr              as character  initial ? 
    field affair-num       as integer    initial ? 
    field ana-cd           as character  initial ? 
    field ana1-cd          as character  initial ? 
    field ana2-cd          as character  initial ? 
    field ana3-cd          as character  initial ? 
    field ana4-cd          as character  initial ? 
    field analytique       as logical    initial ? 
    field bic              as character  initial ? 
    field bqjou-cd         as character  initial ? 
    field bque             as character  initial ? 
    field bque-nom         as character  initial ? 
    field coll-cle         as character  initial ? 
    field cours            as decimal    initial ?  decimals 8
    field cpt              as character  initial ? 
    field cpt-cd           as character  initial ? 
    field cptetr           as character  initial ? 
    field dacompta         as date       initial ? 
    field dacre            as date       initial ? 
    field daech            as date       initial ? 
    field daremise         as date       initial ? 
    field davaleur         as date       initial ? 
    field dev-cd           as character  initial ? 
    field devetr-cd        as character  initial ? 
    field domicil          as character  initial ? 
    field ecrln-jou-cd     as character  initial ? 
    field ecrln-lig        as integer    initial ? 
    field ecrln-piece-int  as integer    initial ? 
    field ecrln-prd-cd     as integer    initial ? 
    field ecrln-prd-num    as integer    initial ? 
    field etab-cd          as integer    initial ? 
    field etr              as logical    initial ? 
    field fg-ana100        as logical    initial ? 
    field flag-transfert   as integer    initial ? 
    field fourn-cpt-cd     as character  initial ? 
    field fourn-sscoll-cle as character  initial ? 
    field guichet          as character  initial ? 
    field iban             as character  initial ? 
    field jou-cd           as character  initial ? 
    field lib              as character  initial ? 
    field lib-ecr          as character  initial ? 
    field libacc-cd        as integer    initial ? 
    field libtier-cd       as integer    initial ? 
    field lien-lig         as integer    initial ? 
    field lig              as integer    initial ? 
    field lig-reg          as integer    initial ? 
    field lig-tot          as integer    initial ? 
    field magnetique       as logical    initial ? 
    field mandat-cd        as integer    initial ? 
    field mandat-prd-cd    as integer    initial ? 
    field mandat-prd-num   as integer    initial ? 
    field mt               as decimal    initial ?  decimals 2
    field mt-EURO          as decimal    initial ?  decimals 2
    field mtdev            as decimal    initial ?  decimals 2
    field mttva            as decimal    initial ?  decimals 2
    field mttva-dev        as decimal    initial ?  decimals 2
    field mttva-EURO       as decimal    initial ?  decimals 2
    field num-bor          as integer    initial ? 
    field num-chq          as character  initial ? 
    field num-int          as integer    initial ? 
    field num-remise       as integer    initial ? 
    field num-rlmc         as character  initial ? 
    field num-zib          as character  initial ? 
    field num-zin          as character  initial ? 
    field ordre-num        as integer    initial ? 
    field piece-bque       as character  initial ? 
    field piece-int        as integer    initial ? 
    field prd-cd           as integer    initial ? 
    field prd-num          as integer    initial ? 
    field profil-cd        as integer    initial ? 
    field ref-num          as character  initial ? 
    field ref-tire         as character  initial ? 
    field repart-ana       as character  initial ? 
    field rib              as character  initial ? 
    field soc-cd           as integer    initial ? 
    field sscoll-cle       as character  initial ? 
    field taxe-cd          as integer    initial ? 
    field tiers-cle        as character  initial ? 
    field tiers-cpt-cd     as character  initial ? 
    field tiers-sscoll-cle as character  initial ? 
    field tot-det          as logical    initial ? 
    field tva-enc-deb      as logical    initial ? 
    field type-ecr         as integer    initial ? 
    field type-remise      as logical    initial ? 
    field typechq-cle      as character  initial ? 
    field typeeff-cd       as integer    initial ? 
    field usrid            as character  initial ? 
    field valid            as logical    initial ? 
    field zone1            as character  initial ? 
    field zone2            as character  initial ? 
    field zone3            as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
