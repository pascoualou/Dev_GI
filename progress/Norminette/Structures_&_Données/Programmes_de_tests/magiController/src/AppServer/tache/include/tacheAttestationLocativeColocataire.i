/*------------------------------------------------------------------------
File        : tacheAttestationLocative.i
Purpose     : table tache Attestation Locative
Author(s)   : npo  -  30/10/2017
Notes       : Baux Lot 1
derniere revue: 2018/06/25 - phm: 
------------------------------------------------------------------------*/

&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheAttestationLocativeColoc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache           as int64     initial ? label "noita"
    field cTypeContrat           as character initial ? label "tpcon"
    field iNumeroContrat         as int64     initial ? label "nocon"
    field cTypeTache             as character initial ? label "tptac"
    field cTypeRole              as character initial ? label "tpidt"
    field cLibelleTypeRole       as character initial ?
    field iNumeroRole            as int64     initial ? label "noidt"
    field cNomRole               as character initial ?
    field iNumeroTypeAttestation as integer   initial ? label "notac"
    field cLibelleAttestation    as character initial ?
    field daValideDu             as date                label "lbdiv#4#@#dd/mm/yyyy" 
    field daValideAu             as date                label "lbdiv#5#@#dd/mm/yyyy" 
    field iNombreMois            as integer   initial ? label "lbdiv#6#@" 
    field cNumeroPolice          as character initial ? label "lbdiv#1#@" 
    field cNomCompagnie          as character initial ? label "lbdiv#2#@" 
    field lBrisdeGlace           as logical   initial ? label "lbdiv2#1#@" format "1/0"
    field lTempeteOuragan        as logical   initial ? label "lbdiv2#2#@" format "1/0" 
    field lVolVandalisme         as logical   initial ? label "lbdiv2#3#@" format "1/0" 
    field lIncendieExplosion     as logical   initial ? label "lbdiv2#4#@" format "1/0" 
    field lDegatsDesEaux         as logical   initial ? label "lbdiv2#5#@" format "1/0" 
    field lCatastrophesNat       as logical   initial ? label "lbdiv2#6#@" format "1/0" 
    field lResponsabiliteCivile  as logical   initial ? label "lbdiv2#7#@" format "1/0" 
    field daReceptionAttestation as date                label "lbdiv#3#@"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
