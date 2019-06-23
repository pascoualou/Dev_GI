/*-----------------------------------------------------------------------------
File        : pcmdtges.p
Purpose     : Extraction table partagé Loi Perissol et Besson
            : Creation des mandats de gestion :                      
              * PEC DES MANDATS DE GERANCE POUR TYPE DE MANDAT COPRO 
                'RESIDENCE LOCATAIRE' (03077)                        
                  - FOURNISSEUR DE LOYER (03075)                     
                  - MANDAT SOUS LOCATION (03076)                     
              * PEC MANDAT DE GERANCE POUR L'IMMEUBLE (Lots isol‚s)  
                  - FOURNISSEUR DE LOYER (03075)                     
              * PEC MANDAT DE GERANCE POUR L'IMMEUBLE (modele no 3 & 4)
                  - MANDAT SOUS LOCATION (03076)                     
Author(s)   : AF - 2001/10/08, GGA - 2018/01/15
Notes       : reprise de adb/src/cont/pcmdtges.p

01  25/11/1999  LG    Passer le mandat de gestion 03075 au DPS par alimaj.p avec la bonne référence de gérance s'il en a 2.
02  03/05/2000  LG    Rechercher le fournisseur de loyer utilisé ds l'appli. au niveau parametrage pclie ("GESFL")
03  28/05/2001  SY    Correction Newunite: on mettait le no mandat à la place du no propriétaire (unite.noman)
                      => problème de données en création appt
04  26/06/2001  SY    Adaptation pour gestion des fournisseurs loyer modèle "lots isolés" (CREDIT LYONNAIS)
05  26/07/2001  SY    Ajout code devise dans mandats créés
06  30/08/2001  SY    Ajout lien gestionnaire pour mandats créés
07  24/01/2002  SY    Remplacement code Gentacauto par les appels des librairies générales de l'appli (sinon gestion des exceptions pas faites)
08  29/07/2002  AFA   Fiche 0202/0232: Ajout des numeros de tel du répertoire télephonique.4eme au 10 eme N° Utilisation de Mj2ladrs das L_ladrs.
09  02/06/2004  PL    0504/0172:Gestion FL Eurostudiomes.
10  08/06/2004  SY    0504/0172:Gestion FL Eurostudiomes - suite
11  21/06/2004  SY    0604/0328:Gestion FL Eurostudiomes - suite, init devise mandat sous-location
12  08/03/2007  SY    0307/0146: creationMandatSousLocation - on sort la création compta de la transaction car cela utilise beaucoup de locks
13  19/03/2008  RF    0507/0195 nelle gestion telephones
14  04/01/2010  SY    1209/0268 - PRI-TER IMMO - ouverture tranche mandat sous-location (03076)
15  16/02/2010  SY    La tranche par défaut des mandats sous-location est 1 à 199 et pas 1 à 200
16  31/08/2010  SY    0810/0101 création mandat sous-location pour modèle "00003" en MAJ copro
17  07/10/2010  SY    1010/0037 Correction suite modif précédente chez ICADE: Ne pas rattacher automatiquement les lots au mandat sous-location
18  08/10/2010  SY    1010/0037 suite modif 0810/0101, Pas de rattachement automatique des lots au mandat sous-location pour ICADE
19  02/03/2012  SY    Essai modèle 00004 multi- sous location (BNP) création mandat sous-location (03076)
20  07/06/2012  SY    0512/0046 MIGRATION BNP: modif TbPecSyn.i
21  14/06/2012  PL    0212/0155 sous location déléguée
22  31/08/2016  PL    1114/0278 Registre copro: modif TbPecSyn.i
------------------------------------------------------------------------------*/

{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageReferenceGeranceCopro.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/intnt.i}
{adblib/include/ctrat.i}
{adblib/include/ctctt.i}
{adblib/include/unite.i}
{immeubleEtLot/include/cpuni.i}

define variable giNumeroImmeuble            as integer   no-undo.
define variable glMandatSousLocDelegue      as logical   no-undo.
define variable giNumeroMandant             as int64     no-undo.
define variable gcCdModele                  as character no-undo.
define variable gcVilleImmeuble             as character no-undo.
define variable gcNomMandant                as character no-undo.
define variable gcCiviliteMandant           as character no-undo.
define variable giNumeroServiceGestionnaire as int64     no-undo.
define variable gcDeviseContrat             as character no-undo.
define variable gcLbNomImm                  as character no-undo.

