/*------------------------------------------------------------------------
File        : mutbail01.p
Purpose     : Mutation de gérance : duplication d'un bail
Author(s)   : SY 09/06/2010  -  GGA  2018/05/04
Notes       : a partir de adb/cont/mutbail01.p

Historique des modifications
  No      Date     Auteur                   Objet
 0001  21/07/2010    SY    Ajout init 1er mois de quitt GI dans le
                           nouveau bail
 0002  17/11/2010    SY    retour tests Eric : on ne dupliquait pas
                           l'historique des révisions
 0003  31/01/2011    SY    0111/0241 : Conservation date de sortie loc.
 0004  12/04/2011    SY    0411/0089 Génération lien bail-RIB (rlctt)
 0005  20/05/2011    SY    0511/0121 Ajout recherche + maj lot principal
                           dans unite (unite.nolot/unite.nolie)
 0006  23/05/2011    SY    0511/0138 Ajout tables du bail :
                           calendrier evolution et echelle mobile
 0007  25/04/2013    PL    1209/0039 Gestion colocation
 0008  04/09/2013    SY    0511/0023 Duplication du mandat de prélèvement SEPA
 0009  04/09/2013    SY    1213/0183 Duplication rubriques calculées
                           (table detail)
 0010  12/02/2016    SY    0216/0014 Dupli mandatSEPA : résilier mandat
                           du locataire d'origine (dtresil Motifresil)
 0011  07/07/2016    SY    0716/0058 Ajout initialisation ctrat.fgprov
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2tache.i}
{preprocesseur/referenceClient.i}
{preprocesseur/type2adresse.i}

using parametre.pclie.parametrageProlongationExpiration.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{outils/include/lancementProgramme.i}
{adblib/include/ctrat.i}
{role/include/role.i}
{adblib/include/ctctt.i}
{adblib/include/intnt.i}
{adresse/include/ladrs.i}
{tache/include/tache.i}
{application/include/glbsepar.i}
{adblib/include/cttac.i}
{adblib/include/revtrt.i}
{adblib/include/revhis.i}
{adblib/include/coloc.i}
{adb/include/echlo.i}
{adblib/include/calev.i}
{adblib/include/chaff.i}
{adblib/include/assat.i}
{adblib/include/prrub.i}
{adblib/include/local.i}
{adblib/include/unite.i}
{bail/include/filtreLo.i}          // Include pour Filtrage locataire à prendre, procedure filtreLoc
{adblib/include/tbent.i}
{adblib/include/tbdet.i}
{adblib/include/detail.i}
{adblib/include/mandatSepa.i}
{adblib/include/suiMandatSepa.i}
{adblib/include/aquit.i}
{bail/include/equit.i}
{adblib/include/rlctt.i}
{comm/include/prclogia.i}

define variable goCollectionHandlePgm as class collection no-undo.

define variable ghProc                     as handle    no-undo.
define variable gcNumeroContratMutation    as character no-undo.
define variable giNumeroMandatAcheteur     as integer   no-undo.
define variable giNumeroUL                 as integer   no-undo.
define variable giNumeroImmeuble           as integer   no-undo.
define variable gdaAchatNotaire            as date      no-undo.
define variable giNumeroContratOrigine     as integer   no-undo.
define variable giMoisDernierQuittancement as integer   no-undo.
define variable gDtResBai-IN               as date      no-undo.
define variable giNumeroNouveauBail        as integer   no-undo.
define variable gMsQttAch-IO               as integer   no-undo.
define variable gChArgPrg-IO               as character no-undo.
define variable giNumeroMandat             as integer   no-undo.
define variable gcNoMutUse                 as character no-undo.

function Date2Inte return integer private (pdaDate as date):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    if pdaDate <> ?
    then return integer(string(year(pdaDate),"9999") + string(month(pdaDate),"99") + string(day(pdaDate),"99")).
    return 0.

end.

procedure lancementMutBai01:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter        piNumeroContratMutation    as int64     no-undo.
    define input parameter        piNumeroMandatAcheteur     as int64     no-undo.
    define input parameter        piNumeroUL                 as integer   no-undo.
    define input parameter        piNumeroImmeuble           as integer   no-undo.
    define input parameter        pdaAchatNotaire            as date      no-undo.
    define input parameter        piNumeroContratOrigine     as integer   no-undo.
    define input parameter        piMoisDernierQuittancement as integer   no-undo.
    define input parameter        DtResBai-IN                as date      no-undo.
    define input-output parameter piNumeroNouveauBail        as integer   no-undo.
    define input-output parameter MsQttAch-IO                as integer   no-undo.
    define input-output parameter ChArgPrg-IO                as character no-undo.

    define buffer intnt for intnt.

    assign
        gcNumeroContratMutation    = string(piNumeroContratMutation, "999999999")
        giNumeroMandatAcheteur     = piNumeroMandatAcheteur
        giNumeroUL                 = piNumeroUL
        giNumeroImmeuble           = piNumeroImmeuble
        gdaAchatNotaire            = pdaAchatNotaire
        giNumeroContratOrigine     = piNumeroContratOrigine
        giMoisDernierQuittancement = piMoisDernierQuittancement
        gDtResBai-IN               = DtResBai-IN
        giNumeroNouveauBail        = piNumeroNouveauBail
        gMsQttAch-IO               = MsQttAch-IO
        gChArgPrg-IO               = ChArgPrg-IO
        gcNoMutUse                 = substring(string(piNumeroContratMutation, "999999999"), 6, -1, 'character')               
    .

    /*récupération du numero de mandant à partir Mandat principal */
    for first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = giNumeroMandatAcheteur
          and intnt.tpidt = {&TYPEROLE-mandant}:
        giNumeroMandat = intnt.noidt.
    end.
    goCollectionHandlePgm = new collection().
    run creationBail.
    suppressionPgmPersistent(goCollectionHandlePgm).
    delete object goCollectionHandlePgm.

end procedure.

