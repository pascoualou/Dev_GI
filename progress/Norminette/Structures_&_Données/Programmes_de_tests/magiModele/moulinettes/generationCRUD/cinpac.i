/*------------------------------------------------------------------------
File        : cinpac.i
Purpose     : fichier chrono
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCinpac
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annee       as integer    initial ? 
    field dadeb       as date       initial ? 
    field dafin       as date       initial ? 
    field etab-cd     as integer    initial ? 
    field invest-cle  as character  initial ? 
    field mois        as integer    initial ? 
    field num         as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field type-invest as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
