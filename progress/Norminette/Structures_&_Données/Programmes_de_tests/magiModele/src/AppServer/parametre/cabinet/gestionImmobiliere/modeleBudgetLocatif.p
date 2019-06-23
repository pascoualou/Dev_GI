/*------------------------------------------------------------------------
File        : modeleBudgetLocatif.p
Purpose     :
Author(s)   : DMI 20180308
Notes       : à partir de adb/src/cabt/budlo00.p
derniere revue: 2018/04/23 - phm: KO
          régler les todo,  potentiel index avec cdlib ???
------------------------------------------------------------------------*/
using parametre.pclie.parametrageBudgetLocatif.
using parametre.pclie.parametrageBudgetLocatifANA.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{parametre/cabinet/gestionImmobiliere/include/modeleBudgetLocatif.i &nomtable=ttModeleBudgetaire &serialName=ttModeleBudgetaire}
{parametre/cabinet/gestionImmobiliere/include/posteBudgetLocatif.i &nomtable=ttPosteBudgetaire &serialName=ttPosteBudgetaire}

define temp-table ttControleRubrique no-undo
    field cTypeEnregistrement as character
    field iCodeRubrique       as integer
    field iCodeSousRubrique   as integer
.
define variable goCollection as class collection no-undo.

function fIsNull returns logical private (pcstring as character):
    /*------------------------------------------------------------------------------
    Purpose: retourne vrai si chaine en entree = "" ou ?
    Notes:
    ------------------------------------------------------------------------------*/
    return pcstring = "" or pcstring = ?.
end function.

function getParametrageModele returns logical private(piNumeroModele as integer):
    /*------------------------------------------------------------------------------
    Purpose: récupère le paramétrage du budget locatif
    Notes: issu de la fonction budlo_RecupereInfosModele dans comm/fctbudlo.i
    ------------------------------------------------------------------------------*/
    define variable voBudgetLocatif as class parametrageBudgetLocatif no-undo.

    if not valid-object(goCollection) then goCollection = new collection().
    voBudgetLocatif = new parametrageBudgetLocatif(string(piNumeroModele, "999")). // Récupération du paramètrage du modele du budget, d'abord le paramètrage du groupe
    goCollection:set("cExclusionsAnalytique", "").
    goCollection:set("cExclusionsQuittancement", "").
    if not voBudgetLocatif:isDbParameter then voBudgetLocatif:reload("000"). //  puis si inexistant le paramètrage de base
    if voBudgetLocatif:isDbParameter then do:
        goCollection:set("cExclusionsAnalytique"   , voBudgetLocatif:zon04) no-error.
        goCollection:set("cExclusionsQuittancement", voBudgetLocatif:zon06) no-error.
    end.
    delete object voBudgetLocatif no-error.
end function.

