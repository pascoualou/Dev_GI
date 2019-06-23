/*------------------------------------------------------------------------
File        : atva3.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAtva3
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdexe     as integer    initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dttir     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field Lbcdi     as character  initial ? 
    field Lbcdr     as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field Lbped     as character  initial ? 
    field lbper     as character  initial ? 
    field Lbreg     as character  initial ? 
    field Mtcrd     as decimal    initial ?  decimals 2
    field Mtcrd-dev as decimal    initial ?  decimals 2
    field mtpay     as decimal    initial ?  decimals 2
    field mtpay-dev as decimal    initial ?  decimals 2
    field nofor     as integer    initial ? 
    field nolig     as integer    initial ? 
    field noman     as integer    initial ? 
    field nomdt     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
