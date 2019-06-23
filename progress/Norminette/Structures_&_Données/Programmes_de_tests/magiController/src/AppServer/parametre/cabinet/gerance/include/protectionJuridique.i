/*------------------------------------------------------------------------
File        : protectionJuridique.i
Purpose     :
Author(s)   : RF  -  09/11/2017
Notes       : Paramétrage des assurances garanties - 01017 - Protection Juridique
derniere revue: 2018/04/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttProtectionJuridique
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat               as character initial ? label "tpctt"
    field cLibelleTypeContrat        as character initial ?
    field iNumeroContrat             as integer   initial ? label "noctt"
    field cLibelleNumeroContrat      as character initial ?
    field cModeComptabilisation      as character initial ? label "lbdiv2"
    field cLibelleComptabilisation   as character initial ?
    field cLibelle2Comptabilisation  as character initial ?
    field cCodeAssureur              as character initial ? label "lbdiv"   // à dupliquer dans garan.cdass
    field cLibelleAssureur           as character initial ?
    field cCodeTVA                   as character initial ? label "cdtva"
    field cLibelleTVA                as character initial ?
    field cCodeApplicationTVA        as character initial ? label "fgtot"
    field cLibelleApplicationTVA     as character initial ?
    field cCodePeriodicite           as character initial ? label "cdper"
    field cLibellePeriodicite        as character initial ?

    field dtTimestamp                as datetime
    field CRUD                       as character
    field rRowid                     as rowid
.
