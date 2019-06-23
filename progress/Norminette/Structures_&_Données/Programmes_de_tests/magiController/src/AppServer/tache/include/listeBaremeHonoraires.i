/*------------------------------------------------------------------------
File        : listeBaremeHonoraires
Purpose     : 
Author(s)   : GGA  -  2017/08/10
Notes       : 
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeBaremeHonoraires
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iCode         as integer   initial ?
    field cType         as character initial ?
    field cNature       as character initial ?
    field iNumero       as integer   initial ?
    field daApplication as date
    field cBaseCalcul   as character initial ?
    field dTaux         as decimal   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
