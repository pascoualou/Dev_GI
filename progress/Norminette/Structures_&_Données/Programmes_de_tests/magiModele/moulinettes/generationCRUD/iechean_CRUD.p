/*------------------------------------------------------------------------
File        : iechean_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iechean
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iechean.i}
{application/include/error.i}
define variable ghttiechean as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phRef-num as handle, output phDaech as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/ref-num/daech, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'ref-num' then phRef-num = phBuffer:buffer-field(vi).
            when 'daech' then phDaech = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIechean private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIechean.
    run updateIechean.
    run createIechean.
end procedure.

procedure setIechean:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIechean.
    ghttIechean = phttIechean.
    run crudIechean.
    delete object phttIechean.
end procedure.

procedure readIechean:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iechean Fichier de repartition des echeances de traites
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcRef-num as character  no-undo.
    define input parameter pdaDaech   as date       no-undo.
    define input parameter table-handle phttIechean.
    define variable vhttBuffer as handle no-undo.
    define buffer iechean for iechean.

    vhttBuffer = phttIechean:default-buffer-handle.
    for first iechean no-lock
        where iechean.soc-cd = piSoc-cd
          and iechean.etab-cd = piEtab-cd
          and iechean.ref-num = pcRef-num
          and iechean.daech = pdaDaech:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iechean:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIechean no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIechean:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iechean Fichier de repartition des echeances de traites
    Notes  : service externe. Critère pcRef-num = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd  as integer    no-undo.
    define input parameter piEtab-cd as integer    no-undo.
    define input parameter pcRef-num as character  no-undo.
    define input parameter table-handle phttIechean.
    define variable vhttBuffer as handle  no-undo.
    define buffer iechean for iechean.

    vhttBuffer = phttIechean:default-buffer-handle.
    if pcRef-num = ?
    then for each iechean no-lock
        where iechean.soc-cd = piSoc-cd
          and iechean.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iechean:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iechean no-lock
        where iechean.soc-cd = piSoc-cd
          and iechean.etab-cd = piEtab-cd
          and iechean.ref-num = pcRef-num:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iechean:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIechean no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIechean private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRef-num    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define buffer iechean for iechean.

    create query vhttquery.
    vhttBuffer = ghttIechean:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIechean:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRef-num, output vhDaech).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iechean exclusive-lock
                where rowid(iechean) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iechean:handle, 'soc-cd/etab-cd/ref-num/daech: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRef-num:buffer-value(), vhDaech:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iechean:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIechean private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iechean for iechean.

    create query vhttquery.
    vhttBuffer = ghttIechean:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIechean:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iechean.
            if not outils:copyValidField(buffer iechean:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIechean private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhRef-num    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define buffer iechean for iechean.

    create query vhttquery.
    vhttBuffer = ghttIechean:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIechean:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhRef-num, output vhDaech).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iechean exclusive-lock
                where rowid(Iechean) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iechean:handle, 'soc-cd/etab-cd/ref-num/daech: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhRef-num:buffer-value(), vhDaech:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iechean no-error.
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

