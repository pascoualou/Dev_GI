/*------------------------------------------------------------------------
File        : validationMutation.p
Purpose     :
Author(s)   :
Notes       : a partir de adb/tach/prmmtmut.p
                          adb/cont/mutger02.p
------------------------------------------------------------------------*/
{preprocesseur/referenceClient.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/nature2cle.i}

using parametre.pclie.parametrageProlongationExpiration.
using parametre.pclie.parametrageChargeLocative.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tacheMutation.i}
{application/include/combo.i}
{application/include/glbsepar.i}
{comm/include/procclot.i}
{application/include/error.i}
{adblib/include/ctctt.i}
{immeubleEtLot/include/cpuni.i}
{adblib/include/cthis.i}
{adblib/include/unite.i}
{tache/include/tache.i}
{adblib/include/ctrat.i}
{adblib/include/intnt.i}
{compta/include/cpreln.i}
{adblib/include/detail.i}
{adblib/include/detlc.i}
{adblib/include/offlc.i}
{bail/include/filtreLo.i}          // Include pour Filtrage locataire à prendre, procedure filtreLoc
{outils/include/lancementProgramme.i}
{mandat/include/clemi.i}

define temp-table ttMilliemeLot no-undo
    field iNumeroLot as integer
    field cCdcle     as character
    field dNbPar     as decimal
.

define temp-table ttListeAnomalie no-undo
    field iNumero  as integer
    field cLibelle as character
.

define variable giGlMoiQtt        as integer   no-undo.
define variable giGlMoiMdf        as integer   no-undo.
define variable giGlMoiMec        as integer   no-undo.
define variable gIRefGerance      as integer   no-undo.
define variable giNumeroImmeuble  as integer   no-undo.
define variable glImmeubleCopro   as logical   no-undo.
define variable giMandant         as integer   no-undo.
define variable gcTypeValidation  as character no-undo.
define variable gcMotifValidation as character no-undo.

define variable ghProc as handle no-undo.

define variable goCollectionHandlePgm as class collection no-undo.

define variable giNbErreur as integer no-undo.

