/*------------------------------------------------------------------------
File        : dateResiliationTriennale.i
Purpose     : 
Author(s)   : gga - 2018/12/07
Notes       : 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDateResiliationTriennale
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat    as character initial ? label "tpcon"
    field iNumeroContrat  as int64     initial ? label "nocon"
    field daResiliation   as date                label "dtresil" 
    field iDureeAn        as integer   initial ? label "nbanndur" 
    field iDureeMois      as integer   initial ? label "nbmoisdur" 
    field iDureeJour      as integer   initial ? label "nbjoudur" 
    field CRUD            as character
.
