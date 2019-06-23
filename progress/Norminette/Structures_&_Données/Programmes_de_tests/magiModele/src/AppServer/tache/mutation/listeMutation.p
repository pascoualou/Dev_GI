/*------------------------------------------------------------------------
File        : listeMutation.p
Purpose     :
Author(s)   :
Notes       : a partir de adb/tach/prmmtmut.p
                          adb/tach/hismtmut.p
derniere revue: 2018/23/03 - phm
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tache/include/tacheMutation.i}
{application/include/glbsepar.i}
{comm/include/procclot.i}        // procedure occupLot
{application/include/error.i}
{adblib/include/ctrat.i}
{adblib/include/ctctt.i}
{adblib/include/intnt.i}
{outils/include/lancementProgramme.i}

define variable goCollectionHandlePgm as class collection no-undo.
define variable ghProc as handle no-undo.

function numeroImmeuble return integer private(piNumeroMandat as int64, pcTypeMandat as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche immeuble du mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock
        where intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        return intnt.noidt.
    end.
    mError:createErrorGestion({&error}, 106470, string(piNumeroMandat)). //immeuble non trouve pour mandat %1
    return 0.
end function.

function numeroMandatSyndic return integer private(piNumeroImmeuble as integer):
    /*------------------------------------------------------------------------------
    Purpose: recherche numero mandat de syndic
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
        return intnt.nocon.
    end.
    return 0.
end function.

procedure getUlMutation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttListeLotMutation.
    define output parameter table for ttMutation.

    empty temp-table ttListeLotMutation.
    empty temp-table ttMutation.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeMandat
                      and ctrat.nocon = piNumeroMandat)
    then mError:createError({&error}, 100057).
    else run lectureUniteLocation(pcTypeMandat, piNumeroMandat).
    return.
end procedure.

procedure getUlMutationHisto:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter pcTypeMandat   as character no-undo.
    define output parameter table for ttListeLotMutation.
    define output parameter table for ttMutation.

    empty temp-table ttListeLotMutation.
    empty temp-table ttMutation.
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeMandat
                      and ctrat.nocon = piNumeroMandat)
    then mError:createError({&error}, 100057).
    else run lectureUniteLocationHisto(pcTypeMandat, piNumeroMandat).
    return.
end procedure.

procedure lectureUniteLocation private:
    /*------------------------------------------------------------------------------
    Purpose: Liste des UL-Lot du mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as int64     no-undo.

    define variable viI                  as integer   no-undo.
    define variable vcTempoRechUl        as character no-undo.
    define variable viNumeroUl           as integer   no-undo.
    define variable viNumeroImmeuble     as integer   no-undo.
    define variable viNumeroMandatSyndic as int64     no-undo.
    define variable viNoord              as integer   no-undo.

    define buffer intnt           for intnt.
    define buffer local           for local.
    define buffer unite           for unite.
    define buffer cpuni           for cpuni.
    define buffer vbCtratMutation for ctrat.
    define buffer vbCtratBail     for ctrat.

    viNumeroImmeuble = numeroImmeuble(piNumeroMandat, pcTypeMandat).
    if mError:erreur() then return.

    viNumeroMandatSyndic = numeroMandatSyndic(viNumeroImmeuble).
    /* UL-lots du mandat */
    for each intnt no-lock
        where intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-lot}
      , first local no-lock
        where local.noloc = intnt.noidt
      , each unite no-lock
        where unite.nomdt = piNumeroMandat
          and unite.noact = 0
      , first cpuni no-lock
        where cpuni.nomdt = unite.nomdt
          and cpuni.noapp = unite.noapp
          and cpuni.nocmp = unite.nocmp
          and cpuni.noimm = local.noimm
          and cpuni.nolot = local.nolot:
        run createTTListeLotMutation(buffer local, pcTypeMandat, piNumeroMandat, yes, cpuni.noapp, if local.fgdiv then cpuni.sflot else local.sfree, cpuni.noord).
        run rechInfoBailOccupant(buffer local).
        run rechCtratMutation(local.noloc, piNumeroMandat).
    end.
    /* anciens lots en attente de validation de la mutation vers un nouveau mandat */
    for each vbCtratMutation no-lock
        where vbCtratMutation.tpcon = {&TYPECONTRAT-mutationGerance}
          and vbCtratMutation.nocon >= piNumeroMandat * 10000 + 1                  //integer(string(piNumeroMandat, "99999") + "0001")
          and vbCtratMutation.nocon <= piNumeroMandat * 10000 + 9999               //integer(string(piNumeroMandat, "99999") + "9999")
          and vbCtratMutation.fgprov = yes
          and vbCtratMutation.nomdt-ach > 0           /* no nouveau mandat gérance */
      , each intnt no-lock
        where intnt.tpcon = vbCtratMutation.tpcon
          and intnt.nocon = vbCtratMutation.nocon
          and intnt.tpidt = {&TYPEBIEN-lot}
      , first local no-lock
        where local.noloc = intnt.noidt:
        /* boucle sur les (ex) UL du lot */
        do viI = 1 to num-entries(intnt.lbdiv, separ[1]):
            assign
                vcTempoRechUl = entry(viI, intnt.lbdiv, separ[1])
                viNumeroUl    = integer(entry(1, vcTempoRechUl, separ[2]))
                viNoord       = integer(entry(3, vcTempoRechUl, separ[2]))
            no-error.
            if not can-find(first ttListeLotMutation
                            where ttListeLotMutation.iNumeroUL  = viNumeroUl
                              and ttListeLotMutation.iNumeroLot = local.nolot)
            then do:
                run createTTListeLotMutation(buffer local, pcTypeMandat, piNumeroMandat, no, viNumeroUl, local.sfree, viNoord).
                run rechInfoBailOccupant(buffer local).
                for last vbCtratBail no-lock
                    where vbCtratBail.tpcon = {&TYPECONTRAT-bail}
                      and vbCtratBail.nocon >= piNumeroMandat * 100000 + viNumeroUl * 100 + 1  //integer(string(piNumeroMandat , "99999") + string(viNumeroUl , "999") + "01" )
                      and vbCtratBail.nocon <= piNumeroMandat * 100000 + viNumeroUl * 100 + 99 //integer(string(piNumeroMandat , "99999") + string(viNumeroUl , "999") + "99" )
                      and (vbCtratBail.dtree = ? or vbCtratBail.dtree >= vbCtratMutation.dtsig):
                    assign
                        ttListeLotMutation.iNumeroBail = vbCtratBail.nocon
                        ttListeLotMutation.cOccupant   = vbCtratBail.lbnom
                    .
                end.
                /* infos mutation */
                run creationTTMutation(buffer vbCtratMutation, no).
            end.
        end.
    end.

