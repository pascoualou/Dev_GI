/*------------------------------------------------------------------------
File        : GL_WORKFLOW.i
Purpose     : Liaison entre les différentes étapes du workflow
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_workflow
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy        as character  initial ? 
    field cdmsy        as character  initial ? 
    field dtcsy        as date       initial ? 
    field dtmsy        as date       initial ? 
    field fgcommercial as logical    initial ? 
    field fggestion    as logical    initial ? 
    field fglogiciel   as logical    initial ? 
    field hecsy        as integer    initial ? 
    field hemsy        as integer    initial ? 
    field noworkflow1  as integer    initial ? 
    field noworkflow2  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