function lancementPgm return handle private(pcProgramme as character, pcProcedure as character, table-handle phTable ):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    run value(pcProgramme) persistent set vhProc.
    run getTokenInstance   in vhProc(mToken:JSessionId).
    run value(pcProcedure) in vhProc(table-handle phTable by-reference).
    run destroy in vhProc.

end function.

function creationTache return handle private(pcTypeContrat as character, piNumeroContrat as int64):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc as handle no-undo.

    run mandat/outilMandat.p persistent set vhProc.
    run getTokenInstance  in vhProc(mToken:JSessionId).
    run creationAutoTache in vhProc(pcTypeContrat, piNumeroContrat).
    run destroy in vhProc.

end function.

function dateAchevementImmeuble return date private(piNumeroImmeuble as int64):
    /*------------------------------------------------------------------------------
    Purpose: recuperer la date d'achevement de l'immeuble
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
        return ctrat.dtfin.
    end.
    return ?.

end function.

function dateFinMandat return date private(pdaAchevementImmeuble as date):
    /*------------------------------------------------------------------------------
    Purpose: Calcul date de fin du mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vdaFinMandat as date   no-undo.
    define variable vhPrgdat     as handle no-undo.

    if pdaAchevementImmeuble <> ?
    then do:
        run application/l_prgdat.p persistent set vhPrgdat.
        run getTokenInstance in vhPrgdat(mToken:JSessionId).
        run cl2DatFin in vhPrgdat(pdaAchevementImmeuble, '99', '00001', output vdaFinMandat).
        run destroy in vhPrgdat.
        return vdaFinMandat.
    end.
    return ?.

end function.

procedure lancementPcmdtges:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandatSyndic   as int64   no-undo.
    define input parameter piNumeroImmeuble       as int64   no-undo.
    define input parameter plMandatSousLocDelegue as logical no-undo.

    define variable voFournisseurLoyer    as class     parametrageFournisseurLoyer no-undo.

    define variable vhFormat7Ext          as handle    no-undo.
    define variable viIncrementSLDeleguee as integer   no-undo.
    define variable viNoSloDeb            as integer   no-undo.
    define variable viNoSloFin            as integer   no-undo.
    define variable viNoFloDeb            as integer   no-undo.
    define variable viNoFloFin            as integer   no-undo.
    define variable viNumeroMandat        as int64     no-undo.
    define variable vcLbZo1Imm            as character no-undo.
    define variable vcLbZo2Imm            as character no-undo.
    define variable vcLbCodPos            as character no-undo.
    define variable vcLbCodPay            as character no-undo.

    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    assign
        giNumeroImmeuble       = piNumeroImmeuble
        glMandatSousLocDelegue = plMandatSousLocDelegue
        /* Recherche parametre GESFL (fournisseur de loyer) - Récupération du modele */
        voFournisseurLoyer     = new parametrageFournisseurLoyer("00001")
    .
    if voFournisseurLoyer:isDbParameter
    then do:
        assign
            giNumeroMandant       = voFournisseurLoyer:getNumeroMandant()
            gcCdModele            = voFournisseurLoyer:getCodeModele()
            viNoSloDeb            = voFournisseurLoyer:getImmeubleDebut()
            viNoSloFin            = voFournisseurLoyer:getImmeubleFin()
            viNoFloDeb            = voFournisseurLoyer:getFournisseurLoyerDebut()
            viNoFloFin            = voFournisseurLoyer:getFournisseurLoyerFin()
            viIncrementSLDeleguee = voFournisseurLoyer:getIncrementSLDeleguee()
        .
        /* S'il s'agit d'un mandat de sous-location déléguée, il faut prendre le mandant
        par défaut pour la sous-location déléguée et non le mandant par défaut du mandat
        de sous-location standard */
        if glMandatSousLocDelegue then giNumeroMandant = voFournisseurLoyer:getNumeroMandantSousLocDelegue().
        delete object voFournisseurLoyer.
    end.
    else do:
        delete object voFournisseurLoyer.
        mLogger:writeLog(0, "Pas de gestion de la sous-location").
        return.
    end.
    mLogger:writeLog(0,
        substitute(
            "Informations de sous-location:%s gcCdModele = &1s viNoSloDeb = &2%s viNoSloFin = &3%s viNoFloDeb = &4%s viNoFloFin = &5%s glMandatSousLocDelegue = &6%s giNumeroMandant = &7%s viIncrementSLDeleguee = &8",
            gcCdModele, viNoSloDeb, viNoSloFin, viNoFloDeb, viNoFloFin, glMandatSousLocDelegue, giNumeroMandant, viIncrementSLDeleguee)).
    /* formatage nom du Mandant garant */
    assign
        gcNomMandant      = outilFormatage:getNomTiers({&TYPEROLE-mandant}, giNumeroMandant)              //remplace appel formtie0.p
        gcCiviliteMandant = outilFormatage:getCiviliteNomTiers({&TYPEROLE-mandant}, giNumeroMandant, no)  //remplace appel FormTiea.p
        giNumeroServiceGestionnaire = 0
    .
    /* Recherche no service du collaborateur */
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-serviceGestion}
          and intnt.tpidt = {&TYPEROLE-gestionnaire}
          and intnt.noidt = mtoken:iCollaborateur:
        giNumeroServiceGestionnaire = intnt.nocon.
    end.
    /* Recherche infos adresse Immeuble */
    if not can-find(first imble no-lock
                    where imble.noimm = giNumeroImmeuble) then return.

    run adresse/formadr7_ext.p persistent set vhFormat7Ext.
    run getAdresseFormat7 in vhFormat7Ext(giNumeroImmeuble,
                                          output gcLbNomImm,
                                          output vcLbZo1Imm,
                                          output vcLbZo2Imm,
                                          output vcLbCodPos,
                                          output gcVilleImmeuble,
                                          output vcLbCodPay).
    delete object vhFormat7Ext.
    gcDeviseContrat = mToken:cDeviseReference.
    /* Modif SY le 31/08/2010 - Fiche 0810/0101 : création mandat sous-location pour modèle "00003" si PEC mandat copro */
    /*IF piNumeroMandatSyndic = 0 THEN DO:*/
    case gcCdModele:
        when "00002"
        then do:
            /* Modele "Lots Isoles" */
            /* mandat fournisseur de loyer */
            viNumeroMandat = viNoFloDeb + giNumeroImmeuble - 1.
            run creationMandatLocation(viNumeroMandat).
        end.
        when "00003" or when "00004"
        then if giNumeroImmeuble >= viNoSloDeb and giNumeroImmeuble <= viNoSloFin            /* Modele EUROSTUDIOMES */
        then do:
            /* mandat sous location (03076) */
            viNumeroMandat = giNumeroImmeuble.
            /* Par convention, le mandat de sous-location délégué associé est :
                N° d'immeuble du mandat + incrément qui dépend de la borne de fin des
                mandats de sous-location normaux */
            if glMandatSousLocDelegue then viNumeroMandat = giNumeroImmeuble + viIncrementSLDeleguee.
            run creationMandatSousLocation(viNumeroMandat).
        end.
        otherwise if piNumeroMandatSyndic > 0            /* Modele "Residence locative" */
        then do:
            find first ctrat no-lock
                where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
                  and ctrat.nocon = piNumeroMandatSyndic no-error.
            if not available ctrat
            or ctrat.ntcon <> {&NATURECONTRAT-residenceLocataire} then return.

            if ctrat.cddev > "" then gcDeviseContrat = ctrat.cddev.
            /* mandat fournisseur de loyer = location (03075) */
            viNumeroMandat = viNoFloDeb + giNumeroImmeuble - 1.
            /* Génération mandat FL pour modele RESIDE ETUDES uniquement */
            if gcCdModele = "00001" then run creationMandatLocation(viNumeroMandat).
            /* mandat sous location (03076) */
            viNumeroMandat = giNumeroImmeuble.
            run creationMandatSousLocation(viNumeroMandat).
        end.
    end case.

