/*------------------------------------------------------------------------
File        : tiers_CRUD.p
Purpose     : Librairie contenant les procedures liées à la mise à jour de la table tiers
Author(s)   : generation automatique le 01/31/18
Notes       : permet de travailler sur un sous ensemble de colonnes de la table à condition
              que les champs de l'index unique soient tous présents.
------------------------------------------------------------------------*/

using parametre.pclie.parametrageFournisseurLoyer.
{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using
{application/include/error.i}
define variable ghtttiers as handle no-undo.      // le handle de la temp table à mettre à jour
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/mode2gestionFournisseurLoyer.i}
{tiers/include/tiers.i}
{adb/include/liensAdbCompta.i}
{outils/include/lancementProgramme.i}

function getIndexField returns logical private(phBuffer as handle, output phNotie as handle):
    /*------------------------------------------------------------------------------
    Purpose: récupère les handles des n champs de l'index unique
    Notes: si la temp-table contient un mapping de label sur notie,
           il faut mapper les champs dynamiques
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to phBuffer:num-fields:
        case phBuffer:buffer-field(vi):label:
            when 'notie' then phNotie = phBuffer:buffer-field(vi).
       end case.
    end.
end function.

function getNextTiers returns int64 private():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer tiers for tiers.

    return next-value(sq_notie01).

end function.

function numeroImmeuble return int64 private(piNumeroContrat as int64, pcTypeContrat as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche immeuble du mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock
        where intnt.tpcon = pcTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        return intnt.noidt.
    end.
    return 0.

end function.

function controleTiers returns character (piNumeroTiers as int64, plAfficheMessage as logical):
    /*------------------------------------------------------------------------------
    Purpose: Contrôle si on peut supprimer un tiers
    Notes  : Service externe - Ancien adb/lib/ctsuptie.p
             Peut être appelé directement avec un numéro de tiers (par ex. depuis suprol01.p),
             ou en passant par le crud de la table temporaire par la procédure controleDeleteTiers (par ex. depuis tiers.p)
    ------------------------------------------------------------------------------*/

    {application/include/glbsepar.i}
    define variable vcMessageErreur as character no-undo.

    define buffer vbRoles for roles.
    define buffer litie   for litie.
    define buffer tache   for tache.

    /* Le tiers ne doit pas avoir de role */
    for first vbRoles no-lock
        where vbRoles.notie = piNumeroTiers:
        if plAfficheMessage then do:
            /* suppression impossible. Le tiers %1 est rattache au role %2 */
            vcMessageErreur = outilTraduction:getLibelle(104432) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(108482),
                                                           substitute('&2&1&3 n°&4', separ[1], piNumeroTiers, outilTraduction:getLibelleProg("O_ROL", vbRoles.tprol), vbRoles.norol)).
            mError:createError({&error}, vcMessageErreur).
        end.
        return "01".
    end.
    /* Le tiers ne doit pas faire partie d'un couple */
    for first litie no-lock
        where litie.noind = piNumeroTiers:
        if plAfficheMessage then do:
            /* suppression impossible. Le tiers %1 est rattache au couple %2 */
            vcMessageErreur = outilTraduction:getLibelle(104432) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(109053),
                                                           substitute('&2&1&3', separ[1], piNumeroTiers, litie.notie)).
            mError:createError({&error}, vcMessageErreur).
        end.
        return "02".
    end.
    /* Il ne doit pas être rattaché à un BIP immeuble */
    for first tache no-lock
        where tache.tpcon = {&TYPECONTRAT-construction}
          and tache.tptac = {&TYPETACHE-cleMagnetiqueDetails}
          and integer(tache.pdges) = piNumeroTiers:
        if plAfficheMessage then do:
            /* suppression impossible. Le tiers %1 est propriétaire d'une carte magnétique de l'immeuble %2*/
            vcMessageErreur = outilTraduction:getLibelle(104432) + "," +
                              outilFormatage:fSubstGestion(outilTraduction:getLibelle(110043),
                                                           substitute('&2&1&3', separ[1], piNumeroTiers, numeroImmeuble(tache.nocon, tache.tpcon))).
            mError:createError({&error}, vcMessageErreur).
        end.
        return "03".
    end.

    return "00".

