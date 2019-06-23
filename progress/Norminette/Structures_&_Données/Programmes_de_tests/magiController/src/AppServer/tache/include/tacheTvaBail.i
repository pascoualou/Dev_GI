/*-----------------------------------------------------------------------------
File        : tacheTvaBail.i
Purpose     : 
Author(s)   : npo  -  2018/03/12
Notes       : Bail - Tache TVA
derniere revue: 2018/05/24 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheTvaBail
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache          as int64     initial ? label "noita"
    field cTypeContrat          as character initial ? label "tpcon"
    field iNumeroContrat        as int64     initial ? label "nocon"
    field cTypeTache            as character initial ? label "tptac"
    field iChronoTache          as integer   initial ? label "notac"
    field daActivation          as date                label "dtdeb"
    field cCodeTauxTVA          as character initial ? label "ntges"      // CdCodTva
    field cLibelleTauxTVA       as character initial ?
    field cCodeApplicableSur    as character initial ? label "pdges"      // CdCmbCal
    field cLibelleApplicableSur as character initial ?
    field iNumeroRubriqueQtt    as integer   initial ?
    field iNumeroLibelleQtt     as integer   initial ?
    field cLibelleRubriqueQtt   as character initial ?
    // Dispositif Fiscal Investisseur Etranger
    field cNumeroTvaIntraComm   as character initial ? label "cdreg"
    field lNonCommunique        as logical   initial ?
    field cCodeTauxTVAIntraComm as character initial ?
    field cLibelleTVAIntraComm  as character initial ?
    field cTravailLbdiv         as character initial ? label "lbdiv"  serialize-hidden
    field cTravailLbdiv2        as character initial ? label "lbdiv2" serialize-hidden
    field lDispositifFiscal     as logical   initial ?

    field dtTimestamp           as datetime
    field CRUD                  as character
    field rRowid                as rowid
.
