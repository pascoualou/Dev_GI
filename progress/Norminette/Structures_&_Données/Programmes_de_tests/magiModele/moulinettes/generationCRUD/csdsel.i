/*------------------------------------------------------------------------
File        : csdsel.i
Purpose     : Solde des dossiers: ecran de selection
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCsdsel
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-deb     as character  initial ? 
    field ana1-fin     as character  initial ? 
    field ana2-deb     as character  initial ? 
    field ana2-fin     as character  initial ? 
    field ana3-deb     as character  initial ? 
    field ana3-fin     as character  initial ? 
    field ana4-deb     as character  initial ? 
    field ana4-fin     as character  initial ? 
    field borne-sup    as logical    initial ? 
    field coll-cle     as character  initial ? 
    field cpt-deb      as character  initial ? 
    field cpt-fin      as character  initial ? 
    field dacre-deb    as date       initial ? 
    field dacre-fin    as date       initial ? 
    field datrt        as date       initial ? 
    field etab-cd      as integer    initial ? 
    field flag-select  as logical    initial ? 
    field mtecart      as decimal    initial ?  decimals 2
    field mtecart-EURO as decimal    initial ?  decimals 2
    field order-num    as integer    initial ? 
    field soc-cd       as integer    initial ? 
    field sscoll-cle   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
