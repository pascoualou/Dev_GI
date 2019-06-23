/*-----------------------------------------------------------------------------
File        : tacheTVAServiceAnnexe.p
Purpose     : Tache TVA Services Annexes bail
Author(s)   : npo  -  2018/03/01
Notes       : a partir de \adb\src\tach\prmobtv2.p
-----------------------------------------------------------------------------*/
{preprocesseur/categorie2bail.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/profil2rubQuit.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

using parametre.pclie.parametrageRubriqueQuittHonoCabinet.
using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/cttac.i}
{application/include/combo.i}
{application/include/glbsepar.i}
{bail/include/libelleRubQuitt.i}
{tache/include/tacheTvaServiceAnnexe.i}
{tache/include/tache.i}
define variable goSyspr as class syspr no-undo.    // variable globale, évite de réinstancier dans une boucle

function lectureTauxTVA returns decimal(pcTypeParametre as character, pcCodeParametre as character):
    /*------------------------------------------------------------------------
    Purpose : fonction de lecture du taux à appliquer
    Notes   :
    ------------------------------------------------------------------------*/
    goSyspr:reload(pcTypeParametre, pcCodeParametre).
    if goSyspr:isDbParameter then return goSyspr:zone1.
    return 0.
end function.

function donneNatureContrat returns character(piNumeroContrat as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------
    Purpose : fonction de récupération de la nature du contrat
    Notes   :
    ------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        return ctrat.ntcon.
    end.
    return ''.
end function.

function donneTauxTvaArticle return decimal(pcCodeArticle as character):
    /*------------------------------------------------------------------------
    Purpose : fonction de récupération du taux de TVA d'un article dans la table des parametres facturation
    Notes   :
    ------------------------------------------------------------------------*/
    define buffer ifdparam for ifdparam.
    define buffer ifdart   for ifdart.
    define buffer itaxe    for itaxe.

    for first ifdparam no-lock
        where ifdparam.soc-dest = integer(mtoken:cRefGerance)
      , first ifdart no-lock      // Se positionner sur l'article
        where ifdart.soc-cd  = ifdparam.soc-cd
          and ifdart.art-cle = pcCodeArticle
      , first itaxe no-lock
        where itaxe.soc-cd  = ifdart.soc-cd 
          and itaxe.taxe-cd = ifdart.taxe-cd:
        return itaxe.taux.
    end.
    return 0.
end function.

function decodageTVA returns integer private(
    piNumeroContrat as int64, pcTypeContrat as character, pcCodeDecodage  as character, pcCodeEntree as character):
    /*------------------------------------------------------------------------------
    Purpose: Décodage TVA -> RUB ou RUB -> TVA
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vcValeurTauxTva as character no-undo.
    define variable vcNatureContrat as character no-undo.

    define buffer bxrbp for bxrbp.
    define buffer rubqt for rubqt.

    if pcCodeDecodage = "TVA" then do:
        if pcCodeEntree = "00000" then return 0.

        assign
            vcValeurTauxTva = string(lectureTauxTVA("CDTVA", pcCodeEntree) * 100)
            vcNatureContrat = donneNatureContrat(piNumeroContrat, pcTypeContrat)
        .
        // Recherche de la rubrique tva associée au taux
        for each bxrbp no-lock
            where bxrbp.ntbai = vcNatureContrat
              and bxrbp.cdfam = {&FamilleRubqt-Taxe}
              and bxrbp.prg05 = {&TYPETACHE-TVAServicesAnnexes}
              and bxrbp.noLib = 0
          , first rubqt no-lock
            where rubqt.cdfam = bxrbp.cdfam
              and rubqt.cdrub = bxrbp.norub
              and rubqt.cdlib = 0
              and rubqt.prg04 = vcValeurTauxTva:
            return rubqt.cdrub.
        end.
        return 0.
    end.
    for first rubqt no-lock
        where rubqt.cdrub = integer(pcCodeEntree)
          and rubqt.cdlib = 0:
        goSyspr:reload("CDTVA", decimal(rubqt.prg04) / 100).
        if goSyspr:isDbParameter then return integer(goSyspr:cdpar).
    end.
    return 0.

end function.

procedure getTvaServiceAnnexe:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheTvaServiceAnnexe.

    define variable viNombreLignes        as integer   no-undo.
    define variable vcLigneTravail        as character no-undo.
    define variable viNumeroSousFamille   as integer   no-undo.
    define variable vcLibelleSousFamille  as character no-undo.
    define variable vcLibelleFamille04    as character no-undo.
    define variable viNumeroLibelleDefaut as integer   no-undo.
    define variable vcLibelleDefaut       as character no-undo.
    define variable vcCodeTva             as character no-undo extent 10.
    define variable viNumeroRubrique      as integer   no-undo extent 10.
    define variable viNumeroLibelle       as integer   no-undo extent 10.

    define buffer tache for tache.
    define buffer ctrat for ctrat.
    define buffer famqt for famqt.

    empty temp-table ttTacheTvaServiceAnnexe.
    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.   
    find last tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-TVAServicesAnnexes} no-error.
    if not available tache then do:
        mError:createError({&error}, 1000471).                //tache inexistante
        return.
    end.
    do viNombreLignes = 1 to num-entries(tache.lbdiv, "@"):
        vcLigneTravail = entry(viNombreLignes, tache.lbdiv, "@").
        if num-entries(vcLigneTravail, "#") >= 5
        then assign
            viNumeroSousFamille                   = integer(entry(4, vcLigneTravail, "#"))
            viNumeroRubrique[viNumeroSousFamille] = integer(entry(1, vcLigneTravail, "#"))
            viNumeroLibelle[viNumeroSousFamille]  = integer(entry(2, vcLigneTravail, "#"))
            vcCodeTva[viNumeroSousFamille]        = entry(5, vcLigneTravail, "#")
        .
    end.
    assign
        viNombreLignes = 0
        goSyspr        = new syspr()
    .
    for each famqt no-lock
        where famqt.cdfam = {&FamilleRubqt-Administratif}
          and (famqt.cdsfa = {&SousFamilleRubqt-Administratif}
            or famqt.cdsfa = {&SousFamilleRubqt-ServiceHotelier}
            or famqt.cdsfa = {&SousFamilleRubqt-ServiceDivers}
            or famqt.cdsfa = {&SousFamilleRubqt-RedevanceSoumiseTVA}
            or famqt.cdsfa = {&SousFamilleRubqt-LoyerRedevanceService}):
        // Recuperation du libelle du type de sous-famille
        vcLibelleSousFamille = outilTraduction:getLibelle(string(famqt.nome1)).
        if famqt.cdsfa = 00
        then vcLibelleFamille04 = string(famqt.cdfam, "99") + " - " + vcLibelleSousFamille.
        else do:
            run recupLibelleDefautRubrique(viNumeroRubrique[famqt.cdsfa], ctrat.ntcon, output viNumeroLibelleDefaut, output vcLibelleDefaut).
            create ttTacheTvaServiceAnnexe.
            outils:copyValidField(buffer tache:handle, buffer ttTacheTvaServiceAnnexe:handle).
            assign
                viNombreLignes                              = viNombreLignes + 1
                ttTacheTvaServiceAnnexe.iNumeroFamille      = famqt.cdfam
                ttTacheTvaServiceAnnexe.cFamilleRubriques   = if viNombreLignes = 1 then vcLibelleFamille04 else ""
                ttTacheTvaServiceAnnexe.iNumeroSousFamille  = famqt.cdsfa
                ttTacheTvaServiceAnnexe.cSousFamille        = string(famqt.cdsfa, "99") + " - " + vcLibelleSousFamille
                ttTacheTvaServiceAnnexe.cCodeTauxTVA        = vcCodeTva[famqt.cdsfa]
                ttTacheTvaServiceAnnexe.dTauxTVA            = lectureTauxTVA("CDTVA", vcCodeTva[famqt.cdsfa])
                ttTacheTvaServiceAnnexe.cLibelleTauxTVA     = outilTraduction:getLibelleParam("CDTVA", vcCodeTva[famqt.cdsfa])
                ttTacheTvaServiceAnnexe.iNumeroRubriqueQtt  = viNumeroRubrique[famqt.cdsfa]
                ttTacheTvaServiceAnnexe.cLibelleRubriqueQtt = if viNumeroRubrique[famqt.cdsfa] > 0 then string(viNumeroRubrique[famqt.cdsfa], "999") else " "
                ttTacheTvaServiceAnnexe.iNumeroLibelleQtt   = viNumeroLibelle[famqt.cdsfa]
                ttTacheTvaServiceAnnexe.iNumeroLibelleQtt   = viNumeroLibelleDefaut
                ttTacheTvaServiceAnnexe.cLibelleQtt         = vcLibelleDefaut
                ttTacheTvaServiceAnnexe.CRUD                = 'R'
                ttTacheTvaServiceAnnexe.dtTimestamp         = datetime(tache.dtmsy, tache.hemsy)
                ttTacheTvaServiceAnnexe.rRowid              = rowid(tache)
            .
        end.
    end.
    delete object goSyspr.
end procedure.

procedure initTvaServiceAnnexe:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheTvaServiceAnnexe.

    define variable viNumeroRubriqueDefaut as integer   no-undo extent 10.
    define variable vcCodeTvaDefaut        as character no-undo extent 10 initial "00000".
    define variable viNombreLignes         as integer   no-undo.
    define variable vcLibelleSousFamille   as character no-undo.
    define variable vcLibelleFamille04     as character no-undo.
    define variable viNumeroLibelleDefaut  as integer   no-undo.
    define variable vcLibelleDefaut        as character no-undo.

    define buffer ctrat for ctrat.
    define buffer famqt for famqt.

    find first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.   
    if can-find(first tache no-lock
                where tache.tpcon = pcTypeContrat
                  and tache.nocon = piNumeroContrat
                  and tache.tptac = {&TYPETACHE-TVAServicesAnnexes})
    then do:
        mError:createError({&error}, 1000410).          // demande d'initialisation d'une tache existante
        return.
    end.

    // Initialisation des TVA/sous-famille  : Par défaut:
    //   sous-famille 03-services hoteliers :TVA 19.6%
    //   sous-famille 05-services divers    :TVA 19.6%
    //   sous-famille 06-redevance          :TVA  5.5%   modif SY le 06/12/2011 : TVA 7%
    //   sous-famille 08-Abonnement         :TVA  5.5%   Ajout SY le 13/01/2012
    assign
        goSyspr                   = new syspr()
        vcCodeTvaDefaut[3]        = {&codeTVA-00209}
        vcCodeTvaDefaut[5]        = {&codeTVA-00209}
        vcCodeTvaDefaut[6]        = if integer(mtoken:cRefGerance) = 2053 then {&codeTVA-00209} else {&codeTVA-00210}
        vcCodeTvaDefaut[8]        = {&codeTVA-00204}   // Ajout SY le 13/01/2012 TVA  5.5%
        viNumeroRubriqueDefaut[3] = decodageTVA(ctrat.nocon, ctrat.tpcon, "TVA", vcCodeTvaDefaut[3])
        viNumeroRubriqueDefaut[5] = decodageTVA(ctrat.nocon, ctrat.tpcon, "TVA", vcCodeTvaDefaut[5])
        viNumeroRubriqueDefaut[6] = decodageTVA(ctrat.nocon, ctrat.tpcon, "TVA", vcCodeTvaDefaut[6])
        viNumeroRubriqueDefaut[8] = decodageTVA(ctrat.nocon, ctrat.tpcon, "TVA", {&codeTVA-00204})
        viNombreLignes = 0
    .
    for each famqt no-lock
        where famqt.cdfam  = {&FamilleRubqt-Administratif}
          and (famqt.cdsfa = {&SousFamilleRubqt-Administratif}
           or famqt.cdsfa  = {&SousFamilleRubqt-ServiceHotelier}
           or famqt.cdsfa  = {&SousFamilleRubqt-ServiceDivers}
           or famqt.cdsfa  = {&SousFamilleRubqt-RedevanceSoumiseTVA}
           or famqt.cdsfa  = {&SousFamilleRubqt-LoyerRedevanceService}):
        // Recuperation du libelle du type de sous-famille
        vcLibelleSousFamille = outilTraduction:getLibelle(string(famqt.nome1)).
        if famqt.cdsfa = 00
        then vcLibelleFamille04 = string(famqt.cdfam, "99") + " - " + vcLibelleSousFamille.
        else do:
            run recupLibelleDefautRubrique(viNumeroRubriqueDefaut[famqt.cdsfa], ctrat.ntcon, output viNumeroLibelleDefaut, output vcLibelleDefaut).
            create ttTacheTvaServiceAnnexe.
            assign
                viNombreLignes                              = viNombreLignes + 1
                ttTacheTvaServiceAnnexe.iNumeroTache        = 0
                ttTacheTvaServiceAnnexe.cTypeContrat        = ctrat.tpcon
                ttTacheTvaServiceAnnexe.iNumeroContrat      = ctrat.nocon
                ttTacheTvaServiceAnnexe.cTypeTache          = {&TYPETACHE-TVAServicesAnnexes}
                ttTacheTvaServiceAnnexe.iChronoTache        = 0
                ttTacheTvaServiceAnnexe.iNumeroFamille      = famqt.cdfam
                ttTacheTvaServiceAnnexe.cFamilleRubriques   = (if viNombreLignes = 1 then vcLibelleFamille04 else "")
                ttTacheTvaServiceAnnexe.iNumeroSousFamille  = famqt.cdsfa
                ttTacheTvaServiceAnnexe.cSousFamille        = string(famqt.cdsfa, "99") + " - " + vcLibelleSousFamille
                ttTacheTvaServiceAnnexe.cCodeTauxTVA        = vcCodeTvaDefaut[famqt.cdsfa]
                ttTacheTvaServiceAnnexe.dTauxTVA            = lectureTauxTVA("CDTVA", vcCodeTvaDefaut[famqt.cdsfa])
                ttTacheTvaServiceAnnexe.cLibelleTauxTVA     = outilTraduction:getLibelleParam("CDTVA", vcCodeTvaDefaut[famqt.cdsfa])
                ttTacheTvaServiceAnnexe.iNumeroRubriqueQtt  = viNumeroRubriqueDefaut[famqt.cdsfa]
                ttTacheTvaServiceAnnexe.cLibelleRubriqueQtt = (if viNumeroRubriqueDefaut[famqt.cdsfa] > 0 then string(viNumeroRubriqueDefaut[famqt.cdsfa], "999") else "")
                ttTacheTvaServiceAnnexe.iNumeroLibelleQtt   = viNumeroLibelleDefaut
                ttTacheTvaServiceAnnexe.cLibelleQtt         = vcLibelleDefaut
                ttTacheTvaServiceAnnexe.CRUD                = 'C'
            .
        end.
    end.
    delete object goSyspr.
end procedure.

procedure setTvaServiceAnnexe:
    /*------------------------------------------------------------------------------
    Purpose: maj tache
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheTvaServiceAnnexe.

    define buffer ctrat for ctrat.

    for first ttTacheTvaServiceAnnexe
        where lookup(ttTacheTvaServiceAnnexe.CRUD, "C,U,D") > 0:
        if not can-find(first ctrat no-lock
            where ctrat.tpcon = ttTacheTvaServiceAnnexe.cTypeContrat
              and ctrat.nocon = ttTacheTvaServiceAnnexe.iNumeroContrat)
        then mError:createError({&error}, 100057).
        else do:
            if ttTacheTvaServiceAnnexe.CRUD <> "D" then run verZonSai(buffer ttTacheTvaServiceAnnexe).
            if not mError:erreur() then run majTache(ttTacheTvaServiceAnnexe.iNumeroContrat, ttTacheTvaServiceAnnexe.cTypeContrat).
        end.
    end.

end procedure.

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache (creation table ttTache a partir table specifique tache (ici ttTacheTvaServiceAnnexe)
             et appel du programme commun de maj des taches (tache/tache.p)
             si maj tache correcte appel maj table relation contrat tache (cttac).
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContrat as int64     no-undo.
    define input parameter pcTypeContrat   as character no-undo.

    define variable vcListeLignes as character no-undo.
    define variable vcTypeCRUD    as character no-undo.
    define variable vhProcTache   as handle    no-undo.
    define variable vhProcCttac   as handle    no-undo.

    define buffer cttac for cttac.

    // Mise à jour de la chaine tache.lbdiv
    for each ttTacheTvaServiceAnnexe:
        vcListeLignes = substitute("&1@&2#&3#&4#&5#&6", vcListeLignes,
                                   string(ttTacheTvaServiceAnnexe.iNumeroRubriqueQtt),
                                   string(ttTacheTvaServiceAnnexe.iNumeroLibelleQtt),
                                   string(ttTacheTvaServiceAnnexe.iNumeroFamille, "99"),
                                   string(ttTacheTvaServiceAnnexe.iNumeroSousFamille, "99"),
                                   ttTacheTvaServiceAnnexe.cCodeTauxTVA).
    end.
    vcListeLignes = trim(vcListeLignes, "@").
    for first ttTacheTvaServiceAnnexe
        where lookup(ttTacheTvaServiceAnnexe.CRUD, "C,U,D") > 0:
        empty temp-table ttTache.
        create ttTache.
        assign
            ttTache.noita       = ttTacheTvaServiceAnnexe.iNumeroTache
            ttTache.tpcon       = ttTacheTvaServiceAnnexe.cTypeContrat
            ttTache.nocon       = ttTacheTvaServiceAnnexe.iNumeroContrat
            ttTache.tptac       = ttTacheTvaServiceAnnexe.cTypeTache
            ttTache.notac       = ttTacheTvaServiceAnnexe.iChronoTache
            ttTache.lbdiv       = vcListeLignes
            ttTache.CRUD        = ttTacheTvaServiceAnnexe.CRUD
            ttTache.dtTimestamp = ttTacheTvaServiceAnnexe.dtTimestamp
            ttTache.rRowid      = ttTacheTvaServiceAnnexe.rRowid
            vcTypeCRUD          = ttTacheTvaServiceAnnexe.CRUD
        .
        run tache/tache.p persistent set vhProcTache.
        run getTokenInstance in vhProcTache(mToken:JSessionId).
        run setTache in vhProcTache(table ttTache by-reference).
        run destroy in vhProcTache.
        if mError:erreur() then return.

        empty temp-table ttCttac.
        create ttCttac.
        assign
            ttCttac.tpcon       = pcTypeContrat
            ttCttac.nocon       = piNumeroContrat
            ttCttac.tptac       = {&TYPETACHE-TVAServicesAnnexes}
        .
        find first cttac no-lock
             where cttac.tpcon = pcTypeContrat
               and cttac.nocon = piNumeroContrat
               and cttac.tptac = {&TYPETACHE-TVAServicesAnnexes} no-error.
        if available cttac and vcTypeCRUD = "D"
        then assign
            ttCttac.CRUD        = "D"
            ttCttac.rRowid      = rowid(cttac)
            ttCttac.dtTimestamp = datetime(cttac.dtmsy, cttac.hemsy)
        .
        else if not available cttac and vcTypeCRUD = "C" then ttCttac.CRUD  = "C".
        run adblib/cttac_CRUD.p persistent set vhProcCttac.
        run getTokenInstance in vhProcCttac(mToken:JSessionId).
        run setCttac in vhProcCttac(table ttCttac by-reference).     
        run destroy  in vhProcCttac.
        if mError:erreur() then return.
    end.

end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheTvaServiceAnnexe for ttTacheTvaServiceAnnexe.

    define variable voRubriqueQuittHonoCabinet as class parametrageRubriqueQuittHonoCabinet no-undo.
    define variable vcCodeArticle as character no-undo.
    define variable vdTauxTva     as decimal   no-undo.

    // VerZonSai-det
    if ttTacheTvaServiceAnnexe.cCodeTauxTVA = '' then do:
        mError:createError({&error}, 101082).        // Le taux de la TVA est obligatoire !!
        return.
    end.
    if ttTacheTvaServiceAnnexe.cCodeTauxTVA <> '00000' then do:
        if ttTacheTvaServiceAnnexe.iNumeroRubriqueQtt = 0 then do:
            mError:createError({&error}, 101080).        // Le numéro de la rubrique est obligatoire !!
            return.
        end.
        if ttTacheTvaServiceAnnexe.iNumeroLibelleQtt = 0 then do:
            mError:createError({&error}, 101081).        // Le libellé de la rubrique est obligatoire !!
            return.
        end.
    end.
    assign
        // VerZonSai-all
        voRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet()
        // Récupère le code article de facturation associé à une famille/sous-famille
        vcCodeArticle = voRubriqueQuittHonoCabinet:donneCodeArticleFacturation(ttTacheTvaServiceAnnexe.iNumeroFamille, ttTacheTvaServiceAnnexe.iNumeroSousFamille)
    .
    // Récupère le taux de Tva associé à cet article de facturation
    if vcCodeArticle > '' then do:
        vdTauxTva = DonneTauxTvaArticle(vcCodeArticle).  
        if vdTauxTva <> ttTacheTvaServiceAnnexe.dTauxTVA then do:
            /*LbTmpPdt = "Sous-famille " + ttTacheTvaServiceAnnexe.cSousFamille + " : Le taux de TVA " + ttTacheTvaServiceAnnexe.cLibelleTauxTVA 
                    + " est incompatible avec celui de l'article de facturation " + vcCodeArticle + " (" + string(vdTauxTva, ">>9.99") + "% ) " 
                    + " associé à la rubrique " + string(ttTacheTvaServiceAnnexe.iNumeroRubriqueQtt, "999") + "-" 
                    + string(ttTacheTvaServiceAnnexe.iNumeroLibelleQtt, "99") + " de cette sous-famille.".
            run GestMess in HdLibPrc(0,"TVA Service et TVA honoraires différentes",0,LbTmpPdt,"","ERROR",output FgRepMes).*/
            mError:createErrorGestion({&error}, 1000590,
                                      substitute('&1&2&3&2&4&2&5&2&6', "", separ[1], ttTacheTvaServiceAnnexe.cLibelleTauxTVA, vcCodeArticle, string(vdTauxTva, ">>9.99"), string(ttTacheTvaServiceAnnexe.iNumeroRubriqueQtt, "999"), string(ttTacheTvaServiceAnnexe.iNumeroLibelleQtt, "99"))).
            return.
        end.
    end.
    delete object voRubriqueQuittHonoCabinet.  

end procedure.

procedure initComboTvaServiceAnnexe:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe (beBail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttCombo.

    run chargeCombo(donneNatureContrat(piNumeroContrat, pcTypeContrat)).

end procedure.

procedure chargeCombo private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement des combos Taux TVA et Rubriques TVA
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcNatureContrat as character no-undo.

    define variable voSyspr           as class syspr no-undo.
    define variable viNumeroItem      as integer     no-undo.
    define variable viNumeroLibelle   as integer     no-undo.
    define variable vcLibelleRubrique as character   no-undo.

    define buffer bxrbp for bxrbp.
    empty temp-table ttCombo.

    // Combo des taux de TVA
    voSyspr = new syspr().
    voSyspr:getComboParametre("CDTVA", "CMBTAUXTVA", output table ttCombo by-reference).
    delete object voSyspr.
    // TVA à 8% non gérée car pas de rubrique
    for first ttCombo
        where ttCombo.cNomCombo = "CMBTAUXTVA"         
          and ttCombo.cCode     = {&codeTVA-00207}:
        delete ttCombo.
    end.
    // Gestion Autres combo
    for last ttCombo:
        viNumeroItem = ttCombo.iSeqId.
    end.
    // Combo des rubriques de TVA
    for each bxrbp no-lock
        where bxrbp.ntbai = pcNatureContrat
          and bxrbp.cdfam = {&FamilleRubqt-Taxe}
          and bxrbp.prg05 = {&TYPETACHE-TVAServicesAnnexes}
          and bxrbp.nolib = 0:
        run recupLibelleDefautRubrique(bxrbp.norub, pcNatureContrat, output viNumeroLibelle, output vcLibelleRubrique).
        create ttCombo.
        assign
            viNumeroItem      = viNumeroItem + 1
            ttcombo.iSeqId    = viNumeroItem
            ttCombo.cNomCombo = "CMBRUBRIQUETVA"
            ttCombo.cCode     = string(bxrbp.norub)
            ttCombo.cLibelle  = vcLibelleRubrique
        .
    end.

end procedure.
