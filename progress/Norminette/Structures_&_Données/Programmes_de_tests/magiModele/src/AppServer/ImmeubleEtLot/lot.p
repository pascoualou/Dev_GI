/*------------------------------------------------------------------------
File        : lot.p
Purpose     :
Author(s)   : kantena - 03/08/2016
Notes       :
Tables      : BASE sadb : intnt local dtlot unite cpUni ladrs telephones sys_pr
                          ctrat tache unite cpuni
              17/10/2017  npo  #7811 add type de lot (registre)
derniere revue: 2018/05/22 - phm: KO
        traiter les TODO
        traductions
----------------------------------------------------------------------*/
using parametre.syspr.syspr.
using parametre.syspr.parametrageNatureLot.
using parametre.pclie.parametrageTarifLoyer.

{preprocesseur/nature2contrat.i}
{preprocesseur/nature2voie.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2telephone.i}
{preprocesseur/type2role.i}
{preprocesseur/type2occupant.i}
{preprocesseur/unite2surface.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2lot.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{immeubleEtLot/include/lot.i}
{immeubleEtLot/include/equipementBien.i}
{immeubleEtLot/include/cpuni.i}
{immeubleEtLot/include/lotCommercialisation.i}
{note/include/notes.i}
{adresse/include/adresse.i}
{immeubleEtLot/include/surface.i &nomTable=ttSurfaceLot &serialName=ttSurface}
{adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationLoca}
{adresse/include/moyenCommunication.i &nomTable=ttMoyenCommunicationCopro}
{adresse/include/moyenCommunication.i}
{adresse/include/coordonnee.i}
{adresse/include/coordonnee.i &nomTable=ttCoordonneeLocataire}
{adresse/include/coordonnee.i &nomTable=ttCoordonneeCoproprietaire}
{role/include/roleContrat.i}
{serviceGestion/include/serviceGestion.i}
{serviceGestion/include/gestionnaire.i}

define variable ghProcMoyen   as handle no-undo. // getCoordonneLot peut être lancé en externe ou a partir de getCoordonneLots
define variable giMaxLigne    as integer no-undo initial 50000.  // nombre maxi de lignes renvoyées - TODO : parametrage base !!!
define variable giNombreLigne as integer no-undo.

function getNumeroImmeuble returns integer (piNumeroBien as int64):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Appelé par le service beLot.cls
    ------------------------------------------------------------------------------*/
    define buffer local for local.
    for first local no-lock
         where local.noloc = piNumeroBien:
         return local.noimm.
    end.
    return -9999. //Immeuble 0 existe en base
end function.

function cToDate returns date private(piDate as integer, pcTpcon as character, piNocon as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcDate  as character no-undo.
    define variable vdaDate as date      no-undo.

    if piDate > 0
    then do:
        assign
            vcDate  = string(piDate)
            vcDate  = substitute('&1/&2/3', substring(vcDate, 7, 2, 'character'), substring(vcDate, 5, 2, 'character'), substring(vcDate, 1, 4, 'character'))
            vdaDate = date(vcDate)
        no-error.
        if error-status:num-messages > 0
        then do:
            mError:createError(3, 211683, substitute('&2&1&3&1ctrat:&4/&5', separ[1], vcDate, session:date-format, pcTpcon, piNocon)).
            return ?.
        end.
        return vdaDate.
    end.
    return ?.

end function.

function donneNumeroServiceContrat returns integer private(pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne le numero du service à partir d'un type et numero de contrat
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcTypePrincipal   as character no-undo.
    define variable viNumeroPrincipal as integer   no-undo.

    define buffer ctctt for ctctt.

    if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} or pcTypeContrat = {&TYPECONTRAT-mandat2Syndic}
    then assign
        vcTypePrincipal   = pcTypeContrat
        viNumeroPrincipal = piNumeroContrat
    .
    else do:
        /* Recherche du type de contrat maitre */
        find first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}  /* Rattaché à la copro */
              and ctctt.tpct2 = pcTypeContrat
              and ctctt.noct2 = piNumeroContrat no-error.
        if not available ctctt
        then find first ctctt no-lock
            where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}  /* Rattaché à la gérance */
              and ctctt.tpct2 = pcTypeContrat
              and ctctt.noct2 = piNumeroContrat no-error.
        if available ctctt
        then assign              /* Mémorisation du contrat principal */
            vcTypePrincipal   = ctctt.tpct1
            viNumeroPrincipal = ctctt.noct1
        .
    end.
    /* Recherche du lien entre le contrat "Service de gestion"  et le contrat principal */
    for first ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
          and ctctt.tpct2 = vcTypePrincipal
          and ctctt.noct2 = viNumeroPrincipal:
        return ctctt.noct1.
    end.
    return 0.

end function.

function isLotPrincipal returns logical private(pcNatureLot as character):
    /*------------------------------------------------------------------------------
    Purpose:  Lot principal
    Notes:
    ------------------------------------------------------------------------------*/
    return can-find(first sys_pr no-lock
        where sys_pr.tppar = "NTLOT"
          and sys_pr.cdpar = pcNatureLot
          and sys_pr.zone1 = 1).

end function.

function surfaceM2 returns decimal private(pcUniteSurface as character, pdeSurfacePonderee as decimal):
    /*------------------------------------------------------------------------------
    Purpose:  calcul la surface réelle d'une surface pondérée
    Notes:
    ------------------------------------------------------------------------------*/
    case pcUniteSurface:
        when {&UNITESURFACE-million}     then return pdeSurfacePonderee * {&Million}.
        when {&UNITESURFACE-dixMillieme} then return pdeSurfacePonderee * {&DixMillieme}.
        when {&UNITESURFACE-cent}        then return pdeSurfacePonderee * {&Cent}.
        when {&UNITESURFACE-dixMille}    then return pdeSurfacePonderee * {&DixMille}.
        otherwise return pdeSurfacePonderee * {&unite}.
    end case.

end function.

function crettListeLot returns logical private(piNumeroTraitement as integer, piNumeroLocal as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose:  créer un enregistrement ttListeLot ainsi que les coordonnees associees
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer local for local.
    define buffer imble for imble.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

    define variable viNumeroBailleur    as integer   no-undo.
    define variable viNumeroContrat     as integer   no-undo.
    define variable vcTypeCopro         as character no-undo.
    define variable viNumeroCopro       as integer   no-undo.
    define variable vcNomCopro          as character no-undo.
    define variable vdaAchLot           as date      no-undo.
    define variable vcCodeRegroupe      as character no-undo.
    define variable vcNomOccupant       as character no-undo.
    define variable vdaEntreeOccupant   as date      no-undo.
    define variable vcTypeOccupant      as character no-undo.

    /* Repositionnement sur le local en cours */
    for first local no-lock
        where local.noloc = piNumeroLocal
      , first imble no-lock
        where imble.noimm = local.noimm:
        run OccupLot(
            buffer local,
            output vcNomOccupant,
            output vdaEntreeOccupant,
            output viNumeroBailleur,
            output viNumeroContrat,
            output vcTypeCopro,
            output viNumeroCopro,
            output vdaAchLot,
            output vcTypeOccupant,
            output vcCodeRegroupe
        ).
        if vcTypeCopro > "" and viNumeroCopro <> 0 then vcNomCopro = outilFormatage:getNomTiers(vcTypeCopro, viNumeroCopro).
        create ttListeLot.
        assign
            giNombreLigne                = giNombreLigne + 1
            ttListeLot.iNumeroTraitement = piNumeroTraitement
            ttListeLot.iNumeroImmeuble   = local.noimm
            ttListeLot.cNomImmeuble      = imble.lbnom
            ttListeLot.iNumeroLot        = local.nolot
            ttListeLot.iNumeroBien       = local.noloc
            ttListeLot.cLibelleNature    = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
            ttListeLot.cCodeNature       = local.ntLot
            ttListeLot.cDesignation      = local.lbgrp
            ttListeLot.dSurfaceReelle    = local.sfree
            ttListeLot.cCodeBatiment     = local.cdbat
            ttListeLot.cCodeEntree       = local.lbdiv
            ttListeLot.cCodeEscalier     = local.cdesc
            ttListeLot.cCodeEtage        = local.CdEta
            ttListeLot.cCodePorte        = local.cdpte
            ttListeLot.cNomOccupant      = local.NmOcc
            ttListeLot.daDateEntree      = local.DtEnt
            ttListeLot.lIsPrincipal      = isLotPrincipal(local.ntlot)
            ttListeLot.cCodeOrientation  = local.orien
            ttListeLot.iNombrePiece      = local.nbprf
            ttListeLot.iNumeroProprietaire      = viNumeroCopro
            ttListeLot.cNomProprietaire         = vcNomCopro
            ttListeLot.cLibelleTypeProprietaire = outilTraduction:getLibelleParam("TPOCC", vcTypeOccupant)
            ttListeLot.lSelected         = false
            ttListeLot.lAffSel           = false
            ttListeLot.CRUD              = 'R'
            ttListeLot.dtTimestamp       = datetime(local.dtmsy, local.hemsy)
            ttListeLot.rRowid            = rowid(local)
        .
        if pcTypeContrat = {&TYPECONTRAT-mandat2gerance}
        then for first intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-acte2propriete}
              and intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.noidt = local.noloc
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon:
            ttlisteLot.daDateAchat = ctrat.dtdeb.   //gga ou ctrat.dtsig ???????????
        end.
    end.
    if giNombreLigne >= giMaxLigne
    then do:
        mError:createError({&warning}, 211668, string(giMaxLigne)).  // nombre maxi d'enregistrement atteint
        return false.
    end.
    return true.

end function.

function calculPourcentageTauxReduit returns decimal (piNumeroImmeuble as integer, pcCodeCle as character):
    /*------------------------------------------------------------------------------
    Purpose: Service de calcul du pourcentage de taux reduit (interventions)
    Notes:   Appelé par beLot.cls
    ------------------------------------------------------------------------------*/
    define variable vdMontantTotalCle   as decimal no-undo.
    define variable vdMontantCommercial as decimal no-undo.

    define buffer local for local.
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.
    define buffer milli for milli.

    /*--> Chargement des lots */
    for each local no-lock
       where local.noimm = piNumeroImmeuble
      , each Intnt no-lock
       where Intnt.TpIdt = {&TYPEBIEN-lot}
         and Intnt.NoIdt = Local.Noloc
         and Intnt.TpCon = {&TYPECONTRAT-acte2propriete}
      , first ctrat no-lock
        where ctrat.TpCon = intnt.TpCon
          and ctrat.NoCon = intnt.Nocon
      , first milli no-lock
        where milli.cdcle = pcCodeCle
          and milli.noimm = piNumeroImmeuble
          and milli.nolot = local.nolot:
        vdMontantTotalCle = vdMontantTotalCle + milli.nbpar.
        if local.tplot = "00002" then vdMontantCommercial = vdMontantCommercial + milli.Nbpar.
    end.
    return round(if vdMontantTotalCle <> 0 then 100 - (vdMontantCommercial * 100 / vdMontantTotalCle) else 0, 2).

end function.

