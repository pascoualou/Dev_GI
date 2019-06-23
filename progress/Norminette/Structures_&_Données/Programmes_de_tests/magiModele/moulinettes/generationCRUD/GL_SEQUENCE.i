/*------------------------------------------------------------------------
File        : GL_SEQUENCE.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_sequence
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy      as character  initial ? 
    field cdmsy      as character  initial ? 
    field dtconge    as date       initial ? 
    field dtcsy      as date       initial ? 
    field dtdispo    as date       initial ? 
    field dtentree   as date       initial ? 
    field dtmsy      as date       initial ? 
    field dtsortie   as date       initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field nofiche    as integer    initial ? 
    field nohisto    as integer    initial ? 
    field norang     as integer    initial ? 
    field nosequence as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
