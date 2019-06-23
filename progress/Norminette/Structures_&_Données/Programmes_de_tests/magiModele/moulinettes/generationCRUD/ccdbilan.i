/*------------------------------------------------------------------------
File        : ccdbilan.i
Purpose     : Fichiers Codes Bilans.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCcdbilan
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd as integer    initial ? 
    field etat-cd as character  initial ? 
    field letfisc as character  initial ? 
    field libfisc as character  initial ? 
    field mt      as decimal    initial ?  decimals 2
    field mt-EURO as decimal    initial ?  decimals 2
    field rub-cd  as integer    initial ? 
    field soc-cd  as integer    initial ? 
    field type    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