procedure creationBail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNoDocSui      as integer   no-undo.
    define variable vinoconSui      as int64     no-undo.
    define variable vdaSortieLoc    as date      no-undo.
    define variable viNumeroMdtSepa as int64     no-undo.
    define variable NoNxtOrd        as int64     no-undo.
    define variable vdaEntreeOcc    as date      no-undo.
    define variable NoLotPrc        as integer   no-undo.
    define variable NoLieLot        as integer   no-undo.
    define variable viNumeroTiers   as integer   no-undo.
    define variable vcAction        as character no-undo.
    define variable vcNomPrg-Info   as character no-undo.

    define buffer detail        for detail.
    define buffer ctrat         for ctrat.
    define buffer cthis         for cthis.
    define buffer coloc         for coloc.
    define buffer ladrs         for ladrs.
    define buffer intnt         for intnt.
    define buffer tache         for tache.
    define buffer revtrt        for revtrt.
    define buffer revhis        for revhis.
    define buffer cttac         for cttac.
    define buffer echlo         for echlo.
    define buffer calev         for calev.
    define buffer chaff         for chaff.
    define buffer assat         for assat.
    define buffer prrub         for prrub.
    define buffer unite         for unite.
    define buffer cpuni         for cpuni.
    define buffer local         for local.
    define buffer tbent         for tbent.
    define buffer vbroles       for roles.
    define buffer vbintnt       for intnt.
    define buffer vbtache       for tache.
    define buffer vbcttac       for cttac.
    define buffer mandatSEPA    for mandatSEPA.
    define buffer suimandatSEPA for suimandatSEPA.
    define buffer vbmandatSEPA  for mandatSEPA.
    define buffer ctanx         for ctanx.
    define buffer vbctrat       for ctrat.

    /* Recherche si existe déjà dans ctrat */
    if can-find (first ctrat no-lock
                 where ctrat.tpcon = {&TYPECONTRAT-bail}
                   and ctrat.nocon = giNumeroNouveauBail)
    then do:
        mError:createError({&error}, 1000741, string(giNumeroNouveauBail)).  //Le contrat Bail &1 existe déjà
        return.
    end.

    /* Ajout SY le 31/01/2011 */
    for first detail no-lock
        where detail.cddet = "MUTAG" + gcNumeroContratMutation
          and integer(detail.tbdec[2]) = giNumeroContratOrigine:
        vdaSortieLoc = detail.tbdat[3].
    end.

    /* Recherche dans ctrat du bail à récupérer */
    find first ctrat no-lock
         where ctrat.tpcon = {&TYPECONTRAT-bail}
           and ctrat.nocon = giNumeroContratOrigine no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 1000740, string(giNumeroContratOrigine)).  //Le contrat Bail à dupliquer &1 n'existe plus
        return.
    end.
    empty temp-table ttCtrat.
    ghProc = lancementPgm("adblib/ctrat_CRUD.p", goCollectionHandlePgm).
    run getNextContrat in ghProc({&TYPECONTRAT-bail}, giNumeroMandatAcheteur, giNumeroUL, output viNoDocSui, output vinoconSui).
    if mError:erreur() then return.
    if vinoconSui <> giNumeroNouveauBail
    then do:
        mError:createError({&error}, 1000742, substitute('&2&1&3', separ[1], vinoconSui, giNumeroNouveauBail)). //Numéro de contrat de NxtCtrat &1 différent du numéro de bail affiché &2
        return.
    end.
    create ttCtrat.
    outils:copyValidField(buffer ctrat:handle, buffer ttCtrat:handle).
    assign
        ttCtrat.CRUD  = "C"
        ttCtrat.nodoc = viNoDocSui
        ttCtrat.nocon = vinoconSui
        ttCtrat.tprol = {&TYPEROLE-locataire}
        ttCtrat.norol = giNumeroNouveauBail
        ttCtrat.dtree = ?
        ttCtrat.cdcsy = mtoken:cUser + "mutbai01".
    .
    /* remettre date de résiliation si ce n'est pas celle due à la mutation */
    /* utiliser cthis sauvegardé avant résiliation (cddev = MUTAGmmmmmxxxx) pour retrouver la vrai date de résiliation...  */
    find last cthis no-lock
        where cthis.tpcon = ctrat.tpcon
          and cthis.nocon = ctrat.nocon                                                   //bail a recuperer
          and cthis.cddev = "MUTAG" + gcNumeroContratMutation no-error.
    if available cthis
    then do:
        if cthis.dtree <> ?
        then do:
            mLogger:writeLog (0, "Création Bail " + string(giNumeroNouveauBail) + " " + ctrat.lbnom + " Date de résiliation ancien locataire = " + string( cthis.dtree , "99/99/9999")).
            ttCtrat.dtree = cthis.dtree.
        end.
    end.
    else if gDtResBai-IN <> ? and ctrat.dtree <> gDtResBai-IN then ttCtrat.dtree = gDtResBai-IN.
    run setCtrat in ghProc(table ttCtrat by-reference).
    if mError:erreur() then return.

    /* Dans la foulée, duplication de l'entete de colocation */
    empty temp-table ttColoc.
    for each coloc no-lock
       where coloc.tpcon = {&TYPECONTRAT-bail}
         and coloc.nocon = giNumeroContratOrigine
         and coloc.noqtt = 0:
        create ttColoc.
        outils:copyValidField(buffer coloc:handle, buffer ttColoc:handle).
        assign
            ttColoc.CRUD        = 'C'
            ttColoc.nocon       = giNumeroNouveauBail
        .
        if coloc.tpidt = {&TYPEROLE-locataire}
        then ttColoc.noidt = giNumeroNouveauBail.
    end.
    ghProc = lancementPgm("adblib/coloc_CRUD.p", goCollectionHandlePgm).
    run setColoc in ghProc(table ttColoc by-reference).
    if mError:erreur() then return.

    for first vbroles no-lock
        where vbroles.tprol = {&TYPEROLE-locataire}
          and vbroles.norol = giNumeroContratOrigine:
        viNumeroTiers = vbroles.notie.
    end.

    /* Creation du nouveau roles */
    empty temp-table ttRole.
    create ttRole.
    assign
        ttRole.CRUD          = "C"
        ttRole.cCodeTypeRole = {&TYPEROLE-locataire}
        ttRole.iNumeroRole   = giNumeroNouveauBail
        ttRole.iNumeroTiers  = viNumeroTiers
    .
    ghProc = lancementPgm("role/roles_CRUD.p", goCollectionHandlePgm).
    run setRoles in ghProc(table ttRole by-reference).
    if mError:erreur() then return.

    //Generation d'un Enregistrement "nouveau bail/mandat" dans ctctt
    empty temp-table ttCtctt.
    create ttCtctt.
    assign
        ttCtctt.CRUD  = "C"
        ttCtctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
        ttCtctt.noct1 = giNumeroMandatAcheteur
        ttCtctt.tpct2 = {&TYPECONTRAT-bail}
        ttCtctt.noct2 = giNumeroNouveauBail
        .
    ghProc = lancementPgm("adblib/ctctt_CRUD.p", goCollectionHandlePgm).
    run setCtctt in ghProc(table ttCtctt by-reference).
    if mError:erreur() then return.

    /* Generation des Enregistrements dans INTNT */
    empty temp-table ttIntnt.
    if not can-find(first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-bail}
                      and intnt.nocon = giNumeroNouveauBail
                      and intnt.tpidt = {&TYPEROLE-mandant}
                      and intnt.noidt = giNumeroMandat)
    then do:
        create ttIntnt.
        assign
            ttIntnt.CRUD  = 'C'
            ttIntnt.tpidt = {&TYPEROLE-mandant}
            ttIntnt.noidt = giNumeroMandat
            ttIntnt.tpcon = {&TYPECONTRAT-bail}
            ttIntnt.nocon = giNumeroNouveauBail
            ttIntnt.nbnum = 0
            ttIntnt.idsui = 0
            ttIntnt.nbden = 0
            ttIntnt.cdreg = ""
            ttIntnt.lbdiv = ""
            .
    end.
    if not can-find(first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-bail}
                      and intnt.nocon = giNumeroNouveauBail
                      and intnt.tpidt = {&TYPEROLE-locataire}
                      and intnt.noidt = giNumeroNouveauBail)
    then do:
        create ttIntnt.
        assign
            ttIntnt.CRUD  = 'C'
            ttIntnt.tpidt = {&TYPEROLE-locataire}
            ttIntnt.noidt = giNumeroNouveauBail
            ttIntnt.tpcon = {&TYPECONTRAT-bail}
            ttIntnt.nocon = giNumeroNouveauBail
            ttIntnt.nbnum = 0
            ttIntnt.idsui = 0
            ttIntnt.nbden = 0
            ttIntnt.cdreg = ""
            ttIntnt.lbdiv = ""
            .
    end.
    if not can-find(first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-bail}
                      and intnt.nocon = giNumeroNouveauBail
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = giNumeroImmeuble)
    then do:
        create ttIntnt.
        assign
            ttIntnt.CRUD  = 'C'
            ttIntnt.tpidt = {&TYPEBIEN-immeuble}
            ttIntnt.noidt = giNumeroImmeuble
            ttIntnt.tpcon = {&TYPECONTRAT-bail}
            ttIntnt.nocon = giNumeroNouveauBail
            ttIntnt.nbnum = 0
            ttIntnt.idsui = 0
            ttIntnt.nbden = 0
            ttIntnt.cdreg = ""
            ttIntnt.lbdiv = ""
            .
    end.
    ghProc = lancementPgm("adblib/intnt_CRUD.p", goCollectionHandlePgm).
    run setIntnt in ghProc(table ttIntnt by-reference).
    if mError:erreur() then return.

    /* Duplication adresse(s)  */
    empty temp-table ttLadrs.
    for first ladrs no-lock
        where ladrs.tpidt = ctrat.tprol
          and ladrs.noidt = ctrat.norol
          and ladrs.tpadr = {&TYPEADRESSE-Principale}:
        create ttLadrs.
        outils:copyValidField(buffer ladrs:handle, buffer ttLadrs:handle).
        assign
            ttLadrs.nolie = 0
            ttLadrs.tpidt = {&TYPEROLE-locataire}
            ttLadrs.noidt = giNumeroNouveauBail
            ttLadrs.CRUD  = "C"
            .
        ghProc = lancementPgm("adresse/ladrs_CRUD.p", goCollectionHandlePgm).
        run setLadrs in ghProc(table ttLadrs by-reference).
        if mError:erreur() then return.
        //duplication telephone
        ghProc = lancementPgm("adresse/fcttelep.p", goCollectionHandlePgm).
        run dupliqueTelephones in ghProc(ctrat.tprol, ctrat.norol, {&TYPEROLE-locataire}, giNumeroNouveauBail).
        if mError:erreur() then return.
    end.

    /* Duplication des Roles annexes */
    empty temp-table ttIntnt.
    for each intnt no-lock
       where intnt.tpcon = {&TYPECONTRAT-bail}
         and intnt.nocon = giNumeroContratOrigine
         and intnt.tpidt < "01000":
        if intnt.tpidt = {&TYPEROLE-locataire} or intnt.tpidt = {&TYPEROLE-mandant} or intnt.tpidt = {&TYPEROLE-candidatLocataire}
        then next.
        if not can-find(first vbintnt no-lock
                        where vbintnt.tpcon = {&TYPECONTRAT-bail}
                          and vbintnt.nocon = giNumeroNouveauBail
                          and vbintnt.tpidt = intnt.tpidt
                          and vbintnt.noidt = intnt.noidt)
        then do:
            create ttIntnt.
            outils:copyValidField(buffer intnt:handle, buffer ttIntnt:handle).
            assign
                ttIntnt.CRUD  = "C"
                ttIntnt.tpcon = {&TYPECONTRAT-bail}
                ttIntnt.nocon = giNumeroNouveauBail
            .
        end.
    end.
    ghProc = lancementPgm("adblib/intnt_CRUD.p", goCollectionHandlePgm).
    run setIntnt in ghProc(table ttIntnt by-reference).
    if mError:erreur() then return.

    /*-----------------------------------------------*
     | Duplication des taches                        |
     *-----------------------------------------------*/
    /*  Traitement des révisions AVANT car tache.noita renuméroté lors de la duplication des taches */
    run Gesrevtrt.
    if mError:erreur() then return.

    empty temp-table ttTache.
    empty temp-table ttRevtrt.
    empty temp-table ttRevhis.
    empty temp-table ttDetail.
    for each tache no-lock
       where tache.tpcon = {&TYPECONTRAT-bail}
         and tache.nocon = giNumeroContratOrigine:
        /* Les taches Droit de bail et allocation logement pour Pre-bail ne doivent plus exister */
        if tache.tptac = {&TYPETACHE-droit2Bail} or tache.tptac = {&TYPETACHE-allocationLogement} then next.
        if can-find(first vbtache no-lock
                    where vbtache.tpcon = {&TYPECONTRAT-bail}
                      and vbtache.nocon = giNumeroNouveauBail
                      and vbtache.tptac = tache.tptac
                      and vbtache.notac = tache.notac)
        then next.
        create ttTache.
        outils:copyValidField(buffer tache:handle, buffer ttTache:handle).
        assign
            ttTache.CRUD  = "C"
            ttTache.noita = 0
            ttTache.tpcon = {&TYPECONTRAT-bail}
            ttTache.nocon = giNumeroNouveauBail
            ttTache.cdcsy = ?
        .
        if tache.tptac = {&TYPETACHE-quittancement}
        then do:
            /* RAZ date de sortie si c'est celle due à la mutation */
            if gDtResBai-IN <> ? and tache.dtfin = gDtResBai-IN then ttTache.dtfin = ?.
            if vdaSortieLoc <> ? then ttTache.dtfin = vdaSortieLoc.
            mLogger:writeLog (0,  "Duplication tache 04029 - Bail " + string(giNumeroContratOrigine) + " -> " + string(giNumeroNouveauBail) + " ancienne date de sortie = " + (if tache.dtfin <> ? then string(tache.dtfin, "99/99/9999" ) else "" ) + " Nouvelle date de sortie = " + (if tache.dtfin <> ? then string(tache.dtfin, "99/99/9999" ) else "" ) + " svg DtSortie = " + (if vdaSortieLoc <> ? then string(vdaSortieLoc,"99/99/9999") else "") ).
            /* RAZ banque de prélèvement (le nouveau mandat n'aura pas forcément les mêmes) */
            ttTache.lbdiv = "-" + separ[1] + "0".
        end.
        if tache.tptac = {&TYPETACHE-quittancementRubCalculees}
        then do:
            for each detail no-lock
               where detail.cddet = tache.tpcon
                 and detail.iddet = integer("04360")
                 and detail.nodet = tache.nocon:
                mLogger:writeLog (0,  "Duplication param rubrique calculees - detail : " + detail.cddet + " " + string(detail.nodet) + " ->" + string(giNumeroNouveauBail) ).
                create ttDetail.
                outils:copyValidField(buffer detail:handle, buffer ttDetail:handle).
                assign
                    ttDetail.CRUD  = "C"
                    ttDetail.nodet = giNumeroNouveauBail
                    ttDetail.cdcsy = mtoken:cUser + "@" + "DUPLI"
                .
            end.
            ghProc = lancementPgm("adblib/detail_CRUD.p", goCollectionHandlePgm).
            run setDetail in ghProc (table ttDetail by-reference).
            if mError:erreur() then return.
        end.
    end. /* du for each sur les taches */
    ghProc = lancementPgm("tache/tache.p", goCollectionHandlePgm).
    run setTache in ghProc(table ttTache by-reference).
    if mError:erreur() then return.

    for each tache no-lock
       where tache.tpcon = {&TYPECONTRAT-bail}
         and tache.nocon = giNumeroContratOrigine
         and tache.tptac = {&TYPETACHE-revision}
    , first vbtache no-lock
       where vbtache.tpcon = {&TYPECONTRAT-bail}
         and vbtache.nocon = giNumeroNouveauBail
         and vbtache.tptac = {&TYPETACHE-revision}
         and vbtache.notac = tache.notac:
        for each revtrt no-lock
           where revtrt.tpcon = {&TYPECONTRAT-bail}
             and revtrt.nocon = giNumeroNouveauBail
             and revtrt.tprol = tache.tptac
             and revtrt.norol = tache.noita:
            create ttRevtrt.
            assign
                ttRevtrt.CRUD        = "U"
                ttRevtrt.inotrtrev   = revtrt.inotrtrev
                ttRevtrt.rRowid      = rowid(revtrt)
                ttRevtrt.dtTimestamp = datetime(revtrt.dtmsy, revtrt.hemsy)
                ttRevtrt.norol       = vbtache.noita
            .
        end.
        for each revhis no-lock
           where revhis.tpcon = {&TYPECONTRAT-bail}
             and revhis.nocon = giNumeroNouveauBail
             and revhis.tprol = tache.tptac
             and revhis.norol = tache.noita:
             create ttRevhis.
             assign
                 ttRevhis.CRUD        = "U"
                 ttRevhis.nohis       = revhis.nohis
                 ttRevhis.rRowid      = rowid(revhis)
                 ttRevhis.dtTimestamp = datetime(revhis.dtmsy, revhis.hemsy)
                 ttRevhis.norol       = vbtache.noita
             .
        end.
    end.
    ghProc = lancementPgm("adblib/revtrt_CRUD.p", goCollectionHandlePgm).
    run setRevtrt in ghProc(table ttRevtrt by-reference).
    if mError:erreur() then return.
    ghProc = lancementPgm("adblib/revhis_CRUD.p", goCollectionHandlePgm).
    run setRevhis in ghProc(table ttRevhis by-reference).
    if mError:erreur() then return.

    /* Duplication des cttac */
    empty temp-table ttCttac.
    for each cttac no-lock
       where cttac.tpcon = {&TYPECONTRAT-bail}
         and cttac.nocon = giNumeroContratOrigine:
        /* Les taches Droit de bail et allocation logement pour Pre-bail ne doivent plus exister */
        if cttac.tptac = {&TYPETACHE-droit2Bail} or cttac.tptac = {&TYPETACHE-allocationLogement} then next.
        if not can-find(first vbcttac no-lock
                        where vbcttac.tpcon = {&TYPECONTRAT-bail}
                          and vbcttac.nocon = giNumeroNouveauBail
                          and vbcttac.tptac = cttac.tptac)
        then do:
            create ttCttac.
            assign
                ttCttac.CRUD  = "C"
                ttCttac.tpcon = {&TYPECONTRAT-bail}
                ttCttac.nocon = giNumeroNouveauBail
                ttCttac.tptac = cttac.tptac
            .
        end.
    end.
    ghProc = lancementPgm("adblib/cttac_CRUD.p", goCollectionHandlePgm).
    run setCttac in ghProc (table ttCttac by-reference).
    if mError:erreur() then return.

    /* Ajout SY le 12/04/2011 : création du lien bail-RIB */
    empty temp-table ttRlctt.
    for first ctanx no-lock
        where ctanx.tpcon = {&TYPECONTRAT-prive}
          and ctanx.tprol = {&TYPEROLE-tiers}
          and ctanx.norol = viNumeroTiers
          and ctanx.tpact = "DEFAU":
        create ttRlctt.
        assign
            ttRlctt.tpidt = {&TYPEROLE-locataire}
            ttRlctt.noidt = giNumeroNouveauBail
            ttRlctt.tpct1 = {&TYPECONTRAT-bail}
            ttRlctt.noct1 = giNumeroNouveauBail
            ttRlctt.tpct2 = ctanx.tpcon
            ttRlctt.noct2 = ctanx.nocon
            ttRlctt.lbdiv = ""
            ttRlctt.CRUD  = ""                     // pas d'init du crud, sera mis a jour dans rlctt_CRUD.p/bquRlctt
        .
        ghProc = lancementPgm("adblib/rlctt_CRUD.p", goCollectionHandlePgm).
        run bquRlCtt in ghProc(input-output table ttRlctt by-reference).
        if mError:erreur() then return.
        run setRlctt in ghProc(table ttRlctt by-reference).
        if mError:erreur() then return.
    end.

    /* Ajout Sy le 04/09/2013 : Duplication du mandat de prélèvement SEPA  */
    empty temp-table ttMandatSEPA.
    empty temp-table ttSuiMandatSEPA.
    for each vbmandatSEPA no-lock
       where vbmandatSEPA.Tpmandat = {&TYPECONTRAT-sepa}
         and vbmandatSEPA.ntcon    = {&NATURECONTRAT-recurrent}
         and vbmandatSEPA.tpcon    = {&TYPECONTRAT-bail}
         and vbmandatSEPA.nocon    = giNumeroContratOrigine:
        /* Prochains No interne mandat prelevement SEPA */
        find last mandatSepa no-lock no-error.
        viNumeroMdtSepa = (if available mandatSEPA then mandatSEPA.noMPrelSEPA + 1 else 1).
        find last mandatSepa no-lock
            where mandatSEPA.Tpmandat = {&TYPECONTRAT-sepa}
              and mandatSEPA.ntcon    = {&NATURECONTRAT-recurrent}
              and mandatSEPA.nomdt    = giNumeroMandatAcheteur
              and mandatSEPA.tpcon    = {&TYPECONTRAT-bail}
              and mandatSEPA.nocon    = giNumeroNouveauBail
              and mandatSEPA.tprol    = vbmandatSEPA.tprol
              and mandatSEPA.norol    = (if vbmandatSEPA.tprol = {&TYPEROLE-locataire} then giNumeroNouveauBail else vbmandatSEPA.norol)
        use-index ix_mandatsepa07 no-error.
        NoNxtOrd = (if available mandatSEPA then mandatSEPA.noord + 1 else 1).
        create ttMandatSEPA.
        outils:copyValidField(buffer vbmandatSEPA:handle, buffer ttMandatSEPA:handle).
        assign
            ttMandatSEPA.CRUD        = "C"
            ttMandatSEPA.noMPrelSEPA = viNumeroMdtSepa
            ttMandatSEPA.nomdt       = giNumeroMandatAcheteur
            ttMandatSEPA.nocon       = giNumeroNouveauBail
            ttMandatSEPA.norol       = (if vbmandatSEPA.tprol = {&TYPEROLE-locataire} then giNumeroNouveauBail else vbmandatSEPA.norol)
            ttMandatSEPA.noord       = NoNxtOrd
            ttMandatSEPA.cdcsy       = mtoken:cUser + "@" + "mutbai01.p"
        .
        for each suimandatsepa no-lock
           where suimandatsepa.noMPrelSEPA = vbmandatSEPA.noMPrelSEPA:
            create ttSuiMandatSEPA.
            outils:copyValidField(buffer suimandatsepa:handle, buffer ttSuiMandatSEPA:handle).
            assign
                ttSuiMandatSEPA.CRUD        = "C"
                ttSuiMandatSEPA.noMPrelSEPA = viNumeroMdtSepa
            .
        end.
        /* Ajout SY le 12/02/2016 : résilier mandat SEPA ancien locataire si actif */
        if vbmandatSEPA.dtresil = ?
        then do:
            create ttMandatSEPA.
            assign
                ttMandatSEPA.CRUD        = "U"
                ttMandatSEPA.dtTimestamp = datetime(vbmandatSEPA.dtmsy, vbmandatSEPA.hemsy)
                ttMandatSEPA.rRowid      = rowid(vbmandatSEPA)
                ttMandatSEPA.dtresil     = ctrat.dtree           /* date de résiliation du bail */
                ttMandatSEPA.Motifresil  = "MUTATION"
                ttMandatSEPA.FgValide    = false
            .
            mLogger:writeLog (0, "Résiliation mandat PREL SEPA pour bail " + string(mandatSEPA.nocon) + " " + ctrat.lbnom + " au " + (if ctrat.dtree <> ? then string(ctrat.dtree) else "")).
        end.
    end.
    ghProc = lancementPgm("adblib/mandatSepa_CRUD.p", goCollectionHandlePgm).
    run setMandatsepa in ghProc (table ttMandatSEPA by-reference).
    if mError:erreur() then return.
    ghProc = lancementPgm("adblib/suiMandatSepa_CRUD.p", goCollectionHandlePgm).
    run setSuiMandatsepa in ghProc (table ttSuiMandatSEPA by-reference).
    if mError:erreur() then return.

    /* Ajout Sy le 23/05/2011 : calendriers d'évolution et echelles mobiles */
    /* echelle mobile */
    empty temp-table ttEchlo.
    for each echlo no-lock
        where echlo.tpcon = {&TYPECONTRAT-bail}
          and echlo.nocon = giNumeroContratOrigine:
        create ttEchlo.
        outils:copyValidField(buffer echlo:handle, buffer ttEchlo:handle).
        assign
            ttEchlo.CRUD  = "C"
            ttEchlo.tpcon = {&TYPECONTRAT-bail}
            ttEchlo.nocon = giNumeroNouveauBail
            ttEchlo.cdcsy = mtoken:cUser + "@" + "mutbai01.p"
        .
    end.
    ghProc = lancementPgm("adblib/echlo_CRUD.p", goCollectionHandlePgm).
    run setEchlo in ghProc (table ttEchlo by-reference).
    if mError:erreur() then return.

    /* calendrier */
    empty temp-table ttCalev.
    for each calev no-lock
       where calev.tpcon = {&TYPECONTRAT-bail}
         and calev.nocon = giNumeroContratOrigine:
        create ttCalev.
        outils:copyValidField(buffer calev:handle, buffer ttCalev:handle).
        assign
            ttCalev.CRUD  = "C"
            ttCalev.tpcon = {&TYPECONTRAT-bail}
            ttCalev.nocon = giNumeroNouveauBail
            ttCalev.cdcsy = mtoken:cUser + "@" + "mutbai01.p"
        .
    end.
    ghProc = lancementPgm("adblib/calev_CRUD.p", goCollectionHandlePgm).
    run setCalev in ghProc (table ttCalev by-reference).
    if mError:erreur() then return.

    /* chiffre d'affaire */
    empty temp-table ttChaff.
    for each chaff no-lock
       where chaff.tpcon = {&TYPECONTRAT-bail}
         and chaff.nocon = giNumeroContratOrigine:
        create ttChaff.
        outils:copyValidField(buffer chaff:handle, buffer ttChaff:handle).
        assign
            ttChaff.CRUD  = "C"
            ttChaff.tpcon = {&TYPECONTRAT-bail}
            ttChaff.nocon = giNumeroNouveauBail
            ttChaff.cdcsy = mtoken:cUser + "@" + "mutbai01.p"
        .
    end.
    ghProc = lancementPgm("adblib/chaff_CRUD.p", goCollectionHandlePgm).
    run setChaff in ghProc (table ttChaff by-reference).
    if mError:erreur() then return.

    /*  attestations d'assurances  */
    empty temp-table ttAssat.
    for each assat no-lock
       where assat.tpcon = {&TYPECONTRAT-bail}
         and assat.nocon = giNumeroContratOrigine:
        create ttAssat.
        outils:copyValidField(buffer assat:handle, buffer ttAssat:handle).
        assign
            ttAssat.CRUD  = "C"
            ttAssat.tpcon = {&TYPECONTRAT-bail}
            ttAssat.nocon = giNumeroNouveauBail
            ttAssat.cdcsy = mtoken:cUser + "@" + "mutbai01.p"
        .
    end.
    ghProc = lancementPgm("adblib/assat_CRUD.p", goCollectionHandlePgm).
    run setAssat in ghProc (table ttAssat by-reference).
    if mError:erreur() then return.

    /*-->  rubriques spécifique locataire */
    empty temp-table ttPrrub.
    for each prrub no-lock
       where prrub.noloc = giNumeroContratOrigine:
        create ttPrrub.
        outils:copyValidField(buffer prrub:handle, buffer ttPrrub:handle).
        assign
            ttPrrub.CRUD  = "C"
            ttPrrub.noloc = giNumeroNouveauBail
            ttPrrub.cdcsy = mtoken:cUser + "@" + "mutbai01.p"
        .
    end.
    ghProc = lancementPgm("adblib/prrub_CRUD.p", goCollectionHandlePgm).
    run setPrrub in ghProc (table ttPrrub by-reference).
    if mError:erreur() then return.

    /* Maj Occupant UL */
    /* Ajout SY le 13/07/2010 : Mise à jour de l'occupant des lots de l'UL */
    find first ctrat no-lock
         where ctrat.tpcon = {&TYPECONTRAT-bail}
           and ctrat.nocon = giNumeroNouveauBail no-error.
    if not available ctrat
    then do:
