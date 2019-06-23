/*------------------------------------------------------------------------
File        : istatcli.i
Purpose     : Statistique concernant les clients.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIstatcli
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field caht        as decimal    initial ?  decimals 2
    field caht-EURO   as decimal    initial ?  decimals 2
    field cli-cle     as character  initial ? 
    field cumtva      as decimal    initial ?  decimals 2
    field cumtva-EURO as decimal    initial ?  decimals 2
    field etab-cd     as integer    initial ? 
    field marge       as decimal    initial ?  decimals 2
    field marge-EURO  as decimal    initial ?  decimals 2
    field nbfact      as integer    initial ? 
    field prd-cd      as integer    initial ? 
    field prd-num     as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