end procedure.

procedure creationMandatLocation private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure creation du mandat de location (fournisseur de loyer)
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    define buffer ctrat for ctrat.

    mLogger:writeLog(0,
        substitute(
            "creationMandatLocation: %sN° Immeuble (giNumeroImmeuble) = &1%sN° Mandat (piNumeroMandat) = &2%sMandat de sous-location déléguée (glMandatSousLocDelegue) = &3",
            giNumeroImmeuble,
            piNumeroMandat,
            glMandatSousLocDelegue)).
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and ctrat.nocon = piNumeroMandat)
    then do:
        /* gga le code creation du tiers n'est pas repris (le tiers doit exister) */
        run creationMandat(piNumeroMandat, {&NATURECONTRAT-mandatLocation}).
        if mError:erreur() then return.

        run creationLienMandat(piNumeroMandat).
        if mError:erreur() then return.

        run majTrace(piNumeroMandat).
        if mError:erreur() then return.
    end.
    /* ctrat doit forcement exister a ce moment du traitement */
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroMandat:
        creationTache(ctrat.tpcon, ctrat.nocon).
        if not mError:erreur() and gcCdModele = "00002"
        then run creationLienLot(piNumeroMandat, ctrat.dtdeb).
    end.
end procedure.

procedure creationMandatSousLocation private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure creation du mandat de sous location
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    define variable vlCreationMandat as logical   no-undo.
    define variable vhPontCompta     as handle    no-undo.
    define variable vcNatureContrat  as character no-undo.
    define buffer intnt   for intnt.
    define buffer ctrat   for ctrat.
    define buffer vbroles for roles.
    define buffer tiers   for tiers.

    mLogger:writeLog(0,
        substitute(
            "creationMandatSousLocation: %sN° Immeuble (giNumeroImmeuble) = &1%sN° Mandat (piNumeroMandat) = &2%sMandat de sous-location déléguée (glMandatSousLocDelegue) = &3",
            giNumeroImmeuble,
            piNumeroMandat,
            glMandatSousLocDelegue)).
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon  = {&TYPECONTRAT-mandat2Gerance}
                       and ctrat.nocon = piNumeroMandat)
    then do:
        assign
            vlCreationMandat = yes
            vcNatureContrat  = if glMandatSousLocDelegue
                               then {&NATURECONTRAT-mandatSousLocationDelegue}
                               else {&NATURECONTRAT-mandatSousLocation}
        .
        run creationMandat(piNumeroMandat, vcNatureContrat).
        if mError:erreur() then return.

        run creationLienMandat (piNumeroMandat).
        if mError:erreur() then return.
    end.
    /* ctrat doit forcement exister a ce moment du traitement */
    find first ctrat no-lock
         where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat then return.

    /* appel creation tache */
    creationTache(ctrat.tpcon, ctrat.nocon).
    if mError:erreur() then return.

    /* gga la boucle sur lecture table TbPecLot n'est pas reprise. cette table temporaire est cree pour modele 00002, 00003 ou 00004 mais la boucle n'est
    traite que si gcCdModele <> "00003" and gcCdModele <> "00004" et cette procedure n'est pas appele si modele 00002 */
    /* si nouveau mandat */
    if vlCreationMandat then do:
        run majTrace (ctrat.nocon).
        if mError:erreur() then return.

        run immeubleEtLot/pontImmeubleCompta.p persistent set vhPontCompta.
        run getTokenInstance in vhPontCompta (mToken:JSessionId).
        /*--> Prevenir Compta d'un nouveau Mandant Gerance. */
        run majMandatExterne in vhPontCompta (ctrat.tpcon, ctrat.nocon, giNumeroImmeuble, yes).
        for first intnt no-lock
            where intnt.tpcon = ctrat.tpcon
              and intnt.nocon = ctrat.nocon
              and intnt.tpidt = {&TYPEROLE-mandant}
          , first vbroles no-lock
            where vbroles.tprol = intnt.tpidt
              and vbroles.norol = intnt.noidt
          , first tiers no-lock
            where tiers.notie = vbroles.notie:
            /*--> Prevenir Compta d'un nouveau Mandant. */
            run majCompteExterne in vhPontCompta(ctrat.tpcon, ctrat.nocon, tiers.notie, {&TYPEROLE-mandant}, vbroles.norol, 0, 0).
            /*--> Prevenir Compta d'une Mise a jour du  Mandant en tant qu'indivisaire */
            run majCompteExterne in vhPontCompta(ctrat.tpcon, ctrat.nocon, tiers.notie, {&TYPEROLE-coIndivisaire}, vbroles.norol, 100, 100).
        end.
        run destroy in vhPontCompta.
    end.

