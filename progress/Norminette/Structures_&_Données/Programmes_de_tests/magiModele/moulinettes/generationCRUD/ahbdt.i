/*------------------------------------------------------------------------
File        : ahbdt.i
Purpose     : Appels Hors-Budget : Détail
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAhbdt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdeta     as integer    initial ? 
    field cdmsy     as character  initial ? 
    field clecr     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lblig     as character  initial ? 
    field mtecr     as decimal    initial ?  decimals 2
    field mtecr-dev as decimal    initial ?  decimals 2
    field noapp     as integer    initial ? 
    field nocpt     as integer    initial ? 
    field noecr     as integer    initial ? 
    field noimm     as integer    initial ? 
    field nolig     as integer    initial ? 
    field noscp     as integer    initial ? 
    field tvecr     as decimal    initial ?  decimals 2
    field tvecr-dev as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
