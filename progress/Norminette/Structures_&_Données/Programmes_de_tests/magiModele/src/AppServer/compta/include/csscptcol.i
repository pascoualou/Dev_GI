/*------------------------------------------------------------------------
File        : csscptcol.i
Purpose     : Fichier collectif
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCsscptcol
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field coll-cle    as character  initial ? 
    field douteux     as logical    initial ? 
    field etab-cd     as integer    initial ? 
    field facturable  as logical    initial ? 
    field fg-compta   as logical    initial ? 
    field fg-fdr      as logical    initial ? 
    field lib         as character  initial ? 
    field lib2        as character  initial ? 
    field libtier-cd  as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field sscoll-cle  as character  initial ? 
    field sscoll-cpt  as character  initial ? 
    field sscoll2-cle as character  initial ? 
    field sscoll2-cpt as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
