/*------------------------------------------------------------------------
File        : rgpbl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table rgpbl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}       // Doit être positionnée juste après using
define variable ghttrgpbl as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNogrp as handle, output phNopost as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nogrp/nopost, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nogrp'  then phNogrp = phBuffer:buffer-field(vi).
            when 'nopost' then phNopost = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRgpbl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRgpbl.
    run updateRgpbl.
    run createRgpbl.
end procedure.

procedure setRgpbl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRgpbl.
    ghttRgpbl = phttRgpbl.
    run crudRgpbl.
    delete object phttRgpbl.
end procedure.

procedure readRgpbl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table rgpbl Référence des groupes et postes budgétaires du budget locatif
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNogrp  as integer  no-undo.
    define input parameter piNopost as integer  no-undo.
    define input parameter table-handle phttRgpbl.

    define variable vhttBuffer as handle no-undo.
    define buffer rgpbl for rgpbl.

    vhttBuffer = phttRgpbl:default-buffer-handle.
    for first rgpbl no-lock
        where rgpbl.nogrp  = piNogrp
          and rgpbl.nopost = piNopost:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rgpbl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRgpbl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRgpbl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rgpbl Référence des groupes et postes budgétaires du budget locatif
    Notes  : service externe. Critère piNogrp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNogrp  as integer  no-undo.
    define input parameter table-handle phttRgpbl.

    define variable vhttBuffer as handle  no-undo.
    define buffer rgpbl for rgpbl.

    vhttBuffer = phttRgpbl:default-buffer-handle.
    if piNogrp = ?                      // fonctionnellement, aucun intérêt.
    then for each rgpbl no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rgpbl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each rgpbl no-lock
        where rgpbl.nogrp = piNogrp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rgpbl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRgpbl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure getRgpblModele:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rgpbl - Modele budgétaires
    Notes  : service externe. Critère piNogrp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroModele as integer no-undo.
    define input parameter table-handle phttRgpbl.
    
    ghttRgpbl = phttRgpbl.
    run getRgpblTypeEnregistrement("G", piNumeroModele, ?).
    delete object phttRgpbl.

end procedure.

procedure getRgpblPoste:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rgpbl - Postes d'une modele budgétaire
    Notes  : service externe. Critère piNogrp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroModele as integer no-undo.
    define input parameter piNumeroPoste  as integer no-undo.
    define input parameter table-handle phttRgpbl.

    ghttRgpbl = phttRgpbl.
    run getRgpblTypeEnregistrement("P", piNumeroModele, piNumeroPoste).
    delete object phttRgpbl.

end procedure.

procedure getRgpblTypeEnregistrement private:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table rgpbl par type enregistrement
    Notes  : service externe. Critère piNogrp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeEnregistrement as character no-undo.
    define input parameter piNumeroGroupe       as integer   no-undo.
    define input parameter piNumeroPoste        as integer   no-undo.
       
    define variable vhttBuffer as handle  no-undo.
    define buffer rgpbl for rgpbl.

    vhttBuffer = ghttRgpbl:default-buffer-handle.
    if piNumeroGroupe = ? then for each rgpbl no-lock
        where rgpbl.tpenr  = pcTypeEnregistrement
          and rgpbl.nopost = (if piNumeroPoste  = ? then rgpbl.nopost else piNumeroPoste):
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rgpbl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else if piNumeroPoste = ? then for each rgpbl no-lock
        where rgpbl.tpenr = pcTypeEnregistrement
          and rgpbl.nogrp = (if piNumeroGroupe = ? then rgpbl.nogrp else piNumeroGroupe): 
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rgpbl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each rgpbl no-lock
        where rgpbl.tpenr  = pcTypeEnregistrement
          and rgpbl.nogrp  = piNumeroGroupe
          and rgpbl.nopost = piNumeroPoste:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer rgpbl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRgpbl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define variable vhNopost   as handle  no-undo.
    define buffer rgpbl for rgpbl.

    create query vhttquery.
    vhttBuffer = ghttRgpbl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRgpbl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNogrp, output vhNopost).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rgpbl exclusive-lock
                where rowid(rgpbl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rgpbl:handle, 'nogrp/nopost: ', substitute('&1/&2', vhNogrp:buffer-value(), vhNopost:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer rgpbl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRgpbl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer rgpbl for rgpbl.

    create query vhttquery.
    vhttBuffer = ghttRgpbl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRgpbl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create rgpbl.
            if not outils:copyValidField(buffer rgpbl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRgpbl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define variable vhNopost   as handle  no-undo.
    define buffer rgpbl for rgpbl.

    create query vhttquery.
    vhttBuffer = ghttRgpbl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRgpbl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNogrp, output vhNopost).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first rgpbl exclusive-lock
                where rowid(Rgpbl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer rgpbl:handle, 'nogrp/nopost: ', substitute('&1/&2', vhNogrp:buffer-value(), vhNopost:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete rgpbl no-error.
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
