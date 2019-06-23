/*------------------------------------------------------------------------
File        : indent_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table indent
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/indent.i}
{application/include/error.i}
define variable ghttindent as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTppar as handle, output phIndice-cd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/tppar/indice-cd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'tppar' then phTppar = phBuffer:buffer-field(vi).
            when 'indice-cd' then phIndice-cd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIndent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIndent.
    run updateIndent.
    run createIndent.
end procedure.

procedure setIndent:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIndent.
    ghttIndent = phttIndent.
    run crudIndent.
    delete object phttIndent.
end procedure.

procedure readIndent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table indent parametrage interet de retard et delai moyen de règlement
 (Entete)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcTppar     as character  no-undo.
    define input parameter pcIndice-cd as character  no-undo.
    define input parameter table-handle phttIndent.
    define variable vhttBuffer as handle no-undo.
    define buffer indent for indent.

    vhttBuffer = phttIndent:default-buffer-handle.
    for first indent no-lock
        where indent.soc-cd = piSoc-cd
          and indent.etab-cd = piEtab-cd
          and indent.tppar = pcTppar
          and indent.indice-cd = pcIndice-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indent:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndent no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIndent:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table indent parametrage interet de retard et delai moyen de règlement
 (Entete)
    Notes  : service externe. Critère pcTppar = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter pcTppar     as character  no-undo.
    define input parameter table-handle phttIndent.
    define variable vhttBuffer as handle  no-undo.
    define buffer indent for indent.

    vhttBuffer = phttIndent:default-buffer-handle.
    if pcTppar = ?
    then for each indent no-lock
        where indent.soc-cd = piSoc-cd
          and indent.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indent:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each indent no-lock
        where indent.soc-cd = piSoc-cd
          and indent.etab-cd = piEtab-cd
          and indent.tppar = pcTppar:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer indent:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIndent no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIndent private:
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
    define buffer indent for indent.

    create query vhttquery.
    vhttBuffer = ghttIndent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIndent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTppar, output vhIndice-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indent exclusive-lock
                where rowid(indent) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indent:handle, 'soc-cd/etab-cd/tppar/indice-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTppar:buffer-value(), vhIndice-cd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer indent:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIndent private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer indent for indent.

    create query vhttquery.
    vhttBuffer = ghttIndent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIndent:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create indent.
            if not outils:copyValidField(buffer indent:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIndent private:
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
    define buffer indent for indent.

    create query vhttquery.
    vhttBuffer = ghttIndent:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIndent:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTppar, output vhIndice-cd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first indent exclusive-lock
                where rowid(Indent) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer indent:handle, 'soc-cd/etab-cd/tppar/indice-cd: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTppar:buffer-value(), vhIndice-cd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete indent no-error.
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

