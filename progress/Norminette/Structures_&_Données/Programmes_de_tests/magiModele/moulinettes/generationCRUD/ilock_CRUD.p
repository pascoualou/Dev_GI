/*------------------------------------------------------------------------
File        : ilock_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ilock
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ilock.i}
{application/include/error.i}
define variable ghttilock as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phGi-ttyid as handle, output phNomfic as handle, output phClesup as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/gi-ttyid/nomfic/clesup, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'gi-ttyid' then phGi-ttyid = phBuffer:buffer-field(vi).
            when 'nomfic' then phNomfic = phBuffer:buffer-field(vi).
            when 'clesup' then phClesup = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlock private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlock.
    run updateIlock.
    run createIlock.
end procedure.

procedure setIlock:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlock.
    ghttIlock = phttIlock.
    run crudIlock.
    delete object phttIlock.
end procedure.

procedure readIlock:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ilock permet de simuler un lock fichier
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcGi-ttyid as character  no-undo.
    define input parameter pcNomfic   as character  no-undo.
    define input parameter pcClesup   as character  no-undo.
    define input parameter table-handle phttIlock.
    define variable vhttBuffer as handle no-undo.
    define buffer ilock for ilock.

    vhttBuffer = phttIlock:default-buffer-handle.
    for first ilock no-lock
        where ilock.soc-cd = piSoc-cd
          and ilock.etab-cd = piEtab-cd
          and ilock.gi-ttyid = pcGi-ttyid
          and ilock.nomfic = pcNomfic
          and ilock.clesup = pcClesup:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilock:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlock no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlock:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ilock permet de simuler un lock fichier
    Notes  : service externe. Critère pcNomfic = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcGi-ttyid as character  no-undo.
    define input parameter pcNomfic   as character  no-undo.
    define input parameter table-handle phttIlock.
    define variable vhttBuffer as handle  no-undo.
    define buffer ilock for ilock.

    vhttBuffer = phttIlock:default-buffer-handle.
    if pcNomfic = ?
    then for each ilock no-lock
        where ilock.soc-cd = piSoc-cd
          and ilock.etab-cd = piEtab-cd
          and ilock.gi-ttyid = pcGi-ttyid:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilock:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ilock no-lock
        where ilock.soc-cd = piSoc-cd
          and ilock.etab-cd = piEtab-cd
          and ilock.gi-ttyid = pcGi-ttyid
          and ilock.nomfic = pcNomfic:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ilock:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlock no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlock private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhNomfic    as handle  no-undo.
    define variable vhClesup    as handle  no-undo.
    define buffer ilock for ilock.

    create query vhttquery.
    vhttBuffer = ghttIlock:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlock:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhGi-ttyid, output vhNomfic, output vhClesup).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilock exclusive-lock
                where rowid(ilock) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilock:handle, 'soc-cd/etab-cd/gi-ttyid/nomfic/clesup: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhGi-ttyid:buffer-value(), vhNomfic:buffer-value(), vhClesup:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ilock:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlock private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ilock for ilock.

    create query vhttquery.
    vhttBuffer = ghttIlock:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlock:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ilock.
            if not outils:copyValidField(buffer ilock:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlock private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhNomfic    as handle  no-undo.
    define variable vhClesup    as handle  no-undo.
    define buffer ilock for ilock.

    create query vhttquery.
    vhttBuffer = ghttIlock:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlock:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhGi-ttyid, output vhNomfic, output vhClesup).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ilock exclusive-lock
                where rowid(Ilock) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ilock:handle, 'soc-cd/etab-cd/gi-ttyid/nomfic/clesup: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhGi-ttyid:buffer-value(), vhNomfic:buffer-value(), vhClesup:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ilock no-error.
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

