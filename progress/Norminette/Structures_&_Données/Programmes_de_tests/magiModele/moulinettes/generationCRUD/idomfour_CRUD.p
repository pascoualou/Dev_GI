/*------------------------------------------------------------------------
File        : idomfour_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table idomfour
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/idomfour.i}
{application/include/error.i}
define variable ghttidomfour as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phFour-cle as handle, output phDom-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/four-cle/dom-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'four-cle' then phFour-cle = phBuffer:buffer-field(vi).
            when 'dom-cd' then phDom-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIdomfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIdomfour.
    run updateIdomfour.
    run createIdomfour.
end procedure.

procedure setIdomfour:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIdomfour.
    ghttIdomfour = phttIdomfour.
    run crudIdomfour.
    delete object phttIdomfour.
end procedure.

procedure readIdomfour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table idomfour 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcFour-cle as character  no-undo.
    define input parameter piDom-cd   as integer    no-undo.
    define input parameter table-handle phttIdomfour.
    define variable vhttBuffer as handle no-undo.
    define buffer idomfour for idomfour.

    vhttBuffer = phttIdomfour:default-buffer-handle.
    for first idomfour no-lock
        where idomfour.soc-cd = piSoc-cd
          and idomfour.etab-cd = piEtab-cd
          and idomfour.four-cle = pcFour-cle
          and idomfour.dom-cd = piDom-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idomfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIdomfour no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIdomfour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table idomfour 
    Notes  : service externe. Crit�re pcFour-cle = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcFour-cle as character  no-undo.
    define input parameter table-handle phttIdomfour.
    define variable vhttBuffer as handle  no-undo.
    define buffer idomfour for idomfour.

    vhttBuffer = phttIdomfour:default-buffer-handle.
    if pcFour-cle = ?
    then for each idomfour no-lock
        where idomfour.soc-cd = piSoc-cd
          and idomfour.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idomfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each idomfour no-lock
        where idomfour.soc-cd = piSoc-cd
          and idomfour.etab-cd = piEtab-cd
          and idomfour.four-cle = pcFour-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer idomfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIdomfour no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIdomfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhDom-cd    as handle  no-undo.
    define buffer idomfour for idomfour.

    create query vhttquery.
    vhttBuffer = ghttIdomfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIdomfour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhFour-cle, output vhDom-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first idomfour exclusive-lock
                where rowid(idomfour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer idomfour:handle, 'soc-cd/etab-cd/four-cle/dom-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhFour-cle:buffer-value(), vhDom-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer idomfour:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIdomfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer idomfour for idomfour.

    create query vhttquery.
    vhttBuffer = ghttIdomfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIdomfour:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create idomfour.
            if not outils:copyValidField(buffer idomfour:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIdomfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhDom-cd    as handle  no-undo.
    define buffer idomfour for idomfour.

    create query vhttquery.
    vhttBuffer = ghttIdomfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIdomfour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhFour-cle, output vhDom-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first idomfour exclusive-lock
                where rowid(Idomfour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer idomfour:handle, 'soc-cd/etab-cd/four-cle/dom-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhFour-cle:buffer-value(), vhDom-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete idomfour no-error.
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

