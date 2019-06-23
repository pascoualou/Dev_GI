/*------------------------------------------------------------------------
File        : immeuble.p
Purpose     :
Author(s)   : kantena - 2016/07/12
Notes       :
Tables      : 13/10/2017  npo  #7791 modif  iVolume -> cVolume + add cNumero
derniere revue: 2018/05/22 - phm: KO
        traiter les todo
        en particulier supprimer la procédure updateContratConstruction, createContratConstruction
------------------------------------------------------------------------*/
{preprocesseur/nature2voie.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/nature2journal.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2telephone.i}

using parametre.pclie.parametragePayePegase.
using parametre.pclie.parametrageCarnetEntretien.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/ctrat.i}
{adblib/include/intnt.i}
{application/include/glbsepar.i}
{application/include/combo.i}
{adresse/include/adresse.i}
{adresse/include/moyenCommunication.i}
{adresse/include/coordonnee.i}
{immeubleEtLot/include/immeuble.i}
{immeubleEtLot/include/immeubleAutre.i}
{immeubleEtLot/include/ascenseur.i}
{immeubleEtLot/include/digicode.i}
{immeubleEtLot/include/reglementCopropriete.i}
{immeubleEtLot/include/impotTaxeImmeuble.i}
{immeubleEtLot/include/dommageOuvrage.i}
{immeubleEtLot/include/mesureAdministrative.i}
{immeubleEtLot/include/equipementBien.i}
{immeubleEtLot/include/gardienLoge.i}
{immeubleEtLot/include/horairesOuverture.i}
{immeubleEtLot/include/fichierJoint.i}
{immeubleEtLot/include/cleMagnetique.i}
{note/include/notes.i}
{role/include/role.i}
{role/include/roleContrat.i}
{serviceGestion/include/serviceGestion.i}
{serviceGestion/include/gestionnaire.i}
{mandat/include/mandat.i}

define variable giNumeroItem  as integer no-undo.
define variable giMaxLigne    as integer no-undo initial 500.  // nombre maxi de lignes renvoyées
define variable giNombreLigne as integer no-undo.
define variable ghProcTVA     as handle  no-undo.

