/*------------------------------------------------------------------------
File        : cdocsai.i
Purpose     : Fichier document (entete)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCdocsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field div-cd        as integer    initial ? 
    field etab-cd       as integer    initial ? 
    field nbcar-annee   as integer    initial ? 
    field nbcar-suffixe as integer    initial ? 
    field num-int       as integer    initial ? 
    field sediv         as integer    initial ? 
    field serie         as integer    initial ? 
    field soc-cd        as integer    initial ? 
    field struct        as logical    initial ? 
    field type-numer    as character  initial ? 
    field typedoc-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
