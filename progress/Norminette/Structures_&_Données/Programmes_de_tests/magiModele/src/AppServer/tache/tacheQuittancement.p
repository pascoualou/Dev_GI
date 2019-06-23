/*------------------------------------------------------------------------
File        : tacheQuittancement.p
Purpose     :
Author(s)   : kantena  -  2017/11/29
Notes       : sylbxqtt.p
derniere revue: 2018/08/14 - phm: KO
        traiter les todo
----------------------------------------------------------------------*/
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/mode2reglement.i}
{preprocesseur/referenceClient.i}
{preprocesseur/param2locataire.i}
{preprocesseur/codePeriode.i}
{preprocesseur/etat2renouvellement.i}
{preprocesseur/phase2renouvellement.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametragePeriodiciteQuittancement.
using parametre.pclie.parametragePrelevementAutomatique.
using parametre.pclie.parametrageRelocation.
using parametre.pclie.parametrageSEPA.
using parametre.syspg.syspg.
using parametre.syspr.syspr.
using parametre.syspr.parametrageMAD.
using parametre.syspg.parametrageTache.
using parametre.pclie.parametrageRubriqueQuittHonoCabinet.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}
{application/include/combo.i}
{bail/include/parametrageQuitt.i}
{bail/include/tbtmpqtt.i}
{bail/include/tbtmprub.i}
{crud/include/equit.i}
{crud/include/pquit.i}
{crud/include/rlctt.i}
{crud/include/unite.i}
{application/include/error.i}
{tache/include/tache.i}
{bail/include/tbtmprub.i &nomtable=ttRubriqueRegularisation} 

define temp-table ttBanquePrelevement no-undo                   // TbBquPrel
    field cdBqu     as character
    field NoMDt     as integer
    field fmtprl    as character   /* Ajout SY le 15/01/2013 format prélèvements : CFONB /  SEPA */
    field fmtvir    as character   /* Ajout SY le 15/01/2013 futur format virements : CFONB /  SEPA */
    field fg-defaut as logical
.
define variable goCollectionHandlePgm as class collection no-undo.
define variable goCollectionContrat   as class collection no-undo.

define variable ghProc                     as handle    no-undo.
define variable giNumeroContrat            as int64     no-undo.    // NoCttUse
define variable gcTypeContrat              as character no-undo.    // TpCttUse
define variable gcTypeRole                 as character no-undo.    // TpRolUse    
define variable giNumeroMandat             as int64     no-undo.    // NoMdtUse
define variable glPrelevementAuto          as logical   no-undo.    // FgPrlAut
define variable giJourPrelevement          as integer   no-undo.    // NoJouPrl
define variable gcMoisPrelevement          as character no-undo.    // CdMspDef
define variable glPrelevementMens          as logical   no-undo.    // FgPrlMens
define variable glBailFournisseurLoyer     as logical   no-undo.    // FgBaiFlo
define variable giComp-Etab-cd             as integer   no-undo.    // Comp-Etab-cd
define variable gcComp-cptg-cd             as character no-undo.    // Comp-cptg-cd
define variable gcComp-sscpt-cd            as character no-undo.    // Comp-sscpt-cd
define variable giNumeroQuittance          as integer   no-undo.    // NoQttTch
define variable glFournisseurLoyer         as logical   no-undo.    // NoQttTch
define variable gcCodeModeleFlo            as character no-undo.    // CdModele
define variable giNombreMoisQuittFlo       as integer   no-undo.    // NbmGESFL
define variable giPeriodicite              as integer   no-undo.    // NbMQTPER
define variable glQuittanceAvance          as logical   no-undo.    // FgQttAva
define variable gcCodeEdition              as character no-undo.    // CdEdtCab
define variable gcTypeTraitement           as character no-undo.    // cdactuse 
define variable giMoisModifiable           as integer   no-undo.
define variable giMoisQuittancement        as integer   no-undo.
define variable giMoisEchu                 as integer   no-undo.
define variable gdaFinOld                  as date      no-undo.

{outils/include/lancementProgramme.i}               // fonctions lancementPgm, suppressionPgmPersistent
{adblib/include/expweb2.i}                         // f_ctratactiv  f_ctrat_tiers_actif
{bail/quittancement/procedureCommuneQuittance.i}    // procédures chgMoisQuittance, isRubMod

function PrcResBai returns logical private ():
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  :   a partir de adb/comm/isbaires.i 
    ------------------------------------------------------------------------------*/      
    define buffer ctrat for ctrat.
    define buffer aquit for aquit.

    for first ctrat no-lock
        where ctrat.tpcon = gcTypeContrat
          and ctrat.nocon = giNumeroContrat
          and ctrat.dtree <> ?: 
        {&_proparse_ prolint-nowarn(use-index)}
        find last aquit no-lock 
            where aquit.noloc = giNumeroContrat
              and aquit.fgfac = no
            use-index ix_aquit03 no-error.    // noloc, msqtt
        if available aquit 
        then return if ctrat.dtree > aquit.dtfpr then true else false.    // laisser true/false à cause de date ?
        else return if ctrat.dtree < today       then false else true.
    end.
    return true. 
end function.

procedure initCombo:
    /*------------------------------------------------------------------------------
      Purpose: Procedure de chargement des combos de la fiche quittance
      Notes:   service externe (beQuittancement.cls)
    ------------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define output parameter table for ttCombo.
    define output parameter table for ttBanquePrelevement.

    define variable voSyspg        as class syspg          no-undo.
    define variable voParametreMAD as class parametrageMAD no-undo.
    
    define variable viI                    as integer   no-undo.
    define variable vlBailFournisseurLoyer as logical   no-undo.
    define variable viNumeroTiers          as integer   no-undo.    // NoTieUse
    define variable viNombreCompteTiers    as integer   no-undo.    // NbBquTie
    define variable vlBanquePrelevVirement as logical   no-undo.    // FgBquPrlVir
    define variable vcIBAN-BICUse          as character no-undo.
    define variable vlBquSepa              as logical   no-undo.    // FgBquSepa

    define buffer ctrat for ctrat. 

    assign
        giNumeroContrat       = poCollectionContrat:getInt64("iNumeroContrat")
        gcTypeContrat         = poCollectionContrat:getCharacter("cTypeContrat")
        gcTypeRole            = poCollectionContrat:getCharacter("cTypeRole")
        giNumeroMandat        = truncate(giNumeroContrat / 100000, 0)
        goCollectionContrat   = poCollectionContrat
        goCollectionHandlePgm = new collection()   
        voSyspg               = new syspg()
        voParametreMAD        = new parametrageMAD()
    .
    run chargeParametreClientPrelevement.
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = giNumeroMandat:
        vlBailFournisseurLoyer = ctrat.fgfloy.
    end.
    
    run chgBquMandat.
    
    run chgInfoBanque(output viNumeroTiers, output viNombreCompteTiers, output vlBanquePrelevVirement, output vcIBAN-BICUse, output vlBquSepa).
    if mError:erreur() then return.   
    
    ghProc = lancementPgm("application/libelle/labelLadb.p", goCollectionHandlePgm).
    run getCombolabel in ghProc("CMBPERIODICITEQTT,CMBECHEANCELOYER,CMBMOISPRELEVQTT,CMBREPRISESOLDE,CMBOUINON,CMBTYPEEDITIONQUITTANCE", output table ttCombo).
 
    if not can-find(first tache no-lock
                    where tache.tpcon = gcTypeContrat
                      and tache.nocon = giNumeroContrat
                      and tache.tptac = {&TYPETACHE-quittancement})
    then do:
        run chargeParametrePeriodicite.
        run chargeParametreGESFL.
        if (not vlBailFournisseurLoyer and giPeriodicite = 3)
        or (vlBailFournisseurLoyer and giNombreMoisQuittFlo = 3) then do:
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-mensuel}           : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-bimestrielJanFev}  : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-bimestrielFevMar}  : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-trimestrielFevAvr} : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-trimestrielMarMai} : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-semestrielFevJui}  : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-semestrielMarAou}  : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-semestrielAvrSep}  : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-semestrielMaiOct}  : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-semestrielJunNov}  : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-AnnuelFevJan}      : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-AnnuelMarFev}      : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-AnnuelAvrMar}      : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-AnnuelMaiAvr}      : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-AnnuelJunMai}      : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-AnnuelJuiJun}      : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-AnnuelAouJui}      : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-AnnuelSepAou}      : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-AnnuelOctSep}      : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-AnnuelNovOct}      : delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBPERIODICITEQTT" and ttCombo.cCode = {&PERIODICITEQUITTANCE-AnnuelDecNov}      : delete ttCombo. end.
        end.    
    end.
    ghProc = lancementPgm("bail/outilColocation.p", goCollectionHandlePgm).
    if dynamic-function('isColocation' in ghProc, gcTypeContrat, giNumeroContrat)
    then voParametreMAD:getComboMAD(output table ttCombo by-reference).
    else voParametreMAD:getComboParametre("MDNET", "CMBMAD", output table ttCombo by-reference).

    //mode de reglement
    voSyspg:creationComboSysPgZonXX("R_MDC", "CMBMODEREGLEMENT", "L", gcTypeContrat, output table ttCombo by-reference).
    if vcIBAN-BICUse = ? or vcIBAN-BICUse = "" or not f_ctrat_tiers_actif(viNumeroTiers, false)     /* On supprime l'option <Prélevement en ligne> pour ce mandat si IBAN non fournie ou si tiers non connecte Giextranet */ 
    then for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-prelevementEnLigne}: delete ttCombo. end.

    if vlBailFournisseurLoyer /*--> Cas mandat de nature 'Mandat de Location' => Locataire = Fournisseur Loyer */
    then do:
        for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-TIP}: delete ttCombo. end. /*pas de TIP*/
        if integer(mToken:cRefPrincipale) <> {&REFCLIENT-LCLILEDEFRANCE} and integer(mToken:cRefPrincipale) <> {&REFCLIENT-LCLPROVINCE} /* Pas de prelevement sauf CREDIT LYONNAIS */ 
        then do:
            for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-prelevement}: delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-prelevementEnLigne}: delete ttCombo. end.
        end.
        for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-prelevementMensuel}: delete ttCombo. end.
        if viNombreCompteTiers = 0 or vlBanquePrelevVirement = false /* Virement autorise si RIB */ 
        then for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-virement}: delete ttCombo. end.
        else do:
        /* initialiser à virement */   //gga todo
        end.
    end.
    else do:
        /* Supprimer l'option 'prelevement' de la combo si le locataire n'a aucune banque ou s'il n'y a pas le parametre client prelevement automatique */
        /* dans tous les cas on enleve le mode de reglement : prelevement Manpower */
        if vlBanquePrelevVirement = no or glPrelevementAuto = no or integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} 
        then do:
            for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-prelevement}: delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-prelevementEnLigne}: delete ttCombo. end.
            for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-prelevementMensuel}: delete ttCombo. end.
        end.        
        if not glPrelevementMens
        then for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-prelevementMensuel}: delete ttCombo. end.
    end.
    if integer(mToken:cRefPrincipale) = {&REFCLIENT-MANPOWER} /* Manpower : Suppression des options non gerees - Especes et TIP */
    then do :
        for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-especes}: delete ttCombo. end.
        for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-TIP}: delete ttCombo. end.
        for first ttCombo where ttCombo.cNomCombo = "CMBMODEREGLEMENT" and ttCombo.cCode = {&MODEREGLEMENT-prelevementMensuel}: delete ttCombo. end.
    end.
    do viI = 1 to 28:
        voSyspg:creationttCombo("CMBJOUR", string(viI), string(viI), output table ttCombo by-reference).
    end. 
    delete object voSyspg.
    delete object voParametreMAD.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure chargeParametreGESFL private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voParametreFournisseurLoyer as class parametrageFournisseurLoyer no-undo.

    voParametreFournisseurLoyer = new parametrageFournisseurLoyer().
    assign
        glFournisseurLoyer   = voParametreFournisseurLoyer:isGesFournisseurLoyer()
        gcCodeModeleFlo      = voParametreFournisseurLoyer:getCodeModele()
        giNombreMoisQuittFlo = voParametreFournisseurLoyer:getNombreMoisQuittance()
    .
    delete object voParametreFournisseurLoyer.