function createHoraire returns logical private(phbttHoraires as handle, piNumeroIdentifiant as integer, pcHoraires as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcJourOuverture as character no-undo.

    phbttHoraires:buffer-create().
    assign
        phbttHoraires::iNumeroIdentifiant = piNumeroIdentifiant
        phbttHoraires::cHeureDebut1       = "00:00"
        phbttHoraires::cHeureFin1         = "20:00"
        phbttHoraires::cHeureDebut2       = "00:00"
        phbttHoraires::cHeureFin2         = "20:00"
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(1) = true
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(2) = false
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(3) = false
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(4) = false
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(5) = false
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(6) = false
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(7) = false
    .
    if pcHoraires > "" then assign
        phbttHoraires::cHeureDebut1  = entry(1, entry(1, pcHoraires, separ[1]), separ[2])
        phbttHoraires::cHeureFin1    = entry(2, entry(1, pcHoraires, separ[1]), separ[2])
        phbttHoraires::cHeureDebut2  = entry(1, entry(2, pcHoraires, separ[1]), separ[2])
        phbttHoraires::cHeureFin2    = entry(2, entry(2, pcHoraires, separ[1]), separ[2])
        vcJourOuverture              = entry(3, pcHoraires, separ[1]) when num-entries(pcHoraires, separ[1]) > 2
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(1)    = (substring(vcJourOuverture, 1, 1, 'character') = "1")
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(2) = (substring(vcJourOuverture, 2, 1, 'character') = "1")
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(3) = (substring(vcJourOuverture, 3, 1, 'character') = "1")
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(4) = (substring(vcJourOuverture, 4, 1, 'character') = "1")
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(5) = (substring(vcJourOuverture, 5, 1, 'character') = "1")
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(6) = (substring(vcJourOuverture, 6, 1, 'character') = "1")
        phbttHoraires:buffer-field('lJourOuverture'):buffer-value(7) = (substring(vcJourOuverture, 7, 1, 'character') = "1")
    .
end function.

function controleDateAchevement returns logical(piNumeoImmeuble as integer):
    /*------------------------------------------------------------------------------
    Purpose: controle de la date d'achèvement de l'immeuble
    Notes: service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-construction}
          and intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piNumeoImmeuble
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
        if add-interval(ctrat.dtfin, 2, "years") > today
        then do:
            mError:createError({&info}, 211692).     // Attention date d'achèvement inférieur à 2 ans.
            return true.
        end.
    end.
    return false.

end function.

function donneTelephone return character private(pcTypeRole as character, piNuneroRole as integer, pcTypeTelephone as character):
    /*------------------------------------------------------------------------------
    Purpose: Renvoie une chaine avec les information de la table telephone
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    for first telephones no-lock
        where telephones.tpidt = pcTypeRole
          and telephones.noidt = piNuneroRole
          and telephones.tpTel = pcTypeTelephone:
        return substitute('&1&2&3&2&4&2&5', telephones.tptel, separ[1], telephones.cdtel, telephones.notel, entry(1, telephones.lbdiv, separ[1])).
    end.
    return ''.

end function.

function donneNumeroServiceContrat returns integer (pcTypeContrat as character, piNumeroContrat as integer):
    /*------------------------------------------------------------------------------
    Purpose: Retourne le numero du service à partir d'un type et numero de contrat
    Notes  :
    todo : fonction dupliquée dans lot.p
    ------------------------------------------------------------------------------*/
    define variable vcTypePrincipal   as character no-undo.
    define variable viNumeroPrincipal as integer   no-undo.
    define variable viNumeroService   as integer   no-undo.

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
    for last ctctt no-lock
        where ctctt.tpct1 = {&TYPECONTRAT-serviceGestion}
          and ctctt.tpct2 = vcTypePrincipal
          and ctctt.noct2 = viNumeroPrincipal:
        viNumeroService = ctctt.noct1.
    end.
    return viNumeroService.

end function.

function getNumeroContratConstruction returns int64 (piNumeroImmeuble as integer):
    /*------------------------------------------------------------------------------
    Purpose: Donne le numéro de contrat de construction de l'immeuble
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-construction}
          and intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piNumeroImmeuble
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
        return ctrat.nocon.
    end.
    return 0.

end function.

procedure getInfoImmeubleParMandat:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat   as int64     no-undo.
    define input  parameter pcTypeContrat     as character no-undo.
    define output parameter table for ttImmeuble.

    define variable vcContact as character no-undo.

    define buffer intnt for intnt.
    define buffer Imble for Imble.
    define buffer ctrat for ctrat.
    define buffer tache for tache.

    /* Immeuble lié */
    for first intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.nocon = piNumeroContrat
          and intnt.tpcon = pcTypeContrat
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon:
        for first tache no-lock
            where tache.tpcon = {&TYPECONTRAT-construction}
              and tache.nocon = piNumeroContrat
              and tache.tptac = {&TYPETACHE-loge}
              and tache.notac = 1:
            vcContact = tache.tpges.
        end.
        for first Imble no-lock
            where Imble.noimm = intnt.noidt:
            create ttImmeuble.
            assign
                ttImmeuble.iNumeroImmeuble    = Imble.noimm
                ttImmeuble.cLibelleImmeuble   = Imble.lbnom
                ttImmeuble.cContact           = vcContact
                ttImmeuble.daDateConstruction = ctrat.dtdeb
            .
        end.
    end.

end procedure.

procedure rechercheImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter poCollection as collection no-undo.
    define output parameter table for ttListeImmeuble.

    define variable viGestion             as integer   no-undo.
    // Critères de recherche immeuble et lot
    define variable vcAdresse             as character no-undo.
    define variable vcNomImmeuble         as character no-undo.
    define variable viNumeroImmeuble      as integer   no-undo.
    define variable viNumeroImmeuble1     as integer   no-undo.
    define variable viNumeroImmeuble2     as integer   no-undo.
    define variable viNumeroMandat        as integer   no-undo.
    define variable viNumeroMandat1       as integer   no-undo.
    define variable viNumeroMandat2       as integer   no-undo.
    define variable vcStatut              as character no-undo.
    define variable vcService             as character no-undo.
    // Critères de recherche supplémentaires immeuble et lot
    define variable vcTypeImmeuble        as character no-undo.
    define variable vcSecteurGeographique as character no-undo.
    define variable vcNatureBien          as character no-undo.
    define variable vcCategorieBien       as character no-undo.
    define variable vcListeMandatSyndic   as character no-undo.
    define variable vcListeMandatCopro    as character no-undo.
    define variable vhProcAdresse         as handle    no-undo.

    /*define buffer imble for imble.*/
    define buffer ladrs for ladrs.
    define buffer adres for adres.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

    run adresse/adresse.p persistent set vhProcAdresse.
    run getTokenInstance  in vhProcAdresse(mToken:JSessionId).

    assign
        vcAdresse            = poCollection:getCharacter("cAdresseImmeuble")
        vcNomImmeuble        = poCollection:getCharacter("cNomImmeuble")
        viNumeroImmeuble     = poCollection:getInteger  ("iNumeroImmeuble")
        viNumeroImmeuble1    = poCollection:getInteger  ("iNumeroImmeuble1")
        viNumeroImmeuble2    = poCollection:getInteger  ("iNumeroImmeuble2")
        viNumeroMandat       = poCollection:getInteger  ("iNumeroMandat")
        viNumeroMandat1      = poCollection:getInteger  ("iNumeroMandat1")
        viNumeroMandat2      = poCollection:getInteger  ("iNumeroMandat2")
        vcStatut             = poCollection:getCharacter("cCodeStatut")
        vcService            = poCollection:getCharacter("cCodeService")
        vcTypeImmeuble       = poCollection:getCharacter("cCodeTypeImmeuble")
        vcSecteurGeographique= poCollection:getCharacter("cCodeSecteur")
        vcNatureBien         = poCollection:getCharacter("cCodeNatureBien")
        vcCategorieBien      = poCollection:getCharacter("cCodeCategorieImmeuble")
    .
    {&_proparse_ prolint-nowarn(when)}
    assign     // laiser 2 assign, utilisation de when
        viNumeroImmeuble1 = viNumeroImmeuble when viNumeroImmeuble > 0
        viNumeroMandat1   = viNumeroMandat   when viNumeroMandat   > 0
        viNumeroMandat2   = viNumeroMandat   when viNumeroMandat   > 0
    .
    {&_proparse_ prolint-nowarn(when)}
    assign     // laiser 2 assign, utilisation de when
        vcAdresse             = '' when vcAdresse = ?
        vcNomImmeuble         = '' when vcNomImmeuble = ?
        vcStatut              = '' when vcStatut  = 'all' or vcStatut = ?
        vcService             = '' when vcService = 'all' or vcService = ?
        vcTypeImmeuble        = '' when vcTypeImmeuble = 'all' or vcTypeImmeuble = ?
        vcSecteurGeographique = '' when vcSecteurGeographique = 'all' or vcSecteurGeographique = ?
        vcNatureBien          = '' when vcNatureBien = 'all' or vcNatureBien = ?
        vcCategorieBien       = '' when vcCategorieBien = 'all' or vcCategorieBien = ?

        viNumeroImmeuble1 = 0 when viNumeroImmeuble1 = ?
        viNumeroImmeuble2 = viNumeroImmeuble1 when viNumeroImmeuble2 = 0 or viNumeroImmeuble2 = ?
        viNumeroImmeuble2 = if viNumeroImmeuble1 = 0 and viNumeroImmeuble2 = 0 then 999999999 else if viNumeroImmeuble2 > 0 then viNumeroImmeuble2 else viNumeroImmeuble1

        viNumeroMandat1 = 0 when viNumeroMandat1 = ?
        viNumeroMandat2 = viNumeroMandat1 when viNumeroMandat2 = 0 or viNumeroMandat2 = ?
        viNumeroMandat2 = if viNumeroMandat1 = 0 and viNumeroMandat2 = 0 then 99999999 else if viNumeroMandat2 > 0 then viNumeroMandat2 else viNumeroMandat1
    .

boucleImmeuble:
    for each imble no-lock
        where imble.noimm >= viNumeroImmeuble1 and imble.noimm <= viNumeroImmeuble2:
        
        assign 
            vcListeMandatCopro  = ""
            vcListeMandatSyndic = ""
        .
        if vcService > ''
        then do:
            viGestion = 0.
            run application/envt/gesflges.p (mToken, integer(vcService), input-output viGestion, 'Direct', substitute("&1|&2", {&TYPEBIEN-immeuble}, string(imble.noimm))).
            if viGestion > 0 then next boucleImmeuble.
        end.
        if (vcAdresse > ''             and not dynamic-function('lDansAdresses' in vhProcAdresse, vcAdresse, {&TYPEBIEN-immeuble}, imble.noimm))
        or (vcTypeImmeuble > ''        and vcTypeImmeuble <> imble.tpimm)
        or (vcSecteurGeographique > '' and vcSecteurGeographique <> imble.cdSec)
        or (vcNatureBien > ''          and vcNatureBien <> imble.ntbie)
        or (vcCategorieBien > ''       and num-entries(imble.lbdiv, "&") >= 9 and vcCategorieBien <> entry(9, imble.lbdiv, "&")) then next boucleImmeuble.

        // Filtre sur le numéro de mandat.
        for each intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = imble.noimm
              and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon
              and ctrat.nocon >= viNumeroMandat1
              and ctrat.nocon <= viNumeroMandat2:
            vcListeMandatSyndic = substitute('&1,&2', vcListeMandatSyndic, ctrat.nocon).
            next toto.
        end.
        vcListeMandatSyndic = trim(vcListeMandatSyndic, ',').

        // Filtre sur le numéro de mandat.
        for each intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = imble.noimm
              and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon
              and ctrat.nocon >= viNumeroMandat1
              and ctrat.nocon <= viNumeroMandat2:
            vcListeMandatCopro = substitute('&1,&2', vcListeMandatCopro, ctrat.nocon).
            leave.
        end.
        vcListeMandatCopro = trim(vcListeMandatCopro, ',').

        if (vcListeMandatSyndic = "" and vcListeMandatCopro = "")
        or (viNumeroMandat > 0 
        and lookup(string(viNumeroMandat), vcListeMandatSyndic, ",") = 0
        and lookup(string(viNumeroMandat), vcListeMandatCopro,  ",") = 0) then next boucleImmeuble.

        // Adresse
        for first ladrs no-lock
            where ladrs.tpidt = {&TYPEBIEN-immeuble}
              and ladrs.noidt = imble.noimm
              and ladrs.tpadr = {&TYPEADRESSE-Principale}
          , first adres no-lock
            where adres.noadr = ladrs.noadr:
            create ttListeImmeuble.
            assign
                giNombreLigne                    = giNombreLigne + 1
                ttListeImmeuble.CRUD             = 'R'
                ttListeImmeuble.iNumeroImmeuble  = imble.noimm
                ttListeImmeuble.cLibelleImmeuble = imble.lbnom
                ttListeImmeuble.cAdresse         = outilFormatage:formatageAdresse(buffer ladrs, buffer adres, 0 /* ni ville, ni pays */) 
                ttListeImmeuble.cCodePostal      = caps(trim(adres.cdpos))
                ttListeImmeuble.cVille           = trim(adres.lbvil)
                ttListeImmeuble.dtTimestampImble = datetime(imble.dtmsy, imble.hemsy)
                ttListeImmeuble.dtTimestampAdres = datetime(adres.dtmsy, adres.hemsy)
            .
            if viNumeroMandat > 0 then leave boucleImmeuble. 
            if giNombreLigne >= giMaxLigne
            then do:
                mError:createError({&warning}, 211668, string(giMaxLigne)).  // nombre maxi d'enregistrement atteint
                leave boucleImmeuble.
            end.
        end.
    end.
    run destroy in vhProcAdresse.

end procedure.

procedure getImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttImmeuble.

    define variable vhProc as handle no-undo.

    run ImmeubleEtLot/imble_crud.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    run readImmeuble in vhproc(piNumeroImmeuble, output table ttImmeuble by-reference).
    run destroy in vhproc.

end procedure.

procedure getEquipementImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttEquipementBien.
    define output parameter table for ttFichierJointEquipement.

    define variable vhproc as handle no-undo.

    empty temp-table ttEquipementBien.
    empty temp-table ttFichierJointEquipement.
    run ImmeubleEtLot/equipementBien.p persistent set vhproc.
    run getTokenInstance  in vhproc(mToken:JSessionId).
    run getEquipementBien in vhproc(piNumeroImmeuble, {&TYPEBIEN-immeuble}, output table ttEquipementBien by-reference, output table ttFichierJointEquipement by-reference).
    run destroy           in vhproc.

end procedure.

procedure getLogeImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttLoge.
    define output parameter table for ttHorairesOuvSerie1.
    define output parameter table for ttHorairesOuvSerie2.

    define variable viContratConstruction as int64 no-undo.
    define buffer tache for tache.

    empty temp-table ttLoge.
    empty temp-table ttHorairesOuvSerie1.
    empty temp-table ttHorairesOuvSerie2.
    viContratConstruction = getNumeroContratConstruction(piNumeroImmeuble).
    for first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viContratConstruction
          and tache.tptac = {&TYPETACHE-loge}
          and tache.notac = 1:
        create ttLoge.
        assign
            ttLoge.CRUD            = 'R'
            ttLoge.iNumeroLoge     = 1
            ttLoge.cTypeContrat    = {&TYPECONTRAT-construction}
            ttLoge.iNumeroContrat  = tache.nocon
            ttLoge.iNumeroImmeuble = piNumeroImmeuble
            ttLoge.cTypeTache      = {&TYPETACHE-loge}
            ttLoge.iNumeroTache    = tache.noita
            ttLoge.dtTimestamp     = datetime(tache.dtmsy, tache.hemsy)
            ttLoge.rRowid          = rowid(tache)
        .
        if tache.tpges <> ? then ttLoge.cNomTiersDepannage = tache.tpges.    // Libellé Tiers: Dépannage sonner chez
        if tache.cdreg <> ? then ttLoge.cCodeTiersDepannage = tache.cdreg.   // 'roles.TpRol + "," + roles.NoRol' du tiers: Dépannage sonner chez
        /* Creation des horaires d'ouverture */
        createHoraire(buffer ttHorairesOuvSerie1:handle, ttLoge.iNumeroLoge, tache.tphon).
        createHoraire(buffer ttHorairesOuvSerie2:handle, ttLoge.iNumeroLoge, tache.ntges).

        /* Coordonnées de la personne à contacter */
        if tache.dcreg > "" then assign
            ttLoge.cCoordonneeContact1 = entry(1, tache.dcreg, SEPAR[1])
            ttLoge.cCoordonneeContact2 = entry(2, tache.dcreg, SEPAR[1]) when num-entries(tache.dcreg, separ[1]) > 1
        .
        /* Zones commentaires */
        if tache.lbdiv > "" then ttLoge.cCommentaire = entry(1, tache.lbdiv, separ[1])
                                                     + (if num-entries(tache.lbdiv, separ[1]) >= 2 then entry(2, tache.lbdiv, separ[1]) else '')
                                                     + (if num-entries(tache.lbdiv, separ[1]) >= 3 then entry(3, tache.lbdiv, separ[1]) else '').
        if tache.lbdiv2 > "" then ttLoge.cCommentaire = ttLoge.cCommentaire + entry(1, tache.lbdiv2, separ[1])
                                                      + (if num-entries(tache.lbdiv2, separ[1]) >= 2 then entry(2, tache.lbdiv2, separ[1]) else '')
                                                      + (if num-entries(tache.lbdiv2, separ[1]) >= 3 then entry(3, tache.lbdiv2, separ[1]) else '').
        if tache.lbdiv3 > "" then ttLoge.cCommentaire = ttLoge.cCommentaire + entry(1, tache.lbdiv3, separ[1])
                                                      + (if num-entries(tache.lbdiv3, separ[1]) >= 2 then entry(2, tache.lbdiv3, separ[1]) else '')
                                                      + (if num-entries(tache.lbdiv3, separ[1]) >= 3 then entry(3, tache.lbdiv3, separ[1]) else '').
        ttLoge.cCommentaire = trim(ttLoge.cCommentaire).
    end.

end procedure.

procedure getReglementCopropriete:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les information de réglement de copropriete
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble  as integer no-undo.
    define output parameter table for ttReglementCopropriete.
    define output parameter table for ttFichierJoint.

    define variable viNumeroContratConstruction as int64  no-undo.
    define variable vhFichierJoint              as handle no-undo.

    define buffer tache for tache.

    empty temp-table ttReglementCopropriete.
    empty temp-table ttFichierJoint.
    run immeubleEtLot/fichierJoint.p persistent set vhFichierJoint.
    run getTokenInstance in vhFichierJoint(mToken:JSessionId).
    viNumeroContratConstruction = getNumeroContratConstruction(piNumeroImmeuble).
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viNumeroContratConstruction
          and tache.tptac = {&TYPETACHE-reglement2copro}:
        create ttReglementCopropriete.
        assign
            ttReglementCopropriete.CRUD                  = 'R'
            ttReglementCopropriete.iNumeroImmeuble       = piNumeroImmeuble
            ttReglementCopropriete.iNumeroReglement      = tache.noita
            ttReglementCopropriete.cTypeContrat          = tache.tpcon
            ttReglementCopropriete.iNumeroContrat        = tache.nocon
            ttReglementCopropriete.cCodeTypeTache        = tache.tptac
            ttReglementCopropriete.iChronoTache          = tache.notac
            ttReglementCopropriete.daDateReglement       = tache.dtdeb
            ttReglementCopropriete.cLieuReglement        = Tache.tpfin
            ttReglementCopropriete.daDatePublication     = tache.dtfin
            ttReglementCopropriete.cNomBureau            = tache.ntges
            ttReglementCopropriete.iNumeroNotaire        = integer(tache.tpges)
            ttReglementCopropriete.cNomNotaire           = outilFormatage:getNomTiers({&TYPEROLE-notaire}, ttReglementCopropriete.iNumeroNotaire)
            //ttReglementCopropriete.iVolume               = integer(tache.pdges)   npo #7791
            ttReglementCopropriete.cVolume               = tache.pdges
            ttReglementCopropriete.cNumero               = tache.pdreg      /* npo #7791 */
            ttReglementCopropriete.iTotalLot             = tache.duree
            ttReglementCopropriete.iNombreLotsPrincipaux = integer(tache.cdreg)
            ttReglementCopropriete.cCommentaire          = tache.ntreg
            ttReglementCopropriete.dtTimestamp           = datetime(tache.dtmsy, tache.hemsy)
            ttReglementCopropriete.rRowid                = rowid(tache)
        .
        run getPJ in vhFichierJoint(
            {&TYPETACHE-reglement2copro},
            int64(string(piNumeroImmeuble, "9999") + string(ttReglementCopropriete.iNumeroReglement, if ttReglementCopropriete.iNumeroReglement > 99999 then "999999" else "99999")),
            "", output table ttFichierJoint by-reference).
    end.
    run destroy in vhFichierJoint.

end procedure.

procedure getImpotTaxe:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les information des organismes sociaux
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble   as integer no-undo.
    define output parameter table for ttImpotTaxe.

    define variable viNumeroContratConstruction as int64 no-undo.
    define buffer tache for tache.
    define buffer orsoc for orsoc.

    empty temp-table ttImpotTaxe.
    viNumeroContratConstruction = getNumeroContratConstruction(piNumeroImmeuble).
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viNumeroContratConstruction
          and tache.tptac = {&TYPETACHE-organismesSociaux}
      , first orsoc no-lock
        where orsoc.tporg = tache.tpfin
          and orsoc.ident = tache.ntges:
        create ttImpotTaxe.
        assign
            ttImpotTaxe.CRUD               = 'R'
            ttImpotTaxe.iNumeroImmeuble    = piNumeroImmeuble
            ttImpotTaxe.iNumeroTache       = tache.noita
            ttImpotTaxe.cTypeContrat       = tache.tpcon
            ttImpotTaxe.iNumeroContrat     = tache.nocon
            ttImpotTaxe.cCodeTypeTache     = tache.tptac
            ttImpotTaxe.iChronoTache       = tache.notac
            ttImpotTaxe.cCodeTypeOrganisme = tache.tpfin
            ttImpotTaxe.cNumeroOrganisme   = tache.ntges
            ttImpotTaxe.cNomOrganisme      = orsoc.lbnom
            ttImpotTaxe.cLibelleAdresse    = substitute("&1 &2 &3", orsoc.adres, orsoc.cdpos, orsoc.lbvil)
            ttImpotTaxe.cTelephone         = orsoc.NoTel
            ttImpotTaxe.dtTimestamp        = datetime(tache.dtmsy, tache.hemsy)
            ttImpotTaxe.rRowid             = rowid(tache)
        .
    end.

end procedure.

procedure getDigicode:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations digicodes
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttDigicode.
    define output parameter table for ttDigicodeImmeuble.

    define variable viNumeroContratConstruction as int64 no-undo.
    define buffer tache for tache.

    empty temp-table ttDigicode.
    empty temp-table ttDigicodeImmeuble.
    viNumeroContratConstruction = getNumeroContratConstruction(piNumeroImmeuble).
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viNumeroContratConstruction
          and tache.tptac = {&TYPETACHE-digicode}:
        create ttDigicodeImmeuble.
        assign
            ttDigicodeImmeuble.CRUD              = 'R'
            ttDigicodeImmeuble.iNumeroImmeuble   = piNumeroImmeuble
            ttDigicodeImmeuble.iNumeroDigicode   = tache.noita
            ttDigicodeImmeuble.cTypeContrat      = tache.tpcon
            ttDigicodeImmeuble.iNumeroContrat    = tache.nocon
            ttDigicodeImmeuble.cCodeTypeTache    = tache.tptac
            ttDigicodeImmeuble.iChronoTache      = tache.notac
            ttDigicodeImmeuble.cCodeBatiment     = tache.TpFin
            ttDigicodeImmeuble.cCodeEntree       = tache.CdHon
            ttDigicodeImmeuble.cCodeEscalier     = tache.tphon
            ttDigicodeImmeuble.dtTimestamp       = datetime(tache.dtmsy, tache.hemsy)
            ttDigicodeImmeuble.rRowid            = rowid(tache)
        .
        /* Digicode 1 */
        create ttDigicode.
        assign
            ttDigicode.CRUD             = 'R'
            ttDigicode.iNumeroImmeuble  = piNumeroImmeuble
            ttDigicode.iNumeroDigicode  = tache.noita
            ttDigicode.cTypeContrat     = tache.tpcon
            ttDigicode.iNumeroContrat   = tache.nocon
            ttDigicode.cCodeTypeTache   = tache.tptac
            ttDigicode.iChronoTache     = tache.notac
            ttDigicode.iExtent          = 1
            ttDigicode.cLibelleDigicode = tache.lbdiv
            ttDigicode.cAncienDigicode  = tache.ntges
            ttDigicode.daDateFin        = tache.dtfin
            ttDigicode.cNouveauDigicode = tache.tpges
            ttDigicode.daDateDebut      = tache.dtdeb
            ttDigicode.dtTimestamp      = datetime(tache.dtmsy, tache.hemsy)
            ttDigicode.rRowid           = rowid(tache)
        .
        /* Digicode 2 */
        create ttDigicode.
        assign
            ttDigicode.CRUD             = 'R'
            ttDigicode.iNumeroImmeuble  = piNumeroImmeuble
            ttDigicode.iNumeroDigicode  = tache.noita
            ttDigicode.cTypeContrat     = tache.tpcon
            ttDigicode.iNumeroContrat   = tache.nocon
            ttDigicode.cCodeTypeTache   = tache.tptac
            ttDigicode.iChronoTache     = tache.notac
            ttDigicode.iExtent          = 2
            ttDigicode.cLibelleDigicode = tache.lbdiv2
            ttDigicode.cAncienDigicode  = tache.utreg
            ttDigicode.daDateFin        = tache.dtree
            ttDigicode.cNouveauDigicode = tache.pdreg
            ttDigicode.daDateDebut      = tache.dtreg
            ttDigicode.dtTimestamp      = datetime(tache.dtmsy, tache.hemsy)
            ttDigicode.rRowid           = rowid(tache)
        .
    end.

end procedure.

procedure getCleMagnetique:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations clés magnétiques
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttCleMagnetique.
    define output parameter table for ttCleMagnetiqueDetail.

    define variable viCpUseDet            as integer no-undo.
    define variable viCpUseRem            as integer no-undo.
    define variable viCpUseTot            as integer no-undo.
    define variable vdMtUseTot            as decimal no-undo.
    define variable viContratConstruction as int64   no-undo.

    define buffer tache   for tache.
    define buffer vbTache for tache.
    define buffer ifour   for ifour.
    define buffer vbCle   for ttCleMagnetiqueDetail.

    empty temp-table ttCleMagnetique.
    empty temp-table ttCleMagnetiqueDetail.
    viContratConstruction = getNumeroContratConstruction(piNumeroImmeuble).
    /* Entête : Cle Magnetique */
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viContratConstruction
          and tache.tptac = {&TYPETACHE-cleMagnetiqueEntete}:
        create ttCleMagnetique.
        assign
            ttCleMagnetique.CRUD             = 'R'
            ttCleMagnetique.iNumeroImmeuble  = piNumeroImmeuble
            ttCleMagnetique.iNumeroCle       = tache.noita
            ttCleMagnetique.cTypeContrat     = tache.tpcon
            ttCleMagnetique.iNumeroContrat   = tache.nocon
            ttCleMagnetique.cCodeTypeTache   = tache.tptac
            ttCleMagnetique.iChronoTache     = tache.notac
            ttCleMagnetique.cLibelle1        = tache.tpfin
            ttCleMagnetique.cLibelle2        = tache.ntges
            ttCleMagnetique.cCodeBatiment    = tache.tpges
            ttCleMagnetique.cCodeEntree      = tache.cdhon
            ttCleMagnetique.cCodeEscalier    = tache.tphon
            ttCleMagnetique.cCodeFournisseur = tache.pdges
            ttCleMagnetique.iNombreCle       = tache.duree      /* Nombre Total de clés */
            ttCleMagnetique.dtTimestamp      = datetime(tache.dtmsy, tache.hemsy)
            ttCleMagnetique.rRowid           = rowid(tache)
        .
        for first ifour no-lock
            where ifour.soc-cd   = mtoken:iCodeSociete
              and ifour.four-cle = tache.pdges:
            ttCleMagnetique.cLibelleFournisseur = ifour.nom.
        end.
        /* Détail : Cle Magnetique */
        viCpUseDet = 0.
        for each vbTache no-lock
            where vbTache.tpcon = tache.tpcon
              and vbTache.nocon = tache.nocon
              and vbTache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
              and vbTache.tpges = string(tache.noita):
            create ttCleMagnetiqueDetail.
            assign
                viCpUseDet                               = viCpUseDet + 1
                ttCleMagnetiqueDetail.CRUD               = 'R'
                ttCleMagnetiqueDetail.iNumeroImmeuble    = piNumeroImmeuble
                ttCleMagnetiqueDetail.iNumeroCle         = tache.noita               /* N° Clé parent            */
                ttCleMagnetiqueDetail.iNumeroDetail      = vbTache.noita
                ttCleMagnetiqueDetail.cTypeContrat       = vbTache.tpcon
                ttCleMagnetiqueDetail.iNumeroContrat     = vbTache.nocon
                ttCleMagnetiqueDetail.cCodeTypeTache     = vbTache.tptac
                ttCleMagnetiqueDetail.iChronoTache       = vbTache.notac
                ttCleMagnetiqueDetail.iNumeroTemporaire  = viCpUseDet                  /* N° Temporaire            */
                ttCleMagnetiqueDetail.iNumeroLot         = integer(vbTache.tpfin)
                ttCleMagnetiqueDetail.cNumeroCompte      = vbTache.ntges
                ttCleMagnetiqueDetail.cCodeTypeRole      = vbTache.dcreg
                ttCleMagnetiqueDetail.cLibelleTypeRole   = outilTraduction:getLibelleProg('O_ROL', vbTache.dcreg)
                ttCleMagnetiqueDetail.iNumeroTiers       = vbTache.pdges
                ttCleMagnetiqueDetail.cNomTiers          = vbTache.utreg              /* Nom tiers                */
                ttCleMagnetiqueDetail.iNombrePieceRemise = integer(vbTache.cdreg)     /* Nombre de pièces remises */
                ttCleMagnetiqueDetail.cNumeroSerie       = vbTache.ntreg              /* N° série                 */
                ttCleMagnetiqueDetail.dMontantCaution    = decimal(vbTache.pdreg)     /* Montant de la caution    */
                ttCleMagnetiqueDetail.daDateRemise       = vbTache.dtdeb              /* Date de remise           */
                ttCleMagnetiqueDetail.daDateRestitution  = vbTache.dtfin              /* Date de restitution      */
                ttCleMagnetiqueDetail.cCommentaire       = vbTache.lbdiv              /* Commentaire              */
                ttCleMagnetiqueDetail.dtTimestamp        = datetime(vbTache.dtmsy, vbTache.hemsy)
                ttCleMagnetiqueDetail.rRowid             = rowid(vbTache)
            .
        end.
        viCpUseRem = 0.
        for each ttCleMagnetiqueDetail
           where ttCleMagnetiqueDetail.iNumeroCle = tache.noita
            break by ttCleMagnetiqueDetail.iNumeroTiers:
            if first-of (ttCleMagnetiqueDetail.iNumeroTiers) then assign
                vdMtUseTot = 0
                viCpUseTot = 0
            .
            assign
                vdMtUseTot = vdMtUseTot + ttCleMagnetiqueDetail.dMontantCaution
                viCpUseTot = viCpUseTot + 1
            .
            if last-of (ttCleMagnetiqueDetail.iNumeroTiers)
            then for each vbCle
                where vbCle.iNumeroCle    = tache.noita
                  and vbCle.cNumeroCompte = ttCleMagnetiqueDetail.cNumeroCompte:
                assign
                    vbCle.iNombrePieceTotal = viCpUseTot
                    vbCle.dMontantTotal     = vdMtUseTot
                .
            end.
            if ttCleMagnetiqueDetail.daDateRemise <> ? and ttCleMagnetiqueDetail.daDateRestitution = ?
            then viCpUseRem = viCpUseRem + 1.
        end.
        assign
            ttCleMagnetique.iNombreCleRemise = viCpUseRem                                                    /* Nombre de clés remises       */
            ttCleMagnetique.iNombreCleDispo  = ttCleMagnetique.iNombreCle - ttCleMagnetique.iNombreCleRemise /* Nombre de clé disponibles    */
        .
    end.

end procedure.

procedure getDommageOuvrage:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations dommages ouvrages
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttDommageOuvrage.

    define variable viNumeroContratConstruction as int64 no-undo.
    define buffer tache for tache.
    define buffer batim for batim.

    empty temp-table ttDommageOuvrage.
    viNumeroContratConstruction = getNumeroContratConstruction(piNumeroImmeuble).
    /* Dommage Ouvrage */
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viNumeroContratConstruction
          and tache.tptac = {&TYPETACHE-dommageOuvrage}:
        create ttDommageOuvrage.
        assign
            ttDommageOuvrage.CRUD                = 'R'
            ttDommageOuvrage.iNumeroImmeuble     = piNumeroImmeuble
            ttDommageOuvrage.iNumeroTache        = tache.noita
            ttDommageOuvrage.cTypeContrat        = tache.tpcon
            ttDommageOuvrage.iNumeroContrat      = tache.nocon
            ttDommageOuvrage.cCodeTypeTache      = tache.tptac
            ttDommageOuvrage.iChronoTache        = tache.notac
            ttDommageOuvrage.cPolice             = tache.tpfin
            ttDommageOuvrage.cGarantie           = tache.tphon
            ttDommageOuvrage.iNumeroCompagnie    = integer(tache.ntges)
            ttDommageOuvrage.cNomCompagnie       = outilFormatage:GetNomTiers({&TYPEROLE-compagnie}, ttDommageOuvrage.iNumeroCompagnie)
            ttDommageOuvrage.iNumeroCourtier     = integer(tache.tpges)
            ttDommageOuvrage.cNomCourtier        = outilFormatage:GetNomTiers({&TYPEROLE-courtier}, ttDommageOuvrage.iNumeroCourtier)
            ttDommageOuvrage.cCodeFournisseur    = tache.pdges
            ttDommageOuvrage.cLibelleFournisseur = outilFormatage:GetNomFour("F", integer(tache.pdges))
            ttDommageOuvrage.daDateReception     = tache.dtree
            ttDommageOuvrage.daDateDebut         = tache.dtdeb
            ttDommageOuvrage.daDateFin           = tache.dtfin
            ttDommageOuvrage.cCommentaireTravaux = tache.cdhon
            ttDommageOuvrage.cCodetypeOuvrage    = tache.cdreg
            ttDommageOuvrage.cLibelleTypeOuvrage = outilTraduction:getLibelleParam("TPOUV", tache.cdreg)
            ttDommageOuvrage.cCodeBatiment       = tache.ntreg
            ttDommageOuvrage.dtTimestamp         = datetime(tache.dtmsy, tache.hemsy)
            ttDommageOuvrage.rRowid              = rowid(tache)
        .
        /* Batiment */
        for first batim no-lock
            where batim.noimm = piNumeroImmeuble
              and batim.cdbat = tache.ntreg:
            ttDommageOuvrage.cLibelleBatiment = substitute("&1 - &2", batim.cdbat, batim.Lbbat).
        end.
    end.

end procedure.

procedure getGardien:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations gardien
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttGardien.
    define output parameter table for ttRole.
    define output parameter table for ttHorairesOuvSerie1.
    define output parameter table for ttHorairesOuvSerie2.

    define variable viNumeroContratConstruction as int64   no-undo.
    define variable viCpt                       as integer no-undo.
    define variable vlTrouve                    as logical no-undo.

    define buffer tache  for tache.

    empty temp-table ttGardien.
    empty temp-table ttRole.
    viNumeroContratConstruction = getNumeroContratConstruction(piNumeroImmeuble).
    for each tache no-lock
       where tache.tpcon = {&TYPECONTRAT-construction}
         and tache.nocon = viNumeroContratConstruction
         and tache.tptac = {&TYPETACHE-gardien}:
        create ttGardien.
        {&_proparse_ prolint-nowarn(when)}
        assign
            ttGardien.CRUD            = 'R'
            ttGardien.iNumeroImmeuble = piNumeroImmeuble
            ttGardien.iNumeroTache    = tache.noita
            ttGardien.cTypeContrat    = tache.tpcon
            ttGardien.iNumeroContrat  = tache.nocon
            ttGardien.cCodeTypeTache  = tache.tptac
            ttGardien.iChronoTache    = tache.notac
            ttGardien.cCoordonneeContact1 = entry(1, tache.dcreg, separ[1])
            ttGardien.cCoordonneeContact2 = entry(2, tache.dcreg, separ[1]) when num-entries(tache.dcreg, separ[1]) > 1
            ttGardien.cNomGardien     = tache.tpges when ttGardien.cNomGardien = "" or ttGardien.cNomGardien = ?
            ttGardien.lPrincipal      = tache.fgrev
            ttGardien.cCodeBatiment   = tache.tpfin
            ttGardien.cCodeEntree     = tache.CdHon
            ttGardien.cCodeEscalier   = tache.utreg
            ttGardien.dtTimestamp     = datetime(tache.dtmsy, tache.hemsy)
            ttGardien.rRowid          = rowid(tache)
            vlTrouve                  = true
        .
        /* Creation des horaires d'ouverture gardien */
        createHoraire(buffer ttHorairesOuvSerie1:handle, ttGardien.iNumeroTache, tache.tphon).
        createHoraire(buffer ttHorairesOuvSerie2:handle, ttGardien.iNumeroTache, tache.ntges).
        do viCpt = 1 to 10: // !!! ttGardien.cCommentaire Initialisé à ?
            if num-entries(tache.lbdiv2, separ[1]) >= viCpt then ttGardien.cCommentaire = substitute('&1 &2', ttGardien.cCommentaire, entry(viCpt, tache.lbdiv2, separ[1])).
        end.
        create ttRole.
        assign
            ttGardien.cCommentaire    = trim( ttGardien.cCommentaire, '? ') // Initialisé à ?
            ttRole.iNumeroIdentifiant = tache.noita
            ttRole.cCodeTypeRole      = tache.tprol
            ttRole.iNumeroRole        = tache.norol
            ttRole.cLibelleTypeRole   = outilTraduction:getLibelleProg('O_ROL', tache.tprol)
        .
    end.
    vlTrouve = true. /* TODO Pour le moment, pas de récupération de l'ancienne tâche dans le nouvel onglet*/

    if not vlTrouve
    then for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viNumeroContratConstruction
          and tache.tptac = {&TYPETACHE-loge}
          and num-entries(tache.cdreg) > 1
          and integer(entry(2, tache.cdreg)) <> 0:
        create ttGardien.
        {&_proparse_ prolint-nowarn(when)}
        assign
            ttGardien.CRUD            = 'R'
            ttGardien.iNumeroImmeuble = piNumeroImmeuble
            ttGardien.iNumeroContrat  = tache.nocon
            ttGardien.iNumeroTache    = tache.noita
            ttGardien.iChronoTache    = tache.notac
            ttGardien.cCodeTypeTache  = tache.tptac
            ttGardien.cNomGardien     = tache.tpges when ttGardien.cNomGardien = "" or ttGardien.cNomGardien = ?
            ttGardien.dtTimestamp     = datetime(tache.dtmsy, tache.hemsy)
            ttGardien.rRowid          = rowid(tache)
        .
        /* Creation des horaires d'ouverture gardien à partir de loge */
        createHoraire(buffer ttHorairesOuvSerie1:handle, ttGardien.iNumeroTache, tache.tphon).
        createHoraire(buffer ttHorairesOuvSerie2:handle, ttGardien.iNumeroTache, tache.ntges).
        assign
            ttGardien.cCoordonneeContact1 = entry(1, tache.dcreg, separ[1])
            ttGardien.cCoordonneeContact2 = entry(2, tache.dcreg, separ[1])  when num-entries(tache.dcreg, separ[1]) > 1
            ttGardien.cCommentaire  = trim(entry(1, tache.lbdiv, separ[1])
                                    + substitute(' &1 &2 &3 &4 &5 &6 &7 &8 &9',
                                             if num-entries(tache.lbdiv, separ[1]) > 1 then entry(2, tache.lbdiv, separ[1]) else "",
                                             entry(1, tache.lbdiv2, separ[1]),
                                             if num-entries(tache.lbdiv2, separ[1]) > 1 then entry(2, tache.lbdiv2, separ[1]) else "",
                                             entry(1, tache.lbdiv3, separ[1]),
                                             if num-entries(tache.lbdiv3, separ[1]) > 1 then entry(2, tache.lbdiv3, separ[1]) else "",
                                             if num-entries(tache.lbdiv3, separ[1]) > 2 then entry(3, tache.lbdiv3, separ[1]) else "",
                                             entry(1, tache.lbdiv-dev, separ[1]),
                                             if num-entries(tache.lbdiv-dev, separ[1]) > 1 then entry(2, tache.lbdiv-dev, separ[1]) else "",
                                             if num-entries(tache.lbdiv-dev, separ[1]) > 2 then entry(3, tache.lbdiv-dev, separ[1]) else ""))
            ttGardien.lPrincipal       = true
            vlTrouve                   = true
        no-error.
        create ttRole.
        assign
            ttRole.CRUD               = 'R'
            ttRole.iNumeroIdentifiant = tache.noita
            ttRole.cCodeTypeRole      = tache.tprol
            ttRole.iNumeroRole        = tache.norol
            ttRole.cLibelleTypeRole   = outilTraduction:getLibelleProg('O_ROL', tache.tprol)
            ttRole.dtTimestamp        = datetime(tache.dtmsy, tache.hemsy)
            ttRole.rRowid             = rowid(tache)
        .
    end.
end procedure.

procedure getFichiersJoints:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations fichiers joints
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttFichierJoint.

    define buffer tbfic for tbfic.

    empty temp-table ttFichierJoint.
    for each tbfic no-lock
       where tbfic.tpidt = {&TYPEBIEN-immeuble}
         and tbfic.noidt = piNumeroImmeuble:
        create ttFichierJoint.
        assign
            ttFichierJoint.CRUD            = 'R'
            ttFichierJoint.iNumeroImmeuble = tbfic.noidt                        /* numero d'immeuble                    */
            ttFichierJoint.cNomFichier     = tbfic.lbfic                        /* nom de fichier                       */
            ttFichierJoint.cCommentaire    = tbfic.lbcom                        /* commentaire                          */
            ttFichierJoint.cChemin         = " "                                /* chemin d'acces des nouveaux fichiers */
            ttFichierJoint.daDateCreation  = tbfic.dtcsy                        /* date de creation                     */
            ttFichierJoint.dtTimestamp     = datetime(tbFic.dtmsy, tbFic.hemsy)
            ttFichierJoint.rRowid          = rowid(tbFic)
        .
    end.

end procedure.

procedure getMesureAdministrative:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations mesures administratives
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttMesureAdministrative.

    define variable viNumeroContratConstruction as int64    no-undo.
    define variable vdtTimestamp                as datetime no-undo.
    define buffer tache for tache.

    empty temp-table ttMesureAdministrative.
    viNumeroContratConstruction = getNumeroContratConstruction(piNumeroImmeuble).
    for first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viNumeroContratConstruction
          and tache.tptac = {&TYPETACHE-mesureAdministrative}:
        vdtTimestamp = datetime(tache.dtmsy, tache.hemsy).
        run createMesure(piNumeroImmeuble, tache.noita, tache.tpcon, tache.nocon, tache.tptac, tache.notac, "CdPer", tache.tpfin, 109210, vdtTimestamp).
        run createMesure(piNumeroImmeuble, tache.noita, tache.tpcon, tache.nocon, tache.tptac, tache.notac, "CdIns", tache.ntges, 109211, vdtTimestamp).
        run createMesure(piNumeroImmeuble, tache.noita, tache.tpcon, tache.nocon, tache.tptac, tache.notac, "CdInj", tache.tpges, 109212, vdtTimestamp).
        run createMesure(piNumeroImmeuble, tache.noita, tache.tpcon, tache.nocon, tache.tptac, tache.notac, "CdHis", tache.dcreg, 109213, vdtTimestamp).
        run createMesure(piNumeroImmeuble, tache.noita, tache.tpcon, tache.nocon, tache.tptac, tache.notac, "CdHab", tache.pdges, 111364, vdtTimestamp).
        run createMesure(piNumeroImmeuble, tache.noita, tache.tpcon, tache.nocon, tache.tptac, tache.notac, "CdRav", tache.cdreg, 111365, vdtTimestamp).
        run createMesure(piNumeroImmeuble, tache.noita, tache.tpcon, tache.nocon, tache.tptac, tache.notac, "CdSau", tache.ntreg, 111366, vdtTimestamp).
        run createMesure(piNumeroImmeuble, tache.noita, tache.tpcon, tache.nocon, tache.tptac, tache.notac, "CdCla", tache.pdreg, 111328, vdtTimestamp).
    end.

end procedure.

procedure getConstruction:
    /*------------------------------------------------------------------------------
    Purpose: lecture des informarions correspondant a l'ecran general/construction immeuble
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttImmeuble.

    define variable vhProc as handle no-undo.
    define buffer imble for imble. 

    empty temp-table ttImmeuble.
    /*Lecture de la table des immeubles*/
    for first imble no-lock
        where imble.noimm = piNumeroImmeuble:
        create ttImmeuble.
        ttImmeuble.daDateRenovation = Imble.dtRenov.               /* derniere rénovation */
        run ImmeubleEtLot/imble_crud.p persistent set vhproc.
        run getTokenInstance in vhproc(mToken:JSessionId).
        run readConstruction in vhproc (piNumeroImmeuble, buffer ttImmeuble).
        run destroy in vhproc.
    end.

end procedure.

procedure createMesure private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer   no-undo.
    define input parameter pinoita          as int64     no-undo.
    define input parameter pctpcon          as character no-undo.
    define input parameter pinocon          as int64     no-undo.
    define input parameter pctptac          as character no-undo.
    define input parameter pinotac          as integer   no-undo.
    define input parameter pcCode           as character no-undo.
    define input parameter pcReponse        as character no-undo.
    define input parameter piCodeLibelle    as integer   no-undo.
    define input parameter pdtTimestamp     as datetime  no-undo.

    create ttMesureAdministrative.
    assign
        ttMesureAdministrative.CRUD            = 'R'
        ttMesureAdministrative.iNumeroImmeuble = piNumeroImmeuble
        ttMesureAdministrative.iNumeroTache    = pinoita
        ttMesureAdministrative.cTypeContrat    = pctpcon
        ttMesureAdministrative.iNumeroContrat  = pinocon
        ttMesureAdministrative.cCodeTypeTache  = pctptac
        ttMesureAdministrative.iChronoTache    = pinotac
        ttMesureAdministrative.cCodeReponse    = pcCode
        ttMesureAdministrative.lValeurReponse  = entry(1, pcReponse, separ[1]) = {&oui}
        ttMesureAdministrative.cCommentaire    = entry(2, pcReponse, separ[1]) when num-entries(pcReponse, separ[1]) > 1
        ttMesureAdministrative.iCodeLibelle    = piCodeLibelle
        ttMesureAdministrative.dtTimestamp     = pdtTimestamp
      // Les 2 lignes ci-dessous à laisser à la fin du assign, à cause de error possible !!!
        ttMesureAdministrative.daDateDebut     = date(entry(3, pcReponse, separ[1])) when num-entries(pcReponse, separ[1]) > 2
        ttMesureAdministrative.daDateFin       = date(entry(4, pcReponse, separ[1])) when num-entries(pcReponse, separ[1]) > 3
    no-error.
end procedure.

procedure getAscenseurs:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations des organismes sociaux
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttAscenseur.
    define output parameter table for ttControleTechnique.
    define output parameter table for ttFichierJoint.

    define variable viNumeroContratConstruction as int64  no-undo.
    define variable vhFichierJoint              as handle no-undo.
    define buffer tache for tache.

    empty temp-table ttAscenseur.
    empty temp-table ttControleTechnique.
    empty temp-table ttFichierJoint.

    run immeubleEtLot/fichierJoint.p persistent set vhFichierJoint.
    run getTokenInstance in vhFichierJoint(mToken:JSessionId).

    viNumeroContratConstruction = getNumeroContratConstruction(piNumeroImmeuble).
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viNumeroContratConstruction
          and tache.tptac = {&TYPETACHE-ascenseurs}:
        create ttAscenseur.
        assign
            ttAscenseur.CRUD               = 'R'
            ttAscenseur.iNumeroImmeuble    = piNumeroImmeuble
            ttAscenseur.iNumeroTache       = tache.noita
            ttAscenseur.iChronoTache       = tache.notac
            ttAscenseur.cCodeAscenseur     = tache.ntges
            ttAscenseur.daDateDebut        = tache.dtdeb
            ttAscenseur.cCodeFournisseur   = tache.tpfin
            ttAscenseur.cNomFournisseur    = outilFormatage:GetNomFour('F', int64(tache.tpfin), {&TYPECONTRAT-mandat2Syndic})  // laisser 3 arguments contrairement à ci-dessous
            ttAscenseur.cNumeroSerie       = tache.ntges
            ttAscenseur.cCodeBatiment      = tache.tpges
            ttAscenseur.dtTimestamp        = datetime(tache.dtmsy, tache.hemsy)
            ttAscenseur.rRowid             = rowid(tache)
        .
        run getPJ in vhFichierJoint(
            {&TYPETACHE-ascenseurs},
            int64(string(piNumeroImmeuble, "9999") + string(ttAscenseur.iNumeroTache, if ttAscenseur.iNumeroTache > 99999 then "999999" else "99999")),
            "", output table ttFichierJoint by-reference).
    end.

    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viNumeroContratConstruction
          and tache.tptac = {&TYPETACHE-ctlTechniqueAscenseur}:
        create ttControleTechnique.
        assign
            ttControleTechnique.CRUD                   = 'R'
            ttControleTechnique.iNumeroTache           = tache.noita
            ttControleTechnique.iChronoTache           = tache.notac
            ttControleTechnique.iNUmeroLien            = integer(tache.ntges)
            ttControleTechnique.cCodeFournisseur       = tache.tpfin
            ttControleTechnique.cNomFournisseur        = outilFormatage:GetNomFour("F", integer(tache.tpfin))
            ttControleTechnique.cNomControlleur        = tache.pdreg
            ttControleTechnique.daDateControle         = tache.dtdeb
            ttControleTechnique.cCodeResultat          = tache.tpges
            ttControleTechnique.lTravauxAEffectuer     = (tache.pdges = "00001")
            ttControleTechnique.lTravauxEffectues      = (tache.cdreg = "00001")
            ttControleTechnique.daDateFinTravaux       = tache.dtfin
            ttControleTechnique.daDatePrevue           = tache.dtree
            ttControleTechnique.daDateEffective        = tache.dtreg
            ttControleTechnique.cVisiteCodeResultat    = tache.ntreg
            ttControleTechnique.cCommentaire           = tache.lbdiv
            ttControleTechnique.cLibelleResultat       = if ttControleTechnique.cCodeResultat = "00001" then "+" else if ttControleTechnique.cCodeResultat = "00002" then "-" else ""
            ttControleTechnique.cVisiteLibelleResultat = if ttControleTechnique.cVisiteCodeResultat = "00001" then "+" else if ttControleTechnique.cVisiteCodeResultat = "00002" then "-" else ""
            ttControleTechnique.dtTimestamp            = datetime(tache.dtmsy, tache.hemsy)
            ttControleTechnique.rRowid                 = rowid(tache)
         // La ligne ci-dessous à laisser à la fin du assign, à cause de error possible !!!
            ttControleTechnique.daDateProchainControle = date(tache.utreg)
        no-error.
    end.
    run destroy in vhFichierJoint.
end procedure.

procedure getTravauxManuels:
    /*------------------------------------------------------------------------------
    Purpose : Récupérer les informations travaux manuels
    Notes   : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttTravaux.
    define output parameter table for ttFournisseur.

    define variable viNumeroContratConstruction as int64   no-undo.
    define variable viCpt                       as integer no-undo.
    define buffer tache for tache.

    /* Attention programme persistent, getTravauxManuels appelé après getDossierTravaux, ne pas retirer les empty temp table */
    empty temp-table ttTravaux.
    empty temp-table ttFournisseur.

    viNumeroContratConstruction = getNumeroContratConstruction(piNumeroImmeuble).
    /*--> Travaux Manuels */
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viNumeroContratConstruction
          and tache.tptac = {&TYPETACHE-travauxXXXX3}:
        create ttTravaux.
        assign
            ttTravaux.CRUD                = 'R'
            ttTravaux.iNumeroImmeuble     = piNumeroImmeuble
            ttTravaux.iNumeroTache        = tache.noita
            ttTravaux.cCodeTypeTache      = tache.tptac
            ttTravaux.iChronoTache        = tache.notac
            ttTravaux.iNumeroDossier      = 0
            ttTravaux.daDateAG            = date(tache.dtdeb)
            ttTravaux.daDateDebut         = date(tache.dtree)
            ttTravaux.daDateFin           = date(tache.dtfin)
            ttTravaux.cTypeContrat        = tache.tpfin
            ttTravaux.iNumeroContrat      = tache.duree
            ttTravaux.cLibelleTravaux     = tache.TpGes
            ttTravaux.cCodeTypeTravaux    = tache.NtGes
            ttTravaux.dMontantVote        = tache.MtReg
            ttTravaux.cCodeBatiment       = tache.pdges
            ttTravaux.cLibelleTypeTravaux = outilTraduction:getLibelleParam("TPTRA", tache.ntges)
            ttTravaux.dtTimestamp         = datetime(tache.dtmsy, tache.hemsy)
            ttTravaux.rRowid              = rowid(tache)
         // La ligne ci-dessous à laisser à la fin du assign, à cause de error possible !!!
            ttTravaux.dMontantRealise     = decimal(tache.utreg)
            ttTravaux.iNumeroLien         = integer(tache.cdreg)
        no-error.
        if error-status:error
        then mError:createError(3, 211639, substitute('&2&1&3&1&4&1&5', separ[1], string(piNumeroImmeuble), chr(10), tache.utreg, tache.cdreg)).

        do viCpt = 1 to num-entries(tache.cdhon, "&"):
            create ttFournisseur.
            assign
                ttFournisseur.CRUD                 = 'R'
                ttFournisseur.iNumeroDossier       = 0
                ttFournisseur.iNumeroTache         = tache.noita
                ttFournisseur.cCodeTypeTache       = tache.tptac
                ttFournisseur.iChronoTache         = tache.notac
                ttFournisseur.cTypeContrat         = tache.tpfin
                ttFournisseur.iNumeroContrat       = tache.duree
                ttFournisseur.dtTimestamp          = datetime(tache.dtmsy, tache.hemsy)
                ttFournisseur.rRowid               = rowid(tache)
             // Les 2 lignes ci-dessous à laisser à la fin du assign, à cause de error possible !!!
                ttFournisseur.iNumeroFournisseur   = integer(entry(1, entry(viCpt, tache.cdhon, "&"), "#"))
                ttFournisseur.cNomFournisseur      = outilFormatage:GetNomFour("F", ttFournisseur.iNumeroFournisseur, tache.tpfin)
                ttFournisseur.cAdresseFournisseur  = outilFormatage:getAdresseFour("F", ttFournisseur.iNumeroFournisseur, tache.tpfin)
                ttFournisseur.dMontantVote         = decimal(entry(2, entry(viCpt, tache.cdhon, "&"), "#"))
                ttFournisseur.dMontantRealise      = decimal(entry(3, entry(viCpt, tache.cdhon, "&"), "#"))
            no-error.
        end.
    end.

end procedure.

procedure getDossierTravaux:
    /*------------------------------------------------------------------------------
    Purpose: Récupérer les informations dossier travaux
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttTravaux.
    define output parameter table for ttFournisseur.

    define variable vlExeMth           as logical no-undo.
    define variable viReferenceContrat as integer no-undo.
    define variable vdMtTraVot         as decimal no-undo.
    define variable vdMtTraRea         as decimal no-undo.

    define buffer intnt      for intnt.
    define buffer inter      for inter.
    define buffer trdos      for trdos.
    define buffer csscpt     for csscpt.
    define buffer cecrln     for cecrln.
    define buffer ijou       for ijou.
    define buffer ilibnatjou for ilibnatjou.
    define buffer dtord      for dtord.
    define buffer ordse      for ordse.
    define buffer devis      for Devis.
    define buffer svdev      for svdev.

    run compta/outilsTVA.p persistent set ghProcTva.
    run getTokenInstance in ghProcTva(mToken:JSessionId).
    empty temp-table ttTravaux.
    empty temp-table ttFournisseur.
    for each intnt no-lock
       where intnt.tpidt  = {&TYPEBIEN-immeuble}
         and intnt.noidt  = piNumeroImmeuble
         and (intnt.tpcon = {&TYPECONTRAT-mandat2Gerance} or intnt.tpcon = {&TYPECONTRAT-mandat2Syndic})
      , each trdos no-lock
       where trdos.tpcon = intnt.tpcon
         and trdos.nocon = intnt.nocon:
        create ttTravaux.
        assign
            ttTravaux.CRUD                = 'R'
            ttTravaux.iNumeroTache        = 0
            ttTravaux.cTypeContrat        = trdos.tpcon
            ttTravaux.iNumeroContrat      = trdos.nocon
            ttTravaux.iNumeroImmeuble     = piNumeroImmeuble
            ttTravaux.daDateAG            = date(trdos.dtsig)
            ttTravaux.daDateDebut         = date(trdos.dtdeb)
            ttTravaux.daDateFin           = date(trdos.dtfin)
            ttTravaux.iNumeroDossier      = trdos.nodos
            ttTravaux.cLibelleTravaux     = trdos.LbDos
            ttTravaux.cCodeTypeTravaux    = trdos.tpDos
            ttTravaux.cLibelleTypeTravaux = outilTraduction:getLibelleParam("TPTRA", trdos.tpDos)
            ttTravaux.cCodeBatiment       = entry(1, trdos.lbdiv1, separ[1])
            ttTravaux.dtTimestamp         = datetime(trdos.dtmsy, trdos.hemsy)
            ttTravaux.rRowid              = rowid(trdos)
         // Les 2 lignes ci-dessous à laisser à la fin du assign, à cause de error possible !!!
            ttTravaux.iNumeroLien         = integer(entry(2, trdos.lbdiv1, separ[1])) when num-entries(trdos.lbdiv1, separ[1]) > 1
            viReferenceContrat            = mtoken:getSociete(trdos.tpcon)
        no-error.
        /*--> Prendre les montants comptables des factures */
        for each csscpt no-lock
            where csscpt.soc-cd     = viReferenceContrat
              and csscpt.etab-cd    = intnt.nocon
              and csscpt.sscoll-cle = "FHB":
            for each cecrln no-lock
                where cecrln.soc-cd     = csscpt.soc-cd
                  and cecrln.etab-cd    = intnt.nocon
                  and cecrln.sscoll-cle = "FHB"
                  and cecrln.cpt-cd     = csscpt.cpt-cd
                  and cecrln.affair-num = trdos.nodos // use-index ecrln-consul  // ecrln-aff sinon
              , first ijou no-lock
                where ijou.soc-cd  = cecrln.soc-cd
                  and ijou.etab-cd = cecrln.mandat-cd
                  and ijou.jou-cd  = cecrln.jou-cd:
                find first ilibnatjou no-lock
                    where ilibnatjou.soc-cd    = ijou.soc-cd
                      and ilibnatjou.natjou-cd = ijou.natjou-cd no-error.
                if ijou.natjou-gi <> {&NATJOUGI-odt}
                and available ilibnatjou and not ilibnatjou.treso and (ilibnatjou.achat or ilibnatjou.od)
                then do:
                    find first ttFournisseur
                        where ttFournisseur.iNumeroFournisseur = integer(csscpt.cpt-cd)
                          and ttFournisseur.cTypeContrat       = trdos.tpcon
                          and ttFournisseur.iNumeroContrat     = trdos.nocon
                          and ttFournisseur.iNumeroDossier     = trdos.nodos no-error.
                    if not available ttFournisseur
                    then do:
                        create ttFournisseur.
                        assign
                            ttFournisseur.CRUD                 = 'R'
                            ttFournisseur.iNumeroTache         = 0
                            ttFournisseur.iNumeroFournisseur   = integer(csscpt.cpt-cd)
                            ttFournisseur.cNomFournisseur      = outilFormatage:GetNomFour("F", integer(csscpt.cpt-cd))
                            ttFournisseur.cAdresseFournisseur  = outilFormatage:getAdresseFour("F", integer(csscpt.cpt-cd))
                            ttFournisseur.cTypeContrat         = trdos.tpcon
                            ttFournisseur.iNumeroContrat       = trdos.nocon
                            ttFournisseur.iNumeroDossier       = trdos.nodos
                            ttFournisseur.dMontantVote         = 0
                            ttFournisseur.dMontantRealise      = 0
                            ttFournisseur.dtTimestamp          = datetime(trdos.dtmsy, trdos.hemsy)
                            ttFournisseur.rRowid               = rowid(trdos)
                        .
                    end.
                    ttFournisseur.dMontantRealise = ttFournisseur.dMontantRealise + (if cecrln.sens then - (cecrln.mt + cecrln.mttva) else (cecrln.mt + cecrln.mttva)).
                end.
            end.
        end.

        /* Montant voté = OS ou Réponse Devis */
boucleInter:
        for each inter no-lock
           where inter.tpcon = trdos.tpcon
             and inter.nocon = trdos.nocon
             and inter.nodos = trdos.nodos:
            /*--> Prendre les OS */
            vlExeMth = false.
            for each dtord no-lock
                where dtord.noint = inter.noint
              , first ordse no-lock
                where ordse.noord = dtord.noord:
                vlExeMth = true.
                find first ttFournisseur
                     where ttFournisseur.iNumeroFournisseur = ordse.NoFou
                       and ttFournisseur.cTypeContrat       = trdos.tpcon
                       and ttFournisseur.iNumeroContrat     = trdos.nocon
                       and ttFournisseur.iNumeroDossier     = trdos.nodos no-error.
                if not available ttFournisseur
                then do:
                    create ttFournisseur.
                    assign
                        ttFournisseur.CRUD                 = 'R'
                        ttFournisseur.iNumeroTache         = 0
                        ttFournisseur.iNumeroFournisseur   = ordse.nofou
                        ttFournisseur.cNomFournisseur      = outilFormatage:GetNomFour("F", ttFournisseur.iNumeroFournisseur)
                        ttFournisseur.cAdresseFournisseur  = outilFormatage:getAdresseFour("F", ttFournisseur.iNumeroFournisseur)
                        ttFournisseur.cTypeContrat         = trdos.tpcon
                        ttFournisseur.iNumeroContrat       = trdos.nocon
                        ttFournisseur.iNumeroDossier       = trdos.nodos
                        ttFournisseur.dtTimestamp          = datetime(trdos.dtmsy, trdos.hemsy)
                        ttFournisseur.rRowid               = rowid(trdos)
                    .
                end.
                ttFournisseur.dMontantVote = ttFournisseur.dMontantVote + dynamic-function('calculTTCdepuisHT' in ghProcTVA, dtord.mtint, dtord.cdtva).
            end.
            if vlExeMth then next boucleInter.

            /*--> Sinon prendre les Reponses Devis votées */
            for each svdev no-lock
                where svdev.noint = inter.noint
                  and svdev.fgvot
              , first devis no-lock
                where devis.nodev = svdev.NoDev:
                vlExeMth = true.
                find first ttFournisseur
                     where ttFournisseur.iNumeroFournisseur = devis.NoFou
                       and ttFournisseur.cTypeContrat       = trdos.tpcon
                       and ttFournisseur.iNumeroContrat     = trdos.nocon
                       and ttFournisseur.iNumeroDossier     = trdos.nodos no-error.
                if not available ttFournisseur
                then do:
                    create ttFournisseur.
                    assign
                        ttFournisseur.CRUD                = 'R'
                        ttFournisseur.iNumeroFournisseur  = devis.nofou
                        ttFournisseur.cNomFournisseur     = outilFormatage:GetNomFour("F", ttFournisseur.iNumeroFournisseur)
                        ttFournisseur.cAdresseFournisseur = outilFormatage:getAdresseFour("F", ttFournisseur.iNumeroFournisseur)
                        ttFournisseur.cTypeContrat        = trdos.tpcon
                        ttFournisseur.iNumeroContrat      = trdos.nocon
                        ttFournisseur.iNumeroDossier      = trdos.nodos
                        ttFournisseur.iNumeroTache        = 0
                        ttFournisseur.dtTimestamp         = datetime(trdos.dtmsy, trdos.hemsy)
                        ttFournisseur.rRowid              = rowid(trdos)
                    .
                end.
                ttFournisseur.dMontantVote = ttFournisseur.dMontantVote + dynamic-function('calculTTCdepuisHT' in ghProcTVA, svdev.mtint, svdev.cdtva).
            end.
            if vlExeMth then next boucleInter.
        end.
        // Calcul du montant global des travaux
        assign
            vdMtTraVot = 0
            vdMtTraRea = 0
        .
        for each ttFournisseur
           where ttFournisseur.cTypeContrat   = trdos.tpcon
             and ttFournisseur.iNumeroContrat = trdos.nocon
             and ttFournisseur.iNumeroDossier = trdos.nodos:
            assign
                vdMtTraVot = vdMtTraVot + ttFournisseur.dMontantVote
                vdMtTraRea = vdMtTraRea + ttFournisseur.dMontantRealise
            .
        end.
        assign
            ttTravaux.dMontantvote    = vdMtTraVot
            ttTravaux.dMontantRealise = vdMtTraRea
        .
    end.
    run destroy in ghProcTva.

end procedure.

procedure getContratImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttContratImmeuble.
    define output parameter table for ttMandatImmeuble.
    define output parameter table for ttRoleContrat.
    define output parameter table for ttServiceGestion.
    define output parameter table for ttGestionnaire.
    define output parameter table for ttFichierJoint.

    define variable voPayePegase as class  parametragePayePegase no-undo.
    define variable viNumeroService    as integer no-undo.
    define buffer ctrat for ctrat.

    empty temp-table ttContratImmeuble.
    empty temp-table ttMandatImmeuble.
    empty temp-table ttRoleContrat.
    empty temp-table ttServiceGestion.
    empty temp-table ttGestionnaire.
    empty temp-table ttFichierJoint.
    voPayePegase = new parametragePayePegase().
    run getContrat({&TYPECONTRAT-mandat2Gerance},   piNumeroImmeuble).
    run getContrat({&TYPECONTRAT-bail},             piNumeroImmeuble).
    run getContrat({&TYPECONTRAT-mandat2Syndic},    piNumeroImmeuble).
    run getContrat({&TYPECONTRAT-titre2copro},      piNumeroImmeuble).
    run getContrat({&TYPECONTRAT-assuranceGerance}, piNumeroImmeuble).
    if voPayePegase:iNiveauPaiePegase < 8
    then run getContrat({&TYPECONTRAT-Salarie}, piNumeroImmeuble).
    if voPayePegase:iNiveauPaiePegase >= 2
    then run getContrat({&TYPECONTRAT-SalariePegase}, piNumeroImmeuble).
    delete object voPayePegase.
    run getContrat({&TYPECONTRAT-fournisseur}, piNumeroImmeuble).

    /* Ajout SY le 17/12/2009 - 0309/0042 : Maj gestionnaire */
    for each ttContratImmeuble:
        viNumeroService = donneNumeroServiceContrat(ttContratImmeuble.cTypeContrat, ttContratImmeuble.iNumeroContrat).
        if viNumeroService <> 0
        then for first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-serviceGestion}
              and ctrat.nocon = viNumeroService:
            create ttServiceGestion.
            assign
                ttServiceGestion.CRUD            = 'R'
                ttServiceGestion.iNumeroImmeuble = piNumeroImmeuble
                ttServiceGestion.iNumeroContrat  = ttContratImmeuble.iNumeroContrat
                ttServiceGestion.cTypeContrat    = ttContratImmeuble.cTypeContrat
                ttServiceGestion.cNumeroService  = string(viNumeroService, "99999")
                ttServiceGestion.cNomService     = ctrat.noree
                ttServiceGestion.dtTimestamp     = datetime(ctrat.dtmsy, ctrat.hemsy)
                ttServiceGestion.rRowid          = rowid(ctrat)
            .
            create ttGestionnaire.
            assign
                ttGestionnaire.CRUD                = 'R'
                ttGestionnaire.iNumeroImmeuble     = piNumeroImmeuble
                ttGestionnaire.iNumeroContrat      = ttContratImmeuble.iNumeroContrat
                ttGestionnaire.cTypeContrat        = ttContratImmeuble.cTypeContrat
                ttGestionnaire.cNumeroGestionnaire = string(ctrat.nocon, "99999")
                ttGestionnaire.cNomGestionnaire    = outilFormatage:GetNomTiers(ctrat.tprol, ctrat.norol)
                ttGestionnaire.dtTimestamp         = datetime(ctrat.dtmsy, ctrat.hemsy)
                ttGestionnaire.rRowid              = rowid(ctrat)
            .
        end.
    end.

