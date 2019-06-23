/*------------------------------------------------------------------------
File        : ascenseur.i
Description : 
Author(s)   : kantena  -  2017/06/05
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttAscenseur no-undo
    field iNumeroTache       as int64     initial ? label 'noita'
    field iChronoTache       as integer   initial ? label 'notac'
    field iNumeroImmeuble    as integer   initial ?
    field cCodeAscenseur     as character initial ? label 'ntges'
    field daDateDebut        as date                label 'dtdeb'
    field cCodeFournisseur   as character initial ? label 'tpfin'
    field cNomFournisseur    as character initial ?
    field cNumeroSerie       as character initial ? label 'ntges'
    field cCodeBatiment      as character initial ? label 'tpges'
    field iNombreAscenseur   as integer   initial ?

    field dtTimestamp as datetime 
    field CRUD        as character 
    field rRowid      as rowid
.
define temp-table ttControleTechnique no-undo
    field iNumeroTache           as int64     initial ? label 'noita' 
    field iChronoTache           as integer   initial ? label 'notac' 
    field iNumeroLien            as integer   initial ?
    field cCodeFournisseur       as character initial ? label 'tpfin' 
    field cNomFournisseur        as character initial ?
    field cNomControlleur        as character initial ?
    field cCodeResultat          as character initial ? label 'tpges' 
    field cLibelleResultat       as character initial ?
    field cVisiteCodeResultat    as character initial ? label 'ntreg' 
    field cVisiteLibelleResultat as character initial ?
    field lTravauxAEffectuer     as logical   initial ? label 'pdges' format "00001/"
    field lTravauxEffectues      as logical   initial ? label 'cdreg' format "00001/" 
    field daDateFinTravaux       as date                label 'dtfin' 
    field daDatePrevue           as date                label 'dtree' 
    field daDateControle         as date                label 'dtdeb' 
    field daDateProchainControle as date                label 'utreg' 
    field daDateEffective        as date                label 'dtreg' 
    field cCommentaire           as character initial ? label 'lbdiv' 

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