end procedure.

procedure chargeParametrePeriodicite private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes:
    ------------------------------------------------------------------------------*/
    define variable voParametrePeriodiciteQuittancement as class parametragePeriodiciteQuittancement no-undo.

    assign 
        giPeriodicite                       = 1
        glQuittanceAvance                   = false
        gcCodeEdition                       = "00001"
        voParametrePeriodiciteQuittancement = new parametragePeriodiciteQuittancement()
        glQuittanceAvance                   = voParametrePeriodiciteQuittancement:isAvance()
        giPeriodicite                       = voParametrePeriodiciteQuittancement:getNombreMoisQuittance()
        gcCodeEdition                       = voParametrePeriodiciteQuittancement:geCodeEditCab()
    . 
    delete object voParametrePeriodiciteQuittancement.
end procedure.

procedure chgInfoNumeroQuittance private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes:   extrait de LoaObjTch 
    ------------------------------------------------------------------------------*/
    define output parameter plModifDateEntree      as logical no-undo initial yes.
    define output parameter plModifCodePeriodicite as logical no-undo initial yes.
    define output parameter plModifCodeTerme       as logical no-undo initial yes.

    define variable vlQuittanceHisto as logical no-undo.                   // NbQttHst
    define variable vlQuittanceEmise as logical no-undo.                   // FgQttEmi

    define buffer pquit for pquit.
    define buffer aquit for aquit.
    define buffer equit for equit.

    /* tester si on est en 1er transfert ou valid.
       si 1er trf => on peut modifier la date d'appli, la periodicité et le terme
       si validation: on grise les zones.
       SIMULATION DE QUITTANCE EMISE OU NON EMISE */
    {&_proparse_ prolint-nowarn(use-index)}
    if gcTypeContrat = {&TYPECONTRAT-preBail}
    then for first pquit no-lock
             where pquit.noloc = giNumeroContrat
             use-index ix_pquit03:                // noloc, msqtt
        giNumeroQuittance = pquit.noqtt.
    end.
    else do:
        /* Test si le locataire a des quittances historisees */
        if can-find(first aquit no-lock
                    where aquit.noloc = giNumeroContrat
                      and aquit.noqtt > 0)
        then vlQuittanceHisto = yes.
        /* Test si la prochaine quittance a ete emise */
        for first equit no-lock
            where equit.noloc = giNumeroContrat
              and equit.msqtt >= (if glBailFournisseurLoyer then giMoisModifiable else giMoisEchu):  /* AJout SY le 12/01/2015 pour ne pas prendre les Avis d'échéance périmés (Pb plantage PEC, equit non historisé) */
            giNumeroQuittance = equit.noqtt.
            if glFournisseurLoyer and glBailFournisseurLoyer 
            then do: /* modif SY le 16/09/2008 */
                if giMoisModifiable = giMoisQuittancement or equit.msqtt > giMoisModifiable 
                then vlQuittanceEmise = false.
            end.
            else if (equit.cdter = {&TERMEQUITTANCEMENT-avance} and equit.msqtt > giMoisModifiable)
                 or (equit.cdter = {&TERMEQUITTANCEMENT-echu} and equit.msqtt > giMoisEchu)
            then vlQuittanceEmise = false.
            else vlQuittanceEmise = if (equit.cdter = {&TERMEQUITTANCEMENT-avance} and giMoisModifiable = giMoisQuittancement)
                                    or (equit.cdter = {&TERMEQUITTANCEMENT-echu} and giMoisEchu       = giMoisQuittancement) 
                                    then false else true.               /* 1er transfert non fait */
        end.
    end.
    if vlQuittanceEmise
    then assign
        plModifDateEntree      = no
        plModifCodePeriodicite = no
        plModifCodeTerme       = no
    .
    if vlQuittanceHisto 
    then plModifDateEntree = no.
    else assign
        plModifDateEntree      = yes
        plModifCodePeriodicite = yes
        plModifCodeTerme       = yes
    .

end procedure.

procedure chgInfoBanque private:
    /*------------------------------------------------------------------------------
      Purpose: 
      Notes:   extrait de prmobqtt.p/LoaObjTch 
    ------------------------------------------------------------------------------*/
    define output parameter piNumeroTiers          as integer   no-undo.    // NoTieUse
    define output parameter piNombreCompteTiers    as integer   no-undo.    // NbBquTie
    define output parameter plBanquePrelevVirement as logical   no-undo.    // FgBquPrlVir
    define output parameter pcIBAN-BICUse          as character no-undo.    // IBAN-BICUse
    define output parameter plBquSepa              as logical   no-undo.    // FgBquSepa

    define variable vlNumeroContratBanqueTiers as int64   no-undo.          // NoCttBqu
    define variable vlBquRib                   as logical no-undo.          // FgBquRib

    define buffer vbRoles  for roles.
    define buffer rlctt    for rlctt.
    define buffer ctanx    for ctanx.

    /* Recuperation du no Tiers du Locataire */
    for first vbRoles no-lock
        where vbRoles.TpRol = gcTypeRole
          and vbRoles.NoRol = giNumeroContrat:
        piNumeroTiers = vbRoles.NoTie.
    end.
    /* Recherche si le tiers a au moins 1 banque */
    ghProc = lancementPgm("crud/ctanx_CRUD.p", goCollectionHandlePgm).
    piNombreCompteTiers = dynamic-function('getNombreContratAnnexe' in ghproc, {&TYPECONTRAT-RIB}, {&TYPEROLE-tiers}, piNumeroTiers).    
    /* Si le tiers a des banques mais pas le bail alors creer le lien banque du contrat bail avec la banque par defaut */
    
    if piNombreCompteTiers > 0 then do:
        find first rlctt no-lock 
            where rlctt.tpidt = gcTypeRole
              and rlctt.noidt = giNumeroContrat
              and rlctt.tpct1 = gcTypeContrat
              and rlctt.noct1 = giNumeroContrat
              and rlctt.tpct2 = {&TYPECONTRAT-RIB} no-error.
        if not available rlctt
        then for first ctanx no-lock 
            where ctanx.tpcon = {&TYPECONTRAT-RIB}
              and ctanx.tprol = {&TYPEROLE-tiers}
              and ctanx.norol = piNumeroTiers
              and ctanx.tpact = "DEFAU":
            empty temp-table ttRlctt.
            create ttRlctt.
            assign
                ttRlctt.tpidt = gcTypeRole
                ttRlctt.noidt = giNumeroContrat
                ttRlctt.tpct1 = gcTypeContrat
                ttRlctt.noct1 = giNumeroContrat
                ttRlctt.tpct2 = ctanx.tpcon
                ttRlctt.noct2 = ctanx.nocon
                ttRlctt.lbdiv = ""
                ttRlctt.CRUD  = "C"
                ghProc        = lancementPgm("crud/rlctt_CRUD.p", goCollectionHandlePgm)
            .
            run setrlctt in ghProc(table ttRlctt by-reference).
            if mError:erreur() then return.          
            vlNumeroContratBanqueTiers = ctanx.nocon.
        end.
        else vlNumeroContratBanqueTiers = rlctt.noct2.
        if vlNumeroContratBanqueTiers > 0 then do:
            find first ctanx no-lock
                where ctanx.tpcon = {&TYPECONTRAT-RIB}
                  and ctanx.nocon = vlNumeroContratBanqueTiers no-error.
            if available ctanx 
            then do:
                assign
                    pcIBAN-BICUse = substitute('&1-&2', ctanx.iban, ctanx.bicod)
                    ghProc        = lancementPgm("outils/controleBancaire.p", goCollectionHandlePgm)
                .
                /* Ajout SY le 15/01/2013: Rechercher si le locataire est dans la zone RIB ou la zone SEPA */  
                if dynamic-function('isZoneRIB' in ghProc, ctanx.iban)
                then assign
                    vlBquRib               = true
                    plBanquePrelevVirement = true
                .
                if can-find(first iparm no-lock where iparm.tppar = "SEPA") and dynamic-function('isZoneSEPA' in ghProc, ctanx.iban, ctanx.bicod)
                then assign
                    plBquSepa              = true
                    plBanquePrelevVirement = true
                .
            end.
            else vlNumeroContratBanqueTiers = 0.
        end.
    end.
   
