/*------------------------------------------------------------------------
File        : dec6660et.i
Purpose     : Table entete de la declaration 6660
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDec6660et
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field activite          as character  initial ? 
    field annee             as integer    initial ? 
    field cdcsy             as character  initial ? 
    field cdhon             as character  initial ? 
    field cdmsy             as character  initial ? 
    field CodeCategorie     as character  initial ? 
    field ctdec             as character  initial ? 
    field ctpai             as character  initial ? 
    field dtcsy             as date       initial ? 
    field dtmsy             as date       initial ? 
    field hecsy             as integer    initial ? 
    field hemsy             as integer    initial ? 
    field idloc             as character  initial ? 
    field lbdiv             as character  initial ? 
    field lbdiv2            as character  initial ? 
    field lbdiv3            as character  initial ? 
    field mtloyann          as decimal    initial ?  decimals ?
    field NACE              as character  initial ? 
    field noapp             as integer    initial ? 
    field NoCategorie       as integer    initial ? 
    field noimm             as integer    initial ? 
    field noman             as integer    initial ? 
    field nomdt             as integer    initial ? 
    field occupation        as character  initial ? 
    field sfloueparprc      as decimal    initial ?  decimals 2
    field sfloueparscouv    as decimal    initial ?  decimals 2
    field sfloueparsnoncouv as decimal    initial ?  decimals 2
    field sfparprc          as decimal    initial ?  decimals 2
    field sfparscouv        as decimal    initial ?  decimals 2
    field sfparsnoncouv     as decimal    initial ?  decimals 2
    field tbocc             as character  initial ? 
    field tbsiren           as character  initial ? 
    field tphon             as character  initial ? 
    field tpmdt             as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
