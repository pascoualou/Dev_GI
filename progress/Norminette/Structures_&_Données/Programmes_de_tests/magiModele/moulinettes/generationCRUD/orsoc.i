/*------------------------------------------------------------------------
File        : orsoc.i
Purpose     : Organismes Sociaux (URSSAF,...)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttOrsoc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adres   as character  initial ? 
    field CDA-ass as character  initial ? 
    field cdcsy   as character  initial ? 
    field cddev   as character  initial ? 
    field CDI-ass as character  initial ? 
    field cdmsy   as character  initial ? 
    field cdpos   as character  initial ? 
    field cpadr   as character  initial ? 
    field dtcsy   as date       initial ? 
    field dtmsy   as date       initial ? 
    field hecsy   as integer    initial ? 
    field hemsy   as integer    initial ? 
    field ident   as character  initial ? 
    field lbdiv   as character  initial ? 
    field lbdiv2  as character  initial ? 
    field lbdiv3  as character  initial ? 
    field LbNom   as character  initial ? 
    field lbvil   as character  initial ? 
    field mssup   as integer    initial ? 
    field nocpt   as integer    initial ? 
    field NoFax   as character  initial ? 
    field noscp   as integer    initial ? 
    field nosie   as character  initial ? 
    field NoTel   as character  initial ? 
    field ODB-ass as character  initial ? 
    field ORP-ass as character  initial ? 
    field OTS-ass as character  initial ? 
    field SIE-ass as character  initial ? 
    field TpOrg   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
