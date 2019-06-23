/*-----------------------------------------------------------------------------
File        : baremeHonoraire.i
Purpose     :
Author(s)   : DM  -  2017/10/11
Notes       :
derniere revue: 2018/05/17 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttBaremeHonoraire
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeHonoraire           as character initial ? label "tphon"
    field cLibelleTypeHonoraire    as character initial ? label "LbLng"
    field iCodeHonoraire           as integer   initial ? label "cdHon"
    field cCodeNature              as character initial ? label "ntHon"
    field cLibelleNature           as character initial ? label "LbNtHon"
    field daDateDebutApplication   as date                label "dtdeb"
    field daDateFinApplication     as date                label "dtfin"
    field cCodeBaseCalcul          as character initial ? label "BsHon"
    field cLibelleBaseCalcul       as character initial ? label "LbBsHon"
    field dTauxMontant             as decimal   initial ? label "mtBar"
    field cCodeTva                 as character initial ? label "cdTva"
    field cLibelleTva              as character initial ? label "LbTva"
    field cCodePresentation        as character initial ? label "CdTot"
    field cLibellePresentation     as character initial ? label "PresCpt"
    field cLibelleHonoraire        as character initial ? label "lbhon"    // Le libellé est codifié pour les honoraires de type frais de gestion, sinon libellé en clair
    field cCodeFamille             as character initial ? label "fam-cle"
    field cLibelleFamille          as character initial ? label "LbFam"
    field cCodeSousFamille         as character initial ? label "sfam-cle"
    field cLibelleSousFamille      as character initial ? label "LbSsFam"
    field dPourcAffProp            as decimal   initial ? label "afPro"
    field cCodeArticle             as character initial ? label "art-cle"
    field cLibelleArticle          as character initial ? 
    field iCodeIndiceRevision      as integer   initial ? label "cdirv"
    field cLibelleIndiceRevision   as character initial ? label "LbCdirv"
    field cCodeDernierIndice       as character initial ?
    field cLibelleDernierIndice    as character initial ?
    field daDateRevision           as date                label "dtrev"
    field iNumeroHonoraire         as integer   initial ? label "nohon"
    field cCommentaire             as character initial ? label "lbcom"
    field dforfaitM2               as decimal   initial ? label "forfM2_s1"
    field dM2Occupe                as decimal   initial ? label "m2Occup_s2"
    field dM2Shon                  as decimal   initial ? label "m2Shon_s3"
    field dM2Vacant                as decimal   initial ? label "m2Vacant_s4"
    field cCodePeriodicite         as character initial ? label "pdHon"
    field cLibellePeriodicite      as character initial ? label "LbPdHon"
    field cCodeCategorieBail       as character initial ? label "catbai"
    field cLibelleCategorieBail    as character initial ? label "lbCat"
    field cCodeCle                 as character initial ? label "cdCle"
    field cLibelleCle              as character initial ?
    field cTypeTache               as character initial ? label "tptac"
    field lModificationPeriodicite as logical   initial ?
    field lNouvelleValeur          as logical   initial ?
    field lcontrole                as logical   initial ?
    field lFactureCabinet          as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
