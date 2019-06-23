/*------------------------------------------------------------------------
File        : ifour.i
Purpose     : Fichier des fournisseurs
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfour
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr              as character  initial ?  extent 3
    field adrcom           as logical    initial ? 
    field adrregl          as logical    initial ? 
    field affact-cle       as character  initial ? 
    field ape              as character  initial ? 
    field bic              as character  initial ? 
    field caa              as decimal    initial ?  decimals 2
    field caa-EURO         as decimal    initial ?  decimals 2
    field caap             as decimal    initial ?  decimals 2
    field caap-EURO        as decimal    initial ?  decimals 2
    field categ-cd         as integer    initial ? 
    field clegroup         as character  initial ? 
    field cliref           as character  initial ? 
    field code-client      as character  initial ? 
    field coll-cle         as character  initial ? 
    field compensation     as integer    initial ? 
    field contact          as character  initial ? 
    field contrat          as character  initial ? 
    field cp               as character  initial ? 
    field cpt-cd           as character  initial ? 
    field dacrea           as date       initial ? 
    field dacreat          as date       initial ? 
    field damod            as date       initial ? 
    field damodif          as date       initial ? 
    field dev-cd           as character  initial ? 
    field effacable        as logical    initial ? 
    field email            as character  initial ? 
    field etab-cd          as integer    initial ? 
    field fam-cd           as integer    initial ? 
    field fax              as character  initial ? 
    field fg-actif         as logical    initial ? 
    field fg-compens       as logical    initial ? 
    field fg-dossier       as logical    initial ? 
    field fg-refer         as logical    initial ? 
    field fopol            as character  initial ? 
    field four-cle         as character  initial ? 
    field iban             as character  initial ? 
    field ihcrea           as integer    initial ? 
    field ihmod            as integer    initial ? 
    field libass-cd        as integer    initial ? 
    field liblang-cd       as integer    initial ? 
    field libpays-cd       as character  initial ? 
    field librais-cd       as integer    initial ? 
    field libtier-cd       as integer    initial ? 
    field livfac           as logical    initial ? 
    field livr-cd          as integer    initial ? 
    field lrefer           as character  initial ? 
    field menupro          as character  initial ? 
    field mini-cde         as decimal    initial ?  decimals 2
    field mtcapital        as decimal    initial ?  decimals 2
    field nbparts          as decimal    initial ?  decimals 2
    field noblc            as integer    initial ? 
    field nom              as character  initial ? 
    field NomPref          as character  initial ? 
    field NumCartProf      as character  initial ? 
    field NumRCS           as character  initial ? 
    field old-ape          as integer    initial ? 
    field port-cd          as integer    initial ? 
    field prof-cle         as character  initial ? 
    field refer-cd         as character  initial ? 
    field regl-cd          as integer    initial ? 
    field rel-cd           as integer    initial ? 
    field releve           as logical    initial ? 
    field remarq           as character  initial ? 
    field rib              as logical    initial ? 
    field siren            as character  initial ? 
    field siret            as character  initial ? 
    field soc-cd           as integer    initial ? 
    field solde            as decimal    initial ?  decimals 2
    field solde-EURO       as decimal    initial ?  decimals 2
    field ssfam-cd         as integer    initial ? 
    field tel              as character  initial ? 
    field telex            as character  initial ? 
    field tiers-declar     as character  initial ? 
    field tpmod            as character  initial ? 
    field transp           as logical    initial ? 
    field trt              as decimal    initial ?  decimals 2
    field trt-EURO         as decimal    initial ?  decimals 2
    field tva-enc-deb      as logical    initial ? 
    field tvacee-cle       as character  initial ? 
    field txescpt          as decimal    initial ?  decimals 2
    field txremex          as decimal    initial ?  decimals 2
    field type-four        as character  initial ? 
    field usrid            as character  initial ? 
    field usridmod         as character  initial ? 
    field ville            as character  initial ? 
    field VilleRCS         as character  initial ? 
    field web-datact       as date       initial ? 
    field web-datdesact    as date       initial ? 
    field web-datouverture as date       initial ? 
    field web-div          as character  initial ? 
    field web-fgactif      as logical    initial ? 
    field web-fgautorise   as logical    initial ? 
    field web-fgouvert     as logical    initial ? 
    field web-id           as character  initial ? 
    field web-mdp          as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