end procedure.

procedure getContrat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat    as character no-undo.
    define input parameter piNumeroImmeuble as integer   no-undo.

    define variable viNbNumUse     as integer   no-undo.
    define variable viNbDenUse     as integer   no-undo.
    define variable vdaVenUse      as date      no-undo.
    define variable vdaAchUse      as date      no-undo.
    define variable vdaFinUse      as date      no-undo.
    define variable vlCopAct       as logical   no-undo.
    define variable vdaReeUse      as date      no-undo.
    define variable vcDummy        as character no-undo.
    define variable vhFichierJoint as handle    no-undo.

    define buffer tache   for tache.
    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer ctctt   for ctctt.
    define buffer ctrat   for ctrat.
    define buffer vbCtrat for ctrat.
    define buffer salar   for salar.

    case pcTypeContrat:
        when {&TYPECONTRAT-assuranceGerance}                                // Assurances immeuble
     or when {&TYPECONTRAT-assuranceSyndic} then for each intnt no-lock
            where (intnt.tpcon = {&TYPECONTRAT-mandat2Syndic} or intnt.tpcon = {&TYPECONTRAT-mandat2Gerance})
              and intnt.tpidt  = {&TYPEBIEN-immeuble}
              and intnt.noidt  = piNumeroImmeuble
          , first vbCtrat no-lock
            where vbCtrat.tpcon = intnt.tpcon
              and vbCtrat.nocon = intnt.nocon
          , each ctctt no-lock
            where ctctt.tpct1 = intnt.tpcon
              and ctctt.noct1 = intnt.nocon
              and (ctctt.tpct2 = {&TYPECONTRAT-assuranceGerance} or ctctt.tpct2 = {&TYPECONTRAT-assuranceSyndic})
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2:
            find first ttContratImmeuble
                where ttContratImmeuble.cTypeContrat    = ctrat.tpcon
                  and ttContratImmeuble.iNumeroContrat  = ctrat.nocon
                  and ttContratImmeuble.iNumeroImmeuble = piNumeroImmeuble  no-error.
            if not available ttContratImmeuble
            then do:
                create ttContratImmeuble.
                assign
                    ttContratImmeuble.CRUD            = 'R'
                    ttContratImmeuble.cTypeContrat    = ctrat.tpcon
                    ttContratImmeuble.iNumeroContrat  = ctrat.nocon
                    ttContratImmeuble.iNumeroImmeuble = piNumeroImmeuble
                    ttContratImmeuble.dtTimestamp     = datetime(ctrat.dtmsy, ctrat.hemsy)
                    ttContratImmeuble.rRowid          = rowid(ctrat)
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
                    ttRoleContrat.rRowid           = rowid(ctrat)
                .
            end.
            assign
                ttContratImmeuble.cLibelleContrat = "AS"
                ttContratImmeuble.daDateDebut     = ctrat.dtdeb
                ttContratImmeuble.daDateFin       = ctrat.dtfin
                ttContratImmeuble.daResiliation   = ctrat.dtree
                ttContratImmeuble.cNatureContrat  = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
                ttContratImmeuble.lPresent        = (ctrat.dtree = ? or ctrat.dtree > today)
                ttContratImmeuble.dtTimestamp     = datetime(ctrat.dtmsy, ctrat.hemsy)
                ttContratImmeuble.rRowid          = rowid(ctrat)
            .
        end.

        when {&TYPECONTRAT-titre2copro} then for each vbIntnt no-lock
            where vbIntnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
              and vbIntnt.tpidt = {&TYPEBIEN-immeuble}
              and vbIntnt.noidt = piNumeroImmeuble
          , first vbCtrat no-lock
            where vbCtrat.tpcon = vbIntnt.tpcon
              and vbCtrat.nocon = vbIntnt.nocon
          , each ctctt no-lock
            where ctctt.tpct1 = vbIntnt.tpcon
              and ctctt.noct1 = vbIntnt.nocon
              and ctctt.tpct2 = {&TYPECONTRAT-titre2copro}
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2:
            assign
                vlCopAct = false
                viNbNumUse = 99999999
                viNbDenUse = 0
                vdaAchUse = ?
                vdaVenUse = ?
            .
            /* Ajout Sy le 03/11/2011 : Gestion des RIE - prendre les dates de rattachement de l'entreprise */
            if vbCtrat.ntcon = {&NATURECONTRAT-restaurantInterEntreprise}
            then assign
                vdaAchUse = ctrat.dtdeb
                vdaVenUse = ctrat.dtfin
            .
            else do:
                for each intnt no-lock
                    where intnt.tpcon = ctrat.tpcon
                      and intnt.nocon = ctrat.nocon
                      and intnt.tpidt = {&TYPEBIEN-lot}:
                    if intnt.nbden = 0 then vlCopAct = true.
                    assign
                        viNbNumUse = if intnt.nbnum > 0 then minimum(viNbNumUse, intnt.nbnum) else viNbNumUse
                        viNbDenUse = maximum(viNbDenUse, intnt.nbden)
                    .
                end.
                /*--> Si tout les lots du coproprietaire sont vendus on valorise la date de fin */
                if not vlCopAct then do:
                    if viNbDenUse <> 0 then do:
                        assign
                            vcDummy   = string(viNbDenUse)
                            vcDummy   = substitute('&1/&2/&3', substring(vcDummy, 7, 2, 'character'), substring(vcDummy, 5, 2, 'character'), substring(vcDummy, 1, 4, 'character'))
                            vdaVenUse = date(vcDummy)
                        no-error.
                        if error-status:error then do:
                            mError:createError(3, 211637, vcDummy).
                            vdaVenUse = ?.
                        end.
                    end.
                    else vdaVenUse = (if ctrat.dtree <> ? then ctrat.dtree else today). /* 1109/0068 - aucun lot */
                end.
                /*--> On prend la plus petite d'achat des lots du copro */
                if viNbNumUse <> 0 and viNbNumUse <> 99999999 then do:
                    assign
                        vcDummy   = string(viNbNumUse)
                        vcDummy   = substitute('&1/&2/&3', substring(vcDummy, 7, 2, 'character'), substring(vcDummy, 5, 2, 'character'), substring(vcDummy, 1, 4, 'character'))
                        vdaAchUse = date(vcDummy)
                    no-error.
                    if error-status:error
                    then do:
                        mError:createError(3, 211638, vcDummy).
                        vdaAchUse = ?.
                    end.
                end.
            end.
            /* Ajout SY le 31/03/2010 - fiche 0310/0196 : Si mandat syndic résilié alors tous les Titres de copro associés aussi  */
            if vbCtrat.dtree <> ? and vdaVenUse = ? then vdaVenUse = vbCtrat.dtree.
            find first ttContratImmeuble
                where ttContratImmeuble.cTypeContrat    = ctrat.tpcon
                  and ttContratImmeuble.iNumeroContrat  = ctrat.nocon
                  and ttContratImmeuble.iNumeroImmeuble = piNumeroImmeuble no-error.
            if not available ttContratImmeuble
            then do:
                create ttContratImmeuble.
                assign
                    ttContratImmeuble.CRUD            = 'R'
                    ttContratImmeuble.cTypeContrat    = ctrat.tpcon
                    ttContratImmeuble.iNumeroContrat  = ctrat.nocon
                    ttContratImmeuble.iNumeroImmeuble = piNumeroImmeuble
                    ttContratImmeuble.dtTimestamp     = datetime(ctrat.dtmsy, ctrat.hemsy)
                    ttContratImmeuble.rRowid          = rowid(ctrat)
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
                    ttRoleContrat.rRowid           = rowid(ctrat)
                .
            end.
            assign
                ttContratImmeuble.cLibelleContrat = "TI"
                ttContratImmeuble.daDateDebut     = (if vdaAchUse <> ? then vdaAchUse else ctrat.dtdeb)
                ttContratImmeuble.daDateFin       = ?
                ttContratImmeuble.daResiliation   = vdaVenUse
                ttContratImmeuble.cNatureContrat  = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
                ttContratImmeuble.lPresent        = (vdaVenUse = ? or vdaVenUse > today)
            .
        end.

        when {&TYPECONTRAT-fournisseur} then for each intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-Immeuble}
              and intnt.noidt = piNumeroImmeuble
              and intnt.TpCon = pcTypeContrat
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon
          , last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-fournisseur}
          , first ctctt no-lock
            where ctctt.tpct2 = ctrat.tpcon
              and ctctt.noct2 = ctrat.nocon:
            run createContratFournisseur(piNumeroImmeuble , integer(mtoken:cRefPrincipale), buffer ctrat , buffer tache, buffer ctctt, buffer ttContratImmeuble).
            run immeubleEtLot/fichierJoint.p persistent set vhFichierJoint.
            run getTokenInstance in vhFichierJoint(mToken:JSessionId).
            run getPJ in vhFichierJoint(
                    {&TYPETACHE-fournisseur},
                    int64(string(piNumeroImmeuble, "9999") + string(ttContratImmeuble.iNumeroContrat, if ttContratImmeuble.iNumeroContrat > 99999 then "999999" else "99999")),
                    'ctratfou', output table ttFichierJoint by-reference).
            run destroy in vhFichierJoint.
        end.

        otherwise for each intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.noidt = piNumeroImmeuble
              and intnt.tpcon = pcTypeContrat
          , first ctrat no-lock
            where ctrat.tpcon = intnt.tpcon
              and ctrat.nocon = intnt.nocon
              and ctrat.ntcon <> {&NATURECONTRAT-specialVacant}:
            vdaFinUse = ctrat.dtfin.
            for last tache no-lock
                where tache.tpcon = ctrat.tpcon
                  and tache.nocon = ctrat.nocon
                  and tache.tptac = {&TYPETACHE-renouvellement}
                  and Tache.tpfin <> "50":
                vdaFinUse = tache.dtfin.
            end.
            vdaReeUse = ctrat.dtree.
            if pcTypeContrat = {&TYPECONTRAT-salarie}
            then for first salar no-lock
                where salar.tprol = {&TYPEROLE-salarie}
                  and salar.norol = ctrat.nocon:
                vdaReeUse = salar.dtsor.
            end.
            else if pcTypeContrat = {&TYPECONTRAT-salariePegase}
            then for first salar no-lock
                where salar.tprol = {&TYPEROLE-salariePegase}
                  and salar.norol = ctrat.nocon:
                vdaReeUse = salar.dtsor.
            end.
            /* Information Bail proportionnel si nécessaire */
            find first tache no-lock
                where tache.tpcon = ctrat.tpcon
                  and tache.nocon = ctrat.nocon
                  and tache.tptac = {&TYPETACHE-bailProportionnel} no-error.
            find first ttContratImmeuble
                where ttContratImmeuble.cTypeContrat    = ctrat.tpcon
                  and ttContratImmeuble.iNumeroContrat  = ctrat.nocon
                  and ttContratImmeuble.iNumeroImmeuble = piNumeroImmeuble no-error.
            if not available ttContratImmeuble
            then do:
                create ttContratImmeuble.
                assign
                    ttContratImmeuble.CRUD            = 'R'
                    ttContratImmeuble.cTypeContrat    = ctrat.tpcon
                    ttContratImmeuble.iNumeroContrat  = ctrat.nocon
                    ttContratImmeuble.iNumeroImmeuble = piNumeroImmeuble
                    ttContratImmeuble.dtTimestamp     = datetime(ctrat.dtmsy, ctrat.hemsy)
                    ttContratImmeuble.rRowid          = rowid(ctrat)
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
                    ttRoleContrat.rRowid           = rowid(ctrat)
                .
            end.
            assign
                ttContratImmeuble.daDateDebut    = ctrat.dtdeb
                ttContratImmeuble.daDateFin      = vdaFinUse
                ttContratImmeuble.daResiliation  = vdaReeUse
                ttContratImmeuble.cNatureContrat = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon) + (if available tache then " (BP)" else "")
                ttContratImmeuble.lPresent       = (vdaReeUse = ? or vdaReeUse > today)
                ttContratImmeuble.lProvisoire    = (if ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance} then ctrat.fgprov else no)  /* 0706/0018 */
            .
            if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} or pcTypeContrat = {&TYPECONTRAT-mandat2Syndic}
            then do:
                create ttMandatImmeuble.
                assign
                    ttMandatImmeuble.CRUD              = 'R'
                    ttMandatImmeuble.iNumeroImmeuble   = piNumeroImmeuble
                    ttMandatImmeuble.iNumeroContrat    = ttContratImmeuble.iNumeroContrat
                    ttMandatImmeuble.cTypeContrat      = ttContratImmeuble.cTypeContrat
                    ttMandatImmeuble.cTypeMandat       = ctrat.tpcon
                    ttMandatImmeuble.iNumeroMandat     = ctrat.nocon
                    ttMandatImmeuble.cCodeNatureMandat = ctrat.ntcon
                    ttMandatImmeuble.dtTimestamp       = datetime(ctrat.dtmsy, ctrat.hemsy)
                    ttMandatImmeuble.rRowid            = rowid(ctrat)
                .
            end.
            else if pcTypeContrat = {&TYPECONTRAT-bail}
            then for first vbCtrat no-lock
                where vbCtrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                  and vbCtrat.nocon = integer(substring(string(intnt.nocon, "9999999999"), 1, 5, 'character')):
                create ttMandatImmeuble.
                assign
                    ttMandatImmeuble.CRUD              = 'R'
                    ttMandatImmeuble.iNumeroImmeuble   = piNumeroImmeuble
                    ttMandatImmeuble.iNumeroContrat    = ttContratImmeuble.iNumeroContrat
                    ttMandatImmeuble.cTypeContrat      = ttContratImmeuble.cTypeContrat
                    ttMandatImmeuble.cTypeMandat       = ctrat.tpcon
                    ttMandatImmeuble.iNumeroMandat     = ctrat.nocon
                    ttMandatImmeuble.cCodeNatureMandat = ctrat.ntcon
                    ttMandatImmeuble.dtTimestamp       = datetime(ctrat.dtmsy, ctrat.hemsy)
                    ttMandatImmeuble.rRowid            = rowid(ctrat)
                .
            end.
            if trim(ttMandatImmeuble.cCodeNatureMandat) > ""
            then ttMandatImmeuble.cLibelleNatureMandat = outilTraduction:getLibelleProg("O_COT", ttMandatImmeuble.cCodeNatureMandat).

            case pcTypeContrat:
                when {&TYPECONTRAT-bail} then do:
                    ttContratImmeuble.cLibelleContrat = "BA".
                    /* BI = Bail Investisseur (mandat location, location indivision, location déléguée) */
                    if lookup(quoter(ttMandatImmeuble.cCodeNatureMandat), '{&NATURECONTRAT-mandatLocation},{&NATURECONTRAT-mandatLocationDelegue},{&NATURECONTRAT-mandatLocationIndivision}') > 0
                    then ttContratImmeuble.cLibelleContrat = "BI". /* 1212/0073 */
                end.
                when {&TYPECONTRAT-Salarie}        then ttContratImmeuble.cLibelleContrat = "SA".
                when {&TYPECONTRAT-SalariePegase}  then ttContratImmeuble.cLibelleContrat = "SP".
                when {&TYPECONTRAT-mandat2Gerance} then ttContratImmeuble.cLibelleContrat = "MG".
                when {&TYPECONTRAT-mandat2Syndic}  then ttContratImmeuble.cLibelleContrat = "MS".
            end case.
        end.
    end case.
    /* Ajout des infos complémentaires */
    for each ttContratImmeuble:
        run donneesComplementaires(ttContratImmeuble.cTypeContrat, ttContratImmeuble.iNumeroContrat, output ttContratImmeuble.cInfoComplementaire).
    end.

