/*------------------------------------------------------------------------
File        : adresse.p
Purpose     :
Author(s)   : LGI/NPO - 2016/12/16
Notes       :
derniere revue: 2018/05/22 - phm: KO
        traiter les todo
------------------------------------------------------------------------*/
{preprocesseur/nature2voie.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{adresse/include/adresse.i &nomTable=ttAdresse}
{adresse/include/codePostal.i}
{adresse/include/moyenCommunication.i}
{adresse/include/coordonnee.i}

define variable ghProcMoyen   as handle no-undo. // getCoordonneLot peut être lancé en externe ou a partir de getCoordonneLots

function lDansAdresses returns logical (pcRecherche as character, pcTypeRole as character, piNumeroRole as integer):
    /*------------------------------------------------------------------------------
    Purpose: Cherche une entrée dans adresse correspondante aux paramètres donnés.
    Notes:
    TODO : fonction dupliquée dans lot.p. A positionner dans un outillage d'adresse ?
    ------------------------------------------------------------------------------*/
    define variable vlAdresseOK as logical   no-undo.
    define variable vcAdresse   as character no-undo.
    define variable viBoucle    as integer   no-undo.
    define buffer ladrs for ladrs.

    /* Balayage des adresses du role */
    for each ladrs no-lock
        where ladrs.tpidt = pcTypeRole
          and ladrs.noidt = piNumeroRole:
        assign
            vcAdresse   = outilFormatage:formatageAdresse(pcTypeRole, piNumeroRole, ladrs.nolie)
            vlAdresseOK = true
        .
boucle:
        do viBoucle = 1 to num-entries(pcRecherche, " ") while vlAdresseOK:
            if not vcAdresse matches substitute('*&1*', entry(viBoucle, pcRecherche, " "))
            then do:
                vlAdresseOK = false.
                leave boucle.
            end.
        end.
        if vlAdresseOK then return true.
    end.
    return false.

end function.

function f_AdresseContrat returns character (pcTypeContrat-In as character, piNumeroContrat-IN as int64):
    /*------------------------------------------------------------------------------
    Purpose: Adresse immeuble
    Notes:  service utilisé dans role.p
    ------------------------------------------------------------------------------*/
    define variable vcLibImmeuble     as character no-undo.
    define variable vcAdresseFormatee as character no-undo.

    define buffer ctrat for ctrat.
    define buffer ctctt for ctctt.
    define buffer intnt for intnt.
    define buffer imble for imble.

    /* Information contrat */
    for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat-In
          and ctrat.nocon = piNumeroContrat-In:
        case ctrat.tpcon:
            when {&TYPECONTRAT-mutation} or when {&TYPECONTRAT-titre2copro}
            then for each ctctt no-lock
                where ctctt.tpct1 = {&TYPECONTRAT-mandat2Syndic}
                  and ctctt.tpct2 = ctrat.tpcon
                  and ctctt.noct2 = ctrat.nocon
              , each intnt no-lock
                where intnt.tpcon = ctctt.tpct1
                  and intnt.nocon = ctctt.noct1
                  and intnt.tpidt = {&TYPEBIEN-immeuble}
              , first imble no-lock
                where imble.noimm = intnt.noidt:
                assign
                    vcLibImmeuble     = imble.lbnom
                    vcAdresseFormatee = outilFormatage:formatageAdresse({&TYPEBIEN-immeuble}, imble.noImm)
                .
                {&_proparse_ prolint-nowarn(blocklabel)}
                leave.
            end.
            otherwise for each intnt no-lock
                where intnt.tpcon = pcTypeContrat-In
                  and intnt.nocon = piNumeroContrat-IN
                  and intnt.tpidt = {&TYPEBIEN-immeuble}
              , first imble no-lock
                where imble.noimm = intnt.noidt:
                assign
                    vcLibImmeuble     = imble.lbnom
                    vcAdresseFormatee = outilFormatage:formatageAdresse({&TYPEBIEN-immeuble}, imble.noImm)
                .
                {&_proparse_ prolint-nowarn(blocklabel)}
                leave.
            end.
        end case.
        return replace(trim(if vcLibImmeuble > "" then vcLibImmeuble + " - " else "") + vcAdresseFormatee, "  ", " ").
    end.
    return "".

end function.

procedure getAdresseSelection:
    /*------------------------------------------------------------------------------
    Purpose: Récupère les adresses d'une selection de iNumeroBien
    Notes:  service utilisé par beLot.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeIdentifiant   as character no-undo.
    define input  parameter pcCodeTypeAdresse   as character no-undo.
    define input  parameter pcJointure          as character no-undo.
    define input  parameter table-handle phttListe.
    define output parameter table for ttAdresse.
    define output parameter table for ttCoordonnee.
    define output parameter table for ttMoyenCommunication.

    define variable vhbtt       as handle    no-undo.
    define variable vhqtt       as handle    no-undo.

    run adresse/moyenCommunication.p persistent set ghProcMoyen.
    run getTokenInstance in ghProcMoyen(mToken:JSessionId).
    vhbtt = phttListe:default-buffer-handle.
    create query vhqtt.
    vhqtt:set-buffers(vhbtt).
    vhqtt:query-prepare(substitute('for each &1', vhbtt:name)).
    vhqtt:query-open().
blocRepeat1:
    repeat:
        vhqtt:get-next().
        if vhqtt:query-off-end then leave blocRepeat1.
        run getAdresse(pcTypeIdentifiant, vhbtt::iNumeroBien, pcCodeTypeAdresse, pcJointure
                     , output table ttAdresse by-reference
                     , output table ttCoordonnee by-reference
                     , output table ttMoyenCommunication by-reference).
    end.
    vhqtt:query-close() no-error.
    delete object vhqtt no-error.
    delete object vhbtt no-error.
    run destroy in ghProcMoyen.
    assign error-status:error = false no-error. /* reset error-status */
    return.                                     /* reset return-value */

end procedure.

procedure getAdresse:
    /*--------------------------------------------------------------------------
    Purpose:
    Note   : service de récupération d'adresse (commercialisation.p, ...)
    ---------------------------------------------------------------------------*/
    define input  parameter pcTypeIdentifiant   as character no-undo.
    define input  parameter piNumeroIdentifiant as integer   no-undo.
    define input  parameter pcCodeTypeAdresse   as character no-undo.
    define input  parameter pcJointure          as character no-undo.
    define output parameter table for ttAdresse.
    define output parameter table for ttCoordonnee.
    define output parameter table for ttMoyenCommunication.

    run getAdresseInterne(pcTypeIdentifiant, piNumeroIdentifiant, pcCodeTypeAdresse, pcJointure).

end procedure.

procedure getAdresseInterne private:
    /*--------------------------------------------------------------------------
    Purpose:
    Note   : 
    ---------------------------------------------------------------------------*/
    define input  parameter pcTypeIdentifiant   as character no-undo.
    define input  parameter piNumeroIdentifiant as integer   no-undo.
    define input  parameter pcCodeTypeAdresse   as character no-undo.
    define input  parameter pcJointure          as character no-undo.

    define variable vlDejaLancee as logical no-undo initial true.

    define buffer ladrs for ladrs.
    define buffer adres for adres.

    if not valid-handle(ghProcMoyen)
    then do:
        run adresse/moyenCommunication.p persistent set ghProcMoyen.
        run getTokenInstance in ghProcMoyen(mToken:JSessionId).
        vlDejaLancee = false.
    end.

    for each ladrs no-lock
        where ladrs.tpidt = pcTypeIdentifiant
          and ladrs.noidt = piNumeroIdentifiant
          and ladrs.tpadr = (if pcCodeTypeAdresse > "" then pcCodeTypeAdresse else ladrs.tpadr)
      , first adres no-lock
        where adres.noadr = ladrs.noadr:
        create ttAdresse.
        assign
            ttAdresse.CRUD                    = 'R'
            ttAdresse.iNumeroLien             = ladrs.nolie
            ttAdresse.cJointure               = pcJointure
            ttAdresse.cTypeIdentifiant        = pcTypeIdentifiant
            ttAdresse.iNumeroIdentifiant      = piNumeroIdentifiant
            ttAdresse.cCodeTypeAdresse        = ladrs.tpadr
            ttAdresse.cLibelleTypeAdresse     = outilTraduction:getLibelleParam("TPADR", ladrs.tpadr)
            ttAdresse.cCodeFormat             = ladrs.tpfrt
            ttAdresse.cLibelleFormat          = outilTraduction:getLibelleParam("FTADR", ladrs.tpfrt)
            ttAdresse.cIdentification         = adres.cpad2
            ttAdresse.cNumeroVoie             = trim(ladrs.novoi)
            ttAdresse.cCodeNumeroBis          = ladrs.cdadr
            ttAdresse.cLibelleNumeroBis       = outilTraduction:getLibelleParam("CDADR", ladrs.cdadr)
            ttAdresse.cLibelleNumeroBisCourt  = outilTraduction:getLibelleParam("CDADR", ladrs.cdadr, 'c')
            ttAdresse.cCodeNatureVoie         = adres.ntvoi
            ttAdresse.cLibelleNatureVoie      = if adres.ntvoi = {&NATUREVOIE--} then "" else outilTraduction:getLibelleParam("NTVOI", adres.ntvoi)
            ttAdresse.cLibelleNatureVoieCourt = if adres.ntvoi = {&NATUREVOIE--} then "" else outilTraduction:getLibelleParam("NTVOI", adres.ntvoi, 'c')
            ttAdresse.cNomVoie                = adres.lbvoi
            ttAdresse.cComplementVoie         = adres.cpvoi
            ttAdresse.cCodePostal             = trim(adres.cdpos)
            ttAdresse.cBureauDistributeur     = adres.lbbur
            ttAdresse.cVille                  = trim(adres.lbvil)
            ttAdresse.cCodeINSEE              = adres.cdins
            ttAdresse.cCodePays               = adres.cdpay
            ttAdresse.cLibellePays            = outilTraduction:getLibelleParam("CDPAY", adres.cdpay)
            ttAdresse.cLibelle                = outilFormatage:formatageAdresse(ladrs.tpidt, ladrs.noidt, ladrs.tpadr, mToken:iCodeLangueSession, mToken:iCodeLangueReference)
            ttAdresse.dtTimestampAdres        = datetime(adres.dtmsy, adres.hemsy)
            ttAdresse.dtTimestampLadrs        = datetime(ladrs.dtmsy, ladrs.hemsy)
            ttAdresse.rRowid                  = rowid(adres)
        .
    end.
    run getMoyenCommunication in ghProcMoyen (pcTypeIdentifiant, piNumeroIdentifiant, pcJointure, output table ttMoyenCommunication by-reference).

    if can-find(first ttMoyenCommunication) then do:
        create ttCoordonnee.
        assign
            ttCoordonnee.iNumeroIdentifiant = piNumeroIdentifiant
            ttCoordonnee.cJointure          = pcJointure
        .
    end.
    if not vlDejaLancee then run destroy in ghProcMoyen.

end procedure.

procedure setAdresseTiersCommercial:
    /*------------------------------------------------------------------------------
    Purpose: mise à jour table TELEPHONES / ttAdresse pour les tiers de la fiche commerciale
    Notes  : service utilisé par beCommercialisation.cls
             Pas de moyen de savoir si TIERS = IFOUR ou ROLES donc on lance les 2
    ------------------------------------------------------------------------------*/
    define input parameter table for ttAdresse.

    define variable vhProcFournisseur as handle no-undo.

    if can-find(first ttAdresse where ttAdresse.cTypeIdentifiant = "FOU")
    then do:
        run "tiers/fournisseur.p" persistent set vhProcFournisseur.
        run getTokenInstance in vhProcFournisseur(mToken:JSessionId).
        run setAdresseFournisseur in vhProcFournisseur (table ttAdresse by-reference).
        run destroy in vhProcFournisseur.
    end.
    if can-find(first ttAdresse where ttAdresse.cTypeIdentifiant <> "FOU")
    then run setAdresseTiersGestion.

end procedure.

procedure setAdresseTiersGestion private:
    /*----------------------------------------------------------------------------------
    Purpose: mise à jour table LADRS-ADRES / ttAdresse pour l'adresse de la fiche Tiers
    Notes  :
    TODO   : A quoi cela sert-il? Si ce ne sont que des contrôles, renommer la procédure.
    ------------------------------------------------------------------------------------*/

message "setAdresseTiersGestion".

    find first ttAdresse where ttAdresse.CRUD <> "R" no-error.
    if not available ttAdresse then return.

    /*--> Contrôles **/
    if not can-find(first roles no-lock
                    where roles.tprol = ttAdresse.cTypeIdentifiant
                      and roles.norol = ttAdresse.iNumeroIdentifiant)
    then do:
        mError:createError({&error}, 999999, ttAdresse.cTypeIdentifiant + string(ttAdresse.iNumeroIdentifiant)).   /* Role &1 inexistant */
        return.
    end.

end procedure.

procedure getCodePostaux:
    /*------------------------------------------------------------------------------
      Purpose: Récupération de la liste des codes postaux
      Notes  : service?
      TODO   : procédure non utilisée !?
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCodePostal.

    define buffer tbpos for tbpos.

    for each tbpos no-lock
       where tbpos.cdpos > "":
        create ttCodePostal.
        assign
            ttCodePostal.cCodePostal      = tbpos.cdpos
            ttCodePostal.cLibelleVille    = tbpos.lbvil
            ttCodePostal.cCodeDepartement = tbpos.cddep
            ttCodePostal.cLibelleDivers   = tbpos.lbdiv
        .
    end.
end procedure.

procedure miroir_Adresse:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service?
    TODO   : procédure non utilisée !?
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiantRef   as character no-undo.
    define input parameter piNumeroIdentifiantRef as int64     no-undo.
    define input parameter pcTypeIdentifiantMir   as character no-undo.
    define input parameter piNumeroIdentifiantMir as int64     no-undo.

    define variable viNextLien as integer   no-undo.

    define buffer ladrs      for ladrs.
    define buffer vbRefLadrs for ladrs.
    define buffer vbMirLadrs for ladrs.

    /* Ajout Sy le 13/10/2015: Pb doublon adresse Bailleur, ne pas créer de lien adresse si le role bailleur n'a pas encore été créé */
    if not can-find(first roles no-lock
                    where roles.tprol = pcTypeIdentifiantMir
                      and roles.norol = piNumeroIdentifiantMir) then return.

    repeat preselect each vbRefLadrs no-lock
        where vbRefLadrs.tpidt = pcTypeIdentifiantRef
          and vbRefLadrs.noidt = piNumeroIdentifiantRef:
        {&_proparse_ prolint-nowarn(noerror)}
        find next vbRefLadrs.    // pas de no-error sur un preselect, A rajouter dans la règle noerror
        /* remarque : ne marche que si une seule adresse par type... */
        {&_proparse_ prolint-nowarn(nowait)}
        find first vbMirLadrs exclusive-lock
             where vbMirLadrs.tpidt = pcTypeIdentifiantMir
               and vbMirLadrs.noidt = piNumeroIdentifiantMir
               and vbMirLadrs.tpadr = vbRefLadrs.tpadr no-error.
        if not available vbMirLadrs then do:
            {&_proparse_ prolint-nowarn(wholeindex)}
            find last ladrs no-lock no-error.
            viNextLien = if available ladrs then ladrs.NoLie + 1 else 1.
            create vbMirLadrs.
            buffer-copy vbRefLadrs
                 except nolie tpidt noidt dtcsy hecsy cdcsy
                     to vbMirLadrs
                 assign
                 vbMirLadrs.NoLie = viNextLien
                 vbMirLadrs.tpidt = pcTypeIdentifiantMir
                 vbMirLadrs.noidt = piNumeroIdentifiantMir
                 vbMirLadrs.dtcsy = today
                 vbMirLadrs.hecsy = time
                 vbMirLadrs.cdcsy = substitute('&1@saiadr00_srv.p@Miroir_Adresse', mtoken:cUser)
            .
        end.
        else buffer-copy vbRefLadrs
                  except nolie tpidt noidt dtcsy hecsy cdcsy
                      to vbMirLadrs.
    end.

    for each vbMirLadrs exclusive-lock
        where vbMirLadrs.tpidt = pcTypeIdentifiantMir
          and vbMirLadrs.noidt = piNumeroIdentifiantMir
          and not can-find(first vbRefLadrs no-lock
                           where vbRefLadrs.tpidt = pcTypeIdentifiantRef
                             and vbRefLadrs.noidt = piNumeroIdentifiantRef
                             and vbRefLadrs.tpadr = vbMirLadrs.tpadr):
        delete vbMirLadrs.
    end.
end procedure.

procedure MajImmCpta:
    /*------------------------------------------------------------------------------
    Purpose: remplacer les run prcRunCo !!
    Notes  : service?
    TODO   : procédure non utilisée !?
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeIdentifiant   as character no-undo.
    define input parameter piNumeroIdentifiant as int64     no-undo.
    define input parameter pcTypeContrat       as character no-undo.
    define input parameter pcTypeAction        as character no-undo.

    define variable vlMandatGerance as logical no-undo.
    define variable vlMandatSyndic  as logical no-undo.

    assign
        vlMandatGerance = can-find(first intnt no-lock
                                   where intnt.tpidt = pcTypeIdentifiant
                                     and intnt.noidt = piNumeroIdentifiant
                                     and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance})
        vlMandatSyndic = can-find(first intnt no-lock
                                  where intnt.tpidt = pcTypeIdentifiant
                                    and intnt.noidt = piNumeroIdentifiant
                                    and intnt.tpcon = {&TYPECONTRAT-mandat2Syndic})
    .
    // Si on a bien un Mandat de Gestion rattaché
    if pcTypeContrat = {&TYPECONTRAT-mandat2Gerance} or vlMandatGerance
    then run prcRunLi("00001", 'saiad', '02001', piNumeroIdentifiant, 0 ,"0", 0, 0, 0).

    // Si on a bien un Mandat de Syndic rattaché
    if (pcTypeContrat = {&TYPECONTRAT-mandat2Syndic} or vlMandatSyndic) and pcTypeAction <> "00" and pcTypeAction <> "01"
    then run PrcRunCo("00001", 'saiad', '02001', piNumeroIdentifiant, 0, "0", 0, 0, 0).

end procedure.
