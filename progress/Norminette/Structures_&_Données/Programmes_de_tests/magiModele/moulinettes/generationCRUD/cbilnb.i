/*------------------------------------------------------------------------
File        : cbilnb.i
Purpose     : Fichier des lignes de bilan colonne B
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbilnb
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cbil-type as character  initial ? 
    field etab-cd   as integer    initial ? 
    field etat-cd   as character  initial ? 
    field rub-cd    as integer    initial ? 
    field rubln-cd  as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field type      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
