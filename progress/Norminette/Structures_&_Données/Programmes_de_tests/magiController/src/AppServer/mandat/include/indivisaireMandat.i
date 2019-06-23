/*------------------------------------------------------------------------
File        : indivisaireMandat.i
Purpose     :
Author(s)   : gga - 2017/09/06
Notes       :
derniere revue: 2018/04/18 - gga: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIndivisaire 
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat       as character initial ?
    field iNumeroContrat     as integer   initial ?
    field iNumeroIndivisaire as integer   initial ? label "noind"
    field iNumeroTiers       as integer   initial ? label "notie"
    field cNomTiers          as character initial ? label "nmind"
    field iNumeroBanque      as integer   initial ? label "cbind"
    field cIban              as character initial ? label "cpind"
    field cLibCdReglCrg      as character initial ? label "mdind"
    field cCdReglCrg         as character initial ? label "cdmrg"
    field iTantieme          as integer   initial ? label "ttInd"
    field cDecom             as character initial ? label "decom"
    field cEdapf             as character initial ? label "edapf"
    field cModEnvCRG         as character initial ? label "mdmad"
    field cLibModEnvCRG      as character initial ? label "lbmad"
    field cLibCdRegltAcc     as character initial ? label "mdacp"
    field cCdRegltAcc        as character initial ? label "cdmra"
    field iBase              as integer   initial ? label "nbden"
    field lTiersActif        as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
