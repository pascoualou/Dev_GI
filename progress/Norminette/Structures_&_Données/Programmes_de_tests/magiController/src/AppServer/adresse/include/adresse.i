/*------------------------------------------------------------------------
File        : adresse.i
Purpose     : 
Author(s)   : KANTENA  2016/12/19
Notes       :
derniere revue: 2018/05/17 - phm: KO
        traiter les todo
        todo entre dtTimestampadres et dtTimestampladrs, n'y a t'il pas un dtTimestamp à choisir
DMI 24/05/2018 - Sera modifié avec la nouvelle gestion des adresses	
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAdresse
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroLien             as int64     initial ?  // ladrs.nolien
    field iNumeroFiche            as integer   initial ?  // GLfiche.nofiche
    field cTypeIdentifiant        as character initial ?  // ladrs.tpidt
    field iNumeroIdentifiant      as integer   initial ?  // ladrs.noidt
    field iTypeBranche            as integer   initial ?
    field cCodeTypeAdresse        as character initial ?  // ladrs.tpadr
    field cLibelleTypeAdresse     as character initial ?
    field cCodeFormat             as character initial ?  // ladrs.tpfrt
    field cLibelleFormat          as character initial ?
    field cIdentification         as character initial ?  // adres.cpad2  NPO new normes adresses
    field cNumeroVoie             as character initial ?  // ladrs.novoi
    field cCodeNumeroBis          as character initial ?  // ladrs.cdadr
    field cLibelleNumeroBis       as character initial ?
    field cLibelleNumeroBisCourt  as character initial ?
    field cCodeNatureVoie         as character initial ? label 'ntvoi'
    field cLibelleNatureVoie      as character initial ?
    field cLibelleNatureVoieCourt as character initial ?
    field cNomVoie                as character initial ? label 'lbvoi'
    field cComplementVoie         as character initial ? label 'cpvoi'
    field cCodePostal             as character initial ? label 'cdpos'
    field cBureauDistributeur     as character initial ? label 'lbbur'
    field cVille                  as character initial ? label 'lbvil'
    field cCodeINSEE              as character initial ? label 'cdins'
    field cCodePays               as character initial ? label 'cdpay'
    field cLibellePays            as character initial ?
    field cLibelle                as character initial ?
    field cJointure               as character initial ?

    field dtTimestampadres as datetime
    field dtTimestampladrs as datetime
    field CRUD             as character
    field rRowid           as rowid
/*gga todo a revoir mais pour la commercialisation si une meme adresse est utilise pour des roles fiches differents, cet index sera bloquant 
index idxAdresse is unique primary iNumeroLien /*iNumeroIdentifiant*/ 
gga*/ 
.
