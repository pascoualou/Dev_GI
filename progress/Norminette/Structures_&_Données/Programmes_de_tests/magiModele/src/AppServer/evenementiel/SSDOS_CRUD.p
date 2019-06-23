/*------------------------------------------------------------------------
File        : SSDOS_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table SSDOS
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
//{include/SSDOS.i}
{application/include/error.i}
{application/include/glbsepar.i}
{outils/include/lancementProgramme.i}

define variable ghttSSDOS as handle no-undo.      // le handle de la temp table à mettre à jour

function getIndexField returns logical private(phBuffer as handle, output phTpidt as handle, output phNoidt as handle, output phNossd as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tpidt/noidt/nossd, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tpidt' then phTpidt = phBuffer:buffer-field(vi).
            when 'noidt' then phNoidt = phBuffer:buffer-field(vi).
            when 'nossd' then phNossd = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudSsdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteSsdos.
    run updateSsdos.
    run createSsdos.
end procedure.

procedure setSsdos:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttSsdos.
    ghttSsdos = phttSsdos.
    run crudSsdos.
    delete object phttSsdos.
end procedure.

procedure readSsdos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table SSDOS Sous-dossier
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as integer    no-undo.
    define input parameter piNossd as integer    no-undo.
    define input parameter table-handle phttSsdos.
    define variable vhttBuffer as handle no-undo.
    define buffer SSDOS for SSDOS.

    vhttBuffer = phttSsdos:default-buffer-handle.
    for first SSDOS no-lock
        where SSDOS.tpidt = pcTpidt
          and SSDOS.noidt = piNoidt
          and SSDOS.nossd = piNossd:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SSDOS:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSsdos no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getSsdos:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table SSDOS Sous-dossier
    Notes  : service externe. Critère piNoidt = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTpidt as character  no-undo.
    define input parameter piNoidt as integer    no-undo.
    define input parameter table-handle phttSsdos.
    define variable vhttBuffer as handle  no-undo.
    define buffer SSDOS for SSDOS.

    vhttBuffer = phttSsdos:default-buffer-handle.
    if piNoidt = ?
    then for each SSDOS no-lock
        where SSDOS.tpidt = pcTpidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SSDOS:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each SSDOS no-lock
        where SSDOS.tpidt = pcTpidt
          and SSDOS.noidt = piNoidt:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer SSDOS:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttSsdos no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateSsdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNossd    as handle  no-undo.
    define buffer SSDOS for SSDOS.

    create query vhttquery.
    vhttBuffer = ghttSsdos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttSsdos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhNossd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SSDOS exclusive-lock
                where rowid(SSDOS) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SSDOS:handle, 'tpidt/noidt/nossd: ', substitute('&1/&2/&3', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNossd:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer SSDOS:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createSsdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer SSDOS for SSDOS.

    create query vhttquery.
    vhttBuffer = ghttSsdos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttSsdos:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create SSDOS.
            if not outils:copyValidField(buffer SSDOS:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteSsdos private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTpidt    as handle  no-undo.
    define variable vhNoidt    as handle  no-undo.
    define variable vhNossd    as handle  no-undo.
    define buffer SSDOS for SSDOS.

    create query vhttquery.
    vhttBuffer = ghttSsdos:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttSsdos:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTpidt, output vhNoidt, output vhNossd).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first SSDOS exclusive-lock
                where rowid(Ssdos) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer SSDOS:handle, 'tpidt/noidt/nossd: ', substitute('&1/&2/&3', vhTpidt:buffer-value(), vhNoidt:buffer-value(), vhNossd:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete SSDOS no-error.
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

procedure deleteSsdosSurNoidt:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
             et des enregistrements des tables dependantes (lidoc, desti, lides, docum) 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as integer   no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.
    
    define variable viI     as integer   no-undo. 
    define variable vcTempo as character no-undo.
    
    define buffer ssdos   for ssdos.
    define buffer vbssdos for ssdos.

message "deleteSsdosSurNoidt "  pcTypeIdentifiant "// " piNumeroIdentifiant.

blocTrans:
    do transaction:
        for each ssdos exclusive-lock 
           where ssdos.tpidt = pcTypeIdentifiant
             and ssdos.noidt = piNumeroIdentifiant:             
            do viI = 1 to num-entries(ssdos.lbcor, separ[1]):
                vcTempo = entry(viI,ssdos.lbcor, separ[1]).
                for each vbssdos exclusive-lock 
                   where vbssdos.tpidt = entry(1, vcTempo, separ[2])
                     and vbssdos.noidt = integer(entry(2, vcTempo, separ[2]))
                     and vbssdos.nossd = integer(entry(3, vcTempo, separ[2])):
                    run deleteDepSsdos(vbssdos.tpidt, vbssdos.noidt, vbssdos.nossd, input-output poCollectionHandlePgm).
                    if mError:erreur()
                    then undo blocTrans, leave blocTrans.
                    delete vbssdos no-error.
                    if error-status:error then do:
                        mError:createError({&error}, error-status:get-message(1)).
                        undo blocTrans, leave blocTrans.
                    end.
                end.
            end.
            run deleteDepSsdos(ssdos.tpidt, ssdos.noidt, ssdos.nossd, input-output poCollectionHandlePgm).
            if mError:erreur()
            then undo blocTrans, leave blocTrans.            
            delete ssdos no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteDepSsdos private:
    /*------------------------------------------------------------------------------
    Purpose: suppression des enregistrements des tables dependantes (lidoc, desti, lides, docum) de ssdos 
    Notes  : 
    ------------------------------------------------------------------------------*/
    def input parameter pcTypeIdentifiant   as character no-undo.
    def input parameter piNumeroIdentifiant as integer   no-undo.
    def input parameter piNumeroSousDossier as integer   no-undo.
    define input-output parameter poCollectionHandlePgm as class collection no-undo.

    define variable vhProc as handle no-undo.
    
    define buffer lidoc for lidoc.
    define buffer desti for desti.
    define buffer lides for lides.
    define buffer docum for docum.  
    define buffer vblidoc for lidoc.

