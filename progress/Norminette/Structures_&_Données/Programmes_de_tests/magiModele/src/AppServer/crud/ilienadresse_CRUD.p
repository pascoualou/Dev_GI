/*------------------------------------------------------------------------
File        : iLienAdresse_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table iLienAdresse
Author(s)   : generation automatique le 22/10/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}

using parametre.pclie.parametrageBnp.

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using

{crud/include/iLienAdresse.i}

define variable ghttiLienAdresse as handle no-undo.      // le handle de la temp table à mettre à jour
define variable ghMdmws as handle no-undo.
define variable glEnvBnp as logical no-undo.

function getIndexField returns logical private(phBuffer as handle, output phCtypeidentifiant as handle, output phInumeroidentifiant as handle, output phCtypeadresse as handle, output phIlienadressefournisseur as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur cTypeIdentifiant/iNumeroIdentifiant/cTypeAdresse/iLienAdresseFournisseur, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'cTypeIdentifiant' then phCtypeidentifiant = phBuffer:buffer-field(vi).
            when 'iNumeroIdentifiant' then phInumeroidentifiant = phBuffer:buffer-field(vi).
            when 'cTypeAdresse' then phCtypeadresse = phBuffer:buffer-field(vi).
            when 'iLienAdresseFournisseur' then phIlienadressefournisseur = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudIlienadresse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteIlienadresse.
    run updateIlienadresse.
    run createIlienadresse.
end procedure.

procedure setIlienadresse:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttIlienadresse.
    define variable voBnp as class parametrageBnp no-undo.
    ghttIlienadresse = phttIlienadresse.
    voBnp = new parametrageBnp().
    glEnvBnp = voBnp:isDbParameter. 
    delete object voBnp.  
    run crudIlienadresse.
    delete object phttIlienadresse.
    if valid-handle (ghMdmws) then run destroy in ghMdmws.             
    
end procedure.

procedure readIlienadresse:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table iLienAdresse Lien adresse - rôle tiers ou fournisseur
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcCtypeidentifiant        as character  no-undo.
    define input parameter piInumeroidentifiant      as int64      no-undo.
    define input parameter pcCtypeadresse            as character  no-undo.
    define input parameter piIlienadressefournisseur as integer    no-undo.
    define input parameter table-handle phttIlienadresse.
    define variable vhttBuffer as handle no-undo.
    define buffer iLienAdresse for iLienAdresse.

    vhttBuffer = phttIlienadresse:default-buffer-handle.
    for first iLienAdresse no-lock
        where iLienAdresse.cTypeIdentifiant = pcCtypeidentifiant
          and iLienAdresse.iNumeroIdentifiant = piInumeroidentifiant
          and iLienAdresse.cTypeAdresse = pcCtypeadresse
          and iLienAdresse.iLienAdresseFournisseur = piIlienadressefournisseur:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iLienAdresse:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlienadresse no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getIlienadresse:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table iLienAdresse Lien adresse - rôle tiers ou fournisseur
    Notes  : service externe. Critère pcCtypeadresse = ? si pas à prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcCtypeidentifiant        as character  no-undo.
    define input parameter piInumeroidentifiant      as int64      no-undo.
    define input parameter pcCtypeadresse            as character  no-undo.
    define input parameter table-handle phttIlienadresse.
    define variable vhttBuffer as handle  no-undo.
    define buffer iLienAdresse for iLienAdresse.

    vhttBuffer = phttIlienadresse:default-buffer-handle.
    if pcCtypeadresse = ?
    then for each iLienAdresse no-lock
        where iLienAdresse.cTypeIdentifiant = pcCtypeidentifiant
          and iLienAdresse.iNumeroIdentifiant = piInumeroidentifiant:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iLienAdresse:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    else for each iLienAdresse no-lock
        where iLienAdresse.cTypeIdentifiant = pcCtypeidentifiant
          and iLienAdresse.iNumeroIdentifiant = piInumeroidentifiant
          and iLienAdresse.cTypeAdresse = pcCtypeadresse:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer iLienAdresse:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttIlienadresse no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateIlienadresse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhCtypeidentifiant        as handle  no-undo.
    define variable vhInumeroidentifiant      as handle  no-undo.
    define variable vhCtypeadresse            as handle  no-undo.
    define variable vhIlienadressefournisseur as handle  no-undo.
    define variable vlModificationAdresse as logical no-undo.    
    define buffer iLienAdresse for iLienAdresse.

    empty temp-table ttIlienAdresse.
    create query vhttquery.
    vhttBuffer = ghttIlienadresse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttIlienadresse:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCtypeidentifiant, output vhInumeroidentifiant, output vhCtypeadresse, output vhIlienadressefournisseur).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iLienAdresse exclusive-lock
                where rowid(iLienAdresse) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iLienAdresse:handle, 'cTypeIdentifiant/iNumeroIdentifiant/cTypeAdresse/iLienAdresseFournisseur: ', substitute('&1/&2/&3/&4', vhCtypeidentifiant:buffer-value(), vhInumeroidentifiant:buffer-value(), vhCtypeadresse:buffer-value(), vhIlienadressefournisseur:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.
            create ttIlienAdresse.                        
            buffer-copy ilienAdresse to ttIlienAdresse.                        
            if not outils:copyValidField(buffer iLienAdresse:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
            buffer-compare iLienAdresse except dtcsy hecsy cdcsy dtmsy hemsy cdmsy        //gga todo a revoir au moment du dev maintenance des adresses
                                        to ttIlienAdresse
                                        save result in vlModificationAdresse no-error.     // false si il y a un delta
            if not vlModificationAdresse then run siModificationAdresse (ilienadresse.cTypeIdentifiant, ilienadresse.iNumeroIdentifiant).              
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createIlienadresse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer iLienAdresse for iLienAdresse.

    create query vhttquery.
    vhttBuffer = ghttIlienadresse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttIlienadresse:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create iLienAdresse.
            if not outils:copyValidField(buffer iLienAdresse:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteIlienadresse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhCtypeidentifiant        as handle  no-undo.
    define variable vhInumeroidentifiant      as handle  no-undo.
    define variable vhCtypeadresse            as handle  no-undo.
    define variable vhIlienadressefournisseur as handle  no-undo.
    define buffer iLienAdresse for iLienAdresse.

    create query vhttquery.
    vhttBuffer = ghttIlienadresse:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttIlienadresse:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhCtypeidentifiant, output vhInumeroidentifiant, output vhCtypeadresse, output vhIlienadressefournisseur).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first iLienAdresse exclusive-lock
                where rowid(Ilienadresse) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer iLienAdresse:handle, 'cTypeIdentifiant/iNumeroIdentifiant/cTypeAdresse/iLienAdresseFournisseur: ', substitute('&1/&2/&3/&4', vhCtypeidentifiant:buffer-value(), vhInumeroidentifiant:buffer-value(), vhCtypeadresse:buffer-value(), vhIlienadressefournisseur:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete iLienAdresse no-error.
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

procedure deleteILienAdresseSurIdentifiant:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as int64     no-undo.
    
    define buffer iLienAdresse for iLienAdresse.

blocTrans:
    do transaction:
        for each iLienAdresse exclusive-lock
           where iLienAdresse.cTypeIdentifiant   = pcTypeIdentifiant
             and iLienAdresse.iNumeroIdentifiant = piNumeroIdentifiant:
            delete iLienAdresse no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status
end procedure.

procedure siModificationAdresse private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de trans/gene/sadb.p  evenement : ON WRITE OF ladrs OLD ladrs-old DO: 
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as int64     no-undo.
    
    define buffer vbroles for roles.   
    define buffer intnt   for intnt.   
    define buffer ctrat   for ctrat.   

message "oooooooooooooooo siModificationAdresse " glEnvBnp. 

    if glEnvBnp  
    then for first vbroles no-lock
             where vbroles.tprol = pcTypeIdentifiant
               and vbroles.norol = piNumeroIdentifiant:
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

end procedure.

