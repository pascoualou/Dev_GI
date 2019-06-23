/*------------------------------------------------------------------------
File        : positionComptable.i
Description :
Author(s)   : LGI/  -  2018/03/09
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPositionComptable
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cLibellePosition as character
    field dSolde           as decimal
.