//gga todo doit forcement exister
    end.

message "avant CreLog-iAction " giNumeroNouveauBail "// " giNumeroContratOrigine. 

    /* ajout SY le 04/09/2013 : trace dans iaction */
    find first vbctrat no-lock
         where vbctrat.tpcon = "01030"
           and vbctrat.nocon = integer(substring(string(giNumeroContratOrigine, '9999999999'), 1, 5, 'character')) no-error.
    assign    
        vcAction      = "Création du Bail " + string(ctrat.nocon) + " - " + ctrat.lbnom + " suite à la mutation de gérance no " + gcNoMutUse + " du mandat " + substring(string(giNumeroContratOrigine, '9999999999'), 1, 5, 'character') + " - " + (if available vbctrat then vbctrat.lbnom else "")
        vcNomPrg-Info = "CRE" + "BAIL" + "@" + "mutbai01.p"   
    .
    run CreLog-iAction (mtoken:cUser, vcAction, vcNomPrg-Info, ctrat.tprol, ctrat.norol, "", "", ctrat.tpcon, ctrat.nocon, "", 0, "", "").

    empty temp-table ttLocal.
    for last tache no-lock
       where tache.tpcon = ctrat.tpcon
         and tache.nocon = ctrat.nocon
         and tache.tptac = {&TYPETACHE-quittancement}:
        vdaEntreeOcc = tache.dtdeb.
    end.
    for each unite no-lock
       where unite.nomdt = giNumeroMandatAcheteur
         and unite.noact = 0
         and unite.noapp = integer(substring(string(ctrat.nocon, "9999999999"), 6, 3, 'character'))
    , each cpuni no-lock
     where cpuni.nomdt = unite.nomdt
       and cpuni.noapp = unite.noapp
       and cpuni.nocmp = unite.nocmp
    , first local no-lock
      where local.noimm = cpuni.noimm
        and local.nolot = cpuni.nolot
    break by cpuni.noord:
        if local.nmocc <> ctrat.lbnom
        then do:
            /*--> Information occupant */
            create ttLocal.
            assign
                ttLocal.noloc       = local.noloc
                ttLocal.CRUD        = "U"
                ttLocal.dtTimestamp = datetime(local.dtmsy, local.hemsy)
                ttLocal.rRowid      = rowid(local)
                ttLocal.NmOcc       = ctrat.lbnom
                ttLocal.DtEnt       = vdaEntreeOcc
                ttLocal.lbdiv3      = "00000"
                ttLocal.cdmsy       = mtoken:cUser + "@" + "mutbai01.p"
            .
        end.
    end.
    ghProc = lancementPgm("adblib/local_CRUD.p", goCollectionHandlePgm).
    run setLocal in ghProc (table ttLocal by-reference).
    if mError:erreur() then return.
    /* Maj code occupant UL */
    empty temp-table ttUnite.
    for each unite no-lock
       where unite.nomdt = giNumeroMandatAcheteur
         and unite.noact = 0
         and unite.noapp = integer(substring(string(ctrat.nocon, "9999999999"), 6, 3, 'character')):
        assign
            NoLotPrc = 0
            NoLieLot = 0
        .
        for first cpuni no-lock
            where cpuni.nomdt = unite.nomdt
              and cpuni.noapp = unite.noapp
              and cpuni.nocmp = unite.nocmp
        , first local no-lock
          where local.noimm = cpuni.noimm
            and local.nolot = cpuni.nolot
        , first ladrs no-lock
          where ladrs.tpidt = {&TYPEBIEN-lot}
            and ladrs.noidt = local.noloc
            and ladrs.tpadr = {&TYPEADRESSE-Principale}:
            assign
                NoLotPrc = local.nolot
                NoLieLot = ladrs.nolie
            .
        end.
        create ttUnite.
        assign
            ttUnite.nomdt       = unite.nomdt
            ttUnite.noapp       = unite.noapp
            ttUnite.noact       = unite.noact
            ttUnite.CRUD        = "U"
            ttUnite.dtTimestamp = datetime(unite.dtmsy, unite.hemsy)
            ttUnite.rRowid      = rowid(unite)
            ttUnite.nolot       = NoLotPrc
            ttUnite.nolie       = NoLieLot
            ttUnite.cdOcc       = (if ctrat.dtree = ? then "00001" else "00002")
            ttUnite.tprol       = ctrat.tprol
            ttUnite.norol       = ctrat.norol
            ttUnite.dtent       = vdaEntreeOcc
            ttUnite.dtsor       = ctrat.dtree
            ttUnite.tpfin       = ctrat.tpfin
        .
    end.
    ghProc = lancementPgm("adblib/unite_CRUD.p", goCollectionHandlePgm).
    run setUnite in ghProc (table ttUnite by-reference).
    if mError:erreur() then return.
    /* CAF */
    run GesAllocLog.
    if mError:erreur() then return.
    /* Quittancement */
    run GesQuitt (buffer ctrat).
    if mError:erreur() then return.

    /* stockage correspondance ancien bail / nouveau bail (tbent) */
    empty temp-table ttTbent.
    find last tbent no-lock
        where tbent.cdent          = "MUTAG" + gcNumeroContratMutation
          and integer(tbent.iden1) = giNumeroContratOrigine no-error.
    create ttTbent.
    if not available tbent
    then assign
             ttTbent.CRUD  = "C"
             ttTbent.cdent = "MUTAG" + gcNumeroContratMutation
             ttTbent.iden1 = string(giNumeroContratOrigine, "9999999999")
             ttTbent.lben1 = outilFormatage:getNomTiers({&TYPEROLE-locataire}, giNumeroContratOrigine)
    .
    else assign
             ttTbent.cdent       = tbent.cdent
             ttTbent.iden1       = tbent.iden1
             ttTbent.iden2       = tbent.iden2
             ttTbent.CRUD        = "U"
             ttTbent.dtTimestamp = datetime(tbent.dtmsy, tbent.hemsy)
             ttTbent.rRowid      = rowid(tbent)
    .
    ttTbent.mten1 = giNumeroNouveauBail.
    ghProc = lancementPgm("adblib/tbent_CRUD.p", goCollectionHandlePgm).
    run settbent in ghProc (table ttTbent by-reference).
    if mError:erreur() then return.

    /*--> Prevenir Compta d'un nouveau Locataire. */
    ghProc = lancementPgm("immeubleEtLot/pontImmeubleCompta.p", goCollectionHandlePgm).
    run majCompteExterne in ghProc({&TYPECONTRAT-mandat2Gerance}, giNumeroMandatAcheteur, viNumeroTiers, {&TYPEROLE-locataire}, giNumeroNouveauBail, 0, 0).

    /* Transfert des écritures comptables Vendeur -> acheteur */
    /* ON PEUT S'INSPIRER de la cession du bail (cadb/src/gestion/cesbai.p)  */
    /* A voir : 2 dates importantes (et non pas une seule) : DATE d'achat notaire + date de résiliation du bail */
    ghProc = lancementPgm("cadbgestion/mutbai.p", goCollectionHandlePgm).
    run lancementMutbai in ghProc(integer(mToken:cRefGerance),
                                  integer(substring(string(giNumeroContratOrigine  , '9999999999'), 1, 5 , 'character')),
                                  integer(substring(string(giNumeroContratOrigine  , '9999999999'), 6, -1, 'character')),
                                  integer(substring(string(giNumeroNouveauBail     , '9999999999'), 1, 5 , 'character')),
                                  integer(substring(string(giNumeroNouveauBail     , '9999999999'), 6, -1, 'character')),
                                  gdaAchatNotaire).
    if mError:erreur()
    then do:
        mError:createError({&error}, 1000743). //La comptabilisation de la mutation en gérance a échoué.
        return.
    end.

