/*------------------------------------------------------------------------
File        : prlvnet.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPrlvnet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdivers    as character  initial ? 
    field coll-cle   as character  initial ? 
    field cpt-cd     as character  initial ? 
    field dacompta   as date       initial ? 
    field dev-cd     as character  initial ? 
    field domicil    as character  initial ? 
    field dtsig      as date       initial ? 
    field dvalid     as date       initial ? 
    field etab-cd    as integer    initial ? 
    field iban       as character  initial ? 
    field lib-ecr    as character  initial ? 
    field mtprel     as decimal    initial ?  decimals 2
    field noprel     as int64      initial ? 
    field norum      as character  initial ? 
    field notie      as int64      initial ? 
    field sens       as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field statut     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
