/*------------------------------------------------------------------------
File        : icli.i
Purpose     : Informations relatives aux clients pour le module interface.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIcli
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field accept           as integer    initial ? 
    field adr              as character  initial ? 
    field adrautre         as logical    initial ? 
    field adrrel           as logical    initial ? 
    field affact-cle       as character  initial ? 
    field ape              as character  initial ? 
    field arecup-mp        as integer    initial ? 
    field bilchif          as logical    initial ? 
    field caa              as decimal    initial ?  decimals 2
    field caa-EURO         as decimal    initial ?  decimals 2
    field caap             as decimal    initial ?  decimals 2
    field caap-EURO        as decimal    initial ?  decimals 2
    field cde              as decimal    initial ?  decimals 2
    field cde-EURO         as decimal    initial ?  decimals 2
    field clegroup         as character  initial ? 
    field cli-cle          as character  initial ? 
    field cli-mere         as character  initial ? 
    field coll-cle         as character  initial ? 
    field comment          as character  initial ? 
    field compensation     as integer    initial ? 
    field consignation     as logical    initial ? 
    field contact          as character  initial ? 
    field courses-gl       as character  initial ? 
    field cp               as character  initial ? 
    field cpt-cd           as character  initial ? 
    field cptgroup         as character  initial ? 
    field dacrea           as date       initial ? 
    field dacreat          as date       initial ? 
    field dafac            as date       initial ? 
    field damod            as date       initial ? 
    field damodif          as date       initial ? 
    field depot-cd         as integer    initial ? 
    field depot-cons       as integer    initial ? 
    field dev-cd           as character  initial ? 
    field effacable        as logical    initial ? 
    field email            as character  initial ? 
    field encour           as decimal    initial ?  decimals 2
    field encour-EURO      as decimal    initial ?  decimals 2
    field etab-cd          as integer    initial ? 
    field exonere          as logical    initial ? 
    field facpart          as logical    initial ? 
    field fam-cd           as integer    initial ? 
    field fax              as character  initial ? 
    field fg-compens       as logical    initial ? 
    field four-cle         as character  initial ? 
    field frais-cd         as integer    initial ? 
    field franco           as logical    initial ? 
    field gesolde          as decimal    initial ?  decimals 2
    field gesolde-EURO     as decimal    initial ?  decimals 2
    field grille           as integer    initial ? 
    field ihcrea           as integer    initial ? 
    field ihmod            as integer    initial ? 
    field insee            as character  initial ? 
    field jour-facture     as integer    initial ? 
    field jour-releve      as integer    initial ? 
    field lfactcns         as decimal    initial ?  decimals 2
    field lfactcns-EURO    as decimal    initial ?  decimals 2
    field lfacture         as decimal    initial ?  decimals 2
    field lfacture-EURO    as decimal    initial ?  decimals 2
    field libass-cd        as integer    initial ? 
    field libcli-cd        as integer    initial ? 
    field liblang-cd       as integer    initial ? 
    field libpays-cd       as character  initial ? 
    field librais-cd       as integer    initial ? 
    field libsolv-cd       as integer    initial ? 
    field libstatut-cd     as integer    initial ? 
    field libtar-cd        as integer    initial ? 
    field libtier-cd       as integer    initial ? 
    field livfac           as logical    initial ? 
    field livpart          as logical    initial ? 
    field livpart1         as integer    initial ? 
    field livr-cd          as integer    initial ? 
    field nbbled           as integer    initial ? 
    field nbcourses-g      as integer    initial ? 
    field nbfaced          as integer    initial ? 
    field nbimpaye         as integer    initial ? 
    field nbliv            as integer    initial ? 
    field nbrel            as integer    initial ? 
    field nom              as character  initial ? 
    field old-ape          as integer    initial ? 
    field period           as character  initial ? 
    field port-cd          as integer    initial ? 
    field raz-fac-num      as logical    initial ? 
    field recup-mp         as logical    initial ? 
    field regl-cd          as integer    initial ? 
    field rel-cd           as integer    initial ? 
    field releve           as logical    initial ? 
    field remquan          as logical    initial ? 
    field rep1-cd          as character  initial ? 
    field rep2-cd          as character  initial ? 
    field risque           as decimal    initial ?  decimals 2
    field risque-EURO      as decimal    initial ?  decimals 2
    field secven-cd        as integer    initial ? 
    field serv-cd          as integer    initial ? 
    field sfac-encour      as decimal    initial ?  decimals 2
    field sfac-encour-EURO as decimal    initial ?  decimals 2
    field siren            as character  initial ? 
    field siret            as character  initial ? 
    field soc-cd           as integer    initial ? 
    field solde            as decimal    initial ?  decimals 2
    field solde-EURO       as decimal    initial ?  decimals 2
    field ssfam-cd         as integer    initial ? 
    field tel              as character  initial ? 
    field tel-abbrege      as character  initial ? 
    field telex            as character  initial ? 
    field tiers-declar     as character  initial ? 
    field tpmod            as character  initial ? 
    field trans-cle        as character  initial ? 
    field transporteur     as character  initial ? 
    field trt              as decimal    initial ?  decimals 2
    field trt-EURO         as decimal    initial ?  decimals 2
    field tvacee-cle       as character  initial ? 
    field txcomm           as decimal    initial ?  decimals 2
    field txcomm2          as decimal    initial ?  decimals 2
    field txescpt          as decimal    initial ?  decimals 2
    field txremex          as decimal    initial ?  decimals 2
    field type-succursale  as character  initial ? 
    field typfac-cd        as integer    initial ? 
    field usrid            as character  initial ? 
    field usridmod         as character  initial ? 
    field ville            as character  initial ? 
    field zone-liv         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