end procedure.

procedure GesAllocLog private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcSelectionDateBordereau as character no-undo.
    define variable vcZoneTemp               as character no-undo.
    define variable viGlMoiQtt               as integer   no-undo.

    define variable voCollectionQuit as class collection no-undo.

    define buffer tbent for tbent.
    define buffer tbdet for tbdet.

    ghProc = lancementPgm("adblib/transfert/suiviTransfert_CRUD.p", goCollectionHandlePgm).
    voCollectionQuit = new collection().
    voCollectionQuit:set("cCodeTraitement", "QUIT").
    run calculTransfertAppelExterne in ghProc(input-output voCollectionQuit).
    viGlMoiQtt = voCollectionQuit:getInteger("GlMoiQtt").
    delete object voCollectionQuit.

    /* MATRICULES CAF */
    /* ATTENTION FORMAT no bail */
    empty temp-table ttTbent.
    for each tbent no-lock
       where tbent.cdent = "00001"
         and integer(entry(1, tbent.iden2, separ[1])) = giNumeroContratOrigine:
        vcZoneTemp = tbent.iden2.
        if num-entries(vcZoneTemp, separ[1]) > 1
        then entry(1, vcZoneTemp, separ[1]) = string(giNumeroNouveauBail, "9999999999").
        else vcZoneTemp = string(giNumeroNouveauBail, "9999999999").
        create ttTbent.
        outils:copyValidField(buffer tbent:handle, buffer ttTbent:handle).
        assign
            ttTbent.CRUD  = "C"
            ttTbent.iden2  = vcZoneTemp
        .
    end.
    ghProc = lancementPgm("adblib/tbent_CRUD.p", goCollectionHandlePgm).
    run settbent in ghProc (table ttTbent by-reference).
    if mError:erreur() then return.

    /* BORDEREAUX CAF */
    if gdaAchatNotaire > today
    then vcSelectionDateBordereau = string(Date2Inte(gdaAchatNotaire), "99999999").
    else vcSelectionDateBordereau = string(Date2Inte(gdaAchatNotaire) - 90, "99999999"). /* limitation de la recherche aux bordereaux de moins de 3 mois */

    empty temp-table ttTbdet.
    for each tbent no-lock
       where tbent.cdent = "00002"
         and tbent.iden2 >= vcSelectionDateBordereau   /* date du bordereau */
         and not tbent.fgen1             /* non comptabilisé */
    break by tbent.iden1 by tbent.iden2 by tbent.dten1:
        /*--> Renumérotation des Détails */
        for each tbdet no-lock
           where tbdet.cdent = "00002"
             and tbdet.iden1 = tbent.iden1
             and tbdet.iden2 = tbent.iden2
             and integer(entry(1, tbdet.lbde1, separ[1])) = giNumeroContratOrigine:
            mLogger:writeLog (0,   "Bordereau CAF " + " caisse = " + tbent.iden1 + " Date remise = " + tbent.iden2 + " matricule = " + tbdet.idde1 + " infos bail = " + tbdet.lbde1 ).
            vcZoneTemp = tbdet.lbde1.
            entry(1, vcZoneTemp, separ[1]) = string(giNumeroNouveauBail, "9999999999").
            create ttTbdet.
            assign
                ttTbdet.cdent       = tbdet.cdent
                ttTbdet.iden1       = tbdet.iden1
                ttTbdet.iden2       = tbdet.iden2
                ttTbdet.idde1       = tbdet.idde1
                ttTbdet.idde2       = tbdet.idde2
                ttTbdet.CRUD        = "U"
                ttTbdet.dtTimestamp = datetime(tbdet.dtmsy, tbdet.hemsy)
                ttTbdet.rRowid      = rowid(tbdet)
                ttTbdet.lbde1       = vcZoneTemp.
                ttTbdet.cdmsy       = mtoken:cUser + "@" + "mutbai01"
            .
        end.
    end.
    ghProc = lancementPgm("adblib/tbdet_CRUD.p", goCollectionHandlePgm).
    run setTbdet in ghProc (table ttTbdet by-reference).
    if mError:erreur() then return.

    /* AVANCE */
    empty temp-table ttTbdet.
    for each tbdet no-lock
       where tbdet.cdent = "00001"
         and tbdet.idde1 > string(giMoisDernierQuittancement , "999999")
        and tbdet.idde1 >= string(viGlMoiQtt , "999999")
         and integer( entry(1,tbdet.iden2,SEPAR[1]) ) = giNumeroContratOrigine
    , first tbent no-lock
      where tbent.cdent = "00001"
        and tbent.iden1 = tbdet.iden1
        and tbent.iden2 = tbdet.iden2:
        vcZoneTemp = tbdet.iden2.
        entry(1, vcZoneTemp, separ[1]) = string(giNumeroNouveauBail, "9999999999").
        create ttTbdet.
        assign
            ttTbdet.cdent       = tbdet.cdent
            ttTbdet.iden1       = tbdet.iden1
            ttTbdet.iden2       = vcZoneTemp
            ttTbdet.idde1       = tbdet.idde1
            ttTbdet.idde2       = tbdet.idde2
            ttTbdet.CRUD        = "U"
            ttTbdet.dtTimestamp = datetime(tbdet.dtmsy, tbdet.hemsy)
            ttTbdet.rRowid      = rowid(tbdet)
        .
    end.
    ghProc = lancementPgm("adblib/tbdet_CRUD.p", goCollectionHandlePgm).
    run setTbdet in ghProc (table ttTbdet by-reference).
    if mError:erreur() then return.

