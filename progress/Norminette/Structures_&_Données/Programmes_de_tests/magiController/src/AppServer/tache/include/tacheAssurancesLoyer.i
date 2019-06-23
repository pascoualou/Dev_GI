/*-----------------------------------------------------------------------------
File        : tacheAssurancesLoyer.i
Purpose     : Définition dataset tache assurances loyers (04342)
Author(s)   : OFA  -  2017/10/05
Notes       : 
derneire revue: 2018/05/16 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheAssurancesLoyer
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache                     as int64     initial ? label "noita"
    field cTypeContrat                     as character initial ? label "tpcon"
    field iNumeroContrat                   as int64     initial ? label "nocon"
    field cTypeTache                       as character initial ? label "tptac"
    field iChronoTache                     as integer   initial ? label "notac"
    field daActivation                     as date                label "dtdeb"
    field cNumGarantieLoyerBauxCom         as character initial ? label "ntges"
    field cNumGarantieLoyerBauxHab         as character initial ? label "tpges"
    field cNumProtectionJuridiqueBauxCom   as character initial ? label "pdreg"
    field cNumProtectionJuridiqueBauxHab   as character initial ? label "dcreg"
    field cNumGarantieRisqueLocatifBauxCom as character initial ? label "cdsie"
    field cNumGarantieRisqueLocatifBauxHab as character initial ? label "nosie"
    field cNumCarenceLocativeBauxCom       as character initial ? label "cdreg"
    field cNumCarenceLocativeBauxHab       as character initial ? label "ntreg"
    field cNumGarantieSpeciale             as character initial ? label "cdhon"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