function numeroImmeuble return integer private(piNumeroMandat as int64, pcTypeMandat as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche immeuble du mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    find first intnt no-lock
         where intnt.tpcon = pcTypeMandat
           and intnt.nocon = piNumeroMandat
           and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
    if not available intnt
    then do:
        mError:createErrorGestion({&error}, 106470, string(piNumeroMandat)). //immeuble non trouve pour mandat %1
        return 0.
    end.
    return intnt.noidt.

end function.

function immeubleCopro return logical private(piNumeroImmeuble as int64):
    /*------------------------------------------------------------------------------
    Purpose: recherche si immeuble de copropriete
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    for each intnt no-lock
       where intnt.tpidt = {&TYPEBIEN-immeuble}
         and intnt.noidt = piNumeroImmeuble
         and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic}
    , first ctrat no-lock
      where ctrat.tpcon = intnt.tpcon
        and ctrat.nocon = intnt.nocon
        and ctrat.dtree = ?:
        return yes.
    end.
    return no.

end function.

procedure validationMutation:
    /*------------------------------------------------------------------------------
    Purpose: pcTypeValidation = 1 pour validation lot/ul du mandat (gestion IHM)
             pcTypeValidation = 2 pour validation lot/ul du mandat en attente de validation de la mutation (gestion IHM)
             pcMotifValidation = "" en validation (force a blanc dans beMandatGerance.cls)
    Notes
      : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeValidation  as character no-undo.
    define input parameter pcMotifValidation as character no-undo.
    define input parameter table for ttListeLotMutation.
    define input parameter table for ttMutation.
    define input parameter table for ttError.

    define variable vcCodeMutation  as character no-undo.
    define variable vcMessageAlerte as character no-undo.

    define buffer tache for tache.
    define buffer ctrat for ctrat.

    assign
         gcTypeValidation  = pcTypeValidation
         gcMotifValidation = pcMotifValidation
     .
    find first ttMutation where ttMutation.CRUD = "U" no-error.
    if not available ttMutation
    then do:
        mError:createError({&error}, 1000702).                      //Vous devez spécifier la ou les mutations à valider
        return.
    end.
    giNumeroImmeuble = numeroImmeuble(ttMutation.iNumeroContrat, ttMutation.cTypeContrat).
    if mError:erreur() then return.
    glImmeubleCopro = immeubleCopro(giNumeroImmeuble).
    find first ctrat no-lock
         where ctrat.tpcon = ttMutation.cTypeContrat
           and ctrat.nocon = ttMutation.iNumeroContrat no-error.
    if not available ctrat
    then do:
        mError:createError({&error}, 353).                //Mandat inexistant
        return.
    end.
    giMandant = ctrat.norol.
    goCollectionHandlePgm = new collection().
    run ctrl.
    if mError:erreur() then return.

    trt-maj: do:
        case gcTypeValidation:
            when "1" then do:
                mError:createError({&information}, 1000682). //La validation de la mutation est irréversible (résiliation des baux, lots retirés du mandat...)
                /* recherche si baux actifs sans mandat acheteur */
                boucleRechercheSiLotActif:
                for each ttMutation no-lock
                   where ttMutation.CRUD = "U"
                     and ttMutation.iNumeroMandatAcheteur = 0
                , each ttListeLotMutation no-lock
                 where ttListeLotMutation.iNumeroContratMutation = ttMutation.iNumeroContratMutation
                   and ttListeLotMutation.iNumeroBail <> 0
                , last tache no-lock
                 where tache.tpcon = {&TYPECONTRAT-bail}
                   and tache.nocon = ttListeLotMutation.iNumeroBail
                   and tache.tptac = {&TYPETACHE-quittancement}
                   and tache.dtfin = ?
                , first ctrat no-lock
                  where ctrat.tpcon = tache.tpcon
                    and ctrat.nocon = tache.nocon
                by ttListeLotMutation.iNumeroContratMutation
                by ttListeLotMutation.iNumeroBail desc:
                    mLogger:writeLog (0, "Validation - Mutation " + string(ttMutation.iNumeroContratMutation) + " Lot " + string(ttListeLotMutation.iNumeroLot) + " bail actif " + string(ttListeLotMutation.iNumeroBail) + " - " + ctrat.lbnom ).
                    mError:createError({&information}, 1000683, substitute('&2&1&3', separ[1], ttListeLotMutation.iNumeroBail, ctrat.lbnom)). //Il existe des baux actifs sans nouveau mandat de gérance (&1 - &2). Ces baux seront résiliés et la reprise mandat, UL et baux devra se faire manuellement
                    leave boucleRechercheSiLotActif.
                end.
                if outils:questionnaire (1000684, table ttError by-reference) <= 2  //Confirmez-vous la validation de cette(ces) mutation(s) ?
                then leave trt-maj.
                for each ttMutation where ttMutation.CRUD = "U":
                    vcCodeMutation = "MUTAG" + string(ttMutation.iNumeroContratMutation, "999999999").
                    run prepaListe01 (vcCodeMutation).
                    if mError:erreur() then leave trt-maj.
                    run venteGerance (vcCodeMutation).
                    if mError:erreur() then leave trt-maj.
                    if ttMutation.iNumeroMandatAcheteur > 0
                    then do:
                        if not glImmeubleCopro
                        then run achatGerance (vcCodeMutation).
                        if mError:erreur() then leave trt-maj.
                    end.
                    else do:
                        /* maj contrat mutation  => définitif (fgprov) + date */
                        run validMutation (ttMutation.iNumeroContratMutation, "Validation1").
                        if mError:erreur() then leave trt-maj.
                    end.
                end.
            end.
            when "2" then do:
                for each ttMutation
                   where ttMutation.CRUD = "U"
                     and ttMutation.iNumeroMandatAcheteur > 0:
                    vcCodeMutation = "MUTAG" + string(ttMutation.iNumeroContratMutation, "999999999").
                    run achatGerance (vcCodeMutation).
                end.
            end.
            when "3" then do:
/*gga todo
                /* Mutation de copro : Vente + achat en une étape */
                FOR EACH ttMutation
                    WHERE ttMutation.fgsel:
                    DO TRANS:   /* Ajout SY le 22/07/2011 */
                        RUN prepaliste01.
                        RUN venteGerance.
                        IF ttMutation.MdtAch > 0 THEN DO:
                            RUN achatGerance.
                        END.
                        ELSE DO:
                            /* maj contrat mutation  => définitif (fgprov) + date */
                            RUN validMutation ( INPUT ttMutation.cttmut , INPUT "Validation3" ).
                        END.
                    END.    /* TRANS */
                END.
gga*/
            end.
        end case.
    end.
    suppressionPgmPersistent(goCollectionHandlePgm).
    delete object goCollectionHandlePgm.

//gga todo a enlever apres test
output to c:\gga\listedebugmoder.txt .
run exportTable (2018, "01030").
run exportTable (1195, "01030").
run exportTable (119500301, "01033").
run exportTable (201800301, "01033").
run exportTable (201800300, "01033").
output close.
mError:createError({&error}, "annul trt pour test"). 
//gga todo enlever apres test

end procedure.

procedure ctrl private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viDernierMoisQtt as integer   no-undo.
    define variable vcLibelleAno     as character no-undo.
    define variable vcListeCopro     as character no-undo.

    define variable voCollectionQuit as class collection no-undo.

    define buffer ajquit     for ajquit.
    define buffer ccptcol    for ccptcol.
    define buffer ietab      for ietab.
    define buffer csscptcol  for csscptcol.
    define buffer cbap       for cbap.
    define buffer vbroles    for roles.
    define buffer cpreln     for cpreln.
    define buffer iftsai     for iftsai.
    define buffer ctrat      for ctrat.
    define buffer ifdparam   for ifdparam.
    define buffer ifdsai     for ifdsai.
    define buffer synge      for synge.
    define buffer compenslot for compenslot.

    /* Si étape 2 = achat gérance APRES mutation copropriété, le no acheteur et le no du copro actuel doivent être identiques (extrait mutger02.p/VerZonSai)*/
    giNbErreur = 0.
    if gcTypeValidation = "2" and glImmeubleCopro
    then do:
        for each ttMutation
           where ttMutation.CRUD = "U":
            vcListeCopro = "".
            for each ttListeLotMutation
               where ttListeLotMutation.iNumeroContratMutation = ttMutation.iNumeroContratMutation:
                if lookup(string(ttListeLotMutation.iNumeroCopro , "99999"), vcListeCopro) = 0
                then vcListeCopro = vcListeCopro + "," + string(ttListeLotMutation.iNumeroCopro , "99999").
            end.
            if vcListeCopro > "" then vcListeCopro = substring(vcListeCopro, 2, -1, 'character').
            if num-entries(vcListeCopro) > 1
            then do:
                mError:createError({&error}, 1000703, string(ttMutation.iNumeroMutation)).   //Mutation no &1 : Validation impossible. Les lots de la mutation appartiennent à plusieurs copropriétaires
                return.
            end.
            else if num-entries(vcListeCopro) = 1
            then do:
                if integer(vcListeCopro) <> ttMutation.iNumeroAcheteur
                then do:
                    if integer(vcListeCopro) = giMandant
                    then mError:createError({&error}, 1000704, string(ttMutation.iNumeroMutation)).  //Mutation no &1 : Validation impossible. Il faut d'abord effectuer la mutation en copropriété
                    else mError:createError({&error}, 1000705, string(ttMutation.iNumeroMutation)).  //Mutation no &1 : Validation impossible. Le copropriétaire actuel est différent de l'acheteur de la mutation de gérance
                    return.
                end.
            end.
        end.
    end.
    for first ajquit no-lock:
        mError:createError({&error}, 1000667, string(ajquit.dacompta, "99/99/9999")). //Validation Interdite. Vous ne pouvez pas valider une mutation de gérance tant que le quittancement en attente n'a pas été émis et intégré en comptabilité (Mois comptable: &1)
        return.
    end.
    ghProc = lancementPgm("adblib/transfert/suiviTransfert_CRUD.p", goCollectionHandlePgm).
    voCollectionQuit = new collection().
    voCollectionQuit:set("cCodeTraitement", "QUIT").
    run calculTransfertAppelExterne in ghProc(input-output voCollectionQuit).
    assign
        giGlMoiQtt = voCollectionQuit:getInteger("GlMoiQtt")
        giGlMoiMdf = voCollectionQuit:getInteger("GlMoiMdf")
        giGlMoiMEc = voCollectionQuit:getInteger("GlMoiMEc")
    .
    delete object voCollectionQuit.
    giRefGerance = integer(mToken:cRefGerance).
    vcLibelleAno = "REFERENCE : " + mToken:cRefGerance.
    mError:createListeErreur(vcLibelleAno).
    vcLibelleAno = "Date : " + string(today, "99/99/9999") + " - " + string(time,"HH:MM:SS").
    mError:createListeErreur(vcLibelleAno).
    for each ttMutation where ttMutation.CRUD = "U":
        vcLibelleAno = fill(" ",20) + "CONTROLES AVANT MUTATION DE GERANCE MANDAT " + string(ttMutation.iNumeroContrat)  .
        mError:createListeErreur(vcLibelleAno).
        if giGlMoiQtt <> giGlMoiMdf or giGlMoiQtt <> giGlMoiMec
        then do:
            vcLibelleAno = outilTraduction:getLibelle(1000668). //Vous ne pouvez pas valider une mutation de gérance entre 2 phases de quittancement
            mError:createListeErreur(vcLibelleAno).
            giNbErreur = giNbErreur + 1.
        end.
        /* pas d'acompte propriétaire en cours => pas de règlement en attente */
        for first ccptcol no-lock
            where ccptcol.soc-cd = integer(mToken:cRefPrincipale)
              and ccptcol.tprole = 16
        , first ietab no-lock
          where ietab.soc-cd = giRefGerance
            and ietab.profil-cd = 20
        , first csscptcol no-lock
          where csscptcol.soc-cd     = giRefGerance
            and csscptcol.etab-cd    = ietab.etab-cd
            and csscptcol.coll-cle   = ccptcol.coll-cle
            and csscptcol.facturable = true:
            for each cbap no-lock
               where cbap.soc-cd     = giRefGerance
                 and cbap.etab-cd    = ttMutation.iNumeroContrat
                 and cbap.coll-cle   = ccptcol.coll-cle
                 and cbap.sscoll-cle = csscptcol.sscoll-cle
                 and cbap.mt         > 0
                 and not cbap.fgval          /* 0714/0255 les cbap comptabilisés ne seront plus supprimés */
            , first vbroles no-lock
              where vbroles.norol = integer(cbap.cpt-cd)
                and (vbroles.tprol = {&TYPEROLE-mandant} or vbroles.tprol = {&TYPEROLE-coIndivisaire}):
                //Règlement propriétaire en attente : Compte no &1 - &2 du &3
                vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000669), substitute('&2&1&3&1&4', separ[1], cbap.cpt-cd, outilFormatage:getNomTiers(vbroles.tprol, vbroles.norol), cbap.daech)).
                mError:createListeErreur(vcLibelleAno).
                giNbErreur = giNbErreur + 1.
            end.
        end.
        /* NP 0716/0235 Add :On les supprime car ils n'ont pas lieu d'exister */
        empty temp-table ttCpreln.
        for each cpreln no-lock
           where cpreln.soc-cd   = giRefGerance
             and cpreln.etab-cd  = ttMutation.iNumeroContrat
             and cpreln.fg-valid = false
             and cpreln.daech    = ?:
            create ttCpreln.
            assign
                ttCpreln.soc-cd    = cpreln.soc-cd
                ttCpreln.fg-valid  = cpreln.fg-valid
                ttCpreln.mandat-cd = cpreln.mandat-cd
                ttCpreln.jou-cd    = cpreln.jou-cd
                ttCpreln.daech     = cpreln.daech
                ttCpreln.etab-cd   = cpreln.etab-cd
                ttCpreln.CRUD        = 'D'
                ttCpreln.dtTimestamp = datetime(cpreln.damod, cpreln.ihmod)
                ttCpreln.rRowid      = rowid(cpreln)
            .
        end.
        if can-find(first ttCpreln)
        then do:
            ghProc = lancementPgm("compta/cpreln_CRUD.p", goCollectionHandlePgm).
            run setCpreln in ghProc (table ttOfflc by-reference).
            if mError:erreur() then return.
        end.
        /* pas de prélèvements locataires en cours */
        for each cpreln no-lock
           where cpreln.soc-cd   = giRefGerance
             and cpreln.etab-cd  = ttMutation.iNumeroContrat
             and cpreln.fg-valid = false:
            //Prélèvement locataire non comptabilisé : &1 ( &2 type traitement &3 ) du &4)"
            vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000670), substitute('&2&1&3&1&4&1&5', separ[1], cpreln.cpt-cd, cpreln.sscoll-cle, cpreln.tp-trait, cpreln.daech)).
            mError:createListeErreur(vcLibelleAno).
            giNbErreur = giNbErreur + 1.
        end.
        /* pas de facture locataire non comptabilisées */
        for each iftsai no-lock
           where iftsai.soc-cd    = giRefGerance
             and iftsai.etab-cd   = ttMutation.iNumeroContrat
             and iftsai.fg-edifac = false
        , first ctrat no-lock
          where ctrat.tpcon = {&TYPECONTRAT-bail}
            and ctrat.nocon = integer(string(ttMutation.iNumeroContrat,"99999") + iftsai.sscptg-cd):
            //Facture locataire non comptabilisée : &1 - &2 ( &3 ) du &4".
            vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000671), substitute('&2&1&3&1&4&1&5', separ[1], ctrat.nocon, ctrat.lbnom, iftsai.typefac-cle, iftsai.dafac)).
            mError:createListeErreur(vcLibelleAno).
            giNbErreur = giNbErreur + 1.
        end.
        /* Ajout Sy le 23/05/2011 : Controle facture honoraires locataire typefac-cle = "41" */
        for first ifdparam no-lock
            where ifdparam.soc-dest = giRefGerance:
            for each ifdsai no-lock
               where ifdsai.soc-cd      = ifdparam.soc-cd
                 and ifdsai.etab-cd     = ifdparam.etab-cd
                 and ifdsai.soc-dest    = ifdparam.soc-dest
                 and ifdsai.etab-dest   = ttMutation.iNumeroContrat
                 and ifdsai.typefac-cle = "41"
                 and ifdsai.dacpta = ?
            , first ctrat no-lock
              where ctrat.tpcon = {&TYPECONTRAT-bail}
                 and ctrat.nocon = integer(string(ttMutation.iNumeroContrat,"99999") + ifdsai.cpt-cd):
                //Facture Honoraire non comptabilisée : &1 (&2) Locataire : &3 " - " + &4 créée le &5
                vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000672), substitute('&2&1&3&1&4&1&5&1&6', separ[1], ifdsai.lib-ecr[1], ifdsai.typefac-cle, ctrat.nocon, ctrat.lbnom, ifdsai.dacrea)).
                mError:createListeErreur(vcLibelleAno).
                giNbErreur = giNbErreur + 1.
            end.
        end.
        /* si compensation sur le mandat : pas de traitement copro en cours sur le(s) mandat(s) de syndic compensé(s) */
        for each synge no-lock
           where synge.tpctp = {&TYPECONTRAT-mandat2Syndic}
             and synge.tpct1 = {&TYPECONTRAT-titre2copro}
             and synge.tpct2 = {&TYPECONTRAT-mandat2Gerance}
             and synge.noct2 = ttMutation.iNumeroContrat
        , first ctrat no-lock
          where ctrat.tpcon = synge.tpctp
            and ctrat.nocon = synge.noctp
            and ctrat.dtree = ?:
            run controleTrfMdtSyn (synge.noctp, input-output giNbErreur).
        end.
        /* SY 1214/0052 Compensation par lot */
        for each compenslot no-lock
           where compenslot.tpctp = {&TYPECONTRAT-mandat2Syndic}
             and compenslot.tpct1 = {&TYPECONTRAT-titre2copro}
             and compenslot.tpct2 = {&TYPECONTRAT-mandat2Gerance}
             and compenslot.noct2 = ttMutation.iNumeroContrat
             and compenslot.dtfin = ?
        , first ctrat no-lock
          where ctrat.tpcon = compenslot.tpctp
            and ctrat.nocon = compenslot.noctp
            and ctrat.dtree = ?:
            run controleTrfMdtSyn (compenslot.noctp, input-output giNbErreur).
        end.

