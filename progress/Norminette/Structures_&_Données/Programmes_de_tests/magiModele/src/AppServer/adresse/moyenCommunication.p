/*------------------------------------------------------------------------
File        : moyenCommunication.p
Description :
Author(s)   : KANTENA  -  2016/12/19
Notes       :
deerniere revue: 2018/05/22 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2bien.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adresse/include/moyenCommunication.i}
{Application/include/glbsepar.i}

procedure getMoyenCommunication:
    /*------------------------------------------------------------------------------
    Purpose: récupère le teléphone bureau, le mobile et le mail
    Notes  : service utilisé par commercialisation.p, immeubleEtLot.p
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeIdentifiant as character no-undo.
    define input  parameter piIdentifiant     as integer   no-undo.
    define input  parameter pcJointure        as character no-undo.
    define output parameter table for ttMoyenCommunication.

    define buffer telephones for telephones.

    for each telephones no-lock
        where telephones.tpidt = pcTypeIdentifiant
          and telephones.noidt = piIdentifiant
          and telephones.notel > "":
        create ttMoyenCommunication.
        assign
            ttMoyenCommunication.CRUD               = "R"
            ttMoyenCommunication.cTypeIdentifiant   = pcTypeIdentifiant
            ttMoyenCommunication.iNumeroIdentifiant = piIdentifiant
            ttMoyenCommunication.iCodeSociete       = telephones.soc-cd
            ttMoyenCommunication.cCodeFournisseur   = telephones.four-cle
            ttMoyenCommunication.cJointure          = pcJointure
            ttMoyenCommunication.iOrdre             = telephones.nopos
            ttMoyenCommunication.cCodeType          = telephones.tptel
            ttMoyenCommunication.cLibelleType       = outilTraduction:getlibelleParam("CDTE2", telephones.tptel)
            ttMoyenCommunication.cCodeMoyen         = telephones.cdtel
            ttMoyenCommunication.cLibelleMoyen      = outilTraduction:getlibelleParam("CDTEL", telephones.cdtel)
            ttMoyenCommunication.cValeur            = telephones.notel
            ttMoyenCommunication.iTypeAdresse       = telephones.libadr-cd
            ttMoyenCommunication.iNumeroAdresse     = telephones.adr-cd
            ttMoyenCommunication.iNumeroContact     = telephones.numero
            ttMoyenCommunication.dtTimestamp        = datetime(telephones.dtmsy, telephones.hemsy)
            ttMoyenCommunication.rRowid             = rowid(telephones)
        .
     end.
end procedure.

procedure dupliqueMoyenCommunication:
    /*------------------------------------------------------------------------------
    Purpose: Duplication des moyens de communication d'un rôle vers un autre rôle
    Notes  : service utilisé par l_roles_ext.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRoleSource   as character no-undo.
    define input parameter piNumeroRoleSource as int64     no-undo.
    define input parameter pcTypeRoleDesti    as character no-undo.
    define input parameter piNumeroRoleDesti  as int64     no-undo.

    define buffer telephones   for telephones.
    define buffer vbtelephones for telephones.

    // test de sécurité
    if not can-find (first ladrs no-lock
        where ladrs.tpidt = pcTypeRoleSource
          and ladrs.noidt = piNumeroRoleSource) then return.

    do transaction on error undo, return:
        for each telephones exclusive-lock
            where telephones.tpidt = pcTypeRoleDesti
              and telephones.noidt = piNumeroRoleDesti:
            delete telephones.
        end.
        for each telephones no-lock
            where telephones.tpidt = pcTypeRoleSource
              and telephones.noidt = piNumeroRoleSource:
            create vbtelephones.
            buffer-copy telephones
                except dtcsy hecsy cdcsy dtmsy hemsy cdmsy tpidt noidt
                    to vbtelephones
                assign
                    vbtelephones.dtcsy = today
                    vbtelephones.hecsy = mtime
                    vbtelephones.cdcsy = mToken:cUser
                    vbtelephones.tpidt = pcTypeRoleDesti
                    vbtelephones.noidt = piNumeroRoleDesti
            .
        end.
    end.

end procedure.

procedure setMoyenCommunicationTiersCommercial:
    /*------------------------------------------------------------------------------
    Purpose: mise à jour table TELEPHONES / ttMoyenCommunication pour les moyens de
             communication de la fiche commerciale
             Pas de moyen de savoir si TIERS = IFOUR ou ROLES donc on lance les 2
             Attention : Annule et Remplace
    Notes  : Service utilisé par beCommercialisation.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttMoyenCommunication.

    if can-find(first ttMoyenCommunication
                where ttMoyenCommunication.cTypeIdentifiant = "FOU")
    then run setMoyenCommunicationFicheFournisseur.
    if can-find(first ttMoyenCommunication
                where ttMoyenCommunication.cTypeIdentifiant <> "FOU")
    then run setMoyenCommunicationGestion.

end procedure.

procedure setMoyenCommunicationFicheFournisseur private:
    /*------------------------------------------------------------------------------
    Purpose: mise à jour table TELEPHONES / ttMoyenCommunication pour les moyens de communication de la fiche fournisseur
    Notes  : Attention : Annule et Remplace
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    /* Au moins un des enregistrements en 'C' ou 'U' ou 'D' */
    find first ttMoyenCommunication
        where ttMoyenCommunication.CRUD <> "R" no-error.
    if not available ttMoyenCommunication then return.

    /*--> Contrôles **/
    if not can-find(first ifour no-lock
        where ifour.soc-cd   = ttMoyenCommunication.iCodeSociete
          and ifour.four-cle = ttMoyenCommunication.cCodeFournisseur)
    then do:
        mError:createError({&error}, 999999, ttMoyenCommunication.cCodeFournisseur).   /* Fournisseur &1 inexistant */
        return.
    end.

    /*--> Annule et remplace : fafours_srv.p Fournisseurs simplifiés
            --> pas de notion d'adresse de paiement ni de tél **/
    for each telephones exclusive-lock
        where telephones.tpidt     = "FOU"
          and telephones.noidt     = integer(ttMoyenCommunication.cCodeFournisseur)
          and telephones.four-cle  = ttMoyenCommunication.cCodeFournisseur
          and telephones.soc-cd    = (if telephones.soc-cd > 0 then ttMoyenCommunication.iCodeSociete else 0)
          and telephones.libadr-cd = 0    /* Numero du fournisseur (ceux de la fiche) */
          and telephones.adr-cd    = 0
          and telephones.numero    = 0:
        delete telephones.
    end.
    for each ttMoyenCommunication
        where ttMoyenCommunication.CRUD <> "D":
        create telephones.
        assign
            telephones.tpidt     = "FOU"
            telephones.noidt     = integer(ttMoyenCommunication.cCodeFournisseur)
            telephones.soc-cd    = ttMoyenCommunication.iCodeSociete
            telephones.nopos     = ttMoyenCommunication.iOrdre
            telephones.tptel     = ttMoyenCommunication.cCodeType
            telephones.cdtel     = ttMoyenCommunication.cCodeMoyen
            telephones.notel     = ttMoyenCommunication.cValeur
            telephones.four-cle  = ttMoyenCommunication.cCodeFournisseur
            telephones.libadr-cd = 0
            telephones.adr-cd    = 0
            telephones.numero    = 0
            telephones.dtcsy     = today
            telephones.hecsy     = mtime
            telephones.cdcsy     = mToken:cUser
            entry(1, telephones.lbdiv, separ[1]) = if ttMoyenCommunication.cCodeMoyen = "00000" then  ttMoyenCommunication.cLibelleMoyen else ""
        .
    end.

    for each ttMoyenCommunication:
        ttMoyenCommunication.CRUD = "R".
    end.

