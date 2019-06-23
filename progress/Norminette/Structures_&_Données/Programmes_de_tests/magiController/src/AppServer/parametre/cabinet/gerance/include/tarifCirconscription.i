/*------------------------------------------------------------------------
File        : tarifCirconscription.i
Purpose     : Paramétrage des tarifs par circonscription et usage (taxe sur les bureaux)
Author(s)   : DMI  -  2017/12/19
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTarifCirconscription
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iAnnee        as integer   initial ?
    field iZone         as integer   initial ?  // NoZone
    field dBureauNormal as decimal   initial ?  // MtBurN
    field dBureauReduit as decimal   initial ?  // MtBurR
    field dCommerciaux  as decimal   initial ?  // MtComN
    field dStockage     as decimal   initial ?  // MtStkN
    field dParcExpo     as decimal   initial ?  // MtPExN
    field dParking      as decimal   initial ?  // MtPkgN
    field dTaxeAddPkg   as decimal   initial ?  // MtPkAd
    field cLibelle      as character initial ?

    field CRUD as character
.
&if defined(nomTableAnnee)   = 0 &then &scoped-define nomTableAnnee ttAnneeTarifCirconscription
&endif
&if defined(serialNameAnnee) = 0 &then &scoped-define serialNameAnnee {&nomTableAnnee}
&endif
define temp-table {&nomTableAnnee} no-undo serialize-name '{&serialNameAnnee}'
    field iAnnee        as integer   initial ?

    field CRUD        as character
    field dtTimestamp as datetime
    field rRowid      as rowid
.