/* gga todo pour l instant gcMotifValidation pas gere
        /* si mutation pour résiliation mandat, il ne doit plus y avoir de quittancement à comptabiliser pour le mandat vendeur */
        if gcTypeValidation = "1" and gcMotifValidationN = "RESIL" then do:
            for each ttMutation
                where ttMutation.fgsel:
                run prepaliste01.

                for each detail no-lock
                    where detail.cddet = "MUTAG" + string( ttMutation.iNumeroContratMutation , "999999999" )
                    /* no bail en cours */
                    and detail.tbdec[2] <> 0
                    and detail.tbdec[2] <> ?
                    ,first local no-lock
                    where local.noimm = detail.nodet
                    and local.nolot = detail.iddet
                    break by cddet by ixd02 by nodet by iddet :
                    if last-of ( detail.ixd02 ) then do:
                        DerMsQtt = integer(detail.tbchr[1]).
                        if DerMsQtt <> 0 and DerMsQtt >= giGlMoiMdf then do:
                            //Mutation no &1 du &2 : le locataire &3 doit encore etre quittancé pour le mandat à résilier jusqu'au quittancement de &4/&5. Validation de la mutation impossible avant
                            vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000673), substitute('&2&1&3&1&4', separ[1], ttMutation.nomut, dtachnot, detail.tbdec[2], SUBstring( detail.tbchr[1] , 5 ),SUBstring( detail.tbchr[1] , 1 , 4) )).
                            mError:createListeErreur(vcLibelleAno).
                            giNbErreur = giNbErreur + 1.
                            FgCtrl-OK = false.
                        end.
                    end.
                end.
            end.
        end.
*/

    end.
    if giNbErreur >= 1
    then mError:createError({&error}, 1000706, string(giNbErreur)).             //Validation impossible il y a &1 controle(s) bloquant(s)

end procedure.

procedure controleTrfMdtSyn private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroContrat  as integer no-undo.
    define input-output parameter piNbErreur       as integer no-undo.

    define variable vcLibelleAno as character no-undo.

    define buffer trfpm for trfpm.

    for each trfpm no-lock
       where trfpm.tptrf = "CC"
         and trfpm.nomdt = piNumeroContrat
         and (trfpm.ettrt = "00002" or trfpm.ettrt = "00012"):
        //Compensation/Traitement Charges de copropriété en attente d'intégration : Mandat de syndic &1 Exercice &2 du &3"
        vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000674), substitute('&2&1&3&1&4', separ[1], piNumeroContrat, trfpm.dtapp)).
        mError:createListeErreur(vcLibelleAno).
        giNbErreur = giNbErreur + 1.
    end.
    for each trfpm no-lock
       where trfpm.tptrf = "AP"
         and trfpm.nomdt = piNumeroContrat
         and (trfpm.ettrt = "00002" or trfpm.ettrt = "00012"):
        case trfpm.tpapp:
            //Compensation/Traitement Appels de fond budget en attente d'intégration : Mandat de syndic &1 Exercice &2 Appel no &3 du &4"
            when "BU"  then vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000675), substitute('&2&1&3&1&4&1&5', separ[1], trfpm.nomdt, trfpm.noexe, string(trfpm.noapp, "99"), trfpm.dtapp)).
            //Compensation/Traitement Appels de fond hors-budget en attente d'intégration : Mandat de syndic &1 Appel no &2 du &3"
            when "HB"  then vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000676), substitute('&2&1&3&1&4', separ[1], trfpm.nomdt, string(trfpm.noapp, "99"), trfpm.dtapp)).
            //Compensation/Traitement Appels de fond travaux en attente d'intégration : Mandat de syndic &1 Appel no &2 du &3"
            when "TR"  then vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000677), substitute('&2&1&3&1&4', separ[1], trfpm.nomdt, string(trfpm.noapp, "99"), trfpm.dtapp)).
            //Compensation/Traitement Cloture dossiers travaux en attente d'intégration : Mandat de syndic &1 Dossier &2"
            when "CX"  then vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000678), substitute('&2&1&3', separ[1], trfpm.nomdt, trfpm.noexe)).
            //Compensation/Traitement Appels de fond dossiers travaux en attente d'intégration : Mandat de syndic &1 Dossier &2 Appel no &3 du &4"
            when "TX"  then vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000679), substitute('&2&1&3&1&4&1&5', separ[1], trfpm.nomdt, trfpm.noexe, string(trfpm.noapp, "99"), trfpm.dtapp)).
            //Compensation/Traitement Appels de fond de roulement en attente d'intégration : Mandat de syndic &1 Appel no &2 du &3"
            when "FRO" then vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000680), substitute('&2&1&3&1&4', separ[1], trfpm.nomdt, string(trfpm.noapp, "99"), trfpm.dtapp)).
            //Compensation/Traitement Appels de fond de réserve en attente d'intégration : Mandat de syndic &1 Appel no &2 du &3"
            when "FRE" then vcLibelleAno = outilFormatage:fSubst(outilTraduction:getLibelle(1000681), substitute('&2&1&3&1&4', separ[1], trfpm.nomdt, string(trfpm.noapp, "99"), trfpm.dtapp)).
        end case.
        mError:createListeErreur(vcLibelleAno).
        giNbErreur = giNbErreur + 1.
    end.

end procedure.

procedure prepaListe01 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcCodeMutation as character no-undo.

    define variable vdaVente         as date    no-undo.
    define variable viDernierMoisQtt as integer no-undo.

    define buffer detail for detail.
    define buffer ctrat  for ctrat.
    define buffer tache  for tache.

    vdaVente = ttMutation.daAchat - 1.
    empty temp-table ttDetail.
    run exportMUTAG ("svg", pcCodeMutation).
    if mError:erreur() then return.
    for each detail no-lock
       where detail.cddet = pcCodeMutation:
        create ttDetail.
        assign
            ttDetail.cddet       = detail.cddet
            ttDetail.nodet       = detail.nodet
            ttDetail.iddet       = detail.iddet
            ttDetail.ixd01       = detail.ixd01
            ttDetail.CRUD        = 'D'
            ttDetail.dtTimestamp = datetime(detail.dtmsy, detail.hemsy)
            ttDetail.rRowid      = rowid(detail)
        .
    end.
    for each ttListeLotMutation
       where ttListeLotMutation.iNumeroContratMutation = ttMutation.iNumeroContratMutation:
        create ttDetail.
        assign
            ttDetail.CRUD     = "C"
            ttDetail.cddet    = pcCodeMutation
            ttDetail.nodet    = giNumeroImmeuble
            ttDetail.iddet    = ttListeLotMutation.iNumeroLot
            ttDetail.ixd01    = string(year(vdaVente), "9999") + string(month(vdaVente), "99") + string(day(vdaVente), "99") /* date de vente */
            ttDetail.ixd02    = string(ttListeLotMutation.iNumeroUL, "999")                                                   /* UL */
            ttDetail.ixd03    = string(ttListeLotMutation.iNumeroClassement, "9999")                                          /* rang du lot dans l'UL */
            ttDetail.tbdec[1] = (if ttListeLotMutation.lDivisible = true then ttListeLotMutation.dSurface else 0)             /* surface lot divisible */
            ttDetail.tbdat[1] = ttMutation.daAchat                                                                            /* date d'achat */
            ttDetail.tbdec[2] = 0                                                                                             /* dernier bail */
            ttDetail.tbdat[3] = ?
            ttDetail.tbint[1] = ttMutation.iNumeroMandatAcheteur                                                              /* nouveau no mandat */
            /* futures zones : initialiser sinon zones invalides (?) */
            ttDetail.tbint[2] = 0                                                                                             /* nouveau no UL */
            ttDetail.tbint[3] = 0                                                                                             /* mois 1er quit pour nouveau mandat */
            ttDetail.tbdec[3] = 0                                                                                             /* nouveau no bail */
            ttDetail.tbdat[2] = ?                                                                                             /* date de résiliation calculée pour le bail */
            ttDetail.tbchr[1] = ""                                                                                            /* dernier mois de quit ancien bail */
            ttDetail.tblog[1] = no                                                                                            /* vente effectuée yes/no */
            ttDetail.tblog[2] = no                                                                                            /* mutation effectuée yes/no */
        .
        for last ctrat no-lock
           where ctrat.tpcon = {&TYPECONTRAT-bail}
             and ctrat.nocon >= integer(string(ttMutation.iNumeroContrat, "99999") + string(ttListeLotMutation.iNumeroUL, "999") + "01")
             and ctrat.nocon <= integer(string(ttMutation.iNumeroContrat, "99999") + string(ttListeLotMutation.iNumeroUL, "999") + "99")
             and (ctrat.dtree = ? or (ctrat.dtree <> ? and ctrat.dtree >= ttMutation.daAchat)):
            ttDetail.tbdec[2] = ctrat.nocon.
            for last tache no-lock
               where tache.tpcon = ctrat.tpcon
                 and tache.nocon = ctrat.nocon
                 and tache.tptac = {&TYPETACHE-quittancement}:
                ttDetail.tbdat[3] = tache.dtfin.    /* Ajout SY le 31/01/2011 : date de sortie ancien locataire */
            end.
        end.
        /* recherche de la date de résiliation selon date d'achat notaire */
        viDernierMoisQtt = 0.
        run calDateResilBail (ttDetail.tbdec[2], ttDetail.tbdat[1], output ttDetail.tbdat[2], output viDernierMoisQtt).
        if viDernierMoisQtt <> 0 then ttDetail.tbchr[1] = string(viDernierMoisQtt, "999999").
    end.
    if can-find(first ttDetail)
    then do:
        ghProc = lancementPgm("adblib/detail_CRUD.p", goCollectionHandlePgm).
        run setDetail in ghProc (table ttDetail by-reference).
        if mError:erreur() then return.
    end.
    run exportMUTAG ("", pcCodeMutation).

end procedure.

