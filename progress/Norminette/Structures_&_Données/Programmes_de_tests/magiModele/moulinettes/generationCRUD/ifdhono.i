/*------------------------------------------------------------------------
File        : ifdhono.i
Purpose     : Table des honoraires de syndic
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfdhono
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num  as decimal    initial ?  decimals 0
    field ana4-cd     as character  initial ? 
    field cdrem       as integer    initial ? 
    field daech       as date       initial ? 
    field date        as date       initial ? 
    field divers      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field fg-compta   as logical    initial ? 
    field fisc-cle    as integer    initial ? 
    field heure       as character  initial ? 
    field lib         as character  initial ? 
    field mois-cpt    as integer    initial ? 
    field mt          as decimal    initial ?  decimals 2
    field mt-EURO     as decimal    initial ?  decimals 2
    field mtdev       as decimal    initial ?  decimals 2
    field mttva       as decimal    initial ?  decimals 2
    field NoIdt       as integer    initial ? 
    field rub-cd      as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field ssrub-cd    as integer    initial ? 
    field taxe-cd     as integer    initial ? 
    field txescpt     as integer    initial ? 
    field txremex     as integer    initial ? 
    field typefac-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
