/*------------------------------------------------------------------------
File        : listeIndivisaire.i
Description : 
Author(s)   : gga 2017/08/03
Notes       : 
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIndivisaire
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iIndivisaire as integer
.