end procedure.

procedure lectureUniteLocationHisto private:
    /*------------------------------------------------------------------------------
    Purpose: Liste des UL-Lot du mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as int64     no-undo.

    define variable viI                  as integer   no-undo.
    define variable vcTempoRechUl        as character no-undo.
    define variable viNumeroUl           as integer   no-undo.
    define variable viNumeroImmeuble     as integer   no-undo.
    define variable viNumeroMandatSyndic as int64     no-undo.
    define variable viNoord              as integer   no-undo.

    define buffer intnt           for intnt.
    define buffer local           for local.
    define buffer vbCtratMutation for ctrat.
    define buffer vbCtratBail     for ctrat.
    define buffer detail          for detail.

    viNumeroImmeuble = numeroImmeuble(piNumeroMandat, pcTypeMandat).
    if mError:erreur() then return.

    viNumeroMandatSyndic = numeroMandatSyndic(viNumeroImmeuble).
    for each vbctratMutation no-lock
        where vbctratMutation.tpcon = {&TYPECONTRAT-mutationGerance}
          and vbctratMutation.nocon >= piNumeroMandat * 10000 + 1                  //integer(string(piNumeroMandat, "99999") + "0001")
          and vbctratMutation.nocon <= piNumeroMandat * 10000 + 9999               //integer(string(piNumeroMandat, "99999") + "9999")
          and vbctratMutation.fgprov = no
      , each intnt no-lock
        where intnt.tpcon = vbctratMutation.tpcon
          and intnt.nocon = vbctratMutation.nocon
          and intnt.tpidt = {&TYPEBIEN-lot}
      , first local no-lock
        where local.noloc = intnt.noidt:
        /* boucle sur les (ex) UL du lot */
        do viI = 1 to num-entries(intnt.lbdiv, separ[1]):
            assign
                vcTempoRechUl = entry(viI, intnt.lbdiv, separ[1])
                viNumeroUl    = integer(entry(1, vcTempoRechUl, separ[2]))
                viNoord = integer(entry(3, vcTempoRechUl, separ[2]))
             no-error.
             if not can-find(first ttListeLotMutation
                             where ttListeLotMutation.iNumeroUL  = viNumeroUl
                               and ttListeLotMutation.iNumeroLot = local.nolot)
            then do:
                run createTTListeLotMutation(buffer local, pcTypeMandat, piNumeroMandat, no, viNumeroUl, local.sfree, viNoord).
                /* infos mutation */
                run creationTTMutation(buffer vbctratMutation, no).
                for first detail no-lock
                    where detail.cddet = "MUTAG" + string(vbctratMutation.nocon, "999999999")
                      and detail.nodet = local.noimm
                      and detail.iddet = local.nolot
                      and detail.ixd02 = string(viNumeroUl, "999"):
                    assign
                        ttListeLotMutation.iNumeroBail  = detail.tbdec[3]        /* nouveau no bail */
                        ttListeLotMutation.iNumeroULAch = detail.tbint[2]        /* nouveau no UL */
                    .
                    /* Modif SY le 22/07/2011 : Pb mauvais stockage no bail créé dans mutger02.p */
                    if ttListeLotMutation.iNumeroBail <> 0
                    and ttListeLotMutation.iNumeroULAch <> truncate(ttListeLotMutation.iNumeroBail modulo 100000 / 100, 0)
                    then do:
                        ttListeLotMutation.iNumeroBail = vbctratMutation.nomdt-ach * 100000 + ttListeLotMutation.iNumeroULAch * 100 + 01.
                        if not can-find(first vbCtratBail no-lock
                                        where vbCtratBail.tpcon = {&TYPECONTRAT-bail}
                                          and vbCtratBail.nocon = ttListeLotMutation.iNumeroBail)
                        then ttListeLotMutation.iNumeroBail = 0.
                    end.
                    ttListeLotMutation.cOccupant = outilFormatage:getNomTiers("00019", ttListeLotMutation.iNumeroBail).
                end.
            end.
        end.
    end.

end procedure.

