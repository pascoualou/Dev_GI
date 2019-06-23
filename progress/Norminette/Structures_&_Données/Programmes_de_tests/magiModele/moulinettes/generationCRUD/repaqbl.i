/*------------------------------------------------------------------------
File        : repaqbl.i
Purpose     : Répartition des rubriques analytique et de quittancement (dans les groupes et postes budgétaires) pour la présentation du Budget Locatif
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRepaqbl
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdrub  as integer    initial ? 
    field cdsrb  as integer    initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field nogrp  as integer    initial ? 
    field nopost as integer    initial ? 
    field notri  as integer    initial ? 
    field tprub  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
