/*------------------------------------------------------------------------
File        : zparspool.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttZparspool
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CmdNet   as character  initial ? 
    field CmdPro   as character  initial ? 
    field nbport   as integer    initial ? 
    field NetPar1  as integer    initial ? 
    field NetPar2  as integer    initial ? 
    field NetPar3  as integer    initial ? 
    field PathBase as character  initial ? 
    field PathLog  as character  initial ? 
    field PathProg as character  initial ? 
    field portcnx  as integer    initial ? 
    field portdeb  as integer    initial ? 
    field time1    as integer    initial ? 
    field time2    as integer    initial ? 
    field time3    as integer    initial ? 
    field time4    as integer    initial ? 
    field time5    as integer    initial ? 
    field Unit1    as character  initial ? 
    field Unit2    as character  initial ? 
    field Unit3    as character  initial ? 
    field Unit4    as character  initial ? 
    field Unit5    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