end procedure.

procedure chgBquMandat private:
/*------------------------------------------------------------------------------
  Purpose:
  Notes:
------------------------------------------------------------------------------*/
    define buffer ietab   for ietab.
    define buffer vbietab for ietab.
    define buffer ijou    for ijou.
    define buffer ibque   for ibque.
    define buffer aetabln for aetabln.

    empty temp-table ttBanquePrelevement.
    for first ietab no-lock
        where ietab.soc-cd  = integer(mtoken:cRefGerance)
          and ietab.etab-cd = giNumeroMandat
      , each aetabln no-lock
        where aetabln.soc-cd  = ietab.soc-cd
          and aetabln.etab-cd = giNumeroMandat:
        create ttBanquePrelevement.
        assign
            ttBanquePrelevement.cdBqu     = aetabln.jou-cd
            ttBanquePrelevement.NoMDt     = aetabln.mandat-cd
            ttBanquePrelevement.fg-defaut = (aetabln.jou-cd = ietab.bqjou-cd
                                             and can-find(first vbietab no-lock
                                                          where vbietab.soc-cd    = aetabln.soc-cd
                                                            and vbietab.etab-cd   = aetabln.mandat-cd
                                                             and vbietab.profil-cd = ietab.bqprofil-cd)) /*--> Banque par défaut du mandat */
        .
        for first ijou no-lock
            where ijou.soc-cd  = ietab.soc-cd
              and ijou.etab-cd = aetabln.mandat-cd
              and ijou.jou-cd  = aetabln.jou-cd
          , first ibque no-lock
            where ibque.soc-cd  = ijou.soc-cd
              and ibque.etab-cd = ijou.etab-cd
              and ibque.cpt-cd  = ijou.cpt-cd:
            assign
                ttBanquePrelevement.fmtprl = ibque.fmtprl     /* CFONB / SEPA */
                ttBanquePrelevement.fmtvir = ibque.fmtvir
            .
        end.
    end.
end procedure.

procedure chargeParametreClientPrelevement private:
    /*------------------------------------------------------------------------------
    Purpose: charge les paramètres de prélèvement du client
    Notes:   depuis adb/tach/prmobqtt.p/RchPrmCli 
    ------------------------------------------------------------------------------*/
    define variable voParametrePrelevement as class parametragePrelevementAutomatique no-undo.

    assign
        gcMoisPrelevement      = "00000"
        voParametrePrelevement = new parametragePrelevementAutomatique()
        glPrelevementAuto      = voParametrePrelevement:isPrelevementAutomatique()
        giJourPrelevement      = voParametrePrelevement:getNombreJoursPrelevement()
        gcMoisPrelevement      = voParametrePrelevement:getCodeMoisPrelevement()
        glPrelevementMens      = voParametrePrelevement:isPrelevementMensuel()
    .
    delete object voParametrePrelevement.
end procedure.

procedure setParametre:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes:   service externe 
    ------------------------------------------------------------------------------*/
    define input  parameter poCollectionContrat as class collection no-undo.
    define input  parameter table for ttParametrageQuitt.
    define input  parameter table for ttError.
    define output parameter table for ttRubriqueRegularisation.  

    define variable vlQuittanceRegenere as logical no-undo. 
   
    find first ttParametrageQuitt where lookup(ttParametrageQuitt.CRUD, "C,U,D") > 0 no-error.
    if not available ttParametrageQuitt then return.

    assign
        giNumeroContrat       = ttParametrageQuitt.iNumeroContrat
        gcTypeContrat         = ttParametrageQuitt.cTypeContrat
        gcTypeRole            = poCollectionContrat:getCharacter("cTypeRole")
        giNumeroMandat        = truncate(giNumeroContrat / 100000, 0)
        goCollectionContrat   = poCollectionContrat
        goCollectionHandlePgm = new collection()       
    .

    goCollectionContrat:set("cTypeContrat", gcTypeContrat).
    goCollectionContrat:set("iNumeroContrat", giNumeroContrat).
    goCollectionContrat:set("iNumeroMandat", giNumeroMandat).
    run verZonSai (output vlQuittanceRegenere).
    if not mError:erreur() then run majTblTch (vlQuittanceRegenere).
    suppressionPgmPersistent(goCollectionHandlePgm).


//mError:createError({&error}, "tstgg").


