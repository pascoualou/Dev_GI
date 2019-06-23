/*------------------------------------------------------------------------
File        : ifouetab_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifouetab
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifouetab.i}
{application/include/error.i}
define variable ghttifouetab as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phFour-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/four-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'four-cle' then phFour-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfouetab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfouetab.
    run updateIfouetab.
    run createIfouetab.
end procedure.

procedure setIfouetab:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfouetab.
    ghttIfouetab = phttIfouetab.
    run crudIfouetab.
    delete object phttIfouetab.
end procedure.

procedure readIfouetab:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifouetab fichier solde fournisseur
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter pcFour-cle as character  no-undo.
    define input parameter table-handle phttIfouetab.
    define variable vhttBuffer as handle no-undo.
    define buffer ifouetab for ifouetab.

    vhttBuffer = phttIfouetab:default-buffer-handle.
    for first ifouetab no-lock
        where ifouetab.soc-cd = piSoc-cd
          and ifouetab.etab-cd = piEtab-cd
          and ifouetab.four-cle = pcFour-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifouetab:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfouetab no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfouetab:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifouetab fichier solde fournisseur
    Notes  : service externe. Critère piEtab-cd = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter table-handle phttIfouetab.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifouetab for ifouetab.

    vhttBuffer = phttIfouetab:default-buffer-handle.
    if piEtab-cd = ?
    then for each ifouetab no-lock
        where ifouetab.soc-cd = piSoc-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifouetab:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifouetab no-lock
        where ifouetab.soc-cd = piSoc-cd
          and ifouetab.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifouetab:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfouetab no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfouetab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define buffer ifouetab for ifouetab.

    create query vhttquery.
    vhttBuffer = ghttIfouetab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfouetab:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhFour-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifouetab exclusive-lock
                where rowid(ifouetab) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifouetab:handle, 'soc-cd/etab-cd/four-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhFour-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifouetab:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfouetab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifouetab for ifouetab.

    create query vhttquery.
    vhttBuffer = ghttIfouetab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfouetab:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifouetab.
            if not outils:copyValidField(buffer ifouetab:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfouetab private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhFour-cle    as handle  no-undo.
    define buffer ifouetab for ifouetab.

    create query vhttquery.
    vhttBuffer = ghttIfouetab:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfouetab:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhFour-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifouetab exclusive-lock
                where rowid(Ifouetab) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifouetab:handle, 'soc-cd/etab-cd/four-cle: ', substitute('&1/&2/&3', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhFour-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifouetab no-error.
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