procedure controleSaisieSurface:
    /*------------------------------------------------------------------------------
    Purpose: CONTROLE FRAME SURFACE
    Notes:   service Appelé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttLot.
    define variable vdeSfLotUse as decimal no-undo.
    define variable voSysPrNatureLot as class parametrageNatureLot no-undo.
    
    define buffer local for local.
    define buffer cpuni for cpuni.
    define buffer unite for unite.
    
    // Si lot divisible alors surface utile obligatoire
boucle_lot:
    for first ttLot 
        where ttLot.CRUD = "U"
           or ttLot.CRUD = "C":
        if ttLot.lIsDivisible then do:
            if ttLot.sfRee = 0 then do:
                mError:createError({&error}, 104497).    // La surface utile brute est obligatoire lorsque le lot est divisible
                leave boucle_lot.
            end.
            if ttLot.sfree < ttLot.sfbur + ttLot.sfStk + ttLot.sfCom then do:
                mError:createError({&error}, 107463).    // La surface concernant la taxe sur les bureaux doit être inférieure ou égale à la surface utile brute.
                leave boucle_lot.
            end.
        end.
        // Controle de la nature divisible
        voSysPrNatureLot = new parametrageNatureLot(ttlot.cCodeNature).
        if ttLot.lIsDivisible and voSysPrNatureLot:isDivisible() then do:
            mError:createError({&error}, 104529).     // La nature de ce lot ne peut être divisible.
            leave boucle_lot.
        end.
        delete object voSysPrNatureLot.

        // On regarde la possition initiale du flag de division
        for first local no-lock
            where local.noimm = ttLot.iNumeroImmeuble
              and local.nolot = ttLot.iNumeroLot:
            // On regarde si on peut rendre indivisible le lot
            if local.fgdiv and not ttLot.lIsDivisible then do:
                // Possible uniquement si le lot fait parti à 100% d'une seule unite
                for each cpuni no-lock
                   where cpuni.noimm = ttLot.iNumeroImmeuble
                     and cpuni.nolot = ttLot.iNumeroLot
                 , each unite no-lock
                   where unite.nomdt = cpuni.nomdt
                     and unite.noapp = cpuni.noapp
                     and unite.nocmp = cpuni.nocmp
                     and unite.noact = 0:
                    vdeSfLotUse = cpuni.sflot.
                end.
                if ttLot.sfree <> vdeSfLotUse then do:
                    mError:createError({&error}, 104502).
                    leave boucle_lot.
                end.
            end.
            // On regarde si la surface saisie est inférieur à la surface antérieur
            if ttLot.lIsDivisible then do:
                vdeSfLotUse = 0.
                for each cpuni no-lock
                   where cpuni.noimm = ttLot.iNumeroImmeuble
                     and cpuni.nolot = ttLot.iNumeroLot
                     and cpuni.noapp <> 998
                  , each unite no-lock
                   where unite.nomdt = cpuni.nomdt
                     and unite.noapp = cpuni.noapp
                     and unite.nocmp = cpuni.nocmp
                     and unite.noact = 0:
                    vdeSfLotUse = vdeSfLotUse + cpuni.sflot.
                end.
                if vdeSfLotUse > ttLot.sfree then do:
                    mError:createError({&error}, 104503).    // Le total des unites affectées du lot est pas supérieur au nouvau total
                    leave boucle_lot.
                end.
            end.
            leave boucle_lot.
        end.
    end.
end procedure.

procedure controleSaisieProprietaire:
    /*------------------------------------------------------------------------------
    Purpose: CONTROLE FRAME PROPRIETAIRE
             - Date acquisition obligatoire.
             - Date acquisition > date construction.
             - Date acquisition < date du jour.
             - Date de vente > date acquisition.
             - Date de vente < date du jour.
    Notes:   service Appelé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttLot.
    
boucle_lot:
    for first ttLot 
        where ttLot.CRUD = "U"
           or ttLot.CRUD = "C":
        // Controle de la date acquisition. 
        if ttLot.daDateAchat = ? then do:
            mError:createError({&error}, 100418).
            leave boucle_lot.
        end.
        if can-find(first intnt no-lock
             where intnt.noidt = ttLot.iNumeroImmeuble
               and intnt.tpidt = {&TYPEBIEN-immeuble}
               and intnt.tpcon = {&TYPECONTRAT-construction} 
               and intnt.nocon = 0)
        and can-find(first ctrat no-lock
             where ctrat.tpcon = {&TYPECONTRAT-construction}
               and ctrat.nocon = 0
               and ctrat.dtdeb > ttLot.daDateAchat) then do:
            mError:createError({&error}, 101474).         // Date acquisition > date construction : Sauvegarde date acquisition
            leave boucle_lot.
        end.
        // Contrele Date de Vente
        if ttLot.daDateVente <> ? then do:
            if ttLot.daDateVente > today then do:
                mError:createError({&error}, 102020).      // Date de vente > date du jour
                leave boucle_lot.
            end.
            if ttLot.daDateAchat >= ttLot.daDateVente then do:
                mError:createError({&error}, 101608).      // Date de vente > date d'achat
                leave boucle_lot.
            end.
        end.
    end.

end procedure.

procedure controleSaisieSituation:
    /*------------------------------------------------------------------------------
    Purpose: CONTROLE FRAME SITUATION LOCAL
    Notes:   service Appelé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttLot.
    define variable voSysPrNatureLot  as class parametrageNatureLot  no-undo.
    define variable voParamTarifLoyer as class parametrageTarifLoyer no-undo.

    voParamTarifLoyer = new parametrageTarifLoyer().

boucle_lot:
    for first ttLot 
        where ttLot.CRUD = "U"
           or ttLot.CRUD = "C":
        // Controle numero de lot.
        if ttLot.iNumeroLot = 0 then do:
            mError:createError({&error}, 100395).    // "Erreur de Saisie" "Le Numero de local est obligatoire..."
            leave boucle_lot.
        end.
        // Controle du nombre de pieces : Recuperer le Nombre de Pieces d'apres NTLOT.
        voSysPrNatureLot = new parametrageNatureLot(ttlot.cCodeNature).
        if ttLot.iNombrePiece < voSysPrNatureLot:getNbPieceMinimum() then do:
            // "Situation Lot" "Le nombre de pieces ne peut etre nul."
            mError:createError({&error}, 101587).
            leave boucle_lot.
        end.
        if ttLot.iNombrePiece > voSysPrNatureLot:getNbPieceMaximum() then do:
            mError:createError({&error}, 101627).     // "Situation Lot" "Le nombre de pieces est trop grand pour cette nature de lot.
            leave boucle_lot.
        end.
        if ttLot.lIsDivisible and voSysPrNatureLot:isDivisible() then do:
            mError:createError({&error}, 104529).    // La nature de ce lot ne peut être divisible.
            leave boucle_lot.
        end.
        delete object voSysPrNatureLot.

        // Module optionnel: TARIF DE LOYER eurostudiome - type de contrat et type de gestion obligatoire
        if voParamTarifLoyer:isActif() and integer(mtoken:cRefPrincipale) = 1501 then do:
            if ttlot.cEUTypeGestion = "" then do:
                mError:createError({&error}, "Type de gestion obligatoire").    /* Type de gestion obligatoire */
                leave boucle_lot.
            end.
            /* ajout SY le 02/03/2009 : si type de gestion <> non géré */
            if ttLot.cEUTypeGestion <> "NON GERE"
            and ttLot.cEUTypeContrat = "" then do:
                mError:createError({&error}, "Type de contrat obligatoire").    // Type de contrat obligatoire
                leave boucle_lot.
            end.
        end.

        /* 
           Controle spécifiques pour InSitu 
           Recherche de l'immeuble dans la table pclie 
        */
        if can-find(first pclie no-lock 
                    where pclie.tppar = "INSITU") 
        then do:
            if can-find(first pclie no-lock
                        where pclie.tppar = "INSITU" + "-IMMEUBLE"
                          and pclie.zon01 = STRING(ttLot.iNumeroImmeuble)) 
            then do:
                if ttLot.cCodePorte = "" then do:
                    mError:createError({&error}, "Code porte obligatoire").
                    leave boucle_lot.
                end.
                if ttlot.cEUTypeGestion = "" then do:
                    mError:createError({&error}, "Type de gestion obligatoire").
                    leave boucle_lot.
                end.
                if ttlot.cEUTypeGestion <> "NON GERE" and ttlot.cEUTypeContrat = "" then do:
                    mError:createError({&error}, "Type de contrat obligatoire").
                    leave boucle_lot.
                end.
            end.
        end.
    end.
    delete object voParamTarifLoyer.
end procedure.

procedure getCoordonneeLotInterne private:
    /*------------------------------------------------------------------------------
    Purpose: Récupère les coordonnées locataire et copropriétaire d'un lot
             si adresse/moyenCommunication.p est déjà lancé, on vient de getCoordonneeLots.
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroBien as int64 no-undo.

    define variable viNumeroBailleur  as integer   no-undo.
    define variable viNumeroContrat   as integer   no-undo.
    define variable vcTypeCopro       as character no-undo.
    define variable viNumeroCopro     as integer   no-undo.
    define variable vdaAchLot         as date      no-undo.
    define variable vcCodeRegroupe    as character no-undo.
    define variable vcNomOccupant     as character no-undo.
    define variable vdaEntreeOccupant as date      no-undo.
    define variable vcTypeOccupant    as character no-undo.
    define variable vlDejaLancee      as logical   no-undo initial true.

    define buffer local for local.
    define buffer ladrs for ladrs.

    find first local no-lock where local.noloc = piNumeroBien no-error.
    if not available local then return.

    if not valid-handle(ghProcMoyen)
    then do:
        run adresse/moyenCommunication.p persistent set ghProcMoyen.
        run getTokenInstance in ghProcMoyen(mToken:JSessionId).
        vlDejaLancee = false.
    end.
    run OccupLot(
        buffer local,
        output vcNomOccupant,
        output vdaEntreeOccupant,
        output viNumeroBailleur,
        output viNumeroContrat,
        output vcTypeCopro,
        output viNumeroCopro,
        output vdaAchLot,
        output vcTypeOccupant,
        output vcCodeRegroupe
    ).
    /* Contacts proprietaire */
    if vcTypeCopro > "" and viNumeroCopro <> 0
    then do:
        create ttCoordonneeCoproprietaire.
        assign
            ttCoordonneeCoproprietaire.iNumeroIdentifiant = local.noloc
            ttCoordonneeCoproprietaire.cJointure          = "1"
        .
        /* Récupérer les moyens de communication du copro */
        run getMoyenCommunication in ghProcMoyen(vcTypeCopro, viNumeroCopro, "1", output table ttMoyenCommunicationCopro by-reference).
        /* compléter avec info propriétaire si copro et inversement */
        run getMoyenCommunication in ghProcMoyen (if vcTypeCopro = {&TYPEROLE-coproprietaire} then {&TYPEROLE-mandant} else {&TYPEROLE-coproprietaire},
            viNumeroCopro, "1", output table ttMoyenCommunicationCopro by-reference).
    end.

    /*--> Locataire / Occupant */
    if viNumeroBailleur <> 0
    then for last ladrs no-lock
        where ladrs.tpidt = {&TYPEROLE-locataire}
          and ladrs.noidt = viNumeroBailleur
          and ladrs.tpadr = {&TYPEADRESSE-Principale}:
        create ttCoordonneeLocataire.
        assign
            ttCoordonneeLocataire.iNumeroIdentifiant = local.noloc
            ttCoordonneeLocataire.cJointure          = "2"
        .
        run getMoyenCommunication in ghProcMoyen(ladrs.tpidt, ladrs.noidt, "2", output table ttMoyenCommunicationLoca by-reference).
    end.
    if not vlDejaLancee then run destroy in ghProcMoyen.

end procedure.

