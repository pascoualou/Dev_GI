/*------------------------------------------------------------------------
File        : imble_crud.p
Purpose     :
Author(s)   : kantena - 2016/12/20
Notes       :
derniere revue: 2018/09/07 - phm: KO
    A remettre au standard des CRUD (create, update, delete en private, set pour appeler la mise à jour.
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/referenceClient.i}
{preprocesseur/mode2gestionFournisseurLoyer.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageMandat5Chiffres.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

define variable ghttimble as handle no-undo.      // le handle de la temp table à mettre à jour

{immeubleEtLot/include/immeuble.i}
{application/include/glbsepar.i}
{crud/include/imble.i}

function getIndexField returns logical private(phBuffer as handle, output phNoimm as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur noimm, 
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'noimm' then phNoimm = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

procedure crudImble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteImble.
    run updateImble.
    run createImble.
end procedure.

procedure setImble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttImble.
    ghttImble = phttImble.
    run crudImble.
    delete object phttImble.
end procedure.

procedure readImble:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table imble 
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNoimm as integer    no-undo.
    define input parameter table-handle phttImble.
    define variable vhttBuffer as handle no-undo.
    define buffer imble for imble.

    vhttBuffer = phttImble:default-buffer-handle.
    for first imble no-lock
        where imble.noimm = piNoimm:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imble:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImble no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure getImble:
    /*------------------------------------------------------------------------------
    Purpose: Lecture des enregistrements de la table imble 
    Notes  : service externe.
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttImble.
    define variable vhttBuffer as handle  no-undo.
    define buffer imble for imble.

    vhttBuffer = phttImble:default-buffer-handle.
    for each imble no-lock:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer imble:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttImble no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateImble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery   as handle  no-undo.
    define variable vhttBuffer  as handle  no-undo.
    define variable vhNoimm as handle  no-undo.
    define buffer imble for imble.

    create query vhttquery.
    vhttBuffer = ghttImble:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttImble:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first imble exclusive-lock
                where rowid(imble) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer imble:handle, 'noimm: ', substitute('&1', vhNoimm:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer imble:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure createImble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define buffer imble for imble.

    create query vhttquery.
    vhttBuffer = ghttImble:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttImble:name)).
    vhttquery:query-open().
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            create imble.
            if not outils:copyValidField(buffer imble:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteImble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNoimm as handle  no-undo.
    define buffer imble for imble.

    create query vhttquery.
    vhttBuffer = ghttImble:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttImble:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNoimm).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first imble exclusive-lock
                where rowid(Imble) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer imble:handle, 'noimm: ', substitute('&1', vhNoimm:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            delete imble no-error.
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

procedure getNextImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : appelé en interne ET par un service de beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define output parameter piNumeroNextImm as integer no-undo.

    define variable viDebImm as integer no-undo initial 1.
    define buffer pclie for pclie.
    define buffer imble for imble.

    // Recherche si no immeuble de depart
    for first pclie no-lock
        where pclie.tppar = "NODEB"
          and pclie.zon01 = {&TYPEBIEN-immeuble}:
        viDebImm = pclie.int01.
    end.
    // Bloquer les n° d'immeuble en dessous de 2000
    if integer(mToken:cRefPrincipale) = {&REFCLIENT-LCLPROVINCE}
    then viDebImm  = maximum(2001, viDebImm).
    piNumeroNextImm = viDebImm.

    // Recherche du premier numéro immeuble disponible (on ré-utilise les trous)
boucle:
    for each imble no-lock
        where imble.noimm >= viDebImm:
        if imble.noimm > piNumeroNextImm then leave boucle.

        piNumeroNextImm = imble.noimm + 1.
    end.
    if piNumeroNextImm > 9999 then mError:createError({&error}, 211655).

end procedure.

procedure readImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Service appelé par immeuble.p
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttImmeuble.

    define variable vhprocTiers as handle no-undo.
    define buffer imble for imble.
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    run tiers/tiers.p persistent set vhprocTiers.
    run getTokenInstance in vhprocTiers(mToken:JSessionId).
    empty temp-table ttImmeuble.

    // Lecture de la table des immeubles
    find first imble no-lock
        where imble.noimm = piNumeroImmeuble no-error.
    if not available imble
    then mError:createError({&error}, 211653, 'immeuble: ' + string(piNumeroImmeuble)).
    else do:
        /*--ENTETE IMMEUBLE--------------------------------------------------------------------------------------------------------*/
        create ttImmeuble.
        assign
            ttImmeuble.iNumeroImmeuble         = imble.NoImm          /* N° Immeuble                     */
            ttImmeuble.cLibelleImmeuble        = imble.LbNom          /* Nom Immeuble                    */
            ttImmeuble.cCodeTypeImmeuble       = imble.TpImm          /* Type Immeuble                   */
            ttImmeuble.cCodeSecteur            = imble.CdSec          /* Secteur Immeuble                */
            ttImmeuble.cCodeNatureBien         = imble.NtBie          /* Nature du Bien                  */
            ttImmeuble.cNumeroCadastre         = imble.cdCad          /* N° du Cadastre                  */
            ttImmeuble.cNumeroPlan             = imble.cdpln          /* N° permis du plan               */
            ttImmeuble.cNumeroPermisConstruire = imble.permis         /* N° permis de construire         */
            ttImmeuble.cCodeTypeConstruction   = imble.TpCst          /* Type de Construction            */
            ttImmeuble.cCodeTypeToiture        = imble.TpTot          /* Type de Toitures                */
            ttImmeuble.lVentilationMecanique   = imble.FgVen          /* Flag Ventilation Mecanique      */
            ttImmeuble.cCodeTypeChauffage      = imble.TpCha          /* Type de Chauffage               */
            ttImmeuble.cCodeModeChauffage      = imble.MdCha          /* Mode de Chauffage               */
            ttImmeuble.cCodeModeClimatisation  = imble.MdCli          /* Mode de Climatisation           */
            ttImmeuble.cCodeModeEauChaude      = imble.MdChd          /* Mode Eau Chaude                 */
            ttImmeuble.cCodeModeEauFroide      = imble.MdFra          /* Mode Eau Froide                 */
    //      ttImmeuble.cCodeResidence          = imble.CdRes          /* Code Residence                  */
            ttImmeuble.cCodeExterneManPower    = imble.CdExt          /* Code Externe Man Power          */
            ttImmeuble.daDateRenovation        = imble.dtRenov        /* derniere rénovation             */
            ttImmeuble.cCodeSousSecteur        = imble.cdsse
    //      ttImmeuble.cPageGardeCarnet        = imble.LbDiv2         /* Commentaire Carnet              */
            ttImmeuble.cCodeQualite            = imble.CdQualite      /* Qualité de l'immeuble           */
            ttImmeuble.cCodeTypePropriete      = imble.TpPropriete
            ttImmeuble.cCodeLocalisation       = imble.CdLocalisation /* Localisation de l'immeuble      */
            ttImmeuble.iNombreBatiment         = imble.nbbat
            ttImmeuble.iNombreAscenseur        = imble.nbasc
            ttImmeuble.iNombreEscalier         = imble.nbEsc
            ttImmeuble.iNombreEtage            = imble.nbEta
            ttImmeuble.iNombreLoge             = imble.nbLog
            ttImmeuble.iNombreSousSol          = imble.nbSss
            ttImmeuble.iNumeroBlocNote         = imble.noblc
            ttImmeuble.cDebutPeriodeChauffe    = if num-entries(imble.lbdiv, "&") > 5 then entry(6, imble.lbdiv, "&") else ?
            ttImmeuble.cFinPeriodeChauffe      = if num-entries(imble.lbdiv, "&") > 6 then entry(7, imble.lbdiv, "&") else ?
            ttImmeuble.cCodeCategorieImmeuble  = if num-entries(imble.lbdiv, "&") > 8 then entry(9, imble.lbdiv, "&") else ?
            ttImmeuble.cCodeTypeSyndicat       = if num-entries(imble.lbdiv, "&") > 12 then entry(12, imble.lbdiv, "&") else ?
            ttImmeuble.cTypeBien               = {&TYPEBIEN-immeuble}
            ttImmeuble.lbdiv                   = imble.lbdiv
            ttImmeuble.lGerance                = can-find(first intnt no-lock
                                                          where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                                                            and intnt.tpidt = {&TYPEBIEN-immeuble}
                                                            and intnt.noidt = imble.noimm)
            ttImmeuble.CRUD                    = 'R'
            ttImmeuble.dtTimestamp             = datetime(imble.dtmsy, imble.hemsy)
            ttImmeuble.rRowid                  = rowid(imble)
        .
        if num-entries(imble.lbdiv, "&") > 7   then ttImmeuble.lParkingSousSol = (integer(entry(8, imble.lbdiv, "&")) > 0).      // Parking sous sol
        if num-entries(imble.lbdiv, "&") >= 5  then ttImmeuble.lTeleReleve = (entry(5, imble.lbdiv, "&") = "00001").             // flag tele releve
        if num-entries(imble.lbdiv, "&") >= 11 then ttImmeuble.lSyndicatProfessionnel = (entry(11, imble.lbdiv, "&") = "00001"). // Flag Syndicat professionnel
        if num-entries(imble.lbdiv, "&") >= 13 then ttImmeuble.lSRU = (entry(13, imble.lbdiv, "&") = "00001").                   // Reglement adapté à la loi SRU
        run readConstruction (piNumeroImmeuble, buffer ttImmeuble). // Contrat de Construction

        // Role syndic
        for first intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
              and intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = imble.noimm:
            ttImmeuble.lCopropriete = true.
            for first ctrat no-lock
                where ctrat.tpcon = intnt.tpcon
                  and ctrat.nocon = intnt.nocon:
                assign
                    ttImmeuble.iNumeroRoleSyndic      = ctrat.norol
                    ttImmeuble.cCodeTypeRoleSyndic    = ctrat.tprol
                    ttImmeuble.cLibelleTypeRoleSyndic = outilTraduction:getLibelleProg("O_ROL", ctrat.tprol)
               .
            end.
        end.
    end.
    run destroy in vhprocTiers.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure deleteImmeuble:
    /*------------------------------------------------------------------------------
    Purpose: phtt = ttImmeuble ou ttImmeuble2
    Notes  : Service appelé par immeuble.p
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phtt.

    define variable vcTableName as character no-undo initial 'imble'.
    define variable vhBuffer    as handle    no-undo.
    define variable vhttBuffer  as handle    no-undo.
    define variable vhttQuery   as handle    no-undo.

    create buffer vhBuffer for table vcTableName.
    vhttBuffer = phtt:default-buffer-handle.
    create query  vhttQuery.
    vhttQuery:set-buffers(vhttBuffer).
    vhttQuery:query-prepare(substitute('for each &1 where &1.CRUD="D"', vhttBuffer:name)).
    vhttQuery:query-open().

blocTransaction:
    do transaction:
blocRepeat:
        repeat:
            vhttQuery:get-next().
            if vhttQuery:query-off-end then leave blocRepeat.

            vhBuffer:find-first(substitute('where rowid(&1) = to-rowid("&2")', vcTableName, vhttBuffer::rRowid), exclusive-lock, no-wait).
            if outils:isUpdated(vhBuffer, vcTableName + ': ', string(vhttBuffer::iNumeroImmeuble), vhttBuffer::dtTimestamp)
            then undo blocTransaction, leave blocTransaction.

            vhBuffer:buffer-delete() no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTransaction, leave blocTransaction.
            end.
        end.
    end.
    vhttQuery:query-close() no-error.
    delete object vhttQuery no-error.
    delete object vhBuffer no-error.
    assign error-status:error = false no-error.

end procedure.

function testNumeroImmeuble returns logical(piNumeroImmeuble as integer, lQuestionnement as logical):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Un service peut appeler cette méthode avec lQuestionnement=true.
    ------------------------------------------------------------------------------*/
    define variable viMdtFlo                 as integer   no-undo.
    define variable vcListeModeleFLComptaAdb as character no-undo.
    define variable voFournisseurLoyer       as class     parametrageFournisseurLoyer no-undo.
    define variable voMandat5Chiffres        as class     parametrageMandat5Chiffres  no-undo.
    define buffer imble for imble.
    define buffer ietab for ietab.

    if piNumeroImmeuble = 0 then do:
        mError:createError({&error}, 102282).
        return false.
    end.
    if can-find(first imble no-lock where imble.noimm = piNumeroImmeuble) then do:
        mError:createError({&error}, 102283).
        return false.
    end.
    // REDING et EUROSTUDIOMES utilisent les rub ext 651 … 692 avec sous-compte imm sur 3 chiffres seulement
    if piNumeroImmeuble > 999 
    and (integer(mToken:cRefPrincipale) = {&REFCLIENT-EUROSTUDIOMES}
      or integer(mToken:cRefPrincipale) = {&REFCLIENT-REDING}) then do:
        mError:createError({&error}, 108883).
        return false.
    end.
    // CL: N° d'immeuble supérieur à 2000
    if piNumeroImmeuble < 2001 and mToken:iCodeSociete = {&REFCLIENT-LCLPROVINCE} then do:
        mError:createError({&error}, 211663).
        return false.
    end.
    // contrôle no mandat Fournisseur de loyer
    voFournisseurLoyer = new parametrageFournisseurLoyer().
    if voFournisseurLoyer:isGesFournisseurLoyer() then do:
        // LCL
        if voFournisseurLoyer:getCodeModele() = {&MODELE-LotIsole-ComptaSociete} then do:
            // mandat fournisseur de loyer
            viMdtFlo = voFournisseurLoyer:getFournisseurLoyerDebut() + piNumeroImmeuble - 1.
            if viMdtFlo > voFournisseurLoyer:getFournisseurLoyerFin() then do:
                mError:createError({&error}, 211664, substitute('&2&1&3', separ[1], string(viMdtFlo), string(voFournisseurLoyer:getFournisseurLoyerFin()))).
                delete object voFournisseurLoyer.
                return false.
            end.
            if viMdtFlo > 9999 then do:
                // le paramètre mandat 5 chiffres doit être ouvert (la moulinette compta société doit être passée)
                voMandat5Chiffres = new parametrageMandat5Chiffres().
                if not voMandat5Chiffres:isDbParameter then do:
                    mError:createError({&error}, 211665, string(viMdtFlo)).
                    delete object voFournisseurLoyer.
                    delete object voMandat5Chiffres.
                    return false.
                end.
                delete object voMandat5Chiffres.
            end.
            // vérifier que le mandat n'a pas été créé en gestion ADB
            if can-find(first ietab no-lock
                        where ietab.soc-cd = integer(mToken:cRefGerance)
                          and ietab.etab-cd = viMdtFlo) then do:
                mError:createError({&error}, 211666, string(viMdtFlo)).
                delete object voFournisseurLoyer.
                return false.
            end.
        end.
        vcListeModeleFLComptaAdb = substitute('&1,&2', {&MODELE-ResidenceLocative-ComptaAdb}, {&MODELE-ResidenceLocativeEtDeleguee-ComptaAdb}).
        if lQuestionnement and can-do(vcListeModeleFLComptaAdb, voFournisseurLoyer:getCodeModele())
                           and piNumeroImmeuble >= voFournisseurLoyer:getImmeubleDebut()
                           and piNumeroImmeuble <= voFournisseurLoyer:getImmeubleFin()
        then mError:createError({&question}, 211667, string(piNumeroImmeuble)).
    end.
    delete object voFournisseurLoyer.
    return true.

