/*------------------------------------------------------------------------
File        : plafonnementEncadrementLoyer.i
Purpose     :
Author(s)   : SY  -  09/01/2017
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPlafonnementEncadrementLoyer
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroFiche               as integer   initial ?
    field lZoneTendue                as logical   initial ?
    field lPremBailLoi89             as logical   initial ?
    field daResilBailPrec            as date
    field lDernTravInf6Mois          as logical   initial ?
    field dMontantTravauxInf6MoisTTC as decimal   initial ?
    field lDernIndex                 as logical   initial ?
    field lAncLoyerSousEval          as logical   initial ?
    field lDernTravSup6Mois          as logical   initial ?
    field dMontantTravauxSup6MoisTTC as decimal   initial ?
    field dAncienLoyer               as decimal   initial ?
    field dLoyerRevise               as decimal   initial ?
    field dLoyerActualise            as decimal   initial ?
    field dLoyerSelonTravaux         as decimal   initial ?
    field dLoyerPourQuartier         as decimal   initial ?
    field dLoyerLibre                as decimal   initial ?
    field daNouvBail                 as date
    field daDernIndex                as date
    field dDernIndiceConnu           as decimal   initial ?
    field dDernIndiceUtilise         as decimal   initial ?
.
