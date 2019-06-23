/*------------------------------------------------------------------------
File        : objetBail.i
Purpose     : 
Author(s)   : gga - 2018/12/05
Notes       : gga pour le moment copie de mandat.i pour faire une table specifique objet du bail 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttObjetBail
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
    field cCodeStatut                   as character initial ? label "cdstatut"
    field cLibelleCodeStatut            as character initial ?
    field daDateEffet                   as date                label "dtdeb"       //effet ou renouvele le
    field daDateExpiration              as date                label "dtfin"       //expire le
    field daDateExpirationContractuelle as date                
    field cTypeDateExpiration           as character                               //vide si gestion date expiration "contractuel" si gestion date contractuel                 
    field daDateInitiale                as date                label "dtini"       //premier contrat le
    field daSignature                   as date                label "dtsig"
    field cLieuSignature                as character initial ? label "lisig"
    field daDateValidation              as date                label "dtvaldef"
    field cNumeroRegistre               as character initial ? label "noree"
    field iNbRenouvellement             as integer   initial ? label "nbren"
    field lTaciteReconduction           as logical   initial ?
    field iDuree                        as integer   initial ? label "nbdur"
    field cUniteDuree                   as character initial ? label "cddur"
    field cLibelleUniteDuree            as character initial ? 
    field iDelaiPreavis                 as integer   initial ? label "nbres"
    field cUnitePreavis                 as character initial ? label "utres"
    field cLibelleUnitePreavis          as character initial ? 
    field cTypeActe                     as character initial ? label "tpact"
    field cLibelleTypeActe              as character initial ? 
    field cOrigineClient                as character initial ? label "cdori"
    field cLibelleOrigineClient         as character initial ? 
    field lResiliation                  as logical   initial ?
    field daResiliation                 as date                label "dtree"       // resiliation le             
    field cMotifResiliation             as character initial ? label "tpfin"
    field cLibelleMotifResiliation      as character initial ?
    field iNumeroBlocNote               as integer   initial ?
    field lProvisoire                   as logical   initial ? label "fgprov"
    field iDureeAn                      as integer   initial ? label ""
    field iDureeMois                    as integer   initial ? label ""
    field iDureeJour                    as integer   initial ? label ""
    field lDroitResiliation             as logical   initial ? label "fgrestrien"
    field lProlongation                 as logical   initial ? label "fgprolongation" 
    field cMotifProlongation            as character initial ? label "motifprolongation" 
    field cReferenceClient              as character initial ? label "lbdiv" 
    field cTypeRegime                   as character initial ? label "" 
    field cLibelleTypeRegime            as character initial ? label "" 
    field lAbattementAvecNature         as logical   initial ? label "" 
    field lCatComCiv                    as logical
    field lBrwResil                     as logical
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