end function.

function miseAJourContratsduTiers return logical private (piNumeroTiers as integer):
/*------------------------------------------------------------------------------
  Purpose:
  Notes:       Ancienne procédure MajTtCtt dans l_tiers_ext.p
------------------------------------------------------------------------------*/

    define variable vcNomTiers                      as character    no-undo case-sensitive.
    define variable VcCiviliteNomTiers              as character    no-undo case-sensitive.
    define variable vcCodeModeleFournisseurLoyer    as character    no-undo.
    define variable NoRetUse                        as integer      no-undo.
    define variable voFournisseurLoyer              as class parametrageFournisseurLoyer no-undo.
    define buffer vbRoles for roles.
    define buffer vbCtrat for ctrat.
    define buffer ietab for ietab.
    define buffer intnt for intnt.

    assign
    vcNomTiers                      = outilFormatage:getNomTiers(piNumeroTiers)
    VcCiviliteNomTiers              = outilFormatage:getCiviliteNomTiers({&TYPEROLE-Tiers}, piNumeroTiers, no)
    voFournisseurLoyer              = new parametrageFournisseurLoyer()
    vcCodeModeleFournisseurLoyer    = voFournisseurLoyer:getCodeModele()
    .
    for each vbRoles no-lock
        where vbRoles.notie = piNumeroTiers:
        for each ctrat no-lock
            where   ctrat.tprol = vbRoles.tprol
            and     ctrat.norol = vbRoles.norol:
            // Inutile de remettre à jour le contrat si le titre/nom/prénom/ du tiers n'a pas changé
            if ctrat.lbnom <> vcNomTiers or ctrat.lnom2 <> VcCiviliteNomTiers then
                for first vbCtrat exclusive-lock
                    where vbCtrat.NoDoc = ctrat.nodoc:
                    for first ietab exclusive-lock
                        where ietab.soc-cd = mToken:getSociete(vbCtrat.tpcon)
                        and   ietab.etab-cd = vbCtrat.nocon:
                        if vbCtrat.lbnom ne "" and ietab.lbrech ne "" then ietab.lbrech = replace(ietab.lbrech,vbCtrat.lbnom,vcNomTiers).
                    end.
                    assign
                        vbCtrat.lbnom = vcNomTiers
                        vbCtrat.lnom2 = VcCiviliteNomTiers
                        .
                end.
        end.
        if vbRoles.tprol = {&TYPEROLE-Locataire} then
            run miseAJourGeranceVersCompta("00002",'CODE',vbRoles.tprol,piNumeroTiers,trunc(vbRoles.norol / 100000,0),vbRoles.tprol,vbRoles.norol,0,0).
        else if vbRoles.tprol = {&TYPEROLE-Mandant} then
            for each intnt no-lock
                where intnt.tpidt = vbRoles.tprol
                and   intnt.noidt = vbRoles.norol
                and   intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}:
                run miseAJourGeranceVersCompta("00002",'CODE',vbRoles.tprol,piNumeroTiers,intnt.nocon,vbRoles.tprol,vbRoles.norol,0,0).
            end.
        else if vbRoles.tprol = {&TYPEROLE-coIndivisaire} then
            for each intnt no-lock
                where intnt.tpidt = vbRoles.tprol
                and   intnt.noidt = vbRoles.norol
                and   intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}:
                run miseAJourGeranceVersCompta("00002","CODE",vbRoles.tprol,piNumeroTiers,intnt.nocon,vbRoles.tprol,vbRoles.norol,intnt.nbnum,intnt.nbden).
            end.
        else if vbRoles.tprol = {&TYPEROLE-coproprietaire} then
            for each intnt no-lock
                where intnt.tpidt = vbRoles.tprol
                and   intnt.noidt = vbRoles.norol
                and   intnt.tpcon = {&TYPECONTRAT-titre2copro}:
                run miseAJourCoproprieteVersCompta("00003",'CODE',vbRoles.tprol,piNumeroTiers,trunc(intnt.nocon / 100000,0),vbRoles.tprol,vbRoles.norol,0,0).
            end.
    end.
    // pas mde maj compta societe si modele Eurostudiomes
    if voFournisseurLoyer:isGesFournisseurLoyer() 
    and (vcCodeModeleFournisseurLoyer = {&MODELE-ResidenceLocative-ComptaSociete} or vcCodeModeleFournisseurLoyer = {&MODELE-LotIsole-ComptaSociete})
    then 
        for each vbRoles no-lock
            where   vbRoles.tprol = {&TYPEROLE-Bailleur}
            and     vbRoles.notie = piNumeroTiers:
            // Lien ADB => Compta SOCIETE
            run lanceMiseAJourFournisseursLoyerCompta (input {&TYPEROLE-Bailleur}
                                                     , input vbRoles.norol
                                                     , output NoRetUse).
            if vcCodeModeleFournisseurLoyer = {&MODELE-LotIsole-ComptaSociete} then leave. // lots isoles : no four = no tiers
        end.

    delete object voFournisseurLoyer.

    return true.

