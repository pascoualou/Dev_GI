/*------------------------------------------------------------------------
File        : majQuittance.p
Purpose     :
Author(s)   : GGA 2018/07/06
Notes       : a partir de adb/quit.crerubqt.p adb/quit/modrubqt.p
derniere revue: 2018/12/20 - DMI: KO
  PHM ->todo supprimer les messages
        beaucoup de code en commentaire
        traiter les todo
----------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/referenceClient.i}
{preprocesseur/profil2rubQuit.i}

/* Nombre de rubriques maxi pour l'écran NP 0314/0049 (attention, défini aussi dans procedureCommuneQuittance.i) */
&SCOPED-DEFINE NbRubMax     14

using parametre.pclie.pclie.
using parametre.pclie.parametrageRubriqueLibelleMultiple.
using parametre.pclie.parametrageRubriqueQuittHonoCabinet.
using parametre.pclie.parametrageRubriqueExtournable.
using parametre.pclie.parametrageEditionCRG.

{oerealm/include/instanciateTokenOnModel.i} // Doit être positionnée juste après using

{application/include/glbsepar.i}
{application/include/error.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{bail/include/tbtmpqtt.i &nomtable=ttQuittance}
{bail/include/tbtmprub.i &nomtable=ttRubrique}
{bail/include/familleRubrique.i}
{bail/include/rubriqueQuitt.i &NomTable=ttRubriqueParFamille}
{bail/include/libelleRubriqueQuitt.i}

define variable goCollectionHandlePgm                 as class collection no-undo.
define variable goCollectionContrat                   as class collection no-undo.
define variable goPclie                               as class pclie      no-undo.
define variable goParametrageRubriqueQuittHonoCabinet as class parametrageRubriqueQuittHonoCabinet no-undo.
define variable goParametrageRubriqueExtournable      as class parametrageRubriqueExtournable      no-undo.
define variable goRubriqueLibelleMultiple             as class parametrageRubriqueLibelleMultiple  no-undo.
define variable ghProc                 as handle    no-undo.
define variable giNumeroContrat        as int64     no-undo.
define variable gcTypeContrat          as character no-undo.
define variable giNumeroMandat         as int64     no-undo.
define variable giMoisModifiable       as integer   no-undo.
define variable giMoisQuittancement    as integer   no-undo.
define variable glBailFournisseurLoyer as logical   no-undo.

{comm/include/ismulaut.i}                           // fonction isMulAut
{outils/include/lancementProgramme.i}               // fonctions lancementPgm, suppressionPgmPersistent
{bail/quittancement/procedureCommuneQuittance.i}    // procedures chgMoisQuittance, isRubMod
{comm/include/prrubhol.i}                           // procedures isRubEcla, isRubProCum, valDefProCum8xx

function evolutionLoyer returns logical private():
    /*------------------------------------------------------------------------------
    Purpose: recherche si mode de calcul calendrier d'evolution des loyers
    Notes  : a partir de adb/quit/crerubqt.p (enawinrch)
    ------------------------------------------------------------------------------*/
    define buffer tache   for tache.

    find last tache no-lock
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroContrat
          and tache.tptac = {&TYPETACHE-revision} no-error.
    if available tache and tache.cdhon = "00001"
    then return can-find(first tache no-lock
                         where tache.tpcon = gcTypeContrat
                           and tache.nocon = giNumeroContrat
                           and tache.tptac = {&TYPETACHE-calendrierEvolutionLoyer}
                           and tache.notac = 0
                           and tache.tphon = "YES").
    return false.
end function.

function tvaServiceAnnexe returns logical private():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de adb/quit/crerubqt.p (enawinrch)
    ------------------------------------------------------------------------------*/
    return can-find(first tache no-lock
                    where tache.tptac = {&TYPETACHE-TVAServicesAnnexes}
                      and tache.tpcon = gcTypeContrat
                      and tache.nocon = giNumeroContrat).
end function.

function suppressionObjetPersistent logical private():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    if valid-object(goParametrageRubriqueQuittHonoCabinet) then delete object goParametrageRubriqueQuittHonoCabinet.
    if valid-object(goParametrageRubriqueExtournable) then delete object goParametrageRubriqueExtournable.
    if valid-object(goPclie) then delete object goPclie.
    if valid-object(goRubriqueLibelleMultiple) then delete object goRubriqueLibelleMultiple.    
end function.

function recherchelibelleIrf returns character private(pcTypeLib as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de adb/quit/crerubqt.p (majecran)
    ------------------------------------------------------------------------------*/
    define variable vcLibelle as character no-undo.
    case pcTypeLib:
        when "00001" or when "00002" 
        then vcLibelle = substitute("&1 &2", outilTraduction:getLibelle(102120), outilTraduction:getLibelle(102121)).    
        when "00003" 
        then vcLibelle = substitute("&1 &2", outilTraduction:getLibelle(102120), outilTraduction:getLibelle(102122)).    
        when "00004" 
        then vcLibelle = substitute("&1 &2", outilTraduction:getLibelle(102120), outilTraduction:getLibelle(102123)).   
        when "00005" 
        then vcLibelle = substitute("&1 &2", outilTraduction:getLibelle(102120), outilTraduction:getLibelle(102124)).   
        when "00006" 
        then vcLibelle = outilTraduction:getLibelle(102120).
        when "00007" 
        then vcLibelle = outilTraduction:getLibelle(102119).
    end case.
    if vcLibelle <> "" and pcTypeLib <> "00007"
    then vcLibelle = substitute("&1 Niveau &2", vcLibelle, string(integer(pcTypeLib))).
    return vcLibelle.
end function.

procedure getListeRubriqueFamille:
    /*------------------------------------------------------------------------------
      Purpose:
      Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input  parameter poCollectionContrat as class collection no-undo.
    define input  parameter poCollection        as class collection no-undo.
    define output parameter table for ttRubriqueParFamille.

    define variable vifamilleRubrique as integer no-undo.
    define variable viNumeroQuittance as integer no-undo.
    
    define buffer ctrat for ctrat.

    empty temp-table ttQtt.
    empty temp-table ttRub.
    empty temp-table ttRubriqueParFamille.

    assign
        giNumeroContrat       = poCollectionContrat:getInt64("iNumeroContrat")
        gcTypeContrat         = poCollectionContrat:getCharacter("cTypeContrat")
        vifamilleRubrique     = poCollection:getInteger("ifamilleRubrique")
        giNumeroMandat        = truncate(giNumeroContrat / 100000, 0)
        viNumeroQuittance     = poCollection:getInteger("iNumeroQuittance")
        goCollectionHandlePgm = new collection()
    .

message "gga getListeRubriqueFamille " giNumeroContrat gcTypeContrat vifamilleRubrique  giNumeroMandat viNumeroQuittance.

    run chgMoisQuittance (giNumeroMandat, input-output poCollectionContrat).
    giMoisQuittancement = poCollectionContrat:getInteger("iMoisQuittancement").
    if vifamilleRubrique = {&FamilleRubqt-HonoraireCabinet} then do:
        ghProc = lancementPgm("bail/quittancement/quittanceEncours.p", goCollectionHandlePgm).
        run getQuittance in ghProc(poCollectionContrat, viNumeroQuittance, input-output table ttQtt by-reference, input-output table ttRub by-reference).
        if can-find(first ttQtt where ttQtt.iNoQuittance = viNumeroQuittance) then do:
            ghProc = lancementPgm("bail/quittancement/rubriqueQuitt.p", goCollectionHandlePgm).
            run chgListeRubriqueFamille08 in ghproc(giNumeroContrat, viNumeroQuittance, table ttRub by-reference, output table ttRubriqueParFamille by-reference).
        end.
    end.
    else for first ctrat no-lock
        where ctrat.tpcon = gcTypeContrat
          and ctrat.nocon = giNumeroContrat:
        ghProc = lancementPgm("bail/quittancement/rubriqueQuitt.p", goCollectionHandlePgm).
        run chgListeRubriqueSurNatureContrat in ghproc(ctrat.ntcon, 1, ctrat.nocon, giMoisQuittancement, string(vifamilleRubrique, "99"), "00001:00003:00007:00008", "", "",
                                                        output table ttRubriqueParFamille by-reference).
    end.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure getLibelleRubrique:
    /*------------------------------------------------------------------------------
      Purpose:
      Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input parameter poCollection        as class collection no-undo.
    define output parameter table for ttLibelleRubriqueQuitt.

    define variable viNumeroRubrique as integer no-undo.
    
    define buffer ctrat for ctrat.

    empty temp-table ttLibelleRubriqueQuitt.
    assign
        giNumeroContrat       = poCollectionContrat:getInt64("iNumeroContrat")
        gcTypeContrat         = poCollectionContrat:getCharacter("cTypeContrat")
        viNumeroRubrique      = poCollection:getInteger("iNumeroRubrique")
        giNumeroMandat        = truncate(giNumeroContrat / 100000, 0)
        goCollectionHandlePgm = new collection()
    .

message "gga getLibelleRubrique " giNumeroContrat gcTypeContrat viNumeroRubrique  giNumeroMandat .

    run chgMoisQuittance (giNumeroMandat, input-output poCollectionContrat).
    assign
        giMoisQuittancement = poCollectionContrat:getInteger("iMoisQuittancement")
        ghProc              = lancementPgm("bail/quittancement/rubriqueQuitt.p", goCollectionHandlePgm)
    .
    for first ctrat no-lock
        where ctrat.tpcon = gcTypeContrat
          and ctrat.nocon = giNumeroContrat:
        run chgLibelleRubriqueSurNatureContrat in ghproc(ctrat.ntcon, viNumeroRubrique, ctrat.nocon, giMoisQuittancement, "", "", "",
                                                         output table ttLibelleRubriqueQuitt by-reference).
    end.
    suppressionPgmPersistent(goCollectionHandlePgm).
end procedure.

procedure initialisationRubrique:
    /*------------------------------------------------------------------------------
    Purpose: extrait de adb/quit/crerubqt.p
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input  parameter poCollectionContrat as class collection no-undo.
    define input  parameter poCollection        as class collection no-undo.
    define output parameter table for ttRubrique.

    define variable viNumeroRubrique  as integer no-undo.
    define variable viNumeroQuittance as integer no-undo.
    define buffer rubqt for rubqt.

    empty temp-table ttQtt.
    empty temp-table ttRub.
    empty temp-table ttRubrique.

    assign
        giNumeroContrat       = poCollectionContrat:getInt64("iNumeroContrat")
        gcTypeContrat         = poCollectionContrat:getCharacter("cTypeContrat")
        viNumeroRubrique      = poCollection:getInteger("iNumeroRubrique")
        viNumeroQuittance     = poCollection:getInteger("iNumeroQuittance")
        giNumeroMandat        = truncate(giNumeroContrat / 100000, 0)
        goCollectionHandlePgm = new collection()
        goParametrageRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet()
        goParametrageRubriqueExtournable      = new parametrageRubriqueExtournable()
        goPclie                               = new pclie()
        goRubriqueLibelleMultiple             = new parametrageRubriqueLibelleMultiple()        
    .

message "gga todo initialisationRubrique " giNumeroContrat gcTypeContrat viNumeroRubrique viNumeroQuittance  giNumeroMandat .

    run chgMoisQuittance(giNumeroMandat, input-output poCollectionContrat).
    ghProc = lancementPgm("bail/quittancement/quittanceEncours.p", goCollectionHandlePgm).
    run getListeQuittance in ghProc(poCollectionContrat, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    find first ttQtt
        where ttQtt.iNoQuittance = viNumeroQuittance no-error.
    if not available ttQtt then do:
        mError:createError({&error}, 1000823, string(viNumeroQuittance)).        // quittance &1 inexistante (ou déjà historisée)
        suppressionObjetPersistent().
        suppressionPgmPersistent(goCollectionHandlePgm).
        return.
    end.
    if ttQtt.iNombreRubrique >= {&NbRubMax} then do:
        mError:createError({&error}, 1000851, string({&NbRubMax})).              // Le nombre de rubrique a atteint le nombre maxi possible (&1)
        suppressionObjetPersistent().
        suppressionPgmPersistent(goCollectionHandlePgm).
        return.
    end.
    find first rubqt no-lock
        where rubqt.cdrub = viNumeroRubrique no-error.
    if not available rubqt then do:
        mError:createErrorGestion({&error}, 104126, string(viNumeroRubrique)).   // rubrique &1 inexistante
        suppressionObjetPersistent().
        suppressionPgmPersistent(goCollectionHandlePgm).
        return.
    end.
    create ttRubrique.
    assign
        ttRubrique.iNumeroLocataire   = giNumeroContrat
        ttRubrique.iNoQuittance       = viNumeroQuittance
        ttRubrique.iNorubrique        = viNumeroRubrique
        ttRubrique.iNoLibelleRubrique = 0
        ttRubrique.CRUD               = "C"
    .
    run chgInfoinitialisationRubrique.
    run verCreRub.
    if mError:erreur() then do:
        delete ttRubrique.
        suppressionObjetPersistent().
        suppressionPgmPersistent(goCollectionHandlePgm).
        return.
    end.
    if goParametrageRubriqueExtournable:isRubriqueExtournable(viNumeroRubrique) then run infOdExt.
    suppressionObjetPersistent().
    suppressionPgmPersistent(goCollectionHandlePgm).
end procedure.

procedure chgInfoinitialisationRubrique private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : extrait de adb/quit/crerubqt.p procedure MajEcran
    ------------------------------------------------------------------------------*/
    define variable vcTypeLibelle     as character no-undo.
    define variable vlProrataRubrique as logical   no-undo.
    define variable vlCumulRubrique   as logical   no-undo.
    define variable vclibelleIrf      as character no-undo.
    
    define buffer prrub for prrub.
    define buffer rubqt for rubqt.

    for first prrub no-lock
        where prrub.cdrub = ttRubrique.iNorubrique
          and prrub.cdlib > 0
          and prrub.cdaff = "00001"
      , first rubqt no-lock
        where rubqt.cdrub = prrub.cdrub
          and rubqt.cdlib = prrub.cdlib:
        ttRubrique.iNoLibelleRubrique = prrub.cdlib.
        run recLibRub (buffer rubqt, output ttRubrique.cLibelleRubrique, output vcTypeLibelle, output ttRubrique.lSaisieQuantitePrixUnit).
        if vcTypeLibelle = "GI"
        then assign
                ttRubrique.iFamille     = rubqt.cdfam
                ttRubrique.iSousFamille = rubqt.cdsfa
                ttRubrique.cCodeGenre   = rubqt.cdgen
                ttRubrique.cCodeSigne   = rubqt.cdsig
                vclibelleIrf            = recherchelibelleIrf(rubqt.prg05)               /* Affectation du libelle I.R.F.  */
            .
        else assign                                             //gga todo voir quel enregistrement prrub
                ttRubrique.iFamille     = prrub.cdfam
                ttRubrique.iSousFamille = prrub.cdsfa
                ttRubrique.cCodeGenre   = prrub.cdgen
                ttRubrique.cCodeSigne   = prrub.cdsig
                vclibelleIrf            = recherchelibelleIrf(prrub.cdirf)               /* Affectation du libelle I.R.F.  */
            .
    end.
message "chgInfoinitialisationRubrique libelle irf " vclibelleIrf vcTypeLibelle.           //gga todo voir si libelle IRF utile (a droite sur ecran maintenance rubrique)

    assign
        ttRubrique.cLibelleGenre  = outilTraduction:getLibelleParam("RUGEN", ttRubrique.cCodeGenre)
        ttRubrique.cLibelleSigne  = outilTraduction:getLibelleParam("RUSIG", ttRubrique.cCodeSigne)
        ttRubrique.lSaisieDateFin = (if ttRubrique.cCodeGenre = {&GenreRubqt-Fixe} or ttRubrique.iNoQuittance < 0 then no else yes)
    .
    if ttRubrique.cCodeGenre = {&GenreRubqt-Fixe} and ttQtt.iProrata <> 0 then do:
        run isRubProCum(ttRubrique.iNorubrique, ttRubrique.iNoLibelleRubrique, output vlProrataRubrique, output vlCumulRubrique).
        if vlProrataRubrique
        then assign
                 ttRubrique.lSaisieProrata       = yes
                 ttRubrique.iProrata             = ttQtt.iProrata
                 ttRubrique.iNumerateurProrata   = ttQtt.iNumerateurProrata
                 ttRubrique.iDenominateurProrata = ttQtt.iDenominateurProrata
         .
    end.
    if  (ttRubrique.cCodeSigne = {&SigneRubqt-Negatif} or ttRubrique.cCodeSigne = {&SigneRubqt-Avoir} or ttRubrique.cCodeSigne = {&SigneRubqt-Remboursement})
    or ((ttRubrique.cCodeSigne = {&SigneRubqt-RappelOuAvoir} or ttRubrique.cCodeSigne = {&SigneRubqt-ComplementOuRemboursement}) and ttRubrique.iNoLibelleRubrique >= 50)
    or (ttRubrique.cCodeSigne  = {&SigneRubqt-PositifOuNegatif} and ttRubrique.iNorubrique >= 800 and ttRubrique.cLibelleRubrique begins "Avoir") 
    then ttRubrique.cNegatif = yes.
    run MajDateApplication.

end procedure.

procedure initialisationRubriqueAssocie:
    /*------------------------------------------------------------------------------
    Purpose: extrait de adb/quit/crerubqt.p procedure MajEcran, CtlRubAss
             creation d'une rubrique lie
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input parameter poCollection        as class collection no-undo.
    define output parameter table for ttRubrique.

    define variable viNbrRubTrv           as integer no-undo.
    define variable viNumeroRubriqueDispo as integer no-undo.
    define variable viNumeroLibelleDispo  as integer no-undo.
    define variable viNumeroRubrique      as integer no-undo.
    define variable viNumeroLibelle       as integer no-undo.
    define variable viNumeroQuittance     as integer no-undo.

    define buffer ctrat for ctrat.
    define buffer rubqt for rubqt.
    define buffer bxrbp for bxrbp.

    empty temp-table ttQtt.
    empty temp-table ttRub.
    empty temp-table ttRubrique.

    assign
        giNumeroContrat                       = poCollectionContrat:getInt64("iNumeroContrat")
        gcTypeContrat                         = poCollectionContrat:getCharacter("cTypeContrat")
        viNumeroRubrique                      = poCollection:getInteger("iNumeroRubrique")
        viNumeroLibelle                       = poCollection:getInteger("iNumeroLibelleRubrique")
        viNumeroQuittance                     = poCollection:getInteger("iNumeroQuittance")
        giNumeroMandat                        = truncate(giNumeroContrat / 100000, 0)
        goCollectionHandlePgm                 = new collection()
        goParametrageRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet()
        goParametrageRubriqueExtournable      = new parametrageRubriqueExtournable()
        goPclie                               = new pclie()
        goRubriqueLibelleMultiple             = new parametrageRubriqueLibelleMultiple()
    .
    run chgMoisQuittance(giNumeroMandat, input-output poCollectionContrat).
    assign
        giMoisModifiable = poCollectionContrat:getInteger("iMoisModifiable")
        ghProc           = lancementPgm("bail/quittancement/quittanceEncours.p", goCollectionHandlePgm)
    .
    run getListeQuittance in ghProc(poCollectionContrat, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    find first ttQtt
        where ttQtt.iNoQuittance = viNumeroQuittance no-error.
    if not available ttQtt then do:
        mError:createError({&error}, 1000823, string(viNumeroQuittance)).    //quittance &1 inexistante (ou déjà historisée)
        suppressionObjetPersistent().
        suppressionPgmPersistent(goCollectionHandlePgm).
        return.
    end.
    find first ttRub
        where ttRub.iNoQuittance       = viNumeroQuittance
          and ttRub.iNorubrique        = viNumeroRubrique
          and ttRub.iNoLibelleRubrique = viNumeroLibelle no-error.
    if not available ttRub then do:
        mError:createErrorGestion({&error}, 104126, string(viNumeroRubrique)). //rubrique &1 inexistante
        suppressionObjetPersistent().
        suppressionPgmPersistent(goCollectionHandlePgm).
        return.
    end.
    find first ctrat no-lock
        where ctrat.tpcon = gcTypeContrat
          and ctrat.nocon = giNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 1000209, string(giNumeroContrat)). //contrat &1 inexistant
        suppressionObjetPersistent().
        suppressionPgmPersistent(goCollectionHandlePgm).
        return.
    end.
    /* recherche s'il existe des rubriques disponibles */
    {&_proparse_ prolint-nowarn(sortaccess)}
boucleRechRubAss:
    for each rubqt no-lock
        where rubqt.asrub = viNumeroRubrique
          and rubqt.aslib = viNumeroLibelle
      , each bxrbp no-lock
        where bxrbp.ntbai  = ctrat.ntcon
          and bxrbp.norub  = rubqt.cdrub
          and (bxrbp.cdgen = "00001" or bxrbp.cdgen = "00003")
          and bxrbp.nolib  = 0
        break by bxrbp.norub:
        if first-of(bxrbp.norub) then do:
            if not can-find(first ttRub
                            where ttRub.iNumeroLocataire   = giNumeroContrat
                              and ttRub.iNoQuittance       = viNumeroQuittance
                              and ttRub.iNorubrique        = rubqt.cdrub
                              and ttRub.iNoLibelleRubrique = rubqt.cdlib)
            then assign
                    viNumeroRubriqueDispo = bxrbp.norub
                    viNumeroLibelleDispo  = bxrbp.noLib
                    viNbrRubTrv           = viNbrRubTrv + 1
            .
            if viNbrRubTrv = 2 then leave boucleRechRubAss.
        end.
    end.
    if viNbrRubTrv = 0 then do:
        mError:createErrorGestion({&error}, 100818, substitute("&1-&2", viNumeroRubrique, viNumeroLibelle)). /* Aucune rubrique associée à la %1 n'est disponible */
        suppressionObjetPersistent().
        suppressionPgmPersistent(goCollectionHandlePgm).
        return.
    end.
    create ttRubrique.
    assign
        ttRubrique.iNumeroLocataire   = giNumeroContrat
        ttRubrique.iNoQuittance       = viNumeroQuittance
        ttRubrique.iNorubrique        = viNumeroRubriqueDispo
        ttRubrique.iNoLibelleRubrique = viNumeroLibelleDispo
        ttRubrique.CRUD               = "C"
    .
    run chgInfoinitialisationRubrique.
    run verCreRub.
    suppressionObjetPersistent().
    suppressionPgmPersistent(goCollectionHandlePgm).
    if mError:erreur() then do:
        delete ttRubrique.
        return.
    end.
end procedure.

procedure recLibRub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer rubqt for rubqt.
    define output parameter pcLibelleRubrique        as character no-undo.
    define output parameter pcTypeLibelle            as character no-undo.
    define output parameter plSaisieQuantitePrixUnit as logical   no-undo.

    define buffer prrub for prrub.

    assign
        pcLibelleRubrique        = outilTraduction:getLibelle(rubqt.nome1)
        pcTypeLibelle            = "GI"
        plSaisieQuantitePrixUnit = (if rubqt.prg06 = "Q" then true else false)           /*--> Flag saisie Quantite/Prix Unitaire */
    .
    /*--> On cherche s'il existe un parametrage pour le locataire */
    find first prrub no-lock
        where prrub.cdrub = rubqt.cdrub
          and prrub.cdlib = rubqt.cdlib
          and prrub.noloc = ttQtt.iNumeroLocataire
          and prrub.msqtt = ttQtt.iMoisTraitementQuitt
          and (prrub.noqtt = 0 or prrub.noqtt = ttQtt.iNoQuittance) no-error.               /* SY 0110/0230 - version > 10.29  */
    if available prrub
    then assign
            pcLibelleRubrique = prrub.lbrub
            pcTypeLibelle     = "CLI"
        .
    else for first prrub no-lock                     /* recherche parametrage cabinet */
         where prrub.cdrub = rubqt.cdrub
           and prrub.cdlib = rubqt.cdlib
           and prrub.noloc = 0
           and prrub.msqtt = 0
           and prrub.lbrub > "":
        assign
            pcLibelleRubrique = prrub.lbrub
            pcTypeLibelle     = "CLI"
        .
    end.

end procedure.

procedure setQuittancePrivate:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour quittance
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define input parameter poCollection as class collection no-undo.

    define variable viNumeroQuittance as integer no-undo.

    assign
        giNumeroContrat       = poCollectionContrat:getInt64("iNumeroContrat")
        gcTypeContrat         = poCollectionContrat:getCharacter("cTypeContrat")
        viNumeroQuittance     = poCollection:getInteger("iNumeroQuittance")
        giNumeroMandat        = truncate(giNumeroContrat / 100000, 0)
        goCollectionContrat   = poCollectionContrat
        goCollectionHandlePgm = new collection()
    .

message "gga todo setQuittance " giNumeroContrat gcTypeContrat viNumeroQuittance giNumeroMandat.

    find first ttRubrique where lookup(ttRubrique.CRUD, "C,U,D") > 0 no-error.
    if not available ttRubrique then return.

    empty temp-table ttQtt.
    empty temp-table ttRub.
    run chgMoisQuittance(giNumeroMandat, input-output goCollectionContrat).
    
    assign
        glBailFournisseurLoyer                = goCollectionContrat:getLogical("lBailFournisseurLoyer")
        giMoisModifiable                      = goCollectionContrat:getInteger("iMoisModifiable")
        ghProc                                = lancementPgm("bail/quittancement/quittanceEncours.p", goCollectionHandlePgm)
        goParametrageRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet()
        goParametrageRubriqueExtournable      = new parametrageRubriqueExtournable()
        goPclie                               = new pclie()
        goRubriqueLibelleMultiple             = new parametrageRubriqueLibelleMultiple()
    .
    run getListeQuittance in ghProc(goCollectionContrat, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    find first ttQtt
         where ttQtt.iNumeroLocataire = giNumeroContrat
           and ttQtt.iNoQuittance = viNumeroQuittance no-error.
    if not available ttQtt then do:
        mError:createError({&error}, 1000823, string(viNumeroQuittance)). //quittance &1 inexistante (ou déjà historisée)
        return.
    end.

    for each ttRubrique
       where ttRubrique.iNumeroLocataire = giNumeroContrat
         and ttRubrique.iNoQuittance     = viNumeroQuittance
         and ttRubrique.CRUD             = "D":
        run verSupRub.
        if mError:erreur() then return.

        run majSupRub.
        if mError:erreur() then return.
    end.
    for each ttRubrique
       where ttRubrique.iNumeroLocataire = giNumeroContrat
         and ttRubrique.iNoQuittance     = viNumeroQuittance
         and ttRubrique.CRUD             = "U":
        run verModRub.
        if mError:erreur() then return.

        run majModRub.
        if mError:erreur() then return.
    end.
    for each ttRubrique
       where ttRubrique.iNumeroLocataire = giNumeroContrat
         and ttRubrique.iNoQuittance     = viNumeroQuittance
         and ttRubrique.CRUD             = "C":
        run verCreRub.
        if mError:erreur() then return.
      
        run verZonSai.
        if mError:erreur() then return.

        run majCreRub.
        if mError:erreur() then return.
    end.

    ghProc = lancementPgm("bail/quittancement/majlocqt.p", goCollectionHandlePgm).
    run lancementMajlocqt in ghProc(input-output table ttQtt by-reference, input-output table ttRub by-reference).
    if mError:erreur() then return.

    ghProc = lancementPgm("adb/bien/majoff01.p", goCollectionHandlePgm).
    run lancementMajoff01 in ghProc(goCollectionContrat).
    if mError:erreur() then return.
    
    // Les objets créés sont supprimés dans setQuittance

//mError:createError({&error}, "fin test gg").
 
end procedure.

procedure setQuittance:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe 
    ------------------------------------------------------------------------------*/
    define input  parameter poCollectionContrat as class collection no-undo.
    define input  parameter poCollection as class collection no-undo.
    define input  parameter table for ttQuittance.                              //table echange ihm pour la maj
    define input  parameter table for ttRubrique.                               //table echange ihm pour la maj
    define input  parameter table for ttError.
    
    run setQuittancePrivate(poCollectionContrat, poCollection).

    delete object goParametrageRubriqueQuittHonoCabinet no-error.
    delete object goParametrageRubriqueExtournable no-error.
    delete object goPclie no-error.
    delete object goRubriqueLibelleMultiple no-error.

    suppressionPgmPersistent(goCollectionHandlePgm).
end procedure.

procedure verSupRub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de adb/quit/suprubqu.p
    ------------------------------------------------------------------------------*/
    define variable vlModAut as logical no-undo.
    define variable vlSupAut as logical no-undo.
    define variable vlLieAut as logical no-undo.

    find first ttRub
         where ttRub.iNumeroLocataire = ttRubrique.iNumeroLocataire
           and ttRub.iNoQuittance = ttRubrique.iNoQuittance
           and ttRub.iNorubrique = ttRubrique.iNorubrique
           and ttRub.iNoLibelleRubrique = ttRubrique.iNoLibelleRubrique no-error.
    if not available ttRub then do:
        mError:createError({&error}, 1000824, substitute("&2&1&3", separ[1], ttRubrique.iNorubrique, ttRubrique.iNoLibelleRubrique)). //suppression rubrique &1-&2 inexistante
        return.
    end.
    run isRubMod(goParametrageRubriqueQuittHonoCabinet, ttRub.iNorubrique, ttRub.iNoLibelleRubrique, ttRub.cCodeGenre, ttQtt.iNombreRubrique, ttQtt.cdori,
                 output vlModAut, output vlSupAut, output vlLieAut).
    if not vlSupAut then do:
        mError:createError({&error}, 1000825, substitute("&2&1&3", separ[1], ttRubrique.iNorubrique, ttRubrique.iNoLibelleRubrique)). //supression rubrique &1-&2 interdite
        return.
    end.

end procedure.

procedure verModRub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de
    ------------------------------------------------------------------------------*/
    define variable vlModAut as logical no-undo.
    define variable vlSupAut as logical no-undo.
    define variable vlLieAut as logical no-undo.

    find first ttRub
        where ttRub.iNumeroLocataire   = ttRubrique.iNumeroLocataire
          and ttRub.iNoQuittance       = ttRubrique.iNoQuittance
          and ttRub.iNorubrique        = ttRubrique.iNorubrique
          and ttRub.iNoLibelleRubrique = ttRubrique.iNoLibelleRubrique no-error.
    if not available ttRub then do:
        mError:createError({&error}, 1000826, substitute("&2&1&3", separ[1], ttRubrique.iNorubrique, ttRubrique.iNoLibelleRubrique)). //modification rubrique &1-&2 inexistante
        return.
    end.
    run isRubMod(goParametrageRubriqueQuittHonoCabinet, ttRub.iNorubrique, ttRub.iNoLibelleRubrique, ttRub.cCodeGenre, ttQtt.iNombreRubrique, ttQtt.cdori,
                 output vlModAut, output vlSupAut, output vlLieAut).
    if not vlModAut then do:
        mError:createError({&error}, 1000827, substitute("&2&1&3", separ[1], ttRubrique.iNorubrique, ttRubrique.iNoLibelleRubrique)). //modification rubrique &1-&2 inexistante
        return.
    end.
    run verZonSai.
    if mError:erreur() then return.

    run verLibelle.

end procedure.

procedure verCreRub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de
    ------------------------------------------------------------------------------*/
    define variable vcListeSsFamilleTVA as character no-undo initial "03,05,06,08".   //Init liste des sous-familles concernees par la TVA sur services annexes (famille 04)
    define variable vlInfMob            as logical   no-undo.
    define variable viCodeRegMob        as integer   no-undo.

    define buffer rubqt for rubqt.
    define buffer prrub for prrub.
    define buffer bxrbp for bxrbp.
    define buffer tache for tache.
    define buffer ctrat for ctrat.

    /* si mode de calcul calendrier d'evolution des loyers, interdire la création des rub 103 */
    if evolutionLoyer() and ttRubrique.iNorubrique = 103 then do:
        mError:createError({&error}, 1000829).     //Rubrique interdite. Ce bail est soumis à un calendrier d'évolution, la rubrique 103 est réservée aux calculs de rappel/avoir
        return.
    end.
    /* Ajout Sy le 25/01/2010 */
    find first rubqt no-lock
        where rubqt.cdrub = ttRubrique.iNorubrique no-error.
    if not available rubqt then do:
        mError:createErrorGestion({&error}, 104126, string(ttRubrique.iNorubrique)). //rubrique &1 inexistante
        return.
    end.
    assign
        ttRubrique.iFamille   = rubqt.cdfam
        ttRubrique.cCodeGenre = rubqt.cdgen
    .
    /* Test si l'en-tete de rubrique est affichable. */
    find first prrub no-lock
        where prrub.cdrub = ttRubrique.iNorubrique
          and prrub.cdlib =   0
          and prrub.cdaff = "00001" no-error.
    if not available prrub then do:
        mError:createError({&error}, 1000830).                //Rubrique non autorisée pour le cabinet (prrub)
        return.
    end.
    if not tvaServiceAnnexe()
    and rubqt.cdfam = {&FamilleRubqt-Administratif}
    and lookup(string(rubqt.cdsfa, "99"), vcListeSsFamilleTVA, ",") <> 0 then do:
        mError:createErrorGestion({&error}, 104919, "").   //Vous ne pouvez pas utiliser les rubriques Services Hôteliers avant%sd'avoir paramétré la tâche 'TVA sur services annexes'
        return.
    end.
    run verLibelle.
    if mError:erreur() then return.

    if goRubriqueLibelleMultiple:isLibelleMultiple()
    and isMultiLibelleRubAutorise(gcTypeContrat, giNumeroContrat, ttRubrique.iNorubrique)
    and (not glBailFournisseurLoyer or (glBailFournisseurLoyer and ttRubrique.iNorubrique <> 101) )
    then do:
        if can-find(first ttRub
                    where ttRub.iNumeroLocataire   = giNumeroContrat
                      and ttRub.iNoQuittance       = ttRubrique.iNoQuittance
                      and ttRub.iNorubrique        = ttRubrique.iNorubrique
                      and ttRub.iNoLibelleRubrique = ttRubrique.iNoLibelleRubrique)
        then mError:createErrorGestion({&error}, 110221, substitute("&2&1&3", separ[1], substitute("&1-&2", ttRubrique.iNorubrique, ttRubrique.iNoLibelleRubrique), giNumeroContrat)). /* La rubrique %1 existe déjà pour le locataire %2 */
    end.
    else do:
        if can-find(first ttRub
                    where ttRub.iNumeroLocataire = giNumeroContrat
                      and ttRub.iNoQuittance     = ttRubrique.iNoQuittance
                      and ttRub.iNorubrique      = ttRubrique.iNorubrique)
        then mError:createErrorGestion({&error}, 110221, substitute("&2&1&3", separ[1], ttRubrique.iNorubrique, giNumeroContrat)). /* La rubrique %1 existe déjà pour le locataire %2 */
    end.
    find first bxrbp no-lock
        where bxrbp.ntbai = ttQtt.cNatureBail
          and bxrbp.cdfam = ttRubrique.iFamille
          and bxrbp.norub = ttRubrique.iNorubrique
          and bxrbp.noord = -1 no-error.
    if available bxrbp then do:
        if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} then do:
            if ttRubrique.iNorubrique = 702
            then for last tache no-lock
                where tache.tpcon = {&TYPECONTRAT-bail}
                  and tache.nocon = giNumeroContrat
                  and tache.tptac = {&TYPETACHE-quittancement}:
                if tache.ntreg = "00002" then do:
                    mError:createError({&error}, 105651).    //saisie impossible bail sans taxe foncière
                    return.
                end.
            end.
        end.
        else do:
            /* Rubriques autorisees : Fixes ou variables */
            if lookup(rubqt.cdgen, substitute("&1,&2", {&GenreRubqt-Fixe}, {&GenreRubqt-Variable})) = 0 then do:
                mError:createErrorGestion({&error}, 100827, string(ttRubrique.iNorubrique)).   //la rubrique &1 n'est pas disponible
                return.
            end.
        end.
    end.
    else do:
        mError:createErrorGestion({&error}, 100827, string(ttRubrique.iNorubrique)). //la rubrique &1 n'est pas disponible
        return.
    end.

    /* test pour honoraires locataire sur quittancement */
    /* ajout SY le 16/10/2009 : Controle rub hono famille 08 */
    /* au moins un libellé avec un Article doit être paramétré */
    if prrub.cdfam = {&FamilleRubqt-HonoraireCabinet}
    and goParametrageRubriqueQuittHonoCabinet:auMoinsUnArticle(prrub.cdrub) = false then do:
        mError:createError({&error}, 1000831, string(prrub.cdrub,"999")).     //La rubrique d'honoraires cabinet &1 doit être paramétrée (libellé + article de facturation) avant de pouvoir être utilisée
        return.
    end.

    if goParametrageRubriqueQuittHonoCabinet:isDbParameter then do:
        if integer(mtoken:cRefPrincipale) = {&REFCLIENT-GIDEV} or integer(mtoken:cRefPrincipale) = {&REFCLIENT-GICLI}
        then do:
            if goParametrageRubriqueQuittHonoCabinet:ancienneRubriqueInterdite(prrub.cdrub)
            then do:
                if prrub.cdfam = {&FamilleRubqt-HonoraireCabinet}
                then mError:createError({&error}, 1000831, string(prrub.cdrub,"999")).     //La rubrique d'honoraires cabinet &1 doit être paramétrée (libellé + article de facturation) avant de pouvoir être utilisée
                else mError:createError({&error}, 1000832, string(prrub.cdrub,"999")).     //La rubrique &1 n'est plus autorisée.Vous devez utiliser les honoraires Cabinet (rub 8xx)
                return.
            end.
        end.
        else do:
            if goParametrageRubriqueExtournable:isRubriqueExtournable(prrub.cdrub)     // Anciennes rubriques EXTOURNABLES interdites
            then do:
                if prrub.cdfam = {&FamilleRubqt-HonoraireCabinet}
                then mError:createError({&error}, 1000831, string(prrub.cdrub,"999")).     //La rubrique d'honoraires cabinet &1 doit être paramétrée (libellé + article de facturation) avant de pouvoir être utilisée
                else mError:createError({&error}, 1000832, string(prrub.cdrub,"999")).     //La rubrique &1 n'est plus autorisée.Vous devez utiliser les honoraires Cabinet (rub 8xx)
                return.
            end.
        end.
    end.
    if can-find(first detail no-lock
                where detail.cddet = gcTypeContrat
                  and detail.nodet = giNumeroContrat
                  and detail.iddet = integer({&TYPETACHE-quittancementRubCalculees})
                  and detail.ixd01 = string(ttRubrique.iNorubrique, "999") + string(ttRubrique.iNorubrique, "99")) then do:
        mError:createError({&error}, 1000833, substitute("&2&1&3", separ[1], string(ttRubrique.iNorubrique, "999"), string(ttRubrique.iNorubrique, "99"))).   //La rubrique &1-&2 est une rubrique de quittancement calculée pour ce locataire. Saisie interdite
        return.
    end.
    goPclie:reload("TIER2").
    if goPclie:isDbParameter and integer(goPclie:zon01) = 1 then do:
        vlInfMob = yes.
        for first ctrat no-lock
            where ctrat.tpcon = gcTypeContrat
              and ctrat.nocon = giNumeroContrat:
             viCodeRegMob = ctrat.noref.
        end.
    end.

    /* Spécifique Crédit Lyonnais . Ancien  régime : rub 138 et 139 interdites */
    if vlInfMob and viCodeRegMob = 0
    and (ttRubrique.iNorubrique = 138 or ttRubrique.iNorubrique = 139) then do:
        mError:createError({&error}, 1000834).   //Les rubriques 138 et 139 sont interdites pour les collaborateurs soumis à l'ancien régime
        return.
    end.

end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    /* test sur le total */
    if ttRubrique.dMontantTotal = 0 then do:
        if (integer(mToken:cRefPrincipale) = {&REFCLIENT-LCLILEDEFRANCE} or integer(mToken:cRefPrincipale) = {&REFCLIENT-LCLPROVINCE}) and ttRubrique.iNorubrique = 101
        then do:
            if outils:questionnaireGestion(999999, "", table ttError by-reference) < 2     //Vous n'avez pas saisi de montant pour la rubrique. Confirmez-vous ?
            then return.
        end.
        else do:
            mError:createError({&error}, 100842).
            return.
        end.
    end.
    run MajDateApplication.

end procedure.

procedure VerLibelle private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    if ttRubrique.iNoLibelleRubrique >= 100 then do:
        mError:createError({&error}, 1000835, string(ttRubrique.iNoLibelleRubrique)).   //Erreur de libellé (> 99) : &1
        return.
    end.
    /* Ajout Sy le 19/10/2009 : libellé vide interdit */
    /* modif SY le 01/12/2009 - fiche 1109/0182 : sauf libellé 99 */
    if ttRubrique.iNoLibelleRubrique < 99 and (ttRubrique.cLibelleRubrique = ? or ttRubrique.cLibelleRubrique = "" or ttRubrique.cLibelleRubrique = outilTraduction:getLibelle(0)) then do:
        mError:createError({&error}, 1000836, substitute("&2&1&3", separ[1], string(ttRubrique.iNorubrique, "999"), string(ttRubrique.iNorubrique, "99"))).  //La rubrique &1-&2 n'a pas de libellé. Saisie interdite
        return.
    end.
    /* test sur le libelle de la rubrique 99. */
    if ttRubrique.iNoLibelleRubrique = 99 and (ttRubrique.cLibelleRubrique = ? or ttRubrique.cLibelleRubrique = "") then do:
        mError:createError({&error}, 102835).
        return.
    end.

end procedure.

procedure majModRub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdaDebutApplicationOld as date      no-undo.
    define variable vdaFinApplicationOld   as date      no-undo.

    for first ttQtt
        where ttQtt.iNumeroLocataire = ttRubrique.iNumeroLocataire
          and ttQtt.iNoQuittance = ttRubrique.iNoQuittance        // doit exister controle dans verzonsai
      , first ttRub
        where ttRub.iNumeroLocataire = ttRubrique.iNumeroLocataire
          and ttRub.iNoQuittance = ttRubrique.iNoQuittance
          and ttRub.iNorubrique = ttRubrique.iNorubrique
          and ttRub.iNoLibelleRubrique = ttRubrique.iNoLibelleRubrique:       // doit exister controle dans verzonsai
        if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER}
        then if ttQtt.iMoisTraitementQuitt >= giMoisModifiable
            then assign
                vdaDebutApplicationOld = ttRub.daDebutApplication
                vdaFinApplicationOld   = ttRub.daFinApplication
            .
            else assign
                vdaDebutApplicationOld = ttRub.daDebutApplication
                vdaFinApplicationOld   = ttQtt.daFinQuittancement
            .
        else assign
            vdaDebutApplicationOld = ttRub.daDebutApplication
            vdaFinApplicationOld   = ttRub.daFinApplication
        .
    end.
/*gga
        IF HwTglPro:SCREEN-VALUE = "YES"
        THEN CdProRub = 1.
        ELSE DO:
            /* SY : 17/06/1999 tester si on a d‚coch‚ le prorata */
            IF CdProIni <> 0
            THEN CdProRub = -1.
            ELSE CdProRub = 0.
        END.
gga*/

    if ttRubrique.cNegatif
    then assign
        ttRubrique.dMontantTotal = ttRubrique.dMontantTotal * -1
        ttRubrique.dMontantQuittance = ttRubrique.dMontantQuittance * -1
    .
    ghProc = lancementPgm("bail/quittancement/majrubtm.p", goCollectionHandlePgm).
    // todo  beaucoup de paramètres pour un run. peut-être passer le buffer ttRubrique en parametre ???
    run lancementMajrubtm in ghProc(
        goCollectionContrat,
        ttRubrique.iNoQuittance,
        ttRubrique.iNorubrique,
        '03',                     // modification
        ttRubrique.iFamille,
        ttRubrique.iSousFamille,
        ttRubrique.iNoLibelleRubrique,
        ttRubrique.cLibelleRubrique,         // plus de changement de libelle, mais supression rubrique-ancien libelle suivi de creation rubrique-nouveau libelle
        ttRubrique.cCodeGenre,
        ttRubrique.cCodeSigne,
        ttRubrique.cddet,
        ttRubrique.dQuantite,
        ttRubrique.dPrixunitaire,
        ttRubrique.dMontantTotal,
        ttRubrique.iProrata,         // gga todo
        ttRubrique.iNumerateurProrata,
        ttRubrique.iDenominateurProrata,
        ttRubrique.dMontantQuittance,
        ttRubrique.daDebutApplication,
        ttRubrique.daFinApplication,
        ttRubrique.daDebutApplicationPrecedente,
        ttRubrique.iNoOrdreRubrique,
        ttRubrique.iNoLibelleRubrique,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
    if mError:erreur() then return.

    /* redressement d'anomalies rub fixes "connues"
      1) "trous" dans la chaine de quittances
      2) date de debut d'application < celle de la 1ere quittance en cours (ex : 01/10/99 en avril et juil 2000 01/10/97 en octobre 2000 et suivants) */
    ghProc = lancementPgm("bail/quittancement/corlocrb.p", goCollectionHandlePgm).
    run trtCorlocrb in ghProc(
        ttRubrique.iNumeroLocataire,
        ttRubrique.iNoQuittance,
        ttRubrique.iNorubrique,
        ttRubrique.iNoLibelleRubrique,
        vdaDebutApplicationOld,
        vdaFinApplicationOld,
        "",
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
    if mError:erreur() then return.

    /* Lancement du module de répercussion sur les quittances futures et sauvegarde dans Equit */
    ghProc = lancementPgm("bail/quittancement/majlocrb.p", goCollectionHandlePgm).
    run trtMajlocrb in ghProc(
        ttRubrique.iNumeroLocataire,
        ttRubrique.iNoQuittance,
        ttRubrique.iNorubrique,
        ttRubrique.iNoLibelleRubrique,
        vdaDebutApplicationOld,
        vdaFinApplicationOld,
        "",
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
end procedure.

procedure majCreRub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdaFinApplicationOld as date no-undo.

    for first ttQtt
        where ttQtt.iNumeroLocataire = ttRubrique.iNumeroLocataire
          and ttQtt.iNoQuittance = ttRubrique.iNoQuittance:         // doit exister controle dans verzonsai
        vdaFinApplicationOld = ttQtt.daFinPeriode.
    end.
/*gga
        IF HwTglPro:SCREEN-VALUE = "YES"
        THEN CdProRub = 1.
        ELSE DO:
            /* SY : 17/06/1999 tester si on a d‚coch‚ le prorata */
            IF CdProIni <> 0
            THEN CdProRub = -1.
            ELSE CdProRub = 0.
        END.
gga*/

    if ttRubrique.cNegatif
    then assign
        ttRubrique.dMontantTotal     = ttRubrique.dMontantTotal     * -1
        ttRubrique.dMontantQuittance = ttRubrique.dMontantQuittance * -1
    .
    ghProc = lancementPgm("bail/quittancement/majrubtm.p", goCollectionHandlePgm).
    // todo  beaucoup de paramètres pour un run. peut-être passer le buffer ttRubrique en parametre ???
    run lancementMajrubtm in ghProc(
        goCollectionContrat,
        ttRubrique.iNoQuittance,
        ttRubrique.iNorubrique,
        '01',                     // creation
        ttRubrique.iFamille,
        ttRubrique.iSousFamille,
        ttRubrique.iNoLibelleRubrique,
        ttRubrique.cLibelleRubrique,         // plus de changement de libelle, mais supression rubrique-ancien libelle suivi de creation rubrique-nouveau libelle
        ttRubrique.cCodeGenre,
        ttRubrique.cCodeSigne,
        '00000',
        ttRubrique.dQuantite,
        ttRubrique.dPrixunitaire,
        ttRubrique.dMontantTotal,
        ttRubrique.iProrata,         // gga todo
        ttQtt.iNumerateurProrata,
        ttQtt.iDenominateurProrata,
        ttRubrique.dMontantQuittance,
        ttRubrique.daDebutApplication,
        ttRubrique.daFinApplication,
        '',
        0,
        0,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
    if mError:erreur() then return.

    /* Lancement du module de répercussion sur les quittances futures et sauvegarde dans Equit */
    ghProc = lancementPgm("bail/quittancement/majlocrb.p", goCollectionHandlePgm).
    run trtMajlocrb in ghProc(
        ttRubrique.iNumeroLocataire,
        ttRubrique.iNoQuittance,
        ttRubrique.iNorubrique,
        ttRubrique.iNoLibelleRubrique,
        ttRubrique.daDebutApplication,
        vdaFinApplicationOld,
        "",
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
end procedure.

procedure majSupRub private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de adb/quit/suprubqu.p    procedure suppression
    ------------------------------------------------------------------------------*/
    define variable vdaDebutApplicationOld as date no-undo.
    define variable vdaFinApplicationOld   as date no-undo.

    assign
        vdaDebutApplicationOld   = ttRub.daDebutApplication
        vdaFinApplicationOld     = ttRub.daFinApplication
        ttRub.daDebutApplication = ttQtt.daDebutPeriode
        ttRub.daFinApplication   = ttQtt.daFinPeriode
        ttQtt.cdmaj              = 1
        ghProc                   = lancementPgm("bail/quittancement/suplocrb.p", goCollectionHandlePgm)
    .

message "gga majSupRub " vdaDebutApplicationOld vdaFinApplicationOld ttRub.daDebutApplication ttRub.daFinApplication ttQtt.cdmaj.

    /* Repercussion sur les quittances futures */
    run trtSuplocrb in ghProc(
        ttRubrique.iNumeroLocataire,
        ttRubrique.iNoQuittance,
        ttRubrique.iNorubrique,
        ttRubrique.iNoLibelleRubrique,
        vdaDebutApplicationOld,
        vdaFinApplicationOld,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
    if mError:erreur() then return.

    ghProc = lancementPgm("bail/quittancement/majrubtm.p", goCollectionHandlePgm).
    run lancementMajrubtm in ghProc(
        goCollectionContrat,
        ttRubrique.iNoQuittance,
        ttRubrique.iNorubrique,
        '06',                           // suppression
        ttRubrique.iFamille,
        ttRubrique.iSousFamille,
        ttRubrique.iNoLibelleRubrique,
        '',
        ttRubrique.cCodeGenre,
        ttRubrique.cCodeSigne,
        ttRubrique.cddet,
        0,
        0,
        0,
        0,
        ttRubrique.iNumerateurProrata,
        ttRubrique.iDenominateurProrata,
        0,
        ?,
        ?,
        ttRubrique.daDebutApplicationPrecedente,
        ttRubrique.iNoOrdreRubrique,
        0,
        input-output table ttQtt by-reference,
        input-output table ttRub by-reference
    ).
end procedure.

procedure majDateApplication private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : a partir de adb/quit/crerubqu.p    procedure MajDateApplication
    ------------------------------------------------------------------------------*/
    define variable vcCdRetDat as character no-undo.

    assign
        ttRubrique.daDebutApplication = ?
        ttRubrique.daFinApplication   = ?
    .
    if ttRubrique.cCodeGenre = {&GenreRubqt-Resultat}
    then assign
        ttRubrique.daDebutApplication = ttQtt.daDebutPeriode
        ttRubrique.daFinApplication = ttQtt.daFinPeriode
    .
    else do:
        assign
            ttRubrique.daDebutApplication = ttQtt.daDebutQuittancement
            ghProc                        = lancementPgm("adblib/ctlappdt.p", goCollectionHandlePgm)
        .
        run lanceCtlappdt in ghProc(
            giNumeroContrat,
            ttRubrique.iNoQuittance,
            ttRubrique.iNorubrique,
            ttRubrique.iNoLibelleRubrique,
            ttRubrique.cCodeGenre,
            input-output ttRubrique.daDebutApplication,
            input-output ttRubrique.daFinApplication, 
            output vcCdRetDat,
            input-output table ttQtt by-reference,
            input-output table ttRub by-reference
        ).
//gga todo test code retour ?
    end.

    /* Specifique Manpower                   */
    /* Si creation d'une rubrique dans aquit */
    /* On force ttRubrique.daFinApplication a ttQtt.daFinQuittancement       */
    if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER}
    and ttQtt.daDebutQuittancement < date(giMoisModifiable modulo 100, 1, integer(truncate(giMoisModifiable / 100, 0)))
    then ttRubrique.daFinApplication = ttQtt.daFinQuittancement.

end procedure.

procedure getListeFamille:
    /*------------------------------------------------------------------------------
      Purpose: a partir de adb/quit/majqttp3.p (majqttp3_srv.p) procedure _main
      Notes:   service externe
    ------------------------------------------------------------------------------*/
    define output parameter table for ttFamilleRubrique.
    define buffer famqt for famqt.

    empty temp-table ttFamilleRubrique.
    goParametrageRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet().
    for each famqt no-lock
        where famqt.cdsfa =  0
          and famqt.cdfam >= {&FamilleRubqt-Loyer}
          and ((famqt.cdfam <> {&FamilleRubqt-HonoraireCabinet} and famqt.cdfam <> {&FamilleRubqt-TVAHonoraire}) or goParametrageRubriqueQuittHonoCabinet:isDbParameter):
        create ttFamilleRubrique.
        assign
            ttFamilleRubrique.iCodeFamille    = famqt.cdfam
            ttFamilleRubrique.cLibelleFamille = outilTraduction:getLibelle(famqt.nome1)
            ttFamilleRubrique.dMontant        = 0
        .
    end.
    delete object goParametrageRubriqueQuittHonoCabinet.
end procedure.

procedure infOdExt private:
    /*------------------------------------------------------------------------------
      Purpose: Procedure de gestion du libellé : 105375   , Fiche 0802/168
      Notes:   a partir de adb/quit/crerubqt.p (InfOdExt)
    ------------------------------------------------------------------------------*/
    define variable voEditionCRG as class parametrageEditionCRG no-undo.
    define buffer tache for tache.

    voEditionCRG = new parametrageEditionCRG().
    if voEditionCRG:isDbParameter
    then for first tache no-lock
        where tache.tptac = {&TYPETACHE-compteRenduGestion}
          and tache.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and tache.nocon = giNumeroMandat:
        // Cabinet Std sans rub extournable et Mandat Std avec rub extournable
        // Attention! OD automatique d'extourne remontant sur le CRG.
        if voEditionCRG:getCodeTypeEdition() = "00021" and tache.utreg = "00001"
        then mError:createError({&information}, 105375).
        // Cabinet Std avec rub extournable et Mandat Std sans rub extournable
        // Attention! OD automatique d'extourne ne remontant pas sur le CRG.
        else if voEditionCRG:getCodeTypeEdition() = "00001" and tache.utreg = "00021"
        then mError:createError({&information}, 107829).
    end.
    delete object voEditionCRG.
end procedure.