procedure getRubriqueBudgetaire:
    /*------------------------------------------------------------------------------
    Purpose: Chargement de la liste des rubriques analytique et quittancement
    Notes  : service
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroModele as integer no-undo.
    define input  parameter piNumeroPoste  as integer no-undo.
    define output parameter table for ttModeleBudgetaire.
    define output parameter table for ttPosteBudgetaire.
    define output parameter table for ttRubriqueBudgetaire.

    define variable vcListeExclusionAnalytique    as character no-undo.
    define variable vcListeExclusionQuittancement as character no-undo.
    define variable vcLibelle                     as character no-undo.

    define buffer repaqbl for repaqbl.
    define buffer aruba   for aruba.
    define buffer rubqt   for rubqt.

    run getPosteBudgetairePrivate(piNumeroModele, piNumeroPoste).
    for each ttModeleBudgetaire:
        // Recherche des rubriques à exclure
        getParametrageModele(ttModeleBudgetaire.iNumeroModele).
        assign
            vcListeExclusionAnalytique    = goCollection:getCharacter("cExclusionsAnalytique")
            vcListeExclusionQuittancement = goCollection:getCharacter("cExclusionsQuittancement")
        .
        for each ttPosteBudgetaire
            where ttPosteBudgetaire.iNumeroModele = ttModeleBudgetaire.iNumeroModele:
            // recherche des libellés des rubriques analytiques
            for each repaqbl no-lock
                where repaqbl.NoGrp  = ttPosteBudgetaire.iNumeroModele
                  and repaqbl.NoPost = ttPosteBudgetaire.iNumeroPoste
                  and repaqbl.TpRub  = "A"
                  and lookup(substitute("&1-&2", string(repaqbl.cdRub, "999"), string(repaqbl.cdSrb, "999")), vcListeExclusionAnalytique) = 0:
                vcLibelle = "".
                for first aruba no-lock
                    where aruba.soc-cd  = integer(mtoken:cRefPrincipale)
                      and aruba.cdlng   = mtoken:iCodeLangueSession
                      and aruba.fg-rub  = true
                      and aruba.rub-cd  = string(repaqbl.cdRub, "999"):
                    vcLibelle = aruba.Lib.
                end.
                //  recherche de libellé de la sous-rubrique en cours
                for first aruba no-lock
                    where aruba.soc-cd = integer(mtoken:cRefPrincipale)
                      and aruba.cdlng  = mtoken:iCodeLangueSession
                      and aruba.fg-rub = false
                      and aruba.rub-cd = string(repaqbl.CdSrb, "999") :
                    vcLibelle = substitute("&1 - &2", vcLibelle, aruba.Lib).
                end.
                create ttRubriqueBudgetaire.
                outils:copyValidField(buffer repaqbl:handle, buffer ttRubriqueBudgetaire:handle).  // copy table physique vers temp-table
                ttRubriqueBudgetaire.cLibelleRubSsRub = vcLibelle.
            end.
            // Recherche des libellés des rubriques de quittancement
            for each repaqbl no-lock
                where repaqbl.NoGrp  = ttPosteBudgetaire.iNumeroModele
                  and repaqbl.NoPost = ttPosteBudgetaire.iNumeroPoste
                  and repaqbl.TpRub  = "Q"
                  and lookup(string(repaqbl.CdRub, "999"), vcListeExclusionQuittancement) = 0 :
                vcLibelle = "".
                for first rubqt no-lock
                    where rubqt.CdLib = 0
                      and rubqt.CdRub = repaqbl.cdRub:
                    vcLibelle = outilTraduction:getLibelle(rubqt.nome1).
                end.
                create  ttRubriqueBudgetaire.
                outils:copyValidField(buffer repaqbl:handle, buffer ttRubriqueBudgetaire:handle).  // copy table physique vers temp-table
                ttRubriqueBudgetaire.cLibelleRubSsRub = vcLibelle.
            end.
        end.
    end.
    delete object goCollection no-error.
end procedure.

procedure getControleGlobal:
    /*------------------------------------------------------------------------------
    Purpose: Controle lancé à la sortie de l'écran
    Notes  : service. procedure ctrlfinal dans adb/src/budlo00.p
    ------------------------------------------------------------------------------*/
    define variable vcListeExclusionAnalytique    as character no-undo.
    define variable vcListeExclusionQuittancement as character no-undo.

    define buffer alrub   for alrub.
    define buffer rubqt   for rubqt.
    define buffer prrub   for prrub.
    define buffer rgpbl   for rgpbl.
    define buffer repaqbl for repaqbl.

    empty temp-table ttControleRubrique.
    for each alrub no-lock
        where alrub.soc-cd = integer(mToken:cRefPrincipale)
          and alrub.fg-use:
        create ttControleRubrique.
        assign
            ttControleRubrique.cTypeEnregistrement = "A"
            ttControleRubrique.iCodeRubrique       = integer(alrub.rub-cd)
            ttControleRubrique.iCodeSousRubrique   = integer(alrub.ssrub-cd)
        .
    end.
    // Pas d'index sur rubqt.cdlib, il n'y a que 2107 enregistrements dans rubqt (table système)
    for each rubqt no-lock
        where rubqt.cdlib = 0
      , first prrub no-lock
        where prrub.cdrub = rubqt.cdrub
          and prrub.cdlib = rubqt.cdlib
          and prrub.cdaff = "00001":
        create ttControleRubrique.
        assign
            ttControleRubrique.cTypeEnregistrement = "Q"
            ttControleRubrique.iCodeRubrique       = prrub.cdrub
            ttControleRubrique.iCodeSousRubrique   = 0
        .
    end.