end procedure.

procedure GesQuitt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ctrat for ctrat.

    define variable viAnneeMoisReglement      as integer no-undo.
    define variable viAnneeReglement          as integer no-undo.
    define variable viMoisReglement           as integer no-undo.
    define variable vdaReglement              as date    no-undo.
    define variable vdaFinApplicationRubrique as date    no-undo.
    define variable vlTaciteReconduction      as logical no-undo.
    define variable vdaSortieLocataire        as date    no-undo.
    define variable vdaResiliationBail        as date    no-undo.
    define variable vdaFinBail                as date    no-undo.
    define variable vlPrendre                 as logical no-undo.

    define buffer aquit for aquit.
    define buffer coloc for coloc.
    define buffer equit for equit.
    define buffer tache for tache.

    empty temp-table ttAquit.
    empty temp-table ttColoc.
    if giMoisDernierQuittancement <> 0
    then do:
        /* Historique de quittancement : */
        /* déplacement vers l'acheteur de tout l'histo > dernier mois quittancé */
        /* (NB : je n'ai pas de critères spécifiques pour les factures) */
        for each aquit no-lock
           where aquit.noloc = giNumeroContratOrigine
             and aquit.msqtt > giMoisDernierQuittancement:
            create ttAquit.
            assign
                ttAquit.noint       = aquit.noint
                ttAquit.CRUD        = "U"
                ttAquit.rRowid      = rowid(aquit)
                ttAquit.dtTimestamp = datetime(aquit.dtmsy, aquit.hemsy)
                ttAquit.noloc       = giNumeroNouveauBail
                ttAquit.nomdt       = giNumeroMandatAcheteur
            .
            /* gestion des répartitions de colocation */
            for each coloc no-lock
               where coloc.tpcon = {&TYPECONTRAT-bail}
                 and coloc.nocon = giNumeroContratOrigine
                 and coloc.noqtt = aquit.noqtt
                 and coloc.noqtt <> 0:                              /* par securité pour ne pas effacer l'entete de la colocation */
                create ttColoc.
                assign
                    ttColoc.tpcon       = coloc.tpcon
                    ttColoc.msqtt       = coloc.msqtt
                    ttColoc.noord       = coloc.noord
                    ttColoc.tpidt       = coloc.tpidt
                    ttColoc.noidt       = coloc.noidt
                    ttColoc.CRUD        = "U"
                    ttColoc.rRowid      = rowid(coloc)
                    ttColoc.dtTimestamp = datetime(coloc.dtmsy, coloc.hemsy)
                    ttColoc.nocon       = giNumeroNouveauBail
                .
                if coloc.tpidt = {&TYPEROLE-locataire} then ttColoc.noidt = giNumeroNouveauBail.
            end.
        end.
    end.
    ghProc = lancementPgm("adblib/aquit_CRUD.p", goCollectionHandlePgm).
    run setAquit in ghProc(table ttAquit by-reference).
    if mError:erreur() then return.
    ghProc = lancementPgm("adblib/coloc_CRUD.p", goCollectionHandlePgm).
    run setColoc in ghProc(table ttColoc by-reference).
    if mError:erreur() then return.

    /* En cours quittancement */
    empty temp-table ttEquit.
    for each equit no-lock
       where equit.noloc = giNumeroContratOrigine
         and equit.msqtt > giMoisDernierQuittancement
    use-index ix_equit03:
        if viAnneeMoisReglement = 0 then viAnneeMoisReglement = equit.msqtt.
        create ttEquit.
        assign
            ttEquit.noqtt       = equit.noqtt
            ttEquit.CRUD        = "U"
            ttEquit.rRowid      = rowid(equit)
            ttEquit.dtTimestamp = datetime(equit.dtmsy, equit.hemsy)
            ttEquit.noloc       = giNumeroNouveauBail
            ttEquit.nomdt       = giNumeroMandatAcheteur
        .
    end.
    ghProc = lancementPgm("bail/quittancement/equit_CRUD.p", goCollectionHandlePgm).
    run setEquit in ghProc(table ttEquit by-reference).
    if mError:erreur() then return.

    /* lancer le renouvellement pour bien avoir les Avis Echéance futurs */
    for first equit no-lock
        where equit.noloc = giNumeroNouveauBail:
        /* Init Date de sortie et résiliation du bail , DtMaxQtt */
        run filtreLoc(equit.dtdpr, equit.dtfpr, output vlTaciteReconduction, output vdaFinBail, output vdaSortieLocataire, output vdaResiliationBail, output vlPrendre, output vdaFinApplicationRubrique).
        mLogger:writeLog (0,   "GesQuitt - Bail " + string(giNumeroNouveauBail) + " " + ctrat.lbnom + " vdaFinApplicationRubrique = " + (if vdaFinApplicationRubrique <> ? then string(vdaFinApplicationRubrique , "99/99/9999") else "") + " 1er equit = " + string(equit.msqtt) + " iMoisDernierQuittancement = " + string(giMoisDernierQuittancement) ).