procedure exportMUTAG private:
    /*------------------------------------------------------------------------------
    Purpose:  Ajout SY le 22/07/2011 : export table detail avant suppression et apres creation pour reprise manuelle sur plantage
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeExport   as character no-undo.
    define input parameter pcCodeMutation as character no-undo.

    define variable vcRefFichier as character no-undo.
    define variable vcRepFichier as character no-undo init "d:\gidev\adb\tmp\".            //gga todo voir comment gerer nom de fichier

    define buffer detail for detail.

    if can-find (first detail no-lock
                 where detail.cddet = pcCodeMutation)
    then do:
        vcRefFichier = substitute("&1MutationGerance&2-&3-&4&5-&6&7.d", vcRepFichier,
                                                                        string(mToken:cRefGerance,"99999"),
                                                                        pcCodeMutation,
                                                                        string(month(today), "99"),
                                                                        string(day(today), "99"),
                                                                        string(time),
                                                                        pcTypeExport).
        output to value(vcRefFichier).
        for each detail no-lock
           where detail.cddet = pcCodeMutation:
            export detail.
        end.
        output close.
    end.

end procedure.

procedure calDateResilBail private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de calcul de la date de résiliation du bail
             à la fin du terme contenant la date d'achat
              + renvoi du mois du 1er quit acheteur
              Fiche 0511/0138 :
              Modification pour les ECHUS
              Si la quittance contenant la date d'achat a un mois de traitement de quittancement < Mois Quitt en cours alors OK
              sinon date de résiliation = date de fin de la quittance précédente
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter  piNumeroBail     as integer no-undo.
    define input parameter  pdaAchat         as date    no-undo.
    define output parameter pdaResiliation   as date    no-undo.
    define output parameter piDernierMoisQtt as integer no-undo.

    define variable vlQuitTrouve              as logical   no-undo.
    define variable vlQuitPrecTrouve          as logical   no-undo.
    define variable viMoisQttFin              as integer   no-undo.
    define variable vdaDebPerQtt              as date      no-undo.
    define variable vdaFinPerQtt              as date      no-undo.
    define variable vcAvanceEchue             as character no-undo init "00001".
    define variable vcNomLocataire            as character no-undo.
    define variable vdaFinApplicationRubrique as date      no-undo.
    define variable vlTaciteReconduction      as logical   no-undo.
    define variable vdaSortieLocataire        as date      no-undo.
    define variable vdaResiliationBail        as date      no-undo.
    define variable vdaFinBail                as date      no-undo.
    define variable vlPrendre                 as logical   no-undo.

    define buffer ctrat for ctrat.
    define buffer tache for tache.
    define buffer aquit for aquit.
    define buffer equit for equit.

    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-bail}
          and ctrat.nocon = piNumeroBail:
        vcNomLocataire = ctrat.lbnom.
    end.

    /* Init Date de sortie et résiliation du bail */
    run filtreLoc(pdaAchat, piNumeroBail, output vlTaciteReconduction, output vdaFinBail, output vdaSortieLocataire, output vdaResiliationBail, output vlPrendre, output vdaFinApplicationRubrique).

    for last tache no-lock
       where tache.tpcon = {&TYPECONTRAT-bail}
         and tache.nocon = piNumeroBail
         and tache.tptac = {&TYPETACHE-quittancement}:
        vcAvanceEchue = tache.ntges.
        mLogger:writeLog(0, "calDateResilBail - tache : " + tache.tpcon + "-" + string(tache.nocon)  + " " + vcNomLocataire + " : "  + tache.tptac + " Entrée le " + (if tache.dtdeb <> ? then string(tache.dtdeb) else "") + " Sortie le " + (if tache.dtfin <> ? then string(tache.dtfin) else "")).
    end.

    /* Cas ou les (vraies) quittances existent (=> dates début fin fiables) */
    for each aquit no-lock
       where aquit.noloc = piNumeroBail
         and aquit.fgfac = no
         and aquit.dtdpr <= pdaAchat
         and aquit.dtfpr >= pdaAchat:
        assign
            vlQuitTrouve = yes
            viMoisQttFin = aquit.msqtt
            vdaFinPerQtt = aquit.dtfpr
        .
        leave.
    end.
    if not vlQuitTrouve
    then do:
        for each equit no-lock
           where equit.noloc = piNumeroBail
             and equit.dtdpr <= pdaAchat
             and equit.dtfpr >= pdaAchat:
            run filtreLoc(equit.dtdpr, piNumeroBail, output vlTaciteReconduction, output vdaFinBail, output vdaSortieLocataire, output vdaResiliationBail, output vlPrendre, output vdaFinApplicationRubrique).
            if vlPrendre
            then do:
                assign
                    vlQuitTrouve = yes
                    viMoisQttFin = equit.msqtt
                    vdaDebPerQtt = equit.dtdpr
                    vdaFinPerQtt = equit.dtfpr
                .
                leave.
            end.
        end.
        if vlQuitTrouve and vcAvanceEchue = "00002" and viMoisQttFin >= giGlMoiMdf
        then do:
            /* Quittance future => prendre la précédente */
            mLogger:writeLog(0, "calDateResilBail - Locataire ECHU " + string(piNumeroBail) + " Quitt trouvé pour date achat " + string(pdaAchat) + " " + string(viMoisQttFin) + " =>  Date résiliation = " + (if vdaFinPerQtt <> ? then string(vdaFinPerQtt) else "???") + " : non traité => prendre quitt précédent " ).
            vlQuitPrecTrouve = no.
            vdaFinPerQtt = vdaDebPerQtt - 1.    /* date de résiliation */
            /* recherche dernier mois de quitt associé à la date de résiliation */
            viMoisQttFin = 0.
            for each aquit no-lock
               where aquit.noloc = piNumeroBail
                 and aquit.fgfac = no
                 and aquit.dtdpr <= vdaFinPerQtt
                 and aquit.dtfpr >= vdaFinPerQtt:
                assign
                    vlQuitPrecTrouve = yes
                    viMoisQttFin     = aquit.msqtt
                .
                leave.
            end.
            if not vlQuitPrecTrouve
            then do:
                for each equit no-lock
                   where equit.noloc = piNumeroBail
                     and equit.dtdpr <= vdaFinPerQtt
                     and equit.dtfpr >= vdaFinPerQtt:
                    viMoisQttFin = equit.msqtt.
                    leave.
                end.
            end.
        end.    /* spécial ECHUS */
    end.

    if vlQuitTrouve
    then do:
        if vdaFinApplicationRubrique <> ? and vdaFinApplicationRubrique <= vdaFinPerQtt
        then pdaResiliation = vdaFinApplicationRubrique.                        /* Locataire déjà sorti ou résilié */
        else pdaResiliation = vdaFinPerQtt.
        piDernierMoisQtt = viMoisQttFin.
        mLogger:writeLog(0, "calDateResilBail - Locataire " + string(piNumeroBail) + " Quitt trouvé pour date achat " + string(pdaAchat) + " " + string(viMoisQttFin) + " =>  Date résiliation = " + (if pdaResiliation <> ? then string(pdaResiliation) else "???") ).
    end.
    else do:
        pdaResiliation = pdaAchat - 1.
        mLogger:writeLog(0, "calDateResilBail - Locataire " + string(piNumeroBail) + " Pas de Quitt pour date achat " + string(pdaAchat) + " =>  Date résiliation = " +  (if pdaResiliation <> ? then string(pdaResiliation) else "???") ).
    end.

end procedure.

procedure venteGerance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcCodeMutation as character no-undo.

    define buffer detail   for detail.
    define buffer vbdetail for detail.
    define buffer local    for local.
    define buffer intnt    for intnt.
    define buffer ctrat    for ctrat.

    for each detail no-lock
       where detail.cddet = pcCodeMutation
    , first local no-lock
      where local.noimm = detail.nodet
        and local.nolot = detail.iddet
    break by detail.cddet by detail.ixd02 by detail.nodet by detail.iddet:

        mLogger:writeLog(0, "venteGerance - detail " + detail.cddet + " : UL = " + detail.ixd02 + " lot = " + string(local.nolot)).
        /* supprimer le lot de la composition 998 ou vider UL */
        run PrcFinUl (ttMutation.iNumeroContrat, integer(detail.ixd02), local.noimm, local.nolot, detail.tbdat[1] - 1).

        /* retirer le lot du mandat */
        empty temp-table ttintnt.
        for each intnt no-lock
           where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
             and intnt.nocon = ttMutation.iNumeroContrat
             and intnt.tpidt = {&TYPEBIEN-lot}
             and intnt.noidt = local.noloc:
            create ttintnt.
            assign
                ttintnt.tpcon       = intnt.tpcon
                ttintnt.nocon       = intnt.nocon
                ttintnt.tpidt       = intnt.tpidt
                ttintnt.noidt       = intnt.noidt
                ttintnt.nbnum       = intnt.nbnum
                ttintnt.idpre       = intnt.idpre
                ttintnt.idsui       = intnt.idsui
                ttintnt.CRUD        = "D"
                ttintnt.rRowid      = rowid(intnt)
                ttintnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
            .
        end.
        if can-find(first ttIntnt)
        then do:
            ghProc = lancementPgm("adblib/intnt_CRUD.p", goCollectionHandlePgm).
            run setIntnt in ghProc (table ttIntnt by-reference).
            if mError:erreur() then return.
        end.

        if last-of (detail.ixd02)
        then do:
            /* résilier le bail en cours si date de résiliation calculée */
            if detail.tbdec[2] <> 0 and detail.tbdec[2] <> ? and detail.tbdat[2] <> ?
            then do:
                run ResilBail (detail.cddet, detail.tbdec[2], detail.tbdat[2]).
                if mError:erreur() then return.
            end.
            /* Maj infos dans table de suivi (detail) pour tous les lots de l'UL */
            empty temp-table ttDetail.
            for each vbdetail
               where vbdetail.cddet = detail.cddet
                 and vbdetail.nodet = detail.nodet
                 and vbdetail.ixd01 = detail.ixd01
                 and vbdetail.ixd02 = detail.ixd02:
                create ttDetail.
                assign
                    ttDetail.cddet       = vbdetail.cddet
                    ttDetail.nodet       = vbdetail.nodet
                    ttDetail.iddet       = vbdetail.iddet
                    ttDetail.ixd01       = vbdetail.ixd01
                    ttDetail.CRUD        = 'U'
                    ttDetail.dtTimestamp = datetime(vbdetail.dtmsy, vbdetail.hemsy)
                    ttDetail.rRowid      = rowid(vbdetail)
                    ttDetail.tblog[1]    = yes                             /* vente effectuée */
                .
            end.
            if can-find(first ttDetail)
            then do:
                ghProc = lancementPgm("adblib/detail_CRUD.p", goCollectionHandlePgm).
                run setDetail in ghProc (table ttDetail by-reference).
                if mError:erreur() then return.
            end.
        end.
    end.

    /* maj contrat mutation  => date traitement résiliation */
    empty temp-table ttCtrat.
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mutationGerance}
          and ctrat.nocon = ttMutation.iNumeroContratMutation:
        create ttCtrat.
        assign
            ttCtrat.tpcon       = ctrat.tpcon
            ttCtrat.nocon       = ctrat.nocon
            ttCtrat.CRUD        = "U"
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttCtrat.rRowid      = rowid(ctrat)
            ttCtrat.dtarc       = today
            ttCtrat.cdmsy       = mtoken:cUser + "@" + "mutger02.p" + "@" + "venteGerance"
        .
        ghProc = lancementPgm("adblib/ctrat_CRUD.p", goCollectionHandlePgm).
        run setCtrat in ghProc (table ttCtrat by-reference).
    end.

