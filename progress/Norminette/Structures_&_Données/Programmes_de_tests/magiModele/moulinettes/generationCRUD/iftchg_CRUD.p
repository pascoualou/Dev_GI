/*------------------------------------------------------------------------
File        : iftchg_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iftchg
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/iftchg.i}
{application/include/error.i}
define variable ghttiftchg as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTprole as handle, output phSscptg-cd as handle, output phNoexo as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/tprole/sscptg-cd/noexo/lig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'tprole' then phTprole = phBuffer:buffer-field(vi).
            when 'sscptg-cd' then phSscptg-cd = phBuffer:buffer-field(vi).
            when 'noexo' then phNoexo = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIftchg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIftchg.
    run updateIftchg.
    run createIftchg.
end procedure.

procedure setIftchg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIftchg.
    ghttIftchg = phttIftchg.
    run crudIftchg.
    delete object phttIftchg.
end procedure.

procedure readIftchg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iftchg 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piTprole    as integer    no-undo.
    define input parameter pcSscptg-cd as character  no-undo.
    define input parameter piNoexo     as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter table-handle phttIftchg.
    define variable vhttBuffer as handle no-undo.
    define buffer iftchg for iftchg.

    vhttBuffer = phttIftchg:default-buffer-handle.
    for first iftchg no-lock
        where iftchg.soc-cd = piSoc-cd
          and iftchg.etab-cd = piEtab-cd
          and iftchg.tprole = piTprole
          and iftchg.sscptg-cd = pcSscptg-cd
          and iftchg.noexo = piNoexo
          and iftchg.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iftchg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIftchg no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIftchg:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iftchg 
    Notes  : service externe. Critère piNoexo = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piTprole    as integer    no-undo.
    define input parameter pcSscptg-cd as character  no-undo.
    define input parameter piNoexo     as integer    no-undo.
    define input parameter table-handle phttIftchg.
    define variable vhttBuffer as handle  no-undo.
    define buffer iftchg for iftchg.

    vhttBuffer = phttIftchg:default-buffer-handle.
    if piNoexo = ?
    then for each iftchg no-lock
        where iftchg.soc-cd = piSoc-cd
          and iftchg.etab-cd = piEtab-cd
          and iftchg.tprole = piTprole
          and iftchg.sscptg-cd = pcSscptg-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iftchg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iftchg no-lock
        where iftchg.soc-cd = piSoc-cd
          and iftchg.etab-cd = piEtab-cd
          and iftchg.tprole = piTprole
          and iftchg.sscptg-cd = pcSscptg-cd
          and iftchg.noexo = piNoexo:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iftchg:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIftchg no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIftchg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTprole    as handle  no-undo.
    define variable vhSscptg-cd    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer iftchg for iftchg.

    create query vhttquery.
    vhttBuffer = ghttIftchg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIftchg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTprole, output vhSscptg-cd, output vhNoexo, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iftchg exclusive-lock
                where rowid(iftchg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iftchg:handle, 'soc-cd/etab-cd/tprole/sscptg-cd/noexo/lig: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTprole:buffer-value(), vhSscptg-cd:buffer-value(), vhNoexo:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iftchg:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIftchg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iftchg for iftchg.

    create query vhttquery.
    vhttBuffer = ghttIftchg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIftchg:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iftchg.
            if not outils:copyValidField(buffer iftchg:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIftchg private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTprole    as handle  no-undo.
    define variable vhSscptg-cd    as handle  no-undo.
    define variable vhNoexo    as handle  no-undo.
    define variable vhLig    as handle  no-undo.
    define buffer iftchg for iftchg.

    create query vhttquery.
    vhttBuffer = ghttIftchg:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIftchg:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTprole, output vhSscptg-cd, output vhNoexo, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iftchg exclusive-lock
                where rowid(Iftchg) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iftchg:handle, 'soc-cd/etab-cd/tprole/sscptg-cd/noexo/lig: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTprole:buffer-value(), vhSscptg-cd:buffer-value(), vhNoexo:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iftchg no-error.
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

