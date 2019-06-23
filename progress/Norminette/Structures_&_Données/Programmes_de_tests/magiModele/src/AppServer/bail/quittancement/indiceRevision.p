/*------------------------------------------------------------------------
    File        : indiceRevision.p
    Purpose     : Indice Révision Loyer dans bail
    Author(s)   : npo  -  29/11/2017
    Notes       : à partir de adb\src\quit\indrev00.p + \quit\gesirv00.p + gesirv01.p
  ----------------------------------------------------------------------*/

/****  npo 
    Toutes les modifs et les créations sont dans ce programme et non dans \bail\quittancement\indiceRevision_CRUD.p
    car elles ne sont utilisées QUE dans ce programme !!!!
****/

{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageFournisseurLoyer.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/combo.i}
{application/include/error.i}
{bail/include/equit.i}
{bail/include/indiceRevisionLoyer.i}

function recupInfosIndiceAnneePrecedente returns decimal(piCodeIndice as integer, piAnneeIndice as integer, piPeriodeIndice as integer, pdTauxIndiceSaisi as decimal):
    /*------------------------------------------------------------------------------
    Purpose: Récupération des infos de l'indice de l'année précédente pour les % d'évolution
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer indrv for indrv.

    for first indrv no-lock
        where indrv.cdirv = piCodeIndice
          and indrv.anper = piAnneeIndice - 1
          and indrv.noper = piPeriodeIndice:
        return round(((pdTauxIndiceSaisi - indrv.vlirv) * 100) / indrv.vlirv, 4).
    end.
    return 0.

end function.

function isEntre2PhasesDeQuitt returns logical():
    /*------------------------------------------------------------------------------
    Purpose: renvoie si l'appli est entre 2 phases de quitt
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcTransfert as handle     no-undo.
    define variable voCollection    as collection no-undo.
    define variable viGlMoiMdf      as integer    no-undo.
    define variable viGlMoiQtt      as integer    no-undo.
    define variable lCreateAutorise as logical    no-undo.
    define variable lModifAutorise  as logical    no-undo.

    // Recherche mois de quittancement en cours locataires
    run adblib/transfert/suiviTransfert_CRUD.p persistent set vhProcTransfert.
    run getTokenInstance in vhProcTransfert(mToken:JSessionId).
    voCollection = new collection().
    run getInfoTransfert in vhProcTransfert("QUIT", input-output voCollection).
    run destroy in vhProcTransfert.

    assign
        viGlMoiQtt = voCollection:getInteger("GlMoiQtt")
        viGlMoiMdf = voCollection:getInteger("GlMoiMdf")
    .
    if viGlMoiMdf < viGlMoiQtt then return true.
                               else return false.
end function.

procedure getIndiceRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeIndice  as integer no-undo.
    define input  parameter piAnneeIndice as integer no-undo.
    define output parameter table for ttIndiceRevisionLoyer.    

    define variable viNumeroIndice           as integer    no-undo.
    define variable viAnneeIndiceReference   as integer    no-undo.
    define variable viPeriodeIndiceReference as integer    no-undo.
    define variable vdValeurDernierIndice    as decimal    no-undo.
    define variable vdTauxDernierIndice      as decimal    no-undo.
    define variable vcCodePeriodicite        as character  no-undo.
    define variable viNumeroAnnee1           as integer    no-undo.
    define variable viNumeroAnnee2           as integer    no-undo.
    define variable viNumeroAnnee3           as integer    no-undo.
    define variable viAvantDernierIndice     as integer    no-undo.

    define buffer lsirv for lsirv.
    define buffer indrv for indrv.

    // Recherche de l'année de référence = dernière année de l'indice
    run recupDernierIndiceRevision(piCodeIndice, output viAnneeIndiceReference, output viPeriodeIndiceReference, output vdValeurDernierIndice, output vdTauxDernierIndice).

    // Récupération des infos pour le diagramme
    for first lsirv no-lock
        where lsirv.cdirv = piCodeIndice:

        // Code de périodicité
        assign
            vcCodePeriodicite = string(lsirv.cdper, "99")
            viNumeroAnnee1    = viAnneeIndiceReference
        .
        case vcCodePeriodicite:
            when "01" then
                assign
                    viNumeroAnnee2 = viAnneeIndiceReference
                    viNumeroAnnee3 = viAnneeIndiceReference
                .
            otherwise
                assign
                    viNumeroAnnee2 = viAnneeIndiceReference - 1
                    viNumeroAnnee3 = viAnneeIndiceReference - 2
                .
        end case.

        // Récupération des valeurs de l'indice
        viAvantDernierIndice = 0.
        for each indrv no-lock
            where indrv.cdirv = lsirv.cdirv
              and indrv.anper <= viNumeroAnnee1
              and indrv.anper >= viNumeroAnnee3
            break by indrv.anper descending
                  by indrv.noper descending:

            viAvantDernierIndice = viAvantDernierIndice + 1.

            create ttIndiceRevisionLoyer.
            assign
                ttIndiceRevisionLoyer.iCodeTypeIndice       = indrv.cdirv
                ttIndiceRevisionLoyer.cLibelleTypeIndice    = lsirv.lbcrt
                ttIndiceRevisionLoyer.iNumeroAnneeReference = indrv.anper
                ttIndiceRevisionLoyer.iNumeroPeriodAnnee    = indrv.noper
                ttIndiceRevisionLoyer.iCodePeriodicite      = lsirv.cdper
                ttIndiceRevisionLoyer.dValeurIndice         = indrv.vlirv
                ttIndiceRevisionLoyer.dTauxRevision         = indrv.txirv
                ttIndiceRevisionLoyer.daParutionJO          = indrv.dtpjo
                ttIndiceRevisionLoyer.daSaisieLe            = indrv.dtmsy
                ttIndiceRevisionLoyer.cFlagAutomatique      = lsirv.fgaut
                ttIndiceRevisionLoyer.iFlagValeur           = lsirv.fgval
                ttIndiceRevisionLoyer.iNombreDecimals       = lsirv.nbdec
                ttIndiceRevisionLoyer.lModifAutorise        = false
                ttIndiceRevisionLoyer.lSupprAutorise        = false
                ttIndiceRevisionLoyer.dtTimestamp           = datetime(indrv.dtmsy, indrv.hemsy)
                ttIndiceRevisionLoyer.CRUD                  = 'R'
                ttIndiceRevisionLoyer.rRowid                = rowid(indrv)
            .
            // Indice automatique = pas de 'C', 'U' ni 'D' possible
            if ttIndiceRevisionLoyer.cFlagAutomatique = '0' then 
                assign
                    ttIndiceRevisionLoyer.lCreateAutorise = false
                    ttIndiceRevisionLoyer.lModifAutorise  = false
                    ttIndiceRevisionLoyer.lSupprAutorise  = false
                .    
            else do: // Indice Manuel
                ttIndiceRevisionLoyer.lCreateAutorise = true.

                // Modif et Suppr possible sur le dernier indice saisi
                if first(indrv.noper) then
                    assign
                        ttIndiceRevisionLoyer.lModifAutorise = true
                        ttIndiceRevisionLoyer.lSupprAutorise = true
                    .
                // Si type indice avec decimales : BATIMENT  ou IPC ou STATEC ou PSDB
                if ttIndiceRevisionLoyer.iNombreDecimals > 0 
                or ttIndiceRevisionLoyer.iCodeTypeIndice < 6 
                or (ttIndiceRevisionLoyer.iCodeTypeIndice >= 10 and ttIndiceRevisionLoyer.iCodeTypeIndice <= 16) 
                or ttIndiceRevisionLoyer.iCodeTypeIndice = 17 then .  // gesirv01.p
                else do: // gesirv00.p
                    // Avant dernier indice : Modif Indices n-1 autorisé si trimestriel ou mensuel pour (gesirv00.p)
                    if viAvantDernierIndice = 2 and ttIndiceRevisionLoyer.iCodePeriodicite  <= 3 then
                        assign
                            ttIndiceRevisionLoyer.lCreateAutorise = false
                            ttIndiceRevisionLoyer.lModifAutorise  = true
                            ttIndiceRevisionLoyer.lSupprAutorise  = false
                        .
                end.
            end.
            // Gestion des indices : IMPOSSIBLE de créer/modifier les indices de révision%sentre les 2 phases de quittancement.
            /*if isEntre2PhasesDeQuitt() then 
                assign
                    ttIndiceRevisionLoyer.lCreateAutorise = false
                    ttIndiceRevisionLoyer.lModifAutorise  = false
                .*/
        end.
    end.

