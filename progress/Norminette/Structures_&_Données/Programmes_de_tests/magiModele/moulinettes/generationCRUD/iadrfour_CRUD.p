/*------------------------------------------------------------------------
File        : iadrfour_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iadrfour
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iadrfour.i}
{application/include/error.i}
define variable ghttiadrfour as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFour-cle as handle, output phLibadr-cd as handle, output phAdr-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/four-cle/libadr-cd/adr-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'four-cle' then phFour-cle = phBuffer:buffer-field(vi).
            when 'libadr-cd' then phLibadr-cd = phBuffer:buffer-field(vi).
            when 'adr-cd' then phAdr-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIadrfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIadrfour.
    run updateIadrfour.
    run createIadrfour.
end procedure.

procedure setIadrfour:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIadrfour.
    ghttIadrfour = phttIadrfour.
    run crudIadrfour.
    delete object phttIadrfour.
end procedure.

procedure readIadrfour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iadrfour Liste des adresses des fournisseurs.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcFour-cle  as character  no-undo.
    define input parameter piLibadr-cd as integer    no-undo.
    define input parameter piAdr-cd    as integer    no-undo.
    define input parameter table-handle phttIadrfour.
    define variable vhttBuffer as handle no-undo.
    define buffer iadrfour for iadrfour.

    vhttBuffer = phttIadrfour:default-buffer-handle.
    for first iadrfour no-lock
        where iadrfour.soc-cd = piSoc-cd
          and iadrfour.four-cle = pcFour-cle
          and iadrfour.libadr-cd = piLibadr-cd
          and iadrfour.adr-cd = piAdr-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iadrfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIadrfour no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIadrfour:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iadrfour Liste des adresses des fournisseurs.
    Notes  : service externe. Critère piLibadr-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcFour-cle  as character  no-undo.
    define input parameter piLibadr-cd as integer    no-undo.
    define input parameter table-handle phttIadrfour.
    define variable vhttBuffer as handle  no-undo.
    define buffer iadrfour for iadrfour.

    vhttBuffer = phttIadrfour:default-buffer-handle.
    if piLibadr-cd = ?
    then for each iadrfour no-lock
        where iadrfour.soc-cd = piSoc-cd
          and iadrfour.four-cle = pcFour-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iadrfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iadrfour no-lock
        where iadrfour.soc-cd = piSoc-cd
          and iadrfour.four-cle = pcFour-cle
          and iadrfour.libadr-cd = piLibadr-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iadrfour:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIadrfour no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIadrfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhLibadr-cd    as handle  no-undo.
    define variable vhAdr-cd    as handle  no-undo.
    define buffer iadrfour for iadrfour.

    create query vhttquery.
    vhttBuffer = ghttIadrfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIadrfour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFour-cle, output vhLibadr-cd, output vhAdr-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iadrfour exclusive-lock
                where rowid(iadrfour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iadrfour:handle, 'soc-cd/four-cle/libadr-cd/adr-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhFour-cle:buffer-value(), vhLibadr-cd:buffer-value(), vhAdr-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iadrfour:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIadrfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iadrfour for iadrfour.

    create query vhttquery.
    vhttBuffer = ghttIadrfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIadrfour:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iadrfour.
            if not outils:copyValidField(buffer iadrfour:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIadrfour private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define variable vhLibadr-cd    as handle  no-undo.
    define variable vhAdr-cd    as handle  no-undo.
    define buffer iadrfour for iadrfour.

    create query vhttquery.
    vhttBuffer = ghttIadrfour:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIadrfour:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFour-cle, output vhLibadr-cd, output vhAdr-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iadrfour exclusive-lock
                where rowid(Iadrfour) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iadrfour:handle, 'soc-cd/four-cle/libadr-cd/adr-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhFour-cle:buffer-value(), vhLibadr-cd:buffer-value(), vhAdr-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iadrfour no-error.
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

