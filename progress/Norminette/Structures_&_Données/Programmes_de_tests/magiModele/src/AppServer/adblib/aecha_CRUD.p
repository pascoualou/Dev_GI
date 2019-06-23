/*------------------------------------------------------------------------
File        : aecha_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table aecha
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
derniere revue: 2018/04/27 - phm: OK
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
define variable ghttaecha as handle no-undo.     // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phSoc-cd as handle, output phEtab-cd as handle, output phCpt-cd as handle, output phMois-cpt as handle, output phDaech as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur soc-cd/etab-cd/cpt-cd/mois-cpt/daech, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'soc-cd'   then phSoc-cd   = phBuffer:buffer-field(vi).
            when 'etab-cd'  then phEtab-cd  = phBuffer:buffer-field(vi).
            when 'cpt-cd'   then phCpt-cd   = phBuffer:buffer-field(vi).
            when 'mois-cpt' then phMois-cpt = phBuffer:buffer-field(vi).
            when 'daech'    then phDaech    = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudAecha private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteAecha.
    run updateAecha.
    run createAecha.
end procedure.

procedure setAecha:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttAecha.
    ghttAecha = phttAecha.
    run crudAecha.
    delete object phttAecha.
end procedure.

procedure readAecha:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table aecha 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer   no-undo.
    define input parameter piEtab-cd  as integer   no-undo.
    define input parameter pcCpt-cd   as character no-undo.
    define input parameter piMois-cpt as integer   no-undo.
    define input parameter pdaDaech   as date      no-undo.
    define input parameter table-handle phttAecha.

    define variable vhttBuffer as handle no-undo.
    define buffer aecha for aecha.

    vhttBuffer = phttAecha:default-buffer-handle.
    for first aecha no-lock
        where aecha.soc-cd   = piSoc-cd
          and aecha.etab-cd  = piEtab-cd
          and aecha.cpt-cd   = pcCpt-cd
          and aecha.mois-cpt = piMois-cpt
          and aecha.daech    = pdaDaech:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aecha:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAecha no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getAecha:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table aecha 
    Notes  : service externe. Critère piMois-cpt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter piSoc-cd   as integer   no-undo.
    define input parameter piEtab-cd  as integer   no-undo.
    define input parameter pcCpt-cd   as character no-undo.
    define input parameter piMois-cpt as integer   no-undo.
    define input parameter table-handle phttAecha.

    define variable vhttBuffer as handle  no-undo.
    define buffer aecha for aecha.

    vhttBuffer = phttAecha:default-buffer-handle.
    if piMois-cpt = ?
    then for each aecha no-lock
        where aecha.soc-cd  = piSoc-cd
          and aecha.etab-cd = piEtab-cd
          and aecha.cpt-cd  = pcCpt-cd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aecha:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each aecha no-lock
        where aecha.soc-cd   = piSoc-cd
          and aecha.etab-cd  = piEtab-cd
          and aecha.cpt-cd   = pcCpt-cd
          and aecha.mois-cpt = piMois-cpt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer aecha:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttAecha no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateAecha private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhEtab-cd  as handle  no-undo.
    define variable vhCpt-cd   as handle  no-undo.
    define variable vhMois-cpt as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define buffer aecha for aecha.

    create query vhttquery.
    vhttBuffer = ghttAecha:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttAecha:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCpt-cd, output vhMois-cpt, output vhDaech).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aecha exclusive-lock
                where rowid(aecha) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aecha:handle, 'soc-cd/etab-cd/cpt-cd/mois-cpt/daech: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCpt-cd:buffer-value(), vhMois-cpt:buffer-value(), vhDaech:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer aecha:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createAecha private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define buffer aecha for aecha.

    create query vhttquery.
    vhttBuffer = ghttAecha:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttAecha:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create aecha.
            if not outils:copyValidField(buffer aecha:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteAecha private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable vhSoc-cd   as handle  no-undo.
    define variable vhEtab-cd  as handle  no-undo.
    define variable vhCpt-cd   as handle  no-undo.
    define variable vhMois-cpt as handle  no-undo.
    define variable vhDaech    as handle  no-undo.
    define buffer aecha for aecha.

    create query vhttquery.
    vhttBuffer = ghttAecha:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttAecha:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhSoc-cd, output vhEtab-cd, output vhCpt-cd, output vhMois-cpt, output vhDaech).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first aecha exclusive-lock
                where rowid(Aecha) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer aecha:handle, 'soc-cd/etab-cd/cpt-cd/mois-cpt/daech: ', substitute('&1/&2/&3/&4/&5', vhSoc-cd:buffer-value(), vhEtab-cd:buffer-value(), vhCpt-cd:buffer-value(), vhMois-cpt:buffer-value(), vhDaech:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete aecha no-error.
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

procedure deleteAechaMandatEtProprietaire:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSociete          as integer   no-undo.
    define input parameter piMandat           as integer   no-undo.
    define input parameter pcCompteIndividuel as character no-undo.
    define input parameter piMoisComptable    as integer   no-undo.
    define buffer aecha for aecha.

blocTrans:
    do transaction:
        for each aecha exclusive-lock
            where aecha.soc-cd    = piSociete
              and aecha.etab-cd   = piMandat
              and aecha.cpt-cd    = pcCompteIndividuel
              and aecha.mois-cpt  >= piMoisComptable
              and aecha.mode-gest <> "S"
              and aecha.fg-compta = no:
            delete aecha no-error.
            if error-status:error
            then do:
                mError:createError({&error},  error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
end procedure.

procedure deleteAechaSurMandat:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piSociete      as integer no-undo.
    define input parameter piNumeroMandat as integer no-undo.
    
    define buffer aecha for aecha.

blocTrans:
    do transaction:
        for each aecha exclusive-lock 
            where aecha.soc-cd          = piSociete
              and aecha.etab-cd         = piNumeroMandat:
            delete aecha no-error.
            if error-status:error
            then do:
                mError:createError({&error},  error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
end procedure.
