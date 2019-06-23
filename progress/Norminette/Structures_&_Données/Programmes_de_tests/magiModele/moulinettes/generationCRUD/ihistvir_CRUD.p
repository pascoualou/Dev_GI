/*------------------------------------------------------------------------
File        : ihistvir_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ihistvir
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ihistvir.i}
{application/include/error.i}
define variable ghttihistvir as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phFic-nom as handle, output phDacrea as handle, output phBque as handle, output phGuichet as handle, output phNblig-tot as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/fic-nom/dacrea/bque/guichet/nblig-tot, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'fic-nom' then phFic-nom = phBuffer:buffer-field(vi).
            when 'dacrea' then phDacrea = phBuffer:buffer-field(vi).
            when 'bque' then phBque = phBuffer:buffer-field(vi).
            when 'guichet' then phGuichet = phBuffer:buffer-field(vi).
            when 'nblig-tot' then phNblig-tot = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIhistvir private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIhistvir.
    run updateIhistvir.
    run createIhistvir.
end procedure.

procedure setIhistvir:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIhistvir.
    ghttIhistvir = phttIhistvir.
    run crudIhistvir.
    delete object phttIhistvir.
end procedure.

procedure readIhistvir:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ihistvir 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcFic-nom   as character  no-undo.
    define input parameter pdaDacrea    as date       no-undo.
    define input parameter pcBque      as character  no-undo.
    define input parameter pcGuichet   as character  no-undo.
    define input parameter piNblig-tot as integer    no-undo.
    define input parameter table-handle phttIhistvir.
    define variable vhttBuffer as handle no-undo.
    define buffer ihistvir for ihistvir.

    vhttBuffer = phttIhistvir:default-buffer-handle.
    for first ihistvir no-lock
        where ihistvir.soc-cd = piSoc-cd
          and ihistvir.fic-nom = pcFic-nom
          and ihistvir.dacrea = pdaDacrea
          and ihistvir.bque = pcBque
          and ihistvir.guichet = pcGuichet
          and ihistvir.nblig-tot = piNblig-tot:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ihistvir:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIhistvir no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIhistvir:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ihistvir 
    Notes  : service externe. Critère pcGuichet = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter pcFic-nom   as character  no-undo.
    define input parameter pdaDacrea    as date       no-undo.
    define input parameter pcBque      as character  no-undo.
    define input parameter pcGuichet   as character  no-undo.
    define input parameter table-handle phttIhistvir.
    define variable vhttBuffer as handle  no-undo.
    define buffer ihistvir for ihistvir.

    vhttBuffer = phttIhistvir:default-buffer-handle.
    if pcGuichet = ?
    then for each ihistvir no-lock
        where ihistvir.soc-cd = piSoc-cd
          and ihistvir.fic-nom = pcFic-nom
          and ihistvir.dacrea = pdaDacrea
          and ihistvir.bque = pcBque:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ihistvir:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ihistvir no-lock
        where ihistvir.soc-cd = piSoc-cd
          and ihistvir.fic-nom = pcFic-nom
          and ihistvir.dacrea = pdaDacrea
          and ihistvir.bque = pcBque
          and ihistvir.guichet = pcGuichet:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ihistvir:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIhistvir no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIhistvir private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFic-nom    as handle  no-undo.
    define variable vhDacrea    as handle  no-undo.
    define variable vhBque    as handle  no-undo.
    define variable vhGuichet    as handle  no-undo.
    define variable vhNblig-tot    as handle  no-undo.
    define buffer ihistvir for ihistvir.

    create query vhttquery.
    vhttBuffer = ghttIhistvir:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIhistvir:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFic-nom, output vhDacrea, output vhBque, output vhGuichet, output vhNblig-tot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ihistvir exclusive-lock
                where rowid(ihistvir) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ihistvir:handle, 'soc-cd/fic-nom/dacrea/bque/guichet/nblig-tot: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhFic-nom:buffer-value(), vhDacrea:buffer-value(), vhBque:buffer-value(), vhGuichet:buffer-value(), vhNblig-tot:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ihistvir:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIhistvir private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ihistvir for ihistvir.

    create query vhttquery.
    vhttBuffer = ghttIhistvir:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIhistvir:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ihistvir.
            if not outils:copyValidField(buffer ihistvir:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIhistvir private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhFic-nom    as handle  no-undo.
    define variable vhDacrea    as handle  no-undo.
    define variable vhBque    as handle  no-undo.
    define variable vhGuichet    as handle  no-undo.
    define variable vhNblig-tot    as handle  no-undo.
    define buffer ihistvir for ihistvir.

    create query vhttquery.
    vhttBuffer = ghttIhistvir:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIhistvir:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhFic-nom, output vhDacrea, output vhBque, output vhGuichet, output vhNblig-tot).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ihistvir exclusive-lock
                where rowid(Ihistvir) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ihistvir:handle, 'soc-cd/fic-nom/dacrea/bque/guichet/nblig-tot: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhFic-nom:buffer-value(), vhDacrea:buffer-value(), vhBque:buffer-value(), vhGuichet:buffer-value(), vhNblig-tot:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ihistvir no-error.
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

