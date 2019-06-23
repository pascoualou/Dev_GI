/*------------------------------------------------------------------------
File        : paramBudgetLocatif.i
Purpose     :
Author(s)   : DMI 2018/03/17
Notes       : Paramétrage des budgets locatifs
derniere revue: 2018/04/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParametreBudgetLocatif
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field tppar                        as character initial "BUDLO"               serialize-hidden // uniquement pour le CRUD
    field iNumeroModele                as integer   initial ?       label "zon07" format "999" // HwCmbMod
    field cRepriseSolde                as character initial ?       label "zon02" // HwCmbPro 
    field lExtraComptable              as logical   initial ?       label "zon03" format "00001/00002" // HwCmbExt - CdBudExt
    field lProrataTva                  as logical   initial ?       label "zon05" format "00001/00002" // HwCmbPrt - CdBudPrt
    field cListeExclusionAnalytique    as character initial ?       label "zon04" serialize-hidden // HwFilExc
    field cListeExclusionQuittancement as character initial ?       label "zon06" serialize-hidden // HwFilExc-Q
    field zon01                        as character initial ?                     serialize-hidden // uniquement pour le CRUD
    field dtTimestamp                  as datetime
    field CRUD                         as character
    field rRowid                       as rowid
.
