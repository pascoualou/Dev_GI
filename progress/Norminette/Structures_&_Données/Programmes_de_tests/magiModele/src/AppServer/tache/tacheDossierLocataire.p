/*-----------------------------------------------------------------------------
File        : tacheDossierLocataire.p
Purpose     : Tâche Dossier Locataire dans bail
Author(s)   : npo - 2017/10/19
Notes       : à partir de adb\src\tache\prmbxdol.p
derniere revue: 2018/03/20 - phm
-----------------------------------------------------------------------------*/
{preprocesseur/categorie2bail.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageRelocation.
using parametre.pclie.parametrageDossierLocataire.
using parametre.syspg.syspg.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/combo.i}
{application/include/glbsepar.i}
{tache/include/tacheDossierLocataire.i}
{tache/include/tache.i}
{adblib/include/cttac.i}

procedure getTacheDossierLocataire:
    /*------------------------------------------------------------------------------
    Purpose: gère à la fois l'initialisation (create) et le get
    Notes  : service externe (beBail.cls et bePrebail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat as int64     no-undo.
    define input  parameter pcTypeContrat   as character no-undo.
    define output parameter table for ttTacheDossierLocataire.

    define variable vcCategorieBail         as character no-undo.
    define variable vcListePieceObligatoire as character no-undo.
    define variable viNombrePieces          as integer   no-undo.
    define variable viPositionPiece         as integer   no-undo.
    define variable viNombrePiecesMax       as integer   no-undo.
    define variable vczon02                 as character no-undo.
    define variable vczon03                 as character no-undo.
    define variable voRelocation            as class parametrageRelocation       no-undo.
    define variable voDossierLocataire      as class parametrageDossierLocataire no-undo.
    define variable voSyspg                 as class syspg                       no-undo.

    define buffer ctrat  for ctrat.
    define buffer tache  for tache.

    empty temp-table ttTacheDossierLocataire.               
    if not can-find(first ctrat no-lock
                    where ctrat.tpcon = pcTypeContrat
                      and ctrat.nocon = piNumeroContrat) then do:
        mError:createError({&error}, 100057).
        return.
    end.   
    assign
        voRelocation       = new parametrageRelocation()
        voDossierLocataire = new parametrageDossierLocataire()
    .
    if pcTypeContrat = {&TYPECONTRAT-preBail} and voRelocation:isActif()
    then for first ctrat no-lock
        where ctrat.tpcon = pcTypeContrat
          and ctrat.nocon = piNumeroContrat:
        // Sélection sur la nature du contrat
        voSyspg = new syspg().
        voSyspg:reloadZone2("R_CBA", ctrat.ntcon).
        if voSyspg:zone1 = {&CATEGORIE2BAIL-Commercial} then vcCategorieBail = "COM".
        if voSyspg:zone1 = {&CATEGORIE2BAIL-Habitation} then vcCategorieBail = "HAB".
        delete object voSyspg.
    end.
    delete object voRelocation.
    find first tache no-lock
        where tache.tpcon = pcTypeContrat
          and tache.nocon = piNumeroContrat
          and tache.tptac = {&TYPETACHE-dossierLocataire} no-error.
    if voDossierLocataire:isDbParameter then do:
        assign
            vcListePieceObligatoire = voDossierLocataire:getListePiecesObligatoires(vcCategorieBail)
            viNombrePiecesMax       = voDossierLocataire:getNombrePieces()
            vczon02                 = voDossierLocataire:zon02
            vczon03                 = voDossierLocataire:zon03
        .
        do viNombrePieces = 1 to viNombrePiecesMax:
            /*= On cherche a savoir si le numero de piece traitée apparait pour ce dossier      =*/ 
            /*= locataire(gestion en dynamique de l'ajout de ligne dans le parametrage client   =*/
            /*= NO-ERROR Pour eviter message sur tache indisponible lorque l'on active la tache =*/
            assign
                viPositionPiece = 0    // dans une boucle, si assign no-error, pas de reset de la variable !!!!
                viPositionPiece = lookup(entry(viNombrePieces, vczon02, separ[1]), tache.cdreg, separ[1])
            no-error.
            create ttTacheDossierLocataire.
            assign
                ttTacheDossierLocataire.iNumeroTache     = (if available tache then tache.noita else 0)
                ttTacheDossierLocataire.cTypeContrat     = pcTypeContrat
                ttTacheDossierLocataire.iNumeroContrat   = piNumeroContrat
                ttTacheDossierLocataire.cTypeTache       = {&TYPETACHE-dossierLocataire}
                ttTacheDossierLocataire.iChronoTache     = (if available tache then tache.notac else 0)
                ttTacheDossierLocataire.daLettre         = (if available tache then tache.dtdeb else today)
                ttTacheDossierLocataire.daRelance        = (if available tache then tache.dtfin else ?)
                ttTacheDossierLocataire.iNumeroPiece     = integer(entry(viNombrePieces, vczon02, separ[1]))
                ttTacheDossierLocataire.cLibellePiece    = entry(viNombrePieces, vczon03, separ[1])
                ttTacheDossierLocataire.cFlagObligatoire = outilTraduction:getLibelleParam("CDOUI", entry(viNombrePieces, vcListePieceObligatoire, separ[1]))
                ttTacheDossierLocataire.cFlagRemise      = (if available tache and viPositionPiece > 0 and num-entries(tache.ntreg, separ[1]) >= viPositionPiece 
                                                            then outilTraduction:getLibelleParam("CDOUI", entry(viPositionPiece, tache.ntreg, separ[1]))
                                                            else outilTraduction:getLibelleParam("CDOUI", "00002"))
                ttTacheDossierLocataire.daDateRemise     = (if available tache and viPositionPiece > 0 and num-entries(tache.pdreg, separ[1]) >= viPositionPiece 
                                                            then date(entry(viPositionPiece, tache.pdreg, separ[1]))
                                                            else ?)
                ttTacheDossierLocataire.dtTimestamp      = datetime(tache.dtmsy, tache.hemsy) when available tache
                ttTacheDossierLocataire.CRUD             = if available tache then 'R' else 'C'
                ttTacheDossierLocataire.rRowid           = rowid(tache) when available tache
            .
        end.
    end.
    delete object voDossierLocataire.