procedure getCoordonneeSelectionLot:
    /*------------------------------------------------------------------------------
    Purpose: Récupère les coordonnées locataire et copropriétaire d'un lot
             hProcMoyen est déclaré dans le main-block.
    Notes  : service utilisé par beLot.cls, beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter table for ttListeLot.
    define output parameter table for ttCoordonneeLocataire.
    define output parameter table for ttCoordonneeCoproprietaire.
    define output parameter table for ttMoyenCommunicationLoca.
    define output parameter table for ttMoyenCommunicationCopro.

    run adresse/moyenCommunication.p persistent set ghProcMoyen.
    run getTokenInstance in ghProcMoyen(mToken:JSessionId).
    for each ttListeLot:
        run getCoordonneeLot(
            ttListeLot.iNumeroBien,
            output table ttCoordonneeLocataire      by-reference,
            output table ttCoordonneeCoproprietaire by-reference,
            output table ttMoyenCommunicationLoca   by-reference,
            output table ttMoyenCommunicationCopro  by-reference).
    end.
    run destroy in ghProcMoyen.

end procedure.

procedure getCoordonneeLot:
    /*------------------------------------------------------------------------------
    Purpose: Récupère les coordonnées locataire et copropriétaire d'un lot
    Notes: service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroBien as int64 no-undo.
    define output parameter table for ttCoordonneeLocataire.
    define output parameter table for ttCoordonneeCoproprietaire.
    define output parameter table for ttMoyenCommunicationLoca.
    define output parameter table for ttMoyenCommunicationCopro.

    run getCoordonneeLotInterne(piNumeroBien).

end procedure.

procedure getEquipementLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLot as int64 no-undo.
    define output parameter table for ttEquipementBien.
    define output parameter table for ttFichierJointEquipement.

    define variable vhproc as handle no-undo.

    empty temp-table ttEquipementBien.
    empty temp-table ttFichierJointEquipement.
    run ImmeubleEtLot/equipementBien.p persistent set vhproc.
    run getTokenInstance  in vhproc(mToken:JSessionId).
    run getEquipementBien in vhproc(piNumeroLot, {&TYPEBIEN-lot}, output table ttEquipementBien by-reference, output table ttFichierJointEquipement by-reference).
    run destroy in vhproc.

end procedure.

procedure occupLot:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des informations occupant
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer local for local.
    define output parameter pcNomOccupant     as character  no-undo.
    define output parameter pdaEntreeOccupant as date       no-undo.
    define output parameter piNumeroBail      as integer    no-undo.
    define output parameter piNumeroContrat   as integer    no-undo.
    define output parameter pcTypeRole        as character  no-undo.
    define output parameter piNumeroRole      as integer    no-undo.
    define output parameter pdaAchLot         as date       no-undo.
    define output parameter pcTypeOccupant    as character  no-undo.
    define output parameter pcCodeRegroupe    as character  no-undo.

    define buffer cpuni   for cpuni.
    define buffer unite   for unite.
    define buffer ctrat   for ctrat.
    define buffer vbCtrat for ctrat.
    define buffer intnt   for intnt.
    define buffer tache   for tache.

    assign
        pcCodeRegroupe = "A"
        pcTypeOccupant = {&TYPEOCCUPANT-indefini}
    .
    for each cpuni no-lock
        where cpuni.NoImm = local.noimm
          and cpuni.NoLot = local.nolot
      , each unite no-lock
        where unite.NoMdt = cpuni.NoMdt
          and unite.NoApp = cpuni.NoApp
          and unite.NoAct = 0
          and unite.NoCmp = cpuni.NoCmp
      , first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = unite.nomdt
          and ctrat.ntcon <> {&NATURECONTRAT-mandatLocation}           // Ignorer mandat Location (FL) et baux spécial vacant propriétaire
          and ctrat.ntcon <> {&NATURECONTRAT-mandatLocationIndivision}
          and ctrat.ntcon <> {&NATURECONTRAT-mandatLocationDelegue}:
        /*--> Propriétaire */
        assign
            piNumeroContrat = unite.nomdt
            pcTypeRole      = {&TYPEROLE-mandant}
            piNumeroRole    = ctrat.norol
        .
        /*--> unite reservé au mandant */
        if integer(unite.cdcmp) = 3
        then assign
            pcNomOccupant  = ctrat.lbnom
            pcTypeOccupant = {&TYPEOCCUPANT-occupant}
        .
        else if piNumeroBail = 0 and unite.norol <> 0
        then do:
            piNumeroBail = unite.norol.
            for first vbCtrat no-lock
                where vbCtrat.tpcon = {&TYPECONTRAT-bail}
                  and vbCtrat.nocon = unite.norol:
                assign
                    pcNomOccupant  = vbCtrat.lbnom
                    pcTypeOccupant = if vbCtrat.ntcon = {&NATURECONTRAT-mandatSousLocation}
                                     or vbCtrat.ntcon = {&NATURECONTRAT-mandatSousLocationDelegue} then {&TYPEOCCUPANT-bailleurSousLoc} else {&TYPEOCCUPANT-bailleur}
                .
            end.
            for last tache no-lock
                where Tache.tpcon = {&TYPECONTRAT-bail}
                  and Tache.nocon = unite.norol
                  and Tache.tptac = {&TYPETACHE-quittancement}:
                pdaEntreeOccupant = Tache.dtdeb.
            end.
        end.
    end.

    if piNumeroBail = 0 // Si aucun bail, prendre l'occupant saisi
    then assign
        pdaEntreeOccupant = local.dtent
        pcTypeOccupant    = local.lbdiv3
        pcNomOccupant     = local.nmocc
    .
    /*--> Récupération du copropriétaire actif, le mandat de syndic ne doit pas etre résilié */
    for each intnt no-lock
        where intnt.tpCon = {&TYPECONTRAT-titre2copro}
          and intnt.tpidt = {&TYPEBIEN-lot}
          and intnt.noidt = Local.noloc
          and intnt.NbDen = 0
      , first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and ctrat.nocon = int64(truncate(intnt.nocon / 100000, 0))   // integer(substring(string(intnt.nocon, "9999999999"), 1, 5, 'character'))
          and ctrat.dtree = ?:
        assign
            pcCodeRegroupe = if intnt.cdreg > "" then intnt.cdreg else pcCodeRegroupe
            pdaAchLot      = cToDate(intnt.nbnum, ctrat.tpcon, ctrat.nocon)
        .
        for first vbCtrat no-lock
            where vbCtrat.tpcon = intnt.tpcon
              and vbCtrat.nocon = intnt.nocon:
            assign
                piNumeroContrat = vbCtrat.nocon
                pcTypeRole      = {&TYPEROLE-coproprietaire}
                piNumeroRole    = vbCtrat.norol
            .
            /*--> SI occupant */
            if pcTypeOccupant = {&TYPEOCCUPANT-occupant} or pcTypeOccupant = ? or pcTypeOccupant = ""
            then assign
                pdaEntreeOccupant = pdaAchLot
                pcTypeOccupant    = {&TYPEOCCUPANT-occupant}
                pcNomOccupant     = vbCtrat.LbNom
            .
        end.
    end.

end procedure.

procedure rechercheLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttListeLot.
    define output parameter table for ttAdresse.
    define output parameter table for ttSurfaceLot.

    define variable vhProcAdresse        as handle    no-undo.
    define variable vhProcSurface        as handle    no-undo.
    define variable viGestion            as integer   no-undo.
    define variable viNumeroMandatSyndic as integer   no-undo.
    define variable vcListeMandatSyndic  as character no-undo.
    define variable vlLotAPrendre        as logical   no-undo.
    define variable vlAucunMandat        as logical   no-undo.
    define variable vlMandatGerance      as logical   no-undo.
    define variable vlMandatPrededent    as logical   no-undo.
    define variable viNumeroTemporaire   as integer   no-undo.
    define variable viCpt                as integer   no-undo.
    // Critères de recherche immeuble et lot
    define variable vcAdresseImmeuble  as character no-undo.
    define variable viNumeroImmeuble   as integer   no-undo.
    define variable viNumeroImmeuble1  as integer   no-undo.
    define variable viNumeroImmeuble2  as integer   no-undo.
    define variable viNumeroMandat     as integer   no-undo.
    define variable viNumeroMandat1    as integer   no-undo.
    define variable viNumeroMandat2    as integer   no-undo.
    define variable vlGerance          as logical   no-undo.
    define variable vlCopropriete      as logical   no-undo.
    define variable vlAucun            as logical   no-undo.
    define variable vcStatut           as character no-undo.
    define variable vcService          as character no-undo.
    // Critères lot
    define variable viNumeroLot1  as integer   no-undo.
    define variable viNumeroLot2  as integer   no-undo.
    define variable vcNatureLot   as character no-undo.
    // Critères de recherche supplémentaires immeuble et lot
    define variable vcTypeImmeuble        as character no-undo.
    define variable vcSecteurGeographique as character no-undo.
    define variable vcNatureBien          as character no-undo.
    define variable vcCategorieBien       as character no-undo.

    define buffer local for local.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer imble for imble.

    assign
        vcAdresseImmeuble    = poCollection:getCharacter("cAdresseImmeuble")
        viNumeroImmeuble     = poCollection:getInteger  ("iNumeroImmeuble")
        viNumeroImmeuble1    = poCollection:getInteger  ("iNumeroImmeuble1")
        viNumeroImmeuble2    = poCollection:getInteger  ("iNumeroImmeuble2")
        viNumeroMandat       = poCollection:getInteger  ("iNumeroMandat")
        viNumeroMandat1      = poCollection:getInteger  ("iNumeroMandat1")
        viNumeroMandat2      = poCollection:getInteger  ("iNumeroMandat2")
        vlGerance            = poCollection:getLogical  ("lGerance")
        vlCopropriete        = poCollection:getLogical  ("lCopropriete")
        vcStatut             = poCollection:getCharacter("cCodeStatut")
        vcService            = poCollection:getCharacter("cCodeService")
        vcTypeImmeuble       = poCollection:getCharacter("cCodeTypeImmeuble")
        vcSecteurGeographique= poCollection:getCharacter("cCodeSecteur")
        vcNatureBien         = poCollection:getCharacter("cCodeNatureBien")
        vcCategorieBien      = poCollection:getCharacter("cCodeCategorieImmeuble")
    .

    {&_proparse_ prolint-nowarn(when)}
    assign
        vcAdresseImmeuble     = '' when vcAdresseImmeuble = ?
        vcStatut              = '' when vcStatut    = 'all' or vcStatut = ?
        vcService             = '' when vcService   = 'all' or vcService = ?
        vcNatureLot           = '' when vcNatureLot = 'all' or vcNatureLot = ?
        vcTypeImmeuble        = '' when vcTypeImmeuble = 'all' or vcTypeImmeuble = ?
        vcSecteurGeographique = '' when vcSecteurGeographique = 'all' or vcSecteurGeographique = ?
        vcNatureBien          = '' when vcNatureBien    = 'all' or vcNatureBien = ?
        vcCategorieBien       = '' when vcCategorieBien = 'all' or vcCategorieBien = ?

        viNumeroImmeuble1 = viNumeroImmeuble  when viNumeroImmeuble > 0
        viNumeroImmeuble2 = viNumeroImmeuble  when viNumeroImmeuble > 0
        viNumeroImmeuble1 = 0 when viNumeroImmeuble1 = ?
        viNumeroImmeuble2 = viNumeroImmeuble1 when viNumeroImmeuble2 = ?
        viNumeroImmeuble2 = if viNumeroImmeuble1 = 0 and viNumeroImmeuble2 = 0 then 999999999 else if viNumeroImmeuble2 > 0 then viNumeroImmeuble2 else viNumeroImmeuble1

        viNumeroMandat1 = viNumeroMandat when viNumeroMandat > 0
        viNumeroMandat2 = viNumeroMandat when viNumeroMandat > 0
        viNumeroMandat1 = 0 when viNumeroMandat1 = ?
        viNumeroMandat2 = viNumeroMandat1 when viNumeroMandat2 = 0 or viNumeroMandat2 = ?
        viNumeroMandat2 = if viNumeroMandat1 = 0 and viNumeroMandat2 = 0 then 99999999 else if viNumeroMandat2 > 0 then viNumeroMandat2 else viNumeroMandat1

        viNumeroLot1   = 0 when viNumeroLot1 = ?
        viNumeroLot2   = viNumeroLot1 when viNumeroLot2 = 0 or viNumeroLot2 = ?
        viNumeroLot2   = if viNumeroLot1 = 0 and viNumeroLot2 = 0 then 99999999 else if viNumeroLot2 > 0 then viNumeroLot2 else viNumeroLot1
        giNombreLigne = 0      // initialise le compteur pour le nombre max de lignes à renvoyer en rechercheLot
    .