end procedure.

procedure createContratFournisseur private:
    /*------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.
    define input parameter piReference      as integer no-undo.
    define parameter buffer ctrat for ctrat.
    define parameter buffer tache for tache.
    define parameter buffer ctctt for ctctt.
    define parameter buffer ttContratImmeuble for ttContratImmeuble.

    define variable voCarnetEntretien as class parametrageCarnetEntretien no-undo.

    define buffer ccptcol for ccptcol.
    define buffer ifour   for ifour.

    find first ttContratImmeuble
        where ttContratImmeuble.cTypeContrat    = ctrat.tpcon
          and ttContratImmeuble.iNumeroContrat  = ctrat.nocon
          and ttContratImmeuble.iNumeroImmeuble = piNumeroImmeuble no-error.
    if not available ttContratImmeuble
    then do:
        create ttContratImmeuble.
        assign
            ttContratImmeuble.CRUD            = 'R'
            ttContratImmeuble.cTypeContrat    = ctrat.tpcon
            ttContratImmeuble.iNumeroContrat  = ctrat.nocon
            ttContratImmeuble.iNumeroImmeuble = piNumeroImmeuble
            ttContratImmeuble.dtTimestamp     = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttContratImmeuble.rRowid          = rowid(ctrat)
        .
        create ttRoleContrat.
        assign
            ttRoleContrat.CRUD             = 'R'
            ttRoleContrat.iNumeroContrat   = ctrat.nocon
            ttRoleContrat.cTypeContrat     = ctrat.tpcon
            ttRoleContrat.iNumeroRole      = Ctrat.norol
            ttRoleContrat.cCodeTypeRole    = "FOU"
            ttRoleContrat.cLibelleTypeRole = ctrat.lbnom
            ttRoleContrat.dtTimestamp      = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttRoleContrat.rRowid           = rowid(ctrat)
        .
    end.
    assign
        ttContratImmeuble.cLibelleContrat    = "FO"
        ttContratImmeuble.daDateDebut        = tache.dtdeb
        ttContratImmeuble.daDateFin          = tache.dtfin
        ttContratImmeuble.daResiliation      = ctrat.dtree
        ttContratImmeuble.cReferenceContrat  = ctrat.noree
        ttContratImmeuble.cDivers            = tache.cdhon + "#" + ctctt.tpct1
        ttContratImmeuble.lPresent           = (Ctrat.dtree = ? or ctrat.dtree > today)
        ttContratImmeuble.iNumeroFournisseur = ctrat.norol
        ttContratImmeuble.cNatureContrat     = outilTraduction:getLibelleProg("O_COT", ctrat.ntcon)
    .
    /*--> Objet du contrat */
    if num-entries(ctrat.lbdiv, "#") >= 4
    then do:
        voCarnetEntretien = new parametrageCarnetEntretien(?, entry(3, ctrat.lbdiv, "#"), entry(4, ctrat.lbdiv, "#")).
        if voCarnetEntretien:isDbParameter
        then ttContratImmeuble.cNatureContrat = voCarnetEntretien:getNatureContrat().
    end.
    /*--> Nom du fournisseur comptable */
    for first ccptcol no-lock
        where ccptcol.tprol  = 12
          and ccptcol.soc-cd = piReference
      , first ifour no-lock
        where ifour.soc-cd   = ccptcol.soc-cd
          and ifour.coll-cle = ccptcol.coll-cle
          and ifour.cpt-cd   = string(ctrat.NoRol, "99999"):
        assign
            ttRoleContrat.cLibelleTypeRole    = trim(ifour.nom)
            ttContratImmeuble.cNomFournisseur = trim(ifour.nom)
        .
    end.