end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define output parameter plQuittanceRegenere as logical no-undo.    
    
    define variable vlPrelevementSEPA       as logical   no-undo.
    define variable vlFicheLocation         as logical   no-undo.
    define variable viNumeroFicheLocation   as int64     no-undo. 
    define variable viMoisFin               as integer   no-undo.
    define variable viI                     as integer   no-undo.
    define variable vcNumeroRubrique        as character no-undo.
    define variable vlRubriqueVariable      as logical   no-undo.
    define variable vcLibelleAno            as character no-undo.
    define variable vcCodeTerme             as character no-undo.
    define variable vcCodePeriodicite       as character no-undo.
    define variable vdaEntreeOld            as date      no-undo.
    define variable vdaCalculRenouvellement as date      no-undo.
    define variable vlModifDateEntree       as logical   no-undo.
    define variable vlModifCodePeriodicite  as logical   no-undo.
    define variable vlModifCodeTerme        as logical   no-undo.
    define variable viNoContratBanque       as integer   no-undo.
    define variable vcIban                  as character no-undo.
    define variable vcCodeErreur            as character no-undo.
    define variable vcLibelleErreur         as character no-undo.  
    define variable viNumeroTiers           as integer   no-undo.      // NoTieUse
    define variable viNombreCompteTiers     as integer   no-undo.      // NbBquTie
    define variable vlBanquePrelevVirement  as logical   no-undo.      // FgBquPrlVir
    define variable vcIBAN-BICUse           as character no-undo.
    define variable vlBquSepa               as logical   no-undo.      // FgBquSepa
    define variable viNumeroUL              as integer   no-undo.      // NoAppUse
    define variable viRetourQuestion        as integer   no-undo.

    define variable voParametreSEPA       as class parametrageSEPA       no-undo.
    define variable voParametreRelocation as class parametrageRelocation no-undo.

    define buffer ctrat      for ctrat.
    define buffer tache      for tache.
    define buffer vbctrat    for ctrat.
    define buffer mandatsepa for mandatsepa.
    define buffer aquit      for aquit.
    define buffer unite      for unite.
    define buffer equit      for equit.
    define buffer location   for location.

    find first ctrat no-lock
        where ctrat.tpcon = gcTypeContrat
          and ctrat.nocon = giNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 1000847, substitute("&2&1&3", separ[1], giNumeroContrat, gcTypeContrat)). //Contrat N° &1 de type &2 non trouvé
        return.
    end.
    run chgMoisQuittance (giNumeroMandat, input-output goCollectionContrat).     
    assign 
        giMoisQuittancement    = goCollectionContrat:getInteger("iMoisQuittancement")
        giMoisModifiable       = goCollectionContrat:getInteger("iMoisModifiable")
        giMoisEchu             = goCollectionContrat:getInteger("iMoisEchu")
        glBailFournisseurLoyer = goCollectionContrat:getLogical("lBailFournisseurLoyer")
    .
    for last tache no-lock
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroContrat
          and tache.tptac = {&TYPETACHE-quittancement}:
        assign
            vcCodePeriodicite = tache.pdges
            vcCodeTerme       = tache.ntges
        .
    end.   
    run chgInfoDate(buffer ctrat, output vdaEntreeOld, output gdaFinOld, output vdaCalculRenouvellement).
    run chgInfoNumeroQuittance (output vlModifDateEntree, output vlModifCodePeriodicite, output vlModifCodeTerme).
    run chargeParametrePeriodicite.
    run chargeParametreGESFL.
    ghProc = lancementPgm("bail/quittancement/quittanceEncours.p", goCollectionHandlePgm).        
    run getListeQuittance in ghProc(goCollectionContrat, input-output table ttQtt by-reference, input-output table ttRub by-reference).
    if ttParametrageQuitt.daEntree <> vdaEntreeOld then do:
        if ttParametrageQuitt.daEntree = ? 
        or ttParametrageQuitt.daEntree < ctrat.dtini
        or ttParametrageQuitt.daEntree >= vdaCalculRenouvellement then do:
            /* Date appli doit etre >= date deb bail et < date fin bail */
            mError:createErrorGestion({&error}, 101071, substitute("&2&1&3", separ[1], ctrat.dtini, vdaCalculRenouvellement)).
            return.
        end.
        /* Chargement des tables ttQtt et TmRub a partir de l'offre */
        run generationQuittanceDepuisOffre (ttParametrageQuitt.cCodeTerme, ttParametrageQuitt.cCodePeriodicite, ttParametrageQuitt.daEntree, output ttParametrageQuitt.daPremiereQuittanceGI).
        plQuittanceRegenere = true.
    end.
    viNumeroUL = truncate((giNumeroContrat modulo 100000) / 100, 0).  // integer(substring(string(giNumeroContrat, "9999999999"), 6 ,3))
    if ttParametrageQuitt.daFin <> ? then do:
        if ttParametrageQuitt.daFin > ctrat.dtree then do:
            mError:createErrorGestion({&error}, 101893, "").
            return.
        end.
        if ttParametrageQuitt.daFin < ttParametrageQuitt.daEntree then do:
            mError:createError({&error}, 101894).
            return.
        end.
        {&_proparse_ prolint-nowarn(use-index)}
        for last aquit no-lock
            where aquit.noloc = giNumeroContrat 
              and aquit.fgfac = no
            use-index ix_aquit03:              // noloc, msqtt
            // ATTENTION Ecart entre Date de sortie et quittancement effectif.
            // Ce locataire a été quittancé jusqu'au &1 donc après la date de sortie saisie.
            // Si vous faites une facture de sortie le calcul ne sera correct que si la date saisie correspond à la date de fin de quittancement réellement effectué.
            // Confirmez-vous la date de sortie saisie : &2 ? */
            if ttParametrageQuitt.daFin < aquit.dtfin
            then do:
                viRetourQuestion = outils:questionnaire(1000805, substitute("&2&1&3", separ[1], aquit.dtfin, ttParametrageQuitt.daFin), table ttError by-reference).
                if viRetourQuestion < 2 then return.
                if viRetourQuestion = 2
                then do:
                    mError:chgTypeQuestion(1000805). 
                    return.
                end.
            end.            
        end.
        /* Avertissement si date de résiliation < date de quittancement */
        viMoisFin = year(ttParametrageQuitt.daFin) * 100 + month(ttParametrageQuitt.daFin).
        if viMoisFin < giMoisQuittancement
        then do:
            viRetourQuestion = outils:questionnaireGestion(109702, "", table ttError by-reference).
            if viRetourQuestion < 2 then return.
            if viRetourQuestion = 2
            then do:
                mError:chgTypeQuestion(109702). 
                return.
            end.
        end.        
        /* Controle avec les dates d'indisponibilite de l'UL */
        for first unite no-lock
            where unite.nomdt = giNumeroMandat
              and unite.noapp = viNumeroUL
              and unite.noact = 0
              and unite.dtdebindis < ttParametrageQuitt.daFin:    // index unique sur nomdt, noapp, noact
            mError:createError({&error}, 1000510).                // Il y a chevauchement entre la date de sortie du locataire et la date d'indisponibilité
            return.
        end.
        /* Locataire "standard" : Controle rubrique regul de charge dans avis d'échéances futurs qui ne seront pas émis  */ 
        if not glBailFournisseurLoyer then do:
            for each equit no-lock
                where equit.noloc = giNumeroContrat
                  and equit.dtdpr > ttParametrageQuitt.daFin
                  and ((equit.cdter = {&TERMEQUITTANCEMENT-avance} and equit.msqtt >= giMoisModifiable) or (equit.cdter = {&TERMEQUITTANCEMENT-echu} and equit.msqtt >= giMoisEchu)):
                vcLibelleAno = "".
                do viI = 1 to 20:
                    if equit.tbrub[viI] > 0 and equit.tbgen[viI] = "00003" then do:
                        /* ignorer rub Franchise, DG */
                        vcNumeroRubrique = string(equit.tbrub[viI],"999").
                        if lookup (vcNumeroRubrique, "108,581") = 0 then do:
                            if vcLibelleAno = ""
                            then vcLibelleAno = substitute("&1 &2/&3 :", outilTraduction:getLibelle(0101690), substring(string(equit.msqtt, "999999"), 5, 2), substring(string(equit.msqtt, "999999"), 1, 4)).
                            assign
                                vcLibelleAno       = substitute("&1 &2.&3 = &4,", vcLibelleAno, vcNumeroRubrique, string(equit.TbLib[viI], "99"), equit.Tbmtq[viI])
                                vlRubriqueVariable = yes
                            . 
                        end.
                    end.
                end.
                if vcLibelleAno > "" then mError:createListeErreur(trim(vcLibelleAno, ",")).  
            end.
            // ATTENTION Rubriques saisies sur quittancement à venir.
            // Des rubriques de régularisation (type variable) sont présentes sur des avis d’échéances postérieurs à la date de sortie,
            // ces avis d’échéance ainsi que ces rubriques seront supprimés: &1
            // Confirmez-vous cette date de sortie ?
            if vlRubriqueVariable
            then do:
                viRetourQuestion = outils:questionnaire(1000807, table ttError by-reference).
                if viRetourQuestion < 2 then return.
                if viRetourQuestion = 2
                then do:
                    mError:chgTypeQuestion(1000807). 
                    return.
                end.
            end.
        end.  
    end.
    if ttParametrageQuitt.cCodePeriodicite <> vcCodePeriodicite
    or ttParametrageQuitt.cCodeTerme <> vcCodeTerme then do:
        run generationQuittanceDepuisOffre (ttParametrageQuitt.cCodeTerme, ttParametrageQuitt.cCodePeriodicite, ttParametrageQuitt.daEntree, output ttParametrageQuitt.daPremiereQuittanceGI).
        plQuittanceRegenere = true.
    end.      
    /* Controle du code periodicite */    
    run verZonPer (ttParametrageQuitt.cCodePeriodicite, ctrat.cddur, ctrat.nbdur).
    if mError:erreur() then return.
    /* Ajout Sy le 29/01/2007 : Controle si changement périodicité/Terme / compatible avec dernière quittance historisée */
    if gcTypeContrat = {&TYPECONTRAT-Bail}
    and (ttParametrageQuitt.cCodePeriodicite <> vcCodePeriodicite or ttParametrageQuitt.cCodeTerme <> vcCodeTerme)
    then do:
        run VerModPer.
        if mError:erreur() then return.
    end.      
    if ttParametrageQuitt.iMoisAvanceEmissionQuittance > 6 then do:
        mError:createError({&error}, 110405). 
        return.
    end.
    /* SY 1013/0126 : Emission quittance à l'avance incompatible avec prélèvement mensuel / NB : la comptabilisation ne sera effective qu'au traitement du VRAI mois de quitt */
    if ttParametrageQuitt.iMoisAvanceEmissionQuittance > 0 and ttParametrageQuitt.cCodeModeReglement = {&MODEREGLEMENT-prelevementMensuel} then do:  
        mError:createError({&error}, 111523). 
        return.
    end.        
    /* 0607/0250 */
    if ttParametrageQuitt.cCodeModeReglement = {&MODEREGLEMENT-compensation}
    and (giComp-Etab-cd = 0 or gcComp-cptg-cd = "" or gcComp-sscpt-cd = "") then do:  //gga todo renseigne dans loadobjtch a voir aussi comment saisir ces infos 
        mError:createError({&error}, 1000808).             //Vous devez saisir le compte de la compensation locataire  
        return.
    end.
    /* Ajout SY le 15/01/2013 : Controle Prélèvement SEPA Locataire */
    if lookup(ttParametrageQuitt.cCodeModeReglement, substitute("&1,&2", {&MODEREGLEMENT-prelevement}, {&MODEREGLEMENT-prelevementMensuel})) > 0
    and not glBailFournisseurLoyer then do:
        /* SY 1013/0126 prélèvement mensuel : Périodicité Trimestrielle uniquement et jour de paiement limité du 1er au 15 */
        if ttParametrageQuitt.cCodeModeReglement = {&MODEREGLEMENT-prelevementMensuel} then do:
            if not ttParametrageQuitt.cCodePeriodicite matches "003*" then do:
                mError:createError({&error}, 111520). 
                return.                 
            end.
            if ttParametrageQuitt.iJourPrelevement > 15 then do:
                mError:createError({&error}, 111521).
                return.
            end.
        end.
        run ChgBquMandat.
        run chgInfoBanque(output viNumeroTiers, output viNombreCompteTiers, output vlBanquePrelevVirement, output vcIBAN-BICUse, output vlBquSepa).
        if mError:erreur() then return.   

        if ttParametrageQuitt.cBanquePrelevement > ""
        then find first ttBanquePrelevement where ttBanquePrelevement.cdbqu = ttParametrageQuitt.cBanquePrelevement no-error.
        else find first ttBanquePrelevement where ttBanquePrelevement.fg-defaut no-error.
        if available ttBanquePrelevement and ttBanquePrelevement.fmtprl = "SEPA" and vlBquSepa = false then do:
            mError:createError({&error}, 1000809, vcIBAN-BICUse).  //Contrôle de cohérence SEPA L'IBAN+BIC du locataire (&1) ne permettent pas d'effectuer un prélèvement <SEPA>.
            return.
        end. 
        /* Recherche si le mandat de prélèvement est Valide SI LE CLIENT A OUVERT LE PARAM PRELEVEMENT SEPA */
        voParametreSEPA = new parametrageSEPA().
        if valid-object(voParametreSEPA) then do:
            vlPrelevementSEPA = voParametreSEPA:isPrelevementSEPA().
            delete object voParametreSEPA.
        end.
        if vlPrelevementSEPA then do:
            if ttParametrageQuitt.iNumeroMPrelSEPA = 0 then do:
                mError:createError({&error}, 1000810).             // Contrôle Mandat SEPA Vous devez créer un mandat de prélèvement SEPA.
                return. 
            end.   
            find first mandatsepa no-lock                          // on verifie que le mandat sepa existe bien pour le locataire
                where mandatsepa.noMPrelSEP = ttParametrageQuitt.iNumeroMPrelSEPA 
                  and mandatsepa.tpmandat   = {&TYPECONTRAT-sepa}
                  and mandatsepa.nomdt      = giNumeroMandat
                  and mandatsepa.tpcon      = gcTypeContrat
                  and mandatsepa.nocon      = giNumeroContrat
                  and mandatsepa.tprol      = gcTypeRole
                  and mandatsepa.norol      = giNumeroContrat no-error.
            if not available mandatsepa then do:
                 mError:createError({&error}, 1000848).         //Mandat SEPA inexistant
                return.
            end.
            ghProc = lancementPgm("outils/IBANRoleContrat.p", goCollectionHandlePgm).
            // Contrôles de validité  IBAN role + contrat
            run IBAN-RoleContrat in ghProc(mandatsepa.tpcon, mandatsepa.nocon, mandatsepa.tprol, mandatsepa.norol, 
                                           output viNoContratBanque, output vcIBAN).
            ghProc = lancementPgm("mandat/sepa/mandatSEPA.p", goCollectionHandlePgm).
            run isMandatSepaValide in ghProc(ttParametrageQuitt.iNumeroMPrelSEPA, viNoContratBanque, today, ?,
                                             output vcCodeErreur, output vcLibelleErreur).
            if integer(vcCodeErreur) <> 0 then do:
                mError:createError({&error}, vcLibelleErreur).
                return.
            end.
        end.
    end.
    if gcTypeContrat = {&TYPECONTRAT-Bail} then do:
        /* Controle colocations et TIP */
        if ttParametrageQuitt.cCodeModeReglement = {&MODEREGLEMENT-TIP} then do:
            ghProc = lancementPgm("bail/outilColocation.p", goCollectionHandlePgm).
            if dynamic-function('IsColocation' in ghProc, gcTypeContrat, giNumeroContrat) then do:
                mError:createError({&error}, 1000811).      //Le locataire fait partie d'une colocation. Le mode de réglement 'TIP' est interdit pour les colocations.
                return.
            end.
        end.
        /*--> Date de sortie possible que si pas de procedure de renouvellement encours et phase = conges */
        if ttParametrageQuitt.daFin <> ? then do:
            for last tache no-lock
                where tache.tpcon = gcTypeContrat
                  and tache.nocon = giNumeroContrat
                  and tache.tptac = {&TYPETACHE-renouvellement}:
                if tache.tpfin <> "00" and tache.tpfin <> "40" and tache.tpfin <> "50" then do:
                    mError:createError({&error}, 106150).
                    return.
                end.
            end.
        end.
        if ttParametrageQuitt.cRepriseSolde = "00002"
