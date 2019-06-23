/*------------------------------------------------------------------------
File        : cinechm.i
Purpose     : echeance mensuelle
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCinechm
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd        as character  initial ? 
    field ana2-cd        as character  initial ? 
    field ana3-cd        as character  initial ? 
    field ana4-cd        as character  initial ? 
    field annee          as integer    initial ? 
    field bureau-cle     as character  initial ? 
    field cpt-cd         as character  initial ? 
    field dadeb          as date       initial ? 
    field dadep          as date       initial ? 
    field daech          as date       initial ? 
    field etab-cd        as integer    initial ? 
    field jou-cd         as character  initial ? 
    field mat-num        as character  initial ? 
    field mois-num       as integer    initial ? 
    field mtamoex        as decimal    initial ?  decimals 2
    field mtamoex-EURO   as decimal    initial ?  decimals 2
    field mtamoex-fis    as decimal    initial ?  decimals 2
    field mtamort        as decimal    initial ?  decimals 2
    field mtamort-EURO   as decimal    initial ?  decimals 2
    field mtamort-fis    as decimal    initial ?  decimals 2
    field mtassur        as decimal    initial ?  decimals 2
    field mtassur-EURO   as decimal    initial ?  decimals 2
    field mtdep          as decimal    initial ?  decimals 2
    field mtderog        as decimal    initial ?  decimals 2
    field mtech          as decimal    initial ?  decimals 2
    field mtech-EURO     as decimal    initial ?  decimals 2
    field mtech-fis      as decimal    initial ?  decimals 2
    field mtinteret      as decimal    initial ?  decimals 2
    field mtinteret-EURO as decimal    initial ?  decimals 2
    field mtresidu       as decimal    initial ?  decimals 2
    field mtresidu-EURO  as decimal    initial ?  decimals 2
    field mtresidu-fis   as decimal    initial ?  decimals 2
    field mtretex        as decimal    initial ?  decimals 2
    field mttva          as decimal    initial ?  decimals 2
    field mttva-EURO     as decimal    initial ?  decimals 2
    field mtvnc          as decimal    initial ?  decimals 2
    field mtvnc-fis      as decimal    initial ?  decimals 2
    field nb-unit        as integer    initial ? 
    field nbmois         as decimal    initial ?  decimals 2
    field num-int        as integer    initial ? 
    field order-num      as integer    initial ? 
    field piece-int      as integer    initial ? 
    field prd-cd         as integer    initial ? 
    field prd-num        as integer    initial ? 
    field projection     as logical    initial ? 
    field soc-cd         as integer    initial ? 
    field type-invest    as integer    initial ? 
    field valid          as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
