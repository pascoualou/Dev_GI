/*------------------------------------------------------------------------
File        : ijou.i
Purpose     : Fichier journaux
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIjou
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bonapaye     as logical    initial ? 
    field bqjou-cd     as character  initial ? 
    field champmod     as character  initial ? 
    field contrepartie as logical    initial ? 
    field cpt-cd       as character  initial ? 
    field cpt-oblig    as logical    initial ? 
    field dacrea       as date       initial ? 
    field dadeb        as date       initial ? 
    field daech        as logical    initial ? 
    field dafin        as date       initial ? 
    field damod        as date       initial ? 
    field dev-cd       as character  initial ? 
    field dev-oblig    as logical    initial ? 
    field etab-cd      as integer    initial ? 
    field fg-defaut    as logical    initial ? 
    field fg-gi        as logical    initial ? 
    field fpiece       as character  initial ? 
    field ihcrea       as integer    initial ? 
    field ihmod        as integer    initial ? 
    field jou-cd       as character  initial ? 
    field lib          as character  initial ? 
    field natjou-cd    as integer    initial ? 
    field natjou-gi    as integer    initial ? 
    field numpiec      as logical    initial ? 
    field soc-cd       as integer    initial ? 
    field sscoll-cle   as character  initial ? 
    field usrid        as character  initial ? 
    field usridmod     as character  initial ? 
    field valecr       as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