end procedure.

procedure getContratFournisseurParMandat:
    /*------------------------------------------------------------------------
    Purpose:
    Notes  : service appelé par beImmeuble.cls
    ------------------------------------------------------------------------*/
    define input parameter piReference    as integer   no-undo.
    define input parameter piNumeroMandat as integer   no-undo.
    define input parameter plResilie      as logical   no-undo.
    define output parameter table for ttContratImmeuble.

    define variable vlGerance     as logical   no-undo.
    define variable vlCopropriete as logical   no-undo.

    define buffer ietab   for ietab.
    define buffer intnt   for intnt.
    define buffer ctctt   for ctctt.
    define buffer ctrat   for ctrat.
    define buffer tache   for tache.
    define buffer vbCtrat for ctrat.

    empty temp-table ttContratImmeuble. // créé par createContratFournisseur
    empty temp-table ttRoleContrat.     // créé par createContratFournisseur (pas utilisée par le service)
    /* Ref de Gerance et/ou copro ? */
    assign
        vlGerance     = (integer(mtoken:cRefGerance) = piReference)
        vlCopropriete = (integer(mtoken:cRefCopro)   = piReference)
    .
    /*--> Chargement des contrats fournisseurs du mandat */
    for first ietab no-lock
        where ietab.Soc-cd = piReference
          and ietab.etab-cd = piNumeroMandat
          and (if vlGerance and not vlCopropriete
               then ietab.profil-cd = 21
               else if vlCopropriete and not vlGerance
                    then ietab.profil-cd = 91
                    else ietab.profil-cd modulo 10 <> 0)
          , each ctctt no-lock
            where ctctt.tpct1 = (if ietab.profil-cd = 91 then {&TYPECONTRAT-mandat2Syndic} else if ietab.profil-cd = 21 then {&TYPECONTRAT-mandat2Gerance} else ?)
              and ctctt.noct1 = piNumeroMandat
              and ctctt.tpct2 = {&TYPECONTRAT-fournisseur}
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2
              and (ctrat.dtree = ? or ctrat.dtree > today or plresilie)
          , last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-fournisseur}
          , first intnt no-lock
            where intnt.tpcon = ctctt.tpct1
              and intnt.nocon = ctctt.noct1
              and intnt.tpidt = {&TYPEBIEN-immeuble}
          , first vbCtrat no-lock
            where vbCtrat.tpcon = ctctt.tpct1
              and vbCtrat.nocon = ctctt.noct1:
            run createContratFournisseur(intnt.noidt, piReference, buffer ctrat , buffer tache, buffer ctctt, buffer ttContratImmeuble).
    end. /* for each */
