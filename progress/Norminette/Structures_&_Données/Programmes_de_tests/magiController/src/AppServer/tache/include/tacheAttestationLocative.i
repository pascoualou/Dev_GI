/*------------------------------------------------------------------------
File        : tacheAttestationLocative.i
Purpose     : table tache Attestation Locative
Author(s)   : npo  -  30/10/2017
Notes       : Baux Lot 1
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheAttestationLocative
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache           as int64     initial ?
    field cTypeContrat           as character initial ? label "tpcon"
    field iNumeroContrat         as int64     initial ? label "nocon"
    field cTypeTache             as character initial ? label "tptac"
    field cTypeRole              as character initial ?
    field cLibelleTypeRole       as character initial ?
    field iNumeroRole            as int64     initial ?
    field cNomRole               as character initial ?
    field iNumeroTypeAttestation as integer   initial ? label "notac"
    field cLibelleAttestation    as character initial ?
    field daValideDu             as date                label "dtdeb"
    field daValideAu             as date                label "dtfin"
    field iNombreMois            as integer   initial ? label "duree"
    field cNumeroPolice          as character initial ? label "ntges"
    field cNomCompagnie          as character initial ? label "tpges" 
    field lBrisdeGlace           as logical   initial ?
    field lTempeteOuragan        as logical   initial ?
    field lVolVandalisme         as logical   initial ?
    field lIncendieExplosion     as logical   initial ?
    field lDegatsDesEaux         as logical   initial ?
    field lCatastrophesNat       as logical   initial ?
    field lResponsabiliteCivile  as logical   initial ?
    field daReceptionAttestation as date                label "dtreg"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
