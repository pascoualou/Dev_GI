/*------------------------------------------------------------------------
File        : caffln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table caffln
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/caffln.i}
{application/include/error.i}
define variable ghttcaffln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phAffair-num as handle, output phCpt-cd as handle, output phDacompta as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/affair-num/cpt-cd/dacompta, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'affair-num' then phAffair-num = phBuffer:buffer-field(vi).
            when 'cpt-cd' then phCpt-cd = phBuffer:buffer-field(vi).
            when 'dacompta' then phDacompta = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudCaffln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteCaffln.
    run updateCaffln.
    run createCaffln.
end procedure.

procedure setCaffln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttCaffln.
    ghttCaffln = phttCaffln.
    run crudCaffln.
    delete object phttCaffln.
end procedure.

procedure readCaffln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table caffln Lignes d'ecritures (conservation apres raz exercice)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piAffair-num as integer    no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter pdaDacompta   as date       no-undo.
    define input parameter table-handle phttCaffln.
    define variable vhttBuffer as handle no-undo.
    define buffer caffln for caffln.

    vhttBuffer = phttCaffln:default-buffer-handle.
    for first caffln no-lock
        where caffln.soc-cd = piSoc-cd
          and caffln.etab-cd = piEtab-cd
          and caffln.affair-num = piAffair-num
          and caffln.cpt-cd = pcCpt-cd
          and caffln.dacompta = pdaDacompta:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caffln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCaffln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getCaffln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table caffln Lignes d'ecritures (conservation apres raz exercice)
    Notes  : service externe. Critère pcCpt-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd     as integer    no-undo.
    define input parameter piEtab-cd    as integer    no-undo.
    define input parameter piAffair-num as integer    no-undo.
    define input parameter pcCpt-cd     as character  no-undo.
    define input parameter table-handle phttCaffln.
    define variable vhttBuffer as handle  no-undo.
    define buffer caffln for caffln.

    vhttBuffer = phttCaffln:default-buffer-handle.
    if pcCpt-cd = ?
    then for each caffln no-lock
        where caffln.soc-cd = piSoc-cd
          and caffln.etab-cd = piEtab-cd
          and caffln.affair-num = piAffair-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caffln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each caffln no-lock
        where caffln.soc-cd = piSoc-cd
          and caffln.etab-cd = piEtab-cd
          and caffln.affair-num = piAffair-num
          and caffln.cpt-cd = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer caffln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttCaffln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCaffln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAffair-num    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define buffer caffln for caffln.

    create query vhttquery.
    vhttBuffer = ghttCaffln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttCaffln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAffair-num, output vhCpt-cd, output vhDacompta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first caffln exclusive-lock
                where rowid(caffln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer caffln:handle, 'soc-cd/etab-cd/affair-num/cpt-cd/dacompta: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAffair-num:buffer-value(), vhCpt-cd:buffer-value(), vhDacompta:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer caffln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createCaffln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer caffln for caffln.

    create query vhttquery.
    vhttBuffer = ghttCaffln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttCaffln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create caffln.
            if not outils:copyValidField(buffer caffln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteCaffln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhAffair-num    as handle  no-undo.
    define variable vhCpt-cd    as handle  no-undo.
    define variable vhDacompta    as handle  no-undo.
    define buffer caffln for caffln.

    create query vhttquery.
    vhttBuffer = ghttCaffln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttCaffln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhAffair-num, output vhCpt-cd, output vhDacompta).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first caffln exclusive-lock
                where rowid(Caffln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer caffln:handle, 'soc-cd/etab-cd/affair-num/cpt-cd/dacompta: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhAffair-num:buffer-value(), vhCpt-cd:buffer-value(), vhDacompta:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete caffln no-error.
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

