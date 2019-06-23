/*------------------------------------------------------------------------
File        : Emprunt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table Emprunt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/Emprunt.i}
{application/include/error.i}
define variable ghttEmprunt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phTpcon as handle, output phNocon as handle, output phTpemp as handle, output phNoemp as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur TpCon/NoCon/TpEmp/NoEmp, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'TpCon' then phTpcon = phBuffer:buffer-field(vi).
            when 'NoCon' then phNocon = phBuffer:buffer-field(vi).
            when 'TpEmp' then phTpemp = phBuffer:buffer-field(vi).
            when 'NoEmp' then phNoemp = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudEmprunt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteEmprunt.
    run updateEmprunt.
    run createEmprunt.
end procedure.

procedure setEmprunt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttEmprunt.
    ghttEmprunt = phttEmprunt.
    run crudEmprunt.
    delete object phttEmprunt.
end procedure.

procedure readEmprunt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table Emprunt Emprunts : Table Emprunts
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter pcTpemp as character  no-undo.
    define input parameter piNoemp as integer    no-undo.
    define input parameter table-handle phttEmprunt.
    define variable vhttBuffer as handle no-undo.
    define buffer Emprunt for Emprunt.

    vhttBuffer = phttEmprunt:default-buffer-handle.
    for first Emprunt no-lock
        where Emprunt.TpCon = pcTpcon
          and Emprunt.NoCon = piNocon
          and Emprunt.TpEmp = pcTpemp
          and Emprunt.NoEmp = piNoemp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Emprunt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEmprunt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getEmprunt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table Emprunt Emprunts : Table Emprunts
    Notes  : service externe. Critère pcTpemp = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpcon as character  no-undo.
    define input parameter piNocon as integer    no-undo.
    define input parameter pcTpemp as character  no-undo.
    define input parameter table-handle phttEmprunt.
    define variable vhttBuffer as handle  no-undo.
    define buffer Emprunt for Emprunt.

    vhttBuffer = phttEmprunt:default-buffer-handle.
    if pcTpemp = ?
    then for each Emprunt no-lock
        where Emprunt.TpCon = pcTpcon
          and Emprunt.NoCon = piNocon:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Emprunt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each Emprunt no-lock
        where Emprunt.TpCon = pcTpcon
          and Emprunt.NoCon = piNocon
          and Emprunt.TpEmp = pcTpemp:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer Emprunt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttEmprunt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateEmprunt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTpemp    as handle  no-undo.
    define variable vhNoemp    as handle  no-undo.
    define buffer Emprunt for Emprunt.

    create query vhttquery.
    vhttBuffer = ghttEmprunt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttEmprunt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTpemp, output vhNoemp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Emprunt exclusive-lock
                where rowid(Emprunt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Emprunt:handle, 'TpCon/NoCon/TpEmp/NoEmp: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTpemp:buffer-value(), vhNoemp:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer Emprunt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createEmprunt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer Emprunt for Emprunt.

    create query vhttquery.
    vhttBuffer = ghttEmprunt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttEmprunt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create Emprunt.
            if not outils:copyValidField(buffer Emprunt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteEmprunt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpcon    as handle  no-undo.
    define variable vhNocon    as handle  no-undo.
    define variable vhTpemp    as handle  no-undo.
    define variable vhNoemp    as handle  no-undo.
    define buffer Emprunt for Emprunt.

    create query vhttquery.
    vhttBuffer = ghttEmprunt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttEmprunt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpcon, output vhNocon, output vhTpemp, output vhNoemp).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first Emprunt exclusive-lock
                where rowid(Emprunt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer Emprunt:handle, 'TpCon/NoCon/TpEmp/NoEmp: ', substitute('&1/&2/&3/&4', vhTpcon:buffer-value(), vhNocon:buffer-value(), vhTpemp:buffer-value(), vhNoemp:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete Emprunt no-error.
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