end procedure.

procedure defautIndiceRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define output parameter table for ttIndiceRevisionLoyer.

    define variable viNumeroIndice as integer no-undo.

    // Proposer par défaut Type Indice = "IRL2008"
    viNumeroIndice = 201.
    
    run getIndiceRevisionLoyer(viNumeroIndice, 0, output table ttIndiceRevisionLoyer).

end procedure.

procedure initIndiceRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBails.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeIndice  as integer no-undo.
    define input  parameter piAnneeIndice as integer no-undo.
    define output parameter table for ttIndiceRevisionLoyer.    

    define buffer lsirv for lsirv.

    find first lsirv no-lock where lsirv.cdirv = piCodeIndice no-error.
    if not available lsirv then do:
        mError:createError({&error}, 100057).
        return.
    end.
    else run InfoParDefautIndiceRevisionLoyer(buffer lsirv).

end procedure.

procedure InfoParDefautIndiceRevisionLoyer private:
    /*------------------------------------------------------------------------------
    Purpose: creation table ttIndiceRevisionLoyer avec les informations par defaut pour creation
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer lsirv for lsirv.

    define variable viAnneeIndiceACreer   as integer no-undo.
    define variable viNumeroPeriodeACreer as integer no-undo.
    define variable vdValeurDernierIndice as decimal no-undo.
    define variable vdTauxDernierIndice   as decimal no-undo.

    empty temp-table ttIndiceRevisionLoyer.
    create ttIndiceRevisionLoyer.
    assign
        ttIndiceRevisionLoyer.iCodeTypeIndice    = lsirv.cdirv
        ttIndiceRevisionLoyer.cLibelleTypeIndice = lsirv.lbcrt
        ttIndiceRevisionLoyer.iCodePeriodicite   = lsirv.cdper
        ttIndiceRevisionLoyer.dValeurIndice      = 0
        ttIndiceRevisionLoyer.dTauxRevision      = 0
        ttIndiceRevisionLoyer.iNombreDecimals    = lsirv.nbdec
        ttIndiceRevisionLoyer.cFlagAutomatique   = lsirv.fgaut
        ttIndiceRevisionLoyer.iFlagValeur        = lsirv.fgval
        ttIndiceRevisionLoyer.CRUD               = 'C'
        // futur dernier indice saisi donc 'U' + 'D'
        ttIndiceRevisionLoyer.lModifAutorise     = yes   
        ttIndiceRevisionLoyer.lSupprAutorise     = yes
    .
    // Recherche de la derniere periode de l'indice
    run recupDernierIndiceRevision(lsirv.cdirv, output viAnneeIndiceACreer, output viNumeroPeriodeACreer, output vdValeurDernierIndice, output vdTauxDernierIndice).

   // Calcul du prochain indice
   viNumeroPeriodeACreer = viNumeroPeriodeACreer + 1.
   
   if (lsirv.cdper = 1 and viNumeroPeriodeACreer >= 13)
   or (lsirv.cdper = 3 and viNumeroPeriodeACreer >= 5)
   or (lsirv.cdper = 6 and viNumeroPeriodeACreer >= 3)
   or  lsirv.cdper = 12 then
       assign  
           viNumeroPeriodeACreer = 1
           viAnneeIndiceACreer   = viAnneeIndiceACreer + 1
       .
   assign
       ttIndiceRevisionLoyer.iNumeroAnneeReference = viAnneeIndiceACreer
       ttIndiceRevisionLoyer.iNumeroPeriodAnnee    = viNumeroPeriodeACreer
   . 

end procedure.

procedure setIndiceRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose: maj indice (a partir de la table ttIndiceRevisionLoyer en fonction du CRUD)
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttIndiceRevisionLoyer.
    define input parameter table for ttCombo.
    define input parameter table for ttError.

/* TODO : droits à 'C', 'U' et 'D'
                  IF LbTmpPdt = "AJOUT" THEN DO:
                      {comm/droitadb.i "cre" "men" 94} 
                  END.  
                  IF LbTmpPdt = "MODIF" THEN DO:
                      {comm/droitadb.i "mod" "men" 94} 
                  END. 
                  IF LbTmpPdt = "POUB" THEN DO:
                  {comm/droitadb.i "sup" "men" 94}  
                  END. 
*/

    for each ttIndiceRevisionLoyer
        where lookup(ttIndiceRevisionLoyer.CRUD, "C,U,D") > 0:

        if ttIndiceRevisionLoyer.cFlagAutomatique = '0' then next.  // Indice automatique = pas de 'C', 'U' ni 'D' possible

        if not can-find(first lsirv no-lock where lsirv.cdirv = ttIndiceRevisionLoyer.iCodeTypeIndice) then
        do:
            mError:createError({&error}, 105250).   // Indice non connu
            return.
        end.
        if ttIndiceRevisionLoyer.CRUD <> "C" and not can-find(first indrv no-lock
                                                              where indrv.cdirv = ttIndiceRevisionLoyer.iCodeTypeIndice
                                                                and indrv.anper = ttIndiceRevisionLoyer.iNumeroAnneeReference
                                                                and indrv.noper = ttIndiceRevisionLoyer.iNumeroPeriodAnnee) then
        do:
            mError:createError({&error}, 105250).   // Indice non connu
            return.
        end.
        run verifIndiceSaisi(buffer ttIndiceRevisionLoyer, buffer ttCombo, buffer ttError).
        if mError:erreur() then return.
        run majIndice(buffer ttIndiceRevisionLoyer).
    end.

end procedure.

