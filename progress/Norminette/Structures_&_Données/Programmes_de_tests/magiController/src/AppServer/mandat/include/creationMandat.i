/*------------------------------------------------------------------------
File        : creationMandat.i
Purpose     : table pour la creation des mandats (avec minimum d'information)
Author(s)   : GGA - 2019/01/07
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCreationMandat 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeTypeContrat              as character initial ?
    field cLibelleTypeContrat           as character initial ?    
    field iNumeroContrat                as int64     initial ?
    field cCodeNatureContrat            as character initial ?
    field cLibelleNatureContrat         as character initial ?
    field iNumeroImmeuble               as integer   initial ?
    field iNumeroServiceGestion         as int64     initial ?
    field lSaisiServiceGestion          as logical   initial ?
    
    field CRUD        as character
.