end procedure.

procedure setMoyenCommunicationAdressePaiementFournisseur:
    /*------------------------------------------------------------------------------
    Purpose: mise à jour table TELEPHONES / ttMoyenCommunication pour les moyens de communication de l'onglet 'Adresses'
    TODO   : pas utilisé ??
    Notes  : service?
             Attention : Annule et Remplace
    ------------------------------------------------------------------------------*/
    define input parameter table for ttMoyenCommunication.

    define buffer telephones for telephones.
    define buffer ifour      for ifour.

    /* Au moins un des enregistrements en 'C' ou 'U' ou 'D' */
    find first ttMoyenCommunication
        where ttMoyenCommunication.CRUD <> "R" no-error.
    if not available ttMoyenCommunication then return.

    /*--> Contrôles **/
    if not can-find(first ifour no-lock
        where ifour.soc-cd   = ttMoyenCommunication.iCodeSociete
          and ifour.four-cle = ttMoyenCommunication.cCodeFournisseur)
    then do:
        mError:createError({&error}, 999999, ttMoyenCommunication.cCodeFournisseur).   /* Fournisseur &1 inexistant */
        return.
    end.

    /*--> Annule et remplace va-adfou.w Fournisseurs Onglet 'Adresses' **/
    for each telephones exclusive-lock
        where telephones.tpidt     = "FOU"
          and telephones.noidt     = integer(ttMoyenCommunication.cCodeFournisseur)
          and telephones.four-cle  = ttMoyenCommunication.cCodeFournisseur
          and telephones.soc-cd    = (if telephones.soc-cd > 0 then ttMoyenCommunication.iCodeSociete else 0)
          and telephones.libadr-cd = ttMoyenCommunication.iTypeAdresse
          and telephones.adr-cd    = ttMoyenCommunication.iNumeroAdresse
          and telephones.numero    = 0 :
      delete telephones.
    end.

    for each ttMoyenCommunication
        where ttMoyenCommunication.CRUD <> "D":
        create telephones.
        assign
            telephones.tpidt     = "FOU"
            telephones.noidt     = integer(ttMoyenCommunication.cCodeFournisseur)
            telephones.soc-cd    = ttMoyenCommunication.iCodeSociete
            telephones.nopos     = ttMoyenCommunication.iOrdre
            telephones.tptel     = ttMoyenCommunication.cCodeType
            telephones.cdtel     = ttMoyenCommunication.cCodeMoyen
            telephones.notel     = ttMoyenCommunication.cValeur
            telephones.four-cle  = ttMoyenCommunication.cCodeFournisseur
            telephones.libadr-cd = ttMoyenCommunication.iTypeAdresse
            telephones.adr-cd    = ttMoyenCommunication.iNumeroAdresse
            telephones.numero    = 0
            telephones.dtcsy     = today
            telephones.hecsy     = mtime
            telephones.cdcsy     = mToken:cUser
            entry(1,telephones.lbdiv,separ[1]) = if ttMoyenCommunication.cCodeMoyen = "00000" then  ttMoyenCommunication.cLibelleMoyen else ""
        .
    end.
    for each ttMoyenCommunication:
        ttMoyenCommunication.CRUD = "R".
    end.

