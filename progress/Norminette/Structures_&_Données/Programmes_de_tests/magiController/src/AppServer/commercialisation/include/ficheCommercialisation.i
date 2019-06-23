/*------------------------------------------------------------------------
File        : ficheCommercialisation.i
Purpose     : Fiche de location
Author(s)   : KANTENA - 2016/08/01
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttFicheCommercialisation
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroFiche         as integer   initial ?
    field iTypeFiche           as integer   initial ? label 'typfiche'
    field cTypeContrat         as character initial ? label 'tpcon'
    field iNumeroContrat       as int64     initial ? label 'nocon'
    field iNumeroUL            as integer   initial ? label 'noapp'               // Numéro de l'unité de location
    field cCodeNatureUL        as character initial ? label 'cdcmp'               // Nature de l'unité de location
    field cLibelleNatureUL     as character initial ?
    field iNumeroWorkflow      as integer   initial ? label 'noworkflow'
    field cLibelleWorkflow     as character initial ? label 'libworkflow'
    field iNumeroModeCreation  as integer   initial ? label 'nomodecreation'
    field iNumeroZoneAlur      as integer   initial ? label 'nozonealur'
    field cTitreCommercial     as character initial ? label 'titre_comm'
    field cAnnonceCommerciale  as character initial ? label 'texte_comm'
    field cDescriptifGestion   as character initial ? label 'texte_gestion'
    field iNombrePieces        as integer   initial ? label 'nbpiece'
    field dSurfaceHabitable    as decimal   initial ? label 'surfhab'
    field iNombrePhotos        as integer   initial ? label 'nbphoto'
    field dLoyerPreconise      as decimal   initial ? label 'loy_preco'
    field cTexteLoyerPreconise as character initial ? label 'texte_loy_preco'
    field lGarantieVacanceLoc  as logical   initial ? label 'fgvac_locative'
    field lGarantieLoyerImpaye as logical   initial ? label 'fgloy_impaye'
    field cTypeContratLoc      as character initial ? label 'tpconloc'            // Type du contrat de location : bail / prébail
    field iNumeroContratLoc    as integer   initial ? label 'noconloc'            // Numéro du contrat de location
    field cCodePostal          as character initial ? label 'codepostal'
    field cVille               as character initial ? label 'ville'
    field cAdresse             as character initial ? label 'adresse'
    field cLibelleAdresse      as character initial ? label 'adressecomplete'
    field cNomMandant          as character initial ? label 'mandant'
    field cNomCompletMandant   as character initial ? label 'nomcompletmandat'
    field cNomCommercial       as character initial ? label 'commercial'
    field cNomServiceGestion   as character initial ? label 'servicegestion'
    field daDateDispo          as date                label 'datedispo'
    field iNombreJoursVacance  as integer   initial ? label 'joursvacance'
    field iNumeroImmeuble      as integer   initial ? label 'immeuble'
    field dMontantLoyerCC      as decimal   initial ? label 'montant_loyer charges comprise'
    field cSysUser             as character 
    field dtDateCreation       as datetime

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
