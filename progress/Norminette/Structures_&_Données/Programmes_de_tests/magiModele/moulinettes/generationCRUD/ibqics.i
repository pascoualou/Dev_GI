/*------------------------------------------------------------------------
File        : ibqics.i
Purpose     : Identifiant Creancier SEPA
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIbqics
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr        as character  initial ? 
    field cdics      as character  initial ? 
    field cp         as character  initial ? 
    field dacrea     as date       initial ? 
    field damod      as date       initial ? 
    field ihcrea     as integer    initial ? 
    field ihmod      as integer    initial ? 
    field libpays-cd as character  initial ? 
    field nomics     as character  initial ? 
    field soc-cd     as integer    initial ? 
    field usrid      as character  initial ? 
    field usridmod   as character  initial ? 
    field ville      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
