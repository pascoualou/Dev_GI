/*------------------------------------------------------------------------
File        : honoraire.i
Purpose     :
Author(s)   : DM  -  2017/10/11
Notes       :
derneire revue: 2018/05/16 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttTranche no-undo
    field dMinimum         as decimal   initial ? label "vlmin"
    field dMaximum         as decimal   initial ? label "vlmax"
    field dMontant         as decimal   initial ? label "Mttrc"
    field cTypeHonoraire   as character initial ? label "tphon"
    field iNumeroHonoraire as integer   initial ? label "nohon"
    field CRUD             as character initial ?
.
define temp-table ttArticle no-undo
    field cCodeArticle     as character initial ? label "art-cle"
    field cLibelleArticle  as character initial ? label "desig1"
    field cCodeFamille     as character initial ? label "fam-cle"
    field cCodeSousFamille as character initial ? label "sfam-cle"
.
define temp-table ttFamilleArticle no-undo
    field cCodeFamille     as character initial ? label "fam-cle"
    field cLibelleFamille  as character initial ? label "lib"
.
define temp-table ttSousFamilleArticle no-undo
    field cCodeFamille        as character initial ? label "fam-cle"
    field cCodeSousFamille    as character initial ? label "sfam-cle"
    field cLibelleSousFamille as character initial ? label "lib"
.
define temp-table ttChampsSaisissable no-undo
    field lSaisieLibelleTypeHonoraire  as logical   initial ?
    field lSaisieLibelleNature         as logical   initial ?
    field lSaisieDateDebutApplication  as logical   initial ?
    field lSaisieLibelleBaseCalcul     as logical   initial ?
    field lSaisieTauxMontant           as logical   initial ?
    field lSaisieLibelleTva            as logical   initial ?
    field lSaisieLibellePresentation   as logical   initial ?
    field lSaisieLibelleFamille        as logical   initial ?
    field lSaisieLibelleSousFamille    as logical   initial ?
    field lSaisiePourcAffProp          as logical   initial ?
    field lSaisieCodeArticle           as logical   initial ?
    field lSaisieLibelleIndiceRevision as logical   initial ?
    field lSaisieLibelleDernierIndice  as logical   initial ?
    field lSaisieDateRevision          as logical   initial ?
    field lSaisieforfaitM2             as logical   initial ?
    field lSaisieM2Occupe              as logical   initial ?
    field lSaisieM2Shon                as logical   initial ?
    field lSaisieM2Vacant              as logical   initial ?
    field lSaisieCodeHonoraire         as logical   initial ?
    field lSaisieLibelleCategorieBail  as logical   initial ?
    field lSaisieLibellePeriodicite    as logical   initial ?
    field lSaisieLibelleCle            as logical   initial ? 
.
define temp-table ttHonoraireUL no-undo
    field cTypeTache             as character initial ? label "tptac"
    field cTypeHonoraire         as character initial ? label "tphon"
    field iCodeHonoraire         as integer   initial ? label "cdhon"
    field cCodeCategorieBail     as character initial ? label "catbai"
    field iNumeroUL              as integer   initial ? label "noapp"
    field cLibelleNatureLocation as character initial ? // pas de label             
    field lSelection             as logical   initial ? // pas de label
.
