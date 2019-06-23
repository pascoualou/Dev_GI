/*------------------------------------------------------------------------
File        : cprorata.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCprorata
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd  as character  initial ? 
    field calcul   as logical    initial ? 
    field dadeb    as date       initial ? 
    field dafin    as date       initial ? 
    field date-reg as date       initial ? 
    field etab-cd  as integer    initial ? 
    field fg-situ  as logical    initial ? 
    field soc-cd   as integer    initial ? 
    field taux     as decimal    initial ?  decimals 8
    field taux-adm as decimal    initial ?  decimals 8
    field taux-ass as decimal    initial ?  decimals 8
    field taux-txt as decimal    initial ?  decimals 8
    field tauxcalc as decimal    initial ?  decimals 8
    field tauxsauv as decimal    initial ?  decimals 8
    field zone1    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