/*gga todo
        {RunPgExp.i &Path       = RpRunQtt
                    &Prog       = "'GenQtRen.p'"
                    &Expert     = YES
                    &Parameter  = "equit.noloc, ctrat.dtdeb, ctrat.dtfin, ctrat.dtdeb, vdaFinApplicationRubrique, OUTPUT CdRetPrc"}
gga*/
    end.

    if viAnneeMoisReglement <> 0
    then assign
             viAnneeReglement = integer(substring(string(viAnneeMoisReglement, "999999"), 1, 4, 'character'))
             viMoisReglement  = integer(substring(string(viAnneeMoisReglement, "999999"), 5, 2, 'character'))
             vdaReglement     = date(viMoisReglement, 01, viAnneeReglement)
    .
    empty temp-table ttTache.
    for last tache no-lock
       where tache.tpcon = {&TYPECONTRAT-bail}
         and tache.nocon = giNumeroNouveauBail
         and tache.tptac = {&TYPETACHE-quittancement}:
        create ttTache.
        assign
            ttTache.tpcon       = tache.tpcon
            ttTache.nocon       = tache.nocon
            ttTache.tptac       = tache.tptac
            ttTache.notac       = tache.notac
            ttTache.CRUD        = "U"
            ttTache.rRowid      = rowid(tache)
            ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
            ttTache.dtreg       = vdaReglement
        .
    end.
    ghProc = lancementPgm("tache/tache.p", goCollectionHandlePgm).
    run setTache in ghProc(table ttTache by-reference).
    if mError:erreur() then return.

