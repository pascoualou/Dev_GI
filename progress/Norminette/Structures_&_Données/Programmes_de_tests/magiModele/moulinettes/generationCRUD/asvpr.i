/*------------------------------------------------------------------------
File        : asvpr.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAsvpr
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bic       as character  initial ? 
    field bque      as character  initial ? 
    field bque-nom  as character  initial ? 
    field cdficvir  as character  initial ? 
    field dacompta  as date       initial ? 
    field dacrea    as date       initial ? 
    field echeance  as character  initial ? 
    field fg-valid  as logical    initial ? 
    field gest-cle  as character  initial ? 
    field guichet   as character  initial ? 
    field iban      as character  initial ? 
    field ihcrea    as integer    initial ? 
    field mt        as decimal    initial ?  decimals 2
    field nbtrans   as integer    initial ? 
    field nom-fich  as character  initial ? 
    field operation as character  initial ? 
    field soc-cd    as integer    initial ? 
    field usrid     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
