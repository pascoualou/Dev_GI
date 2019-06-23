/*------------------------------------------------------------------------
File        : iBaseAdresse.i
Purpose     : Base des adresses utilisées
Author(s)   : generation automatique le 22/10/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIbaseadresse
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ccodeinsee              as character initial ?
    field ccodepays               as character initial ?
    field ccodepostal             as character initial ?
    field ccomplementdistribution as character initial ?
    field cidban                  as character initial ?
    field cville                  as character initial ?
    field cvoie                   as character initial ?
    field dlatitude               as decimal   initial ? decimals 10
    field dlongitude              as decimal   initial ? decimals 10
    field inumeroadresse          as int64     initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
