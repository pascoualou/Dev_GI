/*------------------------------------------------------------------------
File        : tache.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTache
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field anirv              as integer    initial ? 
    field cdCptRecLoc        as character  initial ? 
    field cdcsy              as character  initial ? 
    field cddev              as character  initial ? 
    field cdFacRecLoc        as character  initial ? 
    field cdhon              as character  initial ? 
    field cdInfRecLoc        as character  initial ? 
    field cdir               as character  initial ? 
    field cdirv              as integer    initial ? 
    field cdmsy              as character  initial ? 
    field cdpli              as character  initial ? 
    field cdreg              as character  initial ? 
    field cdsie              as character  initial ? 
    field cptg-cd            as character  initial ? 
    field dcreg              as character  initial ? 
    field dossier            as character  initial ? 
    field dtcsy              as date       initial ? 
    field dtdeb              as date       initial ? 
    field dtfin              as date       initial ? 
    field dtmsy              as date       initial ? 
    field DtNego             as date       initial ? 
    field DtProcRecouv       as date       initial ? 
    field dtree              as date       initial ? 
    field dtreg              as date       initial ? 
    field dtrev              as date       initial ? 
    field duree              as integer    initial ? 
    field EdiModele          as character  initial ? 
    field etab-cd            as integer    initial ? 
    field etqclimat          as character  initial ? 
    field etqenergie         as character  initial ? 
    field FgCopieGlobal      as logical    initial ? 
    field fgdestitrt         as logical    initial ? 
    field FgGlobal           as logical    initial ? 
    field fgidxconv          as logical    initial ? 
    field fgimprdoc          as logical    initial ? 
    field fgmadispo          as logical    initial ? 
    field FgNego             as logical    initial ? 
    field FgPasRelance       as logical    initial ? 
    field FgProcRecouv       as logical    initial ? 
    field fgrev              as logical    initial ? 
    field fgsimplifie        as logical    initial ? 
    field hecsy              as integer    initial ? 
    field hemsy              as integer    initial ? 
    field IndEnergiePrimaire as decimal    initial ?  decimals 2
    field IndGazEffetSerre   as decimal    initial ?  decimals 2
    field joumax             as integer    initial ? 
    field lbdiv              as character  initial ? 
    field lbdiv-dev          as character  initial ? 
    field lbdiv10            as character  initial ? 
    field lbdiv2             as character  initial ? 
    field lbdiv3             as character  initial ? 
    field lbdiv4             as character  initial ? 
    field lbdiv5             as character  initial ? 
    field lbdiv6             as character  initial ? 
    field lbdiv7             as character  initial ? 
    field lbdiv8             as character  initial ? 
    field lbdiv9             as character  initial ? 
    field lbmotif            as character  initial ? 
    field mdcalIR            as character  initial ? 
    field mdreg              as character  initial ? 
    field mtreg              as decimal    initial ?  decimals 2
    field mtreg-dev          as decimal    initial ?  decimals 2
    field nbmav              as integer    initial ? 
    field nocle              as character  initial ? 
    field nocon              as int64      initial ? 
    field nocon-dec          as decimal    initial ?  decimals 0
    field NoCptGlobal        as character  initial ? 
    field noirv              as integer    initial ? 
    field noita              as int64      initial ? 
    field norol              as int64      initial ? 
    field nosie              as character  initial ? 
    field notac              as integer    initial ? 
    field notxt              as integer    initial ? 
    field ntges              as character  initial ? 
    field ntreg              as character  initial ? 
    field pdges              as character  initial ? 
    field pdreg              as character  initial ? 
    field service            as character  initial ? 
    field sscpt-cd           as character  initial ? 
    field tpcon              as character  initial ? 
    field tpfin              as character  initial ? 
    field tpges              as character  initial ? 
    field tphon              as character  initial ? 
    field tpmadisp           as character  initial ? 
    field tprol              as character  initial ? 
    field tptac              as character  initial ? 
    field trtgar             as character  initial ? 
    field tx-norol           as int64      initial ? 
    field tx-tprol           as character  initial ? 
    field TxIRcont           as decimal    initial ?  decimals 2
    field txno1              as decimal    initial ?  decimals 3
    field txno2              as decimal    initial ?  decimals 3
    field utreg              as character  initial ? 
    field valetqclimat       as integer    initial ? 
    field valetqenergie      as integer    initial ? 
    field web-presentation   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