end procedure.


procedure donneesComplementaires private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter piNumeroContrat as integer   no-undo.
    define output parameter pcInfos         as character no-undo.

    define variable vcTempo     as character no-undo.
    define variable vcTempo1    as character no-undo.
    define variable vcTelephone as character no-undo.
    define buffer intnt for intnt.

    case pcTypeContrat:
        when {&TYPECONTRAT-assuranceGerance} or when {&TYPECONTRAT-assuranceSyndic}
        then for first intnt no-lock            /* récupération du courtier */
            where intnt.tpcon = pcTypeContrat
              and intnt.nocon = piNumeroContrat
              and intnt.tpidt = {&TYPEROLE-courtier}:
            assign
                vcTempo     = outilFormatage:GetNomTiers(intnt.tpidt, intnt.noidt)
                vcTelephone = donneTelephone(intnt.tpidt, intnt.noidt, "00001")
            .
            if vcTempo > "" then pcInfos = substitute("&1: &2", outilTraduction:getLibelle(701057), vcTempo).    /* 701057: "Courtier" */
            if num-entries(vcTelephone, separ[1]) > 2 then vcTempo = entry(3, vcTelephone, separ[1]).
            if vcTempo > "" then vcTempo = substitute("&1&2", outilTraduction:getLibelle(102929), vcTempo).      /* 102929: "Tél. :"   */
            if vcTempo1 > "" then vcTempo1 = substitute("&1: &2", outilTraduction:getLibelle(111442), vcTempo1). /* 111442: "Email"    */
            if vcTempo > "" or vcTempo1 > ""
            then pcInfos = substitute('&1 (&2&3)', pcInfos, vcTempo, if vcTempo > "" and vcTempo1 > "" then ' / ' + vcTempo1 else vcTempo1).
        end.
    end case.

