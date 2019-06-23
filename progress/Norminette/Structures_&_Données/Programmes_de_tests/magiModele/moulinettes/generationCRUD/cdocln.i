/*------------------------------------------------------------------------
File        : cdocln.i
Purpose     : Fichier de saisie des numeros de documents
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCdocln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annee      as integer    initial ? 
    field dadeb      as date       initial ? 
    field daderdoc   as date       initial ? 
    field dafin      as date       initial ? 
    field div-cd     as integer    initial ? 
    field etab-cd    as integer    initial ? 
    field mois       as character  initial ? 
    field num-doc    as integer    initial ? 
    field soc-cd     as integer    initial ? 
    field typedoc-cd as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