/*
message
    'viNumeroImmeuble      = ' viNumeroImmeuble      skip
    'viNumeroImmeuble1     = ' viNumeroImmeuble1     skip
    'viNumeroImmeuble2     = ' viNumeroImmeuble2     skip
    'vcAdresse             = ' vcAdresseImmeuble     skip
    'vcStatut              = ' vcStatut              skip
    'vcService             = ' vcService             skip
    'vcNatureLot           = ' vcNatureLot           skip
    'vcTypeImmeuble        = ' vcTypeImmeuble        skip
    'vcSecteurGeographique = ' vcSecteurGeographique skip
    'vcNatureBien          = ' vcNatureBien          skip
    'vcCategorieBien       = ' vcCategorieBien       skip
    'viNumeroMandat        = ' viNumeroMandat        skip
    'viNumeroMandat1       = ' viNumeroMandat1       skip
    'viNumeroMandat2       = ' viNumeroMandat2       skip
    'viNumeroLot1          = ' viNumeroLot1          skip
    'viNumeroLot2          = ' viNumeroLot2          skip
view-as alert-box.
*/

run adresse/adresse.p persistent set vhProcAdresse.
run getTokenInstance  in vhProcAdresse(mToken:JSessionId).

boucleImmeuble:
    for each imble no-lock
        where imble.noimm >= viNumeroImmeuble1 and imble.noimm <= viNumeroImmeuble2:
        if vcService > ''
        then do:
            viGestion = 0.
            run application/envt/gesflges.p (mToken, integer(vcService), input-output viGestion, 'Direct', substitute('&1|&2', {&TYPEBIEN-immeuble}, imble.noimm)).
            if viGestion > 0 then next boucleImmeuble.
        end.
        if vcAdresseImmeuble > '' and not dynamic-function('lDansAdresses' in vhProcAdresse, vcAdresseImmeuble, {&TYPEBIEN-immeuble}, imble.noimm) then next boucleImmeuble.

        /* Rechercher si immeuble de copro */
        assign
            viNumeroMandatSyndic = 0
            vcListeMandatSyndic = ""
        .
        for each intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = imble.noimm
              and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon:
            if ctrat.Dtree = ? then viNumeroMandatSyndic = ctrat.nocon.
            vcListeMandatSyndic = vcListeMandatSyndic + "," + string(ctrat.nocon).
        end.
        vcListeMandatSyndic = trim(vcListeMandatSyndic, ',').

boucleLocal:
        for each local no-lock
            where local.noimm = imble.noimm
              and local.nolot >= viNumeroLot1
              and local.nolot <= viNumeroLot2
              and local.nolot > 0:
            /* Critère nature de lot */
            if vcNatureLot > '' and lookup(local.ntlot, vcNatureLot) = 0 then next boucleLocal.

            assign
                vlLotAPrendre     = false
                vlAucunMandat     = false
                vlMandatGerance   = false
                vlMandatPrededent = false
            .
            if can-find(first intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.noidt = local.noloc
                  and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance})
            then vlMandatGerance = true.
            if vlMandatGerance = false and viNumeroMandatSyndic = 0 and (vcListeMandatSyndic = ? or vcListeMandatSyndic = "")
            then do:
                vlAucunMandat = true.
                if vlAucun then vlLotAPrendre = true.
            end.
            else do:
                if vlGerance then for each intnt no-lock      // Filtre no mandat et Présent
                    where intnt.tpidt = {&TYPEBIEN-lot}
                      and intnt.noidt = local.noloc
                      and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and intnt.nocon >= viNumeroMandat1
                      and intnt.nocon <= viNumeroMandat2
                  , first ctrat no-lock
                    where ctrat.tpcon = intnt.tpcon
                      and ctrat.nocon = intnt.nocon:
                    vlLotAPrendre = true.
                    if ctrat.dtree = ? then do:
                        vlMandatPrededent = true.
                        {&_proparse_ prolint-nowarn(blocklabel)}
                        leave.     // bloc courant
                    end.
                end.
                if vlCopropriete then do:
                    /* Filtre no mandat et Présent */
boucleMandat:
                    do viCpt = 1 to num-entries(vcListeMandatSyndic):
                        viNumeroTemporaire = integer(entry(viCpt, vcListeMandatSyndic)).
                        if viNumeroTemporaire >= viNumeroMandat1 and viNumeroTemporaire <= viNumeroMandat2
                        then vlLotAPrendre = true.
                        leave boucleMandat.
                    end.
                    if viNumeroMandatSyndic > 0
                    and (viNumeroMandatSyndic < viNumeroMandat1 or viNumeroMandatSyndic > viNumeroMandat2)
                    then viNumeroMandatSyndic = 0.
                end.
            end.
            if not vlLotAPrendre then next boucleLocal.

            if not vlAucunMandat
            then do:
                /* présent */
                if vcStatut = {&oui} and not vlMandatPrededent and viNumeroMandatSyndic = 0 then next boucleLocal.
                /* Résiliés */
                if vcStatut = {&non} and (vlMandatPrededent or viNumeroMandatSyndic > 0) then next boucleLocal.
                if integer(vcService) > 0
                then do:                 // Filtrage sur le gestionnaire
                    viGestion = 0.
                    run application/envt/gesflges.p (mToken, integer(vcService), input-output viGestion, 'Direct', substitute('&1|&2', {&TYPEBIEN-immeuble}, imble.noimm)).
                    if viGestion > 0 then next boucleLocal.
                end.
            end.
            if (vcTypeImmeuble > ''        and vcTypeImmeuble <> imble.tpimm)
            or (vcSecteurGeographique > '' and vcSecteurGeographique <> Imble.CdSec)
            or (vcNatureBien > ''          and vcNatureBien <> Imble.NtBie)
            or (vcCategorieBien > ''       and num-entries(imble.lbdiv, "&") >= 9 and vcCategorieBien <> entry(9, imble.lbdiv, "&"))
            then next boucleLocal.

            if not crettListeLot(0, local.noloc, "") then leave boucleImmeuble.
        end.    /* for each local */
    end.
    run immeubleEtLot/surface_crud.p persistent set vhProcSurface.
    run getTokenInstance        in vhProcSurface(mToken:JSessionId).
    run getAdresseSelection     in vhProcAdresse({&TYPEBIEN-lot}, "", "1", table ttListeLot by-reference, output table ttAdresse by-reference, output table ttCoordonnee by-reference, output table ttMoyenCommunication by-reference).
    run readSurfaceSelectionLot in vhProcSurface("PRINCIPALE", table ttListeLot by-reference, output table ttSurfaceLot by-reference).
    run destroy in vhProcSurface.
    run destroy in vhProcAdresse.

end procedure.

procedure getListeLotsImmeuble:
/*------------------------------------------------------------------------------
Purpose: charge la liste des lots d'un immeuble selon numero immeuble
         Pour un immeuble, on ne limite pas le nombre de lots remontés (iMaxLigne)
Notes: service utilisé par beLot.cls, beImmeuble.cls
------------------------------------------------------------------------------*/
define input  parameter piNumeroImmeuble as integer no-undo.
define input  parameter plIsPrincipal    as logical no-undo.
define output parameter table for ttListeLot.

    define variable viNumeroBailleur    as integer   no-undo.
    define variable viNumeroContrat     as integer   no-undo.
    define variable vcTypeCopro         as character no-undo.
    define variable viNumeroCopro       as integer   no-undo.
    define variable vcNomCopro          as character no-undo.
    define variable vdaAchLot           as date      no-undo.
    define variable vcCodeRegroupe      as character no-undo.
    define variable vcNomOccupant       as character no-undo.
    define variable vdaEntreeOccupant   as date      no-undo.
    define variable vcTypeOccupant      as character no-undo.
    define variable viNumeroAppartement as integer   no-undo.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer local for local.


    empty temp-table ttListeLot.
    for each local no-lock
        where local.noimm = piNumeroImmeuble:
        if not plIsPrincipal or isLotPrincipal(local.ntlot)
        then do:
            crettListeLot(0, local.noloc, "").
            run OccupLot(
                buffer local,
                output vcNomOccupant,
                output vdaEntreeOccupant,
                output viNumeroBailleur,
                output viNumeroContrat,
                output vcTypeCopro,
                output viNumeroCopro,
                output vdaAchLot,
                output vcTypeOccupant,
                output vcCodeRegroupe
                ).
            vcNomCopro = ''.       // A laisser, car assigné conditionnellement plus bas.
            if viNumeroBailleur <> 0
            then viNumeroAppartement = truncate(viNumeroBailleur modulo 100000 / 100, 0). 
            if vcTypeCopro > "" and viNumeroCopro <> 0
            then vcNomCopro = outilFormatage:getNomTiers(vcTypeCopro, viNumeroCopro).
            for first ttListeLot
                where ttListeLot.iNumeroBien = local.noloc:
                assign
                    ttListeLot.iNumeroBail              = viNumeroBailleur
                    ttListeLot.iNumeroUL                = viNumeroAppartement
                    ttListeLot.cNomProprietaire         = vcNomCopro
                    ttListeLot.cCodeTypeProprietaire    = vcTypeCopro
                    ttListeLot.iNumeroProprietaire      = viNumeroCopro
                    ttListeLot.cTypeOccupant            = vcTypeOccupant
                    ttListeLot.cLibelleTypeProprietaire = outilTraduction:getLibelleParam("TPOCC", vcTypeOccupant)
                    ttListeLot.daDateAchat              = vdaAchLot
                    ttListeLot.cCodeRegroupement        = vcCodeRegroupe
                .
            end.
            // Loyer mandat : dans acte de propriété du lot.
            if ttlisteLot.daDateAchat = ?
            then for first intnt no-lock
                where intnt.tpcon = {&TYPECONTRAT-acte2propriete}
                  and intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.noidt = local.noloc
              , first ctrat no-lock
                where ctrat.tpcon = intnt.tpcon
                  and ctrat.nocon = intnt.nocon:
                if ttlisteLot.daDateAchat = ? then ttlisteLot.daDateAchat = ctrat.dtdeb.
            end.
        end.
    end.

end procedure.

