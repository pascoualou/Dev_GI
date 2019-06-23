/*------------------------------------------------------------------------
File        : ifprjou_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifprjou
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifprjou.i}
{application/include/error.i}
define variable ghttifprjou as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypefac-cle as handle, output phJou-cd as handle, output phSoc-dest as handle, output phEtab-dest as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typefac-cle/jou-cd/soc-dest/etab-dest, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
            when 'jou-cd' then phJou-cd = phBuffer:buffer-field(vi).
            when 'soc-dest' then phSoc-dest = phBuffer:buffer-field(vi).
            when 'etab-dest' then phEtab-dest = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfprjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfprjou.
    run updateIfprjou.
    run createIfprjou.
end procedure.

procedure setIfprjou:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfprjou.
    ghttIfprjou = phttIfprjou.
    run crudIfprjou.
    delete object phttIfprjou.
end procedure.

procedure readIfprjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifprjou 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcJou-cd      as character  no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter piEtab-dest   as integer    no-undo.
    define input parameter table-handle phttIfprjou.
    define variable vhttBuffer as handle no-undo.
    define buffer ifprjou for ifprjou.

    vhttBuffer = phttIfprjou:default-buffer-handle.
    for first ifprjou no-lock
        where ifprjou.soc-cd = piSoc-cd
          and ifprjou.etab-cd = piEtab-cd
          and ifprjou.typefac-cle = pcTypefac-cle
          and ifprjou.jou-cd = pcJou-cd
          and ifprjou.soc-dest = piSoc-dest
          and ifprjou.etab-dest = piEtab-dest:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfprjou no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfprjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifprjou 
    Notes  : service externe. Critère piSoc-dest = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcJou-cd      as character  no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter table-handle phttIfprjou.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifprjou for ifprjou.

    vhttBuffer = phttIfprjou:default-buffer-handle.
    if piSoc-dest = ?
    then for each ifprjou no-lock
        where ifprjou.soc-cd = piSoc-cd
          and ifprjou.etab-cd = piEtab-cd
          and ifprjou.typefac-cle = pcTypefac-cle
          and ifprjou.jou-cd = pcJou-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifprjou no-lock
        where ifprjou.soc-cd = piSoc-cd
          and ifprjou.etab-cd = piEtab-cd
          and ifprjou.typefac-cle = pcTypefac-cle
          and ifprjou.jou-cd = pcJou-cd
          and ifprjou.soc-dest = piSoc-dest:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfprjou no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfprjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhEtab-dest    as handle  no-undo.
    define buffer ifprjou for ifprjou.

    create query vhttquery.
    vhttBuffer = ghttIfprjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfprjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhJou-cd, output vhSoc-dest, output vhEtab-dest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifprjou exclusive-lock
                where rowid(ifprjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifprjou:handle, 'soc-cd/etab-cd/typefac-cle/jou-cd/soc-dest/etab-dest: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhJou-cd:buffer-value(), vhSoc-dest:buffer-value(), vhEtab-dest:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifprjou:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfprjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifprjou for ifprjou.

    create query vhttquery.
    vhttBuffer = ghttIfprjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfprjou:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifprjou.
            if not outils:copyValidField(buffer ifprjou:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfprjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhJou-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhEtab-dest    as handle  no-undo.
    define buffer ifprjou for ifprjou.

    create query vhttquery.
    vhttBuffer = ghttIfprjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfprjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhJou-cd, output vhSoc-dest, output vhEtab-dest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifprjou exclusive-lock
                where rowid(Ifprjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifprjou:handle, 'soc-cd/etab-cd/typefac-cle/jou-cd/soc-dest/etab-dest: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhJou-cd:buffer-value(), vhSoc-dest:buffer-value(), vhEtab-dest:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifprjou no-error.
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