end function.

procedure crudTiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTiers.
    run updateTiers.
    run createTiers.
end procedure.

procedure setTiers:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTiers.
    define input parameter table for ttError.
    ghttTiers = phttTiers.
    run crudTiers.
    delete object phttTiers.
end procedure.

procedure crudTiersSansConfirmationMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    run deleteTiersSansConfirmationMaj.
    run updateTiers.
    run createTiers.
end procedure.

procedure setTiersSansConfirmationMaj:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTiers.
    ghttTiers = phttTiers.
    run crudTiersSansConfirmationMaj.
    delete object phttTiers.
end procedure.

procedure readTiers:
    /*------------------------------------------------------------------------------
    Purpose: Lecture d'un enregistrement de la table tiers
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNotie as int64      no-undo.
    define input parameter table-handle phttTiers.
    define variable vhttBuffer as handle no-undo.
    define buffer tiers for tiers.

    vhttBuffer = phttTiers:default-buffer-handle.
    for first tiers no-lock
        where tiers.notie = piNotie:
        vhttBuffer:buffer-create().
        outils:copyValidField(buffer tiers:handle, vhttBuffer).  // copy table physique vers temp-table
    end.
    delete object phttTiers no-error.
    assign error-status:error = false no-error.   // reset error-status
    return.                                       // reset return-value
end procedure.

procedure updateTiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle    no-undo.
    define variable vhttBuffer as handle    no-undo.
    define variable vhNotie    as handle    no-undo.
    define variable vhCtanx    as handle    no-undo.
    define variable vhProc     as handle    no-undo.

    define buffer tiers for tiers.
    define buffer vbtiers for tiers.
    define buffer litie for litie.
    define buffer tutil for tutil.

    create query vhttquery.
    vhttBuffer = ghttTiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'U'", ghttTiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tiers exclusive-lock
                where rowid(tiers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tiers:handle, 'notie: ', substitute('&1', vhNotie:buffer-value()), vhttBuffer::dtTimestamp)
            or not outils:copyValidField(buffer tiers:handle, vhttBuffer, "U", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
            //Si modification collaborateur alors mettre à jour tutil associé
            for each tutil no-lock
                where tutil.notie = tiers.notie:
                create ttUtilisateur.
                assign
                    ttUtilisateur.cIdentifiant = tutil.ident_u
                    ttUtilisateur.iNumeroTiers = tutil.notie
                    ttUtilisateur.cNomUtilisateur = tiers.lNom1
                    ttUtilisateur.cNomTiers = tiers.lNom1
                    ttUtilisateur.cPrenom = tiers.lpre1
                    ttUtilisateur.dtTimestamp = datetime(tutil.damod, tutil.ihmod)
                    ttUtilisateur.CRUD = "U"
                    ttUtilisateur.rRowid = rowid(tutil)
                    .
                .
            end.

            //Mise à jour des informations des tiers individus rattachés au tiers principal
            for each litie no-lock
                where litie.notie = tiers.notie
              , first vbtiers exclusive-lock
                where vbtiers.notie = litie.noind:
                //Champs uniques dans la table Tiers
                assign
                    vbtiers.sipro = if litie.nopos = 1 then vhttBuffer::cSituationProf1 else vhttBuffer::cSituationProf2
                    vbtiers.nopid = if litie.nopos = 1 then vhttBuffer::cNumeroCarteIdentite1 else vhttBuffer::cNumeroCarteIdentite2
                    vbtiers.nosec = if litie.nopos = 1 then vhttBuffer::cNumeroSecuriteSociale1 else vhttBuffer::cNumeroSecuriteSociale2
                    vbtiers.nmemp = if litie.nopos = 1 then vhttBuffer::cNomEmployeur1 else vhttBuffer::cNomEmployeur2
                    vbtiers.ademp = if litie.nopos = 1 then vhttBuffer::cAdresseEmployeur1 else vhttBuffer::cAdresseEmployeur2
                    vbtiers.viemp = if litie.nopos = 1 then vhttBuffer::cVilleEmployeur1 else vhttBuffer::cVilleEmployeur2
                    vbtiers.cpemp = if litie.nopos = 1 then vhttBuffer::cCodePostalEmployeur1 else vhttBuffer::cCodePostalEmployeur2
                    .
                //Champs dupliqués en numéros 1 et 2 dans la table Tiers
                if litie.nopos = 1 then
                    assign
                        vbtiers.lnom1 = vhttBuffer::cNom1
                        vbtiers.lpre1 = vhttBuffer::cPrenom1
                        vbtiers.lapr1 = vhttBuffer::cAutrePrenom1
                        vbtiers.cdcv1 = vhttBuffer::cCodeCivilite1
                        vbtiers.cdpr1 = vhttBuffer::cCodeParticulier1
                        vbtiers.cdst1 = vhttBuffer::cCodeSituation1
                        vbtiers.dtna1 = vhttBuffer::daDateNaissance1
                        vbtiers.lina1 = vhttBuffer::cLieuNaissance1
                        vbtiers.dpna1 = vhttBuffer::cDepartementNaissance1
                        vbtiers.pyna1 = vhttBuffer::cCodePaysNaissance1
                        vbtiers.cdna1 = vhttBuffer::cCodeNationalite1
                        vbtiers.fgna1 = (vhttBuffer::lNationaliteFrancaise1 = "001")
                        vbtiers.cdsx1 = vhttBuffer::cCodeSexe1
                        vbtiers.dtdc1 = vhttBuffer::daDateDeces1
                        vbtiers.fgdc1 = vhttBuffer::daDateDeces1 <> ?
                        vbtiers.lnjf1 = vhttBuffer::cNomJeuneFille1
                        vbtiers.lprf1 = vhttBuffer::cLibelleProfession1
                        vbtiers.cdsp1 = vhttBuffer::cCategorieSocioProf1
                        vbtiers.revm1 = vhttBuffer::dRevenuMensuel1
                        vbtiers.reva1 = vhttBuffer::dRevenuAnnuel1
                        .
                else if litie.nopos = 2 then
                    assign
                        vbtiers.lnom1 = vhttBuffer::cNom2
                        vbtiers.lpre1 = vhttBuffer::cPrenom2
                        vbtiers.lapr1 = vhttBuffer::cAutrePrenom2
                        vbtiers.cdcv1 = vhttBuffer::cCodeCivilite2
                        vbtiers.cdpr1 = vhttBuffer::cCodeParticulier2
                        vbtiers.cdsx1 = vhttBuffer::cCodeSexe2
                        vbtiers.cdst1 = vhttBuffer::cCodeSituation2
                        vbtiers.dtna1 = vhttBuffer::daDateNaissance2
                        vbtiers.lina1 = vhttBuffer::cLieuNaissance2
                        vbtiers.dpna1 = vhttBuffer::cDepartementNaissance2
                        vbtiers.pyna1 = vhttBuffer::cCodePaysNaissance2
                        vbtiers.cdna1 = vhttBuffer::cCodeNationalite2
                        vbtiers.fgna1 = (vhttBuffer::lNationaliteFrancaise2 = "001")
                        vbtiers.dtdc1 = vhttBuffer::daDateDeces2
                        vbtiers.fgdc1 = vhttBuffer::daDateDeces2 <> ?
                        vbtiers.lnjf1 = vhttBuffer::cNomJeuneFille2
                        vbtiers.lprf1 = vhttBuffer::cLibelleProfession2
                        vbtiers.cdsp1 = vhttBuffer::cCategorieSocioProf2
                        vbtiers.revm1 = vhttBuffer::dRevenuMensuel2
                        vbtiers.reva1 = vhttBuffer::dRevenuAnnuel2
                        .
            end.
            if not can-find(first litie no-lock
                            where litie.notie = tiers.notie) then
                assign
                    tiers.lnom2 = ""
                    tiers.lpre2 = ""
                    tiers.lapr2 = ""
                    tiers.cdcv2 = ""
                    tiers.cdpr2 = ""
                    tiers.cdsx2 = ""
                    tiers.cdst2 = ""
                    tiers.dtna2 = ?
                    tiers.lina2 = ""
                    tiers.dpna2 = ""
                    tiers.pyna2 = ""
                    tiers.cdna2 = ""
                    tiers.fgna2 = no
                    tiers.cdsx2 = ""
                    tiers.dtdc2 = ?
                    tiers.fgdc2 = no
                    tiers.lnjf2 = ""
                    tiers.lprf2 = ""
                    tiers.cdsp2 = ""
                    tiers.revm2 = 0
                    tiers.reva2 = 0
                .
            miseAJourContratsduTiers(tiers.notie).
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    if can-find(first ttUtilisateur) then do:
        run crud/tutil_CRUD.p persistent set vhProc.
        run getTokenInstance in vhProc (mToken:JSessionId).
        run setTutil in vhProc(table ttUtilisateur).
        run destroy in vhProc.
    end.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure updateCorrespondance:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : externe
    ------------------------------------------------------------------------------*/
    define input parameter table for ttCorrespondanceTiers.

    define buffer tiers for tiers.