procedure getListeLotsIntervention:
/*------------------------------------------------------------------------------
Purpose:  charge la liste des lots d'une intervention: sig, dev, ord...
          selon numero traitement, on ne limite pas le nombre de lots remontés (iMaxLigne)
Notes: service utilisé par beLot.cls
------------------------------------------------------------------------------*/
define input  parameter pcTypeContrat      as character no-undo.
define input  parameter piNumeroContrat    as integer   no-undo.
define input  parameter pcTypeTraitement   as character no-undo.
define input  parameter piNumeroTraitement as integer   no-undo.
define output parameter table for ttListeLot.

    define variable viNumeroMandat      as integer no-undo.
    define variable viNumeroAppartement as integer no-undo.
    define buffer DtLot      for DtLot.
    define buffer cpuni      for cpuni.
    define buffer unite      for unite.
    define buffer local      for local.
    define buffer intnt      for intnt.
    define buffer ttListeLot for ttListeLot.

    empty temp-table ttListeLot.
    /* Chargement de la liste de tous les 'lot' de l'immeubke */
    case pcTypeContrat:
        when {&TYPECONTRAT-mandat2Gerance} then for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-lot}
          , first local no-lock
            where local.noloc = intnt.noidt:
            crettListeLot(piNumeroTraitement, local.noloc, pcTypeContrat).
        end.

        when {&TYPECONTRAT-mandat2Syndic} then for first intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-immeuble}
          , each local no-lock
            where local.noimm = intnt.noidt:
            crettListeLot(piNumeroTraitement, local.noloc, pcTypeContrat).
        end.

        when {&TYPECONTRAT-titre2copro} then for each intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-titre2copro}
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.nbden = 0
          , first local no-lock
            where local.noloc = intnt.noidt:
            crettListeLot(piNumeroTraitement, local.noloc, pcTypeContrat).
        end.

        when {&TYPECONTRAT-bail} then do:
            assign
                viNumeroMandat      = truncate(piNumeroContrat / 100000, 0)            // integer(substring(string(piNumeroContrat, "9999999999"), 1, 5, 'character'))
                viNumeroAppartement = truncate(piNumeroContrat modulo 100000 / 100, 0) // integer(substring(string(piNumeroContrat, "9999999999"), 6, 3, 'character')) 
            .
boucle:
            for each unite no-lock   // on fait for each ...by car find first ... by -- ne marche pas!
                where unite.NoMdt = viNumeroMandat
                  and unite.noapp = viNumeroAppartement
                  and (unite.dtfin = ? or unite.dtfin > today)
                by unite.nocmp:
                for each cpuni no-lock
                    where cpuni.nomdt = unite.nomdt
                      and cpuni.noapp = unite.noapp
                      and cpuni.nocmp = unite.nocmp
                  , first local no-lock
                     where local.noimm = cpuni.noimm
                       and local.nolot = cpuni.nolot:
                    crettListeLot(piNumeroTraitement, local.noloc, "").
                end.
                leave boucle.
            end.
        end.
    end case.
    /* Maj des 'lot' concernés par l'intervention */
    mLogger:writeLog(9, substitute("pcTypeTraitement / piNumeroTraitement = &1 / &2", pcTypeTraitement, piNumeroTraitement)).

    for each dtlot no-lock
        where dtlot.tptrt = pcTypeTraitement
          and dtlot.notrt = piNumeroTraitement
      , first local no-lock
        where local.noloc = dtlot.noloc
      , first ttListeLot where ttListeLot.iNumeroBien = local.noloc:
        ttListeLot.lSelected = yes.
    end.

end procedure.

procedure getLot:
    /*------------------------------------------------------------------------------
    Purpose: Chargement du détail d'un lot
    Notes: service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroLoc as int64   no-undo.
    define output parameter table for ttLot.

    define variable viNumeroBailleur    as integer   no-undo.
    define variable viNumeroContrat     as integer   no-undo.
    define variable vcTypeCopro         as character no-undo.
    define variable viNumeroCopro       as integer   no-undo.
    define variable vcNomCopro          as character no-undo.
    define variable vdaAchLot           as date      no-undo.
    define variable vcCodeRegroupe      as character no-undo.
    define variable vcNomOccupant       as character no-undo.
    define variable vdaEntreeOccupant   as date      no-undo.
    define variable vcTypeOccupant      as character no-undo.
    define variable viNumeroAppartement as integer   no-undo.
    define buffer local   for local.
    define buffer imble   for imble.
    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer ctrat   for ctrat.

    empty temp-table ttLot.
    find first local no-lock where local.noloc = piNumeroLoc no-error.
    if not available local then return.

    find first imble no-lock where imble.noimm = local.noimm no-error.
    if not available imble then return.

    create ttLot.
    assign
        ttLot.CRUD                    = 'R'
        ttLot.iNumeroBien             = local.noloc
        ttLot.iNumeroImmeuble         = local.noimm
        ttLot.cNomImmeuble            = imble.lbnom
        ttLot.iNumeroLot              = local.nolot
        ttLot.cDesignation            = local.lbgrp
        ttLot.cCodeBatiment           = caps(trim(local.cdbat))
        ttLot.iNumeroBlocNote         = local.noblc
        ttLot.cEtiquetteClimat        = local.etqclimat
        ttLot.iValeurEtiquetteClimat  = local.valetqclimat   /* npo #7589 */
        ttLot.cEtiquetteEnergie       = local.etqenergie
        ttLot.iValeurEtiquetteEnergie = local.valetqenergie  /* npo #7589 */
        ttLot.cCodeEntree             = local.lbdiv
        ttLot.cCodeEscalier           = local.cDesc
        ttLot.cCodeEtage              = local.cdeta
        ttLot.cCodePorte              = local.cdpte
        ttLot.cCodeTerrasse           = local.cdtlb
        ttLot.cCodeNature             = local.ntlot
        ttLot.cLibelleNature          = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
        ttLot.cCodeOrientation        = local.orien
        ttLot.lIsMeuble               = local.fgmbl
        ttLot.lIsDivisible            = local.fgdiv
        ttLot.lHasWCIndependant       = local.fgwci
        ttLot.lHasAirConditionne      = local.fgair
        ttLot.cCodeModeChauffage      = local.mdcha
        ttLot.cLibelleModeChauffage   = outilTraduction:getLibelleParam("MDCHA", local.mdcha)
        ttLot.cCodeTypeChauffage      = local.tpcha
        ttLot.cLibelleTypeChauffage   = outilTraduction:getLibelleParam("TPCHA", local.mdcha)
        ttLot.iNombreDependance       = local.nbdep
        ttLot.iNombreNiveaux          = local.nbniv
        ttLot.iNombrePiece            = local.nbprf
        ttLot.iNombreChambreService   = local.nbser
        ttLot.cNomOccupant            = local.NmOcc
        ttLot.daDateMiseEnVente       = local.dtmvt
        ttLot.dMontantMiseEnVente     = local.mtmvt
        // ttLot.cDivers1              = local.lbdiv
        // ttLot.cDivers4              = local.lbdiv4
        // ttLot.cDivers5              = local.lbdiv5
        // ttLot.cDivers6              = local.lbdiv6
        ttLot.daDateAchevement        = local.dtAch
        ttLot.daDateFinApplication    = local.dtflo
        ttLot.daDateDebutValidite     = local.dtdeb-validite
        ttLot.daDateFinValidite       = local.dtfin-validite
        ttLot.cCodeUsage              = local.cdUsage
        ttLot.cEUTypeGestion          = local.euGes
        ttLot.cEUTypeContrat          = local.euCtt
        ttLot.cCodeLotCopropriete     = local.cdlot-cop
        ttLot.cListeLotVente          = trim(local.lbdiv2, '&')
        ttLot.dLoyerMandat                 = local.montantFamille[1]
        ttLot.dprovisionChargeMandat       = local.montantFamille[2]
        //ttLot.CdTrxEntretien               = local.CdTrxEntretien
        ttLot.lTravauxEntretien            = (local.CdTrxEntretien = {&oui})
        ttLot.daDateTravauxEntretien       = local.DtTrxEntretien
        //ttLot.CdTrxMiseAuxNormes           = local.CdTrxMiseAuxNormes
        ttLot.lTravauxMiseAuxNormes        = (local.CdTrxMiseAuxNormes = {&oui})
        ttLot.daDateTravauxMiseAuxNormes   = local.DtTrxMiseAuxNormes
        //ttLot.CdTrxRestructuration         = local.CdTrxRestructuration
        ttLot.lTravauxRestructuration      = (local.CdTrxRestructuration = {&oui})
        ttLot.daDateTravauxRestructuration = local.DtTrxRestructuration
        ttLot.cTypeBien                    = {&TYPEBIEN-lot}
        ttLot.cCodeTypeLot                 = local.tplot                                             /* Type de lot (Registre) */
        ttLot.cLibelleTypeLot              = outilTraduction:getLibelleParam("TPLOT", local.tplot)   /* Libellé Type de lot (Registre) */
        ttLot.dtTimestamp                  = datetime(local.dtmsy, local.hemsy)
        ttLot.rRowid                       = rowid(local)
        vcNomCopro = ''
    .
    run OccupLot(
        buffer local,
        output vcNomOccupant,
        output vdaEntreeOccupant,
        output viNumeroBailleur,
        output viNumeroContrat,
        output vcTypeCopro,
        output viNumeroCopro,
        output vdaAchLot,
        output vcTypeOccupant,
        output vcCodeRegroupe
        ).
    if viNumeroBailleur <> 0
    then viNumeroAppartement = truncate(viNumeroBailleur modulo 100000 / 100, 0).  // integer(substring(string(viNumeroBailleur, "9999999999"), 6, 3, 'character')).
    if vcTypeCopro > "" and viNumeroCopro <> 0 then vcNomCopro = outilFormatage:getNomTiers(vcTypeCopro, viNumeroCopro).
    assign
        ttLot.iNumeroBail              = viNumeroBailleur
        ttLot.iNumeroUL                = viNumeroAppartement
        ttLot.cCodeTypeProprietaire    = vcTypeCopro
        ttLot.iNumeroProprietaire      = viNumeroCopro
        ttLot.cNomProprietaire         = vcNomCopro
        ttLot.cLibelleTypeProprietaire = outilTraduction:getLibelleParam("TPOCC", vcTypeOccupant)
        ttLot.daDateAchat              = vdaAchLot
        ttLot.cTypeOccupant            = vcTypeOccupant
    .
    // Loyer mandat : dans acte de propriété du lot
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-acte2propriete}
          and intnt.tpidt = {&TYPEBIEN-lot}
          and intnt.noidt = local.noloc
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
        /* Recherche du notaire */
        for first vbIntnt no-lock
            where vbIntnt.tpcon = ctrat.tpcon
              and vbIntnt.nocon = ctrat.nocon
              and vbIntnt.tpidt = {&TYPEROLE-notaire}:
            assign
                ttLot.iNumeroNotaire = vbIntnt.noidt
                ttLot.cNomNotaire    = outilFormatage:getNomTiers({&TYPEROLE-notaire}, vbIntnt.noidt)
            .
        end.
        assign
            ttLot.cCodeTypeAcquisition = ctrat.tpren
            ttLot.daDateAchat          = if ttLot.daDateAchat = ? then ctrat.dtdeb else ttLot.daDateAchat
            ttLot.daDateVente          = ctrat.dtfin
            ttLot.cLieuActeNotarie     = ctrat.lisig
        .
    end.

end procedure.