// whole-index corrige par la creation dans la version d'un index sur tprol norol            
        and can-find(first acreg no-lock
                     where acreg.tprol = {&TYPEROLE-locataire}
                       and acreg.norol = giNumeroContrat) 
        then do:
            mError:createError({&error}, 108975).
            return.
        end. 
        /* Interdiction de supprimer la date de sortie si relocation en cours / Uniquement si on a supprimé la date de sortie */
        if ttParametrageQuitt.daFin = ? then do:
            if gdaFinOld <> ? 
            then do:
                voParametreRelocation = new parametrageRelocation().
                if voParametreRelocation:isActif()
                then for last location no-lock                   /* Recherche fiche de relocation */
                    where location.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and location.nocon = giNumeroMandat
                      and location.noapp = viNumeroUL
                      and location.fgarch = no:
                    assign
                        vlFicheLocation       = yes
                        viNumeroFicheLocation = location.nofiche
                    . 
                    /* si fiche validée et pré-bail accepté alors le gestionnaire peut retirer le motif d'indisponibilité */
                    if location.cdstatut = "00090" 
                    and can-find(first ctrat no-lock
                                 where ctrat.tpcon = {&TYPECONTRAT-preBail}
                                   and ctrat.nocon >= int64(string(location.nocon, "99999") + string(location.noapp, "999") + "01")
                                   and ctrat.nocon <= int64(string(location.nocon, "99999") + string(location.noapp, "999") + "99")
                                   and ctrat.cdstatut = "00099")
                    then vlFicheLocation = no.
                    /* SY 0414/0093 : si le no dernier locataire ne correspond pas au locataire en cours (vieille fiche) : ignorer */
                    if location.noderloc <> 0 and location.noderloc < giNumeroContrat 
                    then vlFicheLocation = no.
                end.
                if vlFicheLocation then do:
                    mError:createError({&error}, 1000813, string(viNumeroFicheLocation)).     //Il existe une fiche de relocation non archivée (no &1). Vous ne pouvez pas supprimer la date de sortie.
                    return.
                end.
                /* RAZ des dates d'indispo */
                for first unite no-lock
                    where unite.nomdt = giNumeroMandat
                      and unite.noapp = viNumeroUL
                      and unite.noact = 0:
                    empty temp-table ttUnite.
                    create ttUnite.
                    assign
                        ttUnite.nomdt       = unite.nomdt
                        ttUnite.noapp       = unite.noapp
                        ttUnite.noact       = unite.noact
                        ttUnite.CRUD        = "U"
                        ttUnite.dtTimestamp = datetime(unite.dtmsy, unite.hemsy)
                        ttUnite.rRowid      = rowid(unite)
                        ttUnite.lbdiv       = "&&|"
                        ttUnite.dtdebindis  = {&dateNulle} 
                        ttUnite.dtfinindis  = {&dateNulle} 
                        ttUnite.cdmotindis  = ""
                        ghProc              = lancementPgm("crud/unite_CRUD.p", goCollectionHandlePgm)
                    .
                    run setUnite in ghProc(table ttUnite by-reference).
                    if mError:erreur() then do:
                        mError:createError({&error}, 1000814).         //La mise à jour de la tache (Dates et motif d'indisponibilité) a échoué !
                        return.
                    end.
                end.
            end. /* Fin test date sortie modifiée */
            /* La date de sortie est vide (sans pour autant avoir été modifiée) / Cas ou on revient de la saisie de l'indispo sans avoir saisi de sortie */
            else for first unite no-lock
                where unite.nomdt = giNumeroMandat
                  and unite.noapp = viNumeroUL
                  and unite.noact = 0:
                if unite.dtdebindis <> ? or unite.dtfinindis <> ?
                or (unite.cdmotindis > "" and unite.cdmotindis <> "00000") then do:
                    mError:createError({&error}, 1000815).  // La date de sortie n'est pas renseignée, bien qu'une période d'indisponibilité soit saisie.
                    return.
                end.
            end.
        end. 
    end.

end procedure.

procedure getParametrage:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define output parameter table for ttParametrageQuitt.

    empty temp-table ttParametrageQuitt. 
    assign
        giNumeroContrat       = poCollectionContrat:getInt64("iNumeroContrat")
        gcTypeContrat         = poCollectionContrat:getCharacter("cTypeContrat")
        gcTypeRole            = poCollectionContrat:getCharacter("cTypeRole")
        giNumeroMandat        = truncate(giNumeroContrat / 100000, 0)
        goCollectionContrat   = poCollectionContrat
        goCollectionHandlePgm = new collection()             
    .

    create ttParametrageQuitt.
    assign 
        ttParametrageQuitt.cTypeContrat   = gcTypeContrat
        ttParametrageQuitt.iNumeroContrat = giNumeroContrat
        ttParametrageQuitt.CRUD           = "R"
        ttParametrageQuitt.dtTimestamp    = now
    .
    run chgInfoParametrage. 
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure chgInfoParametrage private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/  
    define variable vdaCalculRenouvellement as date      no-undo.
    define variable vcModeReglement         as character no-undo.
    define variable vcModePrelevement       as character no-undo.

    define buffer ctrat      for ctrat.
    define buffer tache      for tache.
    define buffer mandatsepa for mandatsepa.

    find first ctrat no-lock
         where ctrat.tpcon = gcTypeContrat
           and ctrat.nocon = giNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 1000847, substitute("&2&1&3", separ[1], giNumeroContrat, gcTypeContrat)). //Contrat N° &1 de type &2 non trouvé        
        return.
    end.
    find last tache no-lock
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroContrat
          and tache.tptac = {&TYPETACHE-quittancement} no-error.
    if not available tache then do:
        mError:createError({&error}, 1000849). //tache quittancement inexistante pour ce contrat
        return.
    end.   
    assign
        ttParametrageQuitt.cCodePeriodicite             = tache.pdges             // 14  HwPerQtt
        ttParametrageQuitt.cCodeTerme                   = tache.ntges             // 12  HwTerQtt
        ttParametrageQuitt.cCodeModeReglement           = tache.cdreg             // 15  HwModReg
        ttParametrageQuitt.lDepotGarantie               = (tache.ntreg = "00001") // 16  HwCauQtt
        ttParametrageQuitt.cRepriseSolde                = tache.pdreg             // 17  HwRepSol
        ttParametrageQuitt.daPremiereQuittanceGI        = tache.dtreg             // 19  HwDat1GI
        ttParametrageQuitt.cCodeEdition                 = tache.tphon             // 22  HwCmbTyp 
        ttParametrageQuitt.iMoisAvanceEmissionQuittance = tache.nbmav
        ttParametrageQuitt.lReglementDirectAuProp       = (tache.notxt > 0)
        ttParametrageQuitt.iNumeroTexte                 = tache.notxt
        ttParametrageQuitt.cModeEnvoi                   = tache.tpmadisp
        ttParametrageQuitt.iMandatCompensation          = tache.etab-cd
        ttParametrageQuitt.cCompteCompensation          = tache.cptg-cd
        ttParametrageQuitt.cSousCompteCompensation      = tache.sscpt-cd
    .
    run chgMoisQuittance (giNumeroMandat, input-output goCollectionContrat).
    assign
        giMoisQuittancement = goCollectionContrat:getInteger("iMoisQuittancement")
        giMoisModifiable    = goCollectionContrat:getInteger("iMoisModifiable")
        giMoisEchu          = goCollectionContrat:getInteger("iMoisEchu")
    .  
    //controle quittance. les anomalies du type "plus d'avis d'echeance" sont en message d'erreur de type information, donc pas bloquant
    //si besoin de regenerer les quittances utiliser service specifique (ce n'est pas une reponse a la question)
    if gcTypeContrat = {&TYPECONTRAT-Bail}    //extrait de enaobjtch 
    and ctrat.dtree = ? 
    then do:    
        ghProc = lancementPgm("bail/quittancement/viabiliteBail.p", goCollectionHandlePgm).
        run ctrlQuittance in ghProc (goCollectionContrat).
        if mError:erreur() then return.
    end.
    run chgInfoDate(buffer ctrat, output ttParametrageQuitt.daEntree, output ttParametrageQuitt.dafin, output vdaCalculRenouvellement). 
    if ttParametrageQuitt.dafin = ?
    then if ctrat.dtree <> ?
        then ttParametrageQuitt.daResiliationContrat    = ctrat.dtree.
        else ttParametrageQuitt.daRenouvellementContrat = vdaCalculRenouvellement + 1.
    run chargeParametreClientPrelevement.
    assign
        vcModePrelevement = {&MODEREGLEMENT-prelevement} + "," + {&MODEREGLEMENT-prelevementMensuel}
        vcModeReglement   = {&MODEREGLEMENT-virement} + "," + vcModePrelevement
    .
    if lookup(ttParametrageQuitt.cCodeModeReglement, vcModePrelevement) > 0
    and tache.lbdiv > ""
    and num-entries(tache.lbdiv, separ[1]) >= 2 
    then ttParametrageQuitt.cBanquePrelevement = entry(1, tache.lbdiv, separ[1]).
    run chgInfoBanquePrelevement.
    if lookup(ttParametrageQuitt.cCodeModeReglement, vcModePrelevement) > 0
    then do:
        if glPrelevementAuto and giJourPrelevement > 0 then do:
            ttParametrageQuitt.iJourPrelevement = giJourPrelevement. 
            if tache.duree > 0 then ttParametrageQuitt.iJourPrelevement = tache.duree.
        end.
    end.
    else ttParametrageQuitt.iJourPrelevement = tache.duree. 
    if (integer(mToken:cRefPrincipale) = {&REFCLIENT-LCLILEDEFRANCE} or integer(mToken:cRefPrincipale) = {&REFCLIENT-LCLPROVINCE})
    and lookup(ttParametrageQuitt.cCodeModeReglement, vcModePrelevement) > 0
    and glPrelevementAuto then do:
        ttParametrageQuitt.cMoisPrelevement = gcMoisPrelevement.
        if tache.dcreg > "" then ttParametrageQuitt.cMoisPrelevement = tache.dcreg.
    end.
    for last mandatsepa no-lock
        where mandatsepa.tpmandat = {&TYPECONTRAT-sepa}
          and mandatsepa.ntcon    = {&NATURECONTRAT-recurrent}
          and mandatsepa.nomdt    = giNumeroMandat
          and mandatsepa.tpcon    = gcTypeContrat
          and mandatsepa.nocon    = giNumeroContrat
          and mandatsepa.tprol    = gcTypeRole
          and mandatsepa.norol    = giNumeroContrat:
        assign       
            ttParametrageQuitt.iNumeroMPrelSEPA      = mandatsepa.noMPrelSEPA
            ttParametrageQuitt.cCodeRUM              = mandatsepa.codeRUM
            ttParametrageQuitt.daSignatureMandatSepa = mandatsepa.dtsig
        .
    end.

