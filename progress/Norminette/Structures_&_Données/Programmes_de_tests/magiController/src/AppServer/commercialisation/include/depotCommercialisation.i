/*------------------------------------------------------------------------
File        : depotCommercialisation.i
Purpose     : 
Author(s)   : SY  -  09/01/2017
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDepotCommercialisation
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroDepot          as integer   initial ? label 'nodepot'
    field iNumeroElementFinance as integer   initial ? label 'nofinance'
    field iNumeroFiche          as integer   initial ?
    field iTypeDepot            as integer   initial ? label 'tpdepot'
    field iNombre2Mois          as integer   initial ? label 'nbloyer'
    field dMontantTotalHT       as decimal   initial ? label 'totalht'
    field dMontantTotalTTC      as decimal   initial ? label 'totalttc'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
