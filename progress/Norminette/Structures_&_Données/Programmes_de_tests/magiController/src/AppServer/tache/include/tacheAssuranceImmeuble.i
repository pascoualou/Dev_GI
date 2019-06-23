/*------------------------------------------------------------------------
File        : tacheAssuranceImmeuble.i
Purpose     : table liste assurance immeuble mandat
Author(s)   : GGA  -  2017/11/24
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttObjetAssImm
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat         as character initial ? label "tpcon"
    field iNumeroContrat       as int64     initial ? label "nocon"
    field cNumeroPolice        as character initial ? label "noree"
    field daSignature          as date                label "dtsig"
    field cLieuSignature       as character initial ? label "lisig"
    field daInitiale           as date                label "dtini"
    field daDebut              as date                label "dtdeb"         //effet le
    field daFin                as date                label "dtfin"         //expire le
    field iDuree               as integer   initial ? label "nbdur"         //duree
    field cUniteDuree          as character initial ? label "cddur"
    field cLibUniteDuree       as character initial ?
    field iDelaiPreavis        as integer   initial ? label "nbres"         //delai de preavis
    field cUnitePreavis        as character initial ? label "utres"
    field cLibUnitePreavis     as character initial ?
    field lTaciteReconduction  as logical   initial ? label "tpren" format "00001/00000"         //tacite reconduction
    field cTypeActe            as character initial ? label "tpact"         //type d'acte
    field cLibTypeActe         as character initial ?
    field cNatureContrat       as character initial ? label "ntcon"         //nature du contrat 
    field cLibNatureContrat    as character initial ?
    field lResiliation         as logical   initial ?
    field daResiliation        as date                label "dtree"         //le
    field cMotifResiliation    as character initial ? label "tpfin"         //motif
    field cLibMotifResiliation as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
 define temp-table ttBatimentAssImm no-undo
    field cTypeContrat       as character initial ?
    field iNumeroContrat     as int64     initial ?
    field iNumeroBatiment    as integer   initial ?
    field cCodeBatiment      as character initial ?
    field cNomBatiment       as character initial ?
    field cAdresseBatiment   as character initial ?
    field lSelectionBatiment as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttGarantieAssImm no-undo
    field cTypeContrat              as character initial ?
    field iNumeroContrat            as int64     initial ?
    field iNumeroTache              as int64     initial ?
    field iChronoTache              as integer   initial ?
    field lReconstructionValeurNeuf as logical   initial ?   //HwTglRec 
    field lLimiteCapital            as logical   initial ?   //HwTglCap 
    field dValLimiteCapital         as decimal   initial ?   //HwFilCap

    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
define temp-table ttTypeGarantieAssImm no-undo
    field cCodeTypeGarantie as character initial ?
    field cLibTypeGarantie  as character initial ?
    field lGarantieActive   as logical   initial ?
.
define temp-table ttAttestationAssImm no-undo
    field cTypeContrat       as character initial ? label "tpcon"
    field iNumeroContrat     as int64     initial ? label "nocon"
    field cTypeTache         as character initial ? label "tptac"
    field iNumeroAttestation as integer   initial ? label "noatt"
    field daReception        as date                label "dtrcp"
    field daDebut            as date                label "dtdeb"
    field daFin              as date                label "dtfin"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
