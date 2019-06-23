/*------------------------------------------------------------------------
File        : frsdt_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table frsdt
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/frsdt.i}
{application/include/error.i}
define variable ghttfrsdt as handle no-undo.      // le handle de la temp table à mettre à jour


function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phMois-cpt as handle, output phFam-cle as handle, output phSfam-cle as handle, output phArt-cle as handle, output phCdcle as handle, output phDaech as handle, output phNoord as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/mois-cpt/fam-cle/sfam-cle/art-cle/cdcle/daech/noord, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd' then phSoc-cd = phBuffer:buffer-field(vi).
            when 'etab-cd' then phEtab-cd = phBuffer:buffer-field(vi).
            when 'mois-cpt' then phMois-cpt = phBuffer:buffer-field(vi).
            when 'fam-cle' then phFam-cle = phBuffer:buffer-field(vi).
            when 'sfam-cle' then phSfam-cle = phBuffer:buffer-field(vi).
            when 'art-cle' then phArt-cle = phBuffer:buffer-field(vi).
            when 'cdcle' then phCdcle = phBuffer:buffer-field(vi).
            when 'daech' then phDaech = phBuffer:buffer-field(vi).
            when 'noord' then phNoord = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudFrsdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteFrsdt.
    run updateFrsdt.
    run createFrsdt.
end procedure.

procedure setFrsdt:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttFrsdt.
    ghttFrsdt = phttFrsdt.
    run crudFrsdt.
    delete object phttFrsdt.
end procedure.

procedure readFrsdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table frsdt 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piMois-cpt as integer    no-undo.
    define input parameter pcFam-cle  as character  no-undo.
    define input parameter pcSfam-cle as character  no-undo.
    define input parameter pcArt-cle  as character  no-undo.
    define input parameter pcCdcle    as character  no-undo.
    define input parameter pdaDaech    as date       no-undo.
    define input parameter piNoord    as integer    no-undo.
    define input parameter table-handle phttFrsdt.
    define variable vhttBuffer as handle no-undo.
    define buffer frsdt for frsdt.

    vhttBuffer = phttFrsdt:default-buffer-handle.
    for first frsdt no-lock
        where frsdt.soc-cd = piSoc-cd
          and frsdt.etab-cd = piEtab-cd
          and frsdt.mois-cpt = piMois-cpt
          and frsdt.fam-cle = pcFam-cle
          and frsdt.sfam-cle = pcSfam-cle
          and frsdt.art-cle = pcArt-cle
          and frsdt.cdcle = pcCdcle
          and frsdt.daech = pdaDaech
          and frsdt.noord = piNoord:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer frsdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFrsdt no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getFrsdt:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table frsdt 
    Notes  : service externe. Critère pdaDaech = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer    no-undo.
    define input parameter piEtab-cd  as integer    no-undo.
    define input parameter piMois-cpt as integer    no-undo.
    define input parameter pcFam-cle  as character  no-undo.
    define input parameter pcSfam-cle as character  no-undo.
    define input parameter pcArt-cle  as character  no-undo.
    define input parameter pcCdcle    as character  no-undo.
    define input parameter pdaDaech    as date       no-undo.
    define input parameter table-handle phttFrsdt.
    define variable vhttBuffer as handle  no-undo.
    define buffer frsdt for frsdt.

    vhttBuffer = phttFrsdt:default-buffer-handle.
    if pdaDaech = ?
    then for each frsdt no-lock
        where frsdt.soc-cd = piSoc-cd
          and frsdt.etab-cd = piEtab-cd
          and frsdt.mois-cpt = piMois-cpt
          and frsdt.fam-cle = pcFam-cle
          and frsdt.sfam-cle = pcSfam-cle
          and frsdt.art-cle = pcArt-cle
          and frsdt.cdcle = pcCdcle:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer frsdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each frsdt no-lock
        where frsdt.soc-cd = piSoc-cd
          and frsdt.etab-cd = piEtab-cd
          and frsdt.mois-cpt = piMois-cpt
          and frsdt.fam-cle = pcFam-cle
          and frsdt.sfam-cle = pcSfam-cle
          and frsdt.art-cle = pcArt-cle
          and frsdt.cdcle = pcCdcle
          and frsdt.daech = pdaDaech:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer frsdt:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttFrsdt no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateFrsdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhMois-cpt    as handle  no-undo.
    define variable vhFam-cle    as handle  no-undo.
    define variable vhSfam-cle    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer frsdt for frsdt.

    create query vhttquery.
    vhttBuffer = ghttFrsdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttFrsdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhMois-cpt, output vhFam-cle, output vhSfam-cle, output vhArt-cle, output vhCdcle, output vhDaech, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first frsdt exclusive-lock
                where rowid(frsdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer frsdt:handle, 'soc-cd/etab-cd/mois-cpt/fam-cle/sfam-cle/art-cle/cdcle/daech/noord: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhMois-cpt:buffer-value(), vhFam-cle:buffer-value(), vhSfam-cle:buffer-value(), vhArt-cle:buffer-value(), vhCdcle:buffer-value(), vhDaech:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer frsdt:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createFrsdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer frsdt for frsdt.

    create query vhttquery.
    vhttBuffer = ghttFrsdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttFrsdt:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create frsdt.
            if not outils:copyValidField(buffer frsdt:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteFrsdt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhSoc-cd    as handle  no-undo.
    define variable vhEtab-cd    as handle  no-undo.
    define variable vhMois-cpt    as handle  no-undo.
    define variable vhFam-cle    as handle  no-undo.
    define variable vhSfam-cle    as handle  no-undo.
    define variable vhArt-cle    as handle  no-undo.
    define variable vhCdcle    as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define variable vhNoord    as handle  no-undo.
    define buffer frsdt for frsdt.

    create query vhttquery.
    vhttBuffer = ghttFrsdt:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttFrsdt:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhMois-cpt, output vhFam-cle, output vhSfam-cle, output vhArt-cle, output vhCdcle, output vhDaech, output vhNoord).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first frsdt exclusive-lock
                where rowid(Frsdt) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer frsdt:handle, 'soc-cd/etab-cd/mois-cpt/fam-cle/sfam-cle/art-cle/cdcle/daech/noord: ', substitute('&1/&2/&3/&4/&5/&6/&7/&8/&9', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhMois-cpt:buffer-value(), vhFam-cle:buffer-value(), vhSfam-cle:buffer-value(), vhArt-cle:buffer-value(), vhCdcle:buffer-value(), vhDaech:buffer-value(), vhNoord:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete frsdt no-error.
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

