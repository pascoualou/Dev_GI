/*------------------------------------------------------------------------
File        : roles_CRUD.p
Purpose     : Librairie contenant les procedures li�es � la mise � jour de la table roles
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table � condition
              que les champs de l'index unique soient tous pr�sents.
derniere revue: 2018/04/16 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/famille2role.i}
{preprocesseur/type2adresse.i}

{oerealm/include/instanciateTokenOnModel.i}      // Doit �tre positionn�e juste apr�s using
{application/include/glbsepar.i}
define variable ghttroles as handle no-undo.      // le handle de la temp table � mettre � jour

function getIndexField returns logical private(phBuffer as handle, output phTprol as handle, output phNorol as handle):
    /*------------------------------------------------------------------------------
    Purpose: r�cup�re les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur tprol/norol, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'tprol' then phTprol = phBuffer:buffer-field(vi).
            when 'norol' then phNorol = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

function getNextRole returns int64(pcTypeRole as character, piNumeroRole as int64, piNumeroContrat as int64):
    /*------------------------------------------------------------------------------
    Purpose: Recherche du prochain no role en fonction de la famille de r�le
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNumeroNextRole  as int64     no-undo.
    define variable vcCodeFamilleRole as character no-undo.
    define variable viBoucle          as integer   no-undo.
    define variable viBorneDebut      as integer   no-undo.
    define variable viBorneFin        as integer   no-undo.

    define buffer vbRoles for roles.
    define buffer sys_pg  for sys_pg.
    define buffer ccpt    for ccpt.

    if pcTypeRole = {&TYPEROLE-locataire} or pcTypeRole = {&TYPEROLE-candidatLocataire}
    or pcTypeRole = {&TYPEROLE-salarie}   or pcTypeRole = {&TYPEROLE-salariePegase}
    then return piNumeroContrat.

    for first sys_pg no-lock
        where sys_pg.tppar = "R_RFR" and sys_pg.zone1 = pcTypeRole:
        vcCodeFamilleRole = sys_pg.zone2.
    end.
    case vcCodeFamilleRole:
        when {&FAMILLEROLE-proprietaire} then do:
            if piNumeroRole <> ? and piNumeroRole <> 0
            // Famille du R�le = 'Propri�taires': Chercher si le Tiers est d�j� enregistr� avec le no en entr�e pour un R�le de la Famille '12000'
            then for each sys_pg no-lock
                where sys_pg.tppar = "R_RFR"
                  and sys_pg.zone2 = {&FAMILLEROLE-proprietaire}
                  and sys_pg.zone1 <> pcTypeRole
              , first vbRoles no-lock
                where vbRoles.tprol = sys_pg.zone1
                  and vbRoles.norol = piNumeroRole:
                return vbRoles.norol.
            end.
            {&_proparse_ prolint-nowarn(sequence)}
            viNumeroNextRole = next-value(sq_noRol01).
            if viNumeroNextRole = ? then return 0.            // Tester si Borne Maximale Atteinte.

            for first ccpt no-lock
                where ccpt.soc-cd   = integer(mtoken:cRefCopro)
                  and ccpt.coll-cle = "C"
                  and ccpt.cpt-cd   = string(viNumeroNextRole, "99999"):
                {&_proparse_ prolint-nowarn(sequence)}
                return next-value(Sq_NoRol01).
            end.
        end.

        when {&FAMILLEROLE-locataire} then .    // A laisser, a cause du otherwise. Famille de r�le = "Locataires" g�r�e au d�but avec le type de r�le

        when {&FAMILLEROLE-fournisseur} then do:
            /* Traitement sp�cifique pour le r�le Mandataire:
              Ce r�le doit utiliser la m�me S�quence que la Famille "Propri�taire" mais n'est pas un syn.
              Ceci pour que l'on ne puisse pas avoir le m�me num�ro entre un Mandataire et un r�le de la famille "Propri�taire" (Indiv, Copro, Mandant)*/
            {&_proparse_ prolint-nowarn(sequence)}
            if pcTypeRole = {&TYPEROLE-mandataire} or pcTypeRole = {&TYPEROLE-gerant}
            then return next-value(Sq_NoRol01). // Utilisation de la S�quence sur r�les.

            // Famille du r�le = 'Fournisseurs'.
            find last vbRoles no-lock
                where vbRoles.tprol = pcTypeRole no-error.
            if not available vbRoles then case pcTypeRole:
                when {&TYPEROLE-mandataire} then return 1.
                when {&TYPEROLE-cabinet}    then return 90000.     /* Modif SY le 02/05/2013 */
                otherwise return 50000.
            end case.
            // Ne pas d�passer le plafond 100000.
            if vbRoles.norol >= 99999 then do:
                /* PL : 15/10/2014 (0714/0237) - Il faut assumer le d�bordement */
                assign
                    viBorneDebut = 50000
                    viBorneFin   = 99999
                .
                do viBoucle = viBorneDebut to viBorneFin:
                    if not can-find(first vbRoles no-lock
                        where vbRoles.tprol = pcTypeRole
                          and vbRoles.norol = viBoucle) then return viBoucle.    /* On a trouv� un trou. */
                end.
                mError:createError({&error}, 100566). // La plage allou�e pour ce type r�le est satur�e...
            end.
            else return vbRoles.norol + 1.
        end.

        when {&FAMILLEROLE-client} then do:
            /* Ajout Sy le 08/03/2010 : no role agence de gestion = No service de gestion */
            /* Ajout SY le 24/03/2014 : SAUF POUR MANPOWER pour qui c'est un role "normal" */
            if pcTypeRole = {&TYPEROLE-agenceGestion} and piNumeroContrat > 0 and mToken:cRefPrincipale <> "00010"
            then return piNumeroContrat. /* Si Type de Role = Agence (00048), le No de Role est �gal � celui du Contrat (01049). */

            // Famille du r�le = 'Clients'.
            {&_proparse_ prolint-nowarn(use-index)}
            find last vbRoles no-lock
                where vbRoles.tprol = pcTypeRole
                use-index ix_roles01 no-error.   // index tprol, norol
            if not available vbRoles then return 1.

            // Ne pas d�passer le plafond 100000.
            if vbRoles.norol >= 99999 then do:
                /* PL : 15/10/2014 (0714/0237) - Il faut assumer le d�bordement */
                assign
                    viBorneDebut = 1
                    viBorneFin   = 99999
                .
                do viBoucle = viBorneDebut to viBorneFin:
                    if not can-find(first roles no-lock
                        where roles.tprol = pcTypeRole
                          and roles.norol = viBoucle) then return viBoucle.    /* On a trouv� un trou. */
                end.
                mError:createError({&error}, 100566). // La plage allou�e pour ce type r�le est satur�e...
            end.
            else return vbRoles.norol + 1.
        end.

        when {&FAMILLEROLE-salarie} then .            // Famille de r�le = "Salari�s" g�r�e au d�but avec le type de r�le.

        otherwise mError:createError(
            {&error}
           , 3000012
           , substitute('&2&1&3&1&4', separ[1], vcCodeFamilleRole, pcTypeRole, "", "") /*gga toto attente message */
        ).
    end case.
    return 0.
