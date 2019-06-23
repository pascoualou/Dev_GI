/*------------------------------------------------------------------------
File        : scact.i
Purpose     : Liste des actionnaires de la société
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttScact
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy            as character  initial ? 
    field cdmsy            as character  initial ? 
    field dtcsy            as date       initial ? 
    field dtmsy            as date       initial ? 
    field fgacc            as logical    initial ? 
    field fgind            as logical    initial ? 
    field hecsy            as integer    initial ? 
    field hemsy            as integer    initial ? 
    field lbdiv            as character  initial ? 
    field lbdiv2           as character  initial ? 
    field lbdiv3           as character  initial ? 
    field noact            as integer    initial ? 
    field norol            as int64      initial ? 
    field norol-mandataire as integer    initial ? 
    field nosoc            as integer    initial ? 
    field notie            as int64      initial ? 
    field tprol            as character  initial ? 
    field tprol-Mandataire as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
