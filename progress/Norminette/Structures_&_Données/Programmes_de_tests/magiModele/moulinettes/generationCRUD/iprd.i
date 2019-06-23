/*------------------------------------------------------------------------
File        : iprd.i
Purpose     : Liste des periodes pour un etablissement d'une societe.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIprd
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dadebprd   as date       initial ? 
    field dafinprd   as date       initial ? 
    field dispo      as decimal    initial ?  decimals 2
    field dispo-EURO as decimal    initial ?  decimals 2
    field etab-cd    as integer    initial ? 
    field mvt        as logical    initial ? 
    field prd-cd     as integer    initial ? 
    field prd-num    as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field val        as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
