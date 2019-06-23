/*------------------------------------------------------------------------
File        : menuweb.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMenuweb
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cDivers          as character  initial ? 
    field cLienImage       as character  initial ? 
    field cLienURL         as character  initial ? 
    field cPrefixe         as character  initial ? 
    field cProfilItem      as character  initial ? 
    field cTypeMenu        as character  initial ? 
    field IdMenu           as int64      initial ? 
    field IdParent         as int64      initial ? 
    field iNumeroItem      as int64      initial ? 
    field iNumeroRecherche as int64      initial ? 
    field iOrdre           as int64      initial ? 
    field lItemActif       as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
