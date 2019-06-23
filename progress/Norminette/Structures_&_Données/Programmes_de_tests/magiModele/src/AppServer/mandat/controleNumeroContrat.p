/*------------------------------------------------------------------------
File        : controleNumeroContrat.p
Purpose     : controle numero de contrat saisi (en creation de contrat)
Author(s)   : GGA  -  2017/08/25
Notes       : reprise du pgm adb/cont/selnomdt.p
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}

using parametre.pclie.parametrageFournisseurLoyer.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{mandat/include/listeNumeroContratDispo.i}
{application/include/glbsepar.i}

define variable gcMandatLocation   as character no-undo.
define variable gcMandatLocSousLoc as character no-undo.
assign
    gcMandatLocation   = substitute('&1,&2,&3', {&NATURECONTRAT-mandatLocation}, {&NATURECONTRAT-mandatLocationDelegue}, {&NATURECONTRAT-mandatLocationIndivision})
    gcMandatLocSousLoc = substitute('&1,&2,&3', gcMandatLocation, {&NATURECONTRAT-mandatSousLocation}, {&NATURECONTRAT-mandatSousLocationDelegue})
.

procedure controleNumeroContrat:
    /*------------------------------------------------------------------------------
    Purpose:  controle numero de contrat saisi (en creation de contrat)
    Notes  :  service externe
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter pcNatureContrat as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.

    define variable vlGesFlo   as logical   no-undo.
    define variable vcCdModele as character no-undo initial "00001".
    define variable viNoSloDeb as integer   no-undo initial 1.
    define variable viNoSloFin as integer   no-undo initial 200.
    define variable viNoFloDeb as integer   no-undo initial 8001.
    define variable viNoFloFin as integer   no-undo initial 8200.
    define variable voFournisseurLoyer as class parametrageFournisseurLoyer no-undo.

    /* Recherche parametre GESFL (fournisseur de loyer) - Récupération du modele */
    voFournisseurLoyer = new parametrageFournisseurLoyer("00001").
    if voFournisseurLoyer:isDbParameter
    then assign
        vlGesFlo   = yes
        vcCdModele = voFournisseurLoyer:getCodeModele()
        viNoSloDeb = voFournisseurLoyer:getImmeubleDebut()
        viNoSloFin = voFournisseurLoyer:getImmeubleFin()
        viNoFloDeb = voFournisseurLoyer:getFournisseurLoyerDebut()
        viNoFloFin = voFournisseurLoyer:getFournisseurLoyerFin()
    .
    delete object voFournisseurLoyer. 
    run verNumVal(pcTypeContrat, pcNatureContrat, piNumeroContrat, vlGesFlo, vcCdModele, viNoFloDeb, viNoFloFin, viNoSloDeb, viNoSloFin).
    if mError:erreur() then return.
    if can-find (first ctrat no-lock
                 where ctrat.tpcon = pcTypeContrat
                   and ctrat.nocon = piNumeroContrat)
    or can-find (first ietab no-lock
                 where ietab.soc-cd = integer(mtoken:cRefPrincipale)
                   and ietab.etab-cd = piNumeroContrat)
    then mError:createError({&error}, 107743).

end procedure.

