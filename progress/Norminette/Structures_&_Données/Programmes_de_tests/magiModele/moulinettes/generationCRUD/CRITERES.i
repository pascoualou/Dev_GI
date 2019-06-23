/*------------------------------------------------------------------------
File        : CRITERES.i
Purpose     : Criteres de selection des lots
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCriteres
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field Ddispo    as date       initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field DtRech    as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field Natur     as character  initial ? 
    field Nbpie     as integer    initial ? 
    field norol     as integer    initial ? 
    field norol-dec as decimal    initial ?  decimals 0
    field Prix      as integer    initial ? 
    field Prix-dev  as integer    initial ? 
    field Secteur   as character  initial ? 
    field Surf      as decimal    initial ?  decimals 2
    field Tprol     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
