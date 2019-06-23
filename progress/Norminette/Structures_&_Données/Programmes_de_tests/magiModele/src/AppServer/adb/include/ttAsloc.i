/*------------------------------------------------------------------------
File        : asloc.i
Purpose     : 
Author(s)   : generation automatique le 01/24/18
Notes       : compl�t�e de champs de calculs.
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAsloc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field msqtt     as integer    initial ? 
    field mtass     as decimal    initial ?  decimals 2
    field mtass-dev as decimal    initial ?  decimals 2
    field mthon     as decimal    initial ?  decimals 2
    field mthon-dev as decimal    initial ?  decimals 2
    field mttva     as decimal    initial ?  decimals 2
    field mttva-dev as decimal    initial ?  decimals 2
    field noass     as integer    initial ? 
    field nobar     as integer    initial ? 
    field noloc     as int64      initial ? 
    field noloc-dec as decimal    initial ?  decimals 0
    field txass     as decimal    initial ?  decimals 2
    field txhon     as decimal    initial ?  decimals 2
    field ttAss     as decimal    initial ?    // champ intermediaire pour les calculs, pas dans la base.
    field ttHon     as decimal    initial ?    // champ intermediaire pour les calculs, pas dans la base.
    field ttTva     as decimal    initial ?    // champ intermediaire pour les calculs, pas dans la base.

    field cdcsy     as character  initial ? 
    field cddev     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
