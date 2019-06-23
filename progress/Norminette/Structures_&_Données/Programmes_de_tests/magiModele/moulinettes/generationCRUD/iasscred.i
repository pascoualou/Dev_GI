/*------------------------------------------------------------------------
File        : iasscred.i
Purpose     : Assurance credit pour un client
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIasscred
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field asscred-cd  as integer    initial ? 
    field cli-cle     as character  initial ? 
    field dadebdepass as date       initial ? 
    field dadebmt     as date       initial ? 
    field dafindepass as date       initial ? 
    field dafinmt     as date       initial ? 
    field denomme     as logical    initial ? 
    field depass      as decimal    initial ?  decimals 2
    field depass-EURO as decimal    initial ?  decimals 2
    field etab-cd     as integer    initial ? 
    field mt          as decimal    initial ?  decimals 2
    field mt-EURO     as decimal    initial ?  decimals 2
    field num         as character  initial ? 
    field soc-cd      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
