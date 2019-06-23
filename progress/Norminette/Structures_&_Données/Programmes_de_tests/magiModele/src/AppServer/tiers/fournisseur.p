/*------------------------------------------------------------------------
File        : fournisseur.p
Purpose     :
Author(s)   : Kantena - 2016/08/08
Notes       :
derniere revue: 2018/03/22 - phm
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{tiers/include/fournisseur.i}
{tiers/include/ibanFournisseur.i}
{adresse/include/adresse.i}
{application/include/error.i}

define variable ghControleBancaire as handle  no-undo.

function getLibelleFour returns character (pcTypeRole as character, piNumeroRole as int64):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable viSociete as integer no-undo.

    define buffer ifour   for ifour.
    define buffer ccptcol for ccptcol.

    viSociete = mtoken:getSociete(pcTypeRole).
    for first ccptCol no-lock
        where ccptCol.tprol  = 12
          and ccptcol.soc-cd = viSociete
      , first ifour no-lock
        where ifour.soc-cd   = ccptcol.soc-cd
          and ifour.coll-cle = ccptcol.coll-cle
          and ifour.cpt-cd   = string(piNumeroRole, "99999"):
        return trim(ifour.nom).
    end.
    return "".

end function.

function isActif returns logical (piSociete as integer, pcCodeCompte as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par deandeDeDevis.p, ordreDeService.p
    ------------------------------------------------------------------------------*/
    define buffer ccptcol for ccptcol.
    define buffer ifour   for ifour.

    for first ccptcol no-lock
        where ccptcol.soc-cd = piSociete
          and ccptcol.tprole = 12
      , first ifour no-lock
        where ifour.soc-cd   = ccptcol.soc-cd
          and ifour.coll-cle = ccptcol.coll-cle
          and ifour.cpt-cd   = pcCodeCompte
          and not ifour.fg-actif:
        mError:createError({&warning}, 1000190, ifour.nom).  // message "Le fournisseur" bifour.cpt-cd bifour.Nom "est inactif, saisie impossible"
        return false.
    end.
    return true.

end function.

