/*------------------------------------------------------------------------
File        : cpaiecom.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCpaiecom
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field chrono             as integer    initial ? 
    field coll-cle           as character  initial ? 
    field compens-coll-cle   as character  initial ? 
    field compens-cpt-cd     as character  initial ? 
    field compens-sscoll-cle as character  initial ? 
    field cpt-cd             as character  initial ? 
    field daech              as date       initial ? 
    field etab-cd            as integer    initial ? 
    field jou-cd             as character  initial ? 
    field lib                as character  initial ? 
    field lig                as integer    initial ? 
    field mt                 as decimal    initial ?  decimals 2
    field mt-EURO            as decimal    initial ?  decimals 2
    field piece-compta       as integer    initial ? 
    field piece-int          as integer    initial ? 
    field pointable          as logical    initial ? 
    field prd-cd             as integer    initial ? 
    field prd-num            as integer    initial ? 
    field ref-num            as character  initial ? 
    field regl-cd            as integer    initial ? 
    field sel                as logical    initial ? 
    field sens               as logical    initial ? 
    field soc-cd             as integer    initial ? 
    field sscoll-cle         as character  initial ? 
    field type-cle           as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
