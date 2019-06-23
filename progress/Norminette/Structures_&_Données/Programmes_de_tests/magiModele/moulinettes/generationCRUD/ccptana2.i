/*------------------------------------------------------------------------
File        : ccptana2.i
Purpose     : Deuxiem fichier compte analytique
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCcptana2
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd as character  initial ? 
    field ana2-cd as character  initial ? 
    field dadeb   as date       initial ? 
    field dafin   as date       initial ? 
    field etab-cd as integer    initial ? 
    field libana  as character  initial ? 
    field soc-cd  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