end procedure.

procedure creationMandat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat  as int64   no-undo.
    define input parameter pcNatureContrat as character no-undo.

    define variable vdaFinAchevementConstruction as date no-undo.
    define variable vdaFinMandat as date no-undo.

    empty temp-table ttCtrat.
    empty temp-table ttCtctt.
    /* Creation du mandat */
    create ttCtrat.
    assign
        vdaFinAchevementConstruction = dateAchevementImmeuble(giNumeroImmeuble)     // recuperer la date d'achevement de l'immeuble
        vdaFinMandat                 = dateFinMandat(vdaFinAchevementConstruction)  // Calcul date de fin du mandat
        ttCtrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
        ttCtrat.nocon = piNumeroMandat
        ttCtrat.CRUD  = "C"
        ttCtrat.ntcon = pcNatureContrat
        ttCtrat.dtdeb = vdaFinAchevementConstruction
        ttCtrat.dtfin = vdaFinMandat
        ttCtrat.tpfin =  ""
        ttCtrat.nbdur = 99
        ttCtrat.cddur = "00001"
        ttCtrat.dtsig = vdaFinAchevementConstruction
        ttCtrat.lisig = gcVilleImmeuble
        ttCtrat.dtree = ?
        ttCtrat.noree = "N" + string(piNumeroMandat)
        ttCtrat.tpren = "00000"
        ttCtrat.noren = 00
        ttCtrat.nbres = 3
        ttCtrat.utres = "00002"
        ttCtrat.tpact = "00000"
        ttCtrat.noref =  0
        ttCtrat.pcpte =  0
        ttCtrat.scpte =  0
        ttCtrat.tprol = {&TYPEROLE-mandant}
        ttCtrat.norol = giNumeroMandant
        ttCtrat.lbnom = gcNomMandant
        ttCtrat.lnom2 = gcCiviliteMandant
        ttCtrat.noave = 0
        ttCtrat.noblc = 0
        ttCtrat.lbdiv = ""
        ttCtrat.cdex = ""
        ttCtrat.dtini = vdaFinAchevementConstruction
        ttCtrat.cddev = gcDeviseContrat
    .
    /* Creation lien Service -mandat */
    create ttCtctt.
    assign
        ttCtctt.tpct1 = {&TYPECONTRAT-serviceGestion}
        ttCtctt.noct1 = giNumeroServiceGestionnaire
        ttCtctt.tpct2 = {&TYPECONTRAT-mandat2Gerance}
        ttCtctt.noct2 = piNumeroMandat
        ttCtctt.CRUD  = "C"
    .
    lancementPgm ("adblib/ctrat_CRUD.p", "setCtrat", table ttCtrat by-reference).
    lancementPgm ("adblib/ctctt_CRUD.p", "setCtctt", table ttCtctt by-reference).