boucleModele:
    for each rgpbl no-lock
        where rgpbl.tpenr = "G":
        getParametrageModele(rgpbl.noGrp).
        assign
            vcListeExclusionAnalytique    = goCollection:getCharacter("cExclusionsAnalytique")
            vcListeExclusionQuittancement = goCollection:getCharacter("cExclusionsQuittancement")
        .
        for each ttControleRubrique
            where ttControleRubrique.cTypeEnregistrement = "Q"
              and lookup(string(ttControleRubrique.iCodeRubrique, "999"), vcListeExclusionQuittancement) = 0: // Ne pas tester les rubriques à exclure
            if not can-find(first repaqbl no-lock
                where repaqbl.NoGrp = rgpbl.NoGrp
                  and repaqbl.TpRub = ttControleRubrique.cTypeEnregistrement
                  and repaqbl.CdRub = ttControleRubrique.iCodeRubrique
                  and repaqbl.CdSrb = ttControleRubrique.iCodeSousRubrique)
            then do:
                mError:createError({&info}, outilFormatage:fSubstGestion(outilTraduction:getLibelle(106453), rgpbl.LBENR)). // Le groupe '%1' n'est pas complet.
                next boucleModele.
            end.
        end.
        if not mError:erreur()
        then for each ttControleRubrique
            where ttControleRubrique.cTypeEnregistrement = "A"
              and lookup(substitute("&1-&2", string(ttControleRubrique.iCodeRubrique, "999"), string(ttControleRubrique.iCodeSousRubrique, "999")),vcListeExclusionAnalytique) = 0: //--> Ne pas tester les rubriques à exclure
            if not can-find(first repaqbl no-lock
                where repaqbl.NoGrp = rgpbl.NoGrp
                  and repaqbl.TpRub = ttControleRubrique.cTypeEnregistrement
                  and repaqbl.CdRub = ttControleRubrique.iCodeRubrique
                  and repaqbl.cdSrb = ttControleRubrique.iCodeSousRubrique)
            then do:
                mError:createError({&info}, outilFormatage:fSubstGestion(outilTraduction:getLibelle(106453), rgpbl.LBENR)). // Le groupe '%1' n'est pas complet.
                next boucleModele.
            end.
        end.
    end.
    delete object goCollection no-error.
end procedure.

procedure getModeleBudgetaire:
    /*------------------------------------------------------------------------------
    Purpose: chargement d'un ou de la liste des modeles budgetaires
    Notes  : Service externe appelé par beParametreCabinet.cls et paramBudgetLocatif.p
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroModele as integer no-undo.
    define output parameter table for ttModeleBudgetaire.

    define variable vhProcrgpbl as handle no-undo.

    run adblib/rgpbl_CRUD.p persistent set vhProcrgpbl.
    run getTokenInstance in vhProcrgpbl(mToken:JSessionId).
    run getrgpblModele in vhProcrgpbl(piNumeroModele, table ttModeleBudgetaire by-reference).
    run destroy in vhProcrgpbl.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure deserialisePoste private:
    /*------------------------------------------------------------------------------
    Purpose: Désérialisation pour le json
    Notes  : Service externe appelé par beParametreCabinet.cls
    ------------------------------------------------------------------------------*/
    for each ttPosteBudgetaire                                // Désérialisation pour le json
        where ttPosteBudgetaire.lRubriqueCalculee <> true
          and num-entries(ttPosteBudgetaire.fisc-cle) >= 4:
        assign
            ttPosteBudgetaire.lFiscalite1 = (entry(1, ttPosteBudgetaire.fisc-cle) = "O")
            ttPosteBudgetaire.lFiscalite2 = (entry(2, ttPosteBudgetaire.fisc-cle) = "O")
            ttPosteBudgetaire.lFiscalite3 = (entry(3, ttPosteBudgetaire.fisc-cle) = "O")
            ttPosteBudgetaire.lFiscalite4 = (entry(4, ttPosteBudgetaire.fisc-cle) = "O")
        no-error.
    end.
end procedure.

procedure getPosteBudgetaire:
    /*------------------------------------------------------------------------------
    Purpose: chargement de la liste des postes budgetaire d'un modele
    Notes  : Service externe appelé par beParametreCabinet.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroModele as integer no-undo.
    define input parameter piNumeroPoste  as integer no-undo.
    define output parameter table for ttModeleBudgetaire.
    define output parameter table for ttPosteBudgetaire.
    run getPosteBudgetairePrivate(piNumeroModele, piNumeroPoste).
end procedure.

procedure getPosteBudgetairePrivate private:
    /*------------------------------------------------------------------------------
    Purpose: chargement de la liste des postes budgetaire d'un modele
    Notes  : Service externe appelé par beParametreCabinet.cls
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroModele as integer no-undo.
    define input parameter piNumeroPoste  as integer no-undo.

    define variable vhProcrgpbl as handle no-undo.

    if piNumeroModele > 0 then do:
        run adblib/rgpbl_CRUD.p persistent set vhProcrgpbl.
        run getTokenInstance in vhProcrgpbl(mToken:JSessionId).
        run getrgpblModele in vhProcrgpbl(piNumeroModele, table ttModeleBudgetaire by-reference).
        run destroy in vhProcrgpbl.

        run adblib/rgpbl_CRUD.p persistent set vhProcrgpbl. // meme procedure mais table différente
        run getTokenInstance in vhProcrgpbl(mToken:JSessionId).
        run getrgpblPoste  in vhProcrgpbl(piNumeroModele, piNumeroPoste, table ttPosteBudgetaire  by-reference).
        run destroy in vhProcrgpbl.
        run deserialisePoste.
    end.
    error-status:error = false no-error.  // reset error-status
    return.

end procedure.

procedure initModeleBudgetaire :
    /*------------------------------------------------------------------------------
    Purpose: Initialisation de la création d'un modèle budgetaire
    Notes  : service externe (beParametreCabinet.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter table for ttModeleBudgetaire.
    define output parameter table for ttPosteBudgetaire.

    for each ttModeleBudgetaire where ttModeleBudgetaire.crud = "C":
        run crettPosteBudgetaire(ttModeleBudgetaire.iNumeroModele, 998, caps(outilTraduction:getLibelle(1000594)), "", "", false, "" , true, true, true, true). // Création du Poste Exclusion - 1000594 "Rubriques exclues du modèle"
        run crettPosteBudgetaire(ttModeleBudgetaire.iNumeroModele, 999, caps(outilTraduction:getLibelle(109089)) , "", "", true,  "*", ?,    ?,    ?,    ?).    // Création du Poste Solde Budget
    end.
end procedure.

procedure initPosteBudgetaire:
    /*------------------------------------------------------------------------------
    Purpose: Initialisation de la création d'un poste budgetaire
    Notes  : service externe (beParametreCabinet.cls)
    ------------------------------------------------------------------------------*/
    define input parameter         table for ttModeleBudgetaire.
    define input-output parameter  table for ttPosteBudgetaire.

    define variable viDernierNumeroOrdre as integer initial 0 no-undo.

    for first ttModeleBudgetaire:
bouclePoste:
        for each ttPosteBudgetaire
            where ttPosteBudgetaire.iNumeroModele = ttModeleBudgetaire.iNumeroModele
              and ttPosteBudgetaire.iNumeroOrdre < 998
            by ttPosteBudgetaire.iNumeroOrdre descending:
            viDernierNumeroOrdre = ttPosteBudgetaire.iNumeroOrdre. // Prochain numero d'ordre
            leave bouclePoste.
        end.
        run crettPosteBudgetaire(ttModeleBudgetaire.iNumeroModele, minimum(997, viDernierNumeroOrdre + 10), "", "", "", false, "" , true, true, true, true).
        for each ttPosteBudgetaire where ttPosteBudgetaire.lNouveau <> true: // On renvoie que le nouveau créé
            delete ttPosteBudgetaire.
        end.
    end.
end procedure.

procedure getRubriqueAnalytique:
    /*------------------------------------------------------------------------------
    Purpose: Liste des rubriques analytique à affectable sur le poste
    Notes  : service externe (beParametreCabinet.cls)
             issu de la procédure ChgTmTbAna cabt/affrbana.p
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroModele as integer no-undo.
    define input  parameter piNumeroPoste  as integer no-undo.
    define input  parameter plFiscalite1   as logical no-undo.
    define input  parameter plFiscalite2   as logical no-undo.
    define input  parameter plFiscalite3   as logical no-undo.
    define input  parameter plFiscalite4   as logical no-undo.
    define output parameter table for ttAffectRubriqueAnalytique.

    define variable vcListeExclusionAnalytique as character no-undo.
    define variable vcListFiscalite            as character no-undo.
    define variable vlRubriqueUtilise          as logical   no-undo.
    define variable vcFiscalite                as character no-undo.
    define variable viI1                       as integer   no-undo.
    define variable vcListeFiscalitePoste      as character no-undo.

    define buffer alrub     for alrub.
    define buffer aruba     for aruba.
    define buffer rgpbl     for rgpbl.
    define buffer repaqbl   for repaqbl.
    define buffer vbaruba   for aruba.
    define buffer vbrepaqbl for repaqbl.

    if plFiscalite1 then vcListeFiscalitePoste = substitute("&1,1", vcListeFiscalitePoste).
    if plFiscalite2 then vcListeFiscalitePoste = substitute("&1,2", vcListeFiscalitePoste).
    if plFiscalite3 then vcListeFiscalitePoste = substitute("&1,3", vcListeFiscalitePoste).
    if plFiscalite4 then vcListeFiscalitePoste = substitute("&1,4", vcListeFiscalitePoste).
    vcListeFiscalitePoste = trim(vcListeFiscalitePoste, ",").

    empty temp-table ttAffectRubriqueAnalytique.
    // Recherche des rubriques à exclure
    getParametrageModele(piNumeroModele).
    vcListeExclusionAnalytique = goCollection:getCharacter("cExclusionsAnalytique").
    delete object goCollection no-error.

    for each alrub no-lock
        where alrub.soc-cd = integer(mtoken:cRefPrincipale)
          and lookup(alrub.rub-cd + "-" + alrub.ssrub-cd, vcListeExclusionAnalytique) = 0
      , first aruba no-lock
        where aruba.soc-cd = alrub.soc-cd
          and aruba.cdlng  = mtoken:iCodeLangueSession
          and aruba.fg-rub = true
          and aruba.rub-cd = alrub.rub-cd
      , first vbaruba no-lock
        where vbaruba.soc-cd = alrub.soc-cd
          and vbaruba.cdlng  = mtoken:iCodeLangueSession
          and vbaruba.fg-rub = false
          and vbaruba.rub-cd = alrub.ssrub-cd:
        // On cherche si la rubrique en cours est utilisée par un autre poste du même grpe
        assign
            vlRubriqueUtilise = false
            vcListFiscalite   = ",,,"
        .
        for each repaqbl no-lock
            where repaqbl.NoGrp  = piNumeroModele
              and repaqbl.NoPost <> piNumeroPoste
              and repaqbl.TpRub  = "A"
              and repaqbl.CdRub  = integer(alrub.rub-cd)
              and repaqbl.CdSrb  = integer(alrub.ssrub-cd)
          , first rgpbl no-lock
            where rgpbl.tpenr  = "P"
              and rgpbl.NoGrp  = piNumeroModele
              and rgpbl.NoPost = repaqbl.NoPost
              and num-entries(rgpbl.fisc-cle) >= 4:
            do viI1 = 1 to 4:
                if entry(viI1, rgpbl.fisc-cle) = "O" then entry(viI1, vcListFiscalite) = string(viI1).
            end.
        end.
boucleFisc:
        do viI1 = 1 to num-entries(vcListeFiscalitePoste):
            vcFiscalite = entry(viI1, vcListeFiscalitePoste).
            if lookup(vcFiscalite, vcListFiscalite) > 0 then do:
                vlRubriqueUtilise = true.
                leave boucleFisc.
            end.
        end.
        if vlRubriqueUtilise = false then do: // dans tous ces cas elle va etre créé dans la table tempo
            create ttAffectRubriqueAnalytique.
            assign
                  ttAffectRubriqueAnalytique.iCodeRubrique        = integer(alrub.rub-cd)
                  ttAffectRubriqueAnalytique.cLibelleRubrique     = aruba.Lib
                  ttAffectRubriqueAnalytique.iCodeSousRubrique    = integer(alrub.ssrub-cd)
                  ttAffectRubriqueAnalytique.cLibelleSousRubrique = vbaruba.Lib
                  ttAffectRubriqueAnalytique.lAutorise            = alrub.fg-use
                  ttAffectRubriqueAnalytique.lSelection           = can-find(first vbrepaqbl no-lock // Cocher la case  choix si utilisée par le poste en cours
                                                                        where vbrepaqbl.NoGrp = piNumeroModele
                                                                          and vbrepaqbl.NoPost = piNumeroPoste
                                                                          and vbrepaqbl.TpRub = "A"
                                                                          and vbrepaqbl.CdRub = integer(alrub.rub-cd)
                                                                          and vbrepaqbl.CdSrb = integer(alrub.ssrub-cd))
            .
       end.
    end.
end procedure.

procedure getRubriqueQuittancement:
    /*------------------------------------------------------------------------------
    Purpose: Liste des rubriques quittancement affectable sur le poste
    Notes  : service externe (beParametreCabinet.cls)
             issu de la procédure ChgTmTbAna cabt/affrbqtt.p
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroModele as integer no-undo.
    define input parameter piNumeroPoste  as integer no-undo.
    define output parameter table for ttAffectRubriqueQuittancement.
    
    define variable vcListeExclusionQuittancement as character no-undo.

    define buffer rubqt for rubqt.
    define buffer prrub for prrub.

    getParametrageModele(piNumeroModele).
    vcListeExclusionQuittancement = goCollection:getCharacter("cExclusionsQuittancement").
    delete object goCollection no-error.

    empty temp-table ttAffectRubriqueQuittancement.
    // Pas d'index sur rubqt.cdlib, il n'y a que 2107 enregistrements dans rubqt (table système)
    for each rubqt no-lock
        where rubqt.cdLib = 0
          and lookup(string(rubqt.cdRub, "999"), vcListeExclusionQuittancement) = 0
      , first prrub no-lock
        where prrub.cdRub = rubqt.cdRub
          and prrub.cdLib = rubqt.cdLi:
        // On cherche si la rubrique en cours est utilisée par un autre poste du même grpe
        if not can-find(first repaqbl no-lock
            where repaqbl.noGrp  = piNumeroModele
              and repaqbl.NoPost <> piNumeroPoste
              and repaqbl.tpRub  = "Q"
              and repaqbl.cdRub  = rubqt.cdRub)
        then do: // si elle n'est pas utilisée
            create ttAffectRubriqueQuittancement.
            assign
                ttAffectRubriqueQuittancement.iCodeRubrique    = rubqt.cdrub
                ttAffectRubriqueQuittancement.cLibelleRubrique = outilTraduction:getLibelle(rubqt.nome1)
                ttAffectRubriqueQuittancement.lAutorise        = (prrub.CdAff = "00001")
                ttAffectRubriqueQuittancement.lSelection       = can-find(first repaqbl no-lock // cocher la case  choix si utilisée par le poste en cours
                                                                    where repaqbl.NoGrp  = piNumeroModele
                                                                      and repaqbl.NoPost = piNumeroPoste
                                                                      and repaqbl.TpRub  = "Q"
                                                                      and repaqbl.CdRub  =  rubqt.CdRub)
            .
       end.
     end.
end procedure.

procedure controle private:
    /*------------------------------------------------------------------------------
    Purpose: Controle avant validation
    Notes  :
    ------------------------------------------------------------------------------*/
