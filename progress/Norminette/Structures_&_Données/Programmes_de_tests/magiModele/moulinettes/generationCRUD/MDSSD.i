/*------------------------------------------------------------------------
File        : MDSSD.i
Purpose     : Mod�le de sous-dossier
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMdssd
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdsdo  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field dtsup  as date       initial ? 
    field fgsup  as logical    initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbcom  as character  initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lbmod  as character  initial ? 
    field noact  as integer    initial ? 
    field nomod  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
