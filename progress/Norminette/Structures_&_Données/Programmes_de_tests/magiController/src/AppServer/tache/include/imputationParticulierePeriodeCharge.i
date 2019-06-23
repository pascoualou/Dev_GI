/*------------------------------------------------------------------------
File        : imputationParticulierePeriodeChargLoc.i
Purpose     : 
Author(s)   : GGA  -  2018/01/22
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttImputationParticulierePeriode
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat         as character initial ?
    field iNumeroContrat       as int64     initial ?
    field iNumeroPeriode       as integer   initial ?
    field daReleve             as date
    field dMontantTTC          as decimal   initial ?
    field dMontantRecuperation as decimal   initial ?
.
