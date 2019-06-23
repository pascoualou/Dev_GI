/*------------------------------------------------------------------------
File        : GL_DETAILFINANCE.i
Purpose     : Ligne de détails des éléments financiers
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_detailfinance
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy           as character  initial ? 
    field cdmsy           as character  initial ? 
    field dtcsy           as date       initial ? 
    field dtmsy           as date       initial ? 
    field hecsy           as integer    initial ? 
    field hemsy           as integer    initial ? 
    field montantht       as decimal    initial ?  decimals 2
    field montantht_pro   as decimal    initial ?  decimals 2
    field montanttaxe     as decimal    initial ?  decimals 2
    field montanttaxe_pro as decimal    initial ?  decimals 2
    field montantttc      as decimal    initial ?  decimals 2
    field montantttc_pro  as decimal    initial ?  decimals 2
    field nochpfinance    as integer    initial ? 
    field nodetailfinance as integer    initial ? 
    field nofinance       as integer    initial ? 
    field notaxe          as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
