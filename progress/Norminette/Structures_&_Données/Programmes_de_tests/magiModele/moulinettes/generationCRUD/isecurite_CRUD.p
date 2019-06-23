/*------------------------------------------------------------------------
File        : isecurite_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table isecurite
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/isecurite.i}
{application/include/error.i}
define variable ghttisecurite as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phMenu-titre as handle, output phMenu-nom as handle, output phPrognom as handle, output phSpecifique-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur menu-titre/menu-nom/prognom/specifique-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'menu-titre' then phMenu-titre = phBuffer:buffer-field(vi).
            when 'menu-nom' then phMenu-nom = phBuffer:buffer-field(vi).
            when 'prognom' then phPrognom = phBuffer:buffer-field(vi).
            when 'specifique-cle' then phSpecifique-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIsecurite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIsecurite.
    run updateIsecurite.
    run createIsecurite.
end procedure.

procedure setIsecurite:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIsecurite.
    ghttIsecurite = phttIsecurite.
    run crudIsecurite.
    delete object phttIsecurite.
end procedure.

procedure readIsecurite:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table isecurite Fichier descriptif des securites suivant les utilisateurs.
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcMenu-titre     as character  no-undo.
    define input parameter pcMenu-nom       as character  no-undo.
    define input parameter pcPrognom        as character  no-undo.
    define input parameter pcSpecifique-cle as character  no-undo.
    define input parameter table-handle phttIsecurite.
    define variable vhttBuffer as handle no-undo.
    define buffer isecurite for isecurite.

    vhttBuffer = phttIsecurite:default-buffer-handle.
    for first isecurite no-lock
        where isecurite.menu-titre = pcMenu-titre
          and isecurite.menu-nom = pcMenu-nom
          and isecurite.prognom = pcPrognom
          and isecurite.specifique-cle = pcSpecifique-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer isecurite:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIsecurite no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIsecurite:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table isecurite Fichier descriptif des securites suivant les utilisateurs.
    Notes  : service externe. Critère pcPrognom = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcMenu-titre     as character  no-undo.
    define input parameter pcMenu-nom       as character  no-undo.
    define input parameter pcPrognom        as character  no-undo.
    define input parameter table-handle phttIsecurite.
    define variable vhttBuffer as handle  no-undo.
    define buffer isecurite for isecurite.

    vhttBuffer = phttIsecurite:default-buffer-handle.
    if pcPrognom = ?
    then for each isecurite no-lock
        where isecurite.menu-titre = pcMenu-titre
          and isecurite.menu-nom = pcMenu-nom:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer isecurite:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each isecurite no-lock
        where isecurite.menu-titre = pcMenu-titre
          and isecurite.menu-nom = pcMenu-nom
          and isecurite.prognom = pcPrognom:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer isecurite:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIsecurite no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIsecurite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhMenu-titre    as handle  no-undo.
    define variable vhMenu-nom    as handle  no-undo.
    define variable vhPrognom    as handle  no-undo.
    define variable vhSpecifique-cle    as handle  no-undo.
    define buffer isecurite for isecurite.

    create query vhttquery.
    vhttBuffer = ghttIsecurite:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIsecurite:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhMenu-titre, output vhMenu-nom, output vhPrognom, output vhSpecifique-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first isecurite exclusive-lock
                where rowid(isecurite) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer isecurite:handle, 'menu-titre/menu-nom/prognom/specifique-cle: ', substitute('&1/&2/&3/&4', vhMenu-titre:buffer-value(), vhMenu-nom:buffer-value(), vhPrognom:buffer-value(), vhSpecifique-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer isecurite:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIsecurite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer isecurite for isecurite.

    create query vhttquery.
    vhttBuffer = ghttIsecurite:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIsecurite:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create isecurite.
            if not outils:copyValidField(buffer isecurite:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIsecurite private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhMenu-titre    as handle  no-undo.
    define variable vhMenu-nom    as handle  no-undo.
    define variable vhPrognom    as handle  no-undo.
    define variable vhSpecifique-cle    as handle  no-undo.
    define buffer isecurite for isecurite.

    create query vhttquery.
    vhttBuffer = ghttIsecurite:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIsecurite:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhMenu-titre, output vhMenu-nom, output vhPrognom, output vhSpecifique-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first isecurite exclusive-lock
                where rowid(Isecurite) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer isecurite:handle, 'menu-titre/menu-nom/prognom/specifique-cle: ', substitute('&1/&2/&3/&4', vhMenu-titre:buffer-value(), vhMenu-nom:buffer-value(), vhPrognom:buffer-value(), vhSpecifique-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete isecurite no-error.
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

