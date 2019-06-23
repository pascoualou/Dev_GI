/*------------------------------------------------------------------------
File        : tachePNO.i
Purpose     : table PNO
Author(s)   : DM - 2017/12/05
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttTachePNO no-undo serialize-name 'ttTachePNO'
    field cGereParCabinetMandant as character initial ? label "tpges" 
    field iNumeroMandat          as int64     initial ? label "nocon"
    field lReport                as logical   initial ?  

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttlotPNO no-undo
    field iNumeroMandat        as int64     initial ?
    field iNumeroLocal         as integer   initial ?
    field iNumeroLot           as integer   initial ?
    field iNumeroBail          as int64     initial ?
    field iNumeroUL            as integer   initial ?
    field cNatureUL            as character initial ?
    field iNumeroGarantie      as integer   initial ? label "nogar"
    field iNumeroBareme        as integer   initial ? label "nobar"
    field lPrincipal           as logical   initial ? 
    field iNumeroCompo         as integer   initial ? 
    field cNomLocataire        as character initial ? 
    field cLibelleNatureLot    as character initial ? 
    field cLibelleNatureBail   as character initial ? 
    field cLibelleUL           as character initial ? 
    field cLibelleGarantie     as character initial ? 
    field cLibelleBareme       as character initial ? 
    field cNumeroAssurance     as character initial ? label "numcontrat"
    field daDebutAssurance     as date                label "dtdebass"
    field daFinAssurance       as date                label "dtfinass"
    field daPremiereCotisation as date
    field daCotisation         as date                label "dtcotis1"
    field dMontantCotisation   as decimal   initial ? 
    field daVente              as date
    field lCotisationTraitee   as logical   initial ? label "Fgtrtcotis1"
    field cSurfaceLot          as character initial ? 
    field lControle            as logical   initial ? 

    field CRUD        as character 
    field dtTimestamp as datetime
    field rRowid      as rowid
.
define temp-table ttBareme no-undo
    field iNumeroBareme      as integer   initial ? // cCode
    field cLibelleBareme     as character initial ? // cLibelle
    field iNumeroGarantie    as integer   initial ?
    field cTypeBareme        as character initial ? // cType
    field cNatureUL          as character initial ? 
    field cLibelleTypeBareme as character initial ? // cLibelleType
    field dCotisation        as decimal   initial ? // mtcot
    field dHonoraires        as decimal   initial ? // txhon 
    field dResultant         as decimal   initial ? // mttot 
    field ctypeSaisie        as character initial ?
    field cProrata1erePrime  as character initial ?
.
define temp-table ttGarantie no-undo
    field iNumeroGarantie          as integer   initial ?
    field cLibelleGarantie         as character initial ?
    field cCodePeriodicitePrime    as character initial ?
    field cLibellePeriodicitePrime as character initial ?
    field cContrat                 as character initial ?
    field dadebut                  as date
    field daFin                    as date
    field cNumeroAssurance         as character initial ?
.
