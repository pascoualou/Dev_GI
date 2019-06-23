/*------------------------------------------------------------------------
File        : cinfis.i
Purpose     : fichier des coefficients fiscaux
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCinfis
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field coeff    as decimal    initial ?  decimals 2
    field dadeb    as date       initial ? 
    field dafin    as date       initial ? 
    field duree    as decimal    initial ?  decimals 2
    field taux-deg as decimal    initial ?  decimals 2
    field taux-lin as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
