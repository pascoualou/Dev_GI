/*------------------------------------------------------------------------
File        : facture.i
Description : dataset pour les factures
Author(s)   : kantena - 2017/05/02
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttFacture
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroFacture               as integer   initial ? label 'NoFac'
    field daDateFacture                as date                label 'DtFac'
    field dNumeroIdentifiantFacture    as decimal   initial ? label 'noidt-fac'
    field cTypeIdentifiantFacture      as character initial ? label 'tpidt-fac'
    field daDateComptable              as date                label 'DtCpt'
    field daDateEcheance               as date                label 'DtEch'
    field cReferenceFacture            as character initial ? label 'ref-fac'
    field iReferenceClient             as integer   initial ? label 'NoRef'
    field cReferenceFournisseur        as character initial ? label 'NoReg'
    field iNumeroAdresseFacturation    as integer   initial ? label 'AdFac'
    field iNumeroTerritorialite        as integer   initial ? label 'NoTer'
    field dMontantTva                  as decimal   initial ? label 'MtTva'
    field dMontantTtc                  as decimal   initial ? label 'MtTtc'
    field lFactureAvoir                as logical   initial ? label 'FgFac'
    field lFacturePayee                as logical   initial ? label 'FgPaye'
    field iNumeroPieceComptable        as integer   initial ? label 'NoPie'
    field cCodeJournal                 as character initial ? label 'CdJou'
    field cCommentaire                 as character initial ? label 'LbCom'
    field iNumeroMandat                as int64     initial ? label 'nocon'
    field cTypeMandat                  as character initial ? label 'tpcon'
    field cLibelleEcriture             as character initial ? label 'lbEcr'
    field iNumeroExercice              as integer   initial ? label 'noExe'
    field iNumeroPeriode               as integer   initial ? label 'noPer'
    field lMoisCloture                 as logical   initial ? label 'fgMoisClot'
    field iModeReglement               as integer   initial ? label 'mdReg'
    field dMontantPort                 as decimal   initial ? label 'mtPor'
    field iCodeTvaPort                 as integer   initial ? label 'cdTvP'
    field dMontantTvaPort              as decimal   initial ? label 'tvPor'
    field dMontantEscomptePort         as decimal   initial ? label 'esPor'
    field dMontantTvaEscomptePort      as decimal   initial ? label 'tvEsP'
    field dMontantEmballage            as decimal   initial ? label 'mtEmb'
    field iCodeTvaEmballage            as integer   initial ? label 'cdTvE'
    field dMontantTvaEmballage         as decimal   initial ? label 'tvEmb'
    field dMontantEscompteEmballage    as decimal   initial ? label 'esEmb'
    field dMontantTvaEscompteEmballage as decimal   initial ? label 'tvEsE'
    field dTauxRemise                  as decimal   initial ? label 'txRem'
    field dMontantRemise               as decimal   initial ? label 'mtRem'
    field dMontantTvaRemise            as decimal   initial ? label 'tvRem'
    field dTauxEscompte                as decimal   initial ? label 'txEsc'
    field dMontantEscompte             as decimal   initial ? label 'mtEsc'
    field dMontantTvaEscompte          as decimal   initial ? label 'tvEsc'
    field lEscompteReglement           as logical   initial ? label 'fgEsc'
    field lBonAPayer                   as logical   initial ? label 'fgBap'
    field iNumeroFournisseur           as integer   initial ? label 'noFou'
    field cLibelleFournisseur          as character initial ? label ''
    field iNumeroContratFournisseur    as int64     initial ? label 'noCttF'
    field cTypeContratFournisseur      as character initial ? label 'tpcttF'
    field cCollectifFournisseur        as character initial ? label 'sscoll-cle'
    field lComptabilisation            as logical   initial ? label 'fgCpt'
    field cDivers1                     as character initial ? label 'lbDiv1'
    field cDivers2                     as character initial ? label 'lbDiv2'
    field cDivers3                     as character initial ? label 'lbDiv3'
    field cTypeRoleSignalant           as character initial ? label 'tpPar'
    field iNumeroRoleSignalant         as integer   initial ? label 'noPar'
    field cCodeModeSignalement         as character initial ? label 'mdSig'
    field cEcheancier                  as character initial ? label 'Echeancier'
    field cUserModification            as character initial ? label 'cdmsy'

    field CRUD        as character
    field dtTimeStamp as datetime
    field rRowid      as rowid
.