end procedure.

procedure setMoyenCommunicationContactFournisseur:
    /*------------------------------------------------------------------------------
    Purpose: mise à jour table TELEPHONES / ttMoyenCommunication pour les moyens de communication de l'onglet 'Contact'
    TODO   : pas utilisé ??
    Notes  : service?  Attention : Annule et Remplace
    ------------------------------------------------------------------------------*/
    define input parameter table for ttMoyenCommunication.

    define buffer telephones for telephones.

    /* Au moins un des enregistrements en 'C' ou 'U' ou 'D' */
    find first ttMoyenCommunication
        where ttMoyenCommunication.CRUD <> "R" no-error.
    if not available ttMoyenCommunication then return.

    /*--> Contrôles **/
    if not can-find(first ifour no-lock
        where ifour.soc-cd   = ttMoyenCommunication.iCodeSociete
          and ifour.four-cle = ttMoyenCommunication.cCodeFournisseur)
    then do:
        mError:createError({&error}, 999999, ttMoyenCommunication.cCodeFournisseur).   /* Fournisseur &1 inexistant */
        return.
    end.

    /* IFOUR telephones du contact va-cotaf.w */
    /*--> Annule et remplace **/
    for each telephones exclusive-lock
        where telephones.tpidt     = "FOU"
          and telephones.noidt     = integer(ttMoyenCommunication.cCodeFournisseur)
          and telephones.four-cle  = ttMoyenCommunication.cCodeFournisseur
          and telephones.soc-cd    = (if telephones.soc-cd > 0 then ttMoyenCommunication.iCodeSociete else 0)
          and telephones.libadr-cd = 0
          and telephones.adr-cd    = 0
          and telephones.numero    = ttMoyenCommunication.iNumeroContact:
        delete telephones.
    end.
    for each ttMoyenCommunication
        where ttMoyenCommunication.CRUD <> "D":
        create telephones.
        assign
            telephones.tpidt     = "FOU"
            telephones.noidt     = integer(ttMoyenCommunication.cCodeFournisseur)
            telephones.soc-cd    = ttMoyenCommunication.iCodeSociete
            telephones.nopos     = ttMoyenCommunication.iOrdre
            telephones.tptel     = ttMoyenCommunication.cCodeType
            telephones.cdtel     = ttMoyenCommunication.cCodeMoyen
            telephones.notel     = ttMoyenCommunication.cValeur
            telephones.four-cle  = ttMoyenCommunication.cCodeFournisseur
            telephones.libadr-cd = 0
            telephones.adr-cd    = 0
            telephones.numero    = ttMoyenCommunication.iNumeroContact
            telephones.dtcsy     = today
            telephones.hecsy     = mtime
            telephones.cdcsy     = mToken:cUser
            entry(1, telephones.lbdiv, separ[1]) = if ttMoyenCommunication.cCodeMoyen = "00000" then  ttMoyenCommunication.cLibelleMoyen else ""
        .
    end.
    for each ttMoyenCommunication:
        ttMoyenCommunication.CRUD = "R".
    end.

