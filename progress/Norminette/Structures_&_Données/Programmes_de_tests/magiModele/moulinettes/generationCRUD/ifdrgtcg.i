/*------------------------------------------------------------------------
File        : ifdrgtcg.i
Purpose     : Tables des correspondances comptes generaux par regroupement
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdrgtcg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-ht         as character  initial ? 
    field cpt-tva        as character  initial ? 
    field cptg-cd        as character  initial ? 
    field cptg-dest      as character  initial ? 
    field cptg-produit   as character  initial ? 
    field etab-cd        as integer    initial ? 
    field fg-ana100      as logical    initial ? 
    field fg-ana100-dest as logical    initial ? 
    field FgCptAge       as logical    initial ? 
    field rgt-cle        as character  initial ? 
    field soc-cd         as integer    initial ? 
    field soc-dest       as integer    initial ? 
    field sscpt-cd       as character  initial ? 
    field sscpt-dest     as character  initial ? 
    field sscpt-produit  as character  initial ? 
    field taxe-cd        as integer    initial ? 
    field typefac-cle    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