procedure VerNumVal private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeContrat   as character no-undo.
    define input  parameter pcNatureContrat as character no-undo.
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter plGesFlo        as logical   no-undo.
    define input  parameter pcCdModele      as character no-undo.
    define input  parameter piNoFloDeb      as integer   no-undo.
    define input  parameter piNoFloFin      as integer   no-undo.
    define input  parameter piNoSloDeb      as integer   no-undo.
    define input  parameter piNoSloFin      as integer   no-undo.

    define variable vlFgNumCor as logical   no-undo.
    define variable vcLbLstTra as character no-undo.
    define buffer aprof for aprof.

    if piNumeroContrat <= 0 or piNumeroContrat = ?
    then do:
        mError:createError({&error}, 108467).
        return.
    end.

    /* Controle des tranches autorisée en fonction de la nature de contrat */
    /* par defaut on ne le trouve pas dans les tranches */
    vlFgNumCor = false.
    /* ajout SY le 02/10/2008 */
    {&_proparse_ prolint-nowarn(wholeindex)}
    for first aprof no-lock                // whole index acceptable car peu d'enregistrements.
        where aprof.mandatdeb <= piNumeroContrat
          and aprof.mandatfin >= piNumeroContrat:
        if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} and aprof.profil-cd <> 21
        then do:
            mError:createError({&error}, 1000612, string(piNumeroContrat)).         //Le numéro &1 n'est pas autorisé pour la gérance (c.f table des profils)
            return.
        end.
        if pcTypeContrat = {&TYPECONTRAT-mandat2Syndic} and aprof.profil-cd <> 91
        then do:
            mError:createError({&error}, 1000613, string(piNumeroContrat)).         //Le numéro &1 n'est pas autorisé pour la copropriété (c.f table des profils
            return.
        end.
        /* Ajout SY le 21/10/2008 : controle avec nouvelle zone mandat FL de la table des profils */
        if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} and aprof.profil-cd = 21
        then do:
            if lookup(pcNatureContrat, gcMandatLocation) = 0
            then do:
                if aprof.fgfloy = yes
                then do:
                    mError:createError({&error}, 1000614, string(piNumeroContrat)). //Le numéro &1 est réservée aux mandats <Location> (c.f Mandat FL dans table des profils
                    return.
                end.
            end.
            else do:
                if aprof.fgfloy = no
                then do:
                   mError:createError({&error}, 1000615, string(piNumeroContrat)). //Le numéro &1 n'est pas autorisé pour les mandats <Location> (c.f Mandat FL dans table des profils
                   return.
                end.
            end.
        end.
    end.

    if plGesFlo and pcCdModele < "00003" and lookup(pcNatureContrat, gcMandatLocation) = 0
    then do:
        if piNumeroContrat >= piNoFloDeb and piNumeroContrat <= piNoFloFin
        then do:
            mError:createError({&error}, 1000616, substitute("&2&1&3", separ[1], piNoFloDeb, piNoFloFin)). //La tranche &1-&2 est réservée aux mandats <Location> (c.f. paramètre Gestion des Fournisseurs de loyer
            return.
        end.
    end.
    /* Modif SY le 22/10/2008: les tranches mandat FL sont maintenant distinctes des standards */
boucle:
    for each aprof no-lock
        where aprof.profil-cd = if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} then 21 else 91:
        if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance}
        then do:
            if lookup(pcNatureContrat, gcMandatLocation) > 0
            then do:
                if aprof.fgfloy = no then next boucle.
            end.
            else do:
                if aprof.fgfloy = yes then next boucle.
            end.
        end.
        if piNumeroContrat >= aprof.mandatdeb and piNumeroContrat <= aprof.mandatfin
        then do:
            vlFgNumCor = true.
            leave boucle.
        end.
        /* au passage sauvegarde des tranches pour le message d'erreur */
        vcLbLstTra = substitute('&1&2&3 &4 &5 &6 ',
                                vcLbLstTra,
                                chr(10),
                                if vcLbLstTra > "" then outilTraduction:getLibelle(106104) else outilTraduction:getLibelle(100135),
                                aprof.mandatdeb,
                                outilTraduction:getLibelle(100132),
                                aprof.mandatfin).
    end.
    if vlFgNumCor = false
    then do:
        /* le numero pour un mandat xxx doit etre inclus dans la tranche x-y */
        mError:createErrorGestion({&error}, 108882, substitute('&2&1&3', separ[1], outilTraduction:getLibelleProg("O_COT", pcNatureContrat), vcLbLstTra)).
        return.
    end.
    /* Ajout SY le 04/01/2010: controle création mandat "normal" pour qu'il saute la tranche sous-location */
    if plGesFlo
    then do:
        if (pcCdModele = "00003" or pcCdModele = "00004") and lookup(pcNatureContrat, gcMandatLocSousLoc) = 0
        then do:
            if piNumeroContrat >= piNoSloDeb and piNumeroContrat <= piNoSloFin
            then do:
                mError:createError({&error}, 1000617, substitute("&2&1&3", separ[1], piNoSloDeb, piNoSloFin)). //La tranche &1-&2 est réservée aux mandats <Sous-Location> (c.f. paramètre Gestion des Fournisseurs de loyer
                return.
            end.
        end.
    end.
end procedure.

