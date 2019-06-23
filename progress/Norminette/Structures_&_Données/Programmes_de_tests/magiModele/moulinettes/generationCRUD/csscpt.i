/*------------------------------------------------------------------------
File        : csscpt.i
Purpose     : Fichier collectif rattache aux cptes indiv
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCsscpt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr          as character  initial ? 
    field champmod     as character  initial ? 
    field coll-cle     as character  initial ? 
    field cp           as character  initial ? 
    field cpt-cd       as character  initial ? 
    field cpt-int      as character  initial ? 
    field cpt2-cd      as character  initial ? 
    field cpt2-int     as character  initial ? 
    field dacrea       as date       initial ? 
    field damod        as date       initial ? 
    field denominateur as integer    initial ? 
    field douteux      as logical    initial ? 
    field etab-cd      as integer    initial ? 
    field facturable   as logical    initial ? 
    field ihcrea       as integer    initial ? 
    field ihmod        as integer    initial ? 
    field lib          as character  initial ? 
    field lib2         as character  initial ? 
    field libcli-cd    as integer    initial ? 
    field libpays-cd   as character  initial ? 
    field numerateur   as integer    initial ? 
    field regl-cd      as integer    initial ? 
    field rep-cle      as character  initial ? 
    field soc-cd       as integer    initial ? 
    field sscoll-cle   as character  initial ? 
    field usrid        as character  initial ? 
    field usridmod     as character  initial ? 
    field ville        as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