procedure createTTListeLotMutation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer local for local.
    define input parameter pcTypeMandat   as character no-undo.
    define input parameter piNumeroMandat as int64     no-undo.
    define input parameter plLotActuel    as logical   no-undo.
    define input parameter piNumeroUl     as integer   no-undo.
    define input parameter pdSurface      as decimal   no-undo.
    define input parameter piNoord        as integer   no-undo.

    define variable vcTempoAdresse as character no-undo.

    create ttListeLotMutation.
    assign
        ttListeLotMutation.CRUD              = 'R'
        ttListeLotMutation.cTypeContrat      = pcTypeMandat
        ttListeLotMutation.iNumeroContrat    = piNumeroMandat
        ttListeLotMutation.lLotActuel        = plLotActuel
        ttListeLotMutation.iNumeroUL         = piNumeroUl
        ttListeLotMutation.iNumeroLot        = local.nolot
        ttListeLotMutation.iNumeroClassement = piNoord
        ttListeLotMutation.cNatureLot        = local.ntlot
        ttListeLotMutation.cLibelleNature    = outilTraduction:getLibelleParam("NTLOT", local.ntlot)
        ttListeLotMutation.lDivisible        = local.fgdiv
        ttListeLotMutation.cBatiment         = local.cdbat
        ttListeLotMutation.cEntree           = local.lbdiv
        ttListeLotMutation.cEscalier         = local.cdesc
        ttListeLotMutation.cEtage            = local.cdeta
        ttListeLotMutation.cPorte            = local.cdpte
        ttListeLotMutation.iNombrePiece      = local.nbprf
        ttListeLotMutation.dSurface          = pdSurface
        vcTempoAdresse                       = outilFormatage:getAdresseTelephonesRole({&TYPEBIEN-lot}, local.noloc) /* ancien frmadr4 */
        ttListeLotMutation.cAdresse          = entry(1, vcTempoAdresse, separ[1])
        ttListeLotMutation.cCodePostal       = entry(2, vcTempoAdresse, separ[1])
        ttListeLotMutation.cVille            = entry(3, vcTempoAdresse, separ[1])
    .
end procedure.

procedure rechInfoBailOccupant private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer local for local.

    define variable viNumeroBail        as integer   no-undo.
    define variable viNumeroContratProp as integer   no-undo.
    define variable vcTypeRoleProp      as character no-undo.
    define variable viNumeroRoleProp    as integer   no-undo.
    define variable vdaAchat            as date      no-undo.
    define variable vcCodeRegroupement  as character no-undo.
    define variable vcNomOccupant       as character no-undo.
    define variable vdaEntreeOccupant   as date      no-undo.
    define variable vcTypeOccupant      as character no-undo.

    run OccupLot(buffer local,
                 output vcNomOccupant, output vdaEntreeOccupant, output viNumeroBail, output viNumeroContratProp,
                 output vcTypeRoleProp, output viNumeroRoleProp, output vdaAchat, output vcTypeOccupant, output vcCodeRegroupement).
    assign
        ttListeLotMutation.cOccupant          = vcNomOccupant
        ttListeLotMutation.cTypeProprietaire  = outilTraduction:getLibelleParam("TPOCC", vcTypeOccupant)
        ttListeLotMutation.iNumeroBail        = viNumeroBail
        ttListeLotMutation.iNumeroCopro       = viNumeroRoleProp
        ttListeLotMutation.cNomCoproprietaire = outilFormatage:getNomTiers(vcTypeRoleProp, viNumeroRoleProp)
    .
end procedure.

procedure rechCtratMutation private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroInterneLot as int64 no-undo.
    define input parameter piNumeroMandat     as int64 no-undo.

    define variable viI           as integer   no-undo.
    define variable vcTempoRechUl as character no-undo.
    define variable viNumeroUl    as integer   no-undo.

    define buffer intnt for intnt.
    define buffer vbCtratMutation for ctrat.

    for each intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mutationGerance}
          and intnt.tpidt = {&TYPEBIEN-lot}
          and intnt.noidt = piNumeroInterneLot
    , first vbCtratMutation no-lock
      where vbCtratMutation.tpcon = intnt.tpcon
        and vbCtratMutation.nocon = intnt.nocon
        and vbCtratMutation.nocon >= piNumeroMandat * 10000 + 1               //integer(string(piNumeroMandat, "99999") + "0001")
        and vbCtratMutation.nocon <= piNumeroMandat * 10000 + 9999            //integer(string(piNumeroMandat, "99999") + "9999")
        and vbCtratMutation.fgprov = yes:
        /* boucle sur les (ex) UL du lot */
        do viI = 1 to num-entries(intnt.lbdiv, separ[1]):
            assign
                vcTempoRechUl = entry(viI, intnt.lbdiv, separ[1])
                viNumeroUl    = integer(entry(1, vcTempoRechUl, separ[2]))
            .
            if viNumeroUl = ttListeLotMutation.iNumeroUL
            then run creationTTMutation (buffer vbCtratMutation, yes).
        end.
    end.

end procedure.

