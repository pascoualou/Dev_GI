/*------------------------------------------------------------------------
File        : relevePeriodeCharge.i
Purpose     : 
Author(s)   : GGA  -  2018/01/22
Notes       : table erlet/perio
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRelevePeriode
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat          as character initial ?
    field iNumeroContrat        as int64     initial ?
    field iNumeroPeriode        as integer   initial ?
    field cTypeReleve           as character initial ?
    field cLibelleTypeReleve    as character initial ?
    field iNumeroReleve         as integer   initial ?
    field daReleve              as date
    field dConsommation         as decimal   initial ?
    field dMontantTTC           as decimal   initial ?
    field dMontantRecuperation1 as decimal   initial ?
    field dMontantRecuperation2 as decimal   initial ?
.
