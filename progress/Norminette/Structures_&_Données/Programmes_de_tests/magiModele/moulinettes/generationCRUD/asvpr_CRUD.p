/*------------------------------------------------------------------------
File        : asvpr_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table asvpr
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/asvpr.i}
{application/include/error.i}
define variable ghttasvpr as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phGest-cle as handle, output phBque as handle, output phGuichet as handle, output phDacompta as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/gest-cle/bque/guichet/dacompta, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'gest-cle' then phGest-cle = phBuffer:buffer-field(vi).
            when 'bque' then phBque = phBuffer:buffer-field(vi).
            when 'guichet' then phGuichet = phBuffer:buffer-field(vi).
            when 'dacompta' then phDacompta = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAsvpr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAsvpr.
    run updateAsvpr.
    run createAsvpr.
end procedure.

procedure setAsvpr:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAsvpr.
    ghttAsvpr = phttAsvpr.
    run crudAsvpr.
    delete object phttAsvpr.
end procedure.

procedure readAsvpr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table asvpr 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcGest-cle as character  no-undo.
    define input parameter pcBque     as character  no-undo.
    define input parameter pcGuichet  as character  no-undo.
    define input parameter pdaDacompta as date       no-undo.
    define input parameter table-handle phttAsvpr.
    define variable vhttBuffer as handle no-undo.
    define buffer asvpr for asvpr.

    vhttBuffer = phttAsvpr:default-buffer-handle.
    for first asvpr no-lock
        where asvpr.soc-cd = piSoc-cd
          and asvpr.gest-cle = pcGest-cle
          and asvpr.bque = pcBque
          and asvpr.guichet = pcGuichet
          and asvpr.dacompta = pdaDacompta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer asvpr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAsvpr no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAsvpr:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table asvpr 
    Notes  : service externe. Critère pcGuichet = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter pcGest-cle as character  no-undo.
    define input parameter pcBque     as character  no-undo.
    define input parameter pcGuichet  as character  no-undo.
    define input parameter table-handle phttAsvpr.
    define variable vhttBuffer as handle  no-undo.
    define buffer asvpr for asvpr.

    vhttBuffer = phttAsvpr:default-buffer-handle.
    if pcGuichet = ?
    then for each asvpr no-lock
        where asvpr.soc-cd = piSoc-cd
          and asvpr.gest-cle = pcGest-cle
          and asvpr.bque = pcBque:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer asvpr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each asvpr no-lock
        where asvpr.soc-cd = piSoc-cd
          and asvpr.gest-cle = pcGest-cle
          and asvpr.bque = pcBque
          and asvpr.guichet = pcGuichet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer asvpr:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAsvpr no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAsvpr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhGest-cle    as handle  no-undo.
    define variable vhBque    as handle  no-undo.
    define variable vhGuichet    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define buffer asvpr for asvpr.

    create query vhttquery.
    vhttBuffer = ghttAsvpr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAsvpr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhGest-cle, output vhBque, output vhGuichet, output vhDacompta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first asvpr exclusive-lock
                where rowid(asvpr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer asvpr:handle, 'soc-cd/gest-cle/bque/guichet/dacompta: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhGest-cle:buffer-value(), vhBque:buffer-value(), vhGuichet:buffer-value(), vhDacompta:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer asvpr:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAsvpr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer asvpr for asvpr.

    create query vhttquery.
    vhttBuffer = ghttAsvpr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAsvpr:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create asvpr.
            if not outils:copyValidField(buffer asvpr:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAsvpr private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhGest-cle    as handle  no-undo.
    define variable vhBque    as handle  no-undo.
    define variable vhGuichet    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define buffer asvpr for asvpr.

    create query vhttquery.
    vhttBuffer = ghttAsvpr:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAsvpr:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhGest-cle, output vhBque, output vhGuichet, output vhDacompta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first asvpr exclusive-lock
                where rowid(Asvpr) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer asvpr:handle, 'soc-cd/gest-cle/bque/guichet/dacompta: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhGest-cle:buffer-value(), vhBque:buffer-value(), vhGuichet:buffer-value(), vhDacompta:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete asvpr no-error.
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

