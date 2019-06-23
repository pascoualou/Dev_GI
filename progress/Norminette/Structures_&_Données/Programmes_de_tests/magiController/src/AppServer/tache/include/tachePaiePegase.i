/*------------------------------------------------------------------------
File        : tachePaiePegase
Purpose     : 
Author(s)   : GGA  -  2017/11/13
Notes       : a partir de adb/tache/prmmtpeg.p
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTachePaiePegase
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat                 as character initial ? 
    field iNumeroContrat               as int64     initial ? 
    field cTypeTache                   as character initial ? 
    field cCodeSiret                   as character initial ? //HwDtaSir  
    field cCodeNic                     as character initial ? //HwDtaNic 
    field cCodeApe                     as character initial ? //HwDtaApe
    field cCodeSociete                 as character initial ? //HwDtaSOC 
    field cDateHeurePremierExport      as character initial ? //HwDtaEXP 
    field lGestionPaieExternePegase    as logical   initial ? //HwTglPegase
    field daDebutPaiePegase            as date                //HwDatDeb 
    field daFinPaiePegase              as date                //HwDatFin 
    field cModeComptabilisation        as character initial ? //HwRadCpta 
    field cLibelleModeComptabilisation as character initial ? 
    field daDernierMoisPaieIntegre     as date                //HwDatPai 
    field lMonoEtablissement           as logical   initial ? //HwTglMono 
    field cEtablissementPrincipal      as character initial ? //HwEtbPrinc  
    field lAssujettissement            as logical   initial ? //HwDtaAsj
    field iTauxTaxe                    as integer   initial ? //HwDtaAtx
    field lEtablissementDeclarant      as logical   initial ? //HwTglEtbDec
    field cEtablissementDeclarant      as character initial ? //HwEtbDec  
    field cCentrePaiementInit          as character initial ? //HwORPINI     
    field cClePourOd                   as character initial ? //HwZonClArd 

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
