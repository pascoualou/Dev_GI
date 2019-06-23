/*------------------------------------------------------------------------
File        : AFAIR.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAfair
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CDAFF     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field CDUSE     as character  initial ? 
    field CMAFF     as character  initial ? 
    field dtcsy     as date       initial ? 
    field DTDEB     as date       initial ? 
    field DTFIN     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field HEURE     as integer    initial ? 
    field IdtAff    as character  initial ? 
    field LBDEM     as character  initial ? 
    field LBDET     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field LGRAP     as logical    initial ? 
    field LGURG     as logical    initial ? 
    field MDAFF     as logical    initial ? 
    field NOAFF     as integer    initial ? 
    field NODEM     as integer    initial ? 
    field NOIMM     as integer    initial ? 
    field NOLOC     as integer    initial ? 
    field noloc-dec as decimal    initial ?  decimals 0
    field NOMDT     as integer    initial ? 
    field nomdt-dec as decimal    initial ?  decimals 0
    field NONAT     as integer    initial ? 
    field NOROL     as integer    initial ? 
    field norol-dec as decimal    initial ?  decimals 0
    field TITRE     as character  initial ? 
    field TPDEM     as character  initial ? 
    field TPMDT     as character  initial ? 
    field TPROL     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