procedure creationTTMutation private:
    /*------------------------------------------------------------------------------
    Purpose: creation enregistrement pour les infos de mutation
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer vbCtratMutation for ctrat.
    define input parameter plActuel as logical no-undo.

    assign
        ttListeLotMutation.iNumeroMutation        = vbCtratMutation.nocon modulo 10000.   //integer(substring(string(vbCtratMutation.nocon, "999999999"), 6, 4, 'character'))
        ttListeLotMutation.iNumeroContratMutation = vbCtratMutation.nocon
    .
    if not can-find(first ttMutation
                    where ttMutation.cTypeContrat    = ttListeLotMutation.cTypeContrat
                      and ttMutation.iNumeroContrat  = ttListeLotMutation.iNumeroContrat
                      and ttMutation.iNumeroMutation = ttListeLotMutation.iNumeroMutation)
    then do:
        create ttMutation.
        assign
            ttMutation.CRUD                   = 'R'
            ttMutation.dtTimestamp            = datetime(vbCtratMutation.dtmsy, vbCtratMutation.hemsy)
            ttMutation.rRowid                 = rowid(vbCtratMutation)
            ttMutation.cTypeContrat           = ttListeLotMutation.cTypeContrat
            ttMutation.iNumeroContrat         = ttListeLotMutation.iNumeroContrat
            ttMutation.iNumeroMutation        = ttListeLotMutation.iNumeroMutation
            ttMutation.iNumeroContratMutation = vbCtratMutation.nocon
            ttMutation.daVente                = vbCtratMutation.dtsig
            ttMutation.daAchat                = vbCtratMutation.dtdeb
            ttMutation.iNumeroAcheteur        = vbCtratMutation.norol-ach
            ttMutation.cNomAcheteur           = outilFormatage:getNomTiers(vbCtratMutation.tprol-ach, vbCtratMutation.norol-ach)
            ttMutation.iNumeroMandatAcheteur  = vbCtratMutation.nomdt-ach
            ttMutation.lActuel                = plActuel
        .
    end.
    
end procedure.

procedure setMutation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttListeLotMutation.
    define input parameter table for ttMutation.
    define input parameter table for ttError.

    define variable vhDelmut01 as handle no-undo.

    define buffer vbCtratGerance  for ctrat.
    define buffer vbCtratMutation for ctrat.
    define buffer vbttMutation    for ttMutation.

    find first ttMutation where lookup(ttMutation.CRUD, "C,U,D") > 0 no-error.
    if not available ttMutation then return.

    if can-find(first vbttMutation
                where lookup(vbttMutation.CRUD, "C,U,D") > 0
                  and vbttMutation.iNumeroMutation <> ttMutation.iNumeroMutation)
    then do:
        mError:createError({&error}, 1000709).                    //Vous ne pouvez traiter qu'une maj de mutation à la fois
        return.
    end.
    find first vbCtratGerance no-lock
        where vbCtratGerance.tpcon = ttMutation.cTypeContrat
          and vbCtratGerance.nocon = ttMutation.iNumeroContrat no-error.
    if not available vbCtratGerance
    then do:
        mError:createError({&error}, 353).                   //Mandat inexistant
        return.
    end.
    if lookup(ttMutation.CRUD, "U,D") > 0
    then do:
        find first vbCtratMutation no-lock
            where vbCtratMutation.tpcon = {&TYPECONTRAT-mutationGerance}
              and vbCtratMutation.nocon = ttMutation.iNumeroContratMutation no-error.
        if not available vbCtratMutation
        then do:
            mError:createError({&error}, 1000710).                //Contrat mutation inexistant
            return.
        end.
    end.
    goCollectionHandlePgm = new collection().
    if lookup(ttMutation.CRUD, "C,U") > 0
    then do:
        run ctrlAvantMaj(buffer ttMutation, vbCtratGerance.norol, "", ?).
        if mError:erreur() then return.
        run majMutation(buffer ttMutation, vbCtratGerance.norol).
    end.
    else do:
        run ctrlAvantSuppression(buffer vbCtratMutation, ttMutation.iNumeroContrat).
        if mError:erreur() then return.

        run ctrlAvantSuppression02(ttMutation.lActuel, ttMutation.iNumeroMutation).
        if mError:erreur() then return.

        run adblib/delmut01.p persistent set vhDelmut01.
        run getTokenInstance in vhDelmut01(mToken:JSessionId).
        run DelCttMutGer in vhDelmut01(table ttError, ttMutation.iNumeroContratMutation, input-output goCollectionHandlePgm).
        run destroy in vhDelmut01.
    end.
    suppressionPgmPersistent(goCollectionHandlePgm).
    delete object goCollectionHandlePgm.

message "fin pgm". //gga a enlever apres test
mError:createError({&error}, "annul trt pour test"). //gga a enlever apres test

end procedure.

procedure ctrlAvantSuppression private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : extrait de adb/lib/ctdelmug.p (procedure CtrSupMutGer)
             repris ici car le seul appel du programme ctdelmug.p est dans prmmtmut.p
    ------------------------------------------------------------------------------*/
    define parameter buffer vbctratMutation for ctrat.
    define input parameter piNumeroMandat as int64 no-undo.

    define variable viRetourQuestion as integer no-undo.

    if vbctratMutation.fgprov = false then return.         //Si mutation validée => on peut la supprimer

    if vbctratMutation.dtarc <> ? and vbctratMutation.nomdt-ach > 0 //Si mandat acheteur et résiliation ancien mandat effectuée, demander confirmation
    then do:
        //La mutation n°%1 du mandat %2 n'a pas été complètement validée  : %sLa résiliation des baux et le retrait des lots a été effectuée
        //le %3 %smais le report sur le mandat %4 de l'acheteur n'a pas été effectué.%sConfirmez-vous la suppression
        viRetourQuestion = outils:questionnaireGestion(110880, 
                                                       substitute('&2&1&3&1&4&1&5', separ[1],
                                                                                    vbctratMutation.nocon modulo 10000,
                                                                                    piNumeroMandat,
                                                                                    vbctratMutation.dtarc,
                                                                                    vbctratMutation.nomdt-ach),
                                                       table ttError by-reference).
        if viRetourQuestion = 2        //si reponse non a la question alors message erreur (si reponse non, pas la peine de refaire un appel au pgm
        then mError:createErrorGestion({&error},
                                       110880, 
                                       substitute('&2&1&3&1&4&1&5', separ[1],
                                                                    vbctratMutation.nocon modulo 10000,
                                                                    piNumeroMandat,
                                                                    vbctratMutation.dtarc,
                                                                    vbctratMutation.nomdt-ach)).
    end.
    
