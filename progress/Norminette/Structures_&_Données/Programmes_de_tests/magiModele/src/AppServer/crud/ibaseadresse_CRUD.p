/*------------------------------------------------------------------------
File        : iBaseAdresse_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iBaseAdresse
Author(s)   : generation automatique le 22/10/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2adresse.i}

using parametre.pclie.parametrageBnp.  //gga todo a deplacer apres test dans ilienadressecrud (evenement sur ladrs pas sur adres)         
 
{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using

{crud/include/iBaseAdresse.i}

define variable ghttiBaseAdresse as handle no-undo.      // le handle de la temp table à mettre à jour
define variable ghProc as handle no-undo.
define variable ghMdmws as handle no-undo.
define variable glEnvBnp as logical no-undo.

function getIndexField returns logical private(phBuffer as handle, output phInumeroadresse as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur iNumeroAdresse, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'iNumeroAdresse' then phInumeroadresse = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIbaseadresse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIbaseadresse.
    run updateIbaseadresse.
    run createIbaseadresse.
end procedure.

procedure setIbaseadresse:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIbaseadresse.
    define variable voBnp as class parametrageBnp no-undo.    
    ghttIbaseadresse = phttIbaseadresse.
    voBnp = new parametrageBnp().
    glEnvBnp = voBnp:isDbParameter. 
    delete object voBnp.      
    run crudIbaseadresse.
    delete object phttIbaseadresse.
    if valid-handle (ghProc) then run destroy in ghProc.
    
end procedure.

procedure readIbaseadresse:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iBaseAdresse Base des adresses utilisées
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piInumeroadresse as int64      no-undo.
    define input parameter table-handle phttIbaseadresse.
    define variable vhttBuffer as handle no-undo.
    define buffer iBaseAdresse for iBaseAdresse.

    vhttBuffer = phttIbaseadresse:default-buffer-handle.
    for first iBaseAdresse no-lock
        where iBaseAdresse.iNumeroAdresse = piInumeroadresse:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iBaseAdresse:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIbaseadresse no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIbaseadresse:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iBaseAdresse Base des adresses utilisées
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIbaseadresse.
    define variable vhttBuffer as handle  no-undo.
    define buffer iBaseAdresse for iBaseAdresse.

    vhttBuffer = phttIbaseadresse:default-buffer-handle.
    for each iBaseAdresse no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iBaseAdresse:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIbaseadresse no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIbaseadresse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery             as handle  no-undo.
    define variable vhttBuffer            as handle  no-undo.
    define variable vhInumeroadresse      as handle  no-undo.
    define variable vlModificationAdresse as logical no-undo.
    define buffer iBaseAdresse for iBaseAdresse.

    empty temp-table ttIbaseadresse.
    create query vhttquery.
    vhttBuffer = ghttIbaseadresse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIbaseadresse:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhInumeroadresse).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.
            find first iBaseAdresse exclusive-lock
                where rowid(iBaseAdresse) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iBaseAdresse:handle, 'iNumeroAdresse: ', substitute('&1', vhInumeroadresse:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.
            create ttIbaseadresse.                        
            buffer-copy iBaseAdresse to ttIbaseadresse.                        
            if not outils:copyValidField(buffer iBaseAdresse:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
            buffer-compare iBaseAdresse except dtcsy hecsy cdcsy dtmsy hemsy cdmsy cIdBAN dLongitude dLatitude cCodeInsee        //gga todo a revoir au moment du dev maintenance des adresses
                                        to ttIbaseadresse
                                        save result in vlModificationAdresse no-error.     // false si il y a un delta
            if not vlModificationAdresse then run siModificationAdresse (rowid(iBaseAdresse), iBaseAdresse.iNumeroAdresse).  
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIbaseadresse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iBaseAdresse for iBaseAdresse.

    create query vhttquery.
    vhttBuffer = ghttIbaseadresse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIbaseadresse:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iBaseAdresse.
            if not outils:copyValidField(buffer iBaseAdresse:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIbaseadresse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhInumeroadresse as handle  no-undo.
    define buffer iBaseAdresse for iBaseAdresse.

    create query vhttquery.
    vhttBuffer = ghttIbaseadresse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIbaseadresse:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhInumeroadresse).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iBaseAdresse exclusive-lock
                where rowid(Ibaseadresse) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iBaseAdresse:handle, 'iNumeroAdresse: ', substitute('&1', vhInumeroadresse:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iBaseAdresse no-error.
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

procedure siModificationAdresse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/sadb.p  evenement : ON WRITE OF adres OLD adres-old DO: 
    ------------------------------------------------------------------------------*/
    define input parameter prRowidIBaseAdresse as rowid no-undo.
    define input parameter piNumeroAdresse     as int64 no-undo.
    
    define buffer iLienAdresse for iLienAdresse.
    define buffer vbroles      for roles.   

    if not valid-handle (ghProc)
    then do:
        run trigger/trigger-sadb.p persistent set ghProc.
        run getTokenInstance in ghProc(mToken:JSessionId).
    end.
    for each iLienAdresse no-lock
       where iLienAdresse.iNumeroAdresse = piNumeroAdresse
         and iLienAdresse.cTypeAdresse   = {&TYPEADRESSE-Principale}:  
        for first vbroles no-lock
            where vbroles.tprol = iLienAdresse.cTypeIdentifiant
              and vbroles.norol = iLienAdresse.iNumeroIdentifiant:
            run sadbged in ghProc (rowid(iLienAdresse), prRowidIBaseAdresse). 
            if glEnvBnp             //gga todo a revoir au moment du dev maintenance des adresses  
            then do:
                if lookup(vbroles.tprol, substitute("&1,&2,&3,&4,&5", {&TYPEROLE-locataire}, {&TYPEROLE-mandant}, {&TYPEROLE-syndicat2copro}, {&TYPEROLE-coproprietaire}, {&TYPEROLE-coIndivisaire})) > 0
                then do: 
                    if not valid-handle (ghMdmws)
                    then do:
                        run trigger/mdmws.p persistent set ghMdmws.
                        run getTokenInstance in ghMdmws(mToken:JSessionId).
                    end.
                    if lookup(vbroles.tprol, substitute("&1,&2,&3", {&TYPEROLE-locataire}, {&TYPEROLE-syndicat2copro}, {&TYPEROLE-coproprietaire})) > 0
                    then run trtMdmws in ghMdmws (vbroles.notie, 'C', true).
                    if vbroles.tprol = {&TYPEROLE-syndicat2copro}
                    then run trtMdmws in ghMdmws (vbroles.notie, 'F', true).
                    if lookup(vbroles.tprol, substitute("&1,&2,&3,&4", {&TYPEROLE-mandant}, {&TYPEROLE-coIndivisaire})) > 0
                    then do:
                        for last intnt no-lock
                           where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                             and intnt.tpidt = vbroles.tprol
                             and intnt.noidt = vbroles.norol
                        ,  first ctrat no-lock
                           where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                             and ctrat.nocon = intnt.nocon:
                          if lookup(ctrat.ntcon, substitute("&1,&2,&3", {&NATURECONTRAT-mandatLocation}, {&NATURECONTRAT-mandatLocationDelegue}, {&NATURECONTRAT-mandatLocationIndivision})) > 0 
                          then run trtMdmws in ghMdmws (vbroles.notie, 'F', true).
                          else run trtMdmws in ghMdmws (vbroles.notie, 'C', true).
                        end.
                    end.
                end.         
            end.
        end.         
    end.
            
end procedure.
