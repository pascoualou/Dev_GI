/*------------------------------------------------------------------------
File        : indln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table indln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/indln.i}
{application/include/error.i}
define variable ghttindln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTppar as handle, output phIndice-cd as handle, output phDadeb as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/tppar/indice-cd/dadeb, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'indice-cd' then phIndice-cd = phBuffer:buffer-field(vi).
            when 'dadeb' then phDadeb = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIndln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIndln.
    run updateIndln.
    run createIndln.
end procedure.

procedure setIndln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIndln.
    ghttIndln = phttIndln.
    run crudIndln.
    delete object phttIndln.
end procedure.

procedure readIndln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table indln Ligne d'indice
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcTppar     as character  no-undo.
    define input parameter pcIndice-cd as character  no-undo.
    define input parameter pdaDadeb     as date       no-undo.
    define input parameter table-handle phttIndln.
    define variable vhttBuffer as handle no-undo.
    define buffer indln for indln.

    vhttBuffer = phttIndln:default-buffer-handle.
    for first indln no-lock
        where indln.soc-cd = piSoc-cd
          and indln.etab-cd = piEtab-cd
          and indln.tppar = pcTppar
          and indln.indice-cd = pcIndice-cd
          and indln.dadeb = pdaDadeb:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIndln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table indln Ligne d'indice
    Notes  : service externe. Critère pcIndice-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcTppar     as character  no-undo.
    define input parameter pcIndice-cd as character  no-undo.
    define input parameter table-handle phttIndln.
    define variable vhttBuffer as handle  no-undo.
    define buffer indln for indln.

    vhttBuffer = phttIndln:default-buffer-handle.
    if pcIndice-cd = ?
    then for each indln no-lock
        where indln.soc-cd = piSoc-cd
          and indln.etab-cd = piEtab-cd
          and indln.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each indln no-lock
        where indln.soc-cd = piSoc-cd
          and indln.etab-cd = piEtab-cd
          and indln.tppar = pcTppar
          and indln.indice-cd = pcIndice-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIndln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhIndice-cd    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer indln for indln.

    create query vhttquery.
    vhttBuffer = ghttIndln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIndln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTppar, output vhIndice-cd, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indln exclusive-lock
                where rowid(indln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indln:handle, 'soc-cd/etab-cd/tppar/indice-cd/dadeb: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTppar:buffer-value(), vhIndice-cd:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer indln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIndln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer indln for indln.

    create query vhttquery.
    vhttBuffer = ghttIndln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIndln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create indln.
            if not outils:copyValidField(buffer indln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIndln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTppar    as handle  no-undo.
    define variable vhIndice-cd    as handle  no-undo.
    define variable vhDadeb    as handle  no-undo.
    define buffer indln for indln.

    create query vhttquery.
    vhttBuffer = ghttIndln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIndln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTppar, output vhIndice-cd, output vhDadeb).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indln exclusive-lock
                where rowid(Indln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indln:handle, 'soc-cd/etab-cd/tppar/indice-cd/dadeb: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTppar:buffer-value(), vhIndice-cd:buffer-value(), vhDadeb:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete indln no-error.
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