end function.

procedure createImmeuble:
    /*------------------------------------------------------------------------------
    Purpose: phtt = ttImmeuble ou ttImmeuble2
    Notes  : Service appelé par immeuble.p
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phtt.

    define variable vhttBuffer   as handle  no-undo.
    define variable vhttQuery    as handle  no-undo.
    define variable vhprocPont   as handle  no-undo.
    define variable viNextNumero as integer no-undo.

    define buffer imble for imble.

    run immeubleEtLot/pontImmeubleCompta.p persistent set vhprocPont.
    run getTokenInstance in vhprocPont (mToken:JSessionId).
    vhttBuffer = phtt:default-buffer-handle.
    create query  vhttQuery.
    vhttQuery:set-buffers(vhttBuffer).
    vhttQuery:query-prepare(substitute('for each &1 where &1.CRUD="C"', vhttBuffer:name)).
    vhttQuery:query-open().

blocTransaction:
    do transaction:
blocRepeat:
        repeat:
            vhttQuery:get-next().
            if vhttQuery:query-off-end then leave blocRepeat.

            if vhttBuffer::iNumeroImmeuble = 0 or vhttBuffer::iNumeroImmeuble = ?
            then do:
                run getNextImmeuble(output viNextNumero).
                vhttBuffer::iNumeroImmeuble = viNextNumero.
            end.
            else if not testNumeroImmeuble(vhttBuffer::iNumeroImmeuble, false /* sans question */)
            then undo blocTransaction, leave blocTransaction.

            create imble.
            assign
                imble.noimm  = vhttBuffer::iNumeroImmeuble
                vhttBuffer::rRowid = rowid(imble)
            no-error.
            if error-status:error then do:
                mError:createError({&error},  error-status:get-message(1)).
                undo blocTransaction, leave blocTransaction.
            end.
            if not outils:copyValidField(buffer imble:handle, vhttBuffer, 'C', mtoken:cUser) then undo blocTransaction, leave blocTransaction.
            run majLienImmeuble in vhprocPont (imble.noImm).
            run miseAjourTrace(true, true, imble.noImm).
            run createLogeImmeuble(vhttBuffer::iNumeroContratConstruction).  // creation de la loge par défaut.
        end.
    end.
    vhttQuery:query-close() no-error.
    delete object vhttQuery no-error.
    run destroy in vhprocPont.

