/*------------------------------------------------------------------------
File        : objetMandatSyndic.i
Purpose     : 
Author(s)   : GGA - 2019/01/05
Notes       : gga pour le moment copie de bail.i pour faire une table specifique objet du mandat de syndic
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttObjetMandatSyndic
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
// cle
    field cCodeTypeContrat              as character initial ? label "tpcon"
    field iNumeroContrat                as int64     initial ? label "nocon"
    field iNumeroDocument               as integer   initial ? label "nodoc"
    field cLibelleTypeContrat           as character initial ?
    field cCodeNatureContrat            as character initial ? label "ntcon"
    field cLibelleNatureContrat         as character initial ?
// partie haute    
    field cNumeroRegistre               as character initial ? label "noree"
    field daSignature                   as date                label "dtsig"
    field cLieuSignature                as character initial ? label "lisig"
    field daDateInitiale                as date                label "dtini"       
    field daDateNomination              as date                label "dtdeb"       
    field iDuree                        as integer   initial ? label "nbdur"
    field cUniteDuree                   as character initial ? label "cddur"
    field cLibelleUniteDuree            as character initial ? 
    field daDateExpiration              as date                label "dtfin"       
    field iDelaiPreavis                 as integer   initial ? label "nbres"
    field cUnitePreavis                 as character initial ? label "utres"
    field cLibelleUnitePreavis          as character initial ? 
    field lTaciteReconduction           as logical   initial ?
    field cTypeActe                     as character initial ? label "tpact"
    field cLibelleTypeActe              as character initial ? 
    field cCodeDevise                   as character initial ? label "cddev"
    field cLibelleCodeDevise            as character initial ?
    field cNumeroContratIkos            as character initial ? label "cdusage1" 
// partie resiliation        
    field lResiliation                  as logical   initial ?
    field daResiliation                 as date                label "dtree"              
    field cMotifResiliation             as character initial ? label "tpfin"
    field cLibelleMotifResiliation      as character initial ?
    field daOdFinMandat                 as date                                    // OD fin mandat le
    field daArchivage                   as date                                    // archivale le

// ???????
    field iNumeroBlocNote               as integer   initial ?
    field lProvisoire                   as logical   initial ? label "fgprov"
    field iNumeroImmeuble               as int64     initial ?
        
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
