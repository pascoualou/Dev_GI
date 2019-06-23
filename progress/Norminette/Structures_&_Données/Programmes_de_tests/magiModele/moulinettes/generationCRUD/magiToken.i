/*------------------------------------------------------------------------
File        : magiToken.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMagitoken
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cRefCopro            as character  initial ? 
    field cRefGerance          as character  initial ? 
    field cRefPrincipale       as character  initial ? 
    field cUser                as character  initial ? 
    field cValeur              as character  initial ? 
    field daDateFinRespCopro   as date       initial ? 
    field daDateFinRespGerance as date       initial ? 
    field horodate             as datetime   initial ? 
    field iCodeLangueReference as integer    initial ? 
    field iCodeLangueSession   as integer    initial ? 
    field iCodeSociete         as integer    initial ? 
    field iCollaborateur       as integer    initial ? 
    field iGestionnaire        as integer    initial ? 
    field iTraceLevel          as integer    initial ? 
    field iUser                as int64      initial ? 
    field jSessionId           as character  initial ? 
    field lDebug               as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
