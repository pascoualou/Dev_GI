/*-----------------------------------------------------------------------------
File        : ibanSimple.i
Description : Information minimun coordonnées bancaires
Author(s)   : RF - 2017/07/03
Notes       :
derniere revue: 2018/05/24 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttibanFournisseur 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cCodeFournisseur as character initial ?
    field iCodeSociete     as integer   initial ?
    field cIban            as character initial ?
    field cBic             as character initial ?
    field cDomiciliation   as character initial ?
    field cTitulaire       as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
.
