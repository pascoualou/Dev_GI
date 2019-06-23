/*------------------------------------------------------------------------
File        : PrmVt.i
Purpose     : Chaine travaux : parametrage de la ventilation analytique
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPrmvt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdTva as integer    initial ? 
    field CdVen as character  initial ? 
    field FgDos as logical    initial ? 
    field NoFis as character  initial ? 
    field NoOrd as integer    initial ? 
    field NoRef as integer    initial ? 
    field NoRub as character  initial ? 
    field NoSsr as character  initial ? 
    field PrVen as decimal    initial ?  decimals 2
    field TpCon as character  initial ? 
    field TpUrg as character  initial ? 
    field TpVen as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
