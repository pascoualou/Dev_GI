/*------------------------------------------------------------------------
File        : modeleBudgetLocatif.i
Purpose     :
Author(s)   : DMI 2018/03/17
Notes       : Paramétrage des modèles de budgets locatifs
derniere revue: 2018/04/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttModeleBudgetaire
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroModele       as integer   initial ? label "noGrp"
    field cLibelleModele      as character initial ? label "lbEnr"
    field cCommentaire        as character initial ? label "lbCom" extent 2
    field cTypeEnregistrement as character initial ? label "tpEnr"  serialize-hidden // uniquement pour le CRUD
    field iNumeroPoste        as integer   initial ? label "noPost" serialize-hidden // uniquement pour le CRUD
    field lControle           as logical   initial ?
    field dtTimestamp         as datetime
    field CRUD                as character
    field rRowid              as rowid
.
