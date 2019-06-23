/*------------------------------------------------------------------------
File        : cdocsai_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cdocsai
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cdocsai.i}
{application/include/error.i}
define variable ghttcdocsai as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypedoc-cd as handle, output phDiv-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typedoc-cd/div-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'typedoc-cd' then phTypedoc-cd = phBuffer:buffer-field(vi).
            when 'div-cd' then phDiv-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCdocsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCdocsai.
    run updateCdocsai.
    run createCdocsai.
end procedure.

procedure setCdocsai:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCdocsai.
    ghttCdocsai = phttCdocsai.
    run crudCdocsai.
    delete object phttCdocsai.
end procedure.

procedure readCdocsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cdocsai Fichier document (entete)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypedoc-cd as integer    no-undo.
    define input parameter piDiv-cd     as integer    no-undo.
    define input parameter table-handle phttCdocsai.
    define variable vhttBuffer as handle no-undo.
    define buffer cdocsai for cdocsai.

    vhttBuffer = phttCdocsai:default-buffer-handle.
    for first cdocsai no-lock
        where cdocsai.soc-cd = piSoc-cd
          and cdocsai.etab-cd = piEtab-cd
          and cdocsai.typedoc-cd = piTypedoc-cd
          and cdocsai.div-cd = piDiv-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cdocsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCdocsai no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCdocsai:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cdocsai Fichier document (entete)
    Notes  : service externe. Critère piTypedoc-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypedoc-cd as integer    no-undo.
    define input parameter table-handle phttCdocsai.
    define variable vhttBuffer as handle  no-undo.
    define buffer cdocsai for cdocsai.

    vhttBuffer = phttCdocsai:default-buffer-handle.
    if piTypedoc-cd = ?
    then for each cdocsai no-lock
        where cdocsai.soc-cd = piSoc-cd
          and cdocsai.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cdocsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cdocsai no-lock
        where cdocsai.soc-cd = piSoc-cd
          and cdocsai.etab-cd = piEtab-cd
          and cdocsai.typedoc-cd = piTypedoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cdocsai:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCdocsai no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCdocsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypedoc-cd    as handle  no-undo.
    define variable vhDiv-cd    as handle  no-undo.
    define buffer cdocsai for cdocsai.

    create query vhttquery.
    vhttBuffer = ghttCdocsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCdocsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypedoc-cd, output vhDiv-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cdocsai exclusive-lock
                where rowid(cdocsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cdocsai:handle, 'soc-cd/etab-cd/typedoc-cd/div-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypedoc-cd:buffer-value(), vhDiv-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cdocsai:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCdocsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cdocsai for cdocsai.

    create query vhttquery.
    vhttBuffer = ghttCdocsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCdocsai:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cdocsai.
            if not outils:copyValidField(buffer cdocsai:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCdocsai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypedoc-cd    as handle  no-undo.
    define variable vhDiv-cd    as handle  no-undo.
    define buffer cdocsai for cdocsai.

    create query vhttquery.
    vhttBuffer = ghttCdocsai:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCdocsai:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypedoc-cd, output vhDiv-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cdocsai exclusive-lock
                where rowid(Cdocsai) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cdocsai:handle, 'soc-cd/etab-cd/typedoc-cd/div-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypedoc-cd:buffer-value(), vhDiv-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cdocsai no-error.
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