procedure updateLienLot:
    /*------------------------------------------------------------------------------
    Purpose:  modification des 'lot' d'un traitement: sig, dev, ord... , selon numero traitement
    Notes: service utilisé par beDemandeDeDevis.cls, beOrdreDeService.cls, beSignalement.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTraitement as character no-undo.
    define input parameter table-handle phttTraitement.
    define input parameter table for ttListeLot.

    define variable vhttBufferTraitement as handle  no-undo.
    define variable vhttQueryTraitement  as handle  no-undo.
    define buffer local for local.
    define buffer dtlot for dtlot.
    define variable viNumeroTraitement as integer no-undo.

    vhttBufferTraitement = phttTraitement:default-buffer-handle.
    create query vhttQueryTraitement.
    vhttQueryTraitement:set-buffers(vhttBufferTraitement).
    vhttQueryTraitement:query-prepare(substitute('for each &1', vhttBufferTraitement:name)).
    vhttQueryTraitement:query-open().

blocTransaction:
    do transaction:
blocRepeat:
        repeat:
            vhttQueryTraitement:get-next().
            if vhttQueryTraitement:query-off-end then leave blocRepeat.

            case pcTypeTraitement:
                when {&TYPEINTERVENTION-signalement}   then viNumeroTraitement = vhttBufferTraitement::iNumeroSignalement.
                when {&TYPEINTERVENTION-demande2devis} then viNumeroTraitement = vhttBufferTraitement::iNumeroDemandeDeDevis.
                when {&TYPEINTERVENTION-ordre2service} then viNumeroTraitement = vhttBufferTraitement::iNumeroOrdreDeService.
            end case.

            for each ttListelot:
                case ttListelot.CRUD:
                    when "C" then for first local no-lock
                        where local.noloc = ttListeLot.iNumeroBien:
                        if not can-find(first dtlot no-lock
                            where dtlot.tptrt = pcTypeTraitement
                              and dtlot.notrt = viNumeroTraitement
                              and dtlot.noloc = local.noloc)
                        then do:
                            create dtlot.
                            assign
                                dtlot.tptrt = pcTypeTraitement
                                dtlot.notrt = viNumeroTraitement
                                dtlot.noloc = ttListeLot.iNumeroBien
                                dtlot.dtcsy = today
                                dtlot.hecsy = mtime
                                dtlot.cdcsy = mtoken:cUser
                                dtlot.dtmsy = dtlot.dtcsy
                                dtlot.hemsy = dtlot.hecsy
                                dtlot.cdmsy = mtoken:cUser
                            .
                        end.
                    end.

                    when "D" then for first local no-lock
                        where local.noloc = ttListeLot.iNumeroBien
                      , first dtlot exclusive-lock
                        where dtlot.tptrt = pcTypeTraitement
                          and dtlot.notrt = viNumeroTraitement
                          and dtlot.noloc = local.noloc:
                        delete DtLot.
                    end.
                end case.
            end.
        end.
   end.

end procedure.

procedure getListeLotsContratImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beLot.cls et lot.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroContrat  as integer   no-undo.
    define input parameter piNumeroImmeuble as integer   no-undo.
    define output parameter table for ttListeLot.

    define buffer intnt for intnt.
    define buffer local for local.
    define buffer cpuni for cpuni.
    define buffer unite for unite.

    empty temp-table ttListeLot.

    {&_proparse_ prolint-nowarn(sortaccess)}
    if piNumeroContrat > 0 and lookup(pcTypeContrat, {&TYPECONTRAT-bail}) > 0
    then for each unite no-lock                                     /* lots du locataire */
        where unite.nomdt = integer(truncate(piNumeroContrat / 100000, 0))             // integer(substring(string(piNumeroContrat, "9999999999"), 1, 5, 'character'))
          and unite.noapp = integer(truncate(piNumeroContrat modulo 100000 / 100, 0))  // integer(substring(string(piNumeroContrat, "9999999999"), 6, 3, 'character'))
          and unite.norol = piNumeroContrat
      , each cpuni no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
      , each local no-lock
        where local.noimm = cpuni.noimm
          and local.nolot = cpuni.nolot
        break by local.noloc:
        if first-of(local.noloc) then crettListeLot(0, local.noloc, "").
    end.
    else if piNumeroContrat > 0 and (pcTypeContrat = {&TYPECONTRAT-titre2copro} or pcTypeContrat = {&TYPECONTRAT-mandat2Gerance})
    then for each intnt no-lock            /* lots du copro ou du mandat de gérance */
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEBIEN-lot}
          and intnt.nbden = 0
      , each local no-lock
        where local.noloc = intnt.noidt:
        crettListeLot(0, local.noloc, "").
    end.
    else if piNumeroImmeuble > 0 /* Tous les lots de l'immeuble */
    then for each local no-lock
        where local.noimm = piNumeroImmeuble:
        crettListeLot(0, local.noloc, "").
    end.

end procedure.

procedure getLotsContrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : crée la liste des lots d'un contrat selon son type
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define buffer ctrat for ctrat.
    define buffer intnt for intnt.
    define buffer local for local.

    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat
      , each intnt no-lock
        where intnt.tpcon = ctrat.tpcon
          and intnt.nocon = ctrat.nocon
          and intnt.tpidt = {&TYPEBIEN-lot}
          and intnt.nbden = 0
      , each local no-lock
        where local.noloc = intnt.noidt:
        crettListeLot(0, local.noloc, pcTypeContrat).
    end.
end procedure.

procedure getLotsMandat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Appelé par service beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64   no-undo.
    define output parameter table for ttListeLot.

    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

    empty temp-table ttListeLot.
    find first ctrat no-lock
        where ctrat.nocon = piNumeroMandat
          and ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic} no-error.
    if available ctrat
    then for first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
          and intnt.nocon = ctrat.nocon:
        run getListeLotsContratImmeuble(ctrat.tpcon, ctrat.nocon, intnt.noidt, output table ttListeLot by-reference).
    end.
    else for first ctrat no-lock
        where ctrat.nocon = piNumeroMandat
          and ctrat.tpcon = {&TYPECONTRAT-mandat2gerance}:
        run getLotsContrat(ctrat.tpcon, ctrat.nocon).
    end.

end procedure.

procedure getLotUnite:
    /*------------------------------------------------------------------------------
    Purpose: Renvoie l'adresse d'une unité de location
    Notes  : service utilisé par beLotCommercialisation.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroUnite   as integer no-undo.
    define input  parameter piNumeroContrat as integer no-undo.
    define output parameter table for ttLotCommercialisation.

    define buffer unite for unite.
    define buffer cpuni for cpuni.
    define buffer local for local.

    for first unite no-lock
        where unite.noapp = piNumeroUnite
          and unite.nomdt = piNumeroContrat
      , each cpuni no-lock
        where cpuni.nomdt = Unite.nomdt
          and cpuni.noapp = Unite.noapp
          and cpuni.nocmp = Unite.nocmp
      , each local no-lock
        where local.noimm = cpuni.noimm
          and local.nolot = cpuni.nolot:
        create ttLotCommercialisation.
        assign
            ttLotCommercialisation.CRUD                    = 'R'
            ttLotCommercialisation.iNumeroLot              = local.nolot
            ttLotCommercialisation.iNumeroImmeuble         = local.noimm
            ttLotCommercialisation.cCodeBatiment           = trim(local.cdbat)
            ttLotCommercialisation.cCodeEscalier           = trim(local.cdesc)
            ttLotCommercialisation.cCodeEtage              = trim(local.cdeta)
            ttLotCommercialisation.cCodePorte              = substring(trim(local.cdpte), 1, 16, "CHARACTER")
            ttLotCommercialisation.cTerraseLoggiaBalcon    = trim(local.cdtlb)
            ttLotCommercialisation.cUsage                  = local.cdUsage
            ttLotCommercialisation.cEtiquetteClimat        = local.etqclimat
            ttLotCommercialisation.iValeurEtiquetteClimat  = local.valetqclimat   /* npo #7589 */
            ttLotCommercialisation.cEtiquetteEnergie       = local.etqenergie
            ttLotCommercialisation.iValeurEtiquetteEnergie = local.valetqenergie  /* npo #7589 */
            ttLotCommercialisation.lAirConditionne         = local.fgair
            ttLotCommercialisation.lChauffageIndividuel    = local.fgcha
            ttLotCommercialisation.lEauFroideIndividuel    = local.fgfra
            ttLotCommercialisation.lMeuble                 = local.fgmbl
            ttLotCommercialisation.lWCIndependant          = local.fgwci
            ttLotCommercialisation.cLibelleLot             = local.lbdiv
            ttLotCommercialisation.cCodeModeChauffage      = local.mdcha
            ttLotCommercialisation.cLibelleModeChauffage   = outilTraduction:getLibelleParam("MDCHA", local.mdcha)
            ttLotCommercialisation.cCodeTypeChauffage      = local.tpcha
            ttLotCommercialisation.cLibelleTypeChauffage   = outilTraduction:getLibelleParam("TPCHA", local.tpcha)
            ttLotCommercialisation.iNombreDependances      = local.nbdep
            ttLotCommercialisation.iNombreNiveaux          = local.nbniv
            ttLotCommercialisation.iNombrePieces           = local.nbpie
            ttLotCommercialisation.iNombrePiecesProf       = local.nbprf
            ttLotCommercialisation.iNombreChambresService  = local.nbser
            ttLotCommercialisation.cCodeNature             = local.ntlot
            ttLotCommercialisation.cLibelleNature          = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
            ttLotCommercialisation.dSurfaceReelle          = surfaceM2(local.usree, local.sfree)
            ttLotCommercialisation.dSurfacePonderee        = surfaceM2(local.uspde, local.sfpde)
            ttLotCommercialisation.dSurfaceAnnexes         = surfaceM2(local.usaxe, local.sfaxe)
            ttLotCommercialisation.dSurfaceBureau          = surfaceM2(local.usbur, local.sfbur)
            ttLotCommercialisation.dSurfaceNonUtilisee     = surfaceM2(local.usnon, local.sfnon)
            ttLotCommercialisation.dSurfaceArchives        = surfaceM2(local.usarc, local.sfarc)
            ttLotCommercialisation.dSurfaceCommercial      = surfaceM2(local.uscom, local.sfcom)
            ttLotCommercialisation.dSurfaceHorsOeuvreNet   = surfaceM2(local.ushon, local.sfhon)
            ttLotCommercialisation.dSurfaceLocauxStockage  = surfaceM2(local.usstk, local.sfstk)
            ttLotCommercialisation.dSurfaceTerrasse        = surfaceM2(local.uster, local.sfter)
            ttLotCommercialisation.dSurfaceCorrigee        = surfaceM2(local.uscor, local.sfcor)
            /* npo surface commerciale utile + type de lot ??? */
            ttLotCommercialisation.dtTimestamp             = datetime(local.dtmsy, local.hemsy)
        .
    end.
end procedure.

