/*------------------------------------------------------------------------
File        : tacheClotureManuelle.i
Purpose     : table tache cloture manuelle
Author(s)   : GGA  -  28/07/2017
Notes       :
derniere revue: 2018/05/19 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheClotureManuelle
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat     as character initial ? label "tpcon"
    field iNumeroContrat   as int64     initial ? label "nocon"
    field cTypeTache       as character initial ? label "tptac"
    field lClotureManuelle as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