blocTrans:
    do transaction:
        for first ttCorrespondanceTiers where ttCorrespondanceTiers.CRUD = "U"
          , first tiers exclusive-lock
                where rowid(tiers) = ttCorrespondanceTiers.rRowid:
            tiers.lbdiv2 = substitute("&1#&2#&3",ttCorrespondanceTiers.cTypeCivilite,
                                            if ttCorrespondanceTiers.cTypeCivilite = "00003" then ttCorrespondanceTiers.cLibelleCiviliteLibre
                                            else "",
                                            ttCorrespondanceTiers.cFormulePolitesse).
        end.
    end.
    return.
end procedure.

procedure createTiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle  no-undo.
    define variable vhttBuffer as handle  no-undo.
    define variable viNotie    as int64   no-undo.
    define variable vhNotie    as handle  no-undo.
    define buffer tiers for tiers.

    create query vhttquery.
    vhttBuffer = ghttTiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'C'", ghttTiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.
            viNotie = vhNotie:buffer-value().
            if viNoTie = 0 then viNoTie = getNextTiers().
            vhNotie:buffer-value() = viNotie.
            create tiers.
            if not outils:copyValidField(buffer tiers:handle, vhttBuffer, "C", mtoken:cUser)
            then undo blocTrans, leave blocTrans.
            else mError:createErrorComplement(-1, "", string(viNoTie)). //Pour renvoyer le numéro de tiers afin de raffraîchir l'écran
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTiers private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotie    as handle  no-undo.
    //define variable vhProcTiers             as handle       no-undo.
    //define variable vhProc                  as handle       no-undo.
    define buffer vbRoles for roles.
    define buffer tiers for tiers.

    create query vhttquery.
    vhttBuffer = ghttTiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tiers no-lock
                where rowid(Tiers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tiers:handle, 'notie: ', substitute('&1', vhNotie:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            //Confirmez-vous la suppression du tiers &1 ?
            if outils:questionnaire(1000773, substitute("&1 - &2 &3", tiers.notie, tiers.lnom1, tiers.lpre1), table ttError by-reference) <= 2
            then undo blocTrans, leave blocTrans.
            run deleteTiersEtContrats (tiers.notie).
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTiersSansConfirmationMaj private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotie    as handle  no-undo.
    //define variable vhProcTiers             as handle       no-undo.
    //define variable vhProc                  as handle       no-undo.
    define buffer vbRoles for roles.
    define buffer tiers for tiers.

    create query vhttquery.
    vhttBuffer = ghttTiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", ghttTiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie).
blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tiers no-lock
                where rowid(Tiers) = vhttBuffer::rRowid no-wait no-error.
            if outils:isUpdated(buffer tiers:handle, 'notie: ', substitute('&1', vhNotie:buffer-value()), vhttBuffer::dtTimestamp)
            then undo blocTrans, leave blocTrans.

            run deleteTiersEtContrats (tiers.notie).
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

procedure deleteTiersEtContrats:
    /*------------------------------------------------------------------------------
    Purpose: a partir de adb/lib/suptie01.p
             Suppression d'un Tiers après contrôle (lib\ctsuptie.p) (en gestion uniquement)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroTiers as int64 no-undo.

    define buffer tiers for tiers.
    define buffer ctanx for ctanx.
    define buffer tier2 for tier2.
    define buffer litie for litie.

blocTrans:
    do transaction:
        for each tiers exclusive-lock
           where tiers.notie = piNumeroTiers:
            // contrat annexe (contrat de mariage ou statut société)
            for each ctanx exclusive-lock
               where ctanx.tpcon = {&TYPECONTRAT-Association}
                 and ctanx.nocon = tiers.nocon:
                delete ctanx no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            // IBAN
            for each ctanx exclusive-lock
                where ctanx.tpcon = {&TYPECONTRAT-RIB}
                  and ctanx.tprol = {&TYPEROLE-TIERS}
                  and ctanx.norol = piNumeroTiers:
                delete ctanx no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            // NP 0416/0226 : IBAN en attente de validation
            for each ctanx exclusive-lock
                where ctanx.tpcon = {&TYPECONTRAT-RIBAttenteValidation}
                  and ctanx.tprol = {&TYPEROLE-tiers}
                  and ctanx.norol = piNumeroTiers:
                delete ctanx no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            // contrat employeur
            for each ctanx exclusive-lock
                where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                  and ctanx.tprol = {&TYPEROLE-tiers}
                  and ctanx.norol = piNumeroTiers:
                delete ctanx no-error.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            // Infos mobiles
            for each tier2 exclusive-lock
               where tier2.notie = piNumeroTiers:
                delete tier2 no-error.
            end.
            // liens couple
            for each litie exclusive-lock
               where litie.notie = piNumeroTiers:
                delete litie.
                if error-status:error then do:
                    mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
            delete tiers no-error.
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    error-status:error = false no-error.  // reset error-status

end procedure.

procedure controleDeleteTiers:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Service externe
    ------------------------------------------------------------------------------*/
    define input parameter table-handle phttTiers.

    define variable vhttquery  as handle   no-undo.
    define variable vhttBuffer as handle   no-undo.
    define variable vhNotie    as handle  no-undo.
    define buffer tiers for tiers.

    create query vhttquery.
    vhttBuffer = phttTiers:default-buffer-handle.
    vhttquery:set-buffers(vhttBuffer).
    vhttquery:query-prepare(substitute("for each &1 where &1.crud = 'D'", phttTiers:name)).
    vhttquery:query-open().
    getIndexField(vhttBuffer, output vhNotie).

blocTrans:
    do transaction:
        repeat:
            vhttquery:get-next().
            if vhttquery:query-off-end then leave blocTrans.

            find first tiers no-lock
                where rowid(Tiers) = vhttBuffer::rRowid no-wait no-error.
            controleTiers (tiers.notie, true).
            if error-status:error then do:
                mError:createError({&error}, error-status:get-message(1)).
                undo blocTrans, leave blocTrans.
            end.
        end.
    end.
    vhttquery:query-close().
    delete object vhttQuery no-error.
    error-status:error = false no-error.   // reset error-status
    return.                                // reset return-value
end procedure.