end function.

procedure crudRoles private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteRoles.
    run updateRoles.
    run createRoles.
end procedure.

procedure setRoles:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttRoles.
    ghttRoles = phttRoles.
    run crudRoles.
    delete object phttRoles.
end procedure.

procedure readRoles:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table roles 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character no-undo.
    define input parameter piNorol as int64     no-undo.
    define input parameter table-handle phttRoles.

    define variable vhttBuffer as handle no-undo.
    define buffer vbRoles for roles.

    vhttBuffer = phttRoles:default-buffer-handle.
    for first vbRoles no-lock
        where vbRoles.tprol = pcTprol
          and vbRoles.norol = piNorol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer vbRoles:handle, vhttBuffer).  // copy table physique vers temp-table
        vhttBuffer::cLibelleTypeRole = outilTraduction:getLibelleProg("O_ROL", vbRoles.tprol) no-error.  // m�j du champ libell� s'il existe.
    end.
    delete object phttRoles no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getRoles:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table roles 
    Notes  : service externe. Crit�re pcTprol = ? si pas � prendre en compte
    ------------------------------------------------------------------------------*/
    define input parameter pcTprol as character no-undo.
    define input parameter table-handle phttRoles.

    define variable vhttBuffer as handle  no-undo.
    define buffer vbRoles for roles.

    vhttBuffer = phttRoles:default-buffer-handle.
    for each vbRoles no-lock
        where vbRoles.tprol = pcTprol:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer vbRoles:handle, vhttBuffer).                                        // copy table physique vers temp-table
        vhttBuffer::cLibelleTypeRole = outilTraduction:getLibelleProg("O_ROL", vbRoles.tprol) no-error.  // m�j du champ libell� s'il existe.
    end.
    delete object phttRoles no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateRoles private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer vbRoles for roles.

    create query vhttquery.
    vhttBuffer = ghttRoles:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttRoles:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first vbRoles exclusive-lock
                where rowid(vbRoles) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer vbRoles:handle, 'tprol/norol: ', substitute('&1/&2', vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer vbRoles:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createRoles private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer vbRoles for roles.

    create query vhttquery.
    vhttBuffer = ghttRoles:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttRoles:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create vbRoles.
            if not outils:copyValidField(buffer vbRoles:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteRoles private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhTprol    as handle  no-undo.
    define variable vhNorol    as handle  no-undo.
    define buffer vbRoles for roles.

    create query vhttquery.
    vhttBuffer = ghttRoles:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttRoles:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhTprol, output vhNorol).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first vbRoles exclusive-lock
                where rowid(vbRoles) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer vbRoles:handle, 'tprol/norol: ', substitute('&1/&2', vhTprol:buffer-value(), vhNorol:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete vbRoles no-error.
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

procedure dupliRoles:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de duplication d'un role vers un nouveau no role ou le m�me
             selon param�tres d'entr�e (c.f. PEC copro, Mutation g�rance...)
             a partir de comm/duplirol.i
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeRoleSource   as character no-undo.
    define input  parameter piNumeroRoleSource as int64     no-undo.
    define input  parameter pcTypeRoleDesti    as character no-undo.
    define input  parameter plMemeRole         as logical   no-undo.
    define output parameter piNumeroRoleDesti  as int64     no-undo.

    define variable viNumeroTiers           as int64     no-undo.
    define variable viNumeroRole            as int64     no-undo.
    define variable vcCodeFamilleRoleSource as character no-undo.
    define variable vcCodeFamilleRoleDesti  as character no-undo.
    define variable viNumeroLien            as integer   no-undo.
    define variable vhProc                  as handle    no-undo.

    define buffer sys_pg   for sys_pg.
    define buffer vbRoles  for roles.
    define buffer vbRoles2 for roles.
    define buffer vbILienAdresse  for iLienAdresse.
    define buffer iLienAdresse    for iLienAdresse.

    /* duplication avec m�me n� role: si et seulement si m�me famille de role (c.f. majseq.p) */
    if pcTypeRoleSource = {&TYPEROLE-mandataire} or pcTypeRoleSource = {&TYPEROLE-gerant}
    then vcCodeFamilleRoleSource = {&FAMILLEROLE-proprietaire}.
    else for first sys_pg no-lock
        where sys_pg.tppar = "R_RFR"
          and sys_pg.zone1 = pcTypeRoleSource:
        vcCodeFamilleRoleSource = sys_pg.zone2.
    end.
    if pcTypeRoleDesti = {&TYPEROLE-mandataire} or pcTypeRoleDesti = {&TYPEROLE-gerant}
    then vcCodeFamilleRoleDesti = {&FAMILLEROLE-proprietaire}.
    else for first sys_pg no-lock
        where sys_pg.tppar = "R_RFR"
          and sys_pg.zone1 = pcTypeRoleDesti:
        vcCodeFamilleRoleDesti = sys_pg.zone2.
    end.
    if vcCodeFamilleRoleSource <> {&FAMILLEROLE-proprietaire} or vcCodeFamilleRoleDesti <> {&FAMILLEROLE-proprietaire}
    then plMemeRole = no.
    for first vbRoles2 no-lock
        where vbRoles2.tprol = pcTypeRoleSource
          and vbRoles2.norol = piNumeroRoleSource:
        viNumeroTiers = vbRoles2.notie.
        if plMemeRole
        then viNumeroRole = vbRoles2.norol.
        else do:
            /* On regarde si la personne selectionnee (no tiers) n'existe pas en tant que type de role a dupliquer */
            find first vbRoles no-lock
                where vbRoles.tprol = pcTypeRoleDesti
                  and vbRoles.notie = viNumeroTiers no-error.
            if not available vbRoles
            then run getNextRole(pcTypeRoleDesti, 0, 0, output viNumeroRole).   // Recherche du Prochain No Role Libre
            else viNumeroRole = vbRoles.norol.
        end.
        /*--> On regarde si la personne selectionnee n'existe pas en temps que Type + no role a dupliquer */
        if viNumeroRole > 0
        and not can-find(first roles no-lock
                         where roles.tprol = pcTypeRoleDesti
                           and roles.norol = viNumeroRole)
        then do:
            // (ex newroles)
            create vbRoles.
            assign
                vbRoles.tprol = pcTypeRoleDesti
                vbRoles.norol = viNumeroRole
                vbRoles.notie = viNumeroTiers
                vbRoles.cdext = ""
                vbRoles.lbdiv = ""
                vbRoles.dtcsy = today
                vbRoles.hecsy = mtime
                vbRoles.cdcsy = mtoken:cUser
            .
            for first vbILienAdresse no-lock
                where vbILienAdresse.cTypeIdentifiant   = pcTypeRoleSource
                  and vbILienAdresse.iNumeroIdentifiant = piNumeroRoleSource
                  and vbILienAdresse.cTypeAdresse       = {&TYPEADRESSE-Principale}:
                /*--> creation du lien adresse du role destinataire dans iLienAdresse */
                create iLienAdresse.
                buffer-copy vbILienAdresse
                    except vbILienAdresse.cTypeIdentifiant vbILienAdresse.iNumeroIdentifiant vbILienAdresse.dtmsy vbILienAdresse.hemsy vbILienAdresse.cdmsy
                    to iLienAdresse
                    assign
                    iLienAdresse.cTypeIdentifiant   = pcTypeRoleDesti
                    iLienAdresse.iNumeroIdentifiant = viNumeroRole
                    iLienAdresse.dtcsy              = today
                    iLienAdresse.hecsy              = mtime
                    iLienAdresse.cdcsy              = mToken:cUser
                .
                /* 0507/0195 - duplication table telephones */
                run adresse/moyenCommunication.p persistent set vhProc.
                run getTokenInstance           in vhProc(mToken:JSessionId).
                run dupliqueMoyenCommunication in vhProc(pcTypeRoleSource, piNumeroRoleSource, pcTypeRoleDesti, viNumeroRole).
                run destroy                    in vhProc no-error.
            end.
        end.
    end.
    piNumeroRoleDesti = viNumeroRole.

end procedure.

procedure purgeRoles:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole   as character no-undo.
    define input parameter piNumeroRole as int64     no-undo.

    define buffer vbroles for roles.

blocTrans:
    do transaction:
        for first vbroles exclusive-lock
            where vbroles.tprol = pcTypeRole
              and vbroles.norol = piNumeroRole:
            /* Ajout SY le 17/10/2012 - Suppr Agence : suppression des alertes associ�es + Traitements evenementiel (r�visions...)*/
            if pcTypeRole = {&TYPEROLE-agenceGestion} and piNumeroRole > 0  
            then do:
                run purgeInfosAgence (piNumeroRole).   
                if mError:erreur() then undo blocTrans, leave blocTrans.
            end.      
            delete vbroles no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure purgeInfosAgence private:
    /*------------------------------------------------------------------------------
    Purpose: suppression de tous les enregistrements correspondant aux parametres de selection 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroRole as int64 no-undo.

    define buffer gaint   for gaint.
    define buffer gaent   for gaent.
    define buffer gadet   for gadet.
    define buffer typol   for typol.
    define buffer vbProce for proce.
    define buffer trait   for trait.
    define buffer suivi   for suivi.

blocTrans:
    do transaction:
        for each gaint exclusive-lock
           where gaint.agence = piNumeroRole:
            delete gaint no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
        for each gaent exclusive-lock
           where gaent.agence = piNumeroRole:
            delete gaent no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
        for each gadet exclusive-lock
           where gadet.agence = piNumeroRole:
            delete gadet no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
        /* Typologie (c.f. calhono.p), Traitements et suivi des traitements */
        for each typol exclusive-lock
           where typol.noidt = piNumeroRole:
            delete typol no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
        for each vbProce exclusive-lock
           where vbProce.norol = piNumeroRole:
            delete vbProce no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
        for each trait exclusive-lock
           where trait.noidt = piNumeroRole:
            for each suivi exclusive-lock
               where suivi.notrt = trait.notrt:
                delete suivi no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            delete trait no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.            
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
