/*------------------------------------------------------------------------
File        : mandatPrelevementSepa.i
Purpose     : Mandat de prélèvement d'un role pour un contrat (RUM)
              et suivi de l'utilisation de ce mandat 
              tables : mandatsepa et suimandatsepa
Author(s)   : SPo - 2018/06/11
Notes       : pour locataire, colocataires, candidat locataire, copropriétaire...
derniere revue: 2018/06/25 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMandatPrelSepa
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNoMandatSepa            as int64     initial ? label "nomprelsepa"
    field cTypeMandatSepa          as character initial ? label "tpmandat"
    field iNoMandatbis             as int64     initial ? label "nomandat"
    field cNatureMandatSepa        as character initial ? label "ntcon"
    field iMandatMaitre            as integer   initial ? label "nomdt"
    field cTypeContrat             as character initial ? label "tpcon"
    field iNumeroContrat           as int64     initial ? label "nocon" 
    field cTypeRole                as character initial ? label "tprol" 
    field iNumeroRole              as int64     initial ? label "norol"
    field cNomRole                 as character initial ? label "lbnom"
    field cNomCompletRole          as character initial ? label "lnom2"
    field iOrdre                   as integer   initial ? label "noord"
    field cRUM                     as character initial ? label "coderum"
    field cIBAN                    as character initial ? label "iban"
    field cBIC                     as character initial ? label "bicod"
    field cDomiciliation           as character initial ? label "domicil"
    field lRIBAttenteValidation    as logical   initial ?
    field ldernierRUM              as logical   initial ?
    field ccodeOrigineRUM          as character initial ? label "cdori"
    field cLibelleOrigineRUM       as character initial ?
    field daSignatureRUM           as date                label "dtsig"
    field ccodeSequenceRUM         as character initial ? label "cdstatut"
    field cLibelleSequenceRUM      as character initial ?
    field daDerniereUtilisationRUM as date                label "dtutilisation"
    field lRUMUtilise              as logical   initial ?                       // Flag Mandat SEPA déjà utilisé pour un prélèvement    
    field daValideRUM              as date                label "dtvalide"
    field daResiliationRUM         as date                label "dtresil"
    field daCreation               as date
    field cUtilisateurCreation     as character initial ?
    field lRUMValide               as logical   initial ? label "fgvalide"
    field cCodeErreurNonValide     as character initial ?
    field cLibelleErreurNonValide  as character initial ?
    field lCreerAction             as logical   initial ?                       // pour gérer la création d'une lignes de suivi action post-création/modif
    field cInfoSuiviAvantModif     as character initial ?                       // "RUM &1 / &2 / &3"  (&2 = info date signature, &3 = info date résiliation)
    field cSvgCRUD                 as character initial ?
    field dtTimestamp              as datetime
    field CRUD                     as character
    field rRowid                   as rowid
.
&if defined(nomTableTache)  = 0 &then &scoped-define nomTableTache ttSuiviMandatPrelSepa
&endif
&if defined(serialNameTache) = 0 &then &scoped-define serialNameTache {&nomTableTache}
&endif
define temp-table {&nomTableTache} no-undo serialize-name '{&serialNameTache}'
    field cTypeContrat        as character initial ?
    field iNumeroContrat      as int64     initial ?
    field cTypeRole           as character initial ?
    field iNumeroRole         as int64     initial ?
    field iNoMandatSepa       as int64     initial ? label "nomprelsepa"
    field iNumeroLigne        as int64     initial ? label 'nolig'
    field cTypeLigne          as character initial ? label "typelig"
    field cRUM                as character initial ? label "coderum"
    field daAction            as date
    field cIBAN               as character initial ? label "iban"
    field cDomiciliation      as character initial ? label "domicil"
    field daPrelevement       as date                label "daechprl"
    field ccodeSequenceRUM    as character initial ? label "cdstatut"
    field cLibelleSequenceRUM as character initial ?
    field dMontantPreleve     as decimal   initial ? decimals 2 label "mtprl"
    field cLibelle            as character initial ? label "lib-compta"
    field cUtilisateurAction  as character initial ?
    field daSignatureRUM      as date                label "dtsig"
    field daResiliationRUM    as date                label "dtresil"
    field dtTimestamp         as datetime
    field CRUD                as character
    field rRowid              as rowid
.
