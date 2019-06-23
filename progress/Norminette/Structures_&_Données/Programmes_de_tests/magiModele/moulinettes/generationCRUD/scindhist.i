/*------------------------------------------------------------------------
File        : scindhist.i
Purpose     : Historisation de la décomposition d'une indivision
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttScindhist
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy     as character  initial ? 
    field cdmsy     as character  initial ? 
    field dtcsy     as date       initial ? 
    field dthist    as date       initial ? 
    field dtmsy     as date       initial ? 
    field hecsy     as integer    initial ? 
    field hemsy     as integer    initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field nb-NuProp as integer    initial ? 
    field nb-tant   as integer    initial ? 
    field nb-Usuf   as integer    initial ? 
    field noind     as integer    initial ? 
    field nolgn     as integer    initial ? 
    field nolig     as integer    initial ? 
    field nopos     as integer    initial ? 
    field norang    as integer    initial ? 
    field notie     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
