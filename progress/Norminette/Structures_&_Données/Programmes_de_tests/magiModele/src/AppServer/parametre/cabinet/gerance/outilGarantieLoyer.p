/*------------------------------------------------------------------------
File        : outilGarantieLoyer.p
Purpose     : Regroupement des fonctions et procedures pour toutes les garanties loyer (Glo, Vacance locative, protection juridique etc...)
Author(s)   : RF - adaptations SPo 2018/04/18
Notes       :
derniere revue: 2018/05/24 - phm: KO
        traiter les todo,
        trop de code en commentaire.
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bareme.i}
{preprocesseur/periode2garantie.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/error.i}
{application/include/glbsepar.i}

function f-isnull returns logical private(pcChaine as character):
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes:
    -----------------------------------------------------------------------------*/
    return pcChaine = ? or pcChaine = "".
end function.

function libelleParamComptaAchatOuOd returns character(pcCodeComptabilisation as character, piReference as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : utilisé par différentes procédures .p
    ------------------------------------------------------------------------------*/
    define buffer ifdparam for ifdparam.
    if pcCodeComptabilisation = "00001"
    then for first ifdparam no-lock
        where ifdparam.soc-dest = piReference:
        return outilTraduction:getLibelle(if ifdparam.fg-od then 106021 else 106022).
    end.
end function.

function testGarantieExiste returns logical(pcTypeGarantie as character, piNumeroGarantie as integer, pcCRUD as character):
    /*------------------------------------------------------------------------------
    Purpose: Recherche si une garantie existe
             + Si CRUD modification ou suppression alors génération d'erreur
    Notes  : utilisé par les différentes procédures .p de controle avant update
    ------------------------------------------------------------------------------*/
    if not can-find(first garan no-lock
                    where garan.tpctt = pcTypeGarantie
                      and garan.noctt = piNumeroGarantie
                      and garan.tpbar = "") then do:
        if lookup(pcCRUD, "U,D") > 0
        then mError:createErrorGestion({&error}, 1000685, substitute('&2&1', separ[1], outilTraduction:getLibelleProg('O_CLC', pcTypeGarantie))).
        return false.
    end.
    return true.
end function.

function testAssureurAutorise returns logical(pcTypeGarantie as character, piNumeroGarantie as integer, pcCodeAssureur as character, pcCRUD as character):
    /*------------------------------------------------------------------------------
    Purpose: Vérification que le compte du fournisseur existe
             + si CRUD création il ne doit pas être déjà utilisé pour une autre garantie
    Notes  : d'après procedure VerCptFour de gartlo00.p.
             utilisé par les différentes procédures .p de controle avant update
    ------------------------------------------------------------------------------*/
    define buffer ccptcol for ccptcol.
    define buffer garan   for garan.

    // 1 - saisie non vide
    if f-isNull(pcCodeAssureur) then do:
        mError:createError({&error}, 107702).
        return false.
    end.
    // 2 - fournisseur existant
    for first ccptcol no-lock
        where ccptcol.soc-cd = integer(mtoken:cRefGerance)
          and ccptcol.tprole = 12:
        if can-find(first ifour no-lock
            where ifour.soc-cd   = ccptcol.soc-cd
              and ifour.coll-cle = ccptcol.coll-cle
              and ifour.cpt-cd   = pcCodeAssureur) then do:
            if pcCRUD = "C"
            then for first garan no-lock
                where garan.tpctt =  pcTypeGarantie
                  and garan.noctt <> piNumeroGarantie
                  and garan.tpbar =  ""
                  and garan.lbdiv =  pcCodeAssureur:
                mError:createError({&error}, 1000686, substitute('&2&1&3&1&4', separ[1], pcCodeAssureur, outilTraduction:getLibelleProg('O_CLC', pcTypeGarantie), garan.noctt)).
                return false.
            end.
            return true.
        end.
    end.
    mError:createErrorGestion({&error}, 107703, substitute('&2&1', separ[1], pcCodeAssureur)).
    return false.
end function.

function testCourtier returns logical(pcNumeroCourtier as character):
    /*------------------------------------------------------------------------------
    Purpose: Vérification que le compte du courtier existe
    Notes  : d'après procedure VerCptCourtier de gartlo00.p
             utilisé par les différentes procédures .p de controle avant update
    ------------------------------------------------------------------------------*/
    define buffer ccptcol for ccptcol.
    // 1 - saisie non vide
    if f-isnull(pcNumeroCourtier) or integer(pcNumeroCourtier) = 0 then do:
        mError:createError({&error}, 1000691).
        return false.
    end.
    // 2 - fournisseur existant
    for first ccptcol no-lock
         where ccptcol.soc-cd = integer(mtoken:cRefGerance)
           and ccptcol.tprole = 12:
        if can-find(first ifour no-lock
                    where ifour.soc-cd   = ccptcol.soc-cd
                      and ifour.coll-cle = ccptcol.coll-cle
                      and ifour.cpt-cd   = pcNumeroCourtier)
        then return true.
    end.
    mError:createError({&error}, 1000690, pcNumeroCourtier).
    return false.
end function.

function tacheBailAssocie return character private(pcTypeGarantie as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche de la tache assurance du bail associée au type de garantie
    Notes  :
    ------------------------------------------------------------------------------*/
    case pcTypeGarantie:
        when {&TYPECONTRAT-GarantieLoyer}           or when {&TYPECONTRAT-garantieRisqueLocatif}
     or when {&TYPECONTRAT-proprietaireNonOccupant} or when {&TYPECONTRAT-vacanceLocative}
     or when {&TYPECONTRAT-ProtectionJuridique}     then return pcTypeGarantie.

        when {&TYPECONTRAT-GarantiePierre}          then return {&TYPETACHE-GarantieSpeciale}.
    end case.
    mError:createError({&error}, 1000687, pcTypeGarantie).     // Type de contrat inconnu.
    return "".
end function.

function testGarantieUtilisee returns logical(pcTypeGarantie as character, piNumeroGarantie as integer, pcCRUD as character):
    /*------------------------------------------------------------------------------
    Purpose: Recherche si une garantie loyer est utilisée par un bail
             + si CRUD Suppression alors génération erreur suppression interdite
    Notes  : d'après procedure VerGarUti de gartlo00.p
             utilisé par les différentes procédures .p de controle avant update
    ------------------------------------------------------------------------------*/
    define variable vcTypeTache  as character no-undo.
    define buffer tache for tache.

    vcTypeTache = tacheBailAssocie(pcTypeGarantie).
    if mError:erreur() then return false.

boucleTache:
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-bail}
          and tache.tptac = vcTypeTache:
        if integer(tache.cdreg) = piNumeroGarantie
        or (piNumeroGarantie = 1 and f-isNull(tache.cdreg)) then do:
            if pcCRUD = "D" then
                mError:createErrorGestion({&error}, 107707, substitute('&2&1', separ[1], piNumeroGarantie, tache.nocon)).
            return true.
        end.
    end.
    return false.
end function.

function testCarence returns logical(pcCodeCalculSelondate as character, pdNombreMoisCarence as integer):
    /*------------------------------------------------------------------------------
    Purpose: contrôle de la saisie du nombre de mois de carence si option démarrage garantie à partir d'une date d'application
    Notes  : utilisé par les différentes procédures .p de controle avant update
    ------------------------------------------------------------------------------*/
    if pcCodeCalculSelondate = {&oui} and pdNombreMoisCarence = 0 then do:
        mError:createError({&error}, 1000692).
        return false.
    end.
    return true.
end function.

function testModeComptabilisationQuestion returns logical(pcTypeGarantie as character, pcModeComptabilisation as character, table ttError):
    /*------------------------------------------------------------------------------
    Purpose: test si le mode de comptabilisation a changé
             et demande de confirmation (Ce mode de comptabilisation sera affecté à toutes les garanties loyer. Confirmez-vous votre choix?)
    Notes  : utilisé par les différentes procédures .p de controle avant update
    ------------------------------------------------------------------------------*/
    define variable viNumeroReponse as integer no-undo.
    define buffer garan for garan.

    for first garan no-lock
        where garan.tpctt = pcTypeGarantie
          and garan.tpbar = ""
          and garan.lbdiv2 <> pcModeComptabilisation:
        // Ce mode de comptabilisation sera affecté à toutes les garanties de même type. Confirmez-vous votre choix?
        viNumeroReponse = outils:questionnaire(1000693, table ttError by-reference).
        if viNumeroReponse <= 2 then do:         // question oui/non pour continuer le traitement
            if viNumeroReponse = 2
            then mError:createError({&error}, 1000689). // message sans interet mais erreur nécessaire pour interrompre màj
            return false.
        end.
    end.
    return true.
end function.

function testBareme returns logical(pcCodeTVA as character, pcQueryCommercial as character, pcQueryHabitation as character, phttBaremeCommercial as handle, phttBaremeHabitation as handle):
    /*------------------------------------------------------------------------------
    Purpose: Contrôle des barèmes saisis
    Notes  : utilisé par les différentes procédures .p de controle avant update
    ------------------------------------------------------------------------------*/
    define variable vhQueryCommercial    as handle  no-undo.
    define variable vhQueryHabitation    as handle  no-undo.
    define variable vdTaux2Tva           as decimal no-undo.
    define variable vdMtCotisation       as decimal no-undo.
    define variable vdTauxCotisation     as decimal no-undo.
    define variable vdTauxHonoraire      as decimal no-undo.
    define variable vdTauxResultat       as decimal no-undo.
    define variable vlExisteBaremeNonNul as logical no-undo.

    define buffer sys_Pr for sys_Pr.

    for first sys_Pr no-lock
        where sys_Pr.TpPar = "CDTVA"
          and sys_Pr.CdPar = pcCodeTVA:
        vdTaux2Tva = Sys_Pr.Zone1.
    end.
    create query vhQueryCommercial.
    vhQueryCommercial:set-buffers(phttBaremeCommercial).
    vhQueryCommercial:query-prepare(pcQueryCommercial).
    vhQueryCommercial:query-open().
    create query vhQueryHabitation.
    vhQueryHabitation:set-buffers(phttBaremeHabitation).
    vhQueryHabitation:query-prepare(pcQueryHabitation).
    vhQueryHabitation:query-open().

commercial:
    repeat:
        vhQueryCommercial:get-next().
        if vhQueryCommercial:query-off-end then leave commercial.

        assign
            vdMtCotisation   = phttBaremeCommercial::dMtCotisation
            vdTauxCotisation = phttBaremeCommercial::dTauxCotisation
            vdTauxHonoraire  = phttBaremeCommercial::dTauxHonoraire
            vdTauxResultat   = phttBaremeCommercial::dTauxResultat
        .
        // 1 - TVA ou Forfait TTC, il faut choisir
        if vdTaux2Tva <> 0 and vdMtCotisation > 0 then do:
            mError:createError({&error}, 106024 ).
            leave commercial.
        end.
        // 3 - Les taux Hono doivent être >= 0 et Les taux résultants doivent être >= taux cotisation
        if vdMtCotisation = 0 and vdTauxCotisation <> 0 then do:
            if vdTauxHonoraire < 0 then do:
                mError:createErrorGestion({&error}, 110054, substitute('&2&1', separ[1], trim(string(vdTauxHonoraire, "->9.9999")))).
                leave commercial.
            end.
            if vdTauxResultat < vdTauxCotisation then do:
                mError:createErrorGestion({&error}, 110053, substitute('&2&1&3', separ[1], trim(string(vdTauxResultat, "->9.9999")), trim(string(vdTauxCotisation, "->9.9999")))).
                leave commercial.
            end.
        end.
        if vdMtCotisation <> 0 or vdTauxCotisation <> 0 or vdTauxHonoraire <> 0 then vlExisteBaremeNonNul = true.
    end.
    if vhQueryCommercial:is-open then vhQueryCommercial:query-close().
    delete object vhQueryCommercial no-error.
    if mError:erreur() then return false.

habitation:
    repeat:
        vhQueryHabitation:get-next().
        if vhQueryHabitation:query-off-end then leave habitation.

        assign
            vdMtCotisation   = phttBaremeHabitation::dMtCotisation
            vdTauxCotisation = phttBaremeHabitation::dTauxCotisation
            vdTauxHonoraire  = phttBaremeHabitation::dTauxHonoraire
            vdTauxResultat   = phttBaremeHabitation::dTauxResultat
        .
        // 1 - TVA ou Forfait, il faut choisir
        if vdTaux2Tva <> 0 and vdMtCotisation > 0 then do:
              mError:createError({&error}, 106024).
              leave habitation.
        end.
        // 3 - Les taux résultants doivent être >= taux cotisation // Les taux Hono doivent être >= 0
        if vdMtCotisation = 0 and vdTauxCotisation <> 0 then do:
            if vdTauxHonoraire < 0 then do:
                mError:createErrorGestion({&error}, 110054, substitute('&2&1', separ[1], trim(string(vdTauxHonoraire, "->9.9999")))).
                leave habitation.
            end.
            if vdTauxResultat < vdTauxCotisation then do:
                mError:createErrorGestion({&error}, 110053, substitute('&2&1&3', separ[1], trim(string(vdTauxResultat, "->9.9999")), trim(string(vdTauxCotisation, "->9.9999")))).
                leave habitation.
            end.
        end.
        if vdMtCotisation <> 0 or vdTauxCotisation <> 0 or vdTauxHonoraire <> 0 then vlExisteBaremeNonNul = true.
    end.
    if vhQueryHabitation:is-open then vhQueryHabitation:query-close().
    delete object vhQueryHabitation no-error.
     //  il doit exister un bareme non nul
    if not vlExisteBaremeNonNul then mError:createError({&error}, 107723).
    if mError:erreur() then return false.
    return true.
end function.

function testModifPeriodicite return logical(pcTypeGarantie as character, piNumeroGarantie as integer, pcCodePeriodicite as character):
    /*------------------------------------------------------------------------------
    Purpose: Controle de la modification de la périodicité d'une garantie loyer
    Notes  : d'après procedure VerPerGlo de gartlo00.p
             utilisé par les différentes procédures .p de controle avant update
             
             Principe :
             On ne peut changer la périodicité de la Garantie Loyer que si
              - Il n'y a encore eu aucun traitement de quittancement
             On ne peut PAS changer la périodicité de la Garantie Loyer
             entre 2 phases de quittancement
             
             Ou sinon il faut que
              - mois de début période en cours = mois Quitt en cours (GlMoiQtt)
                (sinon perte des mois entre début de période et mois en cours)
              - mois de début Nlle période     = mois Quitt en cours (GlMoiQtt)
                (sinon perte des mois entre mois en cours et Nlle période )
    ------------------------------------------------------------------------------*/
    define variable voCollection as class collection no-undo.
    define variable viMoisQuittancement        as integer   no-undo.
    define variable viMoisModifiable           as integer   no-undo.
    define variable viMoisEchu                 as integer   no-undo.
    define variable vcMoisQuittancement        as character no-undo.
    define variable vcCodePeriodiciteReference as character no-undo initial {&PERIODEGARANTIE-mensuel}.
    define variable viNombreMoisPeriode        as integer   no-undo.
    define variable vcListePremierMois         as character no-undo.
    define variable vcListeDernierMois         as character no-undo.
    define variable vdaDate1erTraitementPNO    as date      no-undo.
    define variable viNoMandat1erTraitementPNO as integer   no-undo.
    define variable vcMoiQtt1erTraitementPNO   as character no-undo.
    define variable vcMoiQsttPNO               as character no-undo.
    define variable vcLibErreur                as character no-undo.
    define variable vhProcTransfert            as handle    no-undo.

    define buffer svtrf for svtrf.
    define buffer garan for garan.
    define buffer aspno for aspno.

    for first garan no-lock
        where garan.tpctt = pcTypeGarantie
          and garan.noctt = piNumeroGarantie
          and garan.tpbar =  ""
          :
        if garan.cdper = pcCodePeriodicite then return true.    // Pas de modification : ok

        if not can-find(first svtrf no-lock
                    where svtrf.cdtrt = "QUIT"
                      and svtrf.noord > 0) then return true.    // Pas encore de traitement de quittancement => OK

        vcCodePeriodiciteReference = garan.cdper.
    end.
    
    run adblib/transfert/suiviTransfert_CRUD.p persistent set vhProcTransfert.
    run getTokenInstance in vhProcTransfert(mToken:JSessionId).
    voCollection = new collection().
    voCollection:set("cCodeTraitement", "QUIT").
    run calculTransfertAppelExterne in vhProcTransfert(input-output voCollection).
    assign
        viMoisQuittancement = voCollection:getInteger("GlMoiQtt")
        viMoisModifiable    = voCollection:getInteger("GlMoiMdf")
        viMoisEchu          = voCollection:getInteger("GlMoiMEc")
        .
    run destroy in vhProcTransfert.
    delete object voCollection.
    vcMoisQuittancement = string(viMoisQuittancement modulo 100, "99").
    if vcMoisQuittancement = "00" then return true.

    if viMoisQuittancement <> viMoisModifiable or viMoisQuittancement <> viMoisEchu then do:
        mError:createError({&error}, 107776).   // "Modification interdite entre 2 phases de quittancement"
        return false.
    end.
    // Contrôle specifique PNO
    if pcTypeGarantie = {&TYPECONTRAT-ProprietaireNonOccupant} then do:
        assign
            vdaDate1erTraitementPNO    = ?
            viNoMandat1erTraitementPNO = 0
            vcMoiQtt1erTraitementPNO   = ""
            vcMoiQsttPNO               = ""
        .
        for each aspno no-lock
           where aspno.tpgar = {&TYPECONTRAT-ProprietaireNonOccupant}
             and aspno.nogar = (if available garan then garan.noctt else 0)
             and aspno.tpcon = {&TYPECONTRAT-mandat2Gerance}
             and aspno.fgtrtcotis1
            break by aspno.dttrtcotis1 by aspno.nocon:

            if first(aspno.dttrtcotis1) then do:
                assign
                    vdaDate1erTraitementPNO    = aspno.dttrtcotis1
                    viNoMandat1erTraitementPNO = aspno.nocon
                    vcMoiQsttPNO               = entry(1, aspno.lbdiv2, "@")
                .
                if length(vcMoiQsttPNO, "character") = 6
                then vcMoiQtt1erTraitementPNO = substitute("&1/&2", substring(vcMoiQsttPNO, 5, 2, "character"), substring(vcMoiQsttPNO, 1, 4, "character")).
            end.
            if vdaDate1erTraitementPNO <> ? then leave.
        end.
        if vdaDate1erTraitementPNO <> ? then do:
            // Modification interdite: le traitement de cette PNO a déjà commencé le &1&2 ( mandat &3)
            vcLibErreur = substitute(
                outilTraduction:getLibelle(1000694)
                ,vdaDate1erTraitementPNO
                ,if vcMoiQtt1erTraitementPNO > "" then " " + outilTraduction:getLibelle(100242) + " : " + vcMoiQtt1erTraitementPNO else ""
                ,viNoMandat1erTraitementPNO
            ).
            mError:createError({&error}, vcLibErreur).
            return false.
        end.
    end.
    else do:
        run informationPeriodicite(
            vcCodePeriodiciteReference
            , output viNombreMoisPeriode
            , output vcListePremierMois
            , output vcListeDernierMois
        ).
        if viNombreMoisPeriode > 1
        and lookup(vcMoisQuittancement, vcListePremierMois, "@") = 0 then do:
            // Vous ne pouvez changer la périodicité des garanties loyers%sque lorsque le 1er mois de la période est égal au mois de Quittancement en cours (%1)
            mError:createErrorGestion({&error}, 107777, substitute('&2&1', separ[1], vcMoisQuittancement)).
            return false.
        end.
        run informationPeriodicite (
            pcCodePeriodicite
            , output viNombreMoisPeriode
            , output vcListePremierMois
            , output vcListeDernierMois
        ).
        if viNombreMoisPeriode > 1
        and lookup(vcMoisQuittancement, vcListePremierMois, "@") = 0 then do:
            // Vous ne pouvez choisir qu'une périodicité qui commence avec le mois de Quittancement en cours (%1).
            mError:createErrorGestion({&error}, 107778, substitute('&2&1', separ[1], vcMoisQuittancement)).
            return false.
        end.
    end.
    return true.

end function.

procedure informationPeriodicite private:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation des infos sur la Périodicité /  Nb de Mois et 1er Mois Période.
    Notes  : d'après procedure IniInfPer de gartlo00.p
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodePeriodicite   as character no-undo.
    define output parameter piNombreMoisPeriode as integer   no-undo.
    define output parameter pcListePremierMois  as character no-undo.
    define output parameter pcListeDernierMois  as character no-undo.

    case pcCodePeriodicite:
        when {&PERIODEGARANTIE-mensuel} then assign
            piNombreMoisPeriode = 1
            pcListePremierMois  = ""
        .
        when {&PERIODEGARANTIE-trim-Jan-Mar} then assign
            piNombreMoisPeriode = 3
            pcListePremierMois  = "01@04@07@10"
            pcListeDernierMois  = "03@06@09@12"
        .
        when {&PERIODEGARANTIE-trim-Fev-Avr} then assign
            piNombreMoisPeriode = 3
            pcListePremierMois  = "02@05@08@11"
            pcListeDernierMois  = "04@07@10@01"
        .
        when {&PERIODEGARANTIE-trim-Mar-Mai} then assign
            piNombreMoisPeriode = 3
            pcListePremierMois  = "03@06@09@12"
            pcListeDernierMois  = "05@08@11@02"
        .
    end case.

end procedure.

procedure infosPeriodeGarantieLoyer:
    /*------------------------------------------------------------------------------
    Purpose: caractéristiques d'un code periode Garantie loyer (garan.cdper)
    Notes  : Service. A partir de \comm\infpergl.i
             utilisé par les différentes procédures .p de controle avant update
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodePeriode       as character no-undo.
    define input  parameter piMoisQuitt         as integer   no-undo.
    define output parameter piNombreMoisPeriode as integer   no-undo.
    define output parameter pcListePremierMois  as character no-undo.
    define output parameter pcListeDernierMois  as character no-undo.
    define output parameter piMoisMin           as integer   no-undo.
    define output parameter piMoisMax           as integer   no-undo.

    define variable viMoisQuittNextGLo as integer   no-undo.
    define variable vcNumeroMoisTemp   as character no-undo.
    define variable viNumeroAnneeTemp  as integer   no-undo.
    define variable viNumeroMoisInt    as integer   no-undo.
    define variable viNumeroAnneeInt   as integer   no-undo.
    define variable viCompteur         as integer   no-undo.

    // Initialisation des infos sur la Périodicité: Nb de Mois, liste 1er Mois Période et dernier mois période
    run informationPeriodicite(
        pcCodePeriode
        , output piNombreMoisPeriode
        , output pcListePremierMois
        , output pcListeDernierMois
    ).
    if piNombreMoisPeriode = 1
    then assign
        viMoisQuittNextGLo = piMoisQuitt
        piMoisMin          = piMoisQuitt
        piMoisMax          = piMoisQuitt
    .
    else if piNombreMoisPeriode = 3 then do:
        // Recherche bornes d'extraction du prochain traitement
        assign
            viNumeroAnneeTemp = truncate(piMoisQuitt / 100, 0)
            vcNumeroMoisTemp  = string(piMoisQuitt modulo 100, "99")
        .
boucleCompteur:
        do viCompteur = 1 to 4:
            if lookup(vcNumeroMoisTemp, pcListeDernierMois, "@") > 0 then do:
                viMoisQuittNextGLo = integer(string(viNumeroAnneeTemp, "9999") + vcNumeroMoisTemp).
                leave boucleCompteur.
            end.
            if integer(vcNumeroMoisTemp) < 12
            then vcNumeroMoisTemp = string(integer(vcNumeroMoisTemp) + 1, "99").
            else assign
                vcNumeroMoisTemp  = "01"
                viNumeroAnneeTemp = viNumeroAnneeTemp + 1
            .
        end.
        // Bornes
        assign
            piMoisMax        = viMoisQuittNextGLo
            viNumeroMoisInt  = viMoisQuittNextGLo modulo 100
            viNumeroAnneeInt = truncate(viMoisQuittNextGLo / 100, 0)
        .
        if viNumeroMoisInt > 02
        then viNumeroMoisInt = viNumeroMoisInt - 2.
        else assign
            viNumeroMoisInt  = 12
            viNumeroAnneeInt = viNumeroAnneeInt - 1
        .
        piMoisMin = viNumeroAnneeInt * 100 + viNumeroMoisInt.
    end.

end procedure.

procedure loadBaremeGarantie:
    /*-----------------------------------------------------------------------------
    Purpose: Création des ttbaremeXXX pour tous types de garantie loyer du bail (sauf spéciale)
    Notes  : service utilisé par les différentes procédures .p de controle avant update
    -----------------------------------------------------------------------------*/
    define input parameter pcTypeGarantie     as character no-undo.
    define input parameter piNumeroGarantie   as integer   no-undo.
    define input parameter pcTypeBareme       as character no-undo.
    define input parameter phttBaremeGarantie as handle    no-undo.

    define buffer garan for garan.

    for each garan no-lock
        where garan.tpctt = pcTypeGarantie
          and garan.noctt = piNumeroGarantie
          and garan.tpbar = (if pcTypeBareme > "" then pcTypeBareme else garan.tpbar)
          and garan.nobar > 0:
        phttBaremeGarantie:buffer-create().
        assign
            phttBaremeGarantie::cTypeContrat   = garan.tpctt
            phttBaremeGarantie::iNumeroContrat = garan.noctt
            phttBaremeGarantie::cTypeBareme    = garan.tpbar
            phttBaremeGarantie::INumeroBareme  = garan.nobar
            phttBaremeGarantie::dtTimestamp = datetime(garan.dtmsy,garan.hemsy)
            phttBaremeGarantie::CRUD        = "R"
            phttBaremeGarantie::rRowid      = rowid(garan)
        .
        if entry(1, garan.lbdiv, "@") = "MT"
        then assign
            phttBaremeGarantie::dMtCotisation  = garan.txcot
            phttBaremeGarantie::dTauxHonoraire = if garan.tpctt = {&TYPECONTRAT-ProprietaireNonOccupant} then garan.txhon else 0
            phttBaremeGarantie::dTauxResultat  = 0
        .
        else assign
            phttBaremeGarantie::dMtCotisation   = 0
            phttBaremeGarantie::dTauxCotisation = garan.txcot
            phttBaremeGarantie::dTauxHonoraire  = garan.txhon
            phttBaremeGarantie::dTauxResultat   = garan.txres
        .
    end.
end procedure.

procedure nomAdresseAssureur:
    /*------------------------------------------------------------------------------
    Purpose: Récupération des informations de l'assureur (ou cabinet): Nom et adresse
    Notes  : Service. A partir de recLibAss
             utilisé par les différentes procédures .p de controle avant update
    ------------------------------------------------------------------------------*/
    define input  parameter piReference          as integer   no-undo.
    define input  parameter pcTypeGarantie       as character no-undo.
    define input  parameter piNumeroGarantie     as integer   no-undo.
    define input  parameter pcCodeAssureur       as character no-undo.
    define input  parameter pcCompteAssureur     as character no-undo.
    define output parameter pcNomAssureur        as character no-undo.
    define output parameter pcNomAdresseAssureur as character no-undo.

    define variable vcCodeAssureur as character no-undo.
    define buffer ifour   for ifour.
    define buffer ccptcol for ccptcol.

    vcCodeAssureur = if pcTypeGarantie = {&TYPECONTRAT-VacanceLocative}
                     then pcCompteAssureur
                     else if piNumeroGarantie = 1 and f-isnull(pcCodeAssureur) then "00000" else pcCodeAssureur.
    for first ccptcol no-lock
        where ccptcol.soc-cd = piReference
          and ccptcol.tprole = 12
      , first ifour no-lock
        where ifour.soc-cd   = ccptcol.soc-cd
          and ifour.coll-cle = ccptcol.coll-cle
          and ifour.cpt-cd   = vcCodeAssureur:
        assign
            pcNomAssureur        = trim(ifour.nom)
            pcNomAdresseAssureur = substitute("&1 (&2 &3 &4)", trim(ifour.nom), trim(ifour.adr[1]), trim(ifour.cp), trim(ifour.ville))
            pcNomAdresseAssureur = replace(pcNomAdresseAssureur, ",", " ")
            pcNomAdresseAssureur = replace(pcNomAdresseAssureur, ";", " ")
        .
    end.

end procedure.
