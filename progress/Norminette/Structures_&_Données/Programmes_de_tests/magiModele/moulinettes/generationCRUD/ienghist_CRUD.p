/*------------------------------------------------------------------------
File        : ienghist_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ienghist
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ienghist.i}
{application/include/error.i}
define variable ghttienghist as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phNiv-num as handle, output phAna-cd as handle, output phNum-int as handle, output phDaaction as handle, output phHaction as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/niv-num/ana-cd/num-int/daaction/haction, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'niv-num' then phNiv-num = phBuffer:buffer-field(vi).
            when 'ana-cd' then phAna-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'daaction' then phDaaction = phBuffer:buffer-field(vi).
            when 'haction' then phHaction = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIenghist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIenghist.
    run updateIenghist.
    run createIenghist.
end procedure.

procedure setIenghist:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIenghist.
    ghttIenghist = phttIenghist.
    run crudIenghist.
    delete object phttIenghist.
end procedure.

procedure readIenghist:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ienghist 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piNiv-num  as integer    no-undo.
    define input parameter pcAna-cd   as character  no-undo.
    define input parameter piNum-int  as integer    no-undo.
    define input parameter pdaDaaction as date       no-undo.
    define input parameter piHaction  as integer    no-undo.
    define input parameter table-handle phttIenghist.
    define variable vhttBuffer as handle no-undo.
    define buffer ienghist for ienghist.

    vhttBuffer = phttIenghist:default-buffer-handle.
    for first ienghist no-lock
        where ienghist.soc-cd = piSoc-cd
          and ienghist.etab-cd = piEtab-cd
          and ienghist.niv-num = piNiv-num
          and ienghist.ana-cd = pcAna-cd
          and ienghist.num-int = piNum-int
          and ienghist.daaction = pdaDaaction
          and ienghist.haction = piHaction:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ienghist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIenghist no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIenghist:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ienghist 
    Notes  : service externe. Critère pdaDaaction = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piNiv-num  as integer    no-undo.
    define input parameter pcAna-cd   as character  no-undo.
    define input parameter piNum-int  as integer    no-undo.
    define input parameter pdaDaaction as date       no-undo.
    define input parameter table-handle phttIenghist.
    define variable vhttBuffer as handle  no-undo.
    define buffer ienghist for ienghist.

    vhttBuffer = phttIenghist:default-buffer-handle.
    if pdaDaaction = ?
    then for each ienghist no-lock
        where ienghist.soc-cd = piSoc-cd
          and ienghist.etab-cd = piEtab-cd
          and ienghist.niv-num = piNiv-num
          and ienghist.ana-cd = pcAna-cd
          and ienghist.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ienghist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ienghist no-lock
        where ienghist.soc-cd = piSoc-cd
          and ienghist.etab-cd = piEtab-cd
          and ienghist.niv-num = piNiv-num
          and ienghist.ana-cd = pcAna-cd
          and ienghist.num-int = piNum-int
          and ienghist.daaction = pdaDaaction:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ienghist:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIenghist no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIenghist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhDaaction    as handle  no-undo.
    define variable vhHaction    as handle  no-undo.
    define buffer ienghist for ienghist.

    create query vhttquery.
    vhttBuffer = ghttIenghist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIenghist:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd, output vhNum-int, output vhDaaction, output vhHaction).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ienghist exclusive-lock
                where rowid(ienghist) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ienghist:handle, 'soc-cd/etab-cd/niv-num/ana-cd/num-int/daaction/haction: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhNum-int:buffer-value(), vhDaaction:buffer-value(), vhHaction:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ienghist:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIenghist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ienghist for ienghist.

    create query vhttquery.
    vhttBuffer = ghttIenghist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIenghist:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ienghist.
            if not outils:copyValidField(buffer ienghist:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIenghist private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhNiv-num    as handle  no-undo.
    define variable vhAna-cd    as handle  no-undo.
    define variable vhNum-int    as handle  no-undo.
    define variable vhDaaction    as handle  no-undo.
    define variable vhHaction    as handle  no-undo.
    define buffer ienghist for ienghist.

    create query vhttquery.
    vhttBuffer = ghttIenghist:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIenghist:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhNiv-num, output vhAna-cd, output vhNum-int, output vhDaaction, output vhHaction).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ienghist exclusive-lock
                where rowid(Ienghist) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ienghist:handle, 'soc-cd/etab-cd/niv-num/ana-cd/num-int/daaction/haction: ', substitute('&1/&2/&3/&4/&5/&6/&7', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhNiv-num:buffer-value(), vhAna-cd:buffer-value(), vhNum-int:buffer-value(), vhDaaction:buffer-value(), vhHaction:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ienghist no-error.
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

