/*------------------------------------------------------------------------
File        : cinmat.i
Purpose     : Fichier materiel (immos)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCinmat
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cession-cle   as character  initial ? 
    field comptaces     as logical    initial ? 
    field dacess        as date       initial ? 
    field etab-cd       as integer    initial ? 
    field invest-cle    as character  initial ? 
    field invest-num    as character  initial ? 
    field lib           as character  initial ? 
    field mat-num       as character  initial ? 
    field mtht          as decimal    initial ?  decimals 2
    field mtht-EURO     as decimal    initial ?  decimals 2
    field num-int       as integer    initial ? 
    field prixcess      as decimal    initial ?  decimals 2
    field prixcess-EURO as decimal    initial ?  decimals 2
    field soc-cd        as integer    initial ? 
    field tvacess       as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
