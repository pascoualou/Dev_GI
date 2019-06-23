/*------------------------------------------------------------------------
    File        : lot_crud.p
    Purpose     : 
    Syntax      :
    Description : 
    Author(s)   : 
    Created     : Thu Nov 02 10:34:45 CET 2017
    Notes       :
  ----------------------------------------------------------------------*/
  
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/error.i}
{immeubleEtLot/include/lot.i}
{preprocesseur/type2bien.i}

function crudLocal returns logical:
    /*------------------------------------------------------------------------------
    Purpose: CRUD
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteLocal.
    run createLocal.
    run updateLocal.
    mError:getErrors(output table ttError).
    return not can-find(first ttError where ttError.iType >= {&error}).

end function.

procedure setLocal:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (appel depuis les differents pgms de maintenance tache)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttLot.
    crudLocal().

end procedure.


function getNextLocal returns integer private():
    /* -----------------------------------------------------------------------
    Purpose: Fonction pour récupérer le prochain numéro de local
    Notes  :
    ------------------------------------------------------------------------*/
    define variable viLocalSuivant as integer no-undo.

    // Utilisation de la sequence sur le local
    viLocalSuivant = next-value (sq_NoLoc01).
    // ON ATTEIND LA BORNE MAXIMALE
    if viLocalSuivant = ? then mError:createError({&error}, 1).
    return viLocalSuivant.

end function.

procedure createLocal:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer local for local.
    define buffer ttLot for ttLot.

bloc:
    do transaction:
        for each ttLot where ttLot.CRUD = "C" on error undo, leave:
            create local.
            assign local.noloc = getNextLocal() no-error.
            if error-status:error then do:
                mError:createError({&error},  error-status:get-message(1)).
                undo bloc, leave bloc.
            end.
            if not outils:copyValidLabeledField(buffer local:handle, buffer ttLot:handle, 'C', mtoken:cUser)
            then undo bloc, leave bloc.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value

end procedure.