procedure verifIndiceSaisi private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ttIndiceRevisionLoyer for ttIndiceRevisionLoyer.
    define parameter buffer ttCombo               for ttCombo.
    define parameter buffer ttError               for ttError.

    define variable vlIndiceTravail     as logical    no-undo.
    define variable vlIndiceUtilise     as logical    no-undo.
    define variable viNumeroPeriodeNext as integer    no-undo.
    define variable viAnneePeriodeNext  as integer    no-undo.
    define variable vcListeRevision     as character  no-undo.

    define buffer tache for tache.

    if ttIndiceRevisionLoyer.CRUD = "D" and ttIndiceRevisionLoyer.lSupprAutorise then
    do:
        //TODO
        /*{comm/droitadb.i "sup" "men" 94} */

        // Test si l'indice à supprimer est déjà utilisé
        if can-find(first tache no-lock
                        where tache.tpcon = {&TYPECONTRAT-bail}
                          and tache.tptac = {&TYPETACHE-revision}
                          and tache.dcreg = string(ttIndiceRevisionLoyer.iCodeTypeIndice)
                          and tache.cdreg = string(ttIndiceRevisionLoyer.iNumeroAnneeReference)
                          and tache.ntreg = string(ttIndiceRevisionLoyer.iNumeroPeriodAnnee, '99'))
        then do:
            // Cet indice de révision (ou un indice moyen résultat du calcul basé sur cet indice) est utilisé. Suppression interdite !
            mError:createError({&error}, 1000552).
            return.
        end.
        // Vérif que l'indice automatique découlant est non utilisé
        if ttIndiceRevisionLoyer.iCodeTypeIndice = 6 or ttIndiceRevisionLoyer.iCodeTypeIndice = 8 then
        do:
            if can-find(first tache no-lock
                            where tache.tpcon = {&TYPECONTRAT-bail}
                              and tache.tptac = {&TYPETACHE-revision}
                              and tache.dcreg = string(ttIndiceRevisionLoyer.iCodeTypeIndice + 1)
                              and tache.cdreg = string(ttIndiceRevisionLoyer.iNumeroAnneeReference)
                              and tache.ntreg = string(ttIndiceRevisionLoyer.iNumeroPeriodAnnee, '99'))
            then do:
                // Cet indice de révision (ou un indice moyen résultat du calcul basé sur cet indice) est utilisé. Suppression interdite !
                mError:createError({&error}, 1000552).
                return.
            end.
        end.
        // Question : Confirmez-vous la suppression de l'indice suivant : %s" + "Année : " + STRING(AnIndSup) + "%sPériode : " + STRING(NoPerSup)
        // Question : Confirmez-vous la suppression de l'indice suivant ?  Année-Période : %1
        if outils:questionnaire(1000568, string(ttIndiceRevisionLoyer.iNumeroAnneeReference) + "-" + string(ttIndiceRevisionLoyer.iNumeroPeriodAnnee, '99'), table ttError by-reference) <= 2 then return.
    end.
    else do:
        //TODO
        /*IF LbTmpPdt = "AJOUT" THEN DO:
            {comm/droitadb.i "cre" "men" 94} 
        END.  
        IF LbTmpPdt = "MODIF" THEN DO:
            {comm/droitadb.i "mod" "men" 94} 
        END.*/
 
        // Gestion des indices : IMPOSSIBLE de créer/modifier les indices de révision%sentre les 2 phases de quittancement. Veuillez contacter la Gestion Intégrale
        /*if isEntre2PhasesDeQuitt() then do:
            mError:createError({&error}, 107139).
            return.
        end.*/

        // Pour on ne teste plus que l'indice <> 0 pour permettre le taux 0 des lois 48
        if ttIndiceRevisionLoyer.iFlagValeur = 0 and ttIndiceRevisionLoyer.dValeurIndice = 0 then
        do:
            mError:createError({&error}, 102056).   // L'indice ne peut être égal à 0
            return.
        end.

        // Si modif de l'avant dernier Indice alors controler qu'il n'a pas été utilisé dans les révisions (si INSEE, v‚rif INSE-M aussi)
        if ttIndiceRevisionLoyer.CRUD = "U"
        then do:
            if ttIndiceRevisionLoyer.iNombreDecimals > 0 
            or ttIndiceRevisionLoyer.iCodeTypeIndice < 6 
            or (ttIndiceRevisionLoyer.iCodeTypeIndice >= 10 and ttIndiceRevisionLoyer.iCodeTypeIndice <= 16) 
            or ttIndiceRevisionLoyer.iCodeTypeIndice = 17
            then .    // gesirv01.p pas de contrôle en modif
            else do:  // gesirv00.p
                if can-find(first ttCombo where ttCombo.iSeqId = 2) // avant-dernier indice à modifier
                then do: // ctrindrv.p
                    // Balayage des révisions
                    for each tache no-lock
                        where tache.tptac = {&TYPETACHE-revision}
                          and tache.notac > 1
                          and tache.tpcon = {&TYPECONTRAT-bail}
                        by tache.nocon 
                        by tache.notac:
                
                        //run TstIndRev(ttIndiceRevisionLoyer.iCodeTypeIndice, ttIndiceRevisionLoyer.iNumeroAnneeReference, ttIndiceRevisionLoyer.iNumeroPeriodAnnee, output vlIndTrv).
                        // Test sur indice de départ
                        if  integer(tache.tpges) = ttIndiceRevisionLoyer.iCodeTypeIndice and integer(tache.pdges) = ttIndiceRevisionLoyer.iNumeroAnneeReference 
                        and integer(tache.ntges) = ttIndiceRevisionLoyer.iNumeroPeriodAnnee then
                            assign 
                                vlIndiceUtilise = yes
                                vlIndiceTravail = yes
                                .
                        if vlIndiceTravail then next.

                        // Test sur indice courant de la révision
                        if  integer(tache.dcreg) = ttIndiceRevisionLoyer.iCodeTypeIndice and integer(tache.cdreg) = ttIndiceRevisionLoyer.iNumeroAnneeReference 
                        and integer(tache.ntreg) = ttIndiceRevisionLoyer.iNumeroPeriodAnnee then
                            assign 
                                vlIndiceUtilise = yes
                                vlIndiceTravail = yes
                                .
                        if vlIndiceTravail then next.
                        
                        // Cas particulier : indice INSEE => recherche utilisation INSEE-M période et période suivante
                        if ttIndiceRevisionLoyer.iCodeTypeIndice = 6
                        then do:
                            // Test sur indice de départ
                            if  integer(tache.tpges) = 7 and integer(tache.pdges) = ttIndiceRevisionLoyer.iNumeroAnneeReference 
                            and integer(tache.ntges) = ttIndiceRevisionLoyer.iNumeroPeriodAnnee then
                                assign 
                                    vlIndiceUtilise = yes
                                    vlIndiceTravail = yes
                                .
                            if vlIndiceTravail then next.

                            // Test sur indice courant de la révision
                            if  integer(tache.dcreg) = 7 and integer(tache.cdreg) = ttIndiceRevisionLoyer.iNumeroAnneeReference 
                            and integer(tache.ntreg) = ttIndiceRevisionLoyer.iNumeroPeriodAnnee then
                                assign 
                                    vlIndiceUtilise = yes
                                    vlIndiceTravail = yes
                                .
                            if vlIndiceTravail then next.

                            if ttIndiceRevisionLoyer.iNumeroPeriodAnnee = 4 then 
                                assign 
                                    viNumeroPeriodeNext = 1
                                    viAnneePeriodeNext  = viAnneePeriodeNext + 1
                                .
                            else
                                viNumeroPeriodeNext = viNumeroPeriodeNext + 1.
                
                            // Test sur indice de départ
                            if integer(tache.tpges) = 7 and integer(tache.pdges) = viAnneePeriodeNext and integer(tache.ntges) = viNumeroPeriodeNext then
                                assign 
                                    vlIndiceUtilise = yes
                                    vlIndiceTravail = yes
                                .
                            if vlIndiceTravail then next.

                            // Test sur indice courant de la révision
                            if integer(tache.dcreg) = 7 and integer(tache.cdreg) = viAnneePeriodeNext and integer(tache.ntreg) = viNumeroPeriodeNext then
                                assign 
                                    vlIndiceUtilise = yes
                                    vlIndiceTravail = yes
                                .
                            if vlIndiceTravail then next.
                        end.
                    end.
                    /* ATTENTION : Cet indice a déjà été utilisé dans des révisions de Baux. Vous devrez reprendre manuellement les révisions concernées.
                       Confirmez-vous la modification ? */
                    if vlIndiceUtilise and outils:questionnaire(104449, table ttError by-reference) <= 2 then return. 
                end.
            end.
        end.
    end.
 
