/*------------------------------------------------------------------------
File        : icontacf_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table icontacf
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/icontacf.i}
{application/include/error.i}
define variable ghtticontacf as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFour-cle as handle, output phNumero as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/four-cle/numero, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'four-cle' then phFour-cle = phBuffer:buffer-field(vi).
            when 'numero' then phNumero = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIcontacf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIcontacf.
    run updateIcontacf.
    run createIcontacf.
end procedure.

procedure setIcontacf:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIcontacf.
    ghttIcontacf = phttIcontacf.
    run crudIcontacf.
    delete object phttIcontacf.
end procedure.

procedure readIcontacf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table icontacf 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcFour-cle as character  no-undo.
    define input parameter piNumero   as integer    no-undo.
    define input parameter table-handle phttIcontacf.
    define variable vhttBuffer as handle no-undo.
    define buffer icontacf for icontacf.

    vhttBuffer = phttIcontacf:default-buffer-handle.
    for first icontacf no-lock
        where icontacf.soc-cd = piSoc-cd
          and icontacf.four-cle = pcFour-cle
          and icontacf.numero = piNumero:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icontacf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcontacf no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIcontacf:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table icontacf 
    Notes  : service externe. Critère pcFour-cle = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcFour-cle as character  no-undo.
    define input parameter table-handle phttIcontacf.
    define variable vhttBuffer as handle  no-undo.
    define buffer icontacf for icontacf.

    vhttBuffer = phttIcontacf:default-buffer-handle.
    if pcFour-cle = ?
    then for each icontacf no-lock
        where icontacf.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icontacf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each icontacf no-lock
        where icontacf.soc-cd = piSoc-cd
          and icontacf.four-cle = pcFour-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer icontacf:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIcontacf no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIcontacf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhNumero    as handle  no-undo.
    define buffer icontacf for icontacf.

    create query vhttquery.
    vhttBuffer = ghttIcontacf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIcontacf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFour-cle, output vhNumero).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icontacf exclusive-lock
                where rowid(icontacf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icontacf:handle, 'soc-cd/four-cle/numero: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhFour-cle:buffer-value(), vhNumero:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer icontacf:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIcontacf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer icontacf for icontacf.

    create query vhttquery.
    vhttBuffer = ghttIcontacf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIcontacf:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create icontacf.
            if not outils:copyValidField(buffer icontacf:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIcontacf private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhNumero    as handle  no-undo.
    define buffer icontacf for icontacf.

    create query vhttquery.
    vhttBuffer = ghttIcontacf:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIcontacf:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFour-cle, output vhNumero).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first icontacf exclusive-lock
                where rowid(Icontacf) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer icontacf:handle, 'soc-cd/four-cle/numero: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhFour-cle:buffer-value(), vhNumero:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete icontacf no-error.
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

