/*------------------------------------------------------------------------
File        : aligrefa.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAligrefa
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field divers     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field fgfac      as logical    initial ? 
    field fgprorata  as logical    initial ? 
    field jou-cd     as character  initial ? 
    field lbnom      as character  initial ? 
    field lig        as integer    initial ? 
    field mil-loc    as decimal    initial ?  decimals 2
    field mil-mdt    as decimal    initial ?  decimals 2
    field msqtt      as integer    initial ? 
    field mtdep      as decimal    initial ?  decimals 2
    field mtrub      as decimal    initial ?  decimals 2
    field mtttc      as decimal    initial ?  decimals 2
    field nbjourpres as integer    initial ? 
    field nbjourtot  as integer    initial ? 
    field noloc      as integer    initial ? 
    field num-int    as integer    initial ? 
    field pcloc      as decimal    initial ?  decimals 2
    field piece-int  as integer    initial ? 
    field pos        as integer    initial ? 
    field prd-cd     as integer    initial ? 
    field prd-num    as integer    initial ? 
    field prorata    as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