end procedure.

procedure getCombo:
    /*------------------------------------------------------------------------------
    Purpose: Récupère les combos
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer   no-undo.
    define input  parameter pcComboFilter    as character no-undo.
    define output parameter table for ttCombo.

    define variable viNumeroCombo as integer   no-undo.
    define variable vcNomCombo    as character no-undo.

    empty temp-table ttCombo.
    giNumeroItem = 0.
    do viNumeroCombo = 1 to num-entries(pcComboFilter, ","):
        vcNomCombo = entry(viNumeroCombo, pcComboFilter, ",").
        case vcNomCombo:
            when "CMBBATIMENT"         then run getComboBatiment (piNumeroImmeuble).
            when "CMBENTREE"           then run getComboEntree (piNumeroImmeuble).
            when "CMBESCALIER"         then run getComboEscalier (piNumeroImmeuble).
            when "CMBIMMEUBLEBATIMENT" then run getComboImmeubleBatiment (piNumeroImmeuble).
            when "CMBTYPEMOYEN"        then run getComboTypeMoyenCommunication (piNumeroImmeuble).
            when "CMBLIBELLEMOYEN"     then run getComboLibelleMoyenCommunication (piNumeroImmeuble).
            when "CMBMANDAT"           then run getComboMandatImmeuble (piNumeroImmeuble).
        end case.
    end.

end procedure.

procedure getComboImmeubleBatiment private:
    /*------------------------------------------------------------------------------
    Purpose: Récupère la liste des batiments d'un immeuble
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.

    define buffer batim for batim.

    create ttCombo.
    assign
        giNumeroItem      = giNumeroItem + 1
        ttCombo.iSeqId    = giNumeroItem
        ttCombo.cNomCombo = "CMBIMMEUBLEBATIMENT"
        ttCombo.cCode     = string(piNumeroImmeuble)
        ttCombo.cLibelle  = outilTraduction:getLibelle(101206) // "IMMEUBLE"
        ttCombo.cLibelle2 = string(piNumeroImmeuble)
        ttCombo.cLibelle3 = {&TYPEBIEN-immeuble}
    .
    for each batim no-lock
        where batim.noimm = piNumeroImmeuble:
        create ttCombo.
        assign
            giNumeroItem      = giNumeroItem + 1
            ttCombo.iSeqId    = giNumeroItem
            ttCombo.cNomCombo = "CMBIMMEUBLEBATIMENT"
            ttCombo.cCode     = batim.cdbat
            ttCombo.cLibelle  = batim.LbBat
            ttCombo.cLibelle2 = string(batim.nobat)
            ttCombo.cLibelle3 = {&TYPEBIEN-batiment}
        .
    end.

end procedure.

procedure getComboBatiment private:
    /*------------------------------------------------------------------------------
    Purpose: Récupère la liste des batiments d'un immeuble
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.

    define buffer batim for batim.

    for each batim no-lock
        where batim.noimm = piNumeroImmeuble:
        create ttCombo.
        assign
            giNumeroItem      = giNumeroItem + 1
            ttCombo.iSeqId    = giNumeroItem
            ttCombo.cNomCombo = "CMBBATIMENT"
            ttCombo.cCode     = batim.cdbat
            ttCombo.cLibelle  = batim.LbBat
            ttCombo.cLibelle2 = string(batim.nobat)
            ttCombo.cLibelle3 = {&TYPEBIEN-batiment}
        .
    end.

end procedure.

procedure getComboEntree private:
    /*------------------------------------------------------------------------------
    Purpose: Récupère la liste des entrees d'un immeuble
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.

    define buffer local for local.

    for each local no-lock
        where local.noimm = piNumeroImmeuble
        break by local.lbdiv:
        if first-of(local.lbdiv) then do:
            create ttCombo.
            assign
                giNumeroItem      = giNumeroItem + 1
                ttCombo.iSeqId    = giNumeroItem
                ttCombo.cNomCombo = "CMBENTREE"
                ttCombo.cCode     = local.lbdiv
                ttCombo.cLibelle  = local.lbdiv
            .
        end.
    end.

end procedure.

procedure getComboEscalier private:
    /*------------------------------------------------------------------------------
    Purpose: Récupère la liste des escaliers d'un immeuble
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble as integer no-undo.

    define buffer local for local.

    for each local no-lock
        where local.noimm = piNumeroImmeuble
        break by local.cdesc:
        if first-of(local.cdesc) then do:
            create ttCombo.
            assign
                giNumeroItem      = giNumeroItem + 1
                ttCombo.iSeqId    = giNumeroItem
                ttCombo.cNomCombo = "CMBESCALIER"
                ttCombo.cCode     = local.cdesc
                ttCombo.cLibelle  = local.cdesc
            .
        end.
    end.

end procedure.

procedure getComboMandatImmeuble private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define variable viContrat as int64 no-undo.
    define buffer tache for tache.
    define buffer intnt for intnt.
    define buffer trdos for trdos.

    // TRAVAUX MANUELS
    viContrat = getNumeroContratConstruction(piNumeroImmeuble).  // éviter l'utilisation UDF dans une clause where
    for each tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.nocon = viContrat
          and tache.tptac = {&TYPETACHE-travauxXXXX3}:
        create ttCombo.
        assign
            giNumeroItem      = giNumeroItem + 1
            ttCombo.iSeqId    = giNumeroItem
            ttCombo.cNomCombo = "CMBMANDAT"
            ttCombo.cCode     = string(tache.duree) // Numéro de mandat
            ttCombo.cLibelle  = outilTraduction:getLibelleParam("TPTRA", tache.ntges)  // Type de travaux
        .
    end.

    // DOSSIER TRAVAUX
    for each intnt no-lock
        where intnt.tpidt  = {&TYPEBIEN-immeuble}
          and intnt.noidt  = piNumeroImmeuble
          and (intnt.tpcon = {&TYPECONTRAT-mandat2Gerance} or intnt.tpcon = {&TYPECONTRAT-mandat2Syndic})
      , each TrDos no-lock
        where trdos.tpcon = intnt.tpcon
          and trdos.nocon = intnt.nocon:
        create ttCombo.
        assign
            giNumeroItem      = giNumeroItem + 1
            ttCombo.iSeqId    = giNumeroItem
            ttCombo.cNomCombo = "CMBMANDAT"
            ttCombo.cCode     = string(trdos.nocon) // Numéro de mandat
            ttCombo.cLibelle  = trdos.LbDos         // Libelle travaux
        .
    end.

end procedure.

/*TODO: début de validation*/
procedure setImmeuble:
    /*------------------------------------------------------------------------------
    Purpose: validation immeuble
    Notes  : service utilisé par beImmeuble.cls
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phtt.

    define variable vhProcImbleExt as handle no-undo.
    define variable vhBuffer       as handle no-undo.
    define variable vhQuery        as handle no-undo.
    define variable vhField        as handle no-undo.
    define variable vhConstruction as handle no-undo.
    define variable vhFinContrat   as handle no-undo.
    define variable vhPromoteur    as handle no-undo.
    define variable vhArchitecte   as handle no-undo.

    define buffer intnt   for intnt.
    define buffer vbIntnt for intnt.
    define buffer ctrat   for ctrat.

    vhBuffer = phtt:default-buffer-handle.
    create query vhQuery.
    vhQuery:set-buffers(vhBuffer).
    vhQuery:query-prepare(substitute('for each &1', vhBuffer:name)).
    vhQuery:query-open().

    run immeubleEtLot/imble_crud.p persistent set vhProcImbleExt.
    run getTokenInstance in vhProcImbleExt (mToken:JSessionId).
blocTransaction:
    do transaction:
blocRepeat:
        repeat:
            vhQuery:get-next().
            if vhQuery:query-off-end then leave blocRepeat.
            if vhBuffer::CRUD = "C" or vhBuffer::CRUD = "U"
            then do:
                /* Assignation des champs calculés */
                vhField = vhBuffer:buffer-field('lbdiv') no-error.
                if valid-handle(vhField)
                then do:
                    assign
                        vhBuffer::lbdiv = vhBuffer::lbdiv + fill("&", maximum(0, 13 - num-entries(vhBuffer::lbdiv, "&")))
                        vhField         = vhBuffer:buffer-field('lParkingSousSol')
                    no-error.
                    // Parking
                    if valid-handle(vhField) and vhBuffer::lParkingSousSol <> ?
                    then entry(8, vhBuffer::lbdiv, "&") = string(vhBuffer::lParkingSousSol, "1/0").
                    // TeleReleve ?
                    vhField = vhBuffer:buffer-field('lTeleReleve') no-error.
                    if valid-handle(vhField) and vhBuffer::lTeleReleve <> ?
                    then entry(5,  vhBuffer::lbdiv, "&") = string(vhBuffer::lTeleReleve, "00001/").
                    // Début période de chauffe
                    vhField = vhBuffer:buffer-field('cDebutPeriodeChauffe') no-error.
                    if valid-handle(vhField) and vhBuffer::cDebutPeriodeChauffe <> ?
                    then entry(6,  vhBuffer::lbdiv, "&") = vhBuffer::cDebutPeriodeChauffe.
                    // Fin période de chauffe
                    vhField = vhBuffer:buffer-field('cFinPeriodeChauffe') no-error.
                    if valid-handle(vhField) and vhBuffer::cFinPeriodeChauffe <> ?
                    then entry(7,  vhBuffer::lbdiv, "&") = vhBuffer::cFinPeriodeChauffe.
                    // Catégorie
                    vhField = vhBuffer:buffer-field('cCodeCategorieImmeuble') no-error.
                    if valid-handle(vhField) and vhBuffer::cCodeCategorieImmeuble <> ?
                    then entry(9,  vhBuffer::lbdiv, "&") = vhBuffer::cCodeCategorieImmeuble.
                    // Syndicat Pro ?
                    vhField = vhBuffer:buffer-field('lSyndicatProfessionnel') no-error.
                    if valid-handle(vhField) and vhBuffer::lSyndicatProfessionnel <> ?
                    then entry(11, vhBuffer::lbdiv, "&") = string(vhBuffer::lSyndicatProfessionnel, "00001/").
                    // Code syndicat
                    vhField = vhBuffer:buffer-field('cCodeTypeSyndicat') no-error.
                    if valid-handle(vhField) and vhBuffer::cCodeTypeSyndicat <> ?
                    then entry(12, vhBuffer::lbdiv, "&") = vhBuffer::cCodeTypeSyndicat.
                    // SRU
                    vhField = vhBuffer:buffer-field('lSRU') no-error.
                    if valid-handle(vhField) and vhBuffer::lSRU <> ?
                    then entry(13, vhBuffer::lbdiv, "&") = string(vhBuffer::lSRU, "00001/").
                end.
                assign       // ne pas oublier de réinitialiser les handles
                    vhConstruction = ?
                    vhFinContrat   = ?
                    vhPromoteur    = ?
                    vhArchitecte   = ?
                .
                vhConstruction = vhBuffer:buffer-field('daDateConstruction') no-error.
                vhFinContrat   = vhBuffer:buffer-field('daDateFinContrat')   no-error.
                vhPromoteur    = vhBuffer:buffer-field('iNumeroPromoteur')   no-error.
                vhArchitecte   = vhBuffer:buffer-field('iNumeroArchitecte')  no-error.
                /*--> Contrat de Construction */
                if (valid-handle(vhConstruction) and vhConstruction:buffer-value() > 01/01/0001)  // <> ?
                or (valid-handle(vhFinContrat)   and vhFinContrat:buffer-value()   > 01/01/0001)  // <> ?
                or (valid-handle(vhPromoteur)    and vhPromoteur:buffer-value()    > 0)           // <> 0 and <> ?
                or (valid-handle(vhArchitecte)   and vhArchitecte:buffer-value()   > 0)           // <> 0 and <> ?
                then for first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-construction}
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = vhBuffer::iNumeroImmeuble
                  , first ctrat exclusive-lock
                    where ctrat.tpcon = intnt.tpcon
                      and ctrat.nocon = intnt.nocon:
                    /*--> Objet du contrat de construction */
                    assign
                        vhBuffer::iNumeroContratConstruction = ctrat.nocon
                        ctrat.dtdeb = vhBuffer::daDateConstruction when valid-handle(vhConstruction) and vhBuffer::daDateConstruction > 01/01/0001
                        ctrat.dtfin = vhBuffer::daDateFinContrat   when valid-handle(vhFinContrat)   and vhBuffer::daDateFinContrat   > 01/01/0001
                    .
                    /*--> Promoteur */
                    if valid-handle(vhPromoteur) and vhPromoteur:buffer-value() > 0
                    then for first vbIntnt exclusive-lock
                        where vbIntnt.tpcon = ctrat.tpcon
                          and vbIntnt.nocon = ctrat.nocon
                          and vbIntnt.tpidt = {&TYPEROLE-promoteur}:
                        vbIntnt.noidt = vhPromoteur:buffer-value().
                    end.
                    /*--> Architecte */
                    if valid-handle(vhArchitecte) and vhArchitecte:buffer-value() > 0
                    then for first vbIntnt exclusive-lock
                        where vbIntnt.tpcon = ctrat.tpcon
                          and vbIntnt.nocon = ctrat.nocon
                          and vbIntnt.tpidt = {&TYPEROLE-architecte}:
                        vbIntnt.noidt = vhArchitecte:buffer-value().
                    end.
                end.
                // Immeuble de la migration
                if vhBuffer::lCopropriete
                then do:
                    for first intnt no-lock                                /* Recherche si pas de syndic stocké */
                        where intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
                          and intnt.tpidt = {&TYPEBIEN-immeuble}
                          and intnt.noidt = vhBuffer::iNumeroImmeuble
                      , first ctrat exclusive-lock
                        where ctrat.tpcon = intnt.tpcon
                          and ctrat.nocon = intnt.nocon:
                        assign
                            ctrat.tprol = vhBuffer::cCodeTypeRoleSyndic
                            ctrat.norol = vhBuffer::iNumeroRoleSyndic
                        .
                    end.
                    assign   // réinitialiser les zones pour ne pas les assigner dans updateImmeuble.
                        vhBuffer::cCodeTypeRoleSyndic = ""
                        vhBuffer::iNumeroRoleSyndic   = ?
                    .
                end.
            end.
        end.
        run deleteImmeuble in vhProcImbleExt(table-handle phtt by-reference).
        run createImmeuble in vhProcImbleExt(table-handle phtt by-reference).
        run updateImmeuble in vhProcImbleExt(table-handle phtt by-reference).
    end.
    vhQuery:query-close() no-error.
    delete object vhQuery no-error.
    run destroy in vhProcImbleExt.

