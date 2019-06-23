/*------------------------------------------------------------------------
File        : detailFinance.i
Purpose     : 
Author(s)   : SY  -  09/01/2017
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttDetailFinance
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroDetailFinance  as integer   initial ? label 'nodetailfinance'
    field iNumeroFiche          as integer   initial ?
    field iNumeroElementFinance as integer   initial ? label 'nofinance'   
    field iNumeroChampFinance   as integer   initial ? label 'nochpfinance'
    field iCodeTVA              as integer   initial ? label 'notaxe'
    field dMontantHT            as decimal   initial ? label 'montantht'
    field dMontantTaxe          as decimal   initial ? label 'montanttaxe'
    field dMontantTTC           as decimal   initial ? label 'montantttc'
    field dMontantHTProrata     as decimal   initial ? label 'montantht_pro'
    field dMontantTaxeProrata   as decimal   initial ? label 'montanttaxe_pro'
    field dMontantTTCProrata    as decimal   initial ? label 'montantttc_pro'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
index primaire is primary iNumeroDetailFinance.