procedure getContratLot:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLoc as int64  no-undo.
    define output parameter table for ttContratLot.
    define output parameter table for ttRoleContrat.
    define output parameter table for ttServiceGestion.
    define output parameter table for ttGestionnaire.

    define variable vdaDebutContrat as date      no-undo.
    define variable vdaFinContrat   as date      no-undo.
    define variable viNumeroService as integer   no-undo.
    define buffer unite   for unite.
    define buffer cpuni   for cpuni.
    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer ctrat   for ctrat.
    define buffer vbCtrat for ctrat.
    define buffer tache   for tache.
    define buffer local   for local.

    find first local no-lock where local.noloc = piNumeroLoc no-error.
    if not available local then return.

    /*--> Titre de Copropriété */
    {&_proparse_ prolint-nowarn(sortaccess)}
    for each vbIntnt no-lock
       where vbIntnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
         and vbIntnt.tpidt = {&TYPEBIEN-immeuble}
         and vbIntnt.noidt = local.noimm
      , each intnt  no-lock
       where intnt.tpcon = {&TYPECONTRAT-titre2copro}
         and intnt.nocon >= vbIntnt.nocon * 100000 + 1      // integer(string(vbIntnt.nocon, "99999") + "00001")
         and intnt.nocon <= vbIntnt.nocon * 100000 + 99999  // integer(string(vbIntnt.nocon, "99999") + "99999")
         and intnt.tpidt = {&TYPEBIEN-Lot}
         and intnt.noidt = local.noloc
      , first vbCtrat   no-lock
        where vbCtrat.tpcon = vbIntnt.tpcon
          and vbCtrat.nocon = vbIntnt.nocon
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon
           by intnt.nbnum:
        assign
            vdaDebutContrat = cToDate(intnt.nbnum, ctrat.tpcon, ctrat.nocon)
            vdaFinContrat   = cToDate(intnt.nbden, ctrat.tpcon, ctrat.nocon)
        .
        if vbCtrat.dtree <> ? and vdaFinContrat = ? then vdaFinContrat = vbCtrat.dtree.

        find first ttContratLot
             where ttContratLot.cTypeContrat   = ctrat.tpcon
               and ttContratLot.iNumeroContrat = ctrat.nocon no-error.
        if not available ttContratLot
        then do:
            create ttContratLot.
            assign
                ttContratLot.CRUD            = "R"
                ttContratLot.cTypeContrat    = ctrat.tpcon
                ttContratLot.iNumeroContrat  = ctrat.nocon
                ttContratLot.cLibelleContrat = "TI"
                ttContratLot.iNumeroImmeuble = local.noimm
                ttContratLot.iNumeroLot      = local.nolot
                ttContratLot.daDateFin       = ?
            /*
                ttContratLot.TpRol = ctrat.tprol
                ttContratLot.NoRol = string(Ctrat.norol, ">>>>>>>>>9")
                ttContratLot.LbRol = ctrat.lbnom
            */
                ttContratLot.cNatureContrat  = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
                ttCOntratLot.dtTimestamp     = datetime(ctrat.dtmsy, ctrat.hemsy)
            .
            create ttRoleContrat.
            assign
                ttRoleContrat.CRUD             = 'R'
                ttRoleContrat.cTypeContrat     = ctrat.tpcon
                ttRoleContrat.iNumeroContrat   = ctrat.nocon
                ttRoleContrat.iNumeroRole      = ctrat.norol
                ttRoleContrat.cCodeTypeRole    = ctrat.tprol
                ttRoleContrat.cLibelleTypeRole = ctrat.lbnom
                ttRoleContrat.dtTimestamp      = datetime(ctrat.dtmsy, ctrat.hemsy)
            .
        end.
        assign
            ttContratLot.daDateDebut       = (if vdaDebutContrat <> ? then vdaDebutContrat else ctrat.dtdeb)
            ttContratLot.daDateResiliation = vdaFinContrat
            ttContratLot.lPresent          = (vdaFinContrat = ? or vdaFinContrat > today)
        .
    end.

     /* Bail */
     for each intnt  no-lock
        where intnt.tpcon = {&TYPECONTRAT-bail}
          and intnt.tpidt = {&TYPEBIEN-Lot}
          and intnt.noidt = local.noloc
      , first vbCtrat no-lock
        where vbCtrat.tpcon = intnt.tpcon
          and vbCtrat.nocon = intnt.nocon
      , each cpuni no-lock
       where cpuni.nomdt = vbCtrat.nocon
         and cpuni.noimm = local.noimm
         and cpuni.nolot = local.nolot
      , first unite no-lock
        where unite.nomdt = cpuni.nomdt
          and unite.noapp = cpuni.noapp
          and unite.nocmp = cpuni.nocmp
          and unite.noact = 0
       , each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-bail}
          and ctrat.nocon >= vbCtrat.nocon * 100000 + unite.noapp * 100 + 01  // integer(string(vbCtrat.nocon, "99999") + string(unite.noapp , "999") + "01")
          and ctrat.nocon <= vbCtrat.nocon * 100000 + unite.noapp * 100 + 99: // integer(string(vbCtrat.nocon, "99999") + string(unite.noapp , "999") + "99"):
        find last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-renouvellement} no-error.
        vdaFinContrat = if available tache and Tache.tpfin <> "50" then tache.dtfin else ctrat.dtfin.
        create ttContratLot.
        assign
            ttContratLot.CRUD              = "R"
            ttContratLot.cTypeContrat      = ctrat.tpcon
            ttContratLot.iNumeroContrat    = ctrat.nocon
            ttContratLot.iNumeroImmeuble   = local.noimm
            ttContratLot.iNumeroLot        = local.nolot
            ttContratLot.daDateDebut       = ctrat.dtdeb
            ttContratLot.daDateFin         = vdaFinContrat
            ttContratLot.daDateResiliation = ctrat.dtree
        /*
            ttContratLot.TpRol = ctrat.tprol
            ttContratLot.NoRol = string(Ctrat.norol,">>>>>>>>>9")
            ttContratLot.LbRol = ctrat.lbnom
        */
            ttContratLot.cNatureContrat    = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
            ttContratLot.lPresent          = (ctrat.dtree = ? or ctrat.dtree > today)
            ttContratLot.cLibelleContrat   = "BA"
            ttCOntratLot.dtTimestamp       = datetime(ctrat.dtmsy, ctrat.hemsy)
        .
        create ttRoleContrat.
        assign
            ttRoleContrat.CRUD             = 'R'
            ttRoleContrat.cTypeContrat     = ctrat.tpcon
            ttRoleContrat.iNumeroContrat   = ctrat.nocon
            ttRoleContrat.iNumeroRole      = ctrat.norol
            ttRoleContrat.cCodeTypeRole    = ctrat.tprol
            ttRoleContrat.cLibelleTypeRole = ctrat.lbnom
            ttRoleContrat.dtTimestamp      = datetime(ctrat.dtmsy, ctrat.hemsy)
        .
    end.

     /* Mandat de gérance */
     for each intnt  no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.tpidt = {&TYPEBIEN-lot}
          and intnt.noidt = local.noloc
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
        find last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-renouvellement} no-error.
        vdaFinContrat = if available tache and Tache.tpfin <> "50" then tache.dtfin else ctrat.dtfin.

        find first tache no-lock           // Information Bail proportionnel si nécessaire
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-bailProportionnel} no-error.
        create ttContratLot.
        assign
            ttContratLot.cTypeContrat      = ctrat.tpcon
            ttContratLot.iNumeroContrat    = ctrat.nocon
            ttContratLot.daDateDebut       = ctrat.dtdeb
            ttContratLot.daDateFin         = vdaFinContrat
            ttContratLot.daDateResiliation = ctrat.dtree
        /*
            ttContratLot.TpRol = ctrat.tprol
            ttContratLot.NoRol = string(Ctrat.norol,">>>>>>>>>9")
            ttContratLot.LbRol = ctrat.lbnom
        */
            ttContratLot.cNatureContrat    = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon) + (if available tache then " (BP)" else "")
            ttContratLot.lPresent          = (ctrat.dtree = ? or ctrat.dtree > today)
        .
        create ttRoleContrat.
        assign
            ttRoleContrat.CRUD             = 'R'
            ttRoleContrat.cTypeContrat     = ctrat.tpcon
            ttRoleContrat.iNumeroContrat   = ctrat.nocon
            ttRoleContrat.iNumeroRole      = ctrat.norol
            ttRoleContrat.cCodeTypeRole    = ctrat.tprol
            ttRoleContrat.cLibelleTypeRole = ctrat.lbnom
            ttRoleContrat.dtTimestamp      = datetime(ctrat.dtmsy, ctrat.hemsy)
        .
        if ttContratLot.cTypeContrat = {&TYPECONTRAT-mandat2Gerance} then ttContratLot.cLibelleContrat = "MG".
    end.

    /* Mise à jour gestionnaire */
    for each ttContratLot:
        viNumeroService = DonneNumeroServiceContrat(ttContratLot.cTypeContrat, ttContratLot.iNumeroContrat).
        if viNumeroService <> 0
        then for first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-serviceGestion}
              and ctrat.nocon = viNumeroService:
            create ttServiceGestion.
            assign
                ttServiceGestion.CRUD            = 'R'
                ttServiceGestion.iNumeroImmeuble = local.noimm
                ttServiceGestion.iNumeroContrat  = ttContratLot.iNumeroContrat
                ttServiceGestion.cTypeContrat    = ttContratLot.cTypeContrat
                ttServiceGestion.cNumeroService  = string(viNumeroService, "99999")
                ttServiceGestion.cNomService     = ctrat.noree
                ttServiceGestion.dtTimestamp     = datetime(ctrat.dtmsy, ctrat.hemsy)
            .
            create ttGestionnaire.
            assign
                ttGestionnaire.CRUD                = 'R'
                ttGestionnaire.iNumeroImmeuble     = local.noimm
                ttGestionnaire.iNumeroContrat      = ttContratLot.iNumeroContrat
                ttGestionnaire.cTypeContrat        = ttContratLot.cTypeContrat
                ttGestionnaire.cNumeroGestionnaire = string(ctrat.nocon, "99999")
                ttGestionnaire.cNomGestionnaire    = outilFormatage:GetNomTiers(ctrat.tprol, ctrat.norol)
                ttGestionnaire.dtTimestamp         = datetime(ctrat.dtmsy, ctrat.hemsy)
            .
        end.
    end.

end procedure.



procedure setLot:
    /*------------------------------------------------------------------------------
    Purpose: validation lot
    Notes  : service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttLot.

    define variable vhProc    as handle no-undo.
    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer ctrat   for ctrat.

    for each ttLot
       where ttLot.CRUD = "C" or ttLot.CRUD = "U":
        /* MAJ des informations de loyer */
        assign
            ttLot.montantFamille[1] = ttLot.dLoyerMandat
            ttLot.montantFamille[2] = ttLot.dProvisionChargeMandat
            /* MAJ flags et dates TRAVAUX*/
            ttLot.CdTrxEntretien               = if ttLot.lTravauxEntretien       then {&oui} else ""
            ttLot.CdTrxMiseAuxNormes           = if ttLot.lTravauxMiseAuxNormes   then {&oui} else ""
            ttLot.CdTrxRestructuration         = if ttLot.lTravauxRestructuration then {&oui} else ""
            ttLot.daDateTravauxEntretien       = if ttLot.lTravauxEntretien       then ttLot.daDateTravauxEntretien       else ?
            ttLot.daDateTravauxMiseAuxNormes   = if ttLot.lTravauxMiseAuxNormes   then ttLot.daDateTravauxMiseAuxNormes   else ?
            ttLot.daDateTravauxRestructuration = if ttLot.lTravauxRestructuration then ttLot.daDateTravauxRestructuration else ?
        .
        /* Contrat acte de propriete */
        for first intnt no-lock
            where intnt.tpcon = {&TYPECONTRAT-acte2propriete}
              and intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.noidt = ttLot.iNumeroBien
          , first ctrat exclusive-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon:

            /* Recherche du notaire et création si inexistant */
            {&_proparse_ prolint-nowarn(nowait)}
            find first vbIntnt exclusive-lock
                 where vbIntnt.tpcon = ctrat.tpcon
                   and vbIntnt.nocon = ctrat.nocon
                   and vbIntnt.tpidt = {&TYPEROLE-notaire} no-error.
            if not available vbIntnt
            then do:
                create vbintnt.
                assign
                    vbintnt.tpcon = ctrat.tpcon
                    vbintnt.nocon = ctrat.nocon
                    vbintnt.tpidt = {&TYPEROLE-notaire}
                .
            end.
            assign
                vbIntnt.noidt = ttLot.iNumeroNotaire
                ctrat.tpren = ttLot.cCodeTypeAcquisition
                ctrat.dtdeb = ttLot.daDateAchat  // TODO : BUG EXISTANT DANS MAGI, dans le get dateAchat vient de nbnum, dans le set on positionne dtdeb
                ctrat.dtfin = ttLot.daDateVente
                ctrat.lisig = ttLot.cLieuActeNotarie
            .
        end.
    end.
    run immeubleEtLot/lot_crud.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
 
    run setLocal in vhProc(table ttLot).
    run destroy in vhProc.