end procedure.

procedure GesRevtrt private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viNoNxtTrtrev as integer init 1 no-undo.
    define variable viNoNxtHis    as integer init 1 no-undo.

    define buffer revtrt for revtrt.
    define buffer revhis for revhis.

    empty temp-table ttRevtrt.
    empty temp-table ttRevHis.

    for last revtrt no-lock:
        viNoNxtTrtrev = revtrt.inotrtrev + 1.
    end.
    for each revtrt no-lock
       where revtrt.tpcon = {&TYPECONTRAT-bail}
         and revtrt.nocon = giNumeroContratOrigine:
        create ttRevtrt.
        outils:copyValidField(buffer revtrt:handle, buffer ttRevtrt:handle).
        assign
            ttRevtrt.CRUD      = "C"
            ttRevtrt.inotrtrev = viNoNxtTrtrev
            ttRevtrt.nocon     = giNumeroNouveauBail
            ttRevtrt.cdcsy     = mtoken:cUser + "@" + "mutbai01.p"
            viNoNxtTrtrev      = viNoNxtTrtrev + 1
        .
    end.

    for last revhis no-lock:
        viNoNxtHis = revhis.nohis + 1.
    end.
    for each revhis no-lock
       where revhis.tpcon = {&TYPECONTRAT-bail}
         and revhis.nocon = giNumeroContratOrigine:
        create ttRevhis.
        outils:copyValidField(buffer revhis:handle, buffer ttRevhis:handle).
        assign
            ttRevhis.CRUD  = "C"
            ttRevhis.nohis = viNoNxtHis
            ttRevhis.tpcon = {&TYPECONTRAT-bail}
            ttRevhis.nocon = giNumeroNouveauBail
            ttRevhis.cdcsy = mtoken:cUser + "@" + "mutbai01.p"
            viNoNxtHis     = viNoNxtHis + 1
        .
    end.
    ghProc = lancementPgm("adblib/revtrt_CRUD.p", goCollectionHandlePgm).
    run setRevtrt in ghProc(table ttRevtrt by-reference).
    if mError:erreur() then return.
    ghProc = lancementPgm("adblib/revhis_CRUD.p", goCollectionHandlePgm).
    run setRevhis in ghProc(table ttRevhis by-reference).

end procedure.
