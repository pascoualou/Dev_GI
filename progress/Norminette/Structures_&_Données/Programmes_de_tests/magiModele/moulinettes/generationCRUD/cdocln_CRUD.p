/*------------------------------------------------------------------------
File        : cdocln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table cdocln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/cdocln.i}
{application/include/error.i}
define variable ghttcdocln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypedoc-cd as handle, output phDiv-cd as handle, output phDadeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typedoc-cd/div-cd/dadeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'typedoc-cd' then phTypedoc-cd = phBuffer:buffer-field(vi).
            when 'div-cd' then phDiv-cd = phBuffer:buffer-field(vi).
            when 'dadeb' then phDadeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCdocln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCdocln.
    run updateCdocln.
    run createCdocln.
end procedure.

procedure setCdocln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCdocln.
    ghttCdocln = phttCdocln.
    run crudCdocln.
    delete object phttCdocln.
end procedure.

procedure readCdocln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table cdocln Fichier de saisie des numeros de documents
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypedoc-cd as integer    no-undo.
    define input parameter piDiv-cd     as integer    no-undo.
    define input parameter pdaDadeb      as date       no-undo.
    define input parameter table-handle phttCdocln.
    define variable vhttBuffer as handle no-undo.
    define buffer cdocln for cdocln.

    vhttBuffer = phttCdocln:default-buffer-handle.
    for first cdocln no-lock
        where cdocln.soc-cd = piSoc-cd
          and cdocln.etab-cd = piEtab-cd
          and cdocln.typedoc-cd = piTypedoc-cd
          and cdocln.div-cd = piDiv-cd
          and cdocln.dadeb = pdaDadeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cdocln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCdocln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCdocln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table cdocln Fichier de saisie des numeros de documents
    Notes  : service externe. Critère piDiv-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piTypedoc-cd as integer    no-undo.
    define input parameter piDiv-cd     as integer    no-undo.
    define input parameter table-handle phttCdocln.
    define variable vhttBuffer as handle  no-undo.
    define buffer cdocln for cdocln.

    vhttBuffer = phttCdocln:default-buffer-handle.
    if piDiv-cd = ?
    then for each cdocln no-lock
        where cdocln.soc-cd = piSoc-cd
          and cdocln.etab-cd = piEtab-cd
          and cdocln.typedoc-cd = piTypedoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cdocln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each cdocln no-lock
        where cdocln.soc-cd = piSoc-cd
          and cdocln.etab-cd = piEtab-cd
          and cdocln.typedoc-cd = piTypedoc-cd
          and cdocln.div-cd = piDiv-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer cdocln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCdocln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCdocln private:
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
    define variable vhDadeb    as handle  no-undo.
    define buffer cdocln for cdocln.

    create query vhttquery.
    vhttBuffer = ghttCdocln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCdocln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypedoc-cd, output vhDiv-cd, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cdocln exclusive-lock
                where rowid(cdocln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cdocln:handle, 'soc-cd/etab-cd/typedoc-cd/div-cd/dadeb: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypedoc-cd:buffer-value(), vhDiv-cd:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer cdocln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCdocln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer cdocln for cdocln.

    create query vhttquery.
    vhttBuffer = ghttCdocln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCdocln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create cdocln.
            if not outils:copyValidField(buffer cdocln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCdocln private:
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
    define variable vhDadeb    as handle  no-undo.
    define buffer cdocln for cdocln.

    create query vhttquery.
    vhttBuffer = ghttCdocln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCdocln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypedoc-cd, output vhDiv-cd, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first cdocln exclusive-lock
                where rowid(Cdocln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer cdocln:handle, 'soc-cd/etab-cd/typedoc-cd/div-cd/dadeb: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypedoc-cd:buffer-value(), vhDiv-cd:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete cdocln no-error.
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