end procedure.

procedure createLogeImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContratConstruction as int64   no-undo.

    define variable viLast as integer no-undo initial 1.
    define buffer tache for tache.

    {&_proparse_ prolint-nowarn(wholeindex)}
    for last tache no-lock:
        viLast = tache.noita + 1.
    end.
    create tache.
    assign
        tache.tpcon = {&TYPECONTRAT-construction}
        tache.nocon = piNumeroContratConstruction
        tache.tptac = {&TYPETACHE-loge}
        tache.notac = 1
        tache.noita = viLast
        tache.tphon = substitute("00:00&220:00&100:00&220:00&11111100", separ[1], separ[2])
        tache.ntges = tache.tphon
    .
end procedure.

procedure updateImmeuble:
    /*------------------------------------------------------------------------------
    Purpose: phtt = ttImmeuble ou ttImmeuble2
    Notes  : Service appelé par immeuble.p
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phtt.

    define variable vhttBuffer                as handle  no-undo.
    define variable vhttQuery                 as handle  no-undo.
    define variable vlModificationNomImmeuble as logical no-undo.
    define variable vlNonModificationImmeuble as logical no-undo initial true.
    define variable vhprocPont                as handle  no-undo.
    define buffer imble for imble.

    empty temp-table ttimble.
    run immeubleEtLot/pontImmeubleCompta.p persistent set vhprocPont.
    run getTokenInstance in vhprocPont (mToken:JSessionId).
    vhttBuffer = phtt:default-buffer-handle.
    create query  vhttQuery.
    vhttQuery:set-buffers(vhttBuffer).
    vhttQuery:query-prepare(substitute('for each &1 where &1.CRUD="U"', vhttBuffer:name)).
    vhttQuery:query-open().

blocTransaction:
    do transaction:
blocRepeat:
        repeat:
            vhttQuery:get-next().
            if vhttQuery:query-off-end then leave blocRepeat.

            find first imble exclusive-lock
                 where rowid(imble) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer imble:handle, 'immeuble: ', string(vhttBuffer::iNumeroImmeuble), vhttBuffer::dtTimestamp)
            then undo blocTransaction, leave blocTransaction.

            create ttimble.
            buffer-copy imble to ttimble.
            vlModificationNomImmeuble = (imble.lbNom <> vhttBuffer::cLibelleImmeuble).
            if not outils:copyValidField(buffer imble:handle, vhttBuffer, 'U', mtoken:cUser) then undo blocTransaction, leave blocTransaction.

            // reprise des procedures de incliadb.i
            if vlModificationNomImmeuble
            then run majLienImmeuble in vhprocPont (imble.noImm).
            buffer-compare Imble
                except dtmsy hemsy cdmsy tprol norol cdext
                    to ttImble
                save result in vlNonModificationImmeuble  // false si il y a un delta
            no-error.
            run miseAjourTrace(not vlNonModificationImmeuble, vlModificationNomImmeuble, imble.noImm).
        end.
    end.
    vhttQuery:query-close() no-error.
    delete object vhttQuery no-error.
    run destroy in vhprocPont.

end procedure.

procedure miseAjourTrace private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter plModificationImmeuble    as logical no-undo.
    define input  parameter plModificationNomImmeuble as logical no-undo.
    define input  parameter piNumeroImmeuble          as integer no-undo.

    define variable vhproc as handle  no-undo.
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    run "application/transfert/GI_alimaj.p" persistent set vhproc.
    run getTokenInstance in vhproc (mToken:JSessionId).
    if plModificationNomImmeuble
    then for each intnt no-lock            // Balayage des mandat gestion  pour transfert
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piNumeroImmeuble
          and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
         run majTrace in vhproc (integer(mToken:cRefGerance), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).
    end.
    if plModificationImmeuble
    then for each intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piNumeroImmeuble
          and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
        run majTrace in vhproc(integer(mToken:cRefCopro), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).
    end.
    run destroy in vhproc.

end procedure.

procedure readConstruction:
    /*------------------------------------------------------------------------------
    Purpose: chargement des infos du contrat de construction
    Notes  : Service appelé par immeuble.p ou par ce programme imbme_CRUD.p
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define parameter buffer ttImmeuble for ttImmeuble.

    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer ctrat   for ctrat.

    // Contrat de Construction
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-construction}
          and intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piNumeroImmeuble
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
        // Objet du contrat de construction
        assign
            ttImmeuble.daDateConstruction = ctrat.dtdeb
            ttImmeuble.daDateFinContrat   = ctrat.dtfin
        .
        for first vbIntnt no-lock
            where vbIntnt.tpcon = ctrat.tpcon
              and vbIntnt.nocon = ctrat.nocon
              and vbIntnt.tpidt = {&TYPEROLE-promoteur}:
            assign
                ttImmeuble.iNumeroPromoteur = vbIntnt.noidt
                ttImmeuble.cNomPromoteur    = outilFormatage:getNomTiers({&TYPEROLE-promoteur}, vbIntnt.noidt)
            .
        end.
        for first vbIntnt no-lock
            where vbIntnt.tpcon = ctrat.tpcon
              and vbIntnt.nocon = ctrat.nocon
              and vbIntnt.tpidt = {&TYPEROLE-architecte}:
            assign
                ttImmeuble.iNumeroArchitecte = vbIntnt.noidt
                ttImmeuble.cNomArchitecte    = outilFormatage:getNomTiers({&TYPEROLE-architecte}, vbIntnt.noidt)
            .
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