end procedure.

procedure majIndice private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttIndiceRevisionLoyer for ttIndiceRevisionLoyer.    

    define variable viNombreDecimals    as integer   no-undo.
    define variable vdTauxCalcule       as decimal   no-undo.
    define variable viAnneeIndiceNext   as integer   no-undo.
    define variable viNumeroPeriodeNext as integer   no-undo.
    define variable viCpUseIn2          as integer   no-undo.
    define variable viCpUseIn3          as integer   no-undo.
    define variable vdTauxOldIndice     as decimal   no-undo.
    define variable vdTauxFuturIndice   as decimal   no-undo.
    define variable vcLbTmpPdt          as character no-undo.
    define variable vcLbTmpPd2          as character no-undo.
    define variable vcLbTmpPd3          as character no-undo.
    define variable vdTauxSaisiIndice   as decimal   no-undo.
    define variable vdDcTmpPdt          as decimal   no-undo.

    define buffer indrv for indrv.
    define buffer lsirv for lsirv.

    if ttIndiceRevisionLoyer.CRUD = "D"
    then do:
        // suppression de l'indice ...
        for last indrv exclusive-lock
            where indrv.cdirv = ttIndiceRevisionLoyer.iCodeTypeIndice
              and indrv.anper = ttIndiceRevisionLoyer.iNumeroAnneeReference
              and indrv.noper = ttIndiceRevisionLoyer.iNumeroPeriodAnnee:
            delete indrv.
        end.

        // ... et de l'indice moyen correspondant
        if ttIndiceRevisionLoyer.iCodeTypeIndice = 6 or ttIndiceRevisionLoyer.iCodeTypeIndice = 8
        then do:
            for last indrv exclusive-lock
                where indrv.cdirv = ttIndiceRevisionLoyer.iCodeTypeIndice + 1
                  and indrv.anper = ttIndiceRevisionLoyer.iNumeroAnneeReference
                  and indrv.noper = ttIndiceRevisionLoyer.iNumeroPeriodAnnee:
                delete indrv.
            end.
        end.
    end.
    else do:
        // Récupération Nombre de décimales
        find first lsirv no-lock
            where lsirv.cdirv = ttIndiceRevisionLoyer.iCodeTypeIndice no-error.
        if available lsirv then
        do:
            viNombreDecimals = lsirv.nbdec.
            if viNombreDecimals = 0 then
                if lsirv.cdirv < 6 or lsirv.cdirv = 7 or lsirv.cdirv = 9 or (lsirv.cdirv >= 10 and lsirv.cdirv <= 16) or lsirv.cdirv = 17 then viNombreDecimals = 2. 
        end.
        // Si type indice avec decimales : BATIMENT ou IPC ou STATEC ou PSDB : \quit\GesIrv01.p
        if viNombreDecimals > 0 
        or ttIndiceRevisionLoyer.iCodeTypeIndice < 6 
        or (ttIndiceRevisionLoyer.iCodeTypeIndice >= 10 and ttIndiceRevisionLoyer.iCodeTypeIndice <= 16) 
        or ttIndiceRevisionLoyer.iCodeTypeIndice = 17
        then do:
            // Récupération des infos de l'indice de l'année précédente pour les % d'évolution
            vdTauxCalcule = recupInfosIndiceAnneePrecedente(ttIndiceRevisionLoyer.iCodeTypeIndice, ttIndiceRevisionLoyer.iNumeroAnneeReference
                                                          , ttIndiceRevisionLoyer.iNumeroPeriodAnnee, ttIndiceRevisionLoyer.dValeurIndice).
            // Vérification avec la donnée calculée côté IHM
            if vdTauxCalcule <> ttIndiceRevisionLoyer.dTauxRevision then do:
                // Problème de calcul du taux de révision
                mError:createError({&error}, 1000553).
                return.
            end.

            if ttIndiceRevisionLoyer.crud = 'C' or ttIndiceRevisionLoyer.crud = 'U' then
                run majIndrv(ttIndiceRevisionLoyer.iCodeTypeIndice, ttIndiceRevisionLoyer.iNumeroAnneeReference, ttIndiceRevisionLoyer.iNumeroPeriodAnnee,
                             ttIndiceRevisionLoyer.dValeurIndice, ttIndiceRevisionLoyer.dTauxRevision, ttIndiceRevisionLoyer.daParutionJO).
        end.
        else do: // \quit\GesIrv00.p
            if ttIndiceRevisionLoyer.crud = 'C' or ttIndiceRevisionLoyer.crud = 'U'
            then do:
                // INDICES DE REVISION LOI 1948  RT : Calcul des indices. Pour les indices loi 1948
                if ttIndiceRevisionLoyer.iCodeTypeIndice >= 20 then
                do:
                    // Parcours des indices loi 48 pour MAJ des valeurs s'ils ne sont pas primaires
                    assign 
                        viCpUseIn2 = ttIndiceRevisionLoyer.iCodeTypeIndice - 8
                        viCpUseIn3 = ttIndiceRevisionLoyer.iCodeTypeIndice + 9
                        .
                    /*--> Recherche du second indice primaire pour les calculs sauf pour les indices 1948-30 et 80 qui n'en ont pas besoin.
                          On récupère également son libellé pour le remplacer dans les formules de calcul */
                    if ttIndiceRevisionLoyer.iCodeTypeIndice <> 80 or ttIndiceRevisionLoyer.iCodeTypeIndice <> 30 
                    or ttIndiceRevisionLoyer.iCodeTypeIndice <> 180 or ttIndiceRevisionLoyer.iCodeTypeIndice <> 130
                    then do:
                        find first indrv
                            where indrv.cdirv = ttIndiceRevisionLoyer.iCodeTypeIndice - 10
                              and indrv.anper = ttIndiceRevisionLoyer.iNumeroAnneeReference no-wait no-error.
                        if available indrv then vdTauxOldIndice = indrv.txirv.
                                           else vdTauxOldIndice = 0.
                        find first indrv
                            where indrv.cdirv = ttIndiceRevisionLoyer.iCodeTypeIndice + 10
                              and indrv.anper = ttIndiceRevisionLoyer.iNumeroAnneeReference no-wait no-error.
                        if available indrv then vdTauxFuturIndice = indrv.txirv.
                                           else vdTauxFuturIndice = 0.
                    end.
                    else 
                        assign 
                            vdTauxOldIndice   = -1
                            vdTauxFuturIndice = -1
                        .
                    // MAJ des indices finissant par 1 et 0
                    for each lsirv no-lock
                        where string(lsirv.cdirv, "999") begins substring(string(ttIndiceRevisionLoyer.iCodeTypeIndice, "999"), 1, 2)
                          and (substring(string(lsirv.cdirv, "999"), 3, 1) = "1"
                           or  substring(string(lsirv.cdirv, "999"), 3, 1) = "0"):
                
                        assign
                            vcLbTmpPdt        = substring(string(lsirv.cdirv, "999"), 3, 1)
                            vdTauxSaisiIndice = ttIndiceRevisionLoyer.dTauxRevision
                        .
                        if vcLbTmpPdt = "1" then vdDcTmpPdt = vdTauxSaisiIndice - (vdTauxSaisiIndice * 0.25).
                                            else vdDcTmpPdt = vdTauxSaisiIndice.
                
                        // MAJ ou création de l'indice de révision
                        run majIndrv(ttIndiceRevisionLoyer.iCodeTypeIndice, ttIndiceRevisionLoyer.iNumeroAnneeReference, ttIndiceRevisionLoyer.iNumeroPeriodAnnee,
                                     ttIndiceRevisionLoyer.dValeurIndice, vdDcTmpPdt, ttIndiceRevisionLoyer.daParutionJO).
                    end.
                    // Si l'on possède tous les indices, on peut parcourir tous les indices 1948 concernés pour la MAJ des taux 1948 non primaires
                    if vdTauxOldIndice <> 0 then do:
                        for each lsirv no-lock
                            where lsirv.cdirv >= viCpUseIn2
                              and lsirv.cdirv <= viCpUseIn3:
                
                            assign
                                vcLbTmpPdt        = substring(string(lsirv.cdirv, "999"), 3, 1)
                                vcLbTmpPd2        = substring(string(lsirv.cdirv, "999"), 2, 1)
                                vcLbTmpPd3        = substring(string(ttIndiceRevisionLoyer.iCodeTypeIndice, "999"), 2, 1)
                                vdTauxSaisiIndice = ttIndiceRevisionLoyer.dTauxRevision
                                vdDcTmpPdt        = -9999.99
                            .
                            case vcLbTmpPdt:
                                when "5" then
                                    if vcLbTmpPd2 <> vcLbTmpPd3 then vdDcTmpPdt = (vdTauxSaisiIndice + vdTauxOldIndice) / 2.
                                when "6" then
                                    if vcLbTmpPd2 <> vcLbTmpPd3 then vdDcTmpPdt = ((vdTauxSaisiIndice + vdTauxOldIndice) / 2) - (((vdTauxSaisiIndice + vdTauxOldIndice) / 2) * 0.25).
                            end case.
                
                            // MAJ ou création de l'indice de révision
                            if vdDcTmpPdt <> -9999.99 then
                                run majIndrv(ttIndiceRevisionLoyer.iCodeTypeIndice, ttIndiceRevisionLoyer.iNumeroAnneeReference, ttIndiceRevisionLoyer.iNumeroPeriodAnnee,
                                             ttIndiceRevisionLoyer.dValeurIndice, vdDcTmpPdt, ttIndiceRevisionLoyer.daParutionJO).             
                        end.
                    end.
                    // Si l'on possède tous les indices, on peut parcourir tous les indices 1948 concernés pour la MAJ des taux 1948 non primaires
                    if vdTauxFuturIndice <> 0 then do:
                        for each lsirv no-lock
                            where lsirv.cdirv >= viCpUseIn2
                              and lsirv.cdirv <= viCpUseIn3:
                
                            assign
                                vcLbTmpPdt        = substring(string(lsirv.cdirv, "999"), 3, 1)
                                vcLbTmpPd2        = substring(string(lsirv.cdirv, "999"), 2,1)
                                vcLbTmpPd3        = substring(string(ttIndiceRevisionLoyer.iCodeTypeIndice, "999"), 2, 1)
                                vdTauxSaisiIndice = ttIndiceRevisionLoyer.dTauxRevision
                                vdDcTmpPdt        = -9999.99
                            .
                            case vcLbTmpPdt:
                                when "5" then
                                    if vcLbTmpPd2 = vcLbTmpPd3 then vdDcTmpPdt = (vdTauxSaisiIndice + vdTauxFuturIndice) / 2.
                                when "6" then
                                    if vcLbTmpPd2 = vcLbTmpPd3 then vdDcTmpPdt = ((vdTauxSaisiIndice + vdTauxFuturIndice) / 2) - (((vdTauxSaisiIndice + vdTauxFuturIndice) / 2) * 0.25).
                            end case.
                
                            // MAJ ou cr‚ation de l'indice de r‚vision
                            if vdDcTmpPdt <> -9999.99 then
                                run majIndrv(ttIndiceRevisionLoyer.iCodeTypeIndice, ttIndiceRevisionLoyer.iNumeroAnneeReference, ttIndiceRevisionLoyer.iNumeroPeriodAnnee,
                                             ttIndiceRevisionLoyer.dValeurIndice, vdDcTmpPdt, ttIndiceRevisionLoyer.daParutionJO).              
                        end.
                    end.
                end.
                
                // INDICES DE REVISION INSEE
                if ttIndiceRevisionLoyer.iCodeTypeIndice = 6 then do:
                    // Récupération des infos de l'indice de l'année précédente pour les % d'évolution
                    vdTauxCalcule = recupInfosIndiceAnneePrecedente(ttIndiceRevisionLoyer.iCodeTypeIndice, ttIndiceRevisionLoyer.iNumeroAnneeReference
                                                                  , ttIndiceRevisionLoyer.iNumeroPeriodAnnee, ttIndiceRevisionLoyer.dValeurIndice).
                    // Vérification avec la donnée calculée côté IHM
                    if vdTauxCalcule <> ttIndiceRevisionLoyer.dTauxRevision then do:
                        // Problème de calcul du taux de révision
                        mError:createError({&error}, 1000553).
                        return.
                    end.
                
                    run majIndrv(ttIndiceRevisionLoyer.iCodeTypeIndice, ttIndiceRevisionLoyer.iNumeroAnneeReference, ttIndiceRevisionLoyer.iNumeroPeriodAnnee,
                                 ttIndiceRevisionLoyer.dValeurIndice, ttIndiceRevisionLoyer.dTauxRevision, ttIndiceRevisionLoyer.daParutionJO).
                
                    // MAJ de l'indice INSEE-M de la période
                    run MajIndice-M (indrv.cdirv, ttIndiceRevisionLoyer.iNumeroAnneeReference, ttIndiceRevisionLoyer.iNumeroPeriodAnnee).
                
                    // Recherche si période suivante existe -> si oui: MAJ de l'indice INSEE-M période + 1
                    if ttIndiceRevisionLoyer.iNumeroPeriodAnnee = 4 then 
                        assign 
                            viAnneeIndiceNext   = ttIndiceRevisionLoyer.iNumeroAnneeReference + 1
                            viNumeroPeriodeNext = 1
                        .
                    else
                        assign 
                            viAnneeIndiceNext   = ttIndiceRevisionLoyer.iNumeroAnneeReference
                            viNumeroPeriodeNext = ttIndiceRevisionLoyer.iNumeroPeriodAnnee + 1
                        .
                    find first indrv no-lock
                        where indrv.cdirv = 6
                          and indrv.anper = viAnneeIndiceNext
                          and indrv.noper = viNumeroPeriodeNext no-error.
                    if available indrv then
                        // MAJ de l'indice INSEE-M de la période
                        run MajIndice-M (indrv.cdirv, viAnneeIndiceNext, viNumeroPeriodeNext).
                end.
                
                // INDICES DE REVISION FL Fournisseur loyer
                if ttIndiceRevisionLoyer.iCodeTypeIndice = 8 then do:
                    // Récupération des infos de l'indice de l'année précédente pour les % d'évolution 
                    vdTauxCalcule = recupInfosIndiceAnneePrecedente(ttIndiceRevisionLoyer.iCodeTypeIndice, ttIndiceRevisionLoyer.iNumeroAnneeReference
                                                                  , ttIndiceRevisionLoyer.iNumeroPeriodAnnee, ttIndiceRevisionLoyer.dValeurIndice).
                    // Vérification avec la donnée calculée côté IHM
                    if vdTauxCalcule <> ttIndiceRevisionLoyer.dTauxRevision then do:
                        // Problème de calcul du taux de révision
                        mError:createError({&error}, 1000553).
                        return.
                    end.

                    run majIndrv(ttIndiceRevisionLoyer.iCodeTypeIndice, ttIndiceRevisionLoyer.iNumeroAnneeReference, ttIndiceRevisionLoyer.iNumeroPeriodAnnee,
                                 ttIndiceRevisionLoyer.dValeurIndice, ttIndiceRevisionLoyer.dTauxRevision, ttIndiceRevisionLoyer.daParutionJO).
                
                    // MAJ de l'indice FL-M de la période
                    run MajIndice-M (indrv.cdirv, ttIndiceRevisionLoyer.iNumeroAnneeReference, ttIndiceRevisionLoyer.iNumeroPeriodAnnee).
                
                    // Recherche si période suivante existe -> si oui: MAJ de l'indice FL-M période + 1
                    if ttIndiceRevisionLoyer.iNumeroPeriodAnnee = 4 then 
                        assign 
                            viAnneeIndiceNext   = ttIndiceRevisionLoyer.iNumeroAnneeReference + 1
                            viNumeroPeriodeNext = 1
                        .
                    else
                        assign 
                            viAnneeIndiceNext   = ttIndiceRevisionLoyer.iNumeroAnneeReference
                            viNumeroPeriodeNext = ttIndiceRevisionLoyer.iNumeroPeriodAnnee + 1
                        .
                    find first indrv no-lock
                        where indrv.cdirv = 8
                          and indrv.anper = viAnneeIndiceNext
                          and indrv.noper = viNumeroPeriodeNext no-error.
                    if available indrv then
                        // Creation/MAJ FL MOYEN Fournisseur loyer
                        run MajIndice-M (indrv.cdirv, viAnneeIndiceNext, viNumeroPeriodeNext).
                end.
            end.
        end.  
        if ttIndiceRevisionLoyer.CRUD = "C" then
            run marquageQuittances(ttIndiceRevisionLoyer.iCodeTypeIndice, ttIndiceRevisionLoyer.iNumeroAnneeReference, ttIndiceRevisionLoyer.iNumeroPeriodAnnee).
    end.

