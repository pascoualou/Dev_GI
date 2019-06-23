/*------------------------------------------------------------------------
File        : cpaieeap.i
Purpose     : Fichier Preparation des Paiements Fournisseurs (E.A.P.)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCpaieeap
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr-cd           as integer    initial ? 
    field bonapaye         as logical    initial ? 
    field bonapayelib      as character  initial ? 
    field bqjou-cd         as character  initial ? 
    field coll-cle         as character  initial ? 
    field cours            as decimal    initial ?  decimals 8
    field cpt-cd           as character  initial ? 
    field cpt1-cd          as character  initial ? 
    field cpt2-cd          as character  initial ? 
    field cpt3-cd          as character  initial ? 
    field cpttva-cd        as character  initial ? 
    field dacompta         as date       initial ? 
    field daech            as date       initial ? 
    field datecr           as date       initial ? 
    field dev-cd           as character  initial ? 
    field devetr-cd        as character  initial ? 
    field dossier-num      as integer    initial ? 
    field eapjou-cd        as character  initial ? 
    field edi              as logical    initial ? 
    field edidev-cd        as character  initial ? 
    field etab-cd          as integer    initial ? 
    field frais            as logical    initial ? 
    field frais-cd         as character  initial ? 
    field job-num          as integer    initial ? 
    field jou-cd           as character  initial ? 
    field lettre           as character  initial ? 
    field lib              as character  initial ? 
    field libpaie-cd       as integer    initial ? 
    field libtier-cd       as integer    initial ? 
    field lig              as integer    initial ? 
    field lig-tot          as integer    initial ? 
    field mandat-cd        as integer    initial ? 
    field modif            as logical    initial ? 
    field mt               as decimal    initial ?  decimals 2
    field mt-EURO          as decimal    initial ?  decimals 2
    field mtaregl          as decimal    initial ?  decimals 2
    field mtaregl-EURO     as decimal    initial ?  decimals 2
    field mtdev            as decimal    initial ?  decimals 2
    field mtfrais          as decimal    initial ?  decimals 2
    field mtfrais-EURO     as decimal    initial ?  decimals 2
    field mtfrais1         as decimal    initial ?  decimals 2
    field mtfrais1-EURO    as decimal    initial ?  decimals 2
    field mtfrais2         as decimal    initial ?  decimals 2
    field mtfrais2-EURO    as decimal    initial ?  decimals 2
    field mtfrais3         as decimal    initial ?  decimals 2
    field mtfrais3-EURO    as decimal    initial ?  decimals 2
    field mtregl           as decimal    initial ?  decimals 2
    field mtregl-EURO      as decimal    initial ?  decimals 2
    field mttva            as decimal    initial ?  decimals 2
    field mttva-EURO       as decimal    initial ?  decimals 2
    field num-int          as integer    initial ? 
    field piece-compta     as integer    initial ? 
    field piece-int        as integer    initial ? 
    field pointe           as logical    initial ? 
    field prd-cd           as integer    initial ? 
    field prd-num          as integer    initial ? 
    field ref-num          as character  initial ? 
    field regl-cd          as integer    initial ? 
    field sens             as logical    initial ? 
    field soc-cd           as integer    initial ? 
    field sscoll-cle       as character  initial ? 
    field tiers-cle        as character  initial ? 
    field tiers-cpt-cd     as character  initial ? 
    field tiers-sscoll-cle as character  initial ? 
    field type-cle         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
