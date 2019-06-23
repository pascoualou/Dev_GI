/*------------------------------------------------------------------------
File        : equipementBien.i
Purpose     : 
Author(s)   : KANTENA - 2016/12/06
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttEquipementBien no-undo
    field iNumeroOrdre              as integer   initial ? label 'equipements.lbdiv2'
    field cTypeBien                 as character initial ? label 'cTypeBien'
    field iNumeroBien               as int64     initial ? label 'iNumeroBien'
    field cCodeEquipement           as character initial ? label 'cCodeEquipement'
    field cDesignationEquipement    as character initial ? label 'equipements.cDesignation'
    field iNombreEquipement         as integer   initial ? label 'iNombre'
    field lYenA                     as logical   initial ? label 'fgOuiNon'
    field cValeur                   as character initial ? label 'cValeur'
    field cNumeroCompteFournisseur  as character initial ? label 'cEntreprise'
    field cNomFournisseur           as character initial ? label 'ifour.nom'
    field cNumeroContratMaintenance as character initial ? label 'cContratMaintenance'
    field cRefContratMaintenance    as character initial ? label 'ctrat.noree'
    field cCommentaire              as character initial ? label 'cCommentaire'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
    index primaire iNumeroOrdre
.
define temp-table ttEquipement no-undo
    field cCodeEquipement        as character initial ? label 'cCodeEquipement'
    field cDesignationEquipement as character initial ? label 'cDesignation'
    field lNombre                as logical   initial ? label 'fgNombre'
    field lValeur                as logical   initial ? label 'fgValeur'
    field lOuiNon                as logical   initial ? label 'fgOuiNon'
    field cListeValeur           as character initial ? label 'cListeValeurs'

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttFichierJointEquipement no-undo serialize-name "ttFichierJoint"
    field cTypeBien               as character
    field iNumeroBien             as int64
    field cNomFichier             as character
    field iIDFichier              as int64
    field cCodeEquipement         as character
    field cTypeIdentifiant        as character
    field cCommentaire            as character
    field cRepertoire             as character
    field cChemin                 as character
    field daDateCreation          as date
    field daDateDebut             as date
    field daDateFin               as date
    field iNumeroDocument         as int64
    field iNumeroModeleDocument   as integer 
    field cLibelleModeleDocument  as character
    field cLibelleCanevasDocument as character

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
