/*------------------------------------------------------------------------
File        : repaqbl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table repaqbl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/06/18 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}         // Doit être positionnée juste après using
define variable ghttrepaqbl as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phNogrp as handle, output phNopost as handle, output phTprub as handle, output phCdrub as handle, output phCdsrb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur nogrp/nopost/tprub/cdrub/cdsrb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'nogrp'  then phNogrp  = phBuffer:buffer-field(vi).
            when 'nopost' then phNopost = phBuffer:buffer-field(vi).
            when 'tprub'  then phTprub  = phBuffer:buffer-field(vi).
            when 'cdrub'  then phCdrub  = phBuffer:buffer-field(vi).
            when 'cdsrb'  then phCdsrb  = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudRepaqbl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRepaqbl.
    run updateRepaqbl.
    run createRepaqbl.
end procedure.

procedure setRepaqbl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRepaqbl.
    ghttRepaqbl = phttRepaqbl.
    run crudRepaqbl.
    delete object phttRepaqbl.
end procedure.

procedure readRepaqbl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table repaqbl Répartition des rubriques analytique et de quittancement (dans les groupes et postes budgétaires) pour la présentation du Budget Locatif
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNogrp  as integer   no-undo.
    define input parameter piNopost as integer   no-undo.
    define input parameter pcTprub  as character no-undo.
    define input parameter piCdrub  as integer   no-undo.
    define input parameter piCdsrb  as integer   no-undo.
    define input parameter table-handle phttRepaqbl.

    define variable vhttBuffer as handle no-undo.
    define buffer repaqbl for repaqbl.

    vhttBuffer = phttRepaqbl:default-buffer-handle.
    for first repaqbl no-lock
        where repaqbl.nogrp  = piNogrp
          and repaqbl.nopost = piNopost
          and repaqbl.tprub  = pcTprub
          and repaqbl.cdrub  = piCdrub
          and repaqbl.cdsrb  = piCdsrb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer repaqbl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRepaqbl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRepaqbl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table repaqbl Répartition des rubriques analytique et de quittancement (dans les groupes et postes budgétaires) pour la présentation du Budget Locatif
    Notes  : service externe. Critère piCdrub = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piNogrp  as integer   no-undo.
    define input parameter piNopost as integer   no-undo.
    define input parameter pcTprub  as character no-undo.
    define input parameter piCdrub  as integer   no-undo.
    define input parameter table-handle phttRepaqbl.

    define variable vhttBuffer as handle  no-undo.
    define buffer repaqbl for repaqbl.

    vhttBuffer = phttRepaqbl:default-buffer-handle.
    if piCdrub = ?
    then for each repaqbl no-lock
        where repaqbl.nogrp  = piNogrp
          and repaqbl.nopost = piNopost
          and repaqbl.tprub  = pcTprub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer repaqbl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each repaqbl no-lock
        where repaqbl.nogrp  = piNogrp
          and repaqbl.nopost = piNopost
          and repaqbl.tprub  = pcTprub
          and repaqbl.cdrub  = piCdrub:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer repaqbl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttRepaqbl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRepaqbl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define variable vhNopost   as handle  no-undo.
    define variable vhTprub    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define buffer repaqbl for repaqbl.

    create query vhttquery.
    vhttBuffer = ghttRepaqbl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRepaqbl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNogrp, output vhNopost, output vhTprub, output vhCdrub, output vhCdsrb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first repaqbl exclusive-lock
                where rowid(repaqbl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer repaqbl:handle, 'nogrp/nopost/tprub/cdrub/cdsrb: ', substitute('&1/&2/&3/&4/&5', vhNogrp:buffer-value(), vhNopost:buffer-value(), vhTprub:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer repaqbl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRepaqbl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer repaqbl for repaqbl.

    create query vhttquery.
    vhttBuffer = ghttRepaqbl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRepaqbl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create repaqbl.
            if not outils:copyValidField(buffer repaqbl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRepaqbl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhNogrp    as handle  no-undo.
    define variable vhNopost   as handle  no-undo.
    define variable vhTprub    as handle  no-undo.
    define variable vhCdrub    as handle  no-undo.
    define variable vhCdsrb    as handle  no-undo.
    define buffer repaqbl for repaqbl.

    create query vhttquery.
    vhttBuffer = ghttRepaqbl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRepaqbl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNogrp, output vhNopost, output vhTprub, output vhCdrub, output vhCdsrb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first repaqbl exclusive-lock
                where rowid(Repaqbl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer repaqbl:handle, 'nogrp/nopost/tprub/cdrub/cdsrb: ', substitute('&1/&2/&3/&4/&5', vhNogrp:buffer-value(), vhNopost:buffer-value(), vhTprub:buffer-value(), vhCdrub:buffer-value(), vhCdsrb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete repaqbl no-error.
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
