/*------------------------------------------------------------------------
File        : iengparc_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iengparc
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iengparc.i}
{application/include/error.i}
define variable ghttiengparc as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNiv-num as handle, output phAna-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/niv-num/ana-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'niv-num' then phNiv-num = phBuffer:buffer-field(vi).
            when 'ana-cd' then phAna-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIengparc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIengparc.
    run updateIengparc.
    run createIengparc.
end procedure.

procedure setIengparc:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIengparc.
    ghttIengparc = phttIengparc.
    run crudIengparc.
    delete object phttIengparc.
end procedure.

procedure readIengparc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iengparc 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv-num as integer    no-undo.
    define input parameter pcAna-cd  as character  no-undo.
    define input parameter table-handle phttIengparc.
    define variable vhttBuffer as handle no-undo.
    define buffer iengparc for iengparc.

    vhttBuffer = phttIengparc:default-buffer-handle.
    for first iengparc no-lock
        where iengparc.soc-cd = piSoc-cd
          and iengparc.etab-cd = piEtab-cd
          and iengparc.niv-num = piNiv-num
          and iengparc.ana-cd = pcAna-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengparc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIengparc no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIengparc:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iengparc 
    Notes  : service externe. Critère piNiv-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter piNiv-num as integer    no-undo.
    define input parameter table-handle phttIengparc.
    define variable vhttBuffer as handle  no-undo.
    define buffer iengparc for iengparc.

    vhttBuffer = phttIengparc:default-buffer-handle.
    if piNiv-num = ?
    then for each iengparc no-lock
        where iengparc.soc-cd = piSoc-cd
          and iengparc.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengparc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iengparc no-lock
        where iengparc.soc-cd = piSoc-cd
          and iengparc.etab-cd = piEtab-cd
          and iengparc.niv-num = piNiv-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iengparc:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIengparc no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIengparc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define buffer iengparc for iengparc.

    create query vhttquery.
    vhttBuffer = ghttIengparc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIengparc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iengparc exclusive-lock
                where rowid(iengparc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iengparc:handle, 'soc-cd/etab-cd/niv-num/ana-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iengparc:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIengparc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iengparc for iengparc.

    create query vhttquery.
    vhttBuffer = ghttIengparc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIengparc:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iengparc.
            if not outils:copyValidField(buffer iengparc:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIengparc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define buffer iengparc for iengparc.

    create query vhttquery.
    vhttBuffer = ghttIengparc:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIengparc:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iengparc exclusive-lock
                where rowid(Iengparc) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iengparc:handle, 'soc-cd/etab-cd/niv-num/ana-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iengparc no-error.
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

