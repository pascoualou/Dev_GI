/*------------------------------------------------------------------------
File        : icontacl_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table icontacl
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/icontacl.i}
{application/include/error.i}
define variable ghtticontacl as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phCli-cle as handle, output phNumero as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/cli-cle/numero, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'cli-cle' then phCli-cle = phBuffer:buffer-field(vi).
            when 'numero' then phNumero = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIcontacl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIcontacl.
    run updateIcontacl.
    run createIcontacl.
end procedure.

procedure setIcontacl:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIcontacl.
    ghttIcontacl = phttIcontacl.
    run crudIcontacl.
    delete object phttIcontacl.
end procedure.

procedure readIcontacl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table icontacl 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcCli-cle as character  no-undo.
    define input parameter piNumero  as integer    no-undo.
    define input parameter table-handle phttIcontacl.
    define variable vhttBuffer as handle no-undo.
    define buffer icontacl for icontacl.

    vhttBuffer = phttIcontacl:default-buffer-handle.
    for first icontacl no-lock
        where icontacl.soc-cd = piSoc-cd
          and icontacl.cli-cle = pcCli-cle
          and icontacl.numero = piNumero:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icontacl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcontacl no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIcontacl:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table icontacl 
    Notes  : service externe. Critère pcCli-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter pcCli-cle as character  no-undo.
    define input parameter table-handle phttIcontacl.
    define variable vhttBuffer as handle  no-undo.
    define buffer icontacl for icontacl.

    vhttBuffer = phttIcontacl:default-buffer-handle.
    if pcCli-cle = ?
    then for each icontacl no-lock
        where icontacl.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icontacl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each icontacl no-lock
        where icontacl.soc-cd = piSoc-cd
          and icontacl.cli-cle = pcCli-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icontacl:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcontacl no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIcontacl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhNumero    as handle  no-undo.
    define buffer icontacl for icontacl.

    create query vhttquery.
    vhttBuffer = ghttIcontacl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIcontacl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle, output vhNumero).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icontacl exclusive-lock
                where rowid(icontacl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icontacl:handle, 'soc-cd/cli-cle/numero: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value(), vhNumero:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer icontacl:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIcontacl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer icontacl for icontacl.

    create query vhttquery.
    vhttBuffer = ghttIcontacl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIcontacl:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create icontacl.
            if not outils:copyValidField(buffer icontacl:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIcontacl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhCli-cle    as handle  no-undo.
    define variable vhNumero    as handle  no-undo.
    define buffer icontacl for icontacl.

    create query vhttquery.
    vhttBuffer = ghttIcontacl:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIcontacl:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhCli-cle, output vhNumero).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icontacl exclusive-lock
                where rowid(Icontacl) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icontacl:handle, 'soc-cd/cli-cle/numero: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhCli-cle:buffer-value(), vhNumero:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete icontacl no-error.
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

