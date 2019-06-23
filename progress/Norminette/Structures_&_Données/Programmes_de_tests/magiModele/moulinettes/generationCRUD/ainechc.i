/*------------------------------------------------------------------------
File        : ainechc.i
Purpose     : echeances emprunt par copro et lot
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAinechc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd     as character  initial ? 
    field ana2-cd     as character  initial ? 
    field ana3-cd     as character  initial ? 
    field ana4-cd     as character  initial ? 
    field annee       as integer    initial ? 
    field bureau-cle  as character  initial ? 
    field cpt-cd      as character  initial ? 
    field cpt-copro   as character  initial ? 
    field daech       as date       initial ? 
    field etab-cd     as integer    initial ? 
    field jou-cd      as character  initial ? 
    field mt-appel    as decimal    initial ?  decimals 2
    field mtamoex     as decimal    initial ?  decimals 2
    field mtamort     as decimal    initial ?  decimals 2
    field mtassur     as decimal    initial ?  decimals 2
    field mtech       as decimal    initial ?  decimals 2
    field mtinteret   as decimal    initial ?  decimals 2
    field mtresidu    as decimal    initial ?  decimals 2
    field mttva       as decimal    initial ?  decimals 2
    field nbmois      as decimal    initial ?  decimals 2
    field nolot       as integer    initial ? 
    field num-int     as integer    initial ? 
    field order-num   as integer    initial ? 
    field piece-int   as integer    initial ? 
    field prd-cd      as integer    initial ? 
    field prd-num     as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field sscoll-cle  as character  initial ? 
    field type-invest as integer    initial ? 
    field valid       as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
