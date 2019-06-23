/*------------------------------------------------------------------------
File        : enteteEcriture.i
Description : dataset pour les entête de factures
Author(s)   : kantena - 2017/05/02
Notes       :
derniere revue: 2018/07/28 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEnteteEcriture
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field lAcompte               as logical   initial ?            label 'acompte'
    field cCodeJournalAcompte    as character initial ?            label 'acpt-jou-cd'
    field cTypeAcompte           as character initial ?            label 'acpt-type'
    field iCodeAdresse           as integer   initial ?            label 'adr-cd'
    field iNumeroAffaire         as integer   initial ?            label 'affair-num'
    field cCodeBarre             as character initial ?            label 'barre-cd'
    field lBonAPayer             as logical   initial ?            label 'bonapaye'
    field cCodeEnregistrement    as character initial ?            label 'cdenr'
    field cRegroupement          as character initial ?            label 'coll-cle'
    field lConsolidation         as logical   initial ?            label 'consol'
    field dCours                 as decimal   initial ? decimals 8 label 'cours'
    field cCompteTiers           as character initial ?            label 'cpt-cd'
    field cLibelleTiers          as character initial ?            label 'cLibelleTiers'
    field daDateAffaire          as date                           label 'daaff'
    field daDateComptabilisation as date                           label 'dacompta'
    field daDateCreation         as date                           label 'dacrea'
    field daDateDossier          as date                           label 'dadoss'
    field daDateEcheance         as date                           label 'daech'
    field daDateEcriture         as date                           label 'daecr'
    field daDateEffacement       as date                           label 'daeff'
    field daDateLivraison        as date                           label 'dalivr'
    field daDateModification     as date                           label 'damod'
    field cCodeDevise            as character initial ?            label 'dev-cd'
    field iNumeroDossier         as integer   initial ?            label 'dossier-num'
    field iCodeEtablissement     as integer   initial ?            label 'etab-cd'
    field lEcritureLettree       as logical   initial ?            label 'lEcritureLettree'
    field lModification          as logical   initial ?            label 'fg-modif'
    field iIdentifiantFiche      as int64     initial ?            label 'id-fich'
    field iHeureCreation         as integer   initial ?            label 'ihcrea'
    field iHeureDossier          as integer   initial ?            label 'ihdoss'
    field iHeureModification     as integer   initial ?            label 'ihmod'
    field cCodeJournal           as character initial ?            label 'jou-cd'
    field cLibelleTravaux        as character initial ?            label 'lbtrvxctent'
    field cLibelle               as character initial ?            label 'lib'
    field dMontantTVA            as decimal   initial ? decimals 2 label 'dMontantTVA'
    field dMontantDevise         as decimal   initial ? decimals 2 label 'mtdev'
    field dMontantDeviseEURO     as decimal   initial ? decimals 2 label 'mtdev-EURO'
    field dMontantImput          as decimal   initial ? decimals 2 label 'mtimput'
    field dMontantImputEURO      as decimal   initial ? decimals 2 label 'mtimput-EURO'
    field dMontantReglement      as decimal   initial ? decimals 2 label 'mtregl'
    field dMontantReglementEURO  as decimal   initial ? decimals 2 label 'mtregl-EURO'
    field iNatureJournal         as integer   initial ?            label 'natjou-cd'
    field iNumeroChrono          as integer   initial ?            label 'nochrodis'
    field iNumeroPieceComptable  as integer   initial ?            label 'piece-compta'
    field iNumeroPieceInterne    as integer   initial ?            label 'piece-int'
    field iCodePeriode           as integer   initial ?            label 'prd-cd'
    field iNumeroPeriode         as integer   initial ?            label 'prd-num'
    field cReferenceFacture      as character initial ?            label 'ref-fac'
    field iCodeModeReglement     as integer   initial ?            label 'regl-cd'
    field cLibelleModeReglement  as character initial ?            label ''
    field cModeReglementJournal  as character initial ?            label 'regl-jou-cd' 
    field cModeReglementBanque   as integer   initial ?            label 'regl-mandat-cd'
    field cScenario              as character initial ?            label 'scen-cle'
    field lDefinitif             as logical   initial ?            label 'situ'
    field iCodeSociete           as integer   initial ?            label 'soc-cd'
    field cCollectifTiers        as character initial ?            label 'sscoll-cle'
    field cTypeMouvement         as character initial ?            label 'type-cle'
    field cUserModification      as character initial ?            label 'usridmod'

    field CRUD        as character
    field dtTimestamp as datetime
    field rRowid      as rowid
.
