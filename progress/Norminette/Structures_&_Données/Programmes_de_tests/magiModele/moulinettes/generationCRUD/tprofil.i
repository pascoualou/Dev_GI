/*------------------------------------------------------------------------
File        : tprofil.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTprofil
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field acq-mail    as character  initial ? 
    field dacrea      as date       initial ? 
    field damod       as date       initial ? 
    field fg-juri     as logical    initial ? 
    field fg-Location as logical    initial ? 
    field fg-odg      as logical    initial ? 
    field fg-secu     as logical    initial ? 
    field fg-sup      as logical    initial ? 
    field fg-valfac   as logical    initial ? 
    field ged         as character  initial ? 
    field ihcrea      as integer    initial ? 
    field ihmod       as integer    initial ? 
    field iRattBur    as integer    initial ? 
    field lib         as character  initial ? 
    field niveau      as integer    initial ? 
    field nomes       as integer    initial ? 
    field plan-cd     as character  initial ? 
    field profil_u    as character  initial ? 
    field usrid       as character  initial ? 
    field usridmod    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