end procedure.

procedure setTacheDossierLocataire:
    /*------------------------------------------------------------------------------
    Purpose: maj tache (a partir de la table ttTacheDossierLocataire en fonction du CRUD)
    Notes  : service externe (beBail.cls et bePrebail.cls)
    ------------------------------------------------------------------------------*/
    define input parameter table for ttTacheDossierLocataire.

    define buffer tache for tache.

    for first ttTacheDossierLocataire
        where lookup(ttTacheDossierLocataire.CRUD, "C,U,D") > 0:
        if not can-find(first ctrat no-lock
                        where ctrat.tpcon = ttTacheDossierLocataire.cTypeContrat
                          and ctrat.nocon = ttTacheDossierLocataire.iNumeroContrat)
        then do:
            mError:createError({&error}, 100057).
            return.
        end.
        run verZonSai(buffer ttTacheDossierLocataire).
        if mError:erreur() then return.
        run majTache.
    end.

end procedure.

procedure createTacheDossierLocataire:
    /*------------------------------------------------------------------------------
    Purpose: preparation table Dossier locataire avec information par defaut
    Notes  : service externe (beBail.cls et bePrebail.cls)
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroContrat  as integer   no-undo.
    define input  parameter pcTypeContrat    as character no-undo.
    define output parameter table for ttTacheDossierLocataire.

    run getTacheDossierLocataire (piNumeroContrat, pcTypeContrat, output table ttTacheDossierLocataire).

end procedure.

procedure majTache private:
    /*------------------------------------------------------------------------------
    Purpose: maj tache (creation table ttTache a partir table specifique tache (ici ttTacheDossierLocataire)
             et appel du programme commun de maj des taches (tache/tache.p)
             si maj tache correcte appel maj table relation contrat tache (cttac).
             Pas de gestion de la suppression
    Notes  :
    ------------------------------------------------------------------------------*/ 
    define variable vhProc               as handle    no-undo.
    define variable vcListeNumeroPieces  as character no-undo.
    define variable vcFlagPiece          as character no-undo.
    define variable vcListeFlagOuiNon    as character no-undo.
    define variable vcListeDateLivraison as character no-undo.

    define buffer cttac for cttac.

    /* On Boucle sur la table temporaire et on initialise les zone de sortie dans tache */
    /* Gestion en dynamique de l'ajout de ligne dans le parametrage client              */
    /* Cdreg = Liste des N° pieces                                                      */
    /* NtReg = Liste des flag pour les pieces fournies(oui="00001", non="00002")        */
    /* PdReg = Liste des dates de livraison                                             */
    for each ttTacheDossierLocataire:
        assign
            vcFlagPiece          = if ttTacheDossierLocataire.cFlagRemise = "Oui" then "00001" else "00002"
            vcListeNumeroPieces  = substitute("&1&2&3", vcListeNumeroPieces, separ[1], string(ttTacheDossierLocataire.iNumeroPiece, "999"))
            vcListeFlagOuiNon    = substitute("&1&2&3", vcListeFlagOuiNon, separ[1], vcFlagPiece)
            vcListeDateLivraison = substitute("&1&2&3", vcListeDateLivraison, separ[1], ttTacheDossierLocataire.daDateRemise)
        .
    end.
    assign
        vcListeNumeroPieces  = trim(vcListeNumeroPieces,  separ[1])
        vcListeFlagOuiNon    = trim(vcListeFlagOuiNon,    separ[1])
        vcListeDateLivraison = trim(vcListeDateLivraison, separ[1])
    .
    for first ttTacheDossierLocataire
        where lookup(ttTacheDossierLocataire.CRUD, "C,U,D") > 0:
        empty temp-table ttTache.
        create ttTache.
        assign
            ttTache.noita       = ttTacheDossierLocataire.iNumeroTache
            ttTache.tpcon       = ttTacheDossierLocataire.cTypeContrat
            ttTache.nocon       = ttTacheDossierLocataire.iNumeroContrat
            ttTache.tptac       = ttTacheDossierLocataire.cTypeTache
            ttTache.notac       = ttTacheDossierLocataire.iChronoTache
            tttache.dtdeb       = ttTacheDossierLocataire.daLettre
            tttache.dtfin       = ttTacheDossierLocataire.daRelance
            ttTache.cdreg       = vcListeNumeroPieces
            ttTache.ntreg       = vcListeFlagOuiNon
            ttTache.pdreg       = vcListeDateLivraison
            ttTache.CRUD        = ttTacheDossierLocataire.CRUD
            ttTache.dtTimestamp = ttTacheDossierLocataire.dtTimestamp
            ttTache.rRowid      = ttTacheDossierLocataire.rRowid
        .
        run tache/tache.p persistent set vhproc.
        run getTokenInstance in vhproc(mToken:JSessionId).
        run setTache in vhproc(table ttTache by-reference).
        run destroy in vhproc.
        if ttTacheDossierLocataire.CRUD = "C"
        and not can-find(first cttac no-lock
                 where cttac.tpcon = ttTacheDossierLocataire.cTypeContrat
                   and cttac.nocon = ttTacheDossierLocataire.iNumeroContrat
                   and cttac.tptac = ttTacheDossierLocataire.cTypeTache)
        then do:
            empty temp-table ttCttac.
            run adblib/cttac_CRUD.p persistent set vhproc.
            run getTokenInstance in vhproc(mToken:JSessionId).
            create ttCttac.
            assign
                ttCttac.tpcon = ttTacheDossierLocataire.cTypeContrat
                ttCttac.nocon = ttTacheDossierLocataire.iNumeroContrat
                ttCttac.tptac = ttTacheDossierLocataire.cTypeTache
                ttCttac.CRUD  = "C"
            .
            run setCttac in vhproc(table ttCttac by-reference).
            run destroy in vhproc.
        end.
    end.

