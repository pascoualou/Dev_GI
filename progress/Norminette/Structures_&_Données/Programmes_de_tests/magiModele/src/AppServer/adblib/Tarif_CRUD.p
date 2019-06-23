/*------------------------------------------------------------------------
File        : tarif_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table tarif
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
derniere revue: 2018/05/14 - phm: KO
          traiter les todo
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
define variable ghttTarif as handle no-undo.     // le handle de la temp table � mettre � jour

function getIndexField returns logical private(phBuffer as handle, output phCdart as handle, output phNofou as handle, output phNoimm as handle, output phNomdt as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur CdArt/NoFou/NoImm/nomdt, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cdart' then phCdart = phBuffer:buffer-field(vi).
            when 'nofou' then phNofou = phBuffer:buffer-field(vi).
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
            when 'nomdt' then phNomdt = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudTarif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTarif.
    run updateTarif.
    run createTarif.
end procedure.

procedure setTarif:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTarif.
    ghttTarif = phttTarif.
    run crudTarif.
    delete object phttTarif.
end procedure.

procedure readTarif:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tarif Chaine Travaux : Table des tarifs
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCdart as character no-undo.
    define input parameter piNofou as integer   no-undo.
    define input parameter piNoimm as integer   no-undo.
    define input parameter piNomdt as integer   no-undo.
    define input parameter table-handle phttTarif.

    define variable vhttBuffer as handle no-undo.
    define buffer tarif for tarif.

    vhttBuffer = phttTarif:default-buffer-handle.
    for first tarif no-lock
        where tarif.cdart = pcCdart
          and tarif.nofou = piNofou
          and tarif.noimm = piNoimm
          and tarif.nomdt = piNomdt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tarif:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTarif no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getTarif:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table tarif Chaine Travaux : Table des tarifs
    Notes  : service externe. Crit�re piNoimm = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCdart as character no-undo.
    define input parameter piNofou as integer   no-undo.
    define input parameter piNoimm as integer   no-undo.
    define input parameter table-handle phttTarif.

    define variable vhttBuffer as handle  no-undo.
    define buffer tarif for tarif.

    vhttBuffer = phttTarif:default-buffer-handle.
    if piNoimm = ?
    then for each tarif no-lock
        where tarif.cdart = pcCdart
          and tarif.nofou = piNofou:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tarif:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each tarif no-lock
        where tarif.cdart = pcCdart
          and tarif.nofou = piNofou
          and tarif.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tarif:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTarif no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateTarif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCdart    as handle  no-undo.
    define variable vhNofou    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer tarif for tarif.

    create query vhttquery.
    vhttBuffer = ghttTarif:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTarif:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdart, output vhNofou, output vhNoimm, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tarif exclusive-lock
                where rowid(Tarif) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tarif:handle, 'CdArt/NoFou/NoImm/nomdt: ', substitute('&1/&2/&3/&4', vhCdart:buffer-value(), vhNofou:buffer-value(), vhNoimm:buffer-value(), vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tarif:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createTarif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer tarif for tarif.

    create query vhttquery.
    vhttBuffer = ghttTarif:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTarif:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create tarif.
            if not outils:copyValidField(buffer tarif:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTarif private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhCdart    as handle  no-undo.
    define variable vhNofou    as handle  no-undo.
    define variable vhNoimm    as handle  no-undo.
    define variable vhNomdt    as handle  no-undo.
    define buffer tarif for tarif.

    create query vhttquery.
    vhttBuffer = ghttTarif:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTarif:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCdart, output vhNofou, output vhNoimm, output vhNomdt).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tarif exclusive-lock
                where rowid(Tarif) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tarif:handle, 'CdArt/NoFou/NoImm/nomdt: ', substitute('&1/&2/&3/&4', vhCdart:buffer-value(), vhNofou:buffer-value(), vhNoimm:buffer-value(), vhNomdt:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete tarif no-error.
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

procedure deleteTarifSurNofou:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroFournisseur as integer no-undo.

    define buffer tarif for tarif.
    
message "deleteTarifSurNofou "  piNumeroFournisseur.

blocTrans:
    do transaction:
        for each tarif no-lock   
           where tarif.nofou = piNumeroFournisseur:
            find current tarif exclusive-lock.    
            delete tarif no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