end procedure.

procedure setAdresseLot:
    /*------------------------------------------------------------------------------
    Purpose: mise a jour de l 'adresse immeuble
    Notes  : 
    TODO : Identique à setAdresseImmeuble dans immeuble.p ?
    ------------------------------------------------------------------------------*/
    define input  parameter table for ttAdresse.
    define input  parameter table for ttCoordonnee.
    define input  parameter table for ttMoyenCommunication.

    define variable viLien    as int64  no-undo.
    define variable viAdresse as int64  no-undo.
    define variable vhProc    as handle no-undo.
    define buffer adres for adres.
    define buffer ladrs for ladrs.

    run adresse/moyenCommunication.p persistent set vhProc.
    run getTokenInstance in vhProc(mToken:JSessionId).
    // Adresse
    for first ttAdresse:
        {&_proparse_ prolint-nowarn(nowait)}
        find first ladrs exclusive-lock
             where ladrs.nolie = ttAdresse.iNumeroLien no-error.
        if not available ladrs then do:
            {&_proparse_ prolint-nowarn(wholeindex)}
            find last adres no-lock no-error.
            {&_proparse_ prolint-nowarn(wholeindex)}
            find last ladrs no-lock no-error.
            assign
                viAdresse = if available adres then adres.noadr + 1 else 1
                viLien    = if available ladrs then ladrs.nolie + 1 else 1
            .
            create adres.
            assign
                adres.noadr = viAdresse
                adres.dtcsy = today
                adres.hecsy = mtime
                adres.cdcsy = mtoken:cUser
                adres.dtmsy = adres.dtcsy
                adres.hemsy = adres.hecsy
                adres.cdmsy = adres.cdcsy
            .
            create ladrs.
            assign
                ladrs.noadr = viAdresse
                ladrs.nolie = viLien
                ladrs.tpidt = {&TYPEBIEN-immeuble}
                ladrs.noidt = ttAdresse.iNumeroIdentifiant
                ladrs.dtcsy = today
                ladrs.hecsy = mtime
                ladrs.cdcsy = mToken:cUser
                ladrs.dtmsy = ladrs.dtcsy
                ladrs.hemsy = ladrs.hecsy
                ladrs.cdmsy = ladrs.cdcsy
            no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo, return.
            end.
        end.
        else do:
            {&_proparse_ prolint-nowarn(nowait)}
            find first adres exclusive-lock
                where adres.noadr = ladrs.noadr no-error.
            if not available adres then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo, return.
            end.
            assign
                ladrs.dtmsy = today
                ladrs.hemsy = mtime
                ladrs.cdmsy = mToken:cUser
                adres.dtmsy = ladrs.dtmsy
                adres.hemsy = ladrs.hemsy
                adres.cdmsy = ladrs.cdmsy
            no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                message "error1 : " error-status:get-message(1) "error2: " error-status:get-message(2).
                undo, return.
            end.
        end.
        assign
            ladrs.tpadr = ttAdresse.cCodeTypeAdresse
            ladrs.tpfrt = ttAdresse.cCodeFormat
            ladrs.novoi = ttAdresse.cNumeroVoie
            ladrs.cdadr = ttAdresse.cCodeNumeroBis
            adres.cpad2 = ttAdresse.cIdentification   // NPO new format
            adres.lbvoi = ttAdresse.cNomVoie          // NPO new format
            adres.ntvoi = ttAdresse.cCodeNatureVoie
            adres.cpvoi = ttAdresse.cComplementVoie
            adres.cdpos = ttAdresse.cCodePostal
            adres.lbvil = ttAdresse.cVille
            adres.cdpay = ttAdresse.cCodePays
            adres.cdins = ttAdresse.cCodeINSEE
        .
        run setMoyenCommunicationImmeuble in vhProc (ladrs.tpidt, ladrs.noidt).
    end.
    run destroy in vhProc.

end procedure.

function testNumeroLot returns logical(piNumeroImmeuble as integer, piNumeroLot as integer):
    /*------------------------------------------------------------------------------
    Purpose: Test si un numéro de lot est diponible
    Notes  : Appelé depuis beLot.cls
    ------------------------------------------------------------------------------*/
    if piNumeroImmeuble = 0
    then do:
        mError:createError({&error}, 102282).
        return false.
    end.

    if can-find(first local no-lock
                where local.noimm = piNumeroImmeuble
                  and local.nolot = piNumeroLot)
    then do:
        mError:createError({&error}, 106157).
        return false.
    end.

    return true.
end function.



procedure setUniteLocationLot:
    /* -----------------------------------------------------------------------
    Purpose: Procedure pour la mise à jour des unités de locations
    Notes  : service utilisé par beLot.cls
    ----------------------------------------------------------------------- */
    define input  parameter table for ttLot.
    define output parameter table for ttCpuni.

    define variable vdeSfLotSav as decimal no-undo.
    define buffer local for local.
    define buffer cpuni for cpuni.
    define buffer unite for unite.

    for first ttLot
      , first local no-lock 
        where rowid(local) = ttLot.rRowid:

        if local.fgdiv <> ttLot.lIsDivisible then do: 
            for each cpuni no-lock
               where cpuni.noimm = ttLot.iNumeroImmeuble
                 and cpuni.nolot = ttLot.iNumeroLot
             , first unite no-lock
               where unite.nomdt = cpuni.nomdt
                 and unite.noapp = cpuni.noapp
                 and unite.noact = 0:
                    
                create ttCpUni.
                assign 
                    ttCpuni.CRUD  = "U"
                    ttCpuni.noimm = cpuni.noimm
                    ttCpuni.nolot = cpuni.nolot
                    ttCpuni.noapp = cpuni.noapp
                    ttCpuni.noord = cpuni.noord
                    ttCpuni.sflot = ttLot.sfRee
                .
            end.
        end.
    end.

    /*--> Modification de la surface */
    for first ttLot
      , first local no-lock 
        where rowid(local) = ttLot.rRowid:
        if local.sfree <> ttLot.sfRee and local.fgdiv and ttLot.lIsDivisible 
        then do: 
            find first cpuni no-lock
                 where cpuni.noimm = ttLot.iNumeroImmeuble
                   and cpuni.nolot = ttLot.iNumeroLot
                   and cpuni.noapp = 998 no-error.
            if available cpuni then do:
                if cpuni.sflot + ttLot.sfRee - local.sfree > 0 then do:
                    /*--> Mise à jour du 998 avec la nouvelle surface */
                    create ttCpUni.
                    assign 
                        ttCpuni.CRUD  = "U"
                        ttCpuni.noimm = cpuni.noimm
                        ttCpuni.nolot = cpuni.nolot
                        ttCpuni.noapp = cpuni.noapp
                        ttCpuni.noord = cpuni.noord
                        ttCpuni.nomdt = cpuni.nomdt
                        ttCpuni.nocmp = cpuni.nocmp
                        ttCpuni.sflot = cpuni.sflot + ttLot.sfRee - local.sfree
                    .
                end.
                else do:
                    /*--> Si la nouvelle surface est egale à 0 on supprime le 998 */
                    create ttCpUni.
                    assign 
                        ttCpuni.CRUD  = "D"
                        ttCpuni.noimm = cpuni.noimm
                        ttCpuni.nolot = cpuni.nolot
                        ttCpuni.noapp = cpuni.noapp
                        ttCpuni.noord = cpuni.noord
                        ttCpuni.nomdt = cpuni.nomdt
                        ttCpuni.nocmp = cpuni.nocmp
                    .
                end.
            end.
            else do:
                /*--> Si il n'existe plus de 998 on regarde si la nouvelle surface depasse la somme des surfaces des unites */
                vdeSfLotSav = 0.
                for each cpuni no-lock
                   where cpuni.noimm = ttLot.iNumeroImmeuble
                     and cpuni.nolot = ttLot.iNumeroLot
                     and cpuni.noapp <> 998
                 ,  each unite no-lock
                   where unite.nomdt = cpuni.nomdt
                     and unite.noapp = cpuni.noapp
                     and unite.nocmp = cpuni.nocmp
                     and unite.noact = 0:
                     vdeSfLotSav = vdeSfLotSav + cpuni.sflot.
                end.
                /*--> Si la nouvelle surface depasse alors on crée un 998 avec le surplus */
                if vdeSfLotSav < ttLot.sfRee then do:
                    create ttCpUni.
                    assign 
                        ttCpuni.CRUD  = "C"
                        ttCpuni.noimm = cpuni.noimm
                        ttCpuni.nolot = cpuni.nolot
                        ttCpuni.noapp = 998
                        ttCpuni.noord = cpuni.noord
                        ttCpuni.nomdt = cpuni.nomdt
                        ttCpuni.nocmp = 010
                    .
                end.
            end.
        end.
    end.
end procedure.

procedure getListeLotsImmeubleSimplifiee:
    /*------------------------------------------------------------------------------
    Purpose: charge la liste des lots simplifiee d'un immeuble selon numero immeuble
             Pour un immeuble, on ne limite pas le nombre de lots remontés (iMaxLigne)
    Notes: service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttLot.

    define buffer local for local.

    for each local no-lock
       where local.noimm = piNumeroImmeuble:
        create ttLot.
        assign
            ttLot.iNumeroLot     = local.nolot            
            ttLot.cLibelleNature = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
        .
    end.

end procedure.

procedure getListeLotContratSimplifie:
    /*------------------------------------------------------------------------------
    Purpose: charge la liste des lots simplifiee d'un contrats (voir si test sur intnt.nbden = 0 doit etre gere en parametre) 
             a partir de adb/objet/frmlbi20.p
    Notes: service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.    
    define output parameter table for ttLot.

    define buffer intnt for intnt.
    define buffer local for local.

    for each intnt no-lock
       where intnt.tpcon = pcTypeContrat
         and intnt.nocon = piNumeroContrat
         and intnt.tpidt = {&TYPEBIEN-lot}
         and intnt.nbden = 0     /* Pas de date de vente */
    , first local no-lock
        where local.noloc = intnt.noidt:
        create ttLot.
        assign
            ttLot.iNumeroLot     = local.nolot            
            ttLot.cLibelleNature = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
            ttLot.cCodeNature    = local.ntlot
        .
    end.

end procedure.

procedure getNotesLot:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:  service pour beImmeuble.cls ou beLot.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroLocal as int64 no-undo.
    define output parameter table for ttNotes.

    define variable vhproc as handle no-undo.
    define buffer local for local.

    empty temp-table ttNotes.
    run note/notes_CRUD.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    for first local no-lock
        where local.noloc = piNumeroLocal:
        run getNotes in vhProc(local.noblc, input-output table ttNotes).
    end.
    run destroy in vhproc.
    for each ttNotes: ttNotes.iNumeroIdentifiant = piNumeroLocal. end.

end procedure.