end procedure.

procedure ResilBail private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de résiliation du bail à la fin du terme contenant la date d'achat
             + renvoi du mois du 1er quit acheteur
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcCodeMutation as character no-undo.
    define input parameter piNumeroBail   as integer   no-undo.
    define input parameter pdaResiliation as date      no-undo.

    define buffer ctrat for ctrat.
    define buffer cthis for cthis.
    define buffer tache for tache.

    empty temp-table ttCthis.
    empty temp-table ttTache.
    empty temp-table ttCtrat.
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-bail}
          and ctrat.nocon = piNumeroBail:
        create ttCthis.
        outils:copyValidField(buffer ctrat:handle, buffer ttCthis:handle).
        assign
            ttCthis.CRUD  = "C"
            ttCthis.nodoc = 0
            ttCthis.cddev = pcCodeMutation
            ttCthis.cdcsy = mtoken:cUser + "@" + "mutger02.p"
        .
        ghProc = lancementPgm("adblib/cthis_CRUD.p", goCollectionHandlePgm).
        run setCthis in ghProc (table ttCthis by-reference).
        if mError:erreur() then return.
        for last tache no-lock
           where tache.tpcon = {&TYPECONTRAT-bail}
             and tache.nocon = piNumeroBail
             and tache.tptac = {&TYPETACHE-quittancement}:
            create ttTache.
            assign
                ttTache.tpcon       = tache.tpcon
                ttTache.nocon       = tache.nocon
                ttTache.tptac       = tache.tptac
                ttTache.notac       = tache.notac
                ttTache.CRUD        = "U"
                ttTache.dtTimestamp = datetime(tache.dtmsy, tache.hemsy)
                ttTache.rRowid      = rowid(tache)
                ttTache.dtfin       = (if tache.dtfin <> ? then tache.dtfin else pdaResiliation)
            .
            ghProc = lancementPgm("tache/tache.p", goCollectionHandlePgm).
            run setTache in ghProc (table ttTache by-reference).
            if mError:erreur() then return.
        end.
        create ttCtrat.
        assign
            ttCtrat.tpcon       = ctrat.tpcon
            ttCtrat.nocon       = ctrat.nocon
            ttCtrat.CRUD        = "U"
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttCtrat.rRowid      = rowid(ctrat)
            ttCtrat.tpfin       = "00002"      /* motif = pour la vente du logement */
            ttCtrat.dtree       = pdaResiliation
        .
        ghProc = lancementPgm("adblib/ctrat_CRUD.p", goCollectionHandlePgm).
        run setCtrat in ghProc (table ttCtrat by-reference).
    end.

end procedure.

procedure achatGerance private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcCodeMutation as character no-undo.

    define variable viNouveauNumeroUl    as integer   no-undo.
    define variable MsQttAch    as integer   no-undo.
    define variable NoBaiCre    as integer   no-undo.
    define variable NoBaiCre1   as integer   no-undo.
    define variable MsQttAch1   as integer   no-undo.
    define variable NoRangUse   as integer   no-undo.

    define buffer vbCtratGerance for ctrat.
    define buffer detail   for detail.
    define buffer local    for local.
    define buffer vbdetail for detail.

    find first vbCtratGerance no-lock
         where vbCtratGerance.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and vbCtratGerance.nocon = ttMutation.iNumeroMandatAcheteur no-error.
    if not available vbCtratGerance
    then do:
        mError:createError({&error}, 1000707, substitute("&2&1&3", separ[1], ttMutation.iNumeroContratMutation, ttMutation.iNumeroMandatAcheteur)).  //Mutation &1 : Mandat de l'acheteur non trouvé (mandat no &2)
        return.
    end.

    for each detail no-lock
       where detail.cddet = pcCodeMutation
    , first local no-lock
      where local.noimm = detail.nodet
        and local.nolot = detail.iddet
    break by detail.cddet by detail.ixd02 by detail.ixd03 by detail.nodet by detail.iddet:
        mLogger:writeLog(0, "achatGerance - detail : UL = " + detail.ixd02 + " lot = " + string(local.nolot) + " Date achat = " + string(detail.tbdat[1])).
        if first-of (detail.ixd02)
        then do:
            /* Nouvelle UL */
            run PrcNewUl (ttMutation.iNumeroContrat,
                          integer(detail.ixd02),
                          local.nolot,
                          vbCtratGerance.norol,
                          ttMutation.iNumeroMandatAcheteur,
                          detail.tbdat[1],
                          output viNouveauNumeroUl).
            if mError:erreur() then return.
            /* Ajout SY le 22/07/2011 : RAZ infos bail */
            NoBaiCre1 = 0.
        end.

        /* rattacher le lot au nouveau mandat */
        if not can-find (first intnt no-lock
                         where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                           and intnt.nocon = ttMutation.iNumeroMandatAcheteur
                           and intnt.tpidt = {&TYPEBIEN-lot}
                           and intnt.noidt = local.noloc)
        then do:
            empty temp-table ttintnt.
            create ttintnt.
            assign
                ttintnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
                ttintnt.nocon = ttMutation.iNumeroMandatAcheteur
                ttintnt.tpidt = {&TYPEBIEN-lot}
                ttintnt.noidt = local.noloc
                ttintnt.idpre = 0
                ttintnt.CRUD  = "C"
            .
            ghProc = lancementPgm("adblib/intnt_CRUD.p", goCollectionHandlePgm).
            run setIntnt in ghProc (table ttIntnt by-reference).
            if mError:erreur() then return.
        end.

        /* rattacher le lot à la nouvelle UL */
        empty temp-table ttDetail.
        create ttDetail.
        assign
            ttDetail.cddet       = detail.cddet
            ttDetail.nodet       = detail.nodet
            ttDetail.iddet       = detail.iddet
            ttDetail.ixd01       = detail.ixd01
            ttDetail.CRUD        = 'U'
            ttDetail.dtTimestamp = datetime(detail.dtmsy, detail.hemsy)
            ttDetail.rRowid      = rowid(detail)
            ttDetail.tbint[2]    = viNouveauNumeroUl.
        .
        ghProc = lancementPgm("adblib/detail_CRUD.p", goCollectionHandlePgm).
        run setDetail in ghProc (table ttDetail by-reference).
        if mError:erreur() then return.

        if viNouveauNumeroUl <> 0
        then do:
            empty temp-table ttCpuni.
            create ttCpuni.
            assign
                ttCpuni.nomdt       = ttMutation.iNumeroMandatAcheteur
                ttCpuni.noimm       = local.noimm
                ttCpuni.nolot       = local.nolot
                ttCpuni.noapp       = viNouveauNumeroUl
                ttCpuni.nocmp       = 10
                ttCpuni.noord       = integer(detail.ixd03)
                ttCpuni.noman       = vbCtratGerance.norol
                ttCpuni.cdori       = ""
                ttCpuni.sflot       = detail.tbdec[1]
                ttCpuni.CRUD        = 'C'
            .
            ghProc = lancementPgm("immeubleEtLot/cpuni_CRUD.p", goCollectionHandlePgm).
            run setCpuni in ghProc (table ttCpuni by-reference).
            if mError:erreur() then return.
        end.
    end.

    if vbCtratGerance.fgprov
    then do:
        run creationUL998 (buffer vbCtratGerance).
        if mError:erreur() then return.
        run ValidMandat (buffer vbCtratGerance, pcCodeMutation).
        if mError:erreur() then return.
    end.

    for each detail no-lock
       where detail.cddet = pcCodeMutation
    , first local no-lock
      where local.noimm = detail.nodet
        and local.nolot = detail.iddet
    break by detail.cddet by detail.ixd02 by detail.ixd03 by detail.nodet by detail.iddet:

        if last-of (detail.ixd02)
        then do:
            assign
                NoBaiCre = 0
                MsQttAch = 0
                .
            if detail.tbdec[2] <> 0
            then do:
                /* Dupliquer l'ancien bail (ou les anciens baux ?) */
                /* NB : si plusieurs baux, pb stockage infos date résiliation, mois dernier quitt...*/
                NoRangUse = 01.
                for each ctctt no-lock
                   where ctctt.tpct1 = {&TYPECONTRAT-mandat2Gerance}
                     and ctctt.noct1 = ttMutation.iNumeroContrat
                     and ctctt.tpct2 = {&TYPECONTRAT-bail}
                     and ctctt.noct2 >= integer(detail.tbdec[2])
                     and ctctt.noct2 <= integer(string(ttMutation.iNumeroContrat, "99999") + string(integer(detail.ixd02), "999") + "99"):
                    /* Nouveau no bail */
                    NoBaiCre = integer( string( ttMutation.iNumeroMandatAcheteur , "99999") + string(viNouveauNumeroUl , "999") + string(NoRangUse , "99") ).
                    run DupliBail (ttMutation.iNumeroContratMutation,
                                   local.noimm,
                                   ctctt.noct2,
                                   detail.tbdat[1],
                                   integer(detail.tbchr[1]),
                                   detail.tbdat[2],
                                   ttMutation.iNumeroMandatAcheteur,
                                   viNouveauNumeroUl,
                                   input-output NoBaiCre,
                                   input-output MsQttAch).
                    if NoBaiCre1 = 0
                    then assign
                             NoBaiCre1 = NoBaiCre
                             MsQttAch1 = MsQttAch
                    .
                    NoRangUse = NoRangUse + 1.
                end.
            end.
            /* Maj infos dans table de suivi (detail) pour tous les lots de l'UL */
            empty temp-table ttDetail.
            for each vbdetail
                where vbdetail.cddet = detail.cddet
                  and vbdetail.nodet = detail.nodet
                  and vbdetail.ixd01 = detail.ixd01
                  and vbdetail.ixd02 = detail.ixd02:
                create ttDetail.
                assign
                    ttDetail.cddet       = vbdetail.cddet
                    ttDetail.nodet       = vbdetail.nodet
                    ttDetail.iddet       = vbdetail.iddet
                    ttDetail.ixd01       = vbdetail.ixd01
                    ttDetail.CRUD        = 'U'
                    ttDetail.dtTimestamp = datetime(vbdetail.dtmsy, vbdetail.hemsy)
                    ttDetail.rRowid      = rowid(vbdetail)
                    ttDetail.tblog[2]    = yes             /* mutation effectuée */
                    ttDetail.tbdec[3]    = NoBaiCre1
                    ttDetail.tbint[3]    = MsQttAch1
                .
            end.
            if can-find(first ttDetail)
            then do:
                ghProc = lancementPgm("adblib/detail_CRUD.p", goCollectionHandlePgm).
                run setDetail in ghProc (table ttDetail by-reference).
                if mError:erreur() then return.
            end.
        end.
    end.

    /* Ajout Sy le 02/03/2011 : regénération des entêtes de clé à partir des millièmes des lots et des clés de l'ancien mandat */
    run majTotCle (ttMutation.iNumeroMandatAcheteur, ttMutation.iNumeroContrat).
    if mError:erreur() then return.

    /* maj contrat mutation  => définitif (fgprov) + date */
    run validMutation (ttMutation.iNumeroContratMutation, "AchatGerance").