boucle:
    for each ttModeleBudgetaire where lookup(ttModeleBudgetaire.CRUD, "C,U") > 0:
        run controleModele.
        if mError:Erreur() then leave boucle.

        for each ttPosteBudgetaire
            where lookup(ttPosteBudgetaire.CRUD, "C,U") > 0
              and ttPosteBudgetaire.iNumeroModele = ttModeleBudgetaire.iNumeroModele:
            run controlePoste.
            if mError:Erreur() then leave boucle.
        end.
    end.
end procedure.

procedure controleModele private:
    /*------------------------------------------------------------------------------
    Purpose: Controle Modele avant validation
    Notes  :
    ------------------------------------------------------------------------------*/
    if fisnull(ttModeleBudgetaire.cLibelleModele) then mError:createError({&error}, 106404). // 106404 Le libellé du groupe budgétaire est obligatoire
end procedure.

procedure controlePoste private:
    /*------------------------------------------------------------------------------
    Purpose: Controle Poste avant validation
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable viI1    as integer   no-undo.
    define variable viOrdre as integer   no-undo.
    define variable vcListe as character no-undo.

    if ttPosteBudgetaire.iNumeroOrdre >= 998 and ttPosteBudgetaire.CRUD <> "C"
    then mError:createError({&error}, 1000598, string(ttPosteBudgetaire.iNumeroModele)). // 1000598 Modèle &1 le numéro d'ordre du poste doit être inférieur à 998
    else if fisnull(ttPosteBudgetaire.cLibellePoste)
    then mError:createError({&error}, 106447). // 106447 Le libellé du poste budgétaire est obligatoire
    else if ttPosteBudgetaire.lRubriqueCalculee
    then do:
        if fisnull(ttPosteBudgetaire.cListeRubrique)
        then mError:createError({&error}, 109071). // 109071 Rubrique de Calcul sans poste impossible
        else do:
            vcListe = replace(replace(ttPosteBudgetaire.cListeRubrique, "+", ""), "-", "").
boucle:
            do viI1 = 1 to num-entries(vcListe):
                viOrdre = integer(entry(viI1, vcListe)) no-error.
                if error-status:error
                then mError:createError({&error}, 1000597, entry(viI1,vcListe)). // 1000597 "Le numéro de poste &1 est incorrect"
                else if viOrdre > ttPosteBudgetaire.iNumeroOrdre
                then mError:createError({&error}, 109073, entry(viI1,vcListe)). // 109073 Numéro d'ordre impossible car il existe une rubrique calculée avec un numéro d'ordre supérieur.
                if mError:Erreur() then leave boucle.
            end.
        end.
    end.
    if mError:Erreur() then return.

    run controleFiscalite(ttPosteBudgetaire.iNumeroModele, ttPosteBudgetaire.iNumeroPoste).
end procedure.


procedure controleFiscalite private:
    /*------------------------------------------------------------------------------
    Purpose: Verification si rubriques et fiscalité sont paramétréesd'autres postes du modèle
    Notes  : procédure verselfisc de cabt/defpstbl.p
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroModele as integer no-undo.
    define input parameter piNumeroPoste  as integer no-undo.

    define variable viNumeroFiscalite as integer no-undo.
    define buffer repaqbl for repaqbl.
    define buffer rgpbl   for rgpbl.

 boucle:
    for each ttRubriqueBudgetaire
        where ttRubriqueBudgetaire.iNumeroModele       = piNumeroModele
          and ttRubriqueBudgetaire.iNumeroPoste        = piNumeroPoste
          and ttRubriqueBudgetaire.cTypeENregistrement = "A":
        // On cherche si la rubrique en cours est utilisée par un autre poste du même groupe et ce code fiscal
        for each repaqbl no-lock
            where repaqbl.noGrp  = piNumeroModele
              and repaqbl.noPost <> piNumeroPoste
              and repaqbl.tpRub  = "A"
              and repaqbl.cdRub  = ttRubriqueBudgetaire.iCodeRubrique
              and repaqbl.cdSrb  = ttRubriqueBudgetaire.iCodeSousRubrique
           , first rgpbl no-lock
             where rgpbl.tpenr  = "P"
               and rgpbl.noGrp  = piNumeroModele
               and rgpbl.noPost = repaqbl.noPost:
            viNumeroFiscalite = 0.
            if ttPosteBudgetaire.lFiscalite1      and (num-entries(rgpbl.fisc-cle) < 4 or entry(1, rgpbl.fisc-cle) <> "N")
            then viNumeroFiscalite = 1.
            else if ttPosteBudgetaire.lFiscalite2 and (num-entries(rgpbl.fisc-cle) < 4 or entry(2, rgpbl.fisc-cle) <> "N")
            then viNumeroFiscalite = 2.
            else if ttPosteBudgetaire.lFiscalite3 and (num-entries(rgpbl.fisc-cle) < 4 or entry(3, rgpbl.fisc-cle) <> "N")
            then viNumeroFiscalite = 3.
            else if ttPosteBudgetaire.lFiscalite4 and (num-entries(rgpbl.fisc-cle) < 4 or entry(4, rgpbl.fisc-cle) <> "N")
            then viNumeroFiscalite = 4.
            if viNumeroFiscalite > 0 then do:
                mError:createError({&error},
                                   1000602,
                                   substitute("&1&2&1&3&1&4&1&5&1&6",
                                              separ[1],
                                              string(ttRubriqueBudgetaire.iCodeRubrique, "999"),
                                              string(ttRubriqueBudgetaire.iCodeSousRubrique, "999"),
                                              viNumeroFiscalite,
                                              string(rgpbl.noord, "999"),
                                              rgpbl.lbenr)). // 1000602 La rubrique &1-&2 est déjà utilisée avec le code fiscal &3 pour le poste No &4 <&5>.
                leave boucle.
            end.
        end.
    end.
end procedure.

procedure verBudgetLocatif:
    /*------------------------------------------------------------------------------
    Purpose: Controle Budget Locatif (modele et poste)
    Notes  : service
    ------------------------------------------------------------------------------*/
    define input parameter table for ttModeleBudgetaire.
    define input parameter table for ttPosteBudgetaire.
    define input parameter table for ttRubriqueBudgetaire.

