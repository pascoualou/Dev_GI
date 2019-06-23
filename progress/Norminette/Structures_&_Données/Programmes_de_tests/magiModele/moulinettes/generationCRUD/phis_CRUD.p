/*------------------------------------------------------------------------
File        : phis_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table phis
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/phis.i}
{application/include/error.i}
define variable ghttphis as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phGi-ttyid as handle, output phAa-cpt as handle, output phMm-cpt as handle, output phC_etat as handle, output phC_enreg2 as handle, output phAa-ecr as handle, output phMm-ecr as handle, output phJj-ecr as handle, output phDocument as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur gi-ttyid/aa-cpt/mm-cpt/c_etat/c_enreg2/aa-ecr/mm-ecr/jj-ecr/document, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'gi-ttyid' then phGi-ttyid = phBuffer:buffer-field(vi).
            when 'aa-cpt' then phAa-cpt = phBuffer:buffer-field(vi).
            when 'mm-cpt' then phMm-cpt = phBuffer:buffer-field(vi).
            when 'c_etat' then phC_etat = phBuffer:buffer-field(vi).
            when 'c_enreg2' then phC_enreg2 = phBuffer:buffer-field(vi).
            when 'aa-ecr' then phAa-ecr = phBuffer:buffer-field(vi).
            when 'mm-ecr' then phMm-ecr = phBuffer:buffer-field(vi).
            when 'jj-ecr' then phJj-ecr = phBuffer:buffer-field(vi).
            when 'document' then phDocument = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudPhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deletePhis.
    run updatePhis.
    run createPhis.
end procedure.

procedure setPhis:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttPhis.
    ghttPhis = phttPhis.
    run crudPhis.
    delete object phttPhis.
end procedure.

procedure readPhis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table phis Fichier indexation des ecritures
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid as character  no-undo.
    define input parameter piAa-cpt   as integer    no-undo.
    define input parameter piMm-cpt   as integer    no-undo.
    define input parameter pcC_etat   as character  no-undo.
    define input parameter pcC_enreg2 as character  no-undo.
    define input parameter piAa-ecr   as integer    no-undo.
    define input parameter piMm-ecr   as integer    no-undo.
    define input parameter piJj-ecr   as integer    no-undo.
    define input parameter pcDocument as character  no-undo.
    define input parameter table-handle phttPhis.
    define variable vhttBuffer as handle no-undo.
    define buffer phis for phis.

    vhttBuffer = phttPhis:default-buffer-handle.
    for first phis no-lock
        where phis.gi-ttyid = pcGi-ttyid
          and phis.aa-cpt = piAa-cpt
          and phis.mm-cpt = piMm-cpt
          and phis.c_etat = pcC_etat
          and phis.c_enreg2 = pcC_enreg2
          and phis.aa-ecr = piAa-ecr
          and phis.mm-ecr = piMm-ecr
          and phis.jj-ecr = piJj-ecr
          and phis.document = pcDocument:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer phis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPhis no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getPhis:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table phis Fichier indexation des ecritures
    Notes  : service externe. Critère piJj-ecr = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcGi-ttyid as character  no-undo.
    define input parameter piAa-cpt   as integer    no-undo.
    define input parameter piMm-cpt   as integer    no-undo.
    define input parameter pcC_etat   as character  no-undo.
    define input parameter pcC_enreg2 as character  no-undo.
    define input parameter piAa-ecr   as integer    no-undo.
    define input parameter piMm-ecr   as integer    no-undo.
    define input parameter piJj-ecr   as integer    no-undo.
    define input parameter table-handle phttPhis.
    define variable vhttBuffer as handle  no-undo.
    define buffer phis for phis.

    vhttBuffer = phttPhis:default-buffer-handle.
    if piJj-ecr = ?
    then for each phis no-lock
        where phis.gi-ttyid = pcGi-ttyid
          and phis.aa-cpt = piAa-cpt
          and phis.mm-cpt = piMm-cpt
          and phis.c_etat = pcC_etat
          and phis.c_enreg2 = pcC_enreg2
          and phis.aa-ecr = piAa-ecr
          and phis.mm-ecr = piMm-ecr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer phis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each phis no-lock
        where phis.gi-ttyid = pcGi-ttyid
          and phis.aa-cpt = piAa-cpt
          and phis.mm-cpt = piMm-cpt
          and phis.c_etat = pcC_etat
          and phis.c_enreg2 = pcC_enreg2
          and phis.aa-ecr = piAa-ecr
          and phis.mm-ecr = piMm-ecr
          and phis.jj-ecr = piJj-ecr:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer phis:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttPhis no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updatePhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhAa-cpt    as handle  no-undo.
    define variable vhMm-cpt    as handle  no-undo.
    define variable vhC_etat    as handle  no-undo.
    define variable vhC_enreg2    as handle  no-undo.
    define variable vhAa-ecr    as handle  no-undo.
    define variable vhMm-ecr    as handle  no-undo.
    define variable vhJj-ecr    as handle  no-undo.
    define variable vhDocument    as handle  no-undo.
    define buffer phis for phis.

    create query vhttquery.
    vhttBuffer = ghttPhis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttPhis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhAa-cpt, output vhMm-cpt, output vhC_etat, output vhC_enreg2, output vhAa-ecr, output vhMm-ecr, output vhJj-ecr, output vhDocument).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first phis exclusive-lock
                where rowid(phis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer phis:handle, 'gi-ttyid/aa-cpt/mm-cpt/c_etat/c_enreg2/aa-ecr/mm-ecr/jj-ecr/document: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhGi-ttyid:buffer-value(), vhAa-cpt:buffer-value(), vhMm-cpt:buffer-value(), vhC_etat:buffer-value(), vhC_enreg2:buffer-value(), vhAa-ecr:buffer-value(), vhMm-ecr:buffer-value(), vhJj-ecr:buffer-value(), vhDocument:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer phis:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createPhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer phis for phis.

    create query vhttquery.
    vhttBuffer = ghttPhis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttPhis:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create phis.
            if not outils:copyValidField(buffer phis:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deletePhis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhGi-ttyid    as handle  no-undo.
    define variable vhAa-cpt    as handle  no-undo.
    define variable vhMm-cpt    as handle  no-undo.
    define variable vhC_etat    as handle  no-undo.
    define variable vhC_enreg2    as handle  no-undo.
    define variable vhAa-ecr    as handle  no-undo.
    define variable vhMm-ecr    as handle  no-undo.
    define variable vhJj-ecr    as handle  no-undo.
    define variable vhDocument    as handle  no-undo.
    define buffer phis for phis.

    create query vhttquery.
    vhttBuffer = ghttPhis:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttPhis:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhGi-ttyid, output vhAa-cpt, output vhMm-cpt, output vhC_etat, output vhC_enreg2, output vhAa-ecr, output vhMm-ecr, output vhJj-ecr, output vhDocument).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first phis exclusive-lock
                where rowid(Phis) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer phis:handle, 'gi-ttyid/aa-cpt/mm-cpt/c_etat/c_enreg2/aa-ecr/mm-ecr/jj-ecr/document: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhGi-ttyid:buffer-value(), vhAa-cpt:buffer-value(), vhMm-cpt:buffer-value(), vhC_etat:buffer-value(), vhC_enreg2:buffer-value(), vhAa-ecr:buffer-value(), vhMm-ecr:buffer-value(), vhJj-ecr:buffer-value(), vhDocument:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete phis no-error.
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

