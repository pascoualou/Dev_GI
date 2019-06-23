/*------------------------------------------------------------------------
File        : actrcln.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttActrcln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cptdeb     as character  initial ? 
    field cptfin     as character  initial ? 
    field fg-defaut  as logical    initial ? 
    field fg-dispo   as logical    initial ? 
    field fg-dispohb as logical    initial ? 
    field profil-cd  as integer    initial ? 
    field sscptdeb   as character  initial ? 
    field sscptfin   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
