/*------------------------------------------------------------------------
File        : ifdhono_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table ifdhono
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/ifdhono.i}
{application/include/error.i}
define variable ghttifdhono as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phTypefac-cle as handle, output phAna4-cd as handle, output phMois-cpt as handle, output phDaech as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/typefac-cle/ana4-cd/mois-cpt/daech, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'typefac-cle' then phTypefac-cle = phBuffer:buffer-field(vi).
            when 'ana4-cd' then phAna4-cd = phBuffer:buffer-field(vi).
            when 'mois-cpt' then phMois-cpt = phBuffer:buffer-field(vi).
            when 'daech' then phDaech = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIfdhono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIfdhono.
    run updateIfdhono.
    run createIfdhono.
end procedure.

procedure setIfdhono:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIfdhono.
    ghttIfdhono = phttIfdhono.
    run crudIfdhono.
    delete object phttIfdhono.
end procedure.

procedure readIfdhono:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table ifdhono Table des honoraires de syndic
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcAna4-cd     as character  no-undo.
    define input parameter piMois-cpt    as integer    no-undo.
    define input parameter pdaDaech       as date       no-undo.
    define input parameter table-handle phttIfdhono.
    define variable vhttBuffer as handle no-undo.
    define buffer ifdhono for ifdhono.

    vhttBuffer = phttIfdhono:default-buffer-handle.
    for first ifdhono no-lock
        where ifdhono.soc-cd = piSoc-cd
          and ifdhono.etab-cd = piEtab-cd
          and ifdhono.typefac-cle = pcTypefac-cle
          and ifdhono.ana4-cd = pcAna4-cd
          and ifdhono.mois-cpt = piMois-cpt
          and ifdhono.daech = pdaDaech:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdhono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdhono no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIfdhono:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table ifdhono Table des honoraires de syndic
    Notes  : service externe. Critère piMois-cpt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd      as integer    no-undo.
    define input parameter piEtab-cd     as integer    no-undo.
    define input parameter pcTypefac-cle as character  no-undo.
    define input parameter pcAna4-cd     as character  no-undo.
    define input parameter piMois-cpt    as integer    no-undo.
    define input parameter table-handle phttIfdhono.
    define variable vhttBuffer as handle  no-undo.
    define buffer ifdhono for ifdhono.

    vhttBuffer = phttIfdhono:default-buffer-handle.
    if piMois-cpt = ?
    then for each ifdhono no-lock
        where ifdhono.soc-cd = piSoc-cd
          and ifdhono.etab-cd = piEtab-cd
          and ifdhono.typefac-cle = pcTypefac-cle
          and ifdhono.ana4-cd = pcAna4-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdhono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each ifdhono no-lock
        where ifdhono.soc-cd = piSoc-cd
          and ifdhono.etab-cd = piEtab-cd
          and ifdhono.typefac-cle = pcTypefac-cle
          and ifdhono.ana4-cd = pcAna4-cd
          and ifdhono.mois-cpt = piMois-cpt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer ifdhono:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIfdhono no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIfdhono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define variable vhMois-cpt    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define buffer ifdhono for ifdhono.

    create query vhttquery.
    vhttBuffer = ghttIfdhono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIfdhono:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhAna4-cd, output vhMois-cpt, output vhDaech).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdhono exclusive-lock
                where rowid(ifdhono) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdhono:handle, 'soc-cd/etab-cd/typefac-cle/ana4-cd/mois-cpt/daech: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhAna4-cd:buffer-value(), vhMois-cpt:buffer-value(), vhDaech:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer ifdhono:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIfdhono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer ifdhono for ifdhono.

    create query vhttquery.
    vhttBuffer = ghttIfdhono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIfdhono:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create ifdhono.
            if not outils:copyValidField(buffer ifdhono:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIfdhono private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhTypefac-cle    as handle  no-undo.
    define variable vhAna4-cd    as handle  no-undo.
    define variable vhMois-cpt    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define buffer ifdhono for ifdhono.

    create query vhttquery.
    vhttBuffer = ghttIfdhono:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIfdhono:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhTypefac-cle, output vhAna4-cd, output vhMois-cpt, output vhDaech).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first ifdhono exclusive-lock
                where rowid(Ifdhono) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer ifdhono:handle, 'soc-cd/etab-cd/typefac-cle/ana4-cd/mois-cpt/daech: ', substitute('&1/&2/&3/&4/&5/&6', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhTypefac-cle:buffer-value(), vhAna4-cd:buffer-value(), vhMois-cpt:buffer-value(), vhDaech:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete ifdhono no-error.
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

