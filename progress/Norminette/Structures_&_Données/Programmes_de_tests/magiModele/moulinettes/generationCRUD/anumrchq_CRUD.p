/*------------------------------------------------------------------------
File        : anumrchq_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table anumrchq
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/anumrchq.i}
{application/include/error.i}
define variable ghttanumrchq as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCptg-cd as handle, output phDadeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cptg-cd/dadeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cptg-cd' then phCptg-cd = phBuffer:buffer-field(vi).
            when 'dadeb' then phDadeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAnumrchq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAnumrchq.
    run updateAnumrchq.
    run createAnumrchq.
end procedure.

procedure setAnumrchq:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAnumrchq.
    ghttAnumrchq = phttAnumrchq.
    run crudAnumrchq.
    delete object phttAnumrchq.
end procedure.

procedure readAnumrchq:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table anumrchq 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcCptg-cd as character  no-undo.
    define input parameter pdaDadeb   as date       no-undo.
    define input parameter table-handle phttAnumrchq.
    define variable vhttBuffer as handle no-undo.
    define buffer anumrchq for anumrchq.

    vhttBuffer = phttAnumrchq:default-buffer-handle.
    for first anumrchq no-lock
        where anumrchq.soc-cd = piSoc-cd
          and anumrchq.cptg-cd = pcCptg-cd
          and anumrchq.dadeb = pdaDadeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer anumrchq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAnumrchq no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAnumrchq:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table anumrchq 
    Notes  : service externe. Critère pcCptg-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcCptg-cd as character  no-undo.
    define input parameter table-handle phttAnumrchq.
    define variable vhttBuffer as handle  no-undo.
    define buffer anumrchq for anumrchq.

    vhttBuffer = phttAnumrchq:default-buffer-handle.
    if pcCptg-cd = ?
    then for each anumrchq no-lock
        where anumrchq.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer anumrchq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each anumrchq no-lock
        where anumrchq.soc-cd = piSoc-cd
          and anumrchq.cptg-cd = pcCptg-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer anumrchq:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAnumrchq no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAnumrchq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCptg-cd    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer anumrchq for anumrchq.

    create query vhttquery.
    vhttBuffer = ghttAnumrchq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAnumrchq:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCptg-cd, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first anumrchq exclusive-lock
                where rowid(anumrchq) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer anumrchq:handle, 'soc-cd/cptg-cd/dadeb: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhCptg-cd:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer anumrchq:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAnumrchq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer anumrchq for anumrchq.

    create query vhttquery.
    vhttBuffer = ghttAnumrchq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAnumrchq:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create anumrchq.
            if not outils:copyValidField(buffer anumrchq:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAnumrchq private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCptg-cd    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer anumrchq for anumrchq.

    create query vhttquery.
    vhttBuffer = ghttAnumrchq:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAnumrchq:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCptg-cd, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first anumrchq exclusive-lock
                where rowid(Anumrchq) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer anumrchq:handle, 'soc-cd/cptg-cd/dadeb: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhCptg-cd:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete anumrchq no-error.
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

