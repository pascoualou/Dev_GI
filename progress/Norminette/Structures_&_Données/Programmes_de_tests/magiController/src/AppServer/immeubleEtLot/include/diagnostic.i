/*------------------------------------------------------------------------
File        : diagnostic.i
Purpose     : 
Author(s)   : LGI/NPO - 2016/12/13
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttDiagnosticEtude no-undo
    field iNumeroImmeuble           as integer   initial ?
    field iNumeroLot                as integer   initial ?
    field iNumeroTache              as int64     initial ? label "noita"
    field cTypeContrat              as character initial ? label "tpcont"
    field iNumeroContrat            as int64     initial ? label "nocon"
    field cCodeTypeTache            as character initial ? label "tptqc"
    field iChronoTache              as integer   initial ? label "notac"
    field cCodeDisposition          as character initial ?
    field cTypeDiagnosticEtude      as character initial ?
    field cLibelleDisposition       as character initial ?
    field cCodeBatiment             as character initial ?
    field lPrivatif                 as logical   initial ?
    field cCodeOrganisme            as character initial ? label "cdhon"
    field cLibelleOrganisme         as character initial ? label "utreg"
    field daDateRecherche           as datetime
    field cCodeResultatRecherche    as character initial ?
    field cLibelleResultatRecherche as character initial ?
    field daDatePrevueDT            as datetime
    field daDateRealiseeDT          as datetime
    field daDateControle            as datetime
    field lControle                 as logical   initial ?
    field lSurveillance             as logical   initial ?
    field lTravaux                  as logical   initial ?
    field cCommentaire              as character initial ?
    field cEtiquetteEnergie         as character initial ?
    field iValeurEtiquetteEnergie   as integer   initial ?
    field cEtiquetteClimat          as character initial ?
    field iValeurEtiquetteClimat    as integer   initial ?
    field iNumeroFiche              as integer   initial ?
    field daDateCreation            as date                label "dtcsy"

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    index primaire iNumeroImmeuble
.