end procedure.

procedure ValidMandat private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de validation d'un mandat provisoire + majmdt compta + maj no registre si REGIS = AUTO)
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer vbCtratGerance for ctrat.
    define input parameter pcCodeMutation as character no-undo.

    mLogger:writeLog(0, "ValEnrPec : " + {&TYPECONTRAT-mandat2Gerance} + " no " + string(vbCtratGerance.nocon)).
    ghProc = lancementPgm("mandat/mandat.p", goCollectionHandlePgm).
    run validationMandat in ghProc ({&TYPECONTRAT-mandat2Gerance}, vbCtratGerance.nocon).

end procedure.

procedure creationUL998 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer vbCtratGerance for ctrat.

    if not can-find(first unite no-lock
                    where unite.nomdt = vbCtratGerance.nocon
                      and unite.noapp = 998)
    then do:
        empty temp-table ttunite.
        create ttunite.
        assign
            ttunite.CRUD  = "C"
            ttunite.noman = vbCtratGerance.norol
            ttunite.nomdt = vbCtratGerance.nocon
            ttunite.noapp = 998
            ttunite.noact = 0
            ttunite.nocmp = 10
            ttunite.cdcmp = "00004"
            ttunite.dtdeb = vbCtratGerance.dtini
            ttunite.noimm = giNumeroImmeuble
            ttunite.cdocc = "00002"
            ttunite.norol = 0
        .
        ghProc = lancementPgm("adblib/unite_CRUD.p", goCollectionHandlePgm).
        run setUnite in ghProc (table ttUnite by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure PrcNewUl private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de validation d'un mandat provisoire + majmdt compta + création UL 998 +  maj no registre si REGIS = AUTO)
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratMutation as int64   no-undo.
    define input parameter piNumeroUl              as integer no-undo.
    define input parameter piNumeroLot             as integer no-undo.
    define input parameter piNoRole                as integer no-undo.
    define input parameter piNumeroMandatAcheteur  as integer no-undo.
    define input parameter pdaAchat                as date    no-undo.
    define output parameter piNouveauNumeroUl      as integer no-undo.

    define variable voparametrageChargeLocative as class parametrageChargeLocative no-undo.

    define buffer unite   for unite.
    define buffer vbunite for unite.
    define buffer offlc   for offlc.
    define buffer vbofflc for offlc.
    define buffer detlc   for detlc.
    define buffer vbdetlc for detlc.

    if piNumeroUl = 997 or piNumeroUl = 998
    then piNouveauNumeroUl = piNumeroUl.
    else do:
        /* rechercher si no UL déjà pris */
        find first unite no-lock
             where unite.nomdt = piNumeroMandatAcheteur
               and unite.noapp = piNumeroUl no-error.
        if available unite
        then do:
            /* rechercher si no UL = no lot principal déjà pris */
            if piNumeroLot <> 997 and piNumeroLot <> 998 and piNumeroLot <= 999
            then do:
                find first unite no-lock
                     where unite.nomdt = piNumeroMandatAcheteur
                       and unite.noapp = piNumeroLot no-error.
                if not available unite then piNouveauNumeroUl = piNumeroLot.
            end.
            if piNouveauNumeroUl = 0
            then do:
                /*--> Recherche du prochain numero libre */
                for each unite no-lock
                   where unite.nomdt = piNumeroMandatAcheteur
                     and unite.noapp < 997
                break by unite.nomdt by unite.noapp by unite.nocmp:
                    if last-of(unite.noapp)
                    then do:
                        if unite.noapp > piNouveauNumeroUl + 1 then leave.
                        piNouveauNumeroUl = unite.noapp.
                    end.
                end.
                piNouveauNumeroUl = piNouveauNumeroUl + 1.
                if piNouveauNumeroUl > 999 then piNouveauNumeroUl = 0.
            end.
        end.
        else piNouveauNumeroUl = piNumeroUl.
    end.
    if piNouveauNumeroUl = 0
    then do:
        mLogger:writeLog(0, "PrcNewUL : Erreur prochain no UL non trouvé pour mandat " + string(piNumeroMandatAcheteur) ).
        mError:createError({&error}, 1000708, string(piNumeroMandatAcheteur)).    //Dépassement des no UL, Mandat &1 : Erreur en création UL - Aucun no disponible
        return.
    end.
    if not can-find (first unite no-lock
                     where unite.nomdt = piNumeroMandatAcheteur
                       and unite.noapp = piNouveauNumeroUl)
    then do:
        /* Création UL , Duplication UL Vendeur */
        for last vbunite no-lock
           where vbunite.nomdt = piNumeroContratMutation
             and vbunite.noapp = piNumeroUl
             and vbunite.noact = 0:
            create ttUnite.
            outils:copyValidField(buffer vbunite:handle, buffer ttUnite:handle).
            assign
                ttUnite.CRUD  = "C"
                ttUnite.nomdt = piNumeroMandatAcheteur
                ttUnite.noapp = piNouveauNumeroUl
                ttUnite.noman = piNoRole
                ttUnite.nocmp = 10
                ttUnite.dtdeb = pdaAchat
                ttUnite.cdocc = "00002"               /* occupant à mettre à jour à la duplication du bail */
                ttUnite.norol = 0
                ttUnite.cdcsy = mtoken:cUser + "@" + "mutger02"
            .
            ghProc = lancementPgm("adblib/unite_CRUD.p", goCollectionHandlePgm).
            run setUnite in ghProc (table ttUnite by-reference).
            if mError:erreur() then return.
        end.
        /* Si param charges locatives sur UL vacantes alors création auto du bail de rang 00 */
        if not valid-object(voparametrageChargeLocative)
        then voparametrageChargeLocative = new parametrageChargeLocative().
        if voparametrageChargeLocative:IsChargeLocativeSurULVacante()
        then do:
            ghProc = lancementPgm("bail/crebail.p", goCollectionHandlePgm).
            run lancementCrebail in ghProc ({&TYPECONTRAT-mandat2Gerance}, piNumeroMandatAcheteur, {&TYPECONTRAT-bail}, {&NATURECONTRAT-specialVacant}).
            if mError:erreur() then return.
        end.
        /* Ajout SY le 26/07/2010 :  Duplication de l'offre de location  */
        empty temp-table ttOfflc.
        empty temp-table ttDetlc.
        for each offlc no-lock
           where offlc.tpcon = {&TYPECONTRAT-mandat2Gerance}
             and offlc.nocon = piNumeroContratMutation
             and offlc.noapp = piNumeroUl:
            if not can-find (first vbofflc no-lock
                             where vbofflc.tpcon = offlc.tpcon
                               and vbofflc.nocon = piNumeroMandatAcheteur
                               and vbofflc.noapp = piNouveauNumeroUl)
            then do:
                create ttOfflc.
                outils:copyValidField(buffer offlc:handle, buffer ttOfflc:handle).
                assign
                    ttOfflc.nocon = piNumeroMandatAcheteur
                    ttOfflc.noapp = piNouveauNumeroUl
                    ttOfflc.cdcsy = mtoken:cUser + "@" + "mutger02"
                    ttOfflc.CRUD = "C"
                .
            end.
            for each detlc no-lock
               where detlc.tpcon = offlc.tpcon
                 and detlc.nocon = offlc.nocon
                 and detlc.noapp = offlc.noapp:
                if not can-find (first vbdetlc no-lock
                                 where vbdetlc.tpcon = offlc.tpcon
                                   and vbdetlc.nocon = piNumeroMandatAcheteur
                                   and vbdetlc.noapp = piNouveauNumeroUl
                                   and vbdetlc.norub = detlc.norub)
                then do:
                    create ttDetlc.
                    outils:copyValidField(buffer detlc:handle, buffer ttDetlc:handle).
                    assign
                        ttDetlc.nocon = piNumeroMandatAcheteur
                        ttDetlc.noapp = piNouveauNumeroUl
                        ttDetlc.cdcsy = mtoken:cUser + "@" + "mutger02"
                        ttDetlc.CRUD = "C"
                    .
                end.
            end.
        end.
        ghProc = lancementPgm("adblib/offlc_CRUD.p", goCollectionHandlePgm).
        run setOfflc in ghProc (table ttOfflc by-reference).
        if mError:erreur() then return.
        ghProc = lancementPgm("adblib/detlc_CRUD.p", goCollectionHandlePgm).
        run setDetlc in ghProc (table ttDetlc by-reference).
        if mError:erreur() then return.
    end.

end procedure.

procedure DupliBail private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de validation d'un mandat provisoire + majmdt compta + création UL 998 +  maj no registre si REGIS = AUTO)
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter NoCttMut-IN          as integer  no-undo.
    define input parameter NoImmUse-IN          as integer  no-undo.
    define input parameter NoBaiOld-IN          as integer  no-undo.
    define input parameter DtAchNot-IN          as date     no-undo.
    define input parameter MsDerQtt-IN          as integer  no-undo.
    define input parameter DtResBai-IN          as date     no-undo.
    define input parameter NoMdtAch-IN          as integer  no-undo.
    define input parameter NoAppAch-IN          as integer  no-undo.
    define input-output parameter NoBaiNew-IO   as integer  no-undo.
    define input-output parameter MsQttAch-IO   as integer  no-undo.

    define variable LbDivPar as character no-undo.
    define variable FgRetCre as logical   no-undo.

/*
    {RunPgExp.i
        &Path       = RpRunCtt
        &Prog       = "'MutBai01.p'"
        &Parameter  = " INPUT NoCttMut-IN
                    ,INPUT {&TYPECONTRAT-mandat2Gerance}
                    ,INPUT NoMdtAch-IN
                    ,INPUT NoAppAch-IN
                    ,INPUT NoImmUse-IN
                    ,INPUT NoTrsUse
                    ,INPUT DtAchNot-IN
                    ,INPUT {&TYPECONTRAT-bail}
                    ,INPUT '00019'
                    ,INPUT NoBaiOld-IN
                    ,INPUT MsDerQtt-IN
                    ,INPUT DtResBai-IN
                    ,INPUT {&TYPECONTRAT-bail}
                    ,INPUT '00019'
                    ,input-output NoBaiNew-IO
                    ,input-output MsQttAch-IO
                    ,input-output LbDivPar
                    ,OUTPUT FgRetCre
                    "}
*/
    ghProc = lancementPgm("bail/mutbai01.p", goCollectionHandlePgm).
    run lancementMutBai01 in ghProc (NoCttMut-IN, NoMdtAch-IN, NoAppAch-IN, NoImmUse-IN, DtAchNot-IN, NoBaiOld-IN, MsDerQtt-IN, DtResBai-IN, input-output NoBaiNew-IO, input-output MsQttAch-IO, input-output LbDivPar ).
    if mError:erreur() then return.

end procedure.

procedure validMutation:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de validation du contrat mutation
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroContratMutation as int64     no-undo.
    define input parameter pcInfoUserModification  as character no-undo.

    define buffer ctrat for ctrat.

    empty temp-table ttCtrat.
    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mutationGerance}
          and ctrat.nocon = piNumeroContratMutation:
        create ttCtrat.
        assign
            ttCtrat.tpcon       = ctrat.tpcon
            ttCtrat.nocon       = ctrat.nocon
            ttCtrat.CRUD        = "U"
            ttCtrat.dtTimestamp = datetime(ctrat.dtmsy, ctrat.hemsy)
            ttCtrat.rRowid      = rowid(ctrat)
            ttCtrat.fgprov      = no
            ttCtrat.dtvaldef    = today
            ttCtrat.cdmsy       = mtoken:cUser + "@" + "mutger02.p" + "@" + pcInfoUserModification
        .
        ghProc = lancementPgm("adblib/ctrat_CRUD.p", goCollectionHandlePgm).
        run setCtrat in ghProc (table ttCtrat by-reference).
    end.