end procedure.

procedure setAdresseImmeuble:
    /*------------------------------------------------------------------------------
    Purpose: mise a jour de l 'adresse immeuble
    Notes  : service utilisé par beImmeuble.cls vue : Situation
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
        run setMoyenCommunicationImmeuble in vhProc(ladrs.tpidt, ladrs.noidt).
    end.
    run destroy in vhProc.

end procedure.

procedure createContratConstruction private:
    /*------------------------------------------------------------------------------
    Purpose: création du contrat de construction de l'immeuble
    Notes  : service utilisé à la création d'un immeuble
    todo   :  Pas utilisé ?! - à supprimer
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter plRetUse         as logical no-undo.

    define variable vhCtrat as handle   no-undo.
    define variable vhIntnt as handle   no-undo.

    empty temp-table ttMandat.
    run adblib/ctrat_CRUD.p persistent set vhCtrat.
    run getTokenInstance in vhCtrat(mToken:JSessionId).
    run adblib/intnt_CRUD.p persistent set vhIntnt.
    run getTokenInstance in vhIntnt(mToken:JSessionId).

    create ttMandat.
    assign
        ttMandat.cCodeTypeContrat = {&TYPECONTRAT-construction}
        ttMandat.CRUD             = "C"
    .
    run setCtrat in vhCtrat(table ttMandat by-reference).
    // Creation lien IMMEUBLE-CONTRAT DE CONSTRUCTION
    create ttIntnt.
    assign
        ttIntnt.tpidt = {&TYPEBIEN-immeuble}
        ttIntnt.noidt = piNumeroImmeuble
        ttIntnt.tpcon = {&TYPECONTRAT-construction}
        ttIntnt.nocon = ttMandat.iNumeroContrat
        ttIntnt.CRUD  = "C"
    .
    run setIntnt in vhIntnt(table ttIntnt by-reference).
    run destroy in vhCtrat.
    run destroy in vhIntnt.
    plRetUse = true.

end procedure.

procedure updateContratConstruction private:
    /*------------------------------------------------------------------------------
    Purpose: mise a jour du contrat de construction de l'immeuble
    Notes  : service utilisé par   ??? 
    todo   :  Pas utilisé ?! - à supprimer
    ------------------------------------------------------------------------------*/
    define input parameter phttBuffer as handle no-undo.

    define variable vhCtrat as handle no-undo.
    define variable vhIntnt as handle no-undo.
    define buffer ctrat for ctrat.
    define buffer intnt for intnt.

    run adblib/ctrat_CRUD.p persistent set vhCtrat.
    run getTokenInstance in vhCtrat(mToken:JSessionId).
    run adblib/intnt_CRUD.p persistent set vhIntnt.
    run getTokenInstance in vhIntnt(mToken:JSessionId).

    // MAJ du Contrat de Construction
    for first ctrat no-lock
        where ctrat.tpcon =  {&TYPECONTRAT-construction}
          and ctrat.nocon = phttBuffer::iNumeroContratConstruction:
        empty temp-table ttCtrat.
        create ttCtrat.
        assign
            ttCtrat.nodoc = ctrat.nodoc
            ttCtrat.tpcon = ctrat.tpcon
            ttCtrat.nocon = ctrat.nocon
            ttCtrat.dtdeb = phttBuffer::daDateConstruction
            ttCtrat.dtfin = phttBuffer::daDateFinContrat
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttCtrat.CRUD        = "U"
            ttCtrat.rRowid      = rowid(ctrat)
        .
        run setCtrat in vhCtrat(table ttCtrat by-reference).
        /*--> Promoteur */
        if not can-find(first intnt no-lock
             where intnt.tpcon = {&TYPECONTRAT-construction}
               and intnt.nocon = ctrat.nocon
               and intnt.tpidt = {&TYPEROLE-promoteur}
               and intnt.noidt = ttImmeuble.iNumeroPromoteur)
        then do:
            for first intnt no-lock
                 where intnt.tpcon = {&TYPECONTRAT-construction}
                   and intnt.nocon = ctrat.nocon
                   and intnt.tpidt = {&TYPEROLE-promoteur}:
                create ttIntnt.
                assign
                    ttIntnt.tpidt = intnt.tpidt
                    ttIntnt.noidt = intnt.noidt
                    ttIntnt.tpcon = intnt.tpcon
                    ttIntnt.nocon = intnt.nocon
                    ttIntnt.CRUD  = "D"
                .
            end.
            if ttImmeuble.iNumeroPromoteur <> 0 then do:
                create ttIntnt.
                assign
                    ttIntnt.tpidt = {&TYPEROLE-promoteur}
                    ttIntnt.noidt = ttImmeuble.iNumeroPromoteur
                    ttIntnt.tpcon = {&TYPECONTRAT-construction}
                    ttIntnt.nocon = ctrat.nocon
                    ttIntnt.CRUD  = "C"
               .
            end.
        end.
        /*--> Architecte */
        if not can-find(first intnt no-lock
             where intnt.tpcon = {&TYPECONTRAT-construction}
               and intnt.nocon = ctrat.nocon
               and intnt.tpidt = {&TYPEROLE-architecte}
               and intnt.noidt = ttImmeuble.iNumeroArchitecte)
        then do:
            for first intnt no-lock
                 where intnt.tpcon = {&TYPECONTRAT-construction}
                   and intnt.nocon = ctrat.nocon
                   and intnt.tpidt = {&TYPEROLE-architecte}:
                create ttIntnt.
                assign
                    ttIntnt.tpidt = intnt.tpidt
                    ttIntnt.noidt = intnt.noidt
                    ttIntnt.tpcon = intnt.tpcon
                    ttIntnt.nocon = intnt.nocon
                    ttIntnt.CRUD        = "D"
                    ttIntnt.rRowid      = rowid(intnt)
                    ttIntnt.dtTimeStamp = datetime(intnt.dtmsy, intnt.hemsy)
                .
            end.
            if ttImmeuble.iNumeroArchitecte <> 0 then do:
                create ttIntnt.
                assign
                    ttIntnt.tpidt = {&TYPEROLE-architecte}
                    ttIntnt.noidt = ttImmeuble.iNumeroArchitecte
                    ttIntnt.tpcon = {&TYPECONTRAT-construction}
                    ttIntnt.nocon = ctrat.nocon
                    ttIntnt.CRUD  = "C"
                .
            end.
        end.
    end.
    if can-find(first ttIntnt) then run setIntnt in vhIntnt(table ttIntnt by-reference).
    empty temp-table ttIntnt.
    run destroy in vhIntnt.
    run destroy in vhCtrat.

end procedure.

procedure getlisteRoleImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:   service utilisé par beRole.cls, ...
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer   no-undo.
    define output parameter table-handle phttRole.

    define variable vcTypeRole  as character no-undo.
    define variable viLocalMini as int64     no-undo.
    define variable viLocalMaxi as int64     no-undo.

    define buffer local  for local.
    define buffer cpuni  for cpuni.
    define buffer unite  for unite.
    define buffer ctrat  for ctrat.
    define buffer ctctt  for ctctt.
    define buffer intnt  for intnt.
    define buffer vbIntnt for intnt.

    create temp-table phttRole.
    phttRole:add-new-field ("iNumeroImmeuble",  "integer",   0, "", ?, "N° Immeuble", "N° Immeuble").
    phttRole:add-new-field ("iNumeroTiers",     "integer",   0, "", ?, "N° Tiers",    "N° Tiers").
    phttRole:add-new-field ("cNomTiers",        "character", 0, "", ?, "Nom",         "Nom").
    phttRole:add-new-field ("iNumeroRole",      "integer",   0, "", ?, "N° Role",     "N° Role").
    phttRole:add-new-field ("cCodeTypeRole",    "character", 0, "", ?, "Code type role", "Code type role").
    phttRole:add-new-field ("cLibelleTypeRole", "character", 0, "", ?, "Role",        "Role").
    phttRole:add-new-field ("iNumeroLot",       "integer",   0, "", ?, "N° Lot",      "N° Lot").
    phttRole:add-new-field ("cNatureLot",       "character", 0, "", ?, "Nature Lot",  "Nature Lot").
    phttRole:temp-table-prepare("ttRole").

    /** Liste des locataires de ts l'immeuble ou de l'immeuble et du lot **/
    for each local no-lock
        where local.noimm = piNumeroImmeuble
      , each cpuni no-lock
        where cpuni.noimm = local.noimm
          and cpuni.nolot = local.nolot
          and cpuni.noapp < 997:
        assign
            viLocalMini = int64(string(cpuni.nomdt, "9999") + string(cpuni.noapp, "999") + "01")
            viLocalMaxi = int64(string(cpuni.nomdt, "9999") + string(cpuni.noapp, "999") + "99")
        .
        for each unite no-lock
            where unite.nomdt = cpuni.nomdt
              and unite.noapp = cpuni.noapp
              and unite.nocmp = cpuni.nocmp
              and unite.noact = 0
          , last ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-bail}
              and ctrat.nocon >= viLocalMini
              and ctrat.nocon <= viLocalMaxi:  // trié par tpcon, nocon
            run createTtRole(piNumeroImmeuble, local.nolot, {&TYPEROLE-locataire}, ctrat.nocon, table-handle phttRole by-reference).
        end.
    end.

    /* co-Locataire  */
    for each intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = piNumeroImmeuble
          and intnt.tpcon = {&TYPECONTRAT-bail}
      , first ctrat no-lock
        where ctrat.tpcon = intnt.tpcon
          and ctrat.nocon = intnt.nocon
          and ctrat.dtree = ?
      , each vbIntnt no-lock                 /* Recherche colocataires */
        where vbIntnt.tpcon = intnt.tpcon
          and vbIntnt.nocon = intnt.nocon
          and vbIntnt.tpidt = {&TYPEROLE-colocataire}:
        run createTtRole(piNumeroImmeuble, intnt.noidt, vbIntnt.tpidt, vbIntnt.noidt, table-handle phttRole by-reference).
    end.

    /* Liste des copropriétaire de l'immeuble ou de l'immeuble et du lot */
    for each local no-lock
        where local.noimm = piNumeroImmeuble
      , each intnt no-lock
        where intnt.tpidt = {&TYPEBIEN-lot}
          and intnt.noidt = local.noloc
          and intnt.tpcon = {&TYPECONTRAT-acte2propriete}
      , each vbIntnt no-lock
        where vbIntnt.tpcon = intnt.tpcon
          and vbIntnt.nocon = intnt.nocon
          and vbIntnt.tpidt = {&TYPEROLE-coproprietaire}:
        run createTtRole(piNumeroImmeuble, local.nolot, vbIntnt.tpidt, vbIntnt.noidt, table-handle phttRole by-reference).
    end.

    /* salarié,  Lien mandat de syndic */
    for each intnt no-lock
       where intnt.tpidt = {&TYPEBIEN-immeuble}
         and intnt.noidt = piNumeroImmeuble
         and (intnt.tpcon = {&TYPECONTRAT-mandat2Syndic} or intnt.tpcon = {&TYPECONTRAT-mandat2Gerance})
     , each ctctt no-lock
       where ctctt.tpct1 = intnt.tpcon
         and ctctt.noct1 = intnt.nocon
         and ctctt.tpct2 = (if vcTypeRole = {&TYPEROLE-salarie} then {&TYPECONTRAT-Salarie} else {&TYPECONTRAT-SalariePegase})
     , first ctrat no-lock
       where ctrat.tpcon = ctctt.tpct2
         and ctrat.nocon = ctctt.noct2
         and ctrat.dtree = ?
     , each vbIntnt no-lock
       where vbIntnt.tpcon = ctrat.tpcon
         and vbIntnt.nocon = ctrat.nocon
         and vbIntnt.tpidt = vcTypeRole:
       run createTtRole(piNumeroImmeuble, intnt.noidt, vbIntnt.tpidt, vbIntnt.noidt, table-handle phttRole by-reference).
    end.

    /* Liste des mandant/indivisaires de l'immeuble ou de l'immeuble et du lot */
    for each local no-lock
       where local.noimm = piNumeroImmeuble
      , each intnt no-lock
       where intnt.tpidt = {&TYPEBIEN-lot}
         and intnt.noidt = local.noloc
         and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
     , first ctrat no-lock
       where ctrat.tpcon = intnt.tpcon
         and ctrat.nocon = intnt.nocon
         and ctrat.dtree = ?
     , each vbIntnt no-lock
       where vbIntnt.tpcon = intnt.tpcon
         and vbIntnt.nocon = intnt.nocon
         and vbIntnt.tpidt = {&TYPEROLE-mandant}:
       run createTtRole(piNumeroImmeuble, local.nolot, vbIntnt.tpidt, vbIntnt.noidt, table-handle phttRole by-reference).
    end.

end procedure.

procedure createTtRole private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroImmeuble    as integer   no-undo.
    define input parameter piNumeroLot         as integer   no-undo.
    define input parameter pcTypeidentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as integer   no-undo.
    define input parameter table-handle phttRole.

    define variable vhTmpRole as handle no-undo.
    define buffer vbRoles for roles.
    define buffer tiers   for tiers.
    define buffer local   for local.

    vhTmpRole = phttRole:default-buffer-handle.
    for first local no-lock
        where local.noimm = piNumeroImmeuble
          and local.nolot = piNumeroLot
      , each vbRoles no-lock
        where vbRoles.tprol = pcTypeidentifiant
          and vbRoles.norol = piNumeroIdentifiant
      , each tiers no-lock
        where tiers.notie = vbRoles.notie:
        vhTmpRole:handle:buffer-create().
        assign
            vhTmpRole::iNumeroImmeuble  = piNumeroImmeuble
            vhTmpRole::iNumeroTiers     = tiers.notie
            vhTmpRole::cNomTiers        = substitute('&1 &2', trim(tiers.lnom1), trim(tiers.lpre1))
            vhTmpRole::iNumeroRole      = vbRoles.norol
            vhTmpRole::cCodeTypeRole    = vbRoles.tprol
            vhTmpRole::cLibelleTypeRole = outilTraduction:getLibelleProg("O_ROL", vbRoles.tprol)
            vhTmpRole::iNumeroLot       = (if available local then local.nolot else vbRoles.norol)
            vhTmpRole::cNatureLot       = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
        no-error.
    end.

end procedure.

procedure getNotesImmeuble:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:  service pour beImmeuble.cls ou beLot.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroImmeuble as integer no-undo.
    define output parameter table for ttNotes.
    
    define variable vhproc as handle no-undo.
    define buffer imble for imble.

    empty temp-table ttNotes.
    run note/notes_CRUD.p persistent set vhproc.
    run getTokenInstance in vhproc(mToken:JSessionId).
    for first imble no-lock
        where imble.noimm = piNumeroImmeuble:
        run getNotes in vhProc(imble.noblc, input-output table ttNotes).
    end.
    run destroy in vhproc.
    for each ttNotes: ttNotes.iNumeroIdentifiant = piNumeroImmeuble. end.

end procedure.
