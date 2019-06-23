/*------------------------------------------------------------------------
File        : ientnotfrais.i
Purpose     : Fichier entete de note de frais
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIentnotfrais
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field avance        as decimal    initial ?  decimals 2
    field avance-EURO   as decimal    initial ?  decimals 2
    field bque          as character  initial ? 
    field collectif     as character  initial ? 
    field datdeb        as date       initial ? 
    field datfin        as date       initial ? 
    field etab-cd       as integer    initial ? 
    field fic-num       as integer    initial ? 
    field ficvalcompta  as logical    initial ? 
    field lieutrans     as character  initial ? 
    field matcpt        as character  initial ? 
    field modregl       as integer    initial ? 
    field netpaye       as decimal    initial ?  decimals 2
    field netpaye-EURO  as decimal    initial ?  decimals 2
    field scenario      as character  initial ? 
    field soc-cd        as integer    initial ? 
    field totfrais      as decimal    initial ?  decimals 2
    field totfrais-EURO as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