message "deleteDepSsdos "  pcTypeIdentifiant "// " piNumeroIdentifiant "// " piNumeroSousDossier.

blocTrans:
    do transaction:
        for each lidoc exclusive-lock  
           where lidoc.tpidt = pcTypeIdentifiant
             and lidoc.noidt = piNumeroIdentifiant
             and lidoc.nossd = piNumeroSousDossier:
            for each desti exclusive-lock
               where desti.nodoc = lidoc.nodoc:
                delete desti no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.  
                end.  
            end.
            for each lides exclusive-lock
               where lides.nodoc = lidoc.nodoc:
                delete lides no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans. 
                end.               
            end.
            for first docum exclusive-lock
                where docum.nodoc = lidoc.nodoc:
                for each vblidoc exclusive-lock
                   where vblidoc.nodoc = docum.nodoc
                     and vblidoc.nossd = 0:
                    delete vblidoc no-error.
                    if error-status:error then do:
                        mError:createError({&error}, error-status:get-message(1)).
                        undo blocTrans, leave blocTrans. 
                    end.               
                end.
                vhProc = lancementPgm ("evenementiel/event_CRUD.p", poCollectionHandlePgm).
                run deleteEventParType in vhProc("DOCUM", docum.nodoc, "", 0).
                /* Suppression du document si plus utilisé nulle-part */
                if not can-find(first vblidoc no-lock
                                where vblidoc.nodoc = docum.nodoc
                                  and vblidoc.nossd = piNumeroSousDossier)
                then do:
                    delete docum no-error.
                    if error-status:error then do:
                        mError:createError({&error}, error-status:get-message(1)).
                        undo blocTrans, leave blocTrans. 
                    end.               
                end.
            end.
            if available lidoc then delete lidoc no-error.      //si numéro de sous dossier est 0 l' enregistrement a pu etre supprime juste au dessus
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans. 
            end.               
        end.
    end.
    error-status:error = false no-error.  // reset error-status
    
end procedure.

