/*------------------------------------------------------------------------
File        : ilibrais.i
Purpose     : Liste des libelles des differentes raisons sociales des tiers.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIlibrais
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CodeCivilite1     as character  initial ? 
    field CodeCivilite2     as character  initial ? 
    field CodeFamille       as character  initial ? 
    field dacrea            as date       initial ? 
    field damod             as date       initial ? 
    field etab-cd           as integer    initial ? 
    field ihcrea            as integer    initial ? 
    field ihmod             as integer    initial ? 
    field lib               as character  initial ? 
    field LibDivers         as character  initial ? 
    field librais-cd        as integer    initial ? 
    field PolitesseCher     as character  initial ? 
    field PolitesseStandard as character  initial ? 
    field soc-cd            as integer    initial ? 
    field usrid             as character  initial ? 
    field usridmod          as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
