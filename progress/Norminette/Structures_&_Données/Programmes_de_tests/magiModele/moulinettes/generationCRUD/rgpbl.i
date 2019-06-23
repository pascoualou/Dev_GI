/*------------------------------------------------------------------------
File        : rgpbl.i
Purpose     : Référence des groupes et postes budgétaires du budget locatif
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRgpbl
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy      as character  initial ? 
    field cdmsy      as character  initial ? 
    field dtcsy      as date       initial ? 
    field dtmsy      as date       initial ? 
    field fisc-cle   as character  initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field lbcom      as character  initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field lbenr      as character  initial ? 
    field nogrp      as integer    initial ? 
    field noord      as integer    initial ? 
    field nopost     as integer    initial ? 
    field rubexclues as character  initial ? 
    field tpenr      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