end procedure.

procedure ctrlAvantSuppression02 private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter plActuel       as logical no-undo.
    define input parameter piNumeroMandat as int64   no-undo.

    define variable viRetourQuestion as integer no-undo.

    if plActuel 
    then do:
        viRetourQuestion = outils:questionnaire(1000751, string(piNumeroMandat), table ttError by-reference). //Confirmez-vous la suppression de la mutation no &1 ?
        if viRetourQuestion = 2        //si reponse non a la question alors message erreur (si reponse non, pas la peine de refaire un appel au pgm
        then mError:createError({&error}, 1000751, string(piNumeroMandat)).             
    end.
    else do:   
        viRetourQuestion = outils:questionnaire(1000750, string(piNumeroMandat), table ttError by-reference). //ATTENTION : La vente des lots a été effectuée et est irréversible. Si vous supprimez cette mutation vous ne pourrez pas la refaire et s'il y a un mandat acheteur vous devrez recréer les UL et les baux MANUELLEMENT. Confirmez-vous la suppression de la mutation no &1 ?
        if viRetourQuestion = 2        //si reponse non a la question alors message erreur (si reponse non, pas la peine de refaire un appel au pgm
        then mError:createError({&error}, 1000750, string(piNumeroMandat)).    
    end.            
    
end procedure.