end procedure.

procedure PrcFinUl:
    /*------------------------------------------------------------------------------
    Purpose: Procedure d'arret d'une UL
             arreter une UL =
               1) UL <> 998 = creer une nouvelle composition VIDE pour cette unite
                            + creer unite avec noact = ancienne compo & date de fin
                            + creer unite avec noact = 0 & date de d‚but
                               & Maj no lot principal & lien adresse
                    + dans ancienne compo : mettre cpuni.cdori à "F"
               2) UL =  998 = Supprimer les lots de la composition 10
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer  no-undo.
    define input parameter piNumeroUl as integer  no-undo.
    define input parameter piNumeroImmeuble as integer  no-undo.
    define input parameter piNumeroLot as integer  no-undo.
    define input parameter DtFinUL-IN  as date     no-undo.

    define buffer unite for unite.
    define buffer cpuni for cpuni.

    mLogger:writeLog (0, "PrcFinUl - mandat "  + string(piNumeroMandat) + " Appt " + string(piNumeroUl) + " lot " + string(piNumeroLot) ).
    empty temp-table ttCpuni.
    empty temp-table ttUnite.
    if piNumeroUl = 998
    then do:
        for each cpuni no-lock
           where cpuni.nomdt = piNumeroMandat
             and cpuni.noapp = piNumeroUl
             and cpuni.nocmp = 10
             and cpuni.NoLot = piNumeroLot:
            mLogger:writeLog (0, "PrcFinUl - Mandat " + string(piNumeroMandat) + " imm " + string(piNumeroImmeuble) + " : LOT " + string(piNumeroLot) + " enlevé de l'UL " + string(piNumeroUl) ).
            create ttCpuni.
            assign
                ttCpuni.nomdt       = cpuni.nomdt
                ttCpuni.noapp       = cpuni.noapp
                ttCpuni.nocmp       = cpuni.nocmp
                ttCpuni.noord       = cpuni.noord
                ttCpuni.CRUD        = 'D'
                ttCpuni.dtTimestamp = datetime(cpuni.dtmsy, cpuni.hemsy)
                ttCpuni.rRowid      = rowid(cpuni).
            .
        end.
        ghProc = lancementPgm("immeubleEtLot/cpuni_CRUD.p", goCollectionHandlePgm).
        run setCpuni in ghProc (table ttCpuni by-reference).
        return.
    end.

    /* Rechercher la composition en cours */
    find last unite no-lock
        where unite.nomdt = piNumeroMandat
          and unite.noapp = piNumeroUl
          and unite.noact = 0 no-error.
    if not available unite then return.
    /* si lot déjà retiré : sortir */
    find first cpuni no-lock
         where cpuni.nomdt = piNumeroMandat
           and cpuni.noapp = piNumeroUl
           and cpuni.nocmp = unite.nocmp
           and cpuni.noimm = piNumeroImmeuble
           and cpuni.nolot = piNumeroLot no-error.
    if not available cpuni then return.
    if unite.dtdeb < DtFinUL-IN
    then do:
        /* mettre en histo l'UL en cours */
        create ttUnite.
        outils:copyValidField(buffer unite:handle, buffer ttUnite:handle).
        assign
            ttUnite.noact = unite.nocmp
            ttUnite.dtfin = DtFinUL-IN
            ttUnite.cdcsy = mtoken:cUser + "@" + "mutger02"
            ttUnite.CRUD  = "C"
        .
        /* Maj nlle unite en cours (VIDE) */
        create ttUnite.
        assign
            ttUnite.nomdt       = unite.nomdt
            ttUnite.noapp       = unite.noapp
            ttUnite.noact       = unite.noact
            ttUnite.nocmp       = unite.nocmp + 1
            ttUnite.dtdeb       = (if DtFinUL-IN <> ? then DtFinUL-IN + 1 else today)
            ttUnite.nolot       = 0
            ttUnite.nolie       = 0
            ttUnite.norol       = 0
            ttUnite.cdcsy       = mtoken:cUser + "@" + "mutger02"
            ttUnite.CRUD        = "U"
            ttUnite.dtTimestamp = datetime(unite.dtmsy, unite.hemsy)
            ttUnite.rRowid      = rowid(unite).
        .
        mLogger:writeLog (0, "PrcFinUl - Mandat " + string(piNumeroMandat) + " UL " + string(piNumeroUl) + " : Nlle compo " + string(unite.nocmp) + " VIDE " ).
    end.
    else do:
        /* enlever le lot de la composition */
        for each cpuni no-lock
           where cpuni.nomdt = piNumeroMandat
             and cpuni.noapp = piNumeroUl
             and cpuni.nocmp = unite.nocmp
             and cpuni.noimm = piNumeroImmeuble
             and cpuni.nolot = piNumeroLot:
            mLogger:writeLog (0, "PrcFinUl - Mandat " + string(piNumeroMandat) + " imm " + string(piNumeroImmeuble) + " : LOT " + string(piNumeroLot) + " enlevé de l'UL " + string(piNumeroUl) ).
            create ttCpuni.
            assign
                ttCpuni.nomdt       = cpuni.nomdt
                ttCpuni.noapp       = cpuni.noapp
                ttCpuni.nocmp       = cpuni.nocmp
                ttCpuni.noord       = cpuni.noord
                ttCpuni.CRUD        = 'D'
                ttCpuni.dtTimestamp = datetime(cpuni.dtmsy, cpuni.hemsy)
                ttCpuni.rRowid      = rowid(cpuni).
            .
        end.
    end.
    ghProc = lancementPgm("immeubleEtLot/cpuni_CRUD.p", goCollectionHandlePgm).
    run setCpuni in ghProc (table ttCpuni by-reference).
    if mError:erreur() then return.
    ghProc = lancementPgm("adblib/unite_CRUD.p", goCollectionHandlePgm).
    run setUnite in ghProc (table ttUnite by-reference).

end procedure.

