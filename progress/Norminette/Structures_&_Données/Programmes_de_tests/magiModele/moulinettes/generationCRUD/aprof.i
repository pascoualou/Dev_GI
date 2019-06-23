/*------------------------------------------------------------------------
File        : aprof.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAprof
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field fgfloy     as logical    initial ? 
    field mandatdeb  as integer    initial ? 
    field mandatfin  as integer    initial ? 
    field nome1      as integer    initial ? 
    field nome2      as integer    initial ? 
    field profil-adb as character  initial ? 
    field profil-cd  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
