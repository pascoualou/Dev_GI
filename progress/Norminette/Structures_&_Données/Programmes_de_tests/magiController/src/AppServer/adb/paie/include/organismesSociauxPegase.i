/*------------------------------------------------------------------------
File        : organismesSociauxPegase.i
Purpose     : 
Author(s)   : GGA  -  2017/11/16
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttOrganismeSociauxPegase
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cLibTypeOrganisme     as character initial ?
    field cCodeOrganisme        as character initial ?
    field cNomOrganisme         as character initial ?
    field cAdresseOrganisme     as character initial ?
    field cCollGi               as character initial ?
    field cLibelleCollGi        as character initial ?
    field cCompte               as character initial ?
    field cCompteFour           as character initial ?
    field cCleFour              as character initial ?
    field identifiantGI         as character initial ?
    field cNomFour              as character initial ?
    field cAdresseFour          as character initial ?
    field cCPFour               as character initial ?
    field cVilleFour            as character initial ?
    field cCPVilleFourGI        as character initial ?
    field cLibelleAdresse       as character initial ?
    field cCptSalPegase         as character initial ?
    field cCptPatPegase         as character initial ? 
    field cEtabRattach          as character initial ?        /* Etablissement de rattachement */
    field cNoAffiliation        as character initial ?
    field cModeReg              as character initial ?
    field cPerioDeclar          as character initial ?
    field cExigibilite          as character initial ?        /* Exigibilité */   
    field cPerioTaxe            as character initial ?        /* ? */
    field cRefInterneEdi        as character initial ?        /* SY 0316/0282 référence interne (pour le virement) */ 
    field cFlgPeriodiciteUrssaf as character initial ?        /* périodicité de règlement URSSAF (dépend du nb salariés) */       
    field PerioReglt            as character initial ? 
.