end procedure.

procedure chgInfoBanquePrelevement private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure d'affichage ou de raz du compte bancaire OU du tiers payeur si compensation (0607/0250)
    Notes  : a partir de AffCptBqu
    ------------------------------------------------------------------------------*/      
    define variable vcTiersPayeur as character no-undo.
 
    define buffer rlctt     for rlctt.
    define buffer ctanx     for ctanx.
    define buffer ccpt      for ccpt. 
    define buffer csscptcol for csscptcol.  
    define buffer csscpt    for csscpt.  
    define buffer ctrat     for ctrat.  
    
    if ttParametrageQuitt.cCodeModeReglement = {&MODEREGLEMENT-TIP}
    or ttParametrageQuitt.cCodeModeReglement = {&MODEREGLEMENT-prelevementEnLigne}                    // Ajout IA - 0108/0159
    or ((ttParametrageQuitt.cCodeModeReglement = {&MODEREGLEMENT-prelevement}
      or ttParametrageQuitt.cCodeModeReglement = {&MODEREGLEMENT-prelevementMensuel})
      and not glBailFournisseurLoyer)                                                                 // Prelevement: affichier RIB si pas fournisseur loyer
    or (ttParametrageQuitt.cCodeModeReglement = {&MODEREGLEMENT-virement} and glBailFournisseurLoyer) // Virement: affichier RIB si fournisseur loyer uniquement 
    then for first rlctt no-lock
        where rlctt.tpidt = gcTypeRole
          and rlctt.noidt = giNumeroContrat
          and rlctt.tpct1 = gcTypeContrat
          and rlctt.noct1 = giNumeroContrat
      , first ctanx no-lock
        where ctanx.tpcon = rlctt.tpct2
          and ctanx.nocon = rlctt.noct2:              
        ttParametrageQuitt.cInfoBanquePrelevement = substitute("&1 &2", ctanx.lbdom, nocpt).
    end.

    /* Ajout Sy le 24/08/2009 : tiers payeur */
    if ttParametrageQuitt.cCodeModeReglement = {&MODEREGLEMENT-compensation}
    and ttParametrageQuitt.iMandatCompensation <> 0  then do:
        vcTiersPayeur = substitute("Mandat &1 Compte &2 SScpte &3", ttParametrageQuitt.iMandatCompensation, ttParametrageQuitt.cCompteCompensation, ttParametrageQuitt.cSousCompteCompensation).
        find first ctrat no-lock
            where ctrat.nocon = ttParametrageQuitt.iMandatCompensation no-error.
        if integer(ttParametrageQuitt.cCompteCompensation) = 4010                         /* Fournisseur */
        then for first ccpt no-lock 
            where ccpt.soc-cd   = (if available ctrat and ctrat.tpcon = "01003" then integer(mtoken:cRefCopro) else integer(mtoken:cRefGerance))
              and ccpt.coll-cle = "F"
              and ccpt.cpt-cd   = ttParametrageQuitt.cSousCompteCompensation:
            vcTiersPayeur = vcTiersPayeur + " " + ccpt.lib.
        end.    
        else for first csscptcol no-lock
            where csscptcol.soc-cd     = (if available ctrat and ctrat.tpcon = "01003" then integer(mtoken:cRefCopro) else integer(mtoken:cRefGerance))
              and csscptcol.etab-cd    = ttParametrageQuitt.iMandatCompensation
              and csscptcol.sscoll-cpt = ttParametrageQuitt.cCompteCompensation
          , first csscpt no-lock
            where csscpt.soc-cd     = csscptcol.soc-cd
              and csscpt.etab-cd    = ttParametrageQuitt.iMandatCompensation
              and csscpt.sscoll-cle = csscptcol.coll-cle
              and csscpt.cpt-cd     = ttParametrageQuitt.cSousCompteCompensation:
            assign
                ttParametrageQuitt.cCollectifCompensation = csscptcol.coll-cle
                vcTiersPayeur                             = vcTiersPayeur + " " + csscpt.lib
            .
        end.                            
        ttParametrageQuitt.cInfoBanquePrelevement = vcTiersPayeur.
    end.

end procedure.

procedure verZonPer private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure du controle du code periodicite quitt locataire 
    Notes  : 
    ------------------------------------------------------------------------------*/      
    define input parameter pcPeriodicite   as character no-undo.
    define input parameter pcCodeDureeBail as character no-undo.
    define input parameter piDureeBail     as integer   no-undo.

    if ((glBailFournisseurLoyer = no and giPeriodicite = 3)
     or (glBailFournisseurLoyer = yes and giNombreMoisQuittFlo = 3))
    and lookup(pcPeriodicite, substitute('&1,&2,&3', {&PERIODICITEQUITTANCE-trimestrielJanMar}, {&PERIODICITEQUITTANCE-semestrielJanJun}, {&PERIODICITEQUITTANCE-AnnuelJanDec})) = 0
    then do:
        if glBailFournisseurLoyer
        then mError:createErrorGestion({&error}, 106170, "").    /* Vous traitez votre quittancement 'Fournisseur Loyer' trimestriellement.%sVous ne pouvez donc saisir que des Bailleurs Trim./ Sem. / Annuel civil.*/
        else mError:createErrorGestion({&error}, 105657, "").    /* Vous traitez votre quittancement trimestriellement.%sVous ne pouvez donc saisir que des locataires Trim./ Sem. / Annuel civil.*/  
        return.
    end.
    /* Ajout SY le 17/03/2009 - fiche 0209/0177 : comparer avec durée du bail si n mois */
    if pcCodeDureeBail = "00002" and integer(substring(pcPeriodicite, 1, 3)) > piDureeBail 
    then mError:createError({&error}, 1000816, string(piDureeBail)). //Vous ne pouvez pas quittancer sur un nombre de mois supérieur à la durée du Bail (&1 mois).
            
end procedure.

