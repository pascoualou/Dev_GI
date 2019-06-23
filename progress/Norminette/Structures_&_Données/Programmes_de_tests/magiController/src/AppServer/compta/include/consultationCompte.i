/*------------------------------------------------------------------------
File        : consultationCompte.i
Description :
Author(s)   : LGI/  -  2017/01/13
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttLigneEcriture no-undo
    field cTypeLigne            as character initial ? /* Type de Ligne: "M" = mouvements // "T" = Total Tréso // "D" = détail */
    field cLienDetail           as character initial ? /* Lien avec un Détail       */
    field cLienVentilation      as character initial ? /* Lien avec une Ventilation */
    field cCollectif            as character initial ? label 'sscoll-cle'
    field cTypeMouvement        as character initial ? label 'type-cle'
    field dtDateDocument        as date                label 'datecr'
    field cDocument             as character initial ? label 'ref-num'
    field cLettre               as character initial ? label 'lettre'
    field dtDateEcheance        as date                label 'daech'
    field dtDateComptable       as date                label 'dacompta'
    field cCodeJournal          as character initial ? label 'jou-cd'
    field dMontantCredit        as decimal   initial ? label 'mtcre'
    field dMontantDebit         as decimal   initial ? label 'mtdeb'
    field cCodeIndicateur       as character initial ? label 'sc1'
    field cLibelle              as character initial ? label 'lib'
    field cLibelle2             as character initial ? label 'lib2'
    field iNumeroPieceComptable as integer   initial ? label 'piece-compta0'
    field lExtraComptable       as logical   initial ? label 'extra-cpta'
    field rRowid                as rowid
    field cNumeroDossierTravaux as character initial ? label 'NoDos'
    field cNumeroCRG            as character initial ? label 'NoCRG'
    field cNumeroDocumentLong   as character initial ? label 'ref-fac'
    field lLettrageTotal        as logical   initial ? label 'flag-lettre'    serialize-hidden
    field iMandatEntete         as integer   initial ? label 'mandat-cd'      serialize-hidden
    field iExerciceEntete       as integer   initial ? label 'mandat-prd-cd'  serialize-hidden
    field iPeriodeEntete        as integer   initial ? label 'mandat-prd-num' serialize-hidden
    field iExerciceLigne        as integer   initial ? label 'prd-cd'         serialize-hidden
    field iPeriodeLigne         as integer   initial ? label 'prd-num'        serialize-hidden
    field iPieceInterne         as integer   initial ? label 'piece-int'      serialize-hidden
    field iLigne                as integer   initial ? label 'lig'            serialize-hidden
    field iSituation            as logical   initial ? label 'situ0'          serialize-hidden
    field iMouvement            as integer   initial ? label 'mvt'            serialize-hidden
    field lCumul                as logical   initial ? label 'fg-cum'         serialize-hidden
    field cDocumentCumul        as character initial ? label 'ref-num-cum'    serialize-hidden
    field cLettreCumul          as character initial ? label 'lettre-cum'     serialize-hidden
    field cCollectifCumul       as character initial ? label 'sscoll-cle-cum' serialize-hidden
    field cSauvegardeLibelle    as character initial ? label 'lib1-sav'       serialize-hidden
    field dMontantTotal         as decimal   initial ? label 'mt-tot'         serialize-hidden
    field cDossierTravauxCumul  as character initial ? label 'NoDos-cum'      serialize-hidden
    field cDocumentLongCumul    as character initial ? label 'ref-fac-cum'    serialize-hidden
    field rRegroupement         as rowid                                      serialize-hidden
.
define temp-table ttLigneEcritureDetail no-undo
    field cTypeLigne            as character initial ? /* Type de Ligne: "D" = détail */
    field cLienDetail           as character initial ? /* Lien avec un Détail         */
    field cLienVentilation      as character initial ? /* Lien avec une Ventilation   */
    /* Champs Affichés */
    field cCollectif            as character initial ? label 'sscoll-cle'
    field cTypeMouvement        as character initial ? label 'type-cle'
    field dtDateDocument        as date                label 'datecr'
    field cDocument             as character initial ? label 'ref-num'
    field cLettre               as character initial ? label 'lettre'
    field dtDateEcheance        as date                label 'daech'
    field dtDateComptable       as date                label 'dacompta'
    field cCodeJournal          as character initial ? label 'jou-cd'
    field dMontantCredit        as decimal   initial ? label 'mtcre'
    field dMontantDebit         as decimal   initial ? label 'mtdeb'
    field cCodeIndicateur       as character initial ? label 'sc1'
    field cLibelle              as character initial ? label 'lib'
    field cLibelle2             as character initial ? label 'lib2'
    field iNumeroPieceComptable as integer   initial ? label 'piece-compta0'
    field lExtraComptable       as logical   initial ? label 'extra-cpta'
    field cNumeroDossierTravaux as character initial ? label 'NoDos'
    field cNumeroCRG            as character initial ? label 'NoCRG'
    field cNumeroDocumentLong   as character initial ? label 'ref-fac'
    field rRowid                as rowid
.
define temp-table ttVentilationEcriture no-undo
    field cTypeVentilation    as character initial ?
    field cLienVentilation    as character initial ?
    field cCodeVentilation    as character initial ?
    field dMontantDebit       as decimal   initial ?
    field dMontantCredit      as decimal   initial ?
    field dMontantHT          as decimal   initial ?
    field dMontantTVA         as decimal   initial ?
    field dMontantTTC         as decimal   initial ?
    field cLibelleAnalytique  as character initial ?
    field cLibelleRubrique    as character initial ?
.
{&_proparse_ prolint-nowarn(ttnoindex)}
define temp-table ttVentilationDetail no-undo like ttVentilationEcriture
.
define temp-table ttSoldeAnterieur no-undo
    field sscoll-cle as character initial ?
    field deb-ant    as decimal   initial ?
    field cre-ant    as decimal   initial ?
    field solde-ant  as decimal   initial ?
.
