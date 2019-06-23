/*------------------------------------------------------------------------
File        : ajqufl.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAjqufl
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cours           as decimal    initial ?  decimals 2
    field cptg-cd         as character  initial ? 
    field dacompta        as date       initial ? 
    field daech           as date       initial ? 
    field datecr          as date       initial ? 
    field devetr-cd       as character  initial ? 
    field etab-cd         as integer    initial ? 
    field fg-det          as logical    initial ? 
    field fisc-cle        as integer    initial ? 
    field inf01           as character  initial ? 
    field inf02           as character  initial ? 
    field inf03           as character  initial ? 
    field inf04           as character  initial ? 
    field inf05           as character  initial ? 
    field jou-cd          as character  initial ? 
    field lib             as character  initial ? 
    field lig             as integer    initial ? 
    field liste-det       as character  initial ? 
    field liste-det-dev   as character  initial ? 
    field liste-tva       as character  initial ? 
    field liste-tva-dev   as character  initial ? 
    field mandat-cd       as integer    initial ? 
    field mandat-cpt-cd   as character  initial ? 
    field mandat-sscpt-cd as character  initial ? 
    field mt              as decimal    initial ?  decimals 2
    field mt-EURO         as decimal    initial ?  decimals 2
    field mtdev           as decimal    initial ?  decimals 2
    field ordre-cd        as integer    initial ? 
    field piece-compta    as integer    initial ? 
    field pos             as integer    initial ? 
    field ref-num         as character  initial ? 
    field rub-cd          as integer    initial ? 
    field sens            as logical    initial ? 
    field soc-cd          as integer    initial ? 
    field sscpt-cd        as character  initial ? 
    field ssrub-cd        as integer    initial ? 
    field type-cle        as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
