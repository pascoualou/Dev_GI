/*------------------------------------------------------------------------
File        : parndf.i
Purpose     : Parametrage des notes de frais
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParndf
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-auto    as logical    initial ? 
    field etab-cd     as integer    initial ? 
    field flag-compta as logical    initial ? 
    field jou-cd      as character  initial ? 
    field nbuser-ndf  as integer    initial ? 
    field num-int     as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field type-cle    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