procedure readLocal:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service?
    TODO   : pas utilisé. A supprimer !?
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroLocal as integer no-undo.
    define output parameter table for ttLot.

    define buffer local for local.
    define buffer imble for imble.

    find first local no-lock where local.noloc = piNumeroLocal no-error.
    if not available local
    then mError:createError({&error}, 211653, 'local: ' + string(piNumeroLocal)).
    else do:
        find first imble no-lock where imble.noimm = local.noimm no-error.
        if not available imble
        then mError:createError({&error}, 211653, 'immeuble: ' + string(imble.noimm)).
        create ttLot.
        assign
            ttLot.CRUD                         = 'R'
            ttLot.iNumeroBien                  = local.noLoc                            /* N° local                     */
            ttLot.iNumeroImmeuble              = local.noimm                            /* N° d'immeuble                */
            ttLot.cNomImmeuble                 = imble.lbnom when available imble       /* Nom d'immeuble               */
            ttLot.iNumeroLot                   = local.nolot                            /* N° de lot                    */
            ttLot.cDesignation                 = local.lbgrp                            /* Designation                  */
            ttLot.iNumeroBlocNote              = local.noblc                            /* N° de bloc notes             */
            ttLot.cEtiquetteClimat             = local.etqclimat                        /* Etiquette climat             */
            ttLot.cEtiquetteEnergie            = local.etqenergie                       /* Etiquette energie            */
            ttLot.iValeurEtiquetteClimat       = local.valetqclimat                     /* Valeur Etiquette climat      */
            ttLot.iValeurEtiquetteEnergie      = local.valetqenergie                    /* Valeur Etiquette energie     */
            ttLot.cCodeBatiment                = local.cdbat                            /* Code batiment                */
            ttLot.cCodeEntree                  = local.lbdiv                            /* Code entrée                  */
            ttLot.cCodePorte                   = local.cdpte                            /* Code porte                   */
            ttLot.cCodeEscalier                = local.cdesc                            /* Code escalier                */
            ttLot.cCodeEtage                   = local.cdeta                            /* Code etage                   */
            ttLot.cCodeNature                  = local.ntlot                            /* Nature du lot                */
            ttLot.iNombreChambreService        = local.nbser                            /* Nombre Chambres de service   */
            ttLot.iNombreDependance            = local.nbdep                            /* Nombre de dépendance         */
            ttLot.iNombreNiveaux               = local.nbniv                            /* Nombre de niveaux            */
            ttLot.iNombrePiece                 = local.nbpie                            /* Nombre de piece              */
            ttLot.cCodeModeChauffage           = local.cdeta                            /* Code mode de chauffage       */
            ttLot.cCodeTypeChauffage           = local.tpcha                            /* Type de chauffage            */
            ttLot.lIsMeuble                    = local.fgmbl                            /* Meublé ?                     */
            ttLot.lIsDivisible                 = local.fgdiv                            /* Divisible ?                  */
            ttLot.lHasWCIndependant            = local.fgwci                            /* WC indépendant ?             */
            ttLot.lHasAirConditionne           = local.fgair                            /* Air conditionné              */
            ttLot.cCodeOrientation             = local.orien                            /* Code orientation             */
            ttLot.cCodeTerrasse                = local.cdtlb                            /* Code terrasse                */
            ttLot.cNomOccupant                 = local.NmOcc                            /* Nom du locataire             */
            ttLot.daDateMiseEnVente            = local.dtmvt                            /* Date de mise en vente        */
            ttLot.dMontantMiseEnVente          = local.mtmvt                            /* Montant de mise en vente     */
            // ttLot.cDivers1                     = local.lbdiv                            /* Libelle divers 1             */
            ttLot.cTypeOccupant                = local.lbdiv3                           /* Type d'occupant              */
            ttLot.cCodeLotCopropriete          = local.cdlot-cop                        /* Code lot copropriete         */
            // ttLot.cDivers4                     = local.lbdiv4                           /* Libelle divers 4             */
            // ttLot.cDivers5                     = local.lbdiv5                           /* Libelle divers 5             */
            // ttLot.cDivers6                     = local.lbdiv6                           /* Libelle divers 6             */
            ttLot.daDateAchevement             = local.dtAch                            /* Date d'achevement            */
            ttLot.daDateFinApplication         = local.dtflo                            /* Date de fin d'application    */
            ttLot.daDateDebutValidite          = local.dtdeb-validite                   /* Date de début de validité    */
            ttLot.daDateFinValidite            = local.dtfin-validite                   /* Date de fin de validité      */
            ttLot.cCodeUsage                   = local.cdUsage                          /* Code usage                   */
            ttLot.cEUTypeGestion               = local.euGes                            /* Type de gestion              */
            ttLot.cEUTypeContrat               = local.euCtt                            /* Type de contrat              */
            ttLot.cListeLotVente               = entry(1, local.lbdiv2, '&')            /* Liste lot vente              */
            ttLot.dLoyerMandat                 = local.montantFamille[1]                /* Montant du loyer             */
            ttLot.dprovisionChargeMandat       = local.montantFamille[2]                /* Provision charge             */
            ttLot.CdTrxEntretien               = local.CdTrxEntretien                   /* Travaux d'entretien ?        */
            ttLot.lTravauxEntretien            = (local.CdTrxEntretien = {&oui})        /* Travaux d'entretien ?        */
            ttLot.daDateTravauxEntretien       = local.DtTrxEntretien                   /* Date travaux d'entretien     */
            ttLot.CdTrxMiseAuxNormes           = local.CdTrxMiseAuxNormes               /* Travaux de mise aux normes ? */
            ttLot.lTravauxMiseAuxNormes        = (local.CdTrxMiseAuxNormes = {&oui})    /* Travaux de mise aux normes ? */
            ttLot.daDateTravauxMiseAuxNormes   = local.DtTrxMiseAuxNormes               /* Date de mise aux normes      */
            ttLot.CdTrxRestructuration         = local.CdTrxRestructuration             /* Travaux de restructuration ? */
            ttLot.lTravauxRestructuration      = (local.CdTrxRestructuration = {&oui})  /* Travaux de restructuration ? */
            ttLot.daDateTravauxRestructuration = local.DtTrxRestructuration             /* Date de restructuration      */
            ttLot.cTypeBien                    = {&TYPEBIEN-lot}                        /* Type de bien                 */
            ttLot.dtTimestamp                  = datetime(local.dtmsy, local.hemsy)     /* timestamp                    */
            ttLot.rRowid                       = rowid(local)                           /* rowid                        */
        .
    end.
end procedure.

procedure updateLocal:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : phtt = ttLot
    ------------------------------------------------------------------------------*/
    define buffer local for local.

bloc:
    do transaction:
        for each ttLot where ttLot.CRUD = "U":
            find first local exclusive-lock
                 where local.noloc  = ttLot.iNumeroBien no-wait no-error.
            assign
                local.dtTrxEntretien       = if ttLot.lTravauxEntretien       then ttLot.daDateTravauxEntretien       else ? // l'outil de copie ne prend pas en compte les valeurs "?"
                local.dtTrxMiseAuxNormes   = if ttLot.lTravauxMiseAuxNormes   then ttLot.daDateTravauxMiseAuxNormes   else ? // l'outil de copie ne prend pas en compte les valeurs "?"
                local.dtTrxRestructuration = if ttLot.lTravauxRestructuration then ttLot.daDateTravauxRestructuration else ? // l'outil de copie ne prend pas en compte les valeurs "?"
            .
            if outils:isUpdated(buffer local:handle, 'local : ', string(ttLot.iNumeroBien), ttLot.dtTimestamp)
            or not outils:copyValidLabeledField(buffer local:handle, buffer ttLot:handle, 'U', mtoken:cUser)
            then undo bloc, leave bloc.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value

end procedure.

procedure deleteLocal:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer local for local.

bloc:
    do transaction:
        for each ttLot where ttLot.CRUD = "D":
            find first local exclusive-lock
                 where local.noloc = ttLot.iNumeroBien no-wait no-error.
            if outils:isUpdated(buffer local:handle, 'Local: ', string(ttLot.iNumeroBien), ttLot.dtTimestamp)
            then undo bloc, leave bloc.

            delete local no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo bloc, leave bloc.
            end.
        end.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value

end procedure.