/*------------------------------------------------------------------------
File        : imble_crud.p
Purpose     :
Author(s)   : kantena - 2016/12/20
Notes       :
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageMandat5Chiffres.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{immeubleEtLot/include/immeuble.i}
{application/include/glbsepar.i}
define temp-table ttImble no-undo like imble index primaire noimm.

procedure getNextImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : appelé en interne ET par un service de beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define output parameter piNumeroNextImm as integer no-undo.

    define variable viDebImm as integer no-undo.
    define buffer pclie for pclie.
    define buffer imble for imble.

    /*--> Recherche si no immeuble de depart */
    find first pclie no-lock
         where pclie.Tppar = "NODEB"
           and pclie.zon01 = {&TYPEBIEN-immeuble} no-error.
    assign
        viDebImm        = (if available pclie then pclie.int01 else 1)
        piNumeroNextImm = viDebImm
    .
    /* Bloquer les n° d'immeuble en dessous de 2000 */
    if integer(mToken:cRefPrincipale) = 3062
    then assign
        viDebImm        = maximum(2001, viDebImm)
        piNumeroNextImm = viDebImm
    .
    /*Lecture de la table des immeubles */
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
    define buffer imble   for imble.
    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer ctrat   for ctrat.

    run tiers/tiers.p persistent set vhprocTiers.
    run getTokenInstance in vhprocTiers(mToken:JSessionId).
    empty temp-table ttImmeuble.

    /*Lecture de la table des immeubles*/
    find first imble no-lock
        where imble.noimm = piNumeroImmeuble no-error.
    if not available imble
    then mError:createError({&error}, 211653, 'immeuble: ' + string(piNumeroImmeuble)).
    else do:
        /*--ENTETE IMMEUBLE--------------------------------------------------------------------------------------------------------*/
        create ttImmeuble.
        assign
            ttImmeuble.CRUD                    = 'R'
            ttImmeuble.iNumeroImmeuble         = Imble.NoImm          /* N° Immeuble                     */
            ttImmeuble.cLibelleImmeuble        = Imble.LbNom          /* Nom Immeuble                    */
            ttImmeuble.cCodeTypeImmeuble       = Imble.TpImm          /* Type Immeuble                   */
            ttImmeuble.cCodeSecteur            = Imble.CdSec          /* Secteur Immeuble                */
            ttImmeuble.cCodeNatureBien         = Imble.NtBie          /* Nature du Bien                  */
            ttImmeuble.cNumeroCadastre         = Imble.cdCad          /* N° du Cadastre                  */
            ttImmeuble.cNumeroPlan             = imble.cdpln          /* N° permis du plan               */
            ttImmeuble.cNumeroPermisConstruire = imble.permis         /* N° permis de construire         */
            ttImmeuble.cCodeTypeConstruction   = Imble.TpCst          /* Type de Construction            */
            ttImmeuble.cCodeTypeToiture        = Imble.TpTot          /* Type de Toitures                */
            ttImmeuble.lVentilationMecanique   = Imble.FgVen          /* Flag Ventilation Mecanique      */
            ttImmeuble.cCodeTypeChauffage      = Imble.TpCha          /* Type de Chauffage               */
            ttImmeuble.cCodeModeChauffage      = Imble.MdCha          /* Mode de Chauffage               */
            ttImmeuble.cCodeModeClimatisation  = Imble.MdCli          /* Mode de Climatisation           */
            ttImmeuble.cCodeModeEauChaude      = Imble.MdChd          /* Mode Eau Chaude                 */
            ttImmeuble.cCodeModeEauFroide      = Imble.MdFra          /* Mode Eau Froide                 */
    //      ttImmeuble.cCodeResidence          = Imble.CdRes          /* Code Residence                  */
            ttImmeuble.cCodeExterneManPower    = Imble.CdExt          /* Code Externe Man Power          */
            ttImmeuble.daDateRenovation        = Imble.dtRenov        /* derniere rénovation             */
            ttImmeuble.cCodeSousSecteur        = Imble.cdsse
    //      ttImmeuble.cPageGardeCarnet        = Imble.LbDiv2         /* Commentaire Carnet              */
            ttImmeuble.cCodeQualite            = Imble.CdQualite      /* Qualité de l'immeuble           */
            ttImmeuble.cCodeTypePropriete      = Imble.TpPropriete
            ttImmeuble.cCodeLocalisation       = Imble.CdLocalisation /* Localisation de l'immeuble      */
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
            ttImmeuble.dtTimestamp             = datetime(imble.dtmsy, imble.hemsy)
            ttImmeuble.lbdiv                   = imble.lbdiv
            ttImmeuble.rRowid                  = rowid(imble)
        .
        // Parking sous sol
        if num-entries(imble.lbdiv, "&") > 7   then ttImmeuble.lParkingSousSol = (integer(entry(8, imble.lbdiv, "&")) > 0).
        // flag tele releve
        if num-entries(imble.lbdiv, "&") >= 5  then ttImmeuble.lTeleReleve = (entry(5, imble.lbdiv, "&") = "00001").
        // Flag Syndicat professionnel
        if num-entries(imble.lbdiv, "&") >= 11 then ttImmeuble.lSyndicatProfessionnel = (entry(11, imble.lbdiv, "&") = "00001").
        // Reglement adapté à la loi SRU
        if num-entries(imble.lbdiv, "&") >= 13 then ttImmeuble.lSRU = (entry(13, imble.lbdiv, "&") = "00001").

        /*--> Flag gerance */
        find first intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = imble.noimm no-error.
        /*--> Copropriete */
        ttImmeuble.lGerance = (available intnt).

        /*--> Contrat de Construction */
        run readConstruction (piNumeroImmeuble, buffer ttImmeuble).
        
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
    define variable viMdtFlo     as integer   no-undo.

    define variable voFournisseurLoyer as class parametrageFournisseurLoyer no-undo.
    define variable voMandat5Chiffres  as class parametrageMandat5Chiffres  no-undo.
    define buffer imble for imble.
    define buffer ietab for ietab.

    if piNumeroImmeuble = 0
    then do:
        mError:createError({&error}, 102282).
        return false.
    end.
    if can-find(first imble no-lock where imble.noimm = piNumeroImmeuble)
    then do:
        mError:createError({&error}, 102283).
        return false.
    end.
    // REDING et EUROSTUDIOMES utilisent les rub ext 651 … 692 avec sous-compte imm sur 3 chiffres seulement
    if piNumeroImmeuble > 999 and (mToken:cRefPrincipale = "01501" or mToken:cRefPrincipale = "02039")
    then do:
        mError:createError({&error}, 108883).
        return false.
    end.
    // CL : N° d'immeuble supérieur à 2000
    if piNumeroImmeuble < 2001 and mToken:iCodeSociete = 3062
    then do:
        mError:createError({&error}, 211663).
        return false.
    end.
    /* contrôle no mandat Fournisseur de loyer */
    voFournisseurLoyer = new parametrageFournisseurLoyer().
    if voFournisseurLoyer:isGesFournisseurLoyer()
    then do:
        /* Modele "Lots Isoles"  */
        if voFournisseurLoyer:getCodeModele() = "00002" then do:
            /* mandat fournisseur de loyer */
            viMdtFlo = voFournisseurLoyer:getFournisseurLoyerDebut() + piNumeroImmeuble - 1.
            if viMdtFlo > voFournisseurLoyer:getFournisseurLoyerFin() then do:
                mError:createError({&error}, 211664, substitute('&2&1&3', separ[1], string(viMdtFlo), string(voFournisseurLoyer:getFournisseurLoyerFin()))).
                delete object voFournisseurLoyer.
                return false.
            end.
            if viMdtFlo > 9999 then do:
                /* le paramètre mandat 5 chiffres doit être ouvert (la moulinette compta société doit être passée) */
                voMandat5Chiffres = new parametrageMandat5Chiffres().
                if not voMandat5Chiffres:isDbParameter
                then do:
                    mError:createError({&error}, 211665, string(viMdtFlo)).
                    delete object voFournisseurLoyer.
                    delete object voMandat5Chiffres.
                    return false.
                end.
                delete object voMandat5Chiffres.
            end.
            /* vérifier que le mandat n'a pas été créé en gestion ADB */
            if can-find (first ietab no-lock where ietab.soc-cd = integer(mToken:cRefGerance) and ietab.etab-cd = viMdtFlo)
            then do:
                mError:createError({&error}, 211666, string(viMdtFlo)).
                delete object voFournisseurLoyer.
                return false.
            end.
        end.
        if lQuestionnement and can-do("00003,00004", voFournisseurLoyer:getCodeModele())
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
            if not outils:copyValidLabeledField(buffer imble:handle, vhttBuffer, 'C', mtoken:cUser) then undo blocTransaction, leave blocTransaction.
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

    define variable viLast as integer no-undo.
    define buffer tache for tache.

    {&_proparse_ prolint-nowarn(wholeindex)}
    find last tache no-lock no-error.
    viLast = if available tache then tache.noita + 1 else 1.
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
            if not outils:copyValidLabeledField(buffer imble:handle, vhttBuffer, 'U', mtoken:cUser) then undo blocTransaction, leave blocTransaction.

            /* reprise des procedures de incliadb.i */
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
        run majTrace in vhproc (integer(mToken:cRefCopro), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).
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

    /*--> Contrat de Construction */
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-construction}
          and intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piNumeroImmeuble
    , first ctrat no-lock
      where ctrat.tpcon = intnt.tpcon
        and ctrat.nocon = intnt.nocon:

        /*--> Objet du contrat de construction */
        assign
            ttImmeuble.daDateConstruction = ctrat.dtdeb
            ttImmeuble.daDateFinContrat   = ctrat.dtfin
        .
        // Promoteur
        find first vbIntnt no-lock
             where vbIntnt.tpcon = ctrat.tpcon
               and vbIntnt.nocon = ctrat.nocon
               and vbIntnt.tpidt = {&TYPEROLE-promoteur} no-error.
        if available vbIntnt then assign
                ttImmeuble.iNumeroPromoteur = vbIntnt.noidt
                ttImmeuble.cNomPromoteur    = outilFormatage:getNomTiers({&TYPEROLE-promoteur}, vbIntnt.noidt)
        .
        // Architecte
        find first vbIntnt no-lock
             where vbIntnt.tpcon = ctrat.tpcon
               and vbIntnt.nocon = ctrat.nocon
               and vbIntnt.tpidt = {&TYPEROLE-architecte} no-error.
        if available vbIntnt then assign
               ttImmeuble.iNumeroArchitecte = vbIntnt.noidt
                ttImmeuble.cNomArchitecte    = outilFormatage:getNomTiers({&TYPEROLE-architecte}, vbIntnt.noidt)
        .
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.
