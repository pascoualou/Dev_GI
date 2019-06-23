/*------------------------------------------------------------------------
File        : cecrana.i
Purpose     : fichier des entetes de lignes analytiques utilise en  saisie    analytique manuelle
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCecrana
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field consol     as logical    initial ? 
    field dacompta   as date       initial ? 
    field daeff      as date       initial ? 
    field damod      as date       initial ? 
    field dev-cd     as character  initial ? 
    field etab-cd    as integer    initial ? 
    field ihmod      as integer    initial ? 
    field jou-cd     as character  initial ? 
    field lib        as character  initial ? 
    field piece-int  as integer    initial ? 
    field prd-cd     as integer    initial ? 
    field prd-num    as integer    initial ? 
    field repart-cle as character  initial ? 
    field scen-cle   as character  initial ? 
    field situ       as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field type-cle   as character  initial ? 
    field usrid      as character  initial ? 
    field usrid-eff  as character  initial ? 
    field usridmod   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
