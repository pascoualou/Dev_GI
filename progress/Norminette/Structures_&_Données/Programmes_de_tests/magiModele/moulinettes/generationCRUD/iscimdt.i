/*------------------------------------------------------------------------
File        : iscimdt.i
Purpose     : Table des correspondances mandats SCI
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIscimdt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-att    as character  initial ? 
    field cpt-cab    as character  initial ? 
    field etab-cd    as integer    initial ? 
    field fg-tva     as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field soc-sci    as integer    initial ? 
    field sscoll-cab as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
