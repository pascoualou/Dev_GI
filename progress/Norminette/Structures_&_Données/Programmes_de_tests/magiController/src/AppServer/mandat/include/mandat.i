/*------------------------------------------------------------------------
File        : mandat.i
Purpose     : 
Author(s)   : KANTENA - 2016/08/05
Notes       :
Derniere revue: 2018/04/10 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMandat 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeTypeContrat              as character initial ? label "tpcon"
    field iNumeroContrat                as int64     initial ? label "nocon"
    field iNumeroDocument               as integer   initial ? label "nodoc"
    field cLibelleTypeContrat           as character initial ?
    field cCodeNatureContrat            as character initial ? label "ntcon"
    field cLibelleNatureContrat         as character initial ?
    field cCodeDevise                   as character initial ? label "cddev"
    field cLibelleCodeDevise            as character initial ?
    field cCodeStatut                   as character initial ? label "cdstatut"
    field cLibelleCodeStatut            as character initial ?
    field daDateDebut                   as date                label "dtdeb"       //effet ou renouvele le
    field daDateFin                     as date                label "dtfin"       //expire le
    field daDateInitiale                as date                label "dtini"       //premier contrat le
    field daDateLimite                  as date                label "dtmax"       //date fin de contrat
    field daSignature                   as date                label "dtsig"
    field cLieuSignature                as character initial ? label "lisig"
    field daDateValidation              as date                label "dtvaldef"
    field iNbRenouvellementMax          as integer   initial ? label "nbrenmax"
    field cNumeroReelRegistre           as character initial ? label "noree"
    field cCodeTypeRenouvellement       as character initial ? label "tpren"
    field lTaciteReconduction           as logical   initial ?
    field iDuree                        as integer   initial ? label "nbdur"
    field cUniteDuree                   as character initial ? label "cddur"
    field cLibelleUniteDuree            as character initial ? 
    field iDelaiResiliation             as integer   initial ? label "nbres"
    field cUniteDelaiResiliation        as character initial ? label "utres"
    field cLibelleUniteDelaiResiliation as character initial ? 
    field cDureeMax                     as character initial ? label "fgdurmax"
    field cLibelleDureeMax              as character initial ? 
    field iDureeMax                     as integer   initial ? label "nbannmax"  
    field cUniteDureeMax                as character initial ? label "cddurmax"  
    field cLibelleUniteDureeMax         as character initial ? 
    field cTypeActe                     as character initial ? label "tpact"
    field cLibelleTypeActe              as character initial ? 
    field cOrigineClient                as character initial ? label "cdori"
    field cLibelleOrigineClient         as character initial ? 
    field iCodeEsi                      as integer   initial ? label "pcpte"
    field lSaisieCodeEsi                as logical   initial no
    field iNbRenouvellement             as integer   initial ? label "noren"
    field lResiliation                  as logical   initial ?
    field daResiliation                 as date                label "dtree"       // resiliation le             
    field cMotifResiliation             as character initial ? label "tpfin"
    field cLibelleMotifResiliation      as character initial ?
    field daOdFinMandat                 as date                                    // OD fin mandat le
    field daArchivage                   as date                                    // archivale le
    field iNumeroImmeuble               as int64     initial ?
    field iNumeroBlocNote               as integer   initial ?
    field lProvisoire                   as logical   initial ? label "fgprov"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