procedure ctrlAvantMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttMutation for ttMutation.
    define input parameter piMandant        as integer   no-undo.
    define input parameter pcTypeTraitement as character no-undo.   //quand cette procedure sera appele en resiliation
    define input parameter pdaResiliation   as date      no-undo.   //quand cette procedure sera appele en resiliation

    define variable viNumeroImmeuble     as integer no-undo.
    define variable viNumeroMandatSyndic as int64   no-undo.
    define variable vdSurface            as decimal no-undo.
    define variable viNoord              as integer no-undo.
    define variable vdaDernierAchatCopro as date    no-undo.

    define buffer ctrat for ctrat.
    define buffer vbttListeLotMutation for ttListeLotMutation.

    empty temp-table ttIntnt.
    viNumeroImmeuble = numeroImmeuble(ttMutation.iNumeroContrat, ttMutation.cTypeContrat).
    if mError:erreur() then return.

    viNumeroMandatSyndic = numeroMandatSyndic(viNumeroImmeuble).
    if ttMutation.daVente = ? then do:
        mError:createError({&error}, 1000577). //La date de vente est obligatoire
        return.
    end.
    if ttMutation.daAchat = ? then do:
        mError:createError({&error}, 1000576). //La date d'achat est obligatoire
        return.
    end.
    if ttMutation.daAchat >= today then do:
        mError:createError({&error}, 1000575). //La date d'achat (Notaire) doit être inférieure à la date du jour
        return.
    end.
    if ttMutation.daVente < today - 365 then do:
        mError:createError({&error}, 1000574). //Les mutations concernent des ventes futures. La date de vente saisie est trop ancienne (plus d'un an)
        return.
    end.
    if pcTypeTraitement = "RESILIATION" and pdaResiliation < ttMutation.daVente then do:
        mError:createError({&error}, 1000573). //La date de vente ne peut pas être postérieure à la date de résiliation du mandat
        return.
    end.
    if not can-find(first ttListeLotMutation
                    where ttListeLotMutation.cTypeContrat    = ttMutation.cTypeContrat
                      and ttListeLotMutation.iNumeroContrat  = ttMutation.iNumeroContrat
                      and ttListeLotMutation.iNumeroMutation = ttMutation.iNumeroMutation)
    then do:
        mError:createError({&error}, 101284). //Vous devez spécifier le ou les lots intervenant dans la TRANSACTION
        return.
    end.
    for each ttListeLotMutation
        where ttListeLotMutation.cTypeContrat    = ttMutation.cTypeContrat
          and ttListeLotMutation.iNumeroContrat  = ttMutation.iNumeroContrat
          and ttListeLotMutation.iNumeroMutation = ttMutation.iNumeroMutation
        by ttListeLotMutation.iNumeroUL by ttListeLotMutation.iNumerolot:
        if (ttListeLotMutation.iNumeroUL <> 997 and ttListeLotMutation.iNumeroUL <> 998)
        and can-find(first vbttListeLotMutation
                     where vbttListeLotMutation.cTypeContrat    = ttMutation.cTypeContrat
                       and vbttListeLotMutation.iNumeroContrat  = ttMutation.iNumeroContrat
                       and vbttListeLotMutation.iNumeroUL       = ttListeLotMutation.iNumeroUL
                       and vbttListeLotMutation.iNumeroMutation <> ttMutation.iNumeroMutation)
        then do:
            //Les lots d une même UL doivent tous être sélectionnés (UL &1)
            mError:createError({&error}, 1000571, string(ttListeLotMutation.iNumeroUL, "999")).
            return.
        end.
        for each acreg no-lock
            where acreg.tpmdt  = ttMutation.cTypeContrat
              and acreg.nomdt  = ttMutation.iNumeroContrat
              and acreg.tprol  = {&TYPEROLE-locataire}
              and acreg.norol  = ttListeLotMutation.iNumeroBail
              and acreg.tplig  = "0"
              and acreg.fgclot = "00002"
          , first ctrat no-lock
            where ctrat.tpcon = {&TYPECONTRAT-bail}
              and ctrat.nocon = ttListeLotMutation.iNumeroBail:
            //La vente de lots associés à un bail avec un accord de règlement n'est pas autorisée Bail &1 &2 accord de règlement du &3
            mError:createError({&error}, 1000569, substitute("&2&1&3&1&4", separ[1], ctrat.nocon, ctrat.lbnom, acreg.dtacr)).
            return.
        end.
        for each tache no-lock
            where tache.tpcon = {&TYPECONTRAT-bail}
              and tache.tptac = {&TYPETACHE-quittancement}
              and tache.cdreg = "22015"
              and tache.etab-cd = truncate(ttListeLotMutation.iNumeroBail / 100000, 0)
              and tache.cptg-cd = "4112"
              and tache.sscpt-cd = substring(string(ttListeLotMutation.iNumeroBail, "9999999999"), 6, 5, 'character')
          , first ctrat no-lock
            where ctrat.tpcon = tache.tpcon
              and ctrat.nocon = tache.nocon
              and ctrat.dtree = ?:
            //La vente de lots associés à un Locataire qui compense un autre locataire n'est pas autorisée Le locataire &1 &2 compense le locataire &3 - &4
            mError:createError({&error},
                               1000570,
                               substitute("&2&1&3&1&4&1&5",
                                                           separ[1], ttListeLotMutation.iNumeroBail, outilFormatage:getNomTiers({&TYPEROLE-locataire},
                                                           ttListeLotMutation.iNumeroBail), tache.nocon, outilFormatage:getNomTiers("00019", tache.nocon))).
            return.
        end.
        find first local no-lock
             where local.noimm = viNumeroImmeuble
               and local.nolot = ttListeLotMutation.iNumerolot no-error.
        if not available local
        then do:
            mError:createErrorGestion({&error}, 102093, substitute("&2&1&3", separ[1], ttListeLotMutation.iNumerolot, viNumeroImmeuble)).    //Lot %1 inconnu dans l'immeuble %2
            return.
        end.
        /* si immeuble de copro, la date de vente doit être > date d'achat pour chaque lot */
        if viNumeroMandatSyndic <> 0 then do:
            vdaDernierAchatCopro = ?.
            for each intnt no-lock
                where intnt.tpidt = {&TYPEBIEN-lot}
                  and intnt.noidt = local.noloc
                  and intnt.tpcon = {&TYPECONTRAT-titre2copro}
                  and intnt.nocon = viNumeroMandatSyndic * 100000 + piMandant
                  and intnt.nbden = 0
                by intnt.nbnum descending:
                vdaDernierAchatCopro = outils:convertionDate("yyyymmdd", string(intnt.nbnum)).
                leave.
            end.
            if vdaDernierAchatCopro <> ? and vdaDernierAchatCopro >= ttMutation.daVente
            then do:
                //Le lot &1 a été acheté le &2 , il ne peut donc pas être revendu le &3
                mError:createError(
                    {&error}, 1000572,
                    substitute("&2&1&3&1&4",
                               separ[1],
                               ttListeLotMutation.iNumerolot,
                               string(vdaDernierAchatCopro, "99/99/9999"),
                               string(ttMutation.daVente, "99/99/9999"))).
                return.
            end.
        end.
        assign
            vdSurface = 0
            viNoord   = 0
        .
        for first unite no-lock
            where unite.nomdt = ttMutation.iNumeroContrat
              and unite.noapp = ttListeLotMutation.iNumeroUL
              and unite.noact = 0
          , first cpuni no-lock
            where cpuni.nomdt = unite.nomdt
              and cpuni.noapp = unite.noapp
              and cpuni.nocmp = unite.nocmp
              and cpuni.noimm = local.noimm
              and cpuni.nolot = local.nolot:
            assign
                vdSurface = (if local.fgdiv then cpuni.sflot else 0)
                viNoord   = cpuni.noord
            .
        end.
        find first ttIntnt
            where ttIntnt.tpcon = {&TYPECONTRAT-mutationGerance}
              and ttIntnt.nocon = ttMutation.iNumeroContratMutation
              and ttIntnt.tpidt = {&TYPEBIEN-lot}
              and ttIntnt.noidt = local.noloc no-error.
        if not available ttIntnt then do:
            create ttIntnt.
            assign
                ttIntnt.tpcon = {&TYPECONTRAT-mutationGerance}
                ttIntnt.nocon = ttMutation.iNumeroContratMutation
                ttIntnt.tpidt = {&TYPEBIEN-lot}
                ttIntnt.noidt = local.noloc
                ttIntnt.idpre = 0
                ttIntnt.lbdiv = substitute("&1&4&2&4&3", string(ttListeLotMutation.iNumeroUL, "999"), vdSurface, viNoord, separ[2])
                ttIntnt.CRUD  = "C"
            .
        end.
        else ttIntnt.lbdiv = ttIntnt.lbdiv + separ[1] + substitute("&1&4&2&4&3", string(ttListeLotMutation.iNumeroUL, "999"), vdSurface, viNoord, separ[2]).
    end.
    if ttMutation.iNumeroAcheteur = piMandant then do:
        mError:createError({&error}, 108052). //le no ach doit etre <> no vendeur
        return.
    end.

