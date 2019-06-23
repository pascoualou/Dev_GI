/*------------------------------------------------------------------------
File        : irep.i
Purpose     : Fichier Representant
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIrep
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr             as character  initial ? 
    field comment         as character  initial ? 
    field cp              as character  initial ? 
    field dacreat         as date       initial ? 
    field damodif         as date       initial ? 
    field effacable       as logical    initial ? 
    field etab-cd         as integer    initial ? 
    field fax             as character  initial ? 
    field libobj-cd       as integer    initial ? 
    field libpays-cd      as character  initial ? 
    field libtcom-cd      as integer    initial ? 
    field libtreg-cd      as integer    initial ? 
    field mtobjectif      as decimal    initial ?  decimals 2
    field mtobjectif-EURO as decimal    initial ?  decimals 2
    field nom             as character  initial ? 
    field pays            as character  initial ? 
    field rep-cle         as character  initial ? 
    field soc-cd          as integer    initial ? 
    field tel             as character  initial ? 
    field txcomm          as decimal    initial ?  decimals 2
    field ville           as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
