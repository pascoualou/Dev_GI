/*------------------------------------------------------------------------
File        : releveDeCompteur.i
Purpose     : Tableau du relevé des compteurs (eau, gaz, thermies...)
Author(s)   : SPo  -  03/22/2018
Notes       : table erlet complète + information no période, flag modifiable selon encours/histo
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttReleveDeCompteur
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat                     as character initial ? label 'tpcon'
    field iNumeroContrat                   as int64     initial ? label 'nocon'
    field cTypeCompteur                    as character initial ? label 'tpcpt'
    field iNumeroReleve                    as integer   initial ? label 'norlv'
    field iNumeroIdentifiant               as integer   initial ? label 'norli'
    field iCodageContrat                   as int64     initial ? label 'noimm'
    field iNumeroImmeuble                  as integer   initial ?
    field cCodeBatiment                    as character initial ? label 'cdbat'
    field daDateReleve                     as date                label 'dtrlv'
    field daDateReception                  as date                label 'dtrec'
    field cModeSaisie                      as character initial ? label 'mdsai'
    field cCodeUnite                       as character initial ? label 'cduni'
    field iCodeRubriqueAna                 as integer   initial ?
    field iCodeSousRubriqueAna             as integer   initial ?
    field iCodeFiscalite                   as integer   initial ?
    field cCodeAnalytique                  as character initial ? label 'cdana'                // concaténation de iCodeRubriqueAna + iCodeSousRubriqueAna + iCodeFiscalite
    field cCodeTVAFluide                   as character initial ? label 'cdtva'
    field dTauxTVAFluide                   as decimal   initial ? label 'txtva' decimals 3
    field dPrixFluideTTC                   as decimal   initial ? label 'pxuni' decimals 6
    field cCleRecuperationFluide           as character initial ? label 'clrec'
    field cCleRepartitionFluide            as character initial ? label 'clrep'
    field dMontantTTC                      as decimal   initial ? label 'totrl'
    field dMontantTVA                      as decimal   initial ? label 'tvarl'
    field dConsommation                    as decimal   initial ? label 'totco'
    field dMontantRecuperationTTC          as decimal   initial ? label 'totrc'
    field dMontantRecuperationTVA          as decimal   initial ? label 'tvarc'
    field iCodeRubriqueAnaRecuperation     as integer   initial ?
    field iCodeSousRubriqueAnaRecuperation as integer   initial ?
    field iCodeFiscaliteRecuperation       as integer   initial ?
    field cCodeAnalytiqueRecuperation      as character initial ? label 'anarc'               // concaténation de iCodeRubriqueAnaRecuperation + iCodeSousRubriqueAnaRecuperation + iCodeFiscaliteRecuperation    
    field cLibelleRecuperation             as character initial ? label 'librc'
    field daDateRelevePrecedent            as date                label 'ancdt'
    field dPrixEauFroideRechaufTTC         as decimal   initial ? label 'pxuer' decimals 3    // pour Eau chaude uniquement
    field cCodeTVAEauFroideRechauf         as character initial ? label 'cdter'               // pour Eau chaude uniquemen
    field dTauxTVAEauFroideRechauf         as decimal   initial ? label 'txter' decimals 3    // pour Eau chaude uniquement
    field cCleRecuperation2                as character initial ? label 'recer'               // pour Eau chaude et thermies 
    field dMontantRecup2TTC                as decimal   initial ? label 'toter'               // pour Eau chaude et thermies 
    field dMontantRecup2TVA                as decimal   initial ? label 'tvaer'               // pour Eau chaude et thermies 
    field iCodeRubriqueAnaRecup2           as integer   initial ?
    field iCodeSousRubriqueAnaRecup2       as integer   initial ?
    field iCodeFiscaliteRecup2             as integer   initial ?
    field cCodeAnalytiqueRecup2            as character initial ? label 'anaer'      
    field cLibelleRecup2                   as character initial ? label 'liber'
    field cCompteurGeneral                 as character initial ? label 'lbdiv2'
    field cPointLivraison                  as character initial ? label 'lbdiv3'
    field lReleveToutBatiment              as logical   initial ? label 'fgrlvimm'
    field iNumeroIdentifiantReleveCopro    as integer   initial ?               // Si relevé gérance créé à partir d'un relevé de copropriété
    field dPouvoirCalorifique              as decimal   initial ? decimals 3   // pour Gaz de france uniquement    
    field iNumeroExercice                  as integer   initial ?
    field iNumeroPeriode                   as integer   initial ?
    field daDebutPeriode                   as date
    field daFinPeriode                     as date
    field cCodeTraitement                  as character initial ?
    field cLibelleCodeTraitement           as character initial ?
    field lModifiable                      as logical   initial ?
    field cRefDocumentFactureUO            as character initial ?
    field dQuantiteFactureUO               as decimal   initial ?
    field dMontantFactureUO                as decimal   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttLigneReleveDeCompteur no-undo
    field cTypeContrat          as character initial ? 
    field iNumeroContrat        as int64     initial ? 
    field cTypeCompteur         as character initial ? 
    field iNumeroReleve         as integer   initial ? label 'norlv'
    field iNumeroIdentifiant    as integer   initial ? label 'norli'
    field iNumeroImmeuble       as integer   initial ?
    field iNumeroLot            as integer   initial ? label 'nolot'
    field cLibelleNatureLot     as character initial ? label 'ntlot'
    field cNumeroCompteur       as character initial ? label 'nocpt'
    field lProprietaireOccupant as logical   initial ?                  // UL 997
    field lProprietaireVacant   as logical   initial ?                  // Bail spécial vacant propriétaire (rang 00)
    field iNumeroLocataire      as int64     initial ? label 'nocop'
    field cNomLocataire         as character initial ? label 'nmcop'
    field lEstimation           as logical   initial ? label 'fgest'
    field dMontantTTC           as decimal   initial ? label 'mtlig'
    field dMontantTVA           as decimal   initial ? label 'dttva'
    field dAncienIndex          as decimal   initial ? label 'ancix'
    field dNouvelIndex          as decimal   initial ? label 'newix'
    field dConsommation         as decimal   initial ? label 'conso'
    field dAncienneConso        as decimal   initial ? label 'ancco'
    field cLibelleConso         as character initial ? label 'lbdiv'
    field lErreurLigne          as logical   initial ?
    field cLibelleErreur        as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.