end procedure.

procedure majMutation:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttMutation for ttMutation.
    define input parameter piMandant as integer no-undo.

    define variable vhCtrat       as handle    no-undo.
    define variable vhRole        as handle    no-undo.
    define variable vhCtctt       as handle    no-undo.
    define variable vhIntnt       as handle    no-undo.
    define variable viNumeroRole  as integer   no-undo.
    define variable vcRetourCtrl  as character no-undo.
    define variable vcMessageCtrl as character no-undo.
    define variable vrRowidTtMutation as rowid no-undo.
    define variable viNoDocSui as integer no-undo.
    define variable viNoConSui as int64   no-undo.

    /* MAJ Contrat mutation */
    empty temp-table ttCtrat.
    create ttCtrat.
    assign
        ttCtrat.CRUD        = ttMutation.CRUD
        ttCtrat.dtsig       = ttMutation.daVente
        ttCtrat.dtdeb       = ttMutation.daAchat
        ttCtrat.tprol       = {&TYPEROLE-vendeur}
        ttCtrat.norol       = piMandant
        ttCtrat.lbnom       = outilFormatage:getNomTiers({&TYPEROLE-vendeur}, piMandant)
        ttCtrat.lnom2       = outilFormatage:getCiviliteNomTiers({&TYPEROLE-vendeur}, piMandant, no)         //remplace appel formTie9.p
        ttCtrat.tprol-ach   = {&TYPEROLE-acheteur}
        ttCtrat.norol-ach   = ttMutation.iNumeroAcheteur
        ttCtrat.nomdt-ach   = ttMutation.iNumeroMandatAcheteur
        vrRowidTtMutation   = rowid(ttMutation)
    .
    run adblib/ctrat_CRUD.p persistent set vhCtrat.
    run getTokenInstance in vhCtrat(mToken:JSessionId).
    //en creation calcul du numero de contrat (le numero de contrat est constitue du numero de mandat + 1 sequence pour numero de mutation et
    //la procedure de creation dans ctrat_CRUD.p ne permet pas ce calcul
    if ttMutation.CRUD = "C"
    then do:
        run getNextContrat in vhCtrat({&TYPECONTRAT-mutationGerance}, ttMutation.iNumeroContrat, 0, output viNoDocSui, output viNoConSui).
        if mError:erreur()
        then do:
            run destroy in vhCtrat.
            return.
        end.
        assign
            ttCtrat.nodoc  = viNoDocSui
            ttCtrat.tpcon  = {&TYPECONTRAT-mutationGerance}
            ttCtrat.nocon  = viNoConSui
            ttCtrat.ntcon  = ""
            ttCtrat.fgprov = yes
        .
        //mise a jour du numero de contrat de mutation sur la table temporaire des lots a rattacher (creation de cette table dans la procedure de controle)
        if ttMutation.CRUD = "C"
        then for each ttIntnt
                where ttIntnt.tpcon = {&TYPECONTRAT-mutationGerance}
                  and ttIntnt.nocon = ttMutation.iNumeroContratMutation
                  and ttIntnt.tpidt = {&TYPEBIEN-lot}:
            ttIntnt.nocon = viNoConSui.
        end.
        ttMutation.iNumeroContratMutation = viNoConSui.
    end.
    else assign
             ttCtrat.nocon       = ttMutation.iNumeroContratMutation
             ttCtrat.dtTimestamp = ttMutation.dtTimestamp
             ttCtrat.rRowid      = ttMutation.rRowid
    .
    run setCtrat in vhCtrat(table ttCtrat by-reference).
    run destroy  in vhCtrat.
    if mError:erreur() then return.

    /*--> Creation du role Vendeur si non existant */
    if not can-find(first roles no-lock
                    where roles.tprol = {&TYPEROLE-vendeur}
                      and roles.norol = piMandant)
    then do:
        run role/roles_CRUD.p persistent set vhRole.
        run getTokenInstance in vhRole(mToken:JSessionId).
        run dupliRoles in vhRole ({&TYPEROLE-mandant}, piMandant, {&TYPEROLE-vendeur}, yes, output viNumeroRole).
    end.
    /*--> Creation du role Acheteur si non existant */
    if ttMutation.iNumeroAcheteur > 0
    and not can-find(first roles no-lock
                     where roles.tprol = {&TYPEROLE-acheteur}
                       and roles.norol = ttMutation.iNumeroAcheteur)
    then do:
        if not valid-handle(vhRole) then do:
            run role/roles_CRUD.p persistent set vhRole.
            run getTokenInstance in vhRole(mToken:JSessionId).
        end.
        run dupliRoles in vhRole ({&TYPEROLE-mandant}, ttMutation.iNumeroAcheteur , {&TYPEROLE-acheteur}, yes, output viNumeroRole).
    end.
    if valid-handle(vhRole) then run destroy in vhRole.
    /*--> Creation du lien ctctt */
    if not can-find(first ctctt no-lock
                    where ctctt.tpct1 = ttMutation.cTypeContrat
                      and ctctt.noct1 = ttMutation.iNumeroContrat
                      and ctctt.tpct2 = {&TYPECONTRAT-mutationGerance}
                      and ctctt.noct2 = ttMutation.iNumeroContratMutation)
    then do:
        empty temp-table ttCtctt.
        create ttCtctt.
        assign
            ttCtctt.tpct1 = ttMutation.cTypeContrat
            ttCtctt.noct1 = ttMutation.iNumeroContrat
            ttCtctt.tpct2 = {&TYPECONTRAT-mutationGerance}
            ttCtctt.noct2 = ttMutation.iNumeroContratMutation
            ttCtctt.CRUD  = "C"
        .
        run adblib/ctctt_CRUD.p persistent set vhCtctt.
        run getTokenInstance in vhCtctt(mToken:JSessionId).
        run setCtctt in vhCtctt(table ttCtctt by-reference).
        run destroy in vhCtctt.
        if mError:erreur() then return.
    end.
    /*--> Creation du lien Vendeur */
    if not can-find(first intnt no-lock
                    where intnt.tpcon = {&TYPECONTRAT-mutationGerance}
                      and intnt.nocon = ttMutation.iNumeroContratMutation
                      and intnt.tpidt = {&TYPEROLE-vendeur})
    then do:
        create ttIntnt.
        assign
            ttIntnt.tpcon = {&TYPECONTRAT-mutationGerance}
            ttIntnt.nocon = ttMutation.iNumeroContratMutation
            ttIntnt.tpidt = {&TYPEROLE-vendeur}
            ttIntnt.noidt = piMandant
            ttIntnt.CRUD  = "C"
        .
    end.
    for each intnt no-lock
       where intnt.tpcon = {&TYPECONTRAT-mutationGerance}
         and intnt.nocon = ttMutation.iNumeroContratMutation
         and intnt.tpidt = {&TYPEROLE-acheteur}
         and intnt.noidt <> ttMutation.iNumeroAcheteur:
        create ttIntnt.
        assign
            ttIntnt.tpcon  = {&TYPECONTRAT-mutationGerance}
            ttIntnt.nocon  = ttMutation.iNumeroContratMutation
            ttIntnt.tpidt  = {&TYPEROLE-acheteur}
            ttIntnt.noidt  = intnt.noidt
            ttIntnt.nbnum  = intnt.nbnum
            ttIntnt.idpre  = intnt.idpre
            ttIntnt.idsui  = intnt.idsui
            ttIntnt.CRUD   = "D"
            ttIntnt.rRowid = rowid(intnt)
            ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)            
        .
    end.
    if ttMutation.iNumeroAcheteur > 0
    and not can-find (first intnt no-lock
                      where intnt.tpcon = {&TYPECONTRAT-mutationGerance}
                        and intnt.nocon = ttMutation.iNumeroContratMutation
                        and intnt.tpidt = {&TYPEROLE-acheteur}
                        and intnt.noidt = ttMutation.iNumeroAcheteur)
    then do:
        create ttIntnt.
        assign
            ttIntnt.tpcon = {&TYPECONTRAT-mutationGerance}
            ttIntnt.nocon = ttMutation.iNumeroContratMutation
            ttIntnt.tpidt = {&TYPEROLE-acheteur}
            ttIntnt.noidt = ttMutation.iNumeroAcheteur
            ttIntnt.CRUD  = "C"
        .
    end.
    /*--> Suppression des liens Lots (pour la creation des liens lots, la table ttIntnt a été initialise dans la procedure ctrlAvantMaj */
    for each intnt no-lock
       where intnt.tpcon = {&TYPECONTRAT-mutationGerance}
         and intnt.nocon = ttMutation.iNumeroContratMutation
         and intnt.tpidt = {&TYPEBIEN-lot}:
        create ttIntnt.
        assign
            ttIntnt.tpcon  = {&TYPECONTRAT-mutationGerance}
            ttIntnt.nocon  = ttMutation.iNumeroContratMutation
            ttIntnt.tpidt  = {&TYPEBIEN-lot}
            ttIntnt.noidt  = intnt.noidt
            ttIntnt.nbnum  = intnt.nbnum
            ttIntnt.idpre  = intnt.idpre
            ttIntnt.idsui  = intnt.idsui
            ttIntnt.CRUD   = "D"
            ttIntnt.rRowid = rowid(intnt)
            ttIntnt.dtTimestamp = datetime(intnt.dtmsy, intnt.hemsy)
        .
    end.
    run adblib/intnt_CRUD.p persistent set vhIntnt.
    run getTokenInstance in vhIntnt(mToken:JSessionId).
    run setIntnt in vhIntnt(table ttIntnt by-reference).
    run destroy in vhIntnt.
    if mError:erreur() then return.

    for each ttIntnt no-lock
       where ttIntnt.tpcon = {&TYPECONTRAT-mutationGerance}
         and ttIntnt.nocon = ttMutation.iNumeroContratMutation
         and ttIntnt.tpidt = {&TYPEROLE-acheteur}
         and ttIntnt.CRUD   = "D":
        ghProc = lancementPgm("adblib/ctsuprol.p", goCollectionHandlePgm).
        run controleRole in ghProc(table ttError by-reference, {&TYPEROLE-acheteur}, ttIntnt.noidt, no, "", ?, output vcRetourCtrl, output vcMessageCtrl).
        if vcRetourCtrl = "00"
        then do:
            ghProc = lancementPgm("adblib/suprol01.p", goCollectionHandlePgm).
            run suppressionRole in ghProc({&TYPEROLE-acheteur}, ttIntnt.noidt, "", input-output goCollectionHandlePgm).
            if mError:erreur() then return.
        end.
    end.

end procedure.
