/*------------------------------------------------------------------------
File        : cecrsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cecrsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/07/25 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}         // Doit être positionnée juste après using
define variable ghttcecrsai as handle no-undo.      // le handle de la temp table à mettre à jour

function contientChampsTiers returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: Indique si la temp table contient les champs nécessaires 
             à la récupération du libellé du tiers
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    define variable vlLibelleTiers as logical no-undo.

    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cLibelleTiers' then vlLibelleTiers = true.
        end case.
    end.
    return vlLibelleTiers.

end function.

function contientChampsReglement returns logical private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: Indique si la temp table contient les champs nécessaires 
             à la récupération du libellé du règlement
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    define variable vlLibelleReglement as logical no-undo.

    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cLibelleReglement' then vlLibelleReglement = true.
        end case.
    end.
    return vlLibelleReglement.

end function.

function getLibelleTiers returns character private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: Récupération du libelle du compte
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer csscpt for csscpt.

    for first csscpt no-lock
        where csscpt.soc-cd     = phBuffer::iCodeSociete
          and csscpt.etab-cd    = phBuffer::iCodeEtablissement
          and csscpt.sscoll-cle = phBuffer::cCollectifTiers
          and csscpt.cpt-cd     = phBuffer::cCompteTiers:
        return csscpt.lib.
    end.
    return "".

end function.

function getLibelleReglement returns character private(phBuffer as handle):
    /*------------------------------------------------------------------------------
    Purpose: Récupération du libellé du mode de règlement 
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer iregl for iregl.

    for first iregl no-lock
         where iregl.soc-cd  = phBuffer::iCodeSociete
           and iregl.regl-cd = phBuffer::iCodeModeReglement:
        return iregl.lib.
    end.
    return "".

end function.

function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phJou-cd as handle, output phPrd-cd as handle, output phPrd-num as handle, output phPiece-compta as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-compta, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd'       then phSoc-cd  = phBuffer:buffer-field(vi).
            when 'etab-cd'      then phEtab-cd = phBuffer:buffer-field(vi).
            when 'jou-cd'       then phJou-cd  = phBuffer:buffer-field(vi).
            when 'prd-cd'       then phPrd-cd  = phBuffer:buffer-field(vi).
            when 'prd-num'      then phPrd-num = phBuffer:buffer-field(vi).
            when 'piece-compta' then phPiece-compta = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCecrsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCecrsai.
    run updateCecrsai.
    run createCecrsai.
end procedure.

procedure setCecrsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCecrsai.
    ghttCecrsai = phttCecrsai.
    run crudCecrsai.
    delete object phttCecrsai.
end procedure.

procedure readCecrsaiPieceInterne:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cecrsai Entete de gestion des ecritures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer   no-undo.
    define input parameter piEtab-cd  as integer   no-undo.
    define input parameter pcJou-cd   as character no-undo.
    define input parameter piPrd-cd   as integer   no-undo.
    define input parameter piPrd-num  as integer   no-undo.
    define input parameter piPiece    as integer   no-undo.
    define input parameter table-handle phttCecrsai.

    define variable vhttBuffer as handle no-undo.
    define buffer cecrsai for cecrsai.

    vhttBuffer = phttCecrsai:default-buffer-handle.
    for first cecrsai no-lock
        where cecrsai.soc-cd    = piSoc-cd
          and cecrsai.etab-cd   = piEtab-cd
          and cecrsai.jou-cd    = pcJou-cd
          and cecrsai.prd-cd    = piPrd-cd
          and cecrsai.prd-num   = piPrd-num
          and cecrsai.piece-int = piPiece:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrsai:handle, vhttBuffer).  // copy table physique vers temp-table
        assign
            vhttBuffer::cLibelleTiers         = getLibelleTiers(vhttBuffer)
            vhttBuffer::cLibelleModeReglement = getLibelleReglement(vhttBuffer)
        no-error.
    end.
    delete object phttCecrsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure readCecrsaiPieceCompta:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cecrsai Entete de gestion des ecritures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer   no-undo.
    define input parameter piEtab-cd  as integer   no-undo.
    define input parameter pcJou-cd   as character no-undo.
    define input parameter piPrd-cd   as integer   no-undo.
    define input parameter piPrd-num  as integer   no-undo.
    define input parameter piPiece    as integer   no-undo.
    define input parameter table-handle phttCecrsai.

    define variable vhttBuffer as handle no-undo.
    define buffer cecrsai for cecrsai.

    vhttBuffer = phttCecrsai:default-buffer-handle.
    for first cecrsai no-lock
        where cecrsai.soc-cd       = piSoc-cd
          and cecrsai.etab-cd      = piEtab-cd
          and cecrsai.jou-cd       = pcJou-cd
          and cecrsai.prd-cd       = piPrd-cd
          and cecrsai.prd-num      = piPrd-num
          and cecrsai.piece-compta = piPiece:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrsai:handle, vhttBuffer).  // copy table physique vers temp-table
        assign
            vhttBuffer::cLibelleTiers         = getLibelleTiers(vhttBuffer)
            vhttBuffer::cLibelleModeReglement = getLibelleReglement(vhttBuffer)
        no-error.
    end.
    delete object phttCecrsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.


procedure getCecrsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cecrsai Entete de gestion des ecritures
    Notes  : service externe. Critère piPrd-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer   no-undo.
    define input parameter piEtab-cd as integer   no-undo.
    define input parameter pcJou-cd  as character no-undo.
    define input parameter piPrd-cd  as integer   no-undo.
    define input parameter piPrd-num as integer   no-undo.
    define input parameter table-handle phttCecrsai.

    define variable vhttBuffer                as handle  no-undo.
    define variable vlContientChampsTiers     as logical no-undo.
    define variable vlContientChampsReglement as logical no-undo.

    define buffer cecrsai for cecrsai.

     assign
        vhttBuffer                = phttCecrsai:default-buffer-handle
        vlContientChampsTiers     = contientChampsTiers(vhttBuffer)
        vlContientChampsReglement = contientChampsReglement(vhttBuffer)
    .
    if piPrd-num = ?
    then for each cecrsai no-lock
        where cecrsai.soc-cd  = piSoc-cd
          and cecrsai.etab-cd = piEtab-cd
          and cecrsai.jou-cd  = pcJou-cd
          and cecrsai.prd-cd  = piPrd-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrsai:handle, vhttBuffer).  // copy table physique vers temp-table
        if vlContientChampsTiers     then vhttBuffer::cLibelleTiers = getLibelleTiers(vhttBuffer).
        if vlContientChampsReglement then vhttBuffer::cLibelleModeReglement = getLibelleReglement(vhttBuffer).
    end.
    else for each cecrsai no-lock
        where cecrsai.soc-cd  = piSoc-cd
          and cecrsai.etab-cd = piEtab-cd
          and cecrsai.jou-cd  = pcJou-cd
          and cecrsai.prd-cd  = piPrd-cd
          and cecrsai.prd-num = piPrd-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cecrsai:handle, vhttBuffer).  // copy table physique vers temp-table
        if vlContientChampsTiers     then vhttBuffer::cLibelleTiers = getLibelleTiers(vhttBuffer).
        if vlContientChampsReglement then vhttBuffer::cLibelleModeReglement = getLibelleReglement(vhttBuffer).
    end.
    delete object phttCecrsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCecrsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery      as handle  no-undo.
    define variable vhttBuffer     as handle  no-undo.
    define variable vhSoc-cd       as handle  no-undo.
    define variable vhEtab-cd      as handle  no-undo.
    define variable vhJou-cd       as handle  no-undo.
    define variable vhPrd-cd       as handle  no-undo.
    define variable vhPrd-num      as handle  no-undo.
    define variable vhPiece-compta as handle  no-undo.
    define buffer cecrsai for cecrsai.

    create query vhttquery.
    vhttBuffer = ghttCecrsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCecrsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cecrsai exclusive-lock
                where rowid(cecrsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cecrsai:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cecrsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCecrsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cecrsai for cecrsai.

    create query vhttquery.
    vhttBuffer = ghttCecrsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCecrsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cecrsai.
            if not outils:copyValidField(buffer cecrsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCecrsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery      as handle  no-undo.
    define variable vhttBuffer     as handle  no-undo.
    define variable vhSoc-cd       as handle  no-undo.
    define variable vhEtab-cd      as handle  no-undo.
    define variable vhJou-cd       as handle  no-undo.
    define variable vhPrd-cd       as handle  no-undo.
    define variable vhPrd-num      as handle  no-undo.
    define variable vhPiece-compta as handle  no-undo.
    define buffer cecrsai for cecrsai.

    create query vhttquery.
    vhttBuffer = ghttCecrsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCecrsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhJou-cd, output vhPrd-cd, output vhPrd-num, output vhPiece-compta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cecrsai exclusive-lock
                where rowid(Cecrsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cecrsai:handle, 'soc-cd/etab-cd/jou-cd/prd-cd/prd-num/piece-compta: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhJou-cd:buffer-value(), vhPrd-cd:buffer-value(), vhPrd-num:buffer-value(), vhPiece-compta:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cecrsai no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

