/*------------------------------------------------------------------------
File        : cd2ln.i
Purpose     : DAS2 : Detail des montants par fournisseur
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCd2ln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd        as character  initial ? 
    field d2ven-cle     as character  initial ? 
    field etab-cd       as integer    initial ? 
    field mt-total      as decimal    initial ?  decimals 2
    field mt-total-EURO as decimal    initial ?  decimals 2
    field num-int       as integer    initial ? 
    field soc-cd        as integer    initial ? 
    field zone-cd       as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
