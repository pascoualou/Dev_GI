/*------------------------------------------------------------------------
File        : caffpre_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table caffpre
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/caffpre.i}
{application/include/error.i}
define variable ghttcaffpre as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phDaprev as handle, output phAffair-num as handle, output phCpt-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/daprev/affair-num/cpt-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'daprev' then phDaprev = phBuffer:buffer-field(vi).
            when 'affair-num' then phAffair-num = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCaffpre private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCaffpre.
    run updateCaffpre.
    run createCaffpre.
end procedure.

procedure setCaffpre:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCaffpre.
    ghttCaffpre = phttCaffpre.
    run crudCaffpre.
    delete object phttCaffpre.
end procedure.

procedure readCaffpre:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table caffpre Saisie affaires previsionnelles
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcDaprev     as character  no-undo.
    define input parameter piAffair-num as integer    no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter table-handle phttCaffpre.
    define variable vhttBuffer as handle no-undo.
    define buffer caffpre for caffpre.

    vhttBuffer = phttCaffpre:default-buffer-handle.
    for first caffpre no-lock
        where caffpre.soc-cd = piSoc-cd
          and caffpre.etab-cd = piEtab-cd
          and caffpre.daprev = pcDaprev
          and caffpre.affair-num = piAffair-num
          and caffpre.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caffpre:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCaffpre no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCaffpre:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table caffpre Saisie affaires previsionnelles
    Notes  : service externe. Critère piAffair-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter pcDaprev     as character  no-undo.
    define input parameter piAffair-num as integer    no-undo.
    define input parameter table-handle phttCaffpre.
    define variable vhttBuffer as handle  no-undo.
    define buffer caffpre for caffpre.

    vhttBuffer = phttCaffpre:default-buffer-handle.
    if piAffair-num = ?
    then for each caffpre no-lock
        where caffpre.soc-cd = piSoc-cd
          and caffpre.etab-cd = piEtab-cd
          and caffpre.daprev = pcDaprev:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caffpre:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each caffpre no-lock
        where caffpre.soc-cd = piSoc-cd
          and caffpre.etab-cd = piEtab-cd
          and caffpre.daprev = pcDaprev
          and caffpre.affair-num = piAffair-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caffpre:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCaffpre no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCaffpre private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhDaprev    as handle  no-undo.
    define variable vhAffair-num    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer caffpre for caffpre.

    create query vhttquery.
    vhttBuffer = ghttCaffpre:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCaffpre:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhDaprev, output vhAffair-num, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first caffpre exclusive-lock
                where rowid(caffpre) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer caffpre:handle, 'soc-cd/etab-cd/daprev/affair-num/cpt-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhDaprev:buffer-value(), vhAffair-num:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer caffpre:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCaffpre private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer caffpre for caffpre.

    create query vhttquery.
    vhttBuffer = ghttCaffpre:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCaffpre:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create caffpre.
            if not outils:copyValidField(buffer caffpre:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCaffpre private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhDaprev    as handle  no-undo.
    define variable vhAffair-num    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define buffer caffpre for caffpre.

    create query vhttquery.
    vhttBuffer = ghttCaffpre:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCaffpre:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhDaprev, output vhAffair-num, output vhCpt-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first caffpre exclusive-lock
                where rowid(Caffpre) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer caffpre:handle, 'soc-cd/etab-cd/daprev/affair-num/cpt-cd: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhDaprev:buffer-value(), vhAffair-num:buffer-value(), vhCpt-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete caffpre no-error.
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