end procedure.

procedure majIndice-M private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de Creation/MAJ des indices INSEE et FL MOYEN
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piCodeIndiceMaj    as integer no-undo.
    define input parameter piAnneeIndiceMaj   as integer no-undo.
    define input parameter piPeriodeIndiceMaj as integer no-undo.

    define variable vdaDatePJO    as date    no-undo.
    define variable vdTotalIndice as decimal no-undo.
    define variable vdValeurMaj   as decimal no-undo.
    define variable vdTauxMaj     as decimal no-undo.
    define variable vlFlagExeMth  as logical no-undo.
    define variable viCpUseInc    as integer no-undo.
    define variable viCpUseIn2    as integer no-undo.

    define buffer indrv for indrv.

    find first indrv no-lock
        where indrv.cdirv = piCodeIndiceMaj + 1
          and indrv.anper = piAnneeIndiceMaj
          and indrv.noper = piPeriodeIndiceMaj no-error.
    if available indrv then vdaDatePJO = indrv.dtpjo.

    assign 
        vlFlagExeMth  = true
        viCpUseIn2    = piPeriodeIndiceMaj + 1
        vdTotalIndice = 0    
    .
    if piPeriodeIndiceMaj = 4 then vlFlagExeMth = false.

    do viCpUseInc = piPeriodeIndiceMaj to 1 by -1:
        find first indrv no-lock
            where indrv.cdirv = piCodeIndiceMaj
              and indrv.anper = piAnneeIndiceMaj
              and indrv.noper = viCpUseInc no-error.
        if available indrv then vdTotalIndice = vdTotalIndice + indrv.vlirv.
    end.

    if vlFlagExeMth then do:
        piAnneeIndiceMaj = piAnneeIndiceMaj - 1.
        do viCpUseInc = 4 to viCpUseIn2 by -1:
            find first indrv no-lock
                where indrv.cdirv = piCodeIndiceMaj
                  and indrv.anper = piAnneeIndiceMaj
                  and indrv.noper = viCpUseInc no-error.
            if available indrv then vdTotalIndice = vdTotalIndice + indrv.vlirv.
        end.
        piAnneeIndiceMaj = piAnneeIndiceMaj + 1.
    end.

    // Indice INSEE-M
    vdValeurMaj = vdTotalIndice / 4.

    // Récupération des infos de l'indice de l'année précédente pour les % d'évolution
    find first indrv no-lock
        where indrv.cdirv = piCodeIndiceMaj + 1
          and indrv.anper = piAnneeIndiceMaj - 1
          and indrv.noper = piPeriodeIndiceMaj no-error.
    if available indrv then vdTauxMaj = ((vdValeurMaj - indrv.vlirv) * 100) / indrv.vlirv.
                       else vdTauxMaj = 0.

    // MAJ de l'indice
    run majIndrv(piCodeIndiceMaj + 1, piAnneeIndiceMaj, piPeriodeIndiceMaj, vdValeurMaj, vdTauxMaj, vdaDatePJO).

