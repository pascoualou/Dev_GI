/*------------------------------------------------------------------------
File        : loge.i
Purpose     : Loges de l'immeuble
0913/0130 Gardien(s) par batiment
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLoge
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdbat         as character  initial ? 
    field cdcsy         as character  initial ? 
    field cdmsy         as character  initial ? 
    field dtcsy         as date       initial ? 
    field dtmsy         as date       initial ? 
    field fgactif       as logical    initial ? 
    field fgprincipal   as logical    initial ? 
    field hecsy         as integer    initial ? 
    field hemsy         as integer    initial ? 
    field iloge         as integer    initial ? 
    field lbdiv         as character  initial ? 
    field lbdiv2        as character  initial ? 
    field lbdiv3        as character  initial ? 
    field lbloge        as character  initial ? 
    field noimm         as integer    initial ? 
    field nolog         as integer    initial ? 
    field NomContact    as character  initial ? 
    field norol         as int64      initial ? 
    field tbcom         as character  initial ? 
    field tbhouv        as character  initial ? 
    field tbInfoContact as character  initial ? 
    field tprol         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
