/*------------------------------------------------------------------------
File        : gaint.i
Purpose     : affectation tache - utilisateur pour la gestion des alertes
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGaint
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field agence as integer    initial ? 
    field cdcsy  as character  initial ? 
    field cddur  as character  initial ? 
    field cdmaj  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdper  as character  initial ? 
    field delta  as integer    initial ? 
    field deltm  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field DtRDb  as date       initial ? 
    field DtRFi  as date       initial ? 
    field FgDay  as logical    initial ? 
    field hduree as integer    initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field HeRDb  as integer    initial ? 
    field HeRFi  as integer    initial ? 
    field hrale  as character  initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field LbEmp  as character  initial ? 
    field mduree as integer    initial ? 
    field noidt  as int64      initial ? 
    field nojou  as integer    initial ? 
    field noord  as integer    initial ? 
    field norol  as integer    initial ? 
    field notac  as integer    initial ? 
    field ntctt  as character  initial ? 
    field smjou  as integer    initial ? 
    field smnum  as character  initial ? 
    field tpidt  as character  initial ? 
    field tprol  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
