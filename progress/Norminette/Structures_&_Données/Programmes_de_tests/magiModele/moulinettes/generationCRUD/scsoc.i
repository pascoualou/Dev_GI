/*------------------------------------------------------------------------
File        : scsoc.i
Purpose     : Informations diverses sur la société : elles apparaisent dans la fiche tiers
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttScsoc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy    as character  initial ? 
    field cdmsy    as character  initial ? 
    field divers   as character  initial ? 
    field dtcsy    as date       initial ? 
    field dtmsy    as date       initial ? 
    field hecsy    as integer    initial ? 
    field hemsy    as integer    initial ? 
    field lbdiv    as character  initial ? 
    field lbdiv2   as character  initial ? 
    field lbdiv3   as character  initial ? 
    field nbprt    as integer    initial ? 
    field nocab    as integer    initial ? 
    field NoConOrg as integer    initial ? 
    field nomax    as integer    initial ? 
    field nomin    as integer    initial ? 
    field nosoc    as integer    initial ? 
    field pxprt    as decimal    initial ?  decimals 2
    field pxtot    as decimal    initial ?  decimals 2
    field TpConOrg as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
