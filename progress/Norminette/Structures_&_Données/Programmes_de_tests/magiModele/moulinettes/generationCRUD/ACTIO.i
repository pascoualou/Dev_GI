/*------------------------------------------------------------------------
File        : ACTIO.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttActio
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field catbx  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field CDUSE  as character  initial ? 
    field CMFIN  as character  initial ? 
    field CMTEC  as character  initial ? 
    field DOCUM  as character  initial ? 
    field dtcsy  as date       initial ? 
    field DTDEB  as date       initial ? 
    field DTFIN  as date       initial ? 
    field dtmsy  as date       initial ? 
    field DTRET  as date       initial ? 
    field ETDOC  as character  initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field LGMLG  as logical    initial ? 
    field LIACT  as integer    initial ? 
    field LIAFF  as integer    initial ? 
    field NBEXP  as integer    initial ? 
    field NMDOT  as character  initial ? 
    field NOACT  as integer    initial ? 
    field NOAFF  as integer    initial ? 
    field NONAT  as integer    initial ? 
    field nosi2  as integer    initial ? 
    field NOSIG  as integer    initial ? 
    field TITRE  as character  initial ? 
    field tpsi2  as character  initial ? 
    field TPSIG  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
