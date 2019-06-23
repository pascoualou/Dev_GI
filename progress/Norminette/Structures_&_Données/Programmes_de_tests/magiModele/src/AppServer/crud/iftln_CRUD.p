/*------------------------------------------------------------------------
File        : iftln_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iftln
Author(s)   : generation automatique le 08/08/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttiftln as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTprole as handle, output phSscptg-cd as handle, output phNum-int as handle, output phLig as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/tprole/sscptg-cd/num-int/lig, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'tprole' then phTprole = phBuffer:buffer-field(vi).
            when 'sscptg-cd' then phSscptg-cd = phBuffer:buffer-field(vi).
            when 'num-int' then phNum-int = phBuffer:buffer-field(vi).
            when 'lig' then phLig = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIftln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIftln.
    run updateIftln.
    run createIftln.
end procedure.

procedure setIftln:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIftln.
    ghttIftln = phttIftln.
    run crudIftln.
    delete object phttIftln.
end procedure.

procedure readIftln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iftln 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piTprole    as integer    no-undo.
    define input parameter pcSscptg-cd as character  no-undo.
    define input parameter piNum-int   as integer    no-undo.
    define input parameter piLig       as integer    no-undo.
    define input parameter table-handle phttIftln.
    define variable vhttBuffer as handle no-undo.
    define buffer iftln for iftln.

    vhttBuffer = phttIftln:default-buffer-handle.
    for first iftln no-lock
        where iftln.soc-cd = piSoc-cd
          and iftln.etab-cd = piEtab-cd
          and iftln.tprole = piTprole
          and iftln.sscptg-cd = pcSscptg-cd
          and iftln.num-int = piNum-int
          and iftln.lig = piLig:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iftln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIftln no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIftln:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iftln 
    Notes  : service externe. Critère piNum-int = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd    as integer    no-undo.
    define input parameter piEtab-cd   as integer    no-undo.
    define input parameter piTprole    as integer    no-undo.
    define input parameter pcSscptg-cd as character  no-undo.
    define input parameter piNum-int   as integer    no-undo.
    define input parameter table-handle phttIftln.
    define variable vhttBuffer as handle  no-undo.
    define buffer iftln for iftln.

    vhttBuffer = phttIftln:default-buffer-handle.
    if piNum-int = ?
    then for each iftln no-lock
        where iftln.soc-cd = piSoc-cd
          and iftln.etab-cd = piEtab-cd
          and iftln.tprole = piTprole
          and iftln.sscptg-cd = pcSscptg-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iftln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iftln no-lock
        where iftln.soc-cd = piSoc-cd
          and iftln.etab-cd = piEtab-cd
          and iftln.tprole = piTprole
          and iftln.sscptg-cd = pcSscptg-cd
          and iftln.num-int = piNum-int:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iftln:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIftln no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIftln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd   as handle  no-undo.
    define variable vhTprole    as handle  no-undo.
    define variable vhSscptg-cd as handle  no-undo.
    define variable vhNum-int   as handle  no-undo.
    define variable vhLig       as handle  no-undo.
    define buffer iftln for iftln.

    create query vhttquery.
    vhttBuffer = ghttIftln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIftln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTprole, output vhSscptg-cd, output vhNum-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iftln exclusive-lock
                where rowid(iftln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iftln:handle, 'soc-cd/etab-cd/tprole/sscptg-cd/num-int/lig: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTprole:buffer-value(), vhSscptg-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer iftln:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIftln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iftln for iftln.

    create query vhttquery.
    vhttBuffer = ghttIftln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIftln:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iftln.
            if not outils:copyValidField(buffer iftln:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIftln private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd   as handle  no-undo.
    define variable vhTprole    as handle  no-undo.
    define variable vhSscptg-cd as handle  no-undo.
    define variable vhNum-int   as handle  no-undo.
    define variable vhLig       as handle  no-undo.
    define buffer iftln for iftln.

    create query vhttquery.
    vhttBuffer = ghttIftln:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIftln:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTprole, output vhSscptg-cd, output vhNum-int, output vhLig).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iftln exclusive-lock
                where rowid(Iftln) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iftln:handle, 'soc-cd/etab-cd/tprole/sscptg-cd/num-int/lig: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTprole:buffer-value(), vhSscptg-cd:buffer-value(), vhNum-int:buffer-value(), vhLig:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iftln no-error.
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

