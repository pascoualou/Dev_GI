/*------------------------------------------------------------------------
File        : ged.i
Purpose     : 
Author(s)   : LGI/  -  2017/01/10 
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGedTypeDocument
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTypeDocument    as integer   initial ?
    field cLibelleTypeDocument   as character initial ?
    field cCodeTheme             as character initial ?
    field cCodeOrigine           as character initial ?
    field cObjet                 as character initial ?
    field lUtilise               as logical   initial ?
    field cTypeDossierGidemat    as character initial ?
    index idx1 cLibelleTypeDocument              // sortie dans l'ordre alphabétique
.
