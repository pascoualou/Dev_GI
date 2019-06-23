/*------------------------------------------------------------------------
File        : iechean.i
Purpose     : Fichier de repartition des echeances de traites
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIechean
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field daech      as date       initial ? 
    field etab-cd    as integer    initial ? 
    field mtttc      as decimal    initial ?  decimals 2
    field mtttc-EURO as decimal    initial ?  decimals 2
    field order-num  as integer    initial ? 
    field ref-num    as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