end procedure.

procedure setMoyenCommunicationGestion private:
    /*------------------------------------------------------------------------------
    Purpose: mise à jour table TELEPHONES / ttMoyenCommunication
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer telephones for telephones.

    /* Au moins un des enregistrements en 'C' ou 'U' ou 'D' */
    find first ttMoyenCommunication
        where ttMoyenCommunication.CRUD <> "R" no-error.
    if not available ttMoyenCommunication then return.

    /*--> Contrôles **/
    case ttMoyenCommunication.cTypeIdentifiant:
        when {&TYPECONTRAT-serviceGestion}
        then if not can-find(first ctrat no-lock
            where ctrat.tpcon = ttMoyenCommunication.cTypeIdentifiant
              and ctrat.nocon = ttMoyenCommunication.iNumeroIdentifiant) then do:
            mError:createError({&error}, 999999, string(ttMoyenCommunication.iNumeroIdentifiant)).   /* Service de gestion &1 inexistant */
            return.
        end.
        when {&TYPEBIEN-immeuble}
        then if not can-find(first imble no-lock
            where imble.noimm = ttMoyenCommunication.iNumeroIdentifiant) then do:
            mError:createError({&error}, 999999, string(ttMoyenCommunication.iNumeroIdentifiant)).   /* Immeuble &1 inexistant */
            return.
        end.
        when {&TYPEBIEN-lot}
        then if not can-find(first local no-lock
            where local.noloc = ttMoyenCommunication.iNumeroIdentifiant) then do:
            mError:createError({&error}, 999999, string(ttMoyenCommunication.iNumeroIdentifiant)).   /* Lot &1 inexistant */
            return.
        end.
        otherwise if not can-find(first roles no-lock
            where roles.tprol = ttMoyenCommunication.cTypeIdentifiant
              and roles.norol = ttMoyenCommunication.iNumeroIdentifiant) then do:
            mError:createError({&error}, 999999, ttMoyenCommunication.cTypeIdentifiant + string(ttMoyenCommunication.iNumeroIdentifiant)).   /* Rôle &1 inexistant */
            return.
        end.
    end case.

    /*--> Annule et remplace **/
    for each telephones exclusive-lock
        where telephones.tpidt = ttMoyenCommunication.cTypeIdentifiant
          and telephones.noidt = ttMoyenCommunication.iNumeroIdentifiant:
        delete telephones.
    end.

    for each ttMoyenCommunication
        where ttMoyenCommunication.CRUD <> "D":
        create telephones.
        assign
            telephones.tpidt  = ttMoyenCommunication.cTypeIdentifiant
            telephones.noidt  = ttMoyenCommunication.iNumeroIdentifiant
            telephones.soc-cd = 0
            telephones.nopos  = ttMoyenCommunication.iOrdre
            telephones.cdtel  = ttMoyenCommunication.cCodeMoyen
            telephones.tptel  = ttMoyenCommunication.cCodeType
            telephones.notel  = ttMoyenCommunication.cValeur
            telephones.dtcsy  = today
            telephones.hecsy  = mtime
            telephones.cdcsy  = mToken:cUser
        .
    end.
    for each ttMoyenCommunication:
        ttMoyenCommunication.CRUD = "R".
    end.

end procedure.

procedure setMoyenCommunicationImmeuble:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service utilisé par immeuble.p, lot.p
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeRole as character no-undo.
    define input parameter piRole     as integer   no-undo.

    define buffer telephones for telephones.

    for each ttMoyenCommunication
      , first telephones exclusive-lock
        where telephones.noidt = piRole
          and telephones.tpidt = pcTypeRole
          and telephones.nopos = ttMoyenCommunication.iOrdre:
        assign
            telephones.nopos = ttMoyenCommunication.iOrdre
            telephones.tptel = ttMoyenCommunication.cCodeType
            telephones.cdtel = ttMoyenCommunication.cCodeMoyen
            telephones.notel = ttMoyenCommunication.cValeur
        .
    end.
end procedure.
