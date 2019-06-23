/*------------------------------------------------------------------------
File        : GL_HISTO_WORKFLOW.i
Purpose     : Historique changement d'étape du workflow
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_histo_workflow
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy            as character  initial ? 
    field cdmsy            as character  initial ? 
    field dtcsy            as date       initial ? 
    field dtmsy            as date       initial ? 
    field hecsy            as integer    initial ? 
    field hemsy            as integer    initial ? 
    field nofiche          as integer    initial ? 
    field nohisto_workflow as integer    initial ? 
    field noworkflow1      as integer    initial ? 
    field noworkflow2      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
