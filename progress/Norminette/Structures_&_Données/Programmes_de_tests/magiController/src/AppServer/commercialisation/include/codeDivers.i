/*------------------------------------------------------------------------
File        : codeDivers.i
Purpose     :
Author(s)   : GGA - 2017/06/13
Notes       : Table generique code divers (pour ne pas utiliser extent)  
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCodeDivers
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCode    as character initial ? 
    field cLibelle as character initial ? 
.