end procedure.

procedure verZonSai private:
    /*------------------------------------------------------------------------------
    Purpose: Vérification des zones avant maj qui sont obligatoires
    Notes  :
    ------------------------------------------------------------------------------*/
    define parameter buffer ttTacheDossierLocataire for ttTacheDossierLocataire.

    if ttTacheDossierLocataire.daLettre = ? then do:
        mError:createError({&error}, 102296).   // La saisie de la date est obligatoire
        return.
    end.
    if ttTacheDossierLocataire.daRelance = ? then do:
        mError:createError({&error}, 107586).   // La date de relance est obligatoire !
        return.
    end.

end procedure.

procedure initComboTacheDossierLocataire:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : service externe appelé par beBail.cls. 
    ------------------------------------------------------------------------------*/
    define output parameter table for ttCombo.

    run chargeComboCdOui.

end procedure.

procedure chargeComboCdOui private:
    /*------------------------------------------------------------------------------
    Purpose: appel programme pour creation combo OUI/NON
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vhProc   as handle    no-undo.

    empty temp-table ttCombo.
    run application/libelle/labelLadb.p persistent set vhproc.
    run getTokenInstance in vhProc (mToken:JSessionId).
    run getCombolabel in vhProc ("CMBOUINON", output table ttcombo by-reference).
    run destroy in vhProc.

end procedure.
