/*------------------------------------------------------------------------
File        : gacal.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGacal
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annee   as integer    initial ? 
    field cdcsy   as character  initial ? 
    field cdmsy   as character  initial ? 
    field dtcsy   as date       initial ? 
    field dtmsy   as date       initial ? 
    field hecsy   as integer    initial ? 
    field hemsy   as integer    initial ? 
    field jrtra   as integer    initial ? 
    field lbdiv   as character  initial ? 
    field lbdiv2  as character  initial ? 
    field lbdiv3  as character  initial ? 
    field noidt   as int64      initial ? 
    field tbcal   as integer    initial ? 
    field tbcal2  as integer    initial ? 
    field tbcom   as character  initial ? 
    field tbdeb   as date       initial ? 
    field tbdfe   as date       initial ? 
    field tbfin   as date       initial ? 
    field tblfe   as character  initial ? 
    field tbnoidt as integer    initial ? 
    field tbofe   as integer    initial ? 
    field tbtpidt as character  initial ? 
    field tbtra   as date       initial ? 
    field tpidt   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
