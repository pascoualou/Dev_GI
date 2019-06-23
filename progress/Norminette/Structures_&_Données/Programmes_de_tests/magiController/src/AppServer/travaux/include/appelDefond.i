/*------------------------------------------------------------------------
File        : appelDefond.i
Purpose     : 
Author(s)   : Kantena  -  2016/11/09
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttEnteteAppelDeFond no-undo                                  /* Table dosEt */
    /** O,N,P **/
    /** O : Cette entête n'est constituée que d'appels manuels **/
    /** N : Cette entête n'est constituée que d'appels GI **/
    /** P : Cette entête est constituée d'abord d'appels manuels, puis d'appels GI **/
    field iNumeroIdentifiant        as integer   initial ? label 'noidt'
    field iNumeroOrdre              as integer   initial ? label 'NoOrd'
    field cCodeTypeAppel            as character initial ? label 'TpApp'
    field cLibelleTypeAppel         as character
    field cCodeCollectifFinancement as character initial ? label 'sscoll-cle' // coll financement
    field cCodeTypeAppelSur         as character initial ? label 'TpApp'      // Immeuble ou matricule
    field cLibelleAppelSur          as character
    field cCodeFournisseur          as character initial ? label 'noFou'
    field cLibelleFournisseur       as character
    field iNumeroIntervention       as integer   initial ? label 'NoInt'
    field cLibelleIntervention      as character
    field iNombreAppel              as integer   initial ? label 'NbApp'
    field dMontantAppel             as decimal   initial ? label 'MtApp'
    field dMontantEcart             as decimal   initial ?
    field iCodeTva                  as integer   initial ? label 'CdTva'
    field iNumeroPremierAppel       as integer   initial ?
    field dTauxTVA                  as decimal   initial ?
    field dMontantTva               as decimal   initial ? label 'MtTva'
    field lbcom                     as character initial ? label 'lbcom'
    field cRepriseAppel             as character
    field dMontantFondTravauxAlur   as decimal   initial ? label 'HwFilFTA'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    index idxNumeroIdentifiant is unique iNumeroIdentifiant
    index idxiNumeroOrdre is primary iNumeroOrdre
.

define temp-table ttAppelDeFond no-undo                                /* Table dosDt */
    field iNumeroIdentifiant as integer   initial ? label 'NoIdt'
    field iNumeroAppel       as integer   initial ? label 'NoApp'
    field cLibelleAppel      as character initial ? label 'LbApp'
    field dMontantAppel      as decimal   initial ? label 'MtApp'
    field lFlagEmis          as logical   initial ? label 'DosAp.FgEmi'
    field daDateAppel        as date                label 'dosAp.dtApp'
    field dMontantTotal      as decimal   initial ? label 'DosAp.MtTot'
    field cCodeTraitement    as character    /* O si traité GI, M si traité manuel , N si non traité */
    field cModeTraitement    as character initial ? label 'DosAp.ModeTrait'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    index indxAppelDeFond is unique primary iNumeroIdentifiant iNumeroAppel
.
/*--> Table des repartitions par clé (dosDt)*/
define temp-table ttAppelDeFondRepCle no-undo
    field iNumeroIdentifiant as integer   initial ? label 'noIdt'
    field iNumeroAppel       as integer   initial ? label 'noApp'
    field cCodeCle           as character initial ? label 'cdApp'
    field cLibelleAppel      as character initial ? label 'lbApp'  extent 10
    field dMontantAppel      as decimal   initial ? label 'mtApp'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    index indxAppelDeFondCle is unique primary iNumeroIdentifiant iNumeroAppel cCodeCle
.
/*--> Table des repartitions par matricule (dosDt) */
define temp-table ttAppelDeFondRepMat no-undo
    field iNumeroIdentifiant as integer   initial ? label 'NoIdt'
    field iNumeroAppel       as integer   initial ? label 'NoApp'
    field iNumeroCopro       as integer   initial ? label 'CdApp'
    field iNumeroLot         as integer   initial ? label 'CdApp' 
    field cNomCopro          as character
    field cLibelleAppel      as character initial ? label 'LbApp'  extent 10
    field dMontantAppel      as decimal   initial ? label 'MtApp'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    index indxAppelDeFondMat is unique primary iNumeroIdentifiant iNumeroAppel iNumeroCopro iNumeroLot
.
/*--> Table des repartitions par clé (saisie appel)*/
define temp-table ttRepartitionCle no-undo
    field cCodeCle    as character
    field dMontantCle as decimal
    field lAff        as logical
    index indxRepartitionCle is unique primary cCodeCle
.
/*--> Table des repartitions par copropriétaire (saisie appel)*/
define temp-table ttRepartitionCopro no-undo
    field iNumeroCopro  as integer
    field iNumeroLot    as integer
    field dMontantCopro as decimal
    field lAff          as logical
    index indxRepartitionCle is unique primary iNumeroCopro iNumeroLot
.
/*--> Table des repartitions par % de chaque échéance (saisie appel)*/
define temp-table ttRepartitionPourcentage no-undo
    field iNumeroEcheance      as character
    field dPourcentageEcheance as decimal
    index indxRepartitionPourcentage is unique primary iNumeroEcheance
.
/*--> Table info dossier specifique appel de fond */
define temp-table ttDossierAppelDeFond no-undo
    field dMontantTravaux as decimal
    field iNbrAppel       as integer
    field cPresAppelCod   as character
    field cPresAppelLib   as character
    field iNbrEchPrel     as integer
    field iBarHon         as integer
    field lPresAppel      as logical

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
. 
/*--> Table parametre mandat pour choix zone a saisir dans ecran appel de fond */
define temp-table ttInfoSaisieAppelDeFond no-undo
    field lSaisieFondAlur  as logical 
    field dMontantFondAlur as decimal
.