end procedure.

procedure majIndrv private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piCodeIndiceMaj    as integer no-undo.
    define input parameter piAnneeIndiceMaj   as integer no-undo.
    define input parameter piPeriodeIndiceMaj as integer no-undo.
    define input parameter pdValeurIndiceMaj  as decimal no-undo.
    define input parameter pdTauxIndiceMaj    as decimal no-undo.
    define input parameter pdaDatePJOMaj      as date    no-undo.

    define buffer indrv for indrv.

    find first indrv exclusive-lock
        where indrv.cdirv = piCodeIndiceMaj
          and indrv.anper = piAnneeIndiceMaj
          and indrv.noper = piPeriodeIndiceMaj no-error.
    if not available indrv then
    do:
        create indrv.
        assign
            indrv.cdirv = piCodeIndiceMaj
            indrv.anper = piAnneeIndiceMaj
            indrv.noper = piPeriodeIndiceMaj
            indrv.dtcsy = today
            indrv.hecsy = mtime
            indrv.cdcsy = mToken:cUser
            .
    end.
    assign
        indrv.vlirv = pdValeurIndiceMaj
        indrv.txirv = pdTauxIndiceMaj
        indrv.dtpjo = pdaDatePJOMaj
        indrv.dtmsy = today
        indrv.hemsy = mtime
        indrv.cdmsy = mToken:cUser
        .