function isReference returns logical(piSociete as integer, pcCodeCompte as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par deandeDeDevis.p, ordreDeService.p
    ------------------------------------------------------------------------------*/
    define buffer ccptcol for ccptcol.
    define buffer ifour   for ifour.

    if can-find(first iparm no-lock where iparm.tppar = "REFERF" and iparm.cdpar = "01") /* Gestion referencement */
    then for first ccptcol no-lock
        where ccptcol.soc-cd = piSociete
          and ccptcol.tprole = 12
      , first ifour no-lock
        where ifour.soc-cd   = ccptcol.soc-cd
          and ifour.coll-cle = ccptcol.coll-cle
          and ifour.cpt-cd   = pcCodeCompte
          and ifour.refer-cd = "":       /* non referencé */
        return false.
    end.
    return true.

end function.

procedure createFournisseurSimple:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé pr beFournisseur.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttFournisseur.
    define input parameter table for ttibanFournisseur.
    define input parameter table for ttError.

    define variable vcCodeFournisseur as character no-undo initial ?.

    define buffer iribfour for iribfour.
    define buffer ccptcol  for ccptcol.
    define buffer ifour    for ifour.

    run outils/controleBancaire.p persistent set ghControleBancaire.
    run getTokenInstance in ghControleBancaire (mToken:JSessionId).

blocTransaction:
    for first ttFournisseur
        where ttFournisseur.CRUD = "C" transaction:
        for first ccptcol exclusive-lock
            where ccptcol.soc-cd     = ttFournisseur.iCodeSociete
              and ccptcol.libtier-cd = 2
              and ccptcol.tprole     = 12:
            // Test activation de la numérotation automatique
            if ccptcol.codifaux = true
            then do:
                mError:createError({&error},"La numérotation automatique des fournisseurs n'est pas active." ). // Todo Traduction
                undo blocTransaction, leave blocTransaction.
            end.
            // Affectation du prochain code Fournisseur = compte Fournisseur
            run prochainNumeroFournisseur(ccptcol.soc-cd, ccptcol.coll-cle, ccptcol.noseq, output vcCodeFournisseur).
            if vcCodeFournisseur = "" or vcCodeFournisseur = ? or vcCodeFournisseur = "-1"
            then do:
                mError:createError({&error},"Dépassement de format, obtention du code fournisseur impossible"). // Todo Traduction
                undo blocTransaction, leave blocTransaction.
            end.
            create ifour.
            assign
                ifour.soc-cd           = ttFournisseur.iCodeSociete
                ifour.etab-cd          = 0
                ifour.four-cle         = vcCodeFournisseur
                ifour.librais-cd       = ttFournisseur.iCodeRaisonSociale
                ifour.nom              = ttFournisseur.cLibelle
                ifour.coll-cle         = "F"
                ifour.cpt-cd           = vcCodeFournisseur
                ifour.adrcom           = no
                ifour.adrregl          = no
                ifour.dev-cd           = "EUR"
                ifour.regl-cd          = ttFournisseur.iCodeReglement
                ifour.fam-cd           = 1
                ifour.ssfam-cd         = 1
                ifour.dacreat          = today
                ifour.damodif          = today
                ifour.releve           = no
                ifour.rib              = no
                ifour.adr[1]           = ttFournisseur.cAdresse[1]
                ifour.adr[2]           = if ttFournisseur.cAdresse[2] > "" then ttFournisseur.cAdresse[2] else ""
                ifour.adr[3]           = if ttFournisseur.cAdresse[3] > "" then ttFournisseur.cAdresse[3] else ""
                ifour.libpays-cd       = "001"
                ifour.ville            = ttFournisseur.cVille
                ifour.cp               = ttFournisseur.cCodePostal
                ifour.livfac           = no
                ifour.tva-enc-deb      = yes
                ifour.libass-cd        = 1
                ifour.liblang-cd       = 1
                ifour.transp           = no
                ifour.effacable        = no
                ifour.type-four        = "F"
                ifour.fg-compens       = yes
                ifour.usrid            = mtoken:cUser
                ifour.ihcrea           = time
                ifour.ihmod            = time
                ifour.dacrea           = today
                ifour.damod            = today
                ifour.mtcapital        = 0
                ifour.fopol            = "S||Veuillez agréer, %1, l'expression de nos sentiments distingués." // Todo Traduction
                ifour.web-fgautorise   = yes
                ifour.web-fgouvert     = yes
                ifour.web-datouverture = ?
                ifour.web-fgactif      = yes
                ifour.web-datact       = ?
                ifour.web-datdesact    = ?
                ifour.web-div          = ""
                ifour.fg-actif         = yes
                ifour.refer-cd         = ""
                ifour.fg-refer         = ?
                ifour.lrefer           = ""
                ifour.fg-dossier       = no
            .
            if ttFournisseur.iCodeReglement = 700
            and can-find(first ttibanFournisseur where ttFournisseur.CRUD = "C")
            then for first ttibanFournisseur where ttFournisseur.CRUD = "C":
                // Test IBAN valide et format BIC (optionnel)
                if not dynamic-function('controleIbanBic' in ghControleBancaire, ttibanFournisseur.cbic, ttibanFournisseur.ciban)
                then undo blocTransaction, leave blocTransaction.

                create iribfour.
                assign
                    iribfour.soc-cd     = ttIbanFournisseur.iCodeSociete
                    iribfour.etab-cd    = 0
                    iribfour.four-cle   = vcCodeFournisseur
                    iribfour.ordre-num  = 1
                    iribfour.bque       = substring(ttIbanFournisseur.cIban, 5, 5, 'character')
                    iribfour.guichet    = substring(ttIbanFournisseur.cIban, 10, 5, 'character')
                    iribfour.cpt        = substring(ttIbanFournisseur.cIban, 15, 11, 'character')
                    iribfour.rib        = substring(ttIbanFournisseur.cIban, 26, 2, 'character')
                    iribfour.domicil[1] = ttIbanFournisseur.cTitulaire
                    iribfour.domicil[2] = ttIbanFournisseur.cDomiciliation
                    iribfour.edition    = yes
                    iribfour.bque-nom   = ttIbanFournisseur.cDomiciliation
                    iribfour.etr        = no
                    iribfour.bic        = ttIbanFournisseur.cBic
                    iribfour.iban       = ttIbanFournisseur.cIban
                    iribfour.usrid      = mtoken:cUser
                    iribfour.usridmod   = ""
                    iribfour.ihcrea     = time
                    iribfour.ihmod      = time
                    iribfour.dacrea     = today
                    iribfour.damod      = today
                .
            end.
            else do:
                mError:createError({&error}, 1000600). // IBAN obligatoire pour le mode de règlement virement
                undo blocTransaction, leave blocTransaction.
            end.
        end. // ccptcol
        mError:createInfoRowid(rowid(ifour)).  // enregistrement créé, permet de renvoyer le rowid en réponse (clé primaire inconnue à la création)
    end.
    run destroy in ghControleBancaire.

end procedure.

procedure getFournisseurSimpleByRowid:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé pr beFournisseur.cls
    ------------------------------------------------------------------------------*/
    define input  parameter prRowId as rowid no-undo.
    define output parameter table for ttFournisseur.
    define output parameter table for ttibanFournisseur.

    define buffer ifour    for ifour.
    define buffer iribfour for iribfour.

    for first ifour no-lock
        where rowid(ifour) = prRowId:
        run createTTFournisseur(buffer ifour).
        for each iribfour no-lock
            where iribfour.soc-cd = ifour.soc-cd
              and iribfour.four-cle = ifour.four-cle:
            run createTTIbanFournisseur(buffer iribfour).
        end.
    end.

end procedure.

procedure getFournisseurSimple:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par beFournisseur.cls
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeSociete     as integer   no-undo.
    define input  parameter pcCodeFournisseur as character no-undo.

    define output parameter table for ttFournisseur.
    define output parameter table for ttibanFournisseur.

    define buffer ifour    for ifour.
    define buffer iribfour for iribfour.

    for first ifour no-lock
        where ifour.soc-cd   = piCodeSociete
          and ifour.four-cle = pcCodeFournisseur:
        run createTTFournisseur(buffer ifour).
        for each iribfour no-lock
            where iribfour.soc-cd = ifour.soc-cd
              and iribfour.four-cle = ifour.four-cle:
            run createTTIbanFournisseur(buffer iribfour).
        end.
    end.

end procedure.

procedure getListeFournisseurDuplicationDevis:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé pr beFournisseur.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroDevis as integer   no-undo.
    define input parameter pcTypeMandat  as character no-undo.
    define output parameter table for ttFournisseur.

    define variable vcListeDomaine as character no-undo.
    define variable vcListeDevFour as character no-undo.
    define variable vlBlocage      as logical   no-undo.
    define variable viSociete      as integer   no-undo.

    define buffer ifour    for ifour.
    define buffer prmTv    for prmTv.
    define buffer idomfour for idomfour.
    define buffer ccptCol  for ccptCol.
    define buffer dtdev    for dtdev.
    define buffer vbDtdev  for dtdev.
    define buffer devis    for devis.

    viSociete = mtoken:getSociete(pcTypeMandat).
    /*--> Recherche des fournisseurs */
    for each dtdev no-lock
        where dtdev.nodev = piNumeroDevis
      , each vbDtdev no-lock
        where vbDtdev.NoInt = dtdev.noint
      , first devis no-lock
        where devis.nodev = vbDtdev.nodev:
        if lookup(string(devis.nofou), vcListeDevFour) = 0
        then vcListeDevFour = substitute("&1,&2", vcListeDevFour, string(devis.nofou)).
    end.
    vcListeDevFour = trim(vcListeDevFour, ",").
boucle:
    for each ccptCol no-lock
       where ccptCol.tprol  = 12
         and ccptcol.soc-cd = viSociete
      , each ifour no-lock
       where ifour.soc-cd = ccptcol.soc-cd
         and ifour.coll-cle = ccptcol.coll-cle
         and ifour.cpt-cd <> "00000"
         and ifour.cpt-cd <> "99999":
        /* Passer si le fournisseur a déjà fait l'objet d'un devis sur au moins une intervention dupliquée */
        if lookup(string(integer(ifour.cpt-cd)), vcListeDevFour) > 0 then next boucle.

        vcListeDomaine = "".
        for each idomfour no-lock
           where idomfour.soc-cd = ifour.soc-cd
             and ifour.four-cle  = idomfour.four-cle
         , first prmtv no-lock
           where prmtv.tppar = "DOMAI"
             and prmtv.cdpar = string(idomfour.dom-cd, "99999"):
            vcListeDomaine = substitute("&1,&2", vcListeDomaine, prmtv.lbpar).
        end.
        vcListeDomaine = trim(vcListeDomaine, ",").
        /* Si blocage, ne pas proposer le fournisseur */
        if (ifour.refer-cd = "" or ifour.refer-cd = ?) /* Non référencé */
        and can-find(first iparm no-lock where iparm.tppar = "REFERF" and iparm.cdpar = "01") /* Gestion referencement */
        and can-find(first iparm no-lock where iparm.tppar = "REFERB" and iparm.cdpar = "01")
        then vlblocage = true. /* avec blocage */
        else vlblocage = false.
        create ttFournisseur.
        assign
            ttFournisseur.CRUD                = 'R'
            ttFournisseur.cCodeFournisseur    = ifour.four-cle
            ttFournisseur.iCodeSociete        = ifour.soc-cd
            ttFournisseur.cLibelle            = ifour.nom
            ttFournisseur.cAdresse            = ifour.adr
            ttFournisseur.cVille              = ifour.ville
            ttFournisseur.cCodePostal         = ifour.cp
            ttFournisseur.cCoordonnees        = ifour.contact
            ttFournisseur.lActif              = ifour.fg-actif
            ttFournisseur.lReference          = (ifour.refer-cd <> "")
            ttFournisseur.lActradis           = (ifour.lrefer matches "*actradis*")
            ttFournisseur.lBlocageDuplication = vlblocage
            ttFournisseur.cDomaineActivite    = vcListeDomaine
            ttFournisseur.dtTimestamp         = datetime(ifour.damod, ifour.ihmod)
        .
    end.
end procedure.

procedure setAdresseFournisseur:
    /*----------------------------------------------------------------------------------
    Purpose: mise à jour table IFOUR / ttAdresse pour l'adresse de la fiche fournisseur
    Notes  : service utilisé par adresse.p
    ------------------------------------------------------------------------------------*/
    define input parameter table for ttAdresse.

    define buffer ifour for ifour.

    find first ttAdresse
        where ttAdresse.CRUD <> "R" no-error.
    if not available ttAdresse then return.

    /*--> Contrôles **/
    if not can-find(first ifour no-lock
                    where ifour.soc-cd   = mToken:iCodeSociete
                      and ifour.four-cle = string(ttAdresse.iNumeroIdentifiant, "99999"))
    then do:
        mError:createError({&error}, 999999, string(ttAdresse.iNumeroIdentifiant, "99999")).   /* Fournisseur &1 inexistant */
        return.
    end.

    if ttAdresse.CRUD = "U" then do:
        find first ifour exclusive-lock
            where ifour.soc-cd   = mToken:iCodeSociete
              and ifour.four-cle = string(ttAdresse.iNumeroIdentifiant, "99999")  no-wait no-error.
        if outils:isUpdated(buffer ifour:handle, 'ifour ', 'Fournisseur: ' + string(ttAdresse.iNumeroIdentifiant, "99999"), ttAdresse.dtTimestampladrs)
        then return.

        assign
            ifour.adr[1]     = ttAdresse.cNomVoie
            ifour.adr[2]     = ttAdresse.cComplementVoie
            ifour.cp         = ttAdresse.cCodePostal
            ifour.ville      = ttAdresse.cVille
            ifour.libpays-cd = ttAdresse.cCodePays
            ifour.damod      = today
            ifour.ihmod      = mtime
            ifour.usridmod   = mToken:cUser
            ttAdresse.CRUD   = "R"
        .
    end.

end procedure.

procedure prochainNumeroFournisseur private:
    /*------------------------------------------------------------------------------
    Purpose: recherche du prochain code fournisseur disponible
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter piCodeSociete      as integer   no-undo.
    define input  parameter pcCodeRegroupement as character no-undo.
    define input  parameter pcSequence         as character no-undo.
    define output parameter pcCodeFournisseur  as character no-undo.

    define variable viNumeroTemporaire as integer   no-undo.
    define variable vcFormat           as character no-undo.

    define buffer ietab   for ietab.

    /*** Format automatique JR le 04/10/2000 ***/
    find first ietab  no-lock
        where ietab.soc-cd    = piCodeSociete
          and ietab.profil-cd = 10 no-error.
    assign
        vcFormat          = if available ietab and ietab.lgcpt > ietab.lgcum then fill("9", ietab.lgcpt - ietab.lgcum) else ""
        pcCodeFournisseur = if pcSequence > "" then pcSequence else "1"
    .
    if vcFormat > ""
    then do:
        pcCodeFournisseur = string(integer(pcCodeFournisseur), vcFormat) no-error.
        if error-status:error
        then do:
            pcCodeFournisseur = "-1" no-error.  // reset error-status
            return.
        end.
    end.
    do while (can-find(first ccpt no-lock
                       where ccpt.soc-cd   = piCodeSociete
                         and ccpt.coll-cle = pcCodeRegroupement
                         and ccpt.cpt-cd   = pcCodeFournisseur)
           or can-find(first ifour no-lock
                       where ifour.soc-cd   = piCodeSociete
                         and ifour.coll-cle = pcCodeRegroupement
                         and ifour.cpt-cd   = pcCodeFournisseur)
           or can-find(first ifour no-lock
                       where ifour.soc-cd   = piCodeSociete
                         and ifour.coll-cle = pcCodeRegroupement
                         and ifour.four-cle = pcCodeFournisseur)):
        if vcFormat > ""
        then do:
            pcCodeFournisseur = string(integer(pcCodeFournisseur) + 1, vcFormat) no-error.
            if error-status:error
            then do:
                pcCodeFournisseur = "-1" no-error.  // reset error-status
                return.
            end.
        end.
        else pcCodeFournisseur = string(integer(pcCodeFournisseur) + 1).
    end.
    viNumeroTemporaire = integer(pcCodeFournisseur) no-error.
    if error-status:error or viNumeroTemporaire <= 0 or length(pcCodeFournisseur, 'character') > 15
    then pcCodeFournisseur = "-1".

    error-status:error = false no-error.  // reset error-status
    return.                               // reset return-value
end procedure.

procedure createTTFournisseur private:
    /*------------------------------------------------------------------------------
    Purpose: Copie les informations de la table physique vers la temp-table
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ifour for ifour.

    create ttFournisseur.
    assign
        ttFournisseur.cCodeFournisseur    = ifour.four-cle
        ttFournisseur.iCodeSociete        = ifour.soc-cd
        ttFournisseur.iCodeRaisonSociale  = ifour.librais-cd
        ttFournisseur.cLibelle            = ifour.nom
        ttFournisseur.cAdresse            = ifour.adr
        ttFournisseur.cCodePostal         = ifour.cp
        ttFournisseur.cVille              = ifour.ville
        ttFournisseur.lActif              = ifour.fg-actif
        ttFournisseur.lReference          = (ifour.refer-cd > "")
        ttFournisseur.lActradis           = (ifour.lrefer matches "*actradis*")
        ttFournisseur.cDomaineActivite    = ""
        ttFournisseur.lBlocageDuplication = (ifour.refer-cd = "" or ifour.refer-cd = ?)                                           /* Non référencé */
                                            and can-find(first iparm no-lock where iparm.tppar = "REFERF" and iparm.cdpar = "01") /* Gestion referencement */
                                            and can-find(first iparm no-lock where iparm.tppar = "REFERB" and iparm.cdpar = "01")
        ttFournisseur.iCodeReglement      = ifour.regl-cd
        ttFournisseur.dtTimestamp         = datetime(ifour.damod, ifour.ihmod)
        ttFournisseur.CRUD                = "R"
    .
end procedure.

procedure createTTIbanFournisseur private:
    /*------------------------------------------------------------------------------
    Purpose: Copie les informations de la table physique vers la temp-table
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer iribfour for iribfour.

    create ttIbanFournisseur.
    assign
        ttIbanFournisseur.cCodeFournisseur = iribfour.four-cle
        ttIbanFournisseur.iCodeSociete     = iribfour.soc-cd
        ttIbanFournisseur.cIban            = iribfour.iban
        ttIbanFournisseur.cBic             = iribfour.bic
        ttIbanFournisseur.cDomiciliation   = iribfour.domicil[2]
        ttIbanFournisseur.cTitulaire       = iribfour.domicil[1]
        ttIbanFournisseur.dtTimestamp      = datetime(iribfour.damod, iribfour.ihmod)
        ttIbanFournisseur.CRUD             = "R"
    .
end procedure.
