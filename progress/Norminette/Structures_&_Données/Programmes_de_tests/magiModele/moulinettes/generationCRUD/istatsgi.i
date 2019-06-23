/*------------------------------------------------------------------------
File        : istatsgi.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIstatsgi
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCheminement         as character  initial ? 
    field cdcsy                as character  initial ? 
    field cdmsy                as character  initial ? 
    field cNomProgramme        as character  initial ? 
    field cUtilisateurs        as character  initial ? 
    field dDerniereUtilisation as date       initial ? 
    field dInitialisation      as date       initial ? 
    field dtcsy                as date       initial ? 
    field dtmsy                as date       initial ? 
    field hecsy                as integer    initial ? 
    field hemsy                as integer    initial ? 
    field iCompteur            as integer    initial ? 
    field iReference           as integer    initial ? 
    field lbdiv                as character  initial ? 
    field lbdiv2               as character  initial ? 
    field lbdiv3               as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