end procedure.

procedure marquageQuittances private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de marquage des quittances à (re)transférer en cas d'ajout d'une 
             nouvelle période pour un indice
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piCodeIndice    as integer no-undo.
    define input parameter piAnneeIndice   as integer no-undo.
    define input parameter piPeriodeIndice as integer no-undo.

    define variable viNumeroAnneeRevision  as integer    no-undo.
    define variable vcCodeTermeLocataire   as character  no-undo.
    define variable vhProcTransfert        as handle     no-undo.
    define variable vhProcEquit            as handle     no-undo.
    define variable viGlMoiMdf             as integer    no-undo.
    define variable viGlMoiMec             as integer    no-undo.
    define variable viGlMflMdf             as integer    no-undo.
    define variable viMoisQuittEncours     as integer    no-undo.
    define variable vlFlagBailFourniLoyer  as logical    no-undo.
    define variable vlGestionFourniLoyer   as logical    no-undo.
    define variable voCollectionQuit       as collection no-undo.
    define variable voFournisseurLoyer     as class parametrageFournisseurLoyer no-undo.

    define buffer ctrat   for ctrat.
    define buffer tache   for tache.
    define buffer m_ctrat for ctrat.
    define buffer equit   for equit.

    // Recuperation du paramètre GESFL
    voFournisseurLoyer = new parametrageFournisseurLoyer().
    vlGestionFourniLoyer = voFournisseurLoyer:isGesFournisseurLoyer().
    delete object voFournisseurLoyer.

    // Recherche mois de quittancement en cours locataires
    run adblib/transfert/suiviTransfert_CRUD.p persistent set vhProcTransfert.
    run getTokenInstance in vhProcTransfert(mToken:JSessionId).
    voCollectionQuit = new collection().
    run getInfoTransfert in vhProcTransfert("QUIT", input-output voCollectionQuit).
    assign
        viGlMoiMec = voCollectionQuit:getInteger("GlMoiMEc")
        viGlMoiMdf = voCollectionQuit:getInteger("GlMoiMdf")
    .
    voCollectionQuit = new collection().
    run getInfoTransfert in vhProcTransfert("QUFL", input-output voCollectionQuit).
    viGlMflMdf = voCollectionQuit:getInteger("GlMflMdf").
    if valid-handle(vhProcTransfert) then run destroy in vhProcTransfert.

    // MAJ equit
    run bail/quittancement/equit_CRUD.p persistent set vhProcEquit.
    run getTokenInstance in vhProcEquit(mToken:JSessionId).

    majQuitt:
    for each ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-bail}
          and ctrat.dtree = ?:

        // Recherche si locataire Avance ou Echu
        vcCodeTermeLocataire = "00001".

        // Quittancement
        find last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-quittancement} no-error.   
        if not available tache then next majQuitt.
        vcCodeTermeLocataire = tache.ntges.

        // Tache Révision
        find last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-revision} no-error.
        if not available tache then next majQuitt.

        // On saute les Révisions manuelles
        if tache.tphon = "YES" then next majQuitt.
            
        // Recherche si prochaine révision va utiliser cet indice
        // Si ajout indice INSEE => INSEE-M aussi concerné
        if piCodeIndice = 6 then 
            if integer(tache.dcreg) <> 6 and integer(tache.dcreg) <> 7 then next majQuitt.
        else
            if integer(tache.dcreg) <> piCodeIndice then next majQuitt.

        if integer(tache.ntreg) <> piPeriodeIndice then next majQuitt.
        viNumeroAnneeRevision = integer(tache.cdreg) + tache.duree.
        if viNumeroAnneeRevision <> piAnneeIndice then next majQuitt.

        // Ini mois modifiable du locataire
        vlFlagBailFourniLoyer = no.
          
        find first m_ctrat no-lock
            where m_ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and m_ctrat.nocon = int64(truncate(ctrat.nocon / 100000, 0)) no-error.
        if lookup(m_ctrat.ntcon, substitute("&1,&2", {&NATURECONTRAT-mandatLocation}, {&NATURECONTRAT-mandatLocationIndivision})) > 0
        then vlFlagBailFourniLoyer = yes.
 
        if vlGestionFourniLoyer and vlFlagBailFourniLoyer then viMoisQuittEncours = viGlMflMdf.
        else if vcCodeTermeLocataire = "00002"            then viMoisQuittEncours = viGlMoiMec.
                                                          else viMoisQuittEncours = viGlMoiMdf.
/** retour en arrière car besoin d'assigner cdmsy autrement que par l'user
        // Recherche de la première quittance en cours
        for first equit no-lock
            where equit.noloc = ctrat.nocon
              and equit.msqtt >= viMoisQuittEncours
            use-index ix_equit03:
            create ttEquit.
            assign
                ttEquit.noint       = equit.noint
                ttEquit.noloc       = equit.noloc
                ttEquit.noqtt       = equit.noqtt
                ttEquit.fgtrf       = no
                ttEquit.cdmsy       = "MAJIND"
                ttEquit.rRowid      = rowid(equit)
                ttEquit.dtTimestamp = datetime(equit.dtmsy, equit.hemsy)
                ttEquit.CRUD        = 'U'
            .
        end.
        run setEquit in vhProcEquit(table ttEquit by-reference).
    end.
    run destroy in vhProcEquit.
**/  
        // Recherche de la première quittance en cours
        for first equit exclusive-lock
            where equit.noloc = ctrat.nocon
              and equit.msqtt >= viMoisQuittEncours
            use-index ix_equit03:
            assign
                equit.fgtrf = no
                equit.cdmsy = "MAJIND@" + mtoken:cUser
                equit.dtmsy = today
                equit.hemsy = mtime
            .
        end.
    end.
end procedure.

procedure recupDernierIndiceRevision private:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des infos du dernier indice saisi
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeIndice          as integer no-undo.
    define output parameter piAnneeIndice         as integer no-undo.
    define output parameter piPeriodeIndice       as integer no-undo.
    define output parameter pdValeurDernierIndice as decimal no-undo.
    define output parameter pdTauxDernierIndice   as decimal no-undo.

    define buffer indrv for indrv.

    for last indrv no-lock
        where indrv.cdirv = piCodeIndice:
        assign
            piAnneeIndice         = indrv.anper
            piPeriodeIndice       = indrv.noper
            pdValeurDernierIndice = indrv.vlirv
            pdTauxDernierIndice   = indrv.txirv
        .
    end.

end procedure.

