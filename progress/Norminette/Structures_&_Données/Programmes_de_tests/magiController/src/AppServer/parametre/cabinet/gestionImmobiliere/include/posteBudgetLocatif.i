/*------------------------------------------------------------------------
File        : posteBudgetLocatif.i
Purpose     :
Author(s)   : DMI 2018/03/17
Notes       : Paramétrage des budgets locatifs
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttPosteBudgetaire no-undo
    field iNumeroModele       as integer   initial ? label "NoGrp"
    field cTypeEnregistrement as character initial ? label "TpEnr" serialize-hidden // uniquement pour le CRUD
    field iNumeroOrdre        as integer   initial ? label "NoOrd"
    field iNumeroPoste        as integer   initial ? label "NoPost"
    field cLibellePoste       as character initial ? label "LbEnr"
    field cCommentaire        as character initial ? label "LbCom" extent 2  
    field lRubriqueCalculee   as logical   initial ?
    field cListeRubrique      as character initial ?
    field lFiscalite1         as logical   initial ?
    field lFiscalite2         as logical   initial ?
    field lFiscalite3         as logical   initial ?
    field lFiscalite4         as logical   initial ?
    field lbdiv               as character initial ? serialize-hidden // uniquement pour le CRUD
    field fisc-cle            as character initial ? serialize-hidden // uniquement pour le CRUD
    field lNouveau            as logical   initial ? serialize-hidden // Champs interne, pas renvoyé à l'IHM
    field lControle           as logical   initial ?  

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttRubriqueBudgetaire no-undo
    field cTypeEnregistrement as character initial ? label "Tprub" // uniquement pour le CRUD
    field iNumeroModele       as integer   initial ? label "NoGrp"
    field iNumeroPoste        as integer   initial ? label "NoPost"
    field iCodeRubrique       as integer   initial ? label "CdRub"
    field iCodeSousRubrique   as integer   initial ? label "CdSrb"
    field iNumeroTri          as integer   initial ? label "NoTri" serialize-hidden // uniquement pour le CRUD
    field cLibelleRubSsRub    as character initial ?               // Lib rub + Sous Rub

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttAffectRubriqueAnalytique no-undo // TmTbAna - pas de crud
    field iCodeRubrique        as integer   initial ? // "CdRub"
    field cLibelleRubrique     as character initial ? // "LbRub"
    field iCodeSousRubrique    as integer   initial ? // "CdSrb"
    field cLibelleSousRubrique as character initial ? // "LbSrb"
    field lAutorise            as logical   initial ? // "LbUtis" 
    field lSelection           as logical   initial ? // "FgSel"
.
define temp-table ttAffectRubriqueQuittancement no-undo // TmTbQuit - pas de crud
    field iCodeRubrique    as integer   initial ? // "CdRub"
    field cLibelleRubrique as character initial ? // "LbMes"
    field lSelection       as logical   initial ? // "LbChoi"
    field lAutorise        as logical   initial ? // "LbUtis"
.