procedure majTotCle private:
    /*------------------------------------------------------------------------------
    Purpose: Procedure de regénération des entetes clé par mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandatAcheteur as integer no-undo.
    define input parameter piNumeroContrat        as integer no-undo.

    define variable vdTotalMandat as decimal no-undo.

    define buffer intnt for intnt.
    define buffer local for Local.
    define buffer milli for milli.

    empty temp-table ttMilliemeLot.
    for each intnt no-lock
       where intnt.tpidt = {&TYPEBIEN-lot}
         and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
         and intnt.nocon = piNumeroMandatAcheteur
    , first local no-lock
      where local.noloc = intnt.noidt
    , each milli no-lock
     where milli.noimm = local.noimm
       and milli.nolot = local.nolot:
        create ttMilliemeLot.
        assign
            ttMilliemeLot.iNumeroLot = local.nolot
            ttMilliemeLot.cCdCle     = milli.cdcle
            ttMilliemeLot.dNbPar     = milli.nbpar
        .
    end.
    empty temp-table ttClemi.
    for each ttMilliemeLot
    break by ttMilliemeLot.cCdCle
          by ttMilliemeLot.iNumeroLot:
        if first-of(ttMilliemeLot.cCdCle) then vdTotalMandat = 0.
        vdTotalMandat = vdTotalMandat + ttMilliemeLot.dNbPar.
        if last-of(ttMilliemeLot.cCdCle)
        then do:
            create ttclemi.
            assign
                ttClemi.cTypeContrat   = {&TYPECONTRAT-mandat2Gerance}
                ttClemi.iNumeroContrat = piNumeroMandatAcheteur
                ttClemi.dEcart         = 0
                ttClemi.dTotal         = vdTotalMandat
                ttClemi.cCodeEtat      = "V"
                ttClemi.cdmsy          = mtoken:cUser + "@" + "Mutger02.p"
            .
            find first clemi no-lock
                 where clemi.noimm = 10000 + piNumeroMandatAcheteur
                   and clemi.cdcle = ttMilliemeLot.cCdCle no-error.
            if available clemi
            then assign
                     ttClemi.CRUD         = "U"
                     ttCpreln.dtTimestamp = datetime(clemi.dtmsy, clemi.hemsy)
                     ttCpreln.rRowid      = rowid(clemi)
            .
            else do:
                ttClemi.CRUD = "C".
                /* Recherche si clé existe pour l'immeuble ou pour l'ancien mandat */
                find first clemi no-lock
                     where clemi.noimm = giNumeroImmeuble
                       and clemi.cdcle = ttMilliemeLot.cCdCle no-error.
                if not available clemi
                then find first clemi no-lock
                          where clemi.noimm = 10000 + piNumeroContrat
                            and clemi.cdcle = ttMilliemeLot.cCdCle no-error.
                assign
                    ttClemi.iNumeroImmeuble = 10000 + piNumeroMandatAcheteur
                    ttClemi.cCodeCle        = ttMilliemeLot.cCdCle
                    ttClemi.cNatureCle      = (if available clemi then clemi.tpcle else {&NATURECLE-Divers})
                    ttClemi.cLibelleCle     = (if available clemi then clemi.lbcle else ttMilliemeLot.cCdCle)
                    ttClemi.cCodebatiment   = (if available clemi then clemi.cdbat else "")
                    ttClemi.cCodeEtat       = (if available clemi then clemi.cdeta else "V")
                    ttClemi.iNumeroOrdre    = (if available clemi then clemi.noord else 500)
                    ttclemi.cdcsy           = mtoken:cUser + "@" + "Mutger02.p" 
                no-error.
                if vdTotalMandat = 0 and clemi.tpcle = {&NATURECLE-General}
                then ttClemi.cNatureCle = {&NATURECLE-ImputationParticuliere}.
            end.
        end.
    end.
    ghProc = lancementPgm("adblib/clemi_CRUD.p", goCollectionHandlePgm).
    run setClemi in ghProc (table ttclemi by-reference).

end procedure.

procedure exportTable private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    todo   gga a enlever apres les tests
    ------------------------------------------------------------------------------*/
    define input parameter piNumero as integer   no-undo.
    define input parameter pcType   as character no-undo.
    put "ctrat" skip.
    for each ctrat no-lock
        where ctrat.nocon = piNumero
          and ctrat.tpcon = pcType:
        export ctrat except ctrat.cdcsy ctrat.dtcsy ctrat.hecsy ctrat.cdmsy ctrat.dtmsy ctrat.hemsy.
    end.
    put "intnt" skip.
    for each intnt no-lock
        where intnt.nocon = piNumero
          and intnt.tpcon = pcType:
        export intnt except intnt.cdcsy intnt.dtcsy intnt.hecsy intnt.cdmsy intnt.dtmsy intnt.hemsy.
    end.
    put "ctctt" skip.
    for each ctctt no-lock
        where ctctt.noct2 = piNumero
          and ctctt.tpct2 = pcType:
        export ctctt except ctctt.cdcsy ctctt.dtcsy ctctt.hecsy ctctt.cdmsy ctctt.dtmsy ctctt.hemsy.
    end.
    put "unite" skip.
    for each unite no-lock
        where unite.nomdt = piNumero:
        export unite except unite.cdcsy unite.dtcsy unite.hecsy unite.cdmsy unite.dtmsy unite.hemsy.
    end.
    put "cpuni" skip.
    for each cpuni no-lock
        where cpuni.nomdt = piNumero:
        export cpuni except cpuni.cdcsy cpuni.dtcsy cpuni.hecsy cpuni.cdmsy cpuni.dtmsy cpuni.hemsy.
    end.
    put "cttac" skip.
    for each cttac no-lock
        where cttac.nocon = piNumero
          and cttac.tpcon = pcType:
        export cttac except cttac.cdcsy cttac.dtcsy cttac.hecsy cttac.cdmsy cttac.dtmsy cttac.hemsy.
    end.
    put "tache" skip.
    for each tache no-lock
        where tache.nocon = piNumero
          and tache.tpcon = pcType:
        export tache except tache.cdcsy tache.dtcsy tache.hecsy tache.cdmsy tache.dtmsy tache.hemsy .
    end.
    put "ietab" skip.
    for each ietab no-lock
        where ietab.etab-cd = piNumero:
        export ietab except ietab.dacrea ietab.ihcrea ietab.usrid ietab.damod ietab.ihmod ietab.usridmod.
    end.
    put "iprd" skip.
    for each iprd no-lock
        where iprd.etab-cd = piNumero:
        export iprd.
    end.
    put "iparmdt" skip.
    for each iparmdt no-lock
        where iparmdt.etab-cd = piNumero:
        export iparmdt.
    end.
    put "ijou" skip.
    for each ijou no-lock
        where ijou.etab-cd = piNumero:
        export ijou except ijou.dacrea ijou.ihcrea ijou.usrid ijou.damod ijou.ihmod ijou.usridmod.
    end.
    put "ijouprd" skip.
    for each ijouprd no-lock
        where ijouprd.etab-cd = piNumero:
        export ijouprd.
    end.
    put "aetabln" skip.
    for each aetabln no-lock
        where aetabln.mandat-cd = piNumero:
        export aetabln.
    end.
    put "csscpt" skip.
    for each csscpt no-lock
        where csscpt.etab-cd = piNumero:
        export csscpt except csscpt.dacrea csscpt.ihcrea csscpt.usrid csscpt.damod csscpt.ihmod csscpt.usridmod.
    end.
    put "parenc" skip.
    for each parenc no-lock
        where parenc.etab-cd = piNumero:
        export parenc.
    end.
    put "csscptcol" skip.
    for each csscptcol no-lock
        where csscptcol.etab-cd = piNumero:
        export csscptcol.
    end.
    put "itypemvt" skip.
    for each itypemvt no-lock
        where itypemvt.etab-cd = piNumero:
        export itypemvt.
    end.
    put "cbilna" skip.
    for each cbilna no-lock
        where cbilna.etab-cd = piNumero:
        export cbilna.
    end.
    put "cbilnb" skip.
    for each cbilnb no-lock
        where cbilnb.etab-cd = piNumero:
        export cbilnb.
    end.
    put "cbilnc" skip.
    for each cbilnc no-lock
        where cbilnc.etab-cd = piNumero:
        export cbilnc.
    end.
    put "cbilnd" skip.
    for each cbilnd no-lock
        where cbilnd.etab-cd = piNumero:
        export cbilnd.
    end.
    put "ccdbilan" skip.
    for each ccdbilan no-lock
        where ccdbilan.etab-cd = piNumero:
        export ccdbilan.
    end.
    put "crepbil" skip.
    for each crepbil no-lock
        where crepbil.etab-cd = piNumero:
        export crepbil.
    end.
    put "crepbiln" skip.
    for each crepbiln no-lock
        where crepbiln.etab-cd = piNumero:
        export crepbiln.
    end.
    put "clemi" skip.
    for each clemi no-lock
        where clemi.nocon = piNumero:
        export clemi except clemi.cdcsy clemi.dtcsy clemi.hecsy clemi.cdmsy clemi.dtmsy clemi.hemsy.
    end.
    for each clemi
       where clemi.noimm = 10000 + piNumero:
        export clemi except cdcsy dtcsy hecsy cdmsy dtmsy hemsy.
    end.
    put "role" skip.
    for each role
    where role.norol = piNumero:
        export role except role.cdcsy role.dtcsy role.hecsy role.cdmsy role.dtmsy role.hemsy.
    end.
    put "ladrs" skip.
    for each ladrs
    where ladrs.noidt = piNumero   :
        export ladrs except ladrs.cdcsy ladrs.dtcsy ladrs.hecsy ladrs.cdmsy ladrs.dtmsy ladrs.hemsy.
    end.
    put "rlctt" skip.
    for each rlctt
    where rlctt.noidt = piNumero   :
        export rlctt except rlctt.cdcsy rlctt.dtcsy rlctt.hecsy rlctt.cdmsy rlctt.dtmsy rlctt.hemsy.
    end.
    put "revtrt" skip.
    for each revtrt
    where  revtrt.tpcon = pcType
    and revtrt.nocon = piNumero   :
        export revtrt except revtrt.cdcsy revtrt.dtcsy revtrt.hecsy revtrt.cdmsy revtrt.dtmsy revtrt.hemsy.
    end.
    put "revhis" skip.
    for each revhis
    where  revhis.tpcon = pcType
    and revhis.nocon = piNumero   :
        export revhis except cdcsy dtcsy hecsy cdmsy dtmsy hemsy.
    end.

    output close.
end procedure.

