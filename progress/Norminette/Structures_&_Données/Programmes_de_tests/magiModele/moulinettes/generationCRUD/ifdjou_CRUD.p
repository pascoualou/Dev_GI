/*------------------------------------------------------------------------
File        : ifdjou_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table ifdjou
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
//{include/ifdjou.i}
{application/include/error.i}
define variable ghttifdjou as handle no-undo.      // le handle de la temp table � mettre � jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phSoc-dest as handle, output phTypefac-cle as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/soc-dest/typefac-cle, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'soc-dest' then phSoc-dest = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdjou.
    run updateIfdjou.
    run createIfdjou.
end procedure.

procedure setIfdjou:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdjou.
    ghttIfdjou = phttIfdjou.
    run crudIfdjou.
    delete object phttIfdjou.
end procedure.

procedure readIfdjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdjou tables des journaux facturation
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter table-handle phttIfdjou.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdjou for ifdjou.

    vhttBuffer = phttIfdjou:default-buffer-handle.
    for first ifdjou no-lock
        where ifdjou.soc-cd = piSoc-cd
          and ifdjou.etab-cd = piEtab-cd
          and ifdjou.soc-dest = piSoc-dest
          and ifdjou.typefac-cle = pcTypefac-cle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdjou no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdjou:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdjou tables des journaux facturation
    Notes  : service externe. Crit�re piSoc-dest = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter piSoc-dest    as integer    no-undo.
    define input parameter table-handle phttIfdjou.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdjou for ifdjou.

    vhttBuffer = phttIfdjou:default-buffer-handle.
    if piSoc-dest = ?
    then for each ifdjou no-lock
        where ifdjou.soc-cd = piSoc-cd
          and ifdjou.etab-cd = piEtab-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdjou no-lock
        where ifdjou.soc-cd = piSoc-cd
          and ifdjou.etab-cd = piEtab-cd
          and ifdjou.soc-dest = piSoc-dest:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdjou:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdjou no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define buffer ifdjou for ifdjou.

    create query vhttquery.
    vhttBuffer = ghttIfdjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdjou exclusive-lock
                where rowid(ifdjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdjou:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdjou:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdjou for ifdjou.

    create query vhttquery.
    vhttBuffer = ghttIfdjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdjou:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdjou.
            if not outils:copyValidField(buffer ifdjou:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdjou private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhSoc-dest    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define buffer ifdjou for ifdjou.

    create query vhttquery.
    vhttBuffer = ghttIfdjou:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdjou:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhSoc-dest, output vhTypefac-cle).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdjou exclusive-lock
                where rowid(Ifdjou) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdjou:handle, 'soc-cd/etab-cd/soc-dest/typefac-cle: ', substitute('&1/&2/&3/&4', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhSoc-dest:buffer-value(), vhTypefac-cle:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdjou no-error.
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

