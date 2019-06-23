/*------------------------------------------------------------------------
File        : ifprgtcg.i
Purpose     : Tables des correspondances comptes generaux par regroupement
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfprgtcg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cptg-cd     as character  initial ? 
    field etab-cd     as integer    initial ? 
    field fg-ana100   as logical    initial ? 
    field rgt-cle     as character  initial ? 
    field soc-cd      as integer    initial ? 
    field sscpt-cd    as character  initial ? 
    field taxe-cd     as integer    initial ? 
    field typefac-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
