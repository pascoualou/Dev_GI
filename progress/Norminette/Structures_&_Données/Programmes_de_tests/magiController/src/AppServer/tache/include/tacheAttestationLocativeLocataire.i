/*------------------------------------------------------------------------
File        : tacheAttestationLocative.i
Purpose     : table tache Attestation Locative
Author(s)   : npo  -  30/10/2017
Notes       : Baux Lot 1
derniere revue: 2018/06/25 - phm: 
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheAttestationLocativeLoc
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
    field daValideDu             as date                label "dtdeb"                    
    field daValideAu             as date                label "dtfin"                    
    field iNombreMois            as integer   initial ? label "duree"                    
    field cNumeroPolice          as character initial ? label "ntges"                    
    field cNomCompagnie          as character initial ? label "tpges"                    
    field lBrisdeGlace           as logical   initial ? label "lbdiv#1#@" format "1/0"
    field lTempeteOuragan        as logical   initial ? label "lbdiv#2#@" format "1/0"
    field lVolVandalisme         as logical   initial ? label "lbdiv#3#@" format "1/0"
    field lIncendieExplosion     as logical   initial ? label "lbdiv#4#@" format "1/0"
    field lDegatsDesEaux         as logical   initial ? label "lbdiv#5#@" format "1/0"
    field lCatastrophesNat       as logical   initial ? label "lbdiv#6#@" format "1/0"
    field lResponsabiliteCivile  as logical   initial ? label "lbdiv#7#@" format "1/0"
    field daReceptionAttestation as date                label "dtreg"                    

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