procedure verModPer private:
    /*------------------------------------------------------------------------------
    Purpose:  Procedure de controle du changement de terme ou de périodicité
              si le locataire a une quittance historisée (ou FL entrée ?)
              pour qu'un mois ne soit pas quittancé 2 fois
              Fiches 0107/0149 + 0607/0222
    Notes  : 
    ------------------------------------------------------------------------------*/    
    define variable viRub             as integer   no-undo.
    define variable vcRubQtt          as character no-undo.
    define variable vcNumeroRubrique  as character no-undo.
    define variable vlQuittanceVierge as logical   no-undo.
    define variable viRetourQuestion  as integer   no-undo.

    define buffer aquit for aquit. 

    {&_proparse_ prolint-nowarn(use-index)}
    find last aquit no-lock
        where aquit.noloc = giNumeroContrat 
          and aquit.fgfac = no        
        use-index ix_aquit03 no-error.    // noloc, msqtt
    if not available aquit then return.

    /* Ajout SY le 20/06/2007 - fiche 0607/0222: vérifier que ce n'est pas une quittance vierge */
    vlQuittanceVierge = yes.
    if aquit.mtqtt <> 0 
    then vlQuittanceVierge = no.
    else do viRub = 1 to 20:
        vcRubQtt = aquit.tbrub[viRub].
        if num-entries(vcRubQtt, "|") < 13 then next.

        vcNumeroRubrique = entry(1, vcRubQtt, "|").
        if integer(vcNumeroRubrique) = 0 then leave.

        if decimal(entry(6, vcRubQtt, "|")) <> 0 then do:
            vlQuittanceVierge = no.
            leave.
        end.
    end.
    if vlQuittanceVierge = yes then return.

    /* Nouvelles quittances */
    find first ttQtt where ttQtt.iNumeroLocataire = giNumeroContrat no-error.
    if not available ttQtt then return.
 
    /* PL 20/01/2011 Ajout restriction test sur bail*/
    if ttQtt.daDebutPeriode <= aquit.dtfpr
    then do:
        /* La nouvelle période de quittancement (&1 - &2) chevauche la dernière quittance historisée (&3 - &4). Voulez quand même effectuer la modification (pensez à corriger le quittancement en conséquence) ? */
        viRetourQuestion = outils:questionnaire(1000817, substitute("&2&1&3&1&4&1&5", separ[1], ttQtt.daDebutPeriode ,ttQtt.daFinPeriode, aquit.dtdpr, aquit.dtfpr), table ttError by-reference).
        if viRetourQuestion = 2 then mError:chgTypeQuestion(1000817).
    end.

end procedure.

procedure chgInfoDate private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define output parameter pdaEntree         as date no-undo.
    define output parameter pdaFin            as date no-undo.
    define output parameter pdaRenouvellement as date no-undo.

    define buffer tache for tache.

    assign
        pdaEntree         = ctrat.dtini
        pdaRenouvellement = ctrat.dtfin
    .
    /* Recherche si la periodicite du Quittancement Locataires est Trimestrielle */
    /* Recherche du Contrat en Cours. */
    /* Recuperation des Infos du Renouvellement */
    for last tache no-lock
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroContrat
          and tache.tptac = {&TYPETACHE-renouvellement}:
        case tache.tpfin:
            /* Procedure de renouvellement encours */
            when {&ETATPROCRENOU-procedureEnCours} then pdaRenouvellement = tache.dtfin.
            /* Bail a renouveller sur la base de */
            when {&ETATPROCRENOU-quittanceAValider} then case entry(2, entry(num-entries(tache.cdhon, "#"), tache.cdhon, "#"), "&"):
                when {&PHASEPROCRENOU-ARenouvellerSurBaseBail}      then pdaRenouvellement = tache.dtfin.
                when {&PHASEPROCRENOU-ARenouvellerSurBaseOffre}     then pdaRenouvellement = tache.dtreg - 1.
                when {&PHASEPROCRENOU-ARenouvellerSurBaseJugement}  then pdaRenouvellement = tache.dtreg - 1.
            end case.
            /* Bail a resilier */
            when {&ETATPROCRENOU-congeEnCours}               then case entry(2, entry(num-entries(tache.cdhon, "#"), tache.cdhon, "#"), "&"):
                when {&PHASEPROCRENOU-Conges}                then pdaRenouvellement = tache.dtreg - 1.  // Conges (Manuel)
                when {&PHASEPROCRENOU-NonTraiteCongeSysteme} then pdaRenouvellement = tache.dtfin.      // Conges Systeme
                when {&PHASEPROCRENOU-DemandeConge}          then pdaRenouvellement = tache.dtfin.      // Demande de congés
            end case.
        end case.
    end.
    for last tache no-lock
       where tache.tpcon = gcTypeContrat
         and tache.nocon = giNumeroContrat
         and tache.tptac = {&TYPETACHE-quittancement}:
        assign
            pdaEntree = tache.dtdeb
            pdaFin    = tache.dtfin
        .
    end.

end procedure.

procedure generationQuittanceDepuisOffre private:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de l'offre (a partir de ChgTmpOff)
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeTerme            as character no-undo.
    define input  parameter pcCodePeriodicite      as character no-undo.
    define input  parameter pdaEntree              as date no-undo.
    define output parameter pdaPremiereQuittanceGI as date no-undo.
    
    define variable vcLibelleMois1GI  as character no-undo.
    define variable vcLibelleAnnee1GI as character no-undo.

    ghProc = lancementPgm("bail/quittancement/genoffqt.p", goCollectionHandlePgm).
    run lancementGenoffqtt in ghProc (goCollectionContrat,
                                      giNumeroQuittance,
                                      no,
                                      "CHGRUB",
                                      pcCodeTerme,
                                      pcCodePeriodicite,
                                      pdaEntree,
                                      input-output table ttQtt by-reference, 
                                      input-output table ttRub by-reference).
    /* Reinitialisation de la date 1ère Quitt GI */
    for first ttQtt
        where ttQtt.iNumeroLocataire = giNumeroContrat
          and ttQtt.iNoQuittance     = giNumeroQuittance:
        assign
            vcLibelleMois1GI       = substring(string(ttQtt.iMoisTraitementQuitt), 5, 2, "character")
            vcLibelleAnnee1GI      = substring(string(ttQtt.iMoisTraitementQuitt), 1, 4, "character")
            pdaPremiereQuittanceGI = date(integer(vcLibelleMois1GI), 01, integer(vcLibelleAnnee1GI))
        .
    end.

end procedure.