boucle :
    for each ttModeleBudgetaire:
        if lookup(ttModeleBudgetaire.CRUD, "C,U") > 0 or ttModeleBudgetaire.lControle
        then do:
            run controleModele.
            if mError:Erreur() then leave boucle.
        end.
        for each ttPosteBudgetaire
            where (lookup(ttPosteBudgetaire.CRUD, "C,U") > 0 or ttPosteBudgetaire.lControle)
              and ttPosteBudgetaire.iNumeroModele = ttModeleBudgetaire.iNumeroModele:
            run controlePoste.
            if mError:Erreur() then leave boucle.
        end.
    end.
end procedure.

procedure updateBudgetLocatif:
    /*------------------------------------------------------------------------------
    Purpose: Controle et validation des Modeles Budgetaire
    Notes  : Service externe appelé par beParametreGestionImmo.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttModeleBudgetaire.
    define input parameter table for ttPosteBudgetaire.
    define input parameter table for ttRubriqueBudgetaire.

blocTrans:
    do transaction:
        run controle.
        if merror:erreur() then undo blocTrans, return.

        run majTt.
        run validation.
        if merror:erreur() then undo blocTrans, return.
    end.
end procedure.

procedure crettPosteBudgetaire private:
    /*------------------------------------------------------------------------------
    Purpose: creation temp-table ttPosteBudgetaire
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroModele    as integer   no-undo.
    define input parameter piNumeroOrdre     as integer   no-undo.
    define input parameter pcLibelle         as character no-undo.
    define input parameter pcCommentaire1    as character no-undo.
    define input parameter pcCommentaire2    as character no-undo.
    define input parameter plRubriqueCalcule as logical   no-undo.
    define input parameter pcListeRubrique   as character no-undo.
    define input parameter plAna1            as logical   no-undo.
    define input parameter plAna2            as logical   no-undo.
    define input parameter plAna3            as logical   no-undo.
    define input parameter plAna4            as logical   no-undo.

    define variable viDernierPoste as integer initial 0 no-undo.

    // Prochain numero interne de poste
lastPoste:
    for each ttPosteBudgetaire
        where ttPosteBudgetaire.iNumeroModele = piNumeroModele
        by ttPosteBudgetaire.iNumeroPoste descending:
        viDernierPoste = ttPosteBudgetaire.iNumeroPoste.
        leave lastPoste.
    end.
    create ttPosteBudgetaire.
    assign
        ttPosteBudgetaire.CRUD                = "C"
        ttPosteBudgetaire.iNumeroModele       = piNumeroModele
        ttPosteBudgetaire.cTypeEnregistrement = "P"
        ttPosteBudgetaire.cLibellePoste       = pcLibelle
        ttPosteBudgetaire.cCommentaire[1]     = pcCommentaire1
        ttPosteBudgetaire.cCommentaire[2]     = pcCommentaire2
        ttPosteBudgetaire.iNumeroPoste        = viDernierPoste + 1
        ttPosteBudgetaire.iNumeroOrdre        = piNumeroOrdre
        ttPosteBudgetaire.lRubriqueCalcule    = plRubriqueCalcule
        ttPosteBudgetaire.cListeRubrique      = pcListeRubrique when     plRubriqueCalcule
        ttPosteBudgetaire.lFiscalite1         = plAna1          when not plRubriqueCalcule
        ttPosteBudgetaire.lFiscalite2         = plAna2          when not plRubriqueCalcule
        ttPosteBudgetaire.lFiscalite3         = plAna3          when not plRubriqueCalcule
        ttPosteBudgetaire.lFiscalite4         = plAna4          when not plRubriqueCalcule
        ttPosteBudgetaire.lNouveau            = true
    .
end procedure.

procedure majTt private:
    /*------------------------------------------------------------------------------
    Purpose: Mise à jour des champs complémentaires
    Notes  :
    ------------------------------------------------------------------------------*/
    for each ttModeleBudgetaire
        where lookup(ttModeleBudgetaire.CRUD, "C,U,D") > 0:
        assign
            ttModeleBudgetaire.cTypeEnregistrement = "G"
            ttModeleBudgetaire.iNumeroPoste        = 0
        .
    end.
    for each ttPosteBudgetaire
        where lookup(ttPosteBudgetaire.CRUD, "C,U,D") > 0:
        assign
            ttPosteBudgetaire.cTypeEnregistrement = "P"
            ttPosteBudgetaire.lbdiv               = (if ttPosteBudgetaire.lRubriqueCalculee
                                                     then ("TRUE" + separ[1] + ttPosteBudgetaire.cListeRubrique)
                                                     else "")
            ttPosteBudgetaire.fisc-cle            = (if ttPosteBudgetaire.lRubriqueCalculee
                                                     then "*"
                                                     else substitute("&1,&2,&3,&4",
                                                         string(ttPosteBudgetaire.lFiscalite1, "O/N"),
                                                         string(ttPosteBudgetaire.lFiscalite2, "O/N"),
                                                         string(ttPosteBudgetaire.lFiscalite3, "O/N"),
                                                         string(ttPosteBudgetaire.lFiscalite4, "O/N")))
        .
    end.
    for each ttRubriqueBudgetaire
        where lookup(ttRubriqueBudgetaire.CRUD, "C,U,D") > 0:
        assign
            ttRubriqueBudgetaire.iNumeroTri        = 0
            ttRubriqueBudgetaire.iCodeSousRubrique = 0 when ttRubriqueBudgetaire.cTypeEnregistrement = "Q"
        .
    end.
end procedure.

procedure validation private:
    /*------------------------------------------------------------------------------
    Purpose: Validation
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProcrgpbl   as handle no-undo.
    define variable vhProcrepaqbl as handle no-undo.

    run adblib/rgpbl_CRUD.p persistent set vhProcrgpbl.
    run getTokenInstance in vhProcrgpbl(mToken:JSessionId).
    run setrgpbl         in vhProcrgpbl(table ttModeleBudgetaire   by-reference).
    run destroy          in vhProcrgpbl.

    run adblib/rgpbl_CRUD.p persistent set vhProcrgpbl. // meme programmme mais table différente
    run getTokenInstance in vhProcrgpbl(mToken:JSessionId).
    run setrgpbl         in vhProcrgpbl(table ttPosteBudgetaire    by-reference).
    run destroy          in vhProcrgpbl.

    run adblib/repaqbl_CRUD.p persistent set vhProcrepaqbl.
    run getTokenInstance in vhProcrepaqbl(mToken:JSessionId).
    run setrepaqbl       in vhProcrepaqbl(table ttRubriqueBudgetaire by-reference).
    run destroy          in vhProcrepaqbl.

    error-status:error = false no-error.  // reset error-status
    return.

end procedure.