end procedure.

procedure creationLienMandat private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    empty temp-table ttIntnt.
    /* Lien Mandat - Mandant*/
    if not can-find(first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and intnt.nocon = piNumeroMandat
                      and intnt.tpidt = {&TYPEROLE-mandant}) then do:
        create ttIntnt.
        assign
            ttIntnt.tpidt = {&TYPEROLE-mandant}
            ttIntnt.noidt = giNumeroMandant
            ttIntnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
            ttIntnt.nocon = piNumeroMandat
            ttIntnt.nbnum = 0
            ttIntnt.idsui = 0
            ttIntnt.nbden = 0
            ttIntnt.cdreg = ""
            ttIntnt.lbdiv = ""
            ttIntnt.CRUD  = 'C'
        .
    end.
    /* Lien Mandat - Garant*/
    if not can-find(first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and intnt.nocon = piNumeroMandat
                      and intnt.tpidt = {&TYPEROLE-mandataire}) then do:
        create ttIntnt.
        assign
            ttIntnt.tpidt = {&TYPEROLE-mandataire}
            ttIntnt.noidt = 1
            ttIntnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
            ttIntnt.nocon = piNumeroMandat
            ttIntnt.nbnum = 0
            ttIntnt.idsui = 0
            ttIntnt.nbden = 0
            ttIntnt.cdreg = ""
            ttIntnt.lbdiv = ""
            ttIntnt.CRUD  = 'C'
        .
    end.
    /* Lien Mandat - Immeuble*/
    if not can-find(first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                      and intnt.nocon = piNumeroMandat
                      and intnt.tpidt = {&TYPEBIEN-immeuble}) then do:
        create ttIntnt.
        assign
            ttIntnt.tpidt = {&TYPEBIEN-immeuble}
            ttIntnt.noidt = giNumeroImmeuble
            ttIntnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
            ttIntnt.nocon = piNumeroMandat
            ttIntnt.nbnum = 0
            ttIntnt.idsui = 0
            ttIntnt.nbden = 0
            ttIntnt.cdreg = ""
            ttIntnt.lbdiv = ""
            ttIntnt.CRUD  = 'C'
        .
    end.
    lancementPgm ("adblib/intnt_CRUD.p", "setIntnt", table ttIntnt by-reference).

