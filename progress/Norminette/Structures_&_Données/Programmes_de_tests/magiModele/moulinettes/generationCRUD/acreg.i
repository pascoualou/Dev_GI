/*------------------------------------------------------------------------
File        : acreg.i
Purpose     : Accords de règlement
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAcreg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdclot     as character  initial ? 
    field cdcsy      as character  initial ? 
    field cdmsy      as character  initial ? 
    field dtacr      as date       initial ? 
    field dtclot     as date       initial ? 
    field dtcsy      as date       initial ? 
    field dtech      as date       initial ? 
    field dtmsy      as date       initial ? 
    field fgclot     as character  initial ? 
    field fglib      as logical    initial ? 
    field hecsy      as integer    initial ? 
    field hemsy      as integer    initial ? 
    field jou-cd     as character  initial ? 
    field lbdiv      as character  initial ? 
    field lbdiv2     as character  initial ? 
    field lbdiv3     as character  initial ? 
    field lbech      as character  initial ? 
    field mtdiv1     as decimal    initial ?  decimals 2
    field mtdiv1-dev as decimal    initial ?  decimals 2
    field mtech      as decimal    initial ?  decimals 2
    field mtech-dev  as decimal    initial ?  decimals 2
    field mtini      as decimal    initial ?  decimals 2
    field mtini-dev  as decimal    initial ?  decimals 2
    field noblc      as integer    initial ? 
    field nocon      as int64      initial ? 
    field nocon-dec  as decimal    initial ?  decimals 0
    field nomdt      as integer    initial ? 
    field norol      as int64      initial ? 
    field norol-dec  as decimal    initial ?  decimals 0
    field piece-int  as integer    initial ? 
    field prd-cd     as integer    initial ? 
    field prd-num    as integer    initial ? 
    field tpcon      as character  initial ? 
    field tplig      as character  initial ? 
    field tpmdt      as character  initial ? 
    field tprol      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
