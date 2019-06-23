/*------------------------------------------------------------------------
File        : alrubhlp.i
Purpose     : Table des liens Rub/Ssrub pour les listes surgissantes
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAlrubhlp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdlng     as integer    initial ? 
    field cpt-cd    as character  initial ? 
    field fg-use    as logical    initial ? 
    field librub    as character  initial ? 
    field libssrub  as character  initial ? 
    field profil-cd as integer    initial ? 
    field rub-cd    as character  initial ? 
    field soc-cd    as integer    initial ? 
    field ssrub-cd  as character  initial ? 
    field type-chg  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
