/*------------------------------------------------------------------------
File        : iinterf.i
Purpose     : Fichier des parametres d'interface comptabilite
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIinterf
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field corem            as logical    initial ? 
    field cpte-cd          as character  initial ? 
    field cptesc-cd        as character  initial ? 
    field cptp-cd          as character  initial ? 
    field cptrem-cd        as character  initial ? 
    field cptte-cd         as character  initial ? 
    field cpttp-cd         as character  initial ? 
    field cptvcee-cd       as character  initial ? 
    field cptve-cd         as character  initial ? 
    field cptvf-cd         as character  initial ? 
    field cptvr-cd         as character  initial ? 
    field cptvs-cd         as character  initial ? 
    field etab-cd          as integer    initial ? 
    field jouvcee-cd       as character  initial ? 
    field jouvcee-g-cd     as character  initial ? 
    field jouve-cd         as character  initial ? 
    field jouve-g-cd       as character  initial ? 
    field jouvf-cd         as character  initial ? 
    field jouvf-g-cd       as character  initial ? 
    field jouvr-cd         as character  initial ? 
    field soc-cd           as integer    initial ? 
    field sscollvcee-cle   as character  initial ? 
    field sscollvcee-g-cle as character  initial ? 
    field sscollve-cle     as character  initial ? 
    field sscollve-g-cle   as character  initial ? 
    field sscollvf-cle     as character  initial ? 
    field sscollvf-g-cle   as character  initial ? 
    field sscollvr-cle     as character  initial ? 
    field typevceea-cle    as character  initial ? 
    field typevceef-cle    as character  initial ? 
    field typevea-cle      as character  initial ? 
    field typevef-cle      as character  initial ? 
    field typevfa-cle      as character  initial ? 
    field typevff-cle      as character  initial ? 
    field typevra-cle      as character  initial ? 
    field typevrf-cle      as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