end procedure.

procedure creationLienLot private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64  no-undo.
    define input parameter pdaDebutMandat as date   no-undo.

    define buffer local for local.

    empty temp-table ttIntnt.
    empty temp-table ttUnite.
    empty temp-table ttCpuni.
    for each local no-lock
        where local.noimm = giNumeroImmeuble:
        /* Lien Mandat - lot*/
        if not can-find(first intnt no-lock
                        where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                          and intnt.nocon = piNumeroMandat
                          and intnt.tpidt = {&TYPEBIEN-lot}
                          and intnt.noidt = local.noloc) then do:
            create ttIntnt.
            assign
                ttIntnt.tpidt = {&TYPEBIEN-lot}
                ttIntnt.noidt = local.noloc
                ttIntnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                ttIntnt.nocon = piNumeroMandat
                ttIntnt.nbnum = 0
                ttIntnt.idsui = 0
                ttIntnt.nbden = 0
                ttIntnt.cdreg = ""
                ttIntnt.lbdiv = ""
                ttIntnt.CRUD  = 'C'
            .
            /* Rattachement du lot … l'appart 998 */
            /* Test si existence de l'appart 998 dans Unite */
            if not can-find(first unite no-lock
                            where unite.nomdt = piNumeroMandat
                              and unite.noapp = 998
                              and unite.noact = 0)
            and not can-find(first ttUnite
                             where ttUnite.nomdt = piNumeroMandat
                               and ttUnite.noapp = 998
                               and ttUnite.noact = 0)
            then do:
                /* creation de l'appart 998 dans Unite */
                create ttUnite.
                assign
                    ttUnite.nomdt = piNumeroMandat
                    ttUnite.noapp = 998
                    ttUnite.noact = 0
                    ttUnite.CRUD  = "C"
                    ttUnite.noman = giNumeroMandant
                    ttUnite.nocmp = 010
                    ttUnite.cdcmp = "00004"
                    ttUnite.dtdeb = pdaDebutMandat
                    ttUnite.noimm = giNumeroImmeuble
                    ttUnite.norol = 0
                    ttUnite.cdocc = "00002"
                .
            end.
            /* Creation du lot en 998 dans Cpuni    */
            create ttCpuni.
            assign
                ttCpuni.nomdt = piNumeroMandat
                ttCpuni.noapp = 998
                ttCpuni.nocmp = 010
                ttCpuni.noord = ?                                    //le numero d'ordre sera calcule dans cpuni_crud.p
                ttCpuni.noman = giNumeroMandant
                ttCpuni.noimm = giNumeroImmeuble
                ttCpuni.nolot = local.nolot
                ttCpuni.cdori = ""
                ttCpuni.CRUD  = "C"
            .
        end.
    end.
    lancementPgm ("adblib/intnt_CRUD.p",        "setIntnt", table ttIntnt by-reference).
    lancementPgm ("adblib/unite_CRUD.p",        "setUnite", table ttUnite by-reference).
    lancementPgm ("immeubleEtLot/cpuni_CRUD.p", "setCpuni", table ttCpuni by-reference).

end procedure.

procedure majTrace private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.

    define variable vcNoGerRef as character no-undo.
    define variable vhAlimaj   as handle    no-undo.
    define variable voReferenceGeranceCopro as class parametrageReferenceGeranceCopro no-undo.

    define buffer ctrat for ctrat.

    assign
        voReferenceGeranceCopro = new parametrageReferenceGeranceCopro()
        vcNoGerRef = if voReferenceGeranceCopro:isDbParameter
                     then voReferenceGeranceCopro:getReferenceGerance()
                     else mToken:cRefGerance
    .
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroMandat:
        run "application/transfert/GI_alimaj.p" persistent set vhAlimaj.
        run getTokenInstance in vhAlimaj (mToken:JSessionId).
        run majTrace in vhAlimaj(integer(vcNoGerRef), 'sadb', 'ctrat', string(ctrat.nodoc, '>>>>>>>>9')).
        run destroy in vhAlimaj.
    end.

end procedure.
