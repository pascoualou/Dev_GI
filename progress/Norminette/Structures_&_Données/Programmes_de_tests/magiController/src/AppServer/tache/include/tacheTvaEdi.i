/*------------------------------------------------------------------------
File        : tacheTvaEdi.i
Purpose     : 
Author(s)   : GGA  -  2017/08/17
Notes       :
derniere revue: 2018/05/19 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheTvaEdi
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache          as int64     initial ?
    field cTypeContrat          as character initial ?
    field iNumeroContrat        as int64     initial ?
    field cTypeTache            as character initial ?
    field iChronoTache          as integer   initial ?
    field daActivation          as date
    field daFin                 as date
    field cRefOblFisc           as character initial ?
    field cNoFrp                as character initial ?
    field daAdhesion            as date
    field cMoyenPaiement        as character initial ?
    field cLibelleMoyenPaiement as character initial ?
    field cIbanPremierCompte    as character initial ?
    field cBicPremierCompte     as character initial ?
    field cTitPremierCompte     as character initial ?
    field cIbanDeuxiemeCompte   as character initial ?
    field cBicDeuxiemeCompte    as character initial ?
    field cTitDeuxiemeCompte    as character initial ?
    field cIbanTroisiemeCompte  as character initial ?
    field cBicTroisiemeCompte   as character initial ?
    field cTitTroisiemeCompte   as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
