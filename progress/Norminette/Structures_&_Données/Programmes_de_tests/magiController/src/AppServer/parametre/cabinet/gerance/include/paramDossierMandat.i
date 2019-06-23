/*------------------------------------------------------------------------
File        : paramDossierMandat.i
Purpose     : 
Author(s)   : GGA  -  2017/10/27
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttParamDossierMandat
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeTache               as character initial ?
    field lParametrageActif        as logical   initial ?
    field lActivation              as logical   initial ?
    field lAutomatique             as logical   initial ?
    field lReglementChargeAuSyndic as logical   initial ?

    field CRUD as character
.
define temp-table ttParamListeDossierMandat no-undo
    field iNumeroPiece      as integer   initial ?
    field cLibellePiece     as character initial ?
    field lPieceObligatoire as logical   initial ?

    field CRUD as character
.