procedure majTblTch private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter plQuittanceRegenere as logical no-undo. 
    
    define variable vcCodeDepotGarantie as character no-undo.
    define variable vcCodeRepriseSolde  as character no-undo.
    define variable vdaSorOld           as date      no-undo.
    define variable vdaFinReg           as date      no-undo.
    define variable viNoQttMod          as integer   no-undo.
    define variable vcLstRubQt          as character no-undo.
    define variable vcInfRub01          as character no-undo.
    define variable viNoRubUse          as integer   no-undo.
    define variable viNoLibUse          as integer   no-undo.
    define variable vdMtRubUse          as decimal   no-undo.
    define variable viI                 as integer   no-undo.

    define buffer tache for tache.
    define buffer pquit for pquit.
    define buffer equit for equit.
    define buffer aquit for aquit.

    empty temp-table ttTache.
    find last tache no-lock
        where tache.tpcon = gcTypeContrat
          and tache.nocon = giNumeroContrat
          and tache.tptac = {&TYPETACHE-quittancement} no-error.
    if not available tache then return.

    create ttTache.
    assign
        ttTache.tpcon    = tache.tpcon 
        ttTache.nocon    = tache.nocon
        ttTache.tptac    = tache.tptac
        ttTache.notac    = tache.notac 
        ttTache.dtdeb    = (if ttParametrageQuitt.daEntree = ? then {&dateNulle} else ttParametrageQuitt.daEntree)  
        ttTache.dtfin    = (if ttParametrageQuitt.daFin = ? then {&dateNulle} else ttParametrageQuitt.daFin)
        ttTache.pdges    = ttParametrageQuitt.cCodePeriodicite
        ttTache.ntges    = ttParametrageQuitt.cCodeTerme 
        ttTache.cdreg    = ttParametrageQuitt.cCodeModeReglement
        ttTache.ntreg    = string(ttParametrageQuitt.lDepotGarantie, "00001/00002")
        ttTache.pdreg    = ttParametrageQuitt.cRepriseSolde 
        ttTache.dtreg    = ttParametrageQuitt.daPremiereQuittanceGI
        ttTache.dtreg    = ttParametrageQuitt.daPremiereQuittanceGI
        ttTache.tphon    = ttParametrageQuitt.cCodeEdition
        ttTache.nbmav    = ttParametrageQuitt.iMoisAvanceEmissionQuittance
        ttTache.tpmadisp = ttParametrageQuitt.cModeEnvoi
        ttTache.CRUD        = "U"
        ttTache.rRowid      = rowid(tache)
        ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
        ghProc              = lancementPgm("crud/tache_CRUD.p", goCollectionHandlePgm)
    .
    run settache in ghProc(table ttTache by-reference).
    if mError:erreur() then return.

    if giNumeroQuittance <> 0 then do:
        assign
            vcCodeDepotGarantie = (if ttParametrageQuitt.lDepotGarantie then "00001" else "00000")
            vcCodeRepriseSolde  = (if ttParametrageQuitt.cRepriseSolde = "00001" then "00001" else "00000")
        .
        if gcTypeContrat = {&TYPECONTRAT-preBail}
        then do:
            /*- Modification du mode de réglement sur le pré-quit -*/
            empty temp-table ttPquit. 
            for each pquit no-lock  
               where pquit.noloc = giNumeroContrat:
                create ttPquit.
                assign
                    ttPquit.noint       = pquit.noint
                    ttPquit.CRUD        = "U"
                    ttPquit.rRowid      = rowid(pquit)
                    ttPquit.dtTimestamp = datetime(pquit.dtmsy, pquit.hemsy)
                    ttPquit.CdDep       = vcCodeDepotGarantie
                    ttPquit.CdSol       = vcCodeRepriseSolde
                    ttPquit.fgtrf       = no
                    ttPquit.MdReg       = ttParametrageQuitt.cCodeModeReglement
                .
            end.  
            ghProc = lancementPgm("crud/pquit_CRUD.p", goCollectionHandlePgm).
            run setPquit in ghProc(table ttPquit by-reference).
        end.
        else do:
            /*- Modification du mode de réglement sur les quittances non emises -*/
            empty temp-table ttEquit. 
            for each equit no-lock  
                where equit.noloc = giNumeroContrat:
                create ttEquit.
                assign
                    ttEquit.noloc       = equit.noloc
                    ttEquit.noqtt       = equit.noqtt
                    ttEquit.CRUD        = "U"
                    ttEquit.rRowid      = rowid(equit)
                    ttEquit.dtTimestamp = datetime(equit.dtmsy, equit.hemsy)
                    ttEquit.CdDep       = vcCodeDepotGarantie
                    ttEquit.CdSol       = vcCodeRepriseSolde
                    ttEquit.fgtrf       = no
                .
                if equit.msqtt >= (if glBailFournisseurLoyer then giMoisQuittancement else giMoisQuittancement) then ttEquit.MdReg = ttParametrageQuitt.cCodeModeReglement.    /* SY 0117/0188 : 2 mois de quitt différents selon bail fournisseur de loyer ou bail locataire */
            end.
            ghProc = lancementPgm("crud/equit_CRUD.p", goCollectionHandlePgm).
            run setEquit in ghProc(table ttEquit by-reference).
        end.
        for each ttQtt
           where ttQtt.iNumeroLocataire = giNumeroContrat:
            assign  
                ttQtt.cCodeModeReglement = ttParametrageQuitt.cCodeModeReglement
                ttQtt.cCodeEditionDepotGarantie = vcCodeDepotGarantie
                ttQtt.cCodeEditionSolde = vcCodeRepriseSolde
            .
        end.                            
        /*- Si les quittances ont ete regenerees avec l'offre de location -*/
        if plQuittanceRegenere then do:
            ghProc = lancementPgm("bail/quittancement/quittancement.p", goCollectionHandlePgm).
            run majQuittanceRegenere in ghProc(goCollectionContrat, giNumeroQuittance, input-output table ttQtt by-reference, input-output table ttRub by-reference).
            if mError:erreur() then return.
        end.
        /* Si Raz date de sortie : calcul proratas rappel sur jours non quittancés */
        if ttParametrageQuitt.daFin = ? and gdaFinOld <> ttParametrageQuitt.daFin then do:
            ghProc = lancementPgm("bail/quittancement/regulqtt.p", goCollectionHandlePgm).
            run lancementRegulqtt in ghProc(goCollectionContrat, table ttError by-reference, input-output table ttRubriqueRegularisation).
            if mError:erreur() then return.
        end.
        /* Si ajout date de sortie vérifier qu'il n'y avait pas des rub rappel dans prochain quitt */
        if gcTypeContrat = {&TYPECONTRAT-Bail} and gdaFinOld = ? and ttParametrageQuitt.daFin <> ? then do:
            find first equit no-lock 
                where equit.noloc = giNumeroContrat
                  and equit.msqtt >= giMoisEchu no-error.       /* AJout SY le 12/01/2015 pour ne pas prendre les Avis d'échéance périmés (Pb plantage PEC, equit non historisé) */
            find last tache no-lock 
                where tache.tpcon = gcTypeContrat
                  and tache.nocon = giNumeroContrat
                  and tache.tptac = {&TYPETACHE-quittancement} no-error.
            if available equit and available tache and num-entries(tache.lbdiv2, separ[2]) >= 4 then do:
                assign
                    vdaSorOld  = date(entry(1, tache.lbdiv2, separ[2]))
                    vdaFinReg  = date(entry(2, tache.lbdiv2, separ[2]))
                    viNoQttMod = integer(entry(3, tache.lbdiv2, separ[2]))
                .
                if viNoQttMod = equit.noqtt and ttParametrageQuitt.daFin <= vdaFinReg then do:
                    assign
                        vcLstRubQt = entry(5, tache.lbdiv2, separ[2])
                        vcInfRub01 = entry(1, vcLstRubQt, separ[1])
                        viNoRubUse = integer(entry(1, vcInfRub01, separ[3]))
                        viNoLibUse = integer(entry(2, vcInfRub01, separ[3]))
                        vdMtRubUse = decimal(entry(4, vcInfRub01, separ[3])) / 100
                    .
                    do viI = 1 to 20:
                        if equit.tbrub[viI] = 0 then leave.
                        if equit.tbrub[viI] = viNoRubUse
                        and equit.tblib[viI] = viNoLibUse
                        and equit.tbmtq[viI] = vdMtRubUse
                        then do:
                            mError:createError({&information}, 1000850, string(1000850)).  //Attention, vous devez modifier les rubriques de rappels générées par la suppression de la date de sortie précédente (&1)
                            leave.
                        end.
                    end.
                end.
            end.
        end. 
    end.

end procedure.

procedure getAutorisationMaj:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:   service externe
    ------------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.
    define output parameter table-handle phttAutorisation.

    define variable vhTmpAutorisation as handle no-undo.

    assign
        giNumeroContrat       = poCollectionContrat:getInteger("iNumeroContrat")
        gcTypeContrat         = poCollectionContrat:getCharacter("cTypeContrat")
        giNumeroMandat        = truncate(giNumeroContrat / 100000, 0)    
        goCollectionContrat   = poCollectionContrat
        goCollectionHandlePgm = new collection()             
    .
    create temp-table phttAutorisation.
//  phttAutorisation:add-new-field ("nom","type", extent, "format", initialisation).
    phttAutorisation:add-new-field ("lModificationTache"               , "logical", 0, "", ?).    
    phttAutorisation:add-new-field ("lSuppressionTache"                , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lModificationDateEntree"          , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lModificationCodePeriodicite"     , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lModificationCodeTerme"           , "logical", 0, "", ?).
    phttAutorisation:add-new-field ("lAffichageAvanceEmissionQuittance", "logical", 0, "", ?).
    phttAutorisation:temp-table-prepare("ttAutorisation").
    vhTmpAutorisation = phttAutorisation:default-buffer-handle.
    run chgAutorisationMaj(vhTmpAutorisation).

end procedure.

procedure chgAutorisationMaj private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/      
    define input parameter phTmpAutorisation as handle no-undo.

    define variable vlModifDateEntree      as logical no-undo.
    define variable vlModifCodePeriodicite as logical no-undo.
    define variable vlModifCodeTerme       as logical no-undo.
    
    define variable voTache as class parametrageTache no-undo.

    phTmpAutorisation:handle:buffer-create().
    assign
        phTmpAutorisation::lModificationTache = PrcResBai()
        voTache                               = new parametrageTache()
        phTmpAutorisation::lSuppressionTache  = if voTache:tacheObligatoire(giNumeroContrat, gcTypeContrat, {&TYPETACHE-quittancement})
                                                then no else yes
    .
    delete object voTache.
    run chgMoisQuittance(giNumeroMandat, input-output goCollectionContrat).
    assign 
        giMoisQuittancement    = goCollectionContrat:getInteger("iMoisQuittancement")
        giMoisModifiable       = goCollectionContrat:getInteger("iMoisModifiable")
        giMoisEchu             = goCollectionContrat:getInteger("iMoisEchu")
        glBailFournisseurLoyer = goCollectionContrat:getLogical("lBailFournisseurLoyer")
    .
    run chgInfoNumeroQuittance(output vlModifDateEntree, output vlModifCodePeriodicite, output vlModifCodeTerme).
    assign 
        phTmpAutorisation::lModificationDateEntree      = vlModifDateEntree  
        phTmpAutorisation::lModificationCodePeriodicite = vlModifCodePeriodicite
        phTmpAutorisation::lModificationCodeTerme       = vlModifCodeTerme
    .
    run chargeParametrePeriodicite.
    phTmpAutorisation::lAffichageAvanceEmissionQuittance = if glBailFournisseurLoyer or glQuittanceAvance = no then no else yes.

end procedure.

procedure controleTache:
    /*------------------------------------------------------------------------------
    Purpose: controle tache
             pour ce controle, chargement info objet du mandat dans la table ttMandat (comme pour un getObjet)
             et ensuite appel procedure verificationNonResiliation (controle avant maj)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeContrat   as character no-undo.
    define input parameter piNumeroContrat as int64     no-undo.

    define variable vlQuittanceRegenere as logical no-undo. 

    define buffer ctrat for ctrat.

    empty temp-table ttParametrageQuitt. 

    find first ctrat no-lock
         where ctrat.tpcon = pcTypeContrat
           and ctrat.nocon = piNumeroContrat no-error.
    if not available ctrat then do:
        mError:createError({&error}, 100057).
        return.
    end.
    
    empty temp-table ttParametrageQuitt. 
    assign
        goCollectionContrat   = new collection()                       //gga todo a voir pour renseigner collection dans pgm appelant
        goCollectionHandlePgm = new collection()                 
        giNumeroContrat       = piNumeroContrat
        gcTypeContrat         = pcTypeContrat
        gcTypeRole            = {&TYPEROLE-locataire}
        giNumeroMandat        = truncate(giNumeroContrat / 100000, 0)
    .
    goCollectionContrat:set("iNumeroRole", piNumeroContrat) no-error.    //gga todo
    goCollectionContrat:set("cTypeContrat", pcTypeContrat) no-error.
    goCollectionContrat:set("iNumeroContrat", piNumeroContrat) no-error.
    goCollectionContrat:set("cTypeRole", {&TYPEROLE-locataire}).

    create ttParametrageQuitt.
    assign 
        ttParametrageQuitt.cTypeContrat   = gcTypeContrat
        ttParametrageQuitt.iNumeroContrat = giNumeroContrat
        ttParametrageQuitt.CRUD           = "R"
        ttParametrageQuitt.dtTimestamp    = now
    .
    run chgInfoParametrage. 
    if mError:erreur() then return.

    for first ttParametrageQuitt:
        ttParametrageQuitt.CRUD = "U".
        run verZonSai (output vlQuittanceRegenere).    //gga todo a voir comment ne pas gerer les questions quand appel de verzonsai pour controle 
    end.
    
end procedure.

