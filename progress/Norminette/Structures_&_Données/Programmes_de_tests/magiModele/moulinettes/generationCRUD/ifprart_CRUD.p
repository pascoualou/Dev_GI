/*------------------------------------------------------------------------
File        : ifprart_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifprart
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifprart.i}
{application/include/error.i}
define variable ghttifprart as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phTypefac-cle as handle, output phArt-cle as handle, output phTaxe-cd as handle, output phSoc-dest as handle, output phEtab-dest as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/typefac-cle/art-cle/taxe-cd/soc-dest/etab-dest, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
            when 'art-cle' then phArt-cle = phBuffer:buffer-field(vi).
            when 'taxe-cd' then phTaxe-cd = phBuffer:buffer-field(vi).
            when 'soc-dest' then phSoc-dest = phBuffer:buffer-field(vi).
            when 'etab-dest' then phEtab-dest = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfprart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfprart.
    run updateIfprart.
    run createIfprart.
end procedure.

procedure setIfprart:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfprart.
    ghttIfprart = phttIfprart.
    run crudIfprart.
    delete object phttIfprart.
end procedure.

procedure readIfprart:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifprart 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcArt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter piEtab-dest   as integer    no-undo.
    define input parameter table-handle phttIfprart.
    define variable vhttBuffer as handle no-undo.
    define buffer ifprart for ifprart.

    vhttBuffer = phttIfprart:default-buffer-handle.
    for first ifprart no-lock
        where ifprart.soc-cd = piSoc-cd
          and ifprart.typefac-cle = pcTypefac-cle
          and ifprart.art-cle = pcArt-cle
          and ifprart.taxe-cd = piTaxe-cd
          and ifprart.soc-dest = piSoc-dest
          and ifprart.etab-dest = piEtab-dest:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfprart no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfprart:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifprart 
    Notes  : service externe. Critère piSoc-dest = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcArt-cle     as character  no-undo.
    define input parameter piTaxe-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter table-handle phttIfprart.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifprart for ifprart.

    vhttBuffer = phttIfprart:default-buffer-handle.
    if piSoc-dest = ?
    then for each ifprart no-lock
        where ifprart.soc-cd = piSoc-cd
          and ifprart.typefac-cle = pcTypefac-cle
          and ifprart.art-cle = pcArt-cle
          and ifprart.taxe-cd = piTaxe-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifprart no-lock
        where ifprart.soc-cd = piSoc-cd
          and ifprart.typefac-cle = pcTypefac-cle
          and ifprart.art-cle = pcArt-cle
          and ifprart.taxe-cd = piTaxe-cd
          and ifprart.soc-dest = piSoc-dest:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifprart:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfprart no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfprart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhEtab-dest    as handle  no-undo.
    define buffer ifprart for ifprart.

    create query vhttquery.
    vhttBuffer = ghttIfprart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfprart:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTypefac-cle, output vhArt-cle, output vhTaxe-cd, output vhSoc-dest, output vhEtab-dest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifprart exclusive-lock
                where rowid(ifprart) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifprart:handle, 'soc-cd/typefac-cle/art-cle/taxe-cd/soc-dest/etab-dest: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhArt-cle:buffer-value(), vhTaxe-cd:buffer-value(), vhSoc-dest:buffer-value(), vhEtab-dest:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifprart:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfprart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifprart for ifprart.

    create query vhttquery.
    vhttBuffer = ghttIfprart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfprart:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifprart.
            if not outils:copyValidField(buffer ifprart:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfprart private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhTaxe-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhEtab-dest    as handle  no-undo.
    define buffer ifprart for ifprart.

    create query vhttquery.
    vhttBuffer = ghttIfprart:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfprart:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhTypefac-cle, output vhArt-cle, output vhTaxe-cd, output vhSoc-dest, output vhEtab-dest).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifprart exclusive-lock
                where rowid(Ifprart) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifprart:handle, 'soc-cd/typefac-cle/art-cle/taxe-cd/soc-dest/etab-dest: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhArt-cle:buffer-value(), vhTaxe-cd:buffer-value(), vhSoc-dest:buffer-value(), vhEtab-dest:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifprart no-error.
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

