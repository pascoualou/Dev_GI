/*------------------------------------------------------------------------
File        : aredd.i
Purpose     : déclarations antérieures
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAredd
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dpimp     as decimal    initial ?  decimals 2
    field dpimp-dev as decimal    initial ?  decimals 2
    field dpmvt     as decimal    initial ?  decimals 2
    field dpmvt-dev as decimal    initial ?  decimals 2
    field dprap     as decimal    initial ?  decimals 2
    field dprap-dev as decimal    initial ?  decimals 2
    field dpsfi     as decimal    initial ?  decimals 2
    field dpsfi-dev as decimal    initial ?  decimals 2
    field dpsit     as decimal    initial ?  decimals 2
    field dpsit-dev as decimal    initial ?  decimals 2
    field dpsld     as decimal    initial ?  decimals 2
    field dpsld-dev as decimal    initial ?  decimals 2
    field dpver     as decimal    initial ?  decimals 2
    field dpver-dev as decimal    initial ?  decimals 2
    field dtcpt     as integer    initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dttir     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbper     as character  initial ? 
    field mdprs     as character  initial ? 
    field noman     as integer    initial ? 
    field nomdt     as integer    initial ? 
    field nored     as integer    initial ? 
    field rcimp     as decimal    initial ?  decimals 2
    field rcimp-dev as decimal    initial ?  decimals 2
    field rcmvt     as decimal    initial ?  decimals 2
    field rcmvt-dev as decimal    initial ?  decimals 2
    field rcrap     as decimal    initial ?  decimals 2
    field rcrap-dev as decimal    initial ?  decimals 2
    field rcsfi     as decimal    initial ?  decimals 2
    field rcsfi-dev as decimal    initial ?  decimals 2
    field rcsit     as decimal    initial ?  decimals 2
    field rcsit-dev as decimal    initial ?  decimals 2
    field rcsld     as decimal    initial ?  decimals 2
    field rcsld-dev as decimal    initial ?  decimals 2
    field rcver     as decimal    initial ?  decimals 2
    field rcver-dev as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