procedure initComboIndiceRevisionLoyer:
    /*------------------------------------------------------------------------------
    Purpose: appel programme pour creation combo Indice Révision : last période et last période - 1
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeIndice  as integer no-undo.
    define input  parameter piAnneeIndice as integer no-undo.
    define output parameter table for ttCombo.

    run chargeCombo(piCodeIndice, piAnneeIndice).

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de toutes les combos de l'écran
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter piCodeIndice  as integer no-undo.
    define input parameter piAnneeIndice as integer no-undo.

    define variable viNumeroItem as integer   no-undo.
    define variable vhProcIndice as handle    no-undo.
    define variable vcLibelle    as character no-undo.

    define buffer indrv for indrv.

    run adblib/indiceRevision_CRUD.p persistent set vhProcIndice.
    run getTokenInstance in vhProcIndice(mToken:JSessionId).

    empty temp-table ttCombo.

    // Période de révision
    for each indrv no-lock
        where indrv.cdirv =  piCodeIndice
          and indrv.anper >= 1997
        by indrv.anper descending 
        by indrv.noper descending:

        // Recherche du libellé explicite de l'indice
        run getLibelleIndice in vhProcIndice(piCodeIndice, indrv.anper, indrv.noper, "l", output vcLibelle).

        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttCombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBPERIODEINDICE"
            ttCombo.cCode     = string(indrv.anper) + string(indrv.noper,"99")
            ttCombo.cLibelle  = vcLibelle
            ttCombo.cParent   = string(indrv.cdirv)
        .
        if viNumeroItem >= 2 then leave. // Max dernier + avant dernier indice qui nous intéresse car potentiellement modifiable

    end.
    run destroy in vhProcIndice.

end procedure.

procedure getLibelleIndice3Lignes:
    /*------------------------------------------------------------------------------
    Purpose: Formatage d'un indice de révision sur 3 lignes
    Notes  : service appelé par tacheRevisionLoyer.p   ancien \lib\formind2.p  
    ------------------------------------------------------------------------------*/
    define input parameter  pcTypeCleFormat         as character no-undo.
    define input parameter  piCodeIdentifiantIndice as integer   no-undo.
    define input parameter  pcAnneePeriode          as character no-undo.
    define input parameter  piLongueurLigne         as integer   no-undo.
    define output parameter pcLibelleIndice         as character no-undo.

    define variable vcLibelleNomIndice     as character no-undo.
    define variable viPeriodiciteIndice    as integer   no-undo.
    define variable vcLibelleLongIndice    as character no-undo.
    define variable viAnneeReferenceIndice as integer   no-undo.
    define variable viNumeroPeriodeIndice  as integer   no-undo.
    define variable vdeValeurIndice        as decimal   no-undo.
    define variable viNombreDecimal        as integer   no-undo.
    define variable vcLibelleCourtIndice   as character no-undo.
    define variable vcTableauLigne         as character extent 60 no-undo.
    define variable viCompteurMinimum      as integer   no-undo.
    define variable viCompteurMaximum      as integer   no-undo.
    define variable vhProcIndice           as handle    no-undo.

    define buffer lsirv for lsirv.
    define buffer indrv for indrv.

    run adblib/indiceRevision_CRUD.p persistent set vhProcIndice.
    run getTokenInstance in vhProcIndice(mToken:JSessionId).

    pcLibelleIndice = "||".
    if pcTypeCleFormat = "INDICE" then do:
        assign
            viAnneeReferenceIndice = integer(entry(1, pcAnneePeriode, "/"))
            viNumeroPeriodeIndice  = (if num-entries(pcAnneePeriode, "/") >= 2 then integer(entry(2, pcAnneePeriode, "/")) else 0)
        .
        for first lsirv no-lock
            where lsirv.cdirv = piCodeIdentifiantIndice :

            assign 
                vcLibelleNomIndice  = lsirv.lbcrt      // libellé court
                viPeriodiciteIndice = lsirv.cdper
                viNombreDecimal     = lsirv.nbdec      // nombre de décimales
            .
            if viAnneeReferenceIndice <> 0 then do:     
                // Formatage de l'indice (long)
                run getLibelleIndice in vhProcIndice(piCodeIdentifiantIndice, viAnneeReferenceIndice, viNumeroPeriodeIndice, "l", output vcLibelleLongIndice).
                //Formatage de l'indice (court)
                run getLibelleIndice in vhProcIndice(piCodeIdentifiantIndice, viAnneeReferenceIndice, viNumeroPeriodeIndice, "c", output vcLibelleCourtIndice).
                        
                for first indrv no-lock
                    where indrv.cdirv = piCodeIdentifiantIndice
                      and indrv.anper = viAnneeReferenceIndice
                      and Indrv.noper = viNumeroPeriodeIndice:
                    vdeValeurIndice = indrv.vlirv.
                end.
            end.
        end.
    end.
    run destroy in vhProcIndice.
    // Indice trouvé
    if vcLibelleLongIndice <> "" and vdeValeurIndice <> 0 then do:
        // Positionnement sur la premiere ligne
        viCompteurMinimum = 1.
        assign
            vcTableauLigne[viCompteurMinimum] = trim(vcLibelleNomIndice)
            viCompteurMinimum                 = viCompteurMinimum + 1
        .
        assign
            vcTableauLigne[viCompteurMinimum] = trim(vcLibelleLongIndice)
            viCompteurMinimum                 = viCompteurMinimum + 1
        .       
        // Valeur
        assign
            vcTableauLigne[viCompteurMinimum] = (if viAnneeReferenceIndice <> 0 then string(vdeValeurIndice) else "")
            viCompteurMinimum                 = viCompteurMinimum + 1
        .
        assign
            vcTableauLigne[viCompteurMinimum] = string(viNombreDecimal)
            viCompteurMinimum                 = viCompteurMinimum + 1
        .
        assign
            vcTableauLigne[viCompteurMinimum] = trim(vcLibelleCourtIndice)
            viCompteurMinimum                 = viCompteurMinimum + 1
        .           
        // Fusion des lignes dans la chaine a retourner
        assign
            viCompteurMaximum = viCompteurMinimum - 1
            pcLibelleIndice   = vcTableauLigne[1]
        .
        do viCompteurMinimum = 2 to viCompteurMaximum :
            pcLibelleIndice = pcLibelleIndice + "|" + vcTableauLigne[viCompteurMinimum].
        end.
    end.

end procedure.

procedure getcomboIndiceRevision:
    /*------------------------------------------------------------------------------
    Purpose: Construit la combo des indices de révision (libellé long ou court)
    Notes  : service appelé par tacheRevisionLoyer.p   et baremeHonoraire.p
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroItem    as integer   no-undo.
    define input  parameter pcFormatLibelle as character no-undo.
    define output parameter table for ttCombo.

    define buffer lsirv for lsirv.

    for each lsirv no-lock where lsirv.cdirv >= 0 :
        create ttCombo.
        assign
            piNumeroItem      = piNumeroItem + 1
            ttcombo.iSeqId    = piNumeroItem
            ttCombo.cNomCombo = "CMBINDICEREVISION"
            ttCombo.cCode     = string(lsirv.cdirv)
            ttCombo.cLibelle  = (if pcFormatLibelle = 'c' then lsirv.lbcrt else lsirv.lblng)
        .
    end.                        
end procedure.