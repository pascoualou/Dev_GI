/*------------------------------------------------------------------------
File        : versement.p
Description :
Author(s)   : LGI/  -  2017/01/13
Notes       : 
derniere revue: 2018/04/12 - phm: KO
              pour un déploiement, supprimer les messages.
------------------------------------------------------------------------*/
{preprocesseur/actionUtilisateur.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
&SCOPED-DEFINE MAXRETURNEDROWS  200

using parametre.pclie.parametrageTheme.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{role/include/typeRole.i}
{role/include/roleVersement.i}
{application/include/glbsepar.i}
{ged/include/documentGidemat.i}
{ged/include/visibiliteExtranet.i}
{ged/include/versement.i}
{ged/include/recherche.i}
{ged/include/libged.i}
{ged/include/ged.i}
{mandat/include/coloc.i &nomTable=ttColoc}

function fIsNull returns logical(pcString as character):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    return pcString = "" or pcString = ?.
end function.

function f_majRepertoireScanUtilisateur returns logical private:
    /*------------------------------------------------------------------------------
    Purpose: Creation de igedrsur (Liste des utilisateurs par répertoire)
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer igedrusr for igedrusr.
    define buffer tutil    for tutil.

    for each ttRepertoireScanUtilisateur
        where ttRepertoireScanUtilisateur.cNomDossier = ttRepertoireScan.cNomDossier:
        case ttRepertoireScanUtilisateur.CRUD:
            when "D" then for first igedrusr exclusive-lock    /* Suppression des utilisateurs non sélectionnés */
                where igedrusr.nom-doss = ttRepertoireScanUtilisateur.cNomDossier
                  and igedrusr.ident_u  = ttRepertoireScanUtilisateur.cCodeUtilisateur:
                delete igedrusr.
            end.

            when "C" then do:
                find first tutil no-lock
                    where tutil.ident_u = ttRepertoireScanUtilisateur.cCodeUtilisateur no-error.
                if not available tutil then do:
                    mError:createError({&error}, 1000086, ttRepertoireScanUtilisateur.cCodeUtilisateur). /* Utilisateur &1 inexistant  */
                    return false.
                end.
                if not can-find(first igedrusr no-lock
                    where igedrusr.nom-doss = ttRepertoireScanUtilisateur.cNomDossier
                      and igedrusr.ident_u  = ttRepertoireScanUtilisateur.cCodeUtilisateur)
                then do:
                    create igedrusr.
                    assign
                        igedrusr.nom-doss = ttRepertoireScanUtilisateur.cNomDossier
                        igedrusr.ident_u  = ttRepertoireScanUtilisateur.cCodeUtilisateur
                    .
                end.
            end.
        end case.
    end.
    return true.

end function.

function f_creationRepertoireTransfert returns logical private (phProcGidemat as handle):
    /*------------------------------------------------------------------------------
    Purpose: Création des répertoires M:\gi\trans\svg\ged\99999 et M:\gi\trans\svg\ged\99999\filewatcher
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcRepertoire as character no-undo.
    /* Création du répertoire temporaire de transfert FileWatcher --> M:\gi\trans\svg\ged\99999\filewatcher (ou 99999 = refcli) */
    assign
        vcRepertoire        = dynamic-function("f_RepertoireFileWatcher" in phProcGidemat)
        file-info:file-name = vcRepertoire
    .
    if file-info:file-type matches "*D*" then return true.

    mError:createError({&error}, 1000236, vcRepertoire). /* 1000236 le répertoire &1 n'existe pas */
    return false.

end function.

function controleUpdateScan returns logical private:
    /*------------------------------------------------------------------------------
    Purpose: controles champs extranet avant modification
    Notes  :
    ------------------------------------------------------------------------------*/

    if fisNull(ttRepertoireScan.cNomDossier) then do:
        mError:createError({&error}, 1000258). /* Nom du répertoire de scan non renseigné */
        return false.
    end.
    if can-find(first igedrep no-lock
                where igedrep.nom-doss = ttRepertoireScan.cNomDossier
                  and rowid(igedrep) <> ttRepertoireScan.rRowid)
    then do:
        mError:createError({&error}, 1000262, ttRepertoireScan.cNomDossier). /* Dossier &1 déjà existant */
        return false.
    end.
    if fisNull(ttRepertoireScan.cCheminDossier) then do:
        mError:createError({&error}, 1000260, ttRepertoireScan.cNomDossier). /* Chemin scanner du dossier &1 non renseigné */
        return false.
    end.
    if fisNull(ttRepertoireScan.cCheminCorbeille) then return false.

    return true.

end function.

function controleUpdateExtranet returns logical private:
    /*------------------------------------------------------------------------------
    Purpose: controles champs extranet avant modification
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable voTheme as parametrageTheme no-undo.
    
    voTheme = new parametrageTheme(ttDocumentGED.cCodeThemeGiExtranet).
    // Theme giextranet
    if ttDocumentGED.cCodeThemeGiExtranet > "" and not voTheme:isDbParameter
    then do:
        mError:createError({&error}, 1000204, ttDocumentGED.cCodeThemeGiExtranet). /* Thème Giextranet &1 inexistant */
        return false.
    end.
    return true.

end function.

function f_zipfile returns character private (pcNomCompletFichierAZipper as character, pcNomFichier as character, pcExtension as character):
    /*------------------------------------------------------------------------------
    Purpose: zip d'un fichier ged
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcRepertoireTmp        as character no-undo.
    define variable vc7Zip                 as character no-undo.
    define variable vcNomDossierTemporaire as character no-undo.
    define variable vcNomArchive           as character no-undo.
    define variable vcNomCompletArchive    as character no-undo.

    if mToken:getValeur('REPGI') = ? then do:
        mError:createError({&error}, 1000255, substitute("REPGI&1(magitoken)&1", separ[1])). /* Le paramètre &1 n'est pas renseigné &2 &3 */
        return "".
    end.
    assign
        vcRepertoireTmp        = substitute("&1&3&2",
                                            right-trim(replace(mToken:getValeur('REPGI'), "/", outils:separateurRepertoire()), outils:separateurRepertoire()),
                                            substitute("gest&1tmp", outils:separateurRepertoire()),
                                            outils:separateurRepertoire())
        vc7Zip                 = substitute("&1&3&2",  right-trim(replace(mToken:getValeur('REPGI'), "/", outils:separateurRepertoire()), outils:separateurRepertoire()),
                                            substitute("exe&17-zip&17z.exe", outils:separateurRepertoire()),
                                            outils:separateurRepertoire())
        vcNomArchive           = substitute("&1.&2.7z", pcNomFichier, pcExtension)    /* ex 500.pdf.7z */
        vcNomDossierTemporaire = substitute("&1&4&2.&3", vcRepertoireTmp, pcNomFichier, pcExtension,outils:separateurRepertoire())  /* ex: M:\gidev\gest\tmp\500.pdf */
        vcNomCompletArchive    = substitute("&1&3&2", vcRepertoireTmp, vcNomArchive, outils:separateurRepertoire())                 /* ex M:\gidev\gest\tmp\500.pdf.7z */
    .
    os-delete value(vcNomCompletArchive) no-error.
    if search(vcNomCompletArchive) <> ? then do:
        mError:createError({&error}, 1000237, vcNomCompletArchive). /* Erreur en suppression du fichier &1 */
        error-status:error = false no-error.
        return "".
    end.
    /****/
    os-delete value(vcNomDossierTemporaire) no-error.
    if search(vcNomDossierTemporaire) <> ? then do:
        mError:createError({&error}, 1000238, vcNomDossierTemporaire). /* Erreur en suppression du répertoire &1 */
        error-status:error = false no-error.
        return "".
    end.
    /****/
    os-create-dir value(vcNomDossierTemporaire).
    file-info:file-name = vcNomDossierTemporaire.
    if file-info:file-type = ? or not file-info:file-type matches "*D*" then do:
        mError:createError({&error}, 1000239, vcNomDossierTemporaire). /* Erreur en création du dossier &1 */
        error-status:error = false no-error.
        return "".
    end.
    /****/
    os-copy value(pcNomCompletFichierAZipper) value(substitute("&1&2GED", vcNomDossierTemporaire, outils:separateurRepertoire())).
    if search(substitute("&1&2GED", vcNomDossierTemporaire, outils:separateurRepertoire())) = ? then do:
        mError:createError({&error}, 1000234, substitute("&1&4&2&5GED&4&3", pcNomCompletFichierAZipper, vcNomDossierTemporaire, "", separ[1],outils:separateurRepertoire())).  /* Erreur de copie du fichier &1 vers &2 &3 */
        return "".
    end.
    /****/
    os-command silent value(substitute("&1 a &2  &3&4GED", vc7Zip, vcNomCompletArchive, vcNomDossierTemporaire, outils:separateurRepertoire())).
    if search(vcNomCompletArchive) = ? then do:
        mError:createError({&error}, 1000240, vcNomCompletArchive).  /* Erreur en création de l'archive &1 */
        mError:createError({&error}, 1000241, substitute("&1 a &2  &3&4GED", vc7Zip, vcNomCompletArchive, vcNomDossierTemporaire, outils:separateurRepertoire())).  /* Commande &1 */
        return "".
    end.
    /***/
    os-delete value(substitute("&1&2GED", vcNomDossierTemporaire, outils:separateurRepertoire())).
    if search(substitute("&1&2GED", vcNomDossierTemporaire, outils:separateurRepertoire())) <> ? then do:
        mError:createError({&error}, 1000237, substitute("&1&2GED", vcNomDossierTemporaire, outils:separateurRepertoire())). /* Erreur en suppression du fichier &1 */
        return "".
    end.
    /***/
    os-delete value(vcNomDossierTemporaire).
    if search(vcNomDossierTemporaire) <> ? then do:
        mError:createError({&error}, 1000238, vcNomDossierTemporaire). /* Erreur en suppression du répertoire &1 */
        return "".
    end.
    return vcNomCompletArchive.
end function.

function f_creationDansDossierTransfert returns logical private(pcTypeTransfert as character, pcNomCompletFichierOrigine as character, pcNomFichierDestination as character, phProcGidemat as handle):
    /*------------------------------------------------------------------------------
    Purpose:  copie du fichier dans le répertoire fileWatcher si immediat ou ged si differé
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcRepertoireDestination as character no-undo.

    if mToken:getValeur('REPGI') = ? then do:
        mError:createError({&error}, 1000255, substitute("REPGI&1(magitoken)&1", separ[1])). /* Le paramètre &1 n'est pas renseigné &2 &3 */
        return false.
    end.
    vcRepertoireDestination = dynamic-function(if pcTypeTransfert = "I" then "f_RepertoireFileWatcher" else "f_repertoireGed" in phProcGidemat).
    os-copy value(pcNomCompletFichierOrigine) value(substitute("&1&3&2", vcRepertoireDestination, pcNomFichierDestination,outils:separateurRepertoire())).
    if search(substitute("&1&3&2", vcRepertoireDestination, pcNomFichierDestination,outils:separateurRepertoire())) = ? then do:
        mError:createError({&error}, 1000234, substitute("&1&5&2&6&3&5&4", pcNomCompletFichierOrigine, vcRepertoireDestination, pcNomFichierDestination, "", separ[1], outils:separateurRepertoire())). /* Erreur de copie du fichier &1 vers &2 &3 */
        return false.
    end.
    return true.
end function.

function f_copieVersDossierGed returns logical private(pcNomFichierACopier as character, phProcGidemat as handle):
    /*------------------------------------------------------------------------------
    Purpose: copie du fichier du répertoire filewatcher vers répertoire ged
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcRepertoireFileWatcher as character no-undo.
    define variable vcRepertoireGed         as character no-undo.
    define variable vcFileFrom              as character no-undo.
    define variable vcFileTo                as character no-undo.
    define buffer igeddoc for igeddoc.

    assign
        vcRepertoireFileWatcher = dynamic-function("f_RepertoireFileWatcher" in phProcGidemat)
        vcRepertoireGed         = dynamic-function("f_repertoireGed" in phProcGidemat)
        vcFileFrom              = substitute('&1&3&2', vcRepertoireFileWatcher, pcNomFichierACopier, outils:separateurRepertoire())
        vcFileTo                = substitute('&1&3&2', vcRepertoireGed,         pcNomFichierACopier, outils:separateurRepertoire())
    .
    etime(true).
attente:
    repeat:
        find first igeddoc exclusive-lock
            where igeddoc.id-fich = int64(entry(1, pcNomFichierACopier, ".")) no-error no-wait.
        if locked(igeddoc) then do:

message "Fichier locke, attente... ". 

            if etime >= 10000 then do : // 10 secondes
                mError:createErrorComplement({&error}, 211652, substitute("&1 &2","igeddoc", int64(entry(1, pcNomFichierACopier, "."))), igeddoc.ident_u). // 211652 0 "modification de l'enregistrement [&1] impossible. Enregistrement verrouillé par un autre utilisateur."

message "Toujours locke --> sortie".

                return false. // 10 secondes
            end.

message "pause 1 seconde".

            pause 1.
            next attente.
        end.            
        else if available igeddoc then do :
            if igeddoc.statut-cd <> "3" then do :
message substitute("fichier &1 statut &2", igeddoc.id-fich, igeddoc.statut-cd).
                /** Ne pas envoyer de retour à l'IHM pour l'instant debug, nodejs en cours...
		
                mError:createErrorComplement({&error}
                                 , 1000257 // 1000257 "Identifiant GED &1"
                                 , substitute("&1 &2 &3 &4"
                                            , igeddoc.id-fich
                                            , outilTraduction:getLibelle(103265) // 103265 Statut
                                            , "="
                                            , igeddoc.statut-cd)
                                 , igeddoc.ident_u).  
                **/                                 
                return false.
            end.                        
            leave attente.
        end.                    
        else do :
            message "igeddoc inexistant.".
            mError:createError({&error}, 1000245, string(int64(entry(1, pcNomFichierACopier, ".")))). // 1000245 "ID GED &1 inexistant"                    
            return false.
            
        end.                                    
    end.         
    igeddoc.statut-cd = "2". /* 1 = transféré, 2 = non transféré (dossier GED), 3 = Dossier FileWatcher */

message "Statut mis à jour" igeddoc.statut-cd.

    if search(vcFileFrom) = ? then do:
        mError:createErrorComplement({&error}, 1000243, vcFileFrom, igeddoc.ident_u). /* Le fichier &1 est inexistant. */
        return false.
    end.
    os-copy value(vcFileFrom) value(vcFileTo).
    if search(vcFileTo) = ? then do:
        mError:createErrorComplement({&error}, 1000234, substitute("&1&4&2&4&3", vcFileFrom, vcFileTo, "", separ[1]), igeddoc.ident_u). /* Erreur de copie du fichier &1 vers &2 &3 */
        return false.
    end.
    os-delete value(vcFileFrom).
    if error-status:error or search(vcFileFrom) > "" then do:
        message substitute(outilTraduction:getLibelle(1000237), vcFileFrom). // message à laisser en production
        mError:createErrorComplement({&error}, 1000237, vcFileFrom, igeddoc.ident_u). /* Erreur en suppression du fichier &1 */
        if search(vcFileFrom) > "" then os-delete value(vcFileTo) no-error. // on éventuellement supprime le fichier de destination (../ged) si le fichier d'origine (../FileWatcher) est tjrs présent
        return false.
    end.
    return true.

end function.

function controleCreateUpdateGed returns logical private:
    /*------------------------------------------------------------------------------
    Purpose: controles avant Creation/Modification d'un document ged
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vlTrouve as logical no-undo.
    define variable voTheme as parametrageTheme no-undo.

    define buffer ietab    for ietab.
    define buffer unite    for unite.
    define buffer cpuni    for cpuni.
    define buffer ctctt    for ctctt.
    define buffer intnt    for intnt.
    define buffer ctrat    for ctrat.
    define buffer vbctrat  for ctrat.
    define buffer tache    for tache.
    define buffer igedtypd for igedtypd.

    if not can-find(first ttAttributChamps) then do:
        mError:createError({&error}, 1000210, "ttAttributChamps"). /* &1 inexistant */
        return false.
    end.
    /* Theme ged */
    voTheme = new parametrageTheme(ttDocumentGED.cCodeThemeGed).
    if ttDocumentGED.cCodeThemeGed > ""
    then do:
        if not voTheme:isDbParameter then do:
            mError:createError({&error}, 1000203, ttDocumentGED.cCodeThemeGed). /* Thème ged &1 inexistant */
            return false.
        end.
    end.
    else if can-find(first ttAttributChamps where ttAttributChamps.cNomChamp = "theme" and ttAttributChamps.lObligatoire)
    then do:
        mError:createError({&error}, 1000207, outilTraduction:getLibelle(1000177)). /* Thème obligatoire */
        return false.
    end.
    /* objet */
    if fisNull(ttDocumentGED.cObjet) then do:
        mError:createError({&error}, 1000205). /* objet obligatoire */
        return false.
    end.
    /* tiers */
    if ttDocumentGED.iNumeroTiers = 0 and ttDocumentGED.iCodeTypeRole = 0 and ttDocumentGED.iNumeroRole = 0
    and can-find(first ttAttributChamps where ttAttributChamps.cNomChamp = "tiers" and ttAttributChamps.lObligatoire)
    then do:
        mError:createError({&error}, 1000207, outilTraduction:getLibelle(900088)). /* &1 obligatoire (tiers)*/
        return false.
    end.
    if ttDocumentGED.iNumeroTiers <> 0 and not can-find(first tiers no-lock where tiers.notie = ttDocumentGED.iNumeroTiers) then do:
        mError:createError({&error}, 1000206, string(ttDocumentGED.iNumeroTiers)). /* Tiers &1 introuvable */
        return false.
    end.
    if ttDocumentGED.iCodeTypeRole > 0 and ttDocumentGED.iNumeroRole > 0
    and not can-find(first roles no-lock
                     where roles.tprol = string(ttDocumentGED.iCodeTypeRole, "99999")
                       and roles.norol = ttDocumentGED.iNumeroRole)
    then do:
        mError:createError({&error}, 1000208, substitute("&1 - &2", string(ttDocumentGED.iCodeTypeRole, "99999"), string(ttDocumentGED.iNumeroRole))). /* Role &1 inexistant */
        return false.
    end.
    if (ttDocumentGED.cCodeTypeContrat > "" or ttDocumentGED.iNumeroContrat <> 0)
    and not can-find(first ctrat no-lock
                     where ctrat.tpcon = ttDocumentGED.cCodeTypeContrat
                       and ctrat.nocon = ttDocumentGED.iNumeroContrat)
    then do:
        mError:createError({&error}, 1000209, substitute("&1 - &2", ttDocumentGED.cCodeTypeContrat, string(ttDocumentGED.iNumeroContrat))). /* contrat &1 inexistant */
        return false.
    end.

    /* Mandat */
    if ttDocumentGED.iNumeroMandat <> 0 then do:
        find first ietab no-lock
            where ietab.Soc-cd  = ttDocumentGED.iCodeReferenceSociete
              and ietab.etab-cd = ttDocumentGED.iNumeroMandat no-error.
        if not available ietab
        then do:
            mError:createError({&error}, 1000353). /* Mandat inexistant */
            return false.
        end.
    end.
    else if can-find(first ttAttributChamps where ttAttributChamps.cNomChamp = "mandat" and ttAttributChamps.lObligatoire)
    then do:
        mError:createError({&error}, 1000207, outilTraduction:getLibelle(100302)). /* Mandat obligatoire */
        return false.
    end.

    /* immeuble */
    if ttDocumentGED.iNumeroImmeuble <> 0
    then do:
        if not can-find(first imble no-lock where imble.noimm = ttDocumentGED.iNumeroImmeuble)
        then do:
            mError:createError({&error}, 1000210,outilTraduction:getLibelle(101206)). /* Immeuble inexistant */
            return false.
        end.
    end.
    else if can-find(first ttAttributChamps where ttAttributChamps.cNomChamp = "immeuble" and ttAttributChamps.lObligatoire)
    then do:
        mError:createError({&error}, 1000207,outilTraduction:getLibelle(101206)). /* Immeuble obligatoire */
        return false.
    end.

    /* Mandat rattaché à l'immeuble ? */
    if ttDocumentGED.iNumeroImmeuble <> 0 and ttDocumentGED.iNumeroMandat <> 0
    and not can-find(first intnt no-lock
                     where intnt.tpidt = {&TYPEBIEN-immeuble}
                       and intnt.tpcon = (if ietab.profil-cd = 21 then {&TYPECONTRAT-mandat2Gerance} else {&TYPECONTRAT-mandat2Syndic})
                       and intnt.nocon = ttDocumentGED.iNumeroMandat
                       and intnt.noidt = ttDocumentGED.iNumeroImmeuble)
    then do:
        mError:createError({&error}, 1000211). /* Ce mandat n'est pas rattaché à cet immeuble */
        return false.
    end.

    /* lot */
    if ttDocumentGED.iNumeroLot <> 0 then do:
        if ttDocumentGED.iNumeroImmeuble = 0 or ttDocumentGED.iNumeroImmeuble = ? then do:
            mError:createError({&error}, 1000212). /* Le lot est renseigné mais pas l'immeuble */
            return false.
        end.
        vlTrouve = false.
        if ttDocumentGED.iNumeroContrat <> 0 and ttDocumentGED.cCodeTypeContrat = {&TYPECONTRAT-bail}
        then
boucle:
        for each unite no-lock
            where unite.nomdt = integer(truncate(ttDocumentGED.iNumeroContrat / 100000, 0))             // integer(substring(string(ttDocumentGED.iNumeroContrat, "9999999999"), 1, 5, 'character'))
              and unite.noapp = integer(truncate((ttDocumentGED.iNumeroContrat modulo 100000) / 100, 0))  // integer(substring(string(ttDocumentGED.iNumeroContrat, "9999999999"), 6, 3, 'character'))
              and unite.norol = ttDocumentGED.iNumeroContrat
          , each cpuni no-lock
            where cpuni.nomdt = unite.nomdt
              and cpuni.noapp = unite.noapp
              and cpuni.nocmp = unite.nocmp
              and cpuni.nolot = ttDocumentGED.iNumeroLot:
            if can-find(first local no-lock
                where local.noimm = cpuni.noimm
                  and local.nolot = cpuni.nolot) then do:
                vlTrouve = true.
                leave boucle.
            end.
        end.
        else if ttDocumentGED.iNumeroContrat <> 0
             and lookup(ttDocumentGED.cCodeTypeContrat, substitute("&1,&2", {&TYPECONTRAT-titre2copro}, {&TYPECONTRAT-mandat2Gerance})) > 0 /* Titre de copropriété, Mandat */
        then for first intnt no-lock
            where intnt.tpcon = ttDocumentGED.cCodeTypeContrat
              and intnt.nocon = ttDocumentGED.iNumeroContrat
              and intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.nbden = 0:
            if can-find(first local no-lock
                where local.noloc = intnt.noidt
                  and local.nolot = ttDocumentGED.iNumeroLot) then vlTrouve = true.
        end.
        else if ttDocumentGED.iNumeroImmeuble <> 0
        and can-find(first local no-lock   /* Lot de l'immeuble */
            where local.noimm = ttDocumentGED.iNumeroImmeuble
              and local.nolot = ttDocumentGED.iNumeroLot) then vlTrouve = true.

        if not vltrouve then do:
            mError:createError({&error}, 1000213). /* Ce lot n'est pas rattaché à cet immeuble */
            return false.
        end.
    end.
    else if can-find(first ttAttributChamps where ttAttributChamps.cNomChamp = "lot" and ttAttributChamps.lObligatoire)
    then do:
        mError:createError({&error}, 1000207, outilTraduction:getLibelle(100361)). /* Lot obligatoire */
        return false.
    end.

    /* type de document */
    find first igedtypd no-lock
        where igedtypd.orig-cd <> "3"
          and igedtypd.typdoc-cd = ttDocumentGED.iNumeroTypeDocument no-error.
    if not available igedtypd then do:
        mError:createError({&error}, 1000242, string(ttDocumentGED.iNumeroTypeDocument)). /* Type de document &1 inexistant*/
        return false.
    end.
    /* nature */
    if trim(ttDocumentGED.cCodeNatureDocument) > ""
    and not can-find(first aparm no-lock where aparm.tppar = "GEDNAT" and aparm.cdpar = ttDocumentGED.cCodeNatureDocument)
    then do:
        mError:createError({&error}, 1000215, outilTraduction:getLibelle(101167)). /* Nature inexistante */
        return false.
    end.
    /* dossier travaux */
    if ttDocumentGED.iNumeroDossier <> 0
    and not can-find(first trdos no-lock
                     where lookup(trdos.tpcon,substitute("&1,&2",{&TYPECONTRAT-mandat2Syndic},{&TYPECONTRAT-mandat2Gerance})) > 0
                       and trdos.nocon = ttDocumentGED.iNumeroMandat
                       and trdos.NoDos = ttDocumentGED.iNumeroDossier)
    then do:
        mError:createError({&error}, 1000207,outilTraduction:getLibelle(108049)). /* Dossier travaux inexistant */
        return false.
    end.
    /* contrat fournisseur */
    if ttDocumentGED.iNumeroContratFournisseur > 0 then do:
        if ttDocumentGED.iNumeroMandat = 0 or ttDocumentGED.iNumeroMandat = ? then do:
            mError:createError({&error}, 1000216). /* Le contrat fournisseur est renseigné mais pas le mandat */
            return false.
        end.
        vlTrouve = false.
boucle:
        for each ctctt no-lock
            where ctctt.tpct1 = (if ietab.profil-cd = 91 then {&TYPECONTRAT-mandat2Syndic} else if ietab.profil-cd = 21 then {&TYPECONTRAT-mandat2Gerance} else ?)
              and ctctt.noct1 = ttDocumentGED.iNumeroMandat
              and ctctt.tpct2 = {&TYPECONTRAT-fournisseur}
              and ctctt.noct2 = ttDocumentGED.iNumeroContratFournisseur
          , first ctrat no-lock
            where ctrat.tpcon = ctctt.tpct2
              and ctrat.nocon = ctctt.noct2
          , last tache no-lock
            where tache.tpcon = ctrat.tpcon
              and tache.nocon = ctrat.nocon
              and tache.tptac = {&TYPETACHE-fournisseur}
          , first intnt no-lock
            where intnt.tpcon = ctctt.tpct1
              and intnt.nocon = ctctt.noct1
              and intnt.tpidt = {&TYPEBIEN-immeuble}
          , first vbctrat no-lock
            where vbctrat.tpcon = ctctt.tpct1
              and vbctrat.nocon = ctctt.noct1:
            vlTrouve = true.
            leave boucle.
        end.
        if not vlTrouve then do:
            mError:createError({&error}, 1000210, outilTraduction:getLibelle(701974)). /* Contrat fournisseur inexistant */
            return false.
        end.
    end.
    if not controleUpdateExtranet() then return false. // Contrôles champs extranet
    return true.

end function.

function f_nomrol returns character private (pcTpRol-In as character, piNoRol-In as int64, piNoTie-In as integer):
    /*------------------------------------------------------------------------------
    Purpose: retourne le nom du tiers stocké dans role
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer vbRoles for roles.

    if integer(pcTpRol-In) = 0 and piNoRol-In = 0 and piNoTie-In = 0 then return "". /* Le tiers n'est pas obligatoire */
    if piNoTie-In > 0
    then find first vbRoles no-lock
        where vbRoles.notie = piNoTie-In
          and vbRoles.fg-princ = true no-error.
    else find first vbRoles no-lock
        where vbRoles.tprol = pcTpRol-In
          and vbRoles.norol = piNoRol-In no-error.
    if available vbRoles then return entry(1, vbRoles.lbrech, separ[1]).

    return substitute("??? &1 - &2 - &3", pcTpRol-In, string(piNoRol-In), string(piNoTie-In)).

end function.

function f_PlanClassement return character private:
    /*------------------------------------------------------------------------------
    Purpose: Donne le code plan de classement du profil de l'utilisateur 
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer tutil   for tutil.
    define buffer tprofil for tprofil.

    for first tutil no-lock
        where tutil.ident_u = mToken:cUser
      , first tprofil no-lock
        where tprofil.profil_u = tutil.profil_u:
        return tprofil.plan-cd.
    end.
    return "".

end function.

function f_GedDroit returns logical private (pcDroit-In as character, pcUser-In as character):
    /*------------------------------------------------------------------------------
    Purpose: Droit d'acces l'utilisateur en creation/modif/suppression de document ged   
    Notes:
    ------------------------------------------------------------------------------*/
    return lookup(pcDroit-In, "cre,mod,sup") > 0
       and can-find(first tutil no-lock
                    where tutil.ident_u = pcUser-In
                      and num-entries(tutil.ged) >= 3
                      and entry(lookup(pcDroit-In, "cre,mod,sup"), tutil.ged) = "O").
end function.

function controleDeleteUpdateGed returns logical private (pcMode as character, piIdentifiantGed as int64):
    /*------------------------------------------------------------------------------
    Purpose: controles avant suppression/modification d'un document ged
    Notes  : pcMode = 'U' ou 'D'
    ------------------------------------------------------------------------------*/
    if not can-find(first igeddoc no-lock where igeddoc.id-fich = piIdentifiantGed)
    then mError:createError({&error}, 1000072, string(piIdentifiantGed)). /* fiche ged &1 inexistante. */
    else if lookup(pcMode, "U,D") >= 1
         then if f_GedDroit(if pcMode = "U" then "mod" else "sup", mtoken:cUser)
              then return true.
              else mError:createError({&error}, if pcMode = "U" then 1000202 else 1000201).
    return false.

end function.

function f_GedActive returns logical private:
    /*------------------------------------------------------------------------
    Purpose: Module ged activé
    Notes  :
    ------------------------------------------------------------------------*/
    if not can-find(first iparm no-lock where iparm.tppar = "GED" and iparm.lib = "O")
    then do:
        mError:createErrorComplement({&error}, 1000085,"", mToken:cUser). /* 'Module GED non activé' */
        return false.
    end.
    return true.

end function.

function f_oblig returns logical private (pcCodePlan as character, pcCodeChamp as character):
    /*------------------------------------------------------------------------------
    Purpose: Champs du plan de classement obligatoire
    Notes: cf igedplan.w
           ----------,V,Mandats,M,Type de mandats / mandats,TM,Tiers,T,Type de role / tiers,TT,Immeubles,I,Lots,L,Evénements,E,Thèmes,TH
    ------------------------------------------------------------------------------*/
    define variable viTmp as integer no-undo.
    define buffer igedplan for igedplan.

    for first igedplan no-lock
        where igedplan.plan-cd = pcCodePlan:
        do viTmp = 1 to igedplan.plan-nbniv:
            if (pcCodeChamp = "mandat"   and lookup(igedplan.niv-entite[viTmp], "TM,M") > 0 and entry(viTmp, igedplan.cdivers) = "O")
            or (pcCodeChamp = "tiers"    and lookup(igedplan.niv-entite[viTmp], "T,TT") > 0 and entry(viTmp, igedplan.cdivers) = "O")
            or (pcCodeChamp = "immeuble" and lookup(igedplan.niv-entite[viTmp], "I") > 0    and entry(viTmp, igedplan.cdivers) = "O")
            or (pcCodeChamp = "lot"      and lookup(igedplan.niv-entite[viTmp], "L") > 0    and entry(viTmp, igedplan.cdivers) = "O")
            or (pcCodeChamp = "theme"    and lookup(igedplan.niv-entite[viTmp], "TH") > 0   and entry(viTmp, igedplan.cdivers) = "O")
            then return true.
        end.
    end.
    return lookup(pcCodeChamp, "referenceSociete,dateDeDoc,objet,typeDeDoc") > 0.

end function.

function f_affiche returns logical private (pcCodePlan as character, pcCodeChamp as character):
    /*------------------------------------------------------------------------------
    Purpose: code champs affichable
    Notes  :
    ------------------------------------------------------------------------------*/
    return f_oblig(pcCodePlan, pcCodeChamp) or lookup(pcCodeChamp, "mandat,tiers,immeuble") > 0.

end function.

function f_TypeDeDocument returns collection private(poCollection as collection, phBuffer as handle):
    /*------------------------------------------------------------------------
    Purpose: Découpage de igedtypd.cdivers
    Notes  : 
    ------------------------------------------------------------------------*/
    define variable viNombreSepar1 as integer no-undo.
    
    viNombreSepar1 = num-entries(phBuffer::cdivers, separ[1]).
    poCollection:set("cLibelleTypeDocument", if viNombreSepar1 >= 5 and entry(5, phBuffer::cdivers, separ[1]) > ""
                                                    then entry(5, phBuffer::cdivers, separ[1]) else phBuffer::lib).
    poCollection:set("cCodeTheme"          , if viNombreSepar1 >= 4 then entry(4, phBuffer::cdivers, separ[1]) else "").
    poCollection:set("cObjet"              , if viNombreSepar1 >= 9 then entry(9, phBuffer::cdivers, separ[1]) else "").
    poCollection:set("lUtilise"            , viNombreSepar1 >= 6 and entry(6, phBuffer::cdivers, separ[1]) = "O").
    poCollection:set("cTypeDossierGidemat" , if viNombreSepar1 >= 2 then entry(2, phBuffer::cdivers, separ[1]) else "").
    poCollection:set("cTypeTransfert"      , if viNombreSepar1 >= 3 then entry(3, phBuffer::cdivers, separ[1]) else "").
    return poCollection.

end function.


procedure getDocumentParId:
    /*------------------------------------------------------------------------
    Purpose: Extraction d'un document selon l'ID
    Notes  : service utilisé par beVersement.cls
    ------------------------------------------------------------------------*/
    define input  parameter pcTypeIdentifiant  as character no-undo.
    define input  parameter pcListeIdentifiant as character no-undo.
    define output parameter table for ttDocumentGidemat.

    define variable vhProcGidemat as handle  no-undo.
    define variable vItmp         as integer no-undo.
    define variable viIdentifiant as int64   no-undo.

    if pcTypeIdentifiant <> "ged" and pcTypeIdentifiant <> "gidemat" then do:
        mError:createError({&erreur}, 1000200,"cTypeIdentifiant"). /* 1000200 Paramètre &1 incorrect */
        return.
    end.
    run ged/gidemat.p persistent set vhProcGidemat.
    run getTokenInstance in vhProcGidemat(mToken:JSessionId).
boucleIdentifiant:
    do viTmp = 1 to num-entries(pcListeIdentifiant):
        viIdentifiant = int64(entry(viTmp,pcListeIdentifiant)) no-error.
        if error-status:error then next boucleIdentifiant.

        if pcTypeIdentifiant = "ged"
        then run getDocumentParIdGed     in vhProcGidemat(viIdentifiant, output table ttDocumentGidemat append).
        else run getDocumentParIdGidemat in vhProcGidemat(viIdentifiant, output table ttDocumentGidemat append).
    end.
    run destroy   in vhProcGidemat.

end procedure.

procedure getDocumentScan:
    /*------------------------------------------------------------------------
    Purpose: Extraction des fichiers d'un repertoire scanner
    Notes  : service utilisé par beVersement.cls
    ------------------------------------------------------------------------*/
    define input        parameter table for ttRepertoireScan.
    define input-output parameter table for ttFichierScan.

    define variable vmFichier as memptr    no-undo.
    define variable vcFile    as character no-undo.
    define buffer igedrep for igedrep.

    for each ttRepertoireScan
      , first igedrep no-lock
        where igedrep.nom-doss = ttRepertoireScan.cNomDossier
      , each ttFichierScan
        where ttFichierScan.cNomDossier = ttRepertoireScan.cNomDossier:
        vcFile = substitute('&1&3&2', igedrep.chemin-doss, ttFichierScan.cNomFichier, outils:separateurRepertoire()).
        if search(vcFile) = ?
        then do:
            mError:createError({&error}, 1000243, ttFichierScan.cNomFichier). /* Le fichier &1 est inexistant */
            undo, leave.
        end.
        copy-lob from file vcFile to vmFichier no-error.
        assign
            ttFichierScan.cContenuFichier = base64-encode(vmFichier)
            set-size(vmFichier)           = 0 /* sinon erreur -> Impossible d'allouer la mémoire pour un large object */
        .
    end.

end procedure.

procedure getVisibiliteRoleExtranet:
    /*------------------------------------------------------------------------
    Purpose: Visibilité extranet des documents selon le type de role
    Notes  : service utilisé par beVersement.cls
    ------------------------------------------------------------------------*/
    define input  parameter pcTypeRole       as character no-undo.
    define input  parameter piNumeroImmeuble as integer   no-undo.
    define input  parameter piNumeroMandat   as integer   no-undo.
    define output parameter table for ttVisibiliteExtranet.

    define variable voCollection as class collection no-undo.

    empty temp-table ttVisibiliteExtranet.
    create ttVisibiliteExtranet.
    assign
        voCollection                                = f_VisibiliteRoleExtranet(pcTypeRole, piNumeroImmeuble, piNumeroMandat)
        ttVisibiliteExtranet.lSaisirLocataire       = (voCollection:getLogical('saisirLocataire') = true)
        ttVisibiliteExtranet.lVoirLocataire         = (voCollection:getLogical('voirLocataire')   = true)
        ttVisibiliteExtranet.lSaisirProprietaire    = (voCollection:getLogical('saisirProprietaire') = true)
        ttVisibiliteExtranet.lVoirProprietaire      = (voCollection:getLogical('voirProprietaire')  = true)
        ttVisibiliteExtranet.lSaisirCoproprietaire  = (voCollection:getLogical('saisirCoproprietaire') = true)
        ttVisibiliteExtranet.lVoirCoproprietaire    = (voCollection:getLogical('voirCoproprietaire') = true)
        ttVisibiliteExtranet.lSaisirConseilSyndical = (voCollection:getLogical('saisirConseilSyndic') = true)
        ttVisibiliteExtranet.lVoirConseilSyndical   = (voCollection:getLogical('voirConseilSyndic') = true)
        ttVisibiliteExtranet.lSaisirEmployeImmeuble = (voCollection:getLogical('saisirEmployeImmeuble') = true)
        ttVisibiliteExtranet.lVoirEmployeImmeuble   = (voCollection:getLogical('voirEmployeImmeuble') = true)
    no-error. /* si erreur -> valeur par défaut du flag */

end procedure.

procedure getVisibiliteRoleExtranetDocument:
    /*------------------------------------------------------------------------
    Purpose: Visibilité extranet d'un document
    Notes  : service utilisé par rechercheGed.p
    ------------------------------------------------------------------------*/
    define parameter buffer ttDocumentGED for ttDocumentGED.
    define output parameter table for ttVisibiliteExtranet.

    define variable voCollection as collection no-undo.

    voCollection = f_VisibiliteRoleExtranet(string(ttDocumentGED.iCodeTypeRole,"99999"), ttDocumentGED.iNumeroImmeuble, ttDocumentGED.iNumeroMandat).
    empty temp-table ttVisibiliteExtranet.
    create ttVisibiliteExtranet.
    assign
        ttVisibiliteExtranet.id-fich                = ttdocumentGed.iIdentifiantGed
        ttVisibiliteExtranet.lSaisirLocataire       = (voCollection:getLogical('saisirLocataire') = true)
        ttVisibiliteExtranet.lVoirLocataire         = ttDocumentGED.lVisibiliteLocataire
        ttVisibiliteExtranet.lSaisirProprietaire    = (voCollection:getLogical('saisirProprietaire') = true)
        ttVisibiliteExtranet.lVoirProprietaire      = ttDocumentGED.lVisibiliteProprietaire
        ttVisibiliteExtranet.lSaisirCoproprietaire  = (voCollection:getLogical('saisirCoproprietaire') = true)
        ttVisibiliteExtranet.lVoirCoproprietaire    = ttDocumentGED.lVisibiliteCoproprietaire
        ttVisibiliteExtranet.lSaisirConseilSyndical = (voCollection:getLogical('saisirConseilSyndic') = true)
        ttVisibiliteExtranet.lVoirConseilSyndical   = ttDocumentGED.lVisibiliteCS
        ttVisibiliteExtranet.lSaisirEmployeImmeuble = (voCollection:getLogical('saisirEmployeImmeuble') = true)
        ttVisibiliteExtranet.lVoirEmployeImmeuble   = ttDocumentGED.lVisibiliteEmployeImmeuble
    no-error. /* si erreur -> valeur par défaut du flag */

end procedure.

procedure getComboTypeDocument:
    /*------------------------------------------------------------------------
    Purpose: Combo liste des types de document en versement et recherche ged
    Notes  : service utilisé par beVersement.cls
    ------------------------------------------------------------------------*/
    define input  parameter piReference         as integer   no-undo.
    define input  parameter piNumeroMandat      as integer   no-undo.
    define input  parameter pcCodeThemeGed      as character no-undo.
    define input  parameter pcListeCodeOrigine  as character no-undo. /* "" = Tous , sinon "1,2" pour type doc Gi et Client */
    define input  parameter pcListeTypeDocument as character no-undo. /* "" = Tous ou Liste des types de doc autorisés */
    define input  parameter pcFiltre            as character no-undo. /* filtre sur le libellé ou le N° de type de document */
    define output parameter table for ttGedTypeDocument.

    define variable vcListeDossierUtil   as character no-undo.
    define variable vcListeDossierMandat as character no-undo initial "PAI,CAB,SOC".
    define variable vcWhereClause        as character no-undo.
    define variable vlExisteGerance      as logical   no-undo.
    define variable vlExisteCopro        as logical   no-undo.           

    define buffer tutil  for tutil.
    define buffer ietab  for ietab.

    assign 
        vlExisteGerance = can-find(first ietab no-lock where ietab.soc-cd = piReference and ietab.profil-cd = 21)
        vlExisteCopro   = can-find(first ietab no-lock where ietab.soc-cd = piReference and ietab.profil-cd = 91)
    .
    empty temp-table ttGedTypeDocument.
    for first tutil no-lock
        where tutil.ident_u = mtoken:cUser:
        /* Liste des dossiers autorisés pour l'utilisateur */
        if num-entries(tutil.GEd) >= 4 and entry(4, tutil.GEd) = "O" and vlExisteGerance then vcListeDossierUtil = "GER".
        if num-entries(tutil.GEd) >= 5 and entry(5, tutil.GEd) = "O" and vlExisteCopro   then vcListeDossierUtil = vcListeDossierUtil + ",COP".
        if num-entries(tutil.GEd) >= 6 and entry(6, tutil.GEd) = "O"                     then vcListeDossierUtil = vcListeDossierUtil + ",PAI".
        if num-entries(tutil.GEd) >= 7 and entry(7, tutil.GEd) = "O"                     then vcListeDossierUtil = vcListeDossierUtil + ",CAB".
        if num-entries(tutil.GEd) >= 8 and entry(8, tutil.GEd) = "O"                     then vcListeDossierUtil = vcListeDossierUtil + ",SOC".
        vcListeDossierUtil = trim(vcListeDossierUtil, ',').
        /* Type de mandat */
        if piNumeroMandat > 0 then for first ietab no-lock
            where ietab.Soc-cd  = pireference
              and ietab.etab-cd = piNumeroMandat
              and ietab.profil-cd modulo 10 <> 0:
            if lookup(string(ietab.profil-cd), "20,21") > 0
            then vcListeDossierMandat = vcListeDossierMandat + ",GER".
            else if lookup(string(ietab.profil-cd), "90,91") > 0
                 then vcListeDossierMandat = vcListeDossierMandat + ",COP".
        end.
        else assign 
            vcListeDossierMandat = vcListeDossierMandat + ",GER" when vlExisteGerance
            vcListeDossierMandat = vcListeDossierMandat + ",COP" when vlExisteCopro
        .
        vcWhereClause = substitute('where num-entries(igedtypd.cdivers,"&2") >= 2 and lookup(entry(2,igedtypd.cdivers,"&2"),"&1") > 0', vcListeDossierUtil, separ[1])  /* Liste des types de dossiers autorisés pour l'utilisateur */
                      + substitute(' and lookup(entry(2,igedtypd.cdivers,"&2"),"&1") > 0', vcListeDossierMandat, separ[1])  /* filtre selon le type de mandat  */
                      + substitute(' and num-entries(igedtypd.cdivers,"&1") >= 6 and entry(6,igedtypd.cdivers,"&1") = "O"', separ[1]) /* Filtre utilisé O/N */
                      + (if pcCodeThemeGed      > "" then substitute(' and num-entries(igedtypd.cdivers,"&2") >= 4 and entry(4,igedtypd.cdivers,"&2") = "&1"', pcCodeThemeGed, separ[1]) else "")  /* filtre selon le code theme ged */
                      + (if pcListeCodeOrigine  > "" then substitute(' and lookup(string(igedtypd.orig-cd),"&1") > 0', pcListeCodeOrigine) else "")      /* filtre selon le Code origine */
                      + (if pcListeTypeDocument > "" then substitute(' and lookup(string(igedtypd.typdoc-cd),"&1") > 0', pcListeTypeDocument) else "")   /* Filtre selon liste des codes types doc */
                      + (if pcFiltre > "" then substitute(' and ( string(igedtypd.typdoc-cd) matches "*&1*" or (if num-entries(igedtypd.cdivers, "&2") >= 5 and entry(5, igedtypd.cdivers, "&2") > ""
                                                            then entry(5, igedtypd.cdivers, "&2") else igedtypd.lib) matches "*&1*") ', pcFiltre, separ[1]) else "").
        run createttGedTypeDocument(vcWhereClause).
    end. /* for first */
end procedure.

procedure getAttributEcranVersement:
    /*------------------------------------------------------------------------
    Purpose: Extraction de l'ordre d'affichage des champs de saisie 
    Notes  : service utilisé par beVersement.cls
    ------------------------------------------------------------------------*/
    define output parameter table for ttParamVersement.
    define output parameter table for ttAttributChamps.

    define variable vcCodePlan    as character no-undo.
    define variable vdaRecherche  as date      no-undo.
    define variable vhProcGidemat as handle    no-undo.

    define buffer igedplan for igedplan.
    define buffer aparm    for aparm.

    if not f_GedActive() then return.

    run ged/gidemat.p persistent set vhProcGidemat.
    run getTokenInstance in vhProcGidemat(mToken:JSessionId).

    vcCodePlan = f_PlanClassement().
    find first igedplan no-lock where igedplan.plan-cd = vcCodePlan no-error.
    if available igedplan
    then do:
        vdaRecherche = today.
        for first aparm no-lock
            where aparm.tppar = "GEDPAR"
              and aparm.cdpar = "NBJRCH":
            vdaRecherche =  vdaRecherche - integer(aparm.zone2).
        end.
        create ttParamVersement.
        assign
            ttParamVersement.cCodePlanClassement = igedplan.plan-cd
            ttParamVersement.lGiExtranet         = can-find(first aparm no-lock where aparm.tppar = "TWEB")
            ttParamVersement.cFormatDate         = "yyyy-mm-dd"
            ttParamVersement.daRecherche         = vdaRecherche
            ttParamVersement.cCheminFileWatcher  = dynamic-function("f_RepertoireFileWatcher" in vhProcGidemat)
        .
        run getAttributChamps(igedplan.plan-cd).
    end.
    else mError:createError({&error}, 1000087, vcCodePlan).  /* Plan de classement &1 inexistant */
    run destroy in vhProcGidemat.

end procedure.

procedure createAttributChamps private:
    /*------------------------------------------------------------------------
    Purpose: statut obligatoire/visible d'un champ
    Notes  :
    ------------------------------------------------------------------------*/
    define input parameter pcPlan-cd   as character no-undo.
    define input parameter pcNomChamps as character no-undo.
    define input parameter piPosition  as integer   no-undo.
    define input parameter plVisible   as logical   no-undo.

    create ttAttributChamps.
    assign
        ttAttributChamps.cNomChamp    = pcNomChamps
        ttAttributChamps.iPosition    = piPosition
        ttAttributChamps.lObligatoire = f_oblig(pcPlan-cd, pcNomChamps)
        ttAttributChamps.lVisible     = plVisible
    .

end procedure.

procedure getAttributChamps private:
    /*------------------------------------------------------------------------
    Purpose: calcul le positionnement des champs de saisie selon le plan de classement
    Notes  :
    ------------------------------------------------------------------------*/
    define input parameter pcPlan as character no-undo.

    define variable viPosition as integer no-undo.

    /* reference */
    viPosition = viPosition + 1.
    run createAttributChamps(pcPlan, "referenceSociete", viPosition, true).
    /* Date de doc */
    viPosition = viPosition + 1.
    run createAttributChamps(pcPlan, "dateDeDoc", viPosition, true).
    /* Thème */
    if f_affiche(pcPlan, "theme") then do:
        viPosition = viPosition + 1.
        run createAttributChamps(pcPlan, "theme", viPosition, true).
    end.
    /* Objet */
    viPosition = viPosition + 1.
    run createAttributChamps(pcPlan, "objet", viPosition, true).
    /* Tiers */
    if f_affiche(pcPlan, "tiers") then do:
        viPosition = viPosition + 1.
        run createAttributChamps(pcPlan, "tiers", viPosition, true).
    end.
    /* Mandat */
    if f_affiche(pcPlan, "mandat") then do:
        viPosition = viPosition + 1.
        run createAttributChamps(pcPlan, "mandat", viPosition, true).
    end.
    /* Immeuble */
    if f_affiche(pcPlan, "immeuble") then do:
        viPosition = viPosition + 1.
        run createAttributChamps(pcPlan, "immeuble", viPosition, true).
    end.
    /* Lot */
    if f_affiche(pcPlan, "lot") then do:
        viPosition = viPosition + 1.
        run createAttributChamps(pcPlan, "lot", viPosition, true).
    end.
    /* Type de doc  */
    viPosition = viPosition + 1.
    run createAttributChamps(pcPlan, "typeDeDoc", viPosition, true).
    /* Tiers */
    if not f_affiche(pcPlan,"tiers") then do:
        viPosition = viPosition + 1.
        run createAttributChamps(pcPlan, "tiers", viPosition, false).
    end.
    /* Mandat */
    if not f_affiche(pcPlan,"mandat") then do:
        viPosition = viPosition + 1.
        run createAttributChamps(pcPlan, "mandat", viPosition, false).
    end.
    /* Immeuble */
    if not f_affiche(pcPlan,"immeuble") then do:
        viPosition = viPosition + 1.
        run createAttributChamps(pcPlan, "immeuble", viPosition, false).
    end.
    /* Lot */
    if not f_affiche(pcPlan,"lot") then do:
        viPosition = viPosition + 1.
        run createAttributChamps(pcPlan, "lot", viPosition, false).
    end.
    /* Nature  */
    viPosition = viPosition + 1.
    run createAttributChamps(pcPlan, "nature", viPosition, false).
    /* Descriptif  */
    viPosition = viPosition + 1.
    run createAttributChamps(pcPlan, "descriptif", viPosition, false).
    /* Travaux  */
    viPosition = viPosition + 1.
    run createAttributChamps(pcPlan, "travaux", viPosition, false).
    /* contrat fourn   */
    viPosition = viPosition + 1.
    run createAttributChamps(pcPlan, "contratFourn", viPosition, false).
    /* Thème */
    if not f_affiche(pcPlan, "theme") then do:
        viPosition = viPosition + 1.
        run createAttributChamps(pcPlan, "theme", viPosition, false).
    end.
    /* Mots clés   */
    viPosition = viPosition + 1.
    run createAttributChamps(pcPlan, "motsCles", viPosition, false).

end procedure.

procedure updateDocumentGED :
    /*------------------------------------------------------------------------------
    Purpose:  Mise à jour des index d'un document GED
    Notes  : service utilisé par beVersement.cls
    ------------------------------------------------------------------------------*/
    define input-output parameter table for ttDocumentGED.
    define input        parameter table for ttAttributChamps.
    define input        parameter table for ttTypeRole.
    define input        parameter pcVue as character no-undo.

    define variable vlErreur       as logical   no-undo initial true.
    define variable vhProcGidemat  as handle    no-undo.
    define variable vhProcRole     as handle    no-undo.
    define variable vcLibelleIdGed as character no-undo.

    define buffer igeddoc for igeddoc.

    if not f_GedActive() then return.

    run role/role.p persistent set vhProcRole.
    run getTokenInstance in vhProcRole(mToken:JSessionId).
    run ged/gidemat.p persistent set vhProcGidemat.
    run getTokenInstance in vhProcGidemat(mToken:JSessionId).
    vcLibelleIdGed = outilTraduction:getLibelle(1000257).

blocTransaction:
    for each ttDocumentGED where ttDocumentGED.CRUD = 'U' transaction:

        if not controleDeleteUpdateGed(ttDocumentGED.CRUD, ttDocumentGED.iIdentifiantGed) then undo blocTransaction, leave blocTransaction.
        if pcVue = "GIEXTRANET" then do:
            if not controleUpdateExtranet() then undo blocTransaction, next blocTransaction.
        end.
        else if not controleCreateUpdateGed() or not controleUpdateExtranet()
             then undo blocTransaction, leave blocTransaction.

        find first igeddoc exclusive-lock
            where igeddoc.id-fich = ttDocumentGED.iIdentifiantGed no-wait no-error.
        if outils:isUpdated(buffer igeddoc:handle, substitute(outilTraduction:getLibelle(1000257),""), string(ttDocumentGED.iIdentifiantGed), ttDocumentGed.dtTimestamp)
        then undo blocTransaction, next blocTransaction.
        if pcVue = "GIEXTRANET"
        then run setExtranet(buffer igeddoc, output vlErreur). // Maj des champs pour giextranet uniquement
        else do:
            run setDocumentGED(buffer igeddoc, vhProcGidemat, vhProcRole, output vlErreur). // Maj champs hors giextranet
            if not vlErreur then run setExtranet(buffer igeddoc, output vlErreur). // Maj des champs pour giextranet
        end.
        if vlErreur then undo blocTransaction, next blocTransaction.

        assign
            igeddoc.cdmsy             = mtoken:cUser
            igeddoc.dtmsy             = today
            igeddoc.hemsy             = mtime
            ttDocumentGED.dtTimestamp = datetime(igeddoc.dtmsy, igeddoc.hemsy)
            ttDocumentGED.CRUD        = 'R'
        .
        mError:createError({&info}, 1000256, substitute(vcLibelleIdGed, string(igeddoc.id-fich))). /* Mise à jour effectuée */
    end. /* trans */
    run destroy in vhProcGidemat.
    run destroy in vhProcRole.

end procedure.

procedure createDocumentGED:
    /*------------------------------------------------------------------------------
    Purpose: Création d'un document GED
    Notes  : service utilisé par beVersement.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttDocumentGED.
    define input parameter table for ttTypeRole.
    define input parameter table for ttFichierVerse.
    define input parameter table for ttAttributChamps.
    define input parameter table for ttRepertoireScan.
    define input parameter table for ttFichierScan.
    define input parameter table for ttColoc.

    define variable vlErreur            as logical   no-undo initial true.
    define variable vlAnomalieFichier   as logical   no-undo.
    define variable vmFichier           as memptr    no-undo.
    define variable vhProcGidemat       as handle    no-undo.
    define variable vhProcRole          as handle    no-undo.
    define variable vcLongVar           as longchar  no-undo.
    define variable viIdentifiantGed    as int64     no-undo.
    define variable vlVersementMasse    as logical   no-undo.
    define variable viTailleFichier     as int64     no-undo.
    define variable vcNomArchive        as character no-undo.
    define variable vcExtension         as character no-undo.
    define variable vcNomFichier        as character no-undo.
    define variable vcNomCompletFichier as character no-undo.
    define variable viNombreVersement   as integer   no-undo.
    define variable voCollection    as class collection no-undo.

    define buffer igedrep  for igedrep.
    define buffer igeddoc  for igeddoc.
    define buffer aparm    for aparm.
    define buffer iparm    for iparm.
    define buffer igedtypd for igedtypd.

    if not f_GedActive() then return.
    if not f_GedDroit("cre", mtoken:cUser)
    then do:
        mError:createError({&error}, 1000229). /* Création non autorisée */
        return.
    end.
    if mToken:getValeur('REPGI') = ? then do:
        mError:createError({&error}, 1000255, substitute("REPGI&1(magitoken)&1", separ[1])). /* Le paramètre &1 n'est pas renseigné &2 &3 */
        return.
    end.

    run role/role.p persistent set vhProcRole.
    run getTokenInstance in vhProcRole(mToken:JSessionId).
    run ged/gidemat.p persistent set vhProcGidemat.
    run getTokenInstance in vhProcGidemat(mToken:JSessionId).

    voCollection = new collection().
    if f_CreationRepertoireTransfert(vhProcGidemat)
    then blocCreation: do on error undo, leave:

        find first aparm no-lock
            where aparm.tppar = "GEDpar"
              and aparm.cdpar = "EXT" no-error.
        /* Contrôle répertoire gest\tmp */
        file-info:file-name = substitute("&1&2gest&2tmp&2", mToken:getValeur('REPGI'), outils:separateurRepertoire()).
        if file-info:file-type = ? or not file-info:file-type matches "*D*" then do:
            mError:createError({&error}, 1000236, substitute("&1&2gest&2tmp&2", mToken:getValeur('REPGI'), outils:separateurRepertoire())). /* 1000236 le répertoire &1 n'existe pas */
            undo blocCreation, leave blocCreation.
        end.

        /* Versement en masse ? */
        vlVersementMasse = false.
        for each ttDocumentGED where ttDocumentGED.CRUD = 'C'
          , each ttRepertoireScan where ttRepertoireScan.iIdentifiantGed = ttDocumentGED.iIdentifiantGed:
            find first igedrep no-lock
                where igedrep.nom-doss = ttRepertoireScan.cNomDossier no-error.
            if not available igedrep then do:
                mError:createError({&error}, 1000264, ttRepertoireScan.cNomDossier). /* 1000264,0,Dossier scanner &1 inexistant */
                undo blocCreation, leave blocCreation.
            end.
            if igedrep.chemin-corb > "" and igedrep.chemin-dos <> igedrep.chemin-corb then do:
                file-info:file-name = igedrep.chemin-corb.
                if file-info:file-type = ? or not file-info:file-type matches "*D*" then do:
                    mError:createError({&error}, 1000300, igedrep.chemin-corb). /* Dossier corbeille &1 inexistant */
                    undo blocCreation, leave blocCreation.
                end.
            end.
            for each ttFichierScan
                where ttFichierScan.iIdentifiantGed = ttRepertoireScan.iIdentifiantGed
                  and ttFichierScan.cNomDossier = ttRepertoireScan.cNomDossier:
                if search(substitute('&1&3&2', igedrep.chemin-doss, ttFichierScan.cNomFichier, outils:separateurRepertoire())) = ?
                then do:
                    mError:createError({&error}, 1000243, substitute('&1&3&2', igedrep.chemin-doss, ttFichierScan.cNomFichier, outils:separateurRepertoire())).
                    undo blocCreation, leave blocCreation.
                end.
                if not vlVersementMasse then empty temp-table ttFichierVerse. /* Cette table doit être vide en entree pour acces depuis versement en masse */
                create ttFichierVerse.
                assign
                    vlVersementMasse              = true
                    ttFichierVerse.id-fich        = ttFichierScan.iIdentifiantGed
                    ttFichierVerse.cNomFichier    = ttFichierScan.cNomFichier
                    ttFichierVerse.cCheminFichier = igedrep.chemin-doss
                    ttFichierVerse.cNomDossier    = igedrep.nom-doss
                .
            end.
        end.
        empty temp-table ttRoleVersement.
        for each ttDocumentGED where ttDocumentGED.CRUD = 'C':
            if not controleCreateUpdateGed() then undo blocCreation, leave blocCreation.

            find first igedtypd no-lock
                where igedtypd.typdoc-cd = ttDocumentGED.iNumeroTypeDocument no-error. // existe obligatoirement, controlé dans controleCreateUpdateGed)
            voCollection = f_TypeDeDocument(voCollection, buffer igedtypd:handle).
            /* Plusieurs tiers versés (colocataire) */
            if not can-find(first ttColoc where ttColoc.identifiant = ttDocumentGed.iIdentifiantGed) then do:
                create ttRoleVersement.
                assign
                    ttRoleVersement.cTypeRole      = string(ttDocumentGED.iCodeTypeRole)
                    ttRoleVersement.iNumeroRole    = ttDocumentGED.iNumeroRole
                    ttRoleVersement.cTypeContrat   = ttDocumentGED.cCodeTypeContrat
                    ttRoleVersement.iNumeroContrat = ttDocumentGED.iNumeroContrat
                    ttRoleVersement.iNumeroTiers   = ttDocumentGED.iNumeroTiers
                    ttRoleVersement.id-fich        = ttDocumentGed.iIdentifiantGed
                .
            end.
            else do: /* raz info tiers */
                ttDocumentGed.iNumeroTiers = 0.
                for each ttColoc
                    where ttColoc.identifiant = ttDocumentGed.iIdentifiantGed
                      and ttcoloc.lSelection:
                    create ttRoleVersement.
                    assign
                        ttRoleVersement.cTypeRole      = ttColoc.cTypeRole
                        ttRoleVersement.iNumeroRole    = int64(ttColoc.cNumeroRole)
                        ttRoleVersement.cTypeContrat   = ttColoc.cTypeContrat
                        ttRoleVersement.iNumeroContrat = ttColoc.iNumeroContrat
                        ttRoleVersement.iNumeroTiers   = ttColoc.iNumeroTiers
                        ttRoleVersement.id-fich        = ttDocumentGed.iIdentifiantGed
                    .
                end.
            end.
BoucleFichierVerse:
            for each ttFichierVerse
                where ttFichierVerse.id-fich = ttDOcumentGED.iIdentifiantGed:
                assign
                    vlAnomalieFichier = false
                    vcExtension       = substring(ttFichierVerse.cNomFichier, r-index(ttFichierVerse.cNomFichier, ".") + 1)
                .
                /* Contrôle fichier */
                if fisNull(ttFichierVerse.cNomFichier) then do:
                    mError:createError({&error}, 103738). /* Le nom du fichier est obligatoire */
                    next BoucleFichierVerse.
                end.
                /* Extension du fichier */
                if not available aparm
                or not lookup(vcExtension, aparm.zone2) >= 1
                then do:
                    mError:createError({&error}, 1000233, ttFichierVerse.cNomFichier). /* Fichier &1 extension non autorisée */
                    next BoucleFichierVerse.
                end.
                if vlVersementMasse then do:
                    assign
                        file-info:file-name               = substitute('&1&3&2', ttFichierVerse.cCheminFichier, ttFichierVerse.cNomFichier, outils:separateurRepertoire())
                        ttfichierVerse.DaDateModification = file-info:file-mod-date // Date du fichier scan 
                    .
                    copy-lob from file file-info:file-name to vmFichier no-error.
                    if error-status:error then do:
                        mError:createError({&error}, 1000253, substitute('&1&3&2', ttFichierVerse.cCheminFichier, ttFichierVerse.cNomFichier, outils:separateurRepertoire())). /* Impossible d'accéder au fichier &1 */
                        next BoucleFichierVerse.
                    end.
                end.
                else do:
                    if length(ttFichierVerse.cContenuFichier, 'character') = 0 or ttFichierVerse.cContenuFichier = ? then do:
                        mError:createError({&error}, 1000232). /* Contenu du fichier vide */
                        next BoucleFichierVerse.
                    end.
                    copy-lob from ttFichierVerse.cContenuFichier to vcLongVar.
                    vmFichier = base64-decode(vcLongVar).
                end.

                if dynamic-function("f_TailleMax" in vhProcGidemat) < round(get-size(vmFichier) / (1024 * 1024),2) /* octet -> mega octet */
                then do:
                    mError:createError({&error}, 1000246, substitute("&1&4&2&4&3"
                                                , ttFichierVerse.cNomFichier
                                                , string(round(get-size(vmFichier) / (1024 * 1024),2))
                                                , string(dynamic-function("f_TailleMax" in vhProcGidemat))
                                                , separ[1])). /* Taille du fichier &1 (&2 Mo) supérieure au maximum autorisé (&3 Mo) */
                    set-size(vmFichier) = 0. /* sinon erreur -> Impossible d'allouer la mémoire pour un large object */
                    next BoucleFichierVerse.
                end.
                assign
                    vcNomFichier        = substitute("&1&2&3&4&5&6.ged",
                                                 mToken:cRefPrincipale,
                                                 mToken:cUser,
                                                 year(today),
                                                 string(month(today), "99"),
                                                 string(day(today), "99"),
                                                 string(mtime))
                    vcNomCompletFichier = substitute('&1&3gest&3tmp&3&2', mToken:getValeur('REPGI'), vcNomFichier, outils:separateurRepertoire())
                .
                copy-lob from vmFichier to file vcNomCompletFichier.
                set-size(vmFichier) = 0. /* sinon erreur -> Impossible d'allouer la mémoire pour un large object */
                if search(vcNomCompletFichier) = ? then do:
                    mError:createError({&error}, 1000235, vcNomCompletFichier). /* Impossible de créer le fichier &1 */
                    next BoucleFichierVerse.
                end.
                assign
                    file-info:file-name = vcNomCompletFichier
                    viTailleFichier = file-info:file-size
                    /* création de l'archive */
                    vcNomArchive    = f_zipfile(vcNomCompletFichier, vcNomFichier, VcExtension)
                .
                os-delete value(vcNomCompletFichier).
                if fisNull(vcNomArchive) then next BoucleFichierVerse.

blocTransaction:
                for each ttRoleVersement
                    where ttRoleVersement.id-fich = ttDOcumentGED.iIdentifiantGed
                    transaction on error undo, retry:
                    if retry then do:
                        vlAnomalieFichier = true.
                        next blocTransaction.
                    end.
                    assign
                        ttDocumentGED.iCodeTypeRole    = integer(ttRoleVersement.cTypeRole)
                        ttDocumentGED.iNumeroRole      = ttRoleVersement.iNumeroRole
                        ttDocumentGED.cCodeTypeContrat = ttRoleVersement.cTypeContrat
                        ttDocumentGED.iNumeroContrat   = ttRoleVersement.iNumeroContrat
                        ttDocumentGED.iNumeroTiers     = ttRoleVersement.iNumeroTiers
                        viIdentifiantGed               = 0
                    .
                    /*** CHRONO ****/
                    {&_proparse_ prolint-nowarn(wholeindex)}
                    for last igeddoc no-lock:
                        viIdentifiantGed = igeddoc.id-fich + 1.
                    end.
                    for first iparm exclusive-lock where iparm.tppar = "GED":
                        assign
                            viIdentifiantGed = maximum(viIdentifiantGed, iparm.zone1 + 1)
                            iparm.zone1      = viIdentifiantGed
                        .
                    end.
                    create igeddoc.
                    assign
                        igeddoc.resid     = ?
                        igeddoc.id-fich   = viIdentifiantGed
                        igeddoc.chfichier = ttFichierVerse.cCheminFichier
                        igeddoc.nmfichier = ttFichierVerse.cNomFichier
                        igeddoc.statut-cd = "3" // 1 = transféré, 2 non transféré, 3 non copié dans le repertoire avant transfert
                        igeddoc.ident_u   = mToken:cUser
                        igeddoc.dacre     = today
                        igeddoc.cdivers2  = substitute("&2&1&3&1&4&1&5",
                                                       separ[1],
                                                       hex-encode(md5-digest(vmFichier)), /* Empreinte MD5 du fichier */
                                                       viTailleFichier,                   /* Taille du fichier en octets */
                                                       string(ttFichierVerse.daDateModification, "99/99/9999"), /* Date de derniere modification du fichier */
                                                       substring(igeddoc.nmfichier, r-index(igeddoc.nmfichier, ".") + 1)) /* Extension */
                        igeddoc.tpidt     = ttDocumentGed.cTypeIdentifiant   // assigné uniquement en création
                        igeddoc.noidt     = ttDocumentGed.iNumeroIdentifiant // assigné uniquement en création

                    .
                    run setDocumentGED(buffer igeddoc, vhProcGidemat, vhProcRole, output vlErreur).
                    if not vlErreur then run setExtranet(buffer igeddoc, output vlErreur).
                    /* copie du fichier dans le répertoire fileWatcher si immediat ou ged si differé */
                    if vlErreur
                    or not f_creationDansDossierTransfert(voCollection:getCharacter("cTypeTransfert")
                                                        , vcNomArchive, substitute("&1.&2.7z", string(viIdentifiantGed),vcExtension), vhProcGidemat)
                    then do:
                        os-delete value(vcNomCompletFichier).
                        undo blocTransaction, next blocTransaction.
                    end.
                    if voCollection:getCharacter("cTypeTransfert") <> "I" then igeddoc.statut-cd = "2".
                    mError:createInfoRowid(rowid(igeddoc)). // enregistrement créé, permet de renvoyer le rowid en réponse.
                    viNombreVersement = viNombreVersement + 1.
                end. /* transaction ttRoleVerse */
                if vlVersementMasse and not vlAnomalieFichier
                then for first igedrep no-lock                    /* déplacement du fichier du répertoire de scan vers la corbeille */
                    where igedrep.nom-doss = ttFichierVerse.cNomDossier
                      and igedrep.chemin-corb > ""
                      and igedrep.chemin-dos <> igedrep.chemin-corb:
                    os-copy value(substitute('&1&3&2', igedrep.chemin-doss, ttFichierVerse.cNomFichier, outils:separateurRepertoire()))
                            value(substitute('&1&3&2', igedrep.chemin-corb, ttFichierVerse.cNomFichier, outils:separateurRepertoire())).
                    if search(substitute('&1&3&2', igedrep.chemin-corb, ttFichierVerse.cNomFichier, outils:separateurRepertoire())) <> ?
                    then os-delete value(substitute('&1&3&2', igedrep.chemin-doss, ttFichierVerse.cNomFichier, outils:separateurRepertoire())).
                end.
                os-delete value(vcNomArchive).
            end.  /* for each ttFichierVerse */
        end. /* for each ttDocumentGED */
        if viNombreVersement = 1 then mError:createError({&info}, 1000302). /* Versement effectué */
        else if viNombreVersement > 1 then mError:createError({&info}, 1000303, string(viNombreVersement)). /* &1 versements effectués */
    end. /* creation */
    delete object voCollection no-error.
    if valid-handle(vhProcGidemat) then run destroy in vhProcGidemat.
    if valid-handle(vhProcGidemat) then run destroy in vhProcRole.

end procedure.

procedure sendDocumentFileWatcher:
    /*------------------------------------------------------------------------------
    Purpose: Transfert depuis répertoire filewatcher
    Notes  : service utilisé par beVersement.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcNomfichier as character no-undo.

    define variable vhProcGidemat as handle no-undo.

    if not f_GedActive() then return.

    run ged/gidemat.p persistent set vhProcGidemat.
    run getTokenInstance in vhProcGidemat(mToken:JSessionId).

message "Transfert FileWatcher fichier " pcNomfichier.

    if f_copieVersDossierGed(pcNomfichier, vhProcGidemat) /* copie du fichier vers svg/ged  */
    then do:

message "Transfert gidemat fichier " pcNomfichier.

        run gidemat_trsf_docs in vhProcGidemat (entry(1, pcNomfichier, ".")).
    end.
    run destroy in vhProcGidemat.

end procedure.

procedure sendDocumentGed:
    /*------------------------------------------------------------------------------
    Purpose: Transfert depuis répertoire GED
    Notes:   service utilisé par beVersement.cls
    ------------------------------------------------------------------------------*/
    define input parameter piIdentifiantGed as int64 no-undo.

    define variable vhProcGidemat as handle no-undo.
    define buffer igeddoc for igeddoc.

    if not f_GedActive() then return.

    run ged/gidemat.p persistent set vhProcGidemat.
    run getTokenInstance in vhProcGidemat(mToken:JSessionId).
    if piIdentifiantGed = 0
    then do:
        for each igeddoc no-lock
            where igeddoc.statut = "3": /* Tous les fichiers du répertoire FileWatcher */
            if f_copieVersDossierGed(substitute("&1.&2.7z",string(igeddoc.id-fich),substring(igeddoc.nmfichier, r-index(igeddoc.nmfichier, ".") + 1)), vhProcGidemat) /* copie du fichier vers svg/ged  */
            then run gidemat_trsf_docs in vhProcGidemat (string(igeddoc.id-fich)).
        end.
        for each igeddoc no-lock
            where igeddoc.statut = "2": /* Tous les fichiers non transferes */
            run gidemat_trsf_docs in vhProcGidemat (string(igeddoc.id-fich)).
        end.
    end.
    else do:
        for first igeddoc no-lock
            where igeddoc.statut  = "3"                   // fichier du répertoire FileWatcher
              and igeddoc.id-fich = piIdentifiantGed:     // uniquement le fichier demandé
            if f_copieVersDossierGed(substitute("&1.&2.7z",string(igeddoc.id-fich),substring(igeddoc.nmfichier, r-index(igeddoc.nmfichier, ".") + 1)), vhProcGidemat) /* copie du fichier vers svg/ged  */
            then run gidemat_trsf_docs in vhProcGidemat (string(igeddoc.id-fich)).
        end.
        for first igeddoc no-lock
            where igeddoc.statut  = "2"                   // non transféré
              and igeddoc.id-fich = piIdentifiantGed:     // uniquement le fichier demandé
            run gidemat_trsf_docs in vhProcGidemat (string(igeddoc.id-fich)).
        end.
    end.
    run destroy in vhProcGidemat.
  
end procedure.

procedure getIndex private:
    /*------------------------------------------------------------------------------
    Purpose: Extraction des champs d'index
    Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer igeddoc for igeddoc.
    define output parameter poCollection as collection no-undo.

    poCollection = new collection().
    poCollection:set('dadoc', igeddoc.dadoc).
    poCollection:set('nbpag', igeddoc.nbpag).
    poCollection:set('cdoctype', igeddoc.cdoctype).
    poCollection:set('ctypdos', igeddoc.ctypdos).
    poCollection:set('nomdt', igeddoc.nomdt).
    poCollection:set('cnumcpt', igeddoc.cnumcpt).
    poCollection:set('ctypetrait', igeddoc.ctypetrait).
    poCollection:set('canneemois', igeddoc.canneemois).
    poCollection:set('clibtrt', igeddoc.clibtrt).
    poCollection:set('clibcpt', igeddoc.clibcpt).
    poCollection:set('cdestinat', igeddoc.cdestinat).
    poCollection:set('id-fich', igeddoc.id-fich).

end procedure.

procedure deleteDocumentGED :
    /*------------------------------------------------------------------------------
    Purpose: Suppression d'un document GED
    Notes: service utilisé par beVersement.cls
    ------------------------------------------------------------------------------*/
    define input parameter piIdentifiantGed as int64   no-undo.

    define variable vhProcGidemat            as handle no-undo.
    define variable vcReferenceClientGidemat as character no-undo.
    define buffer igeddoc for igeddoc.

    if not f_GedActive() then return.

    run ged/gidemat.p persistent set vhProcGidemat.
    run getTokenInstance in vhProcGidemat(mToken:JSessionId).
    vcReferenceClientGidemat = dynamic-function("f_referenceClientGidemat" in vhProcGidemat).
    if vcReferenceClientGidemat > ""
    then do:
        if controleDeleteUpdateGed('D', piIdentifiantGed)
        then for first igeddoc exclusive-lock
            where igeddoc.id-fich = piIdentifiantGed transaction:
            run gidemat_del_docs in vhProcGidemat(string(igeddoc.id-fich)).
        end.
    end.
    else mError:createError({&error}, 1000231). /* Référence client Gidemat non renseignée */
    run destroy in vhProcGidemat.

end procedure.

procedure getScan:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par beVersement.cls
    ------------------------------------------------------------------------------*/
    define input parameter pcChemin as character no-undo.
    define input parameter pcVue    as character no-undo.
    define output parameter table for ttRepertoireScan.
    define output parameter table for ttFichierScan.
    define output parameter table for ttRepertoireScanUtilisateur.

    define variable vcNomFichier      as character no-undo.
    define variable vcAttributFichier as character no-undo.

    define buffer igedrep  for igedrep.
    define buffer igedrusr for igedrusr.
    define buffer tutil    for tutil.

    empty temp-table ttFichierScan.
    empty temp-table ttRepertoireScan.
    empty temp-table ttRepertoireScanUtilisateur.

    {&_proparse_ prolint-nowarn(wholeindex)}
boucle:
    for each igedrep no-lock
        where (pcChemin > "" and igedrep.chemin-doss = pcChemin) or fisNull(pcChemin):
        if pcvue <> "PARAMETRAGE"
        and not can-find(first igedrusr no-lock
                         where igedrusr.ident_u = mToken:cUser
                           and igedrusr.nom-doss = igedrep.nom-doss)
        then next boucle. /* L'utilisateur n'a pas les droits d'accès à ce répertoire */

        create ttRepertoireScan.
        assign
            ttRepertoireScan.cNomDossier      = igedrep.nom-doss
            ttRepertoireScan.cLibelleDossier  = igedrep.lib-doss
            ttRepertoireScan.rRowid           = rowid(igedrep)
            ttRepertoireScan.dtTimestamp      = datetime(igedrep.dtmsy, igedrep.hemsy)
            ttRepertoireScan.cCheminDossier   = igedrep.chemin-doss
            ttRepertoireScan.cCheminCorbeille = igedrep.chemin-corb  when pcvue = "PARAMETRAGE"
        .
        if pcvue <> "PARAMETRAGE" then do: // contenu du repertoire
            file-info:file-name = igedrep.chemin-doss.
            if file-info:file-type matches "*D*" then do:
                input from os-dir(igedrep.chemin-doss).
                repeat:
                    import vcNomFichier ^ vcAttributFichier.
                    if vcAttributFichier = "F"  then do: /* F => fichiers uniquement */
                        create ttFichierScan.
                        assign
                            ttFichierScan.cNomDossier = ttRepertoireScan.cNomDossier
                            ttFichierScan.cNomFichier = vcNomFichier
                        .
                    end.
                end.
                input close.
            end.
        end.
        else for each igedrusr no-lock                    // liste des utilisateurs autorisés pour ce répertoire
            where igedrusr.nom-doss = igedrep.nom-doss:
            create ttRepertoireScanUtilisateur.
            assign
                ttRepertoireScanUtilisateur.cNomDossier      = igedrep.nom-doss
                ttRepertoireScanUtilisateur.cCodeUtilisateur = igedrusr.ident_u
                ttRepertoireScanUtilisateur.lAutorise        = true
            .
            for first tutil no-lock where tutil.ident_u = igedrusr.ident_u:
                ttRepertoireScanUtilisateur.cNomUtilisateur = tutil.nom.
            end.
        end.
    end.
end procedure.

procedure createScan:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par beVersement.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttRepertoireScan.
    define input parameter table for ttRepertoireScanUtilisateur.

    define buffer igedrep for igedrep.

    if not f_GedActive() then return.

blocTransaction:
    do transaction:
        for each ttRepertoireScan where ttRepertoireScan.CRUD = "C":
            if not controleUpdateScan() then undo blocTransaction, leave blocTransaction.

            find first igedrep no-lock
                where igedrep.nom-doss = ttRepertoireScan.cNomDossier no-error.
            if not available igedrep then do:
                create igedrep.
                // run setScan(buffer igedrep).
                if not outils:copyValidLabeledField(buffer igedrep:handle, buffer ttRepertoireScan:handle, 'U', mtoken:cUser) // U car pas de champs cdcsy
                then undo blocTransaction, leave blocTransaction.
                if not f_majRepertoireScanUtilisateur()
                then undo blocTransaction, leave blocTransaction.
                mError:createInfoRowid(rowid(igedrep)). // enregistrement créé, permet de renvoyer le rowid en réponse.
            end.
            else do:
                mError:createError({&error}, 1000258,ttRepertoireScan.cNomDossier). /* Répertoire de scan &1 déjà existant; */
                undo blocTransaction, leave blocTransaction.
            end.
        end.
    end.
end procedure.

procedure deleteScan:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par beVersement.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttRepertoireScan.

    define variable vlPasse as logical no-undo.
    define buffer igedrep  for igedrep.
    define buffer igedrusr for igedrusr.

    if not f_GedActive() then return.

blocTransaction:
    do transaction on error undo, leave:
        for each ttRepertoireScan where ttRepertoireScan.CRUD = "D"
          , first igedrep exclusive-lock
            where rowid(igedrep) = ttRepertoireScan.rRowid:
            for each igedrusr exclusive-lock where igedrusr.nom-doss = ttRepertoireScan.cNomDossier:
                delete igedrusr.
            end.
            delete igedrep.
            vlPasse = true.
        end.
        if vlPasse then mError:createError({&info}, 1000263). /* Suppression effectuée */
    end.
end procedure.

procedure updateScan:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par beVersement.cls
    ------------------------------------------------------------------------------*/
    define input parameter table for ttRepertoireScan.
    define input parameter table for ttRepertoireScanUtilisateur.

    define variable vcLibelleDossier as character no-undo.
    define variable vlPasse           as logical no-undo.

    define buffer igedrep  for igedrep.
    define buffer igedrusr for igedrusr.

    if not f_GedActive() then return.

    vcLibelleDossier = substitute("&1 &2", outilTraduction:getLibelle(105132), "&1").
blocTransaction:
    do transaction on error undo, leave:
        for each ttRepertoireScan where ttRepertoireScan.CRUD = "U"
          , first igedrep exclusive-lock
            where rowid(igedrep) = ttRepertoireScan.rRowid:
            if not controleUpdateScan() then undo blocTransaction, leave blocTransaction.

            if outils:isUpdated(buffer igedrep:handle, vcLibelleDossier, igedrep.nom-doss, ttRepertoireScan.dtTimestamp)
            then undo blocTransaction, leave blocTransaction.

            for each igedrusr exclusive-lock where igedrusr.nom-doss = igedrep.nom-doss:
                igedrusr.nom-doss = ttRepertoireScan.cNomDossier.
            end.
            if not f_majRepertoireScanUtilisateur() then undo blocTransaction, leave blocTransaction.

            if not outils:copyValidLabeledField(buffer igedrep:handle, buffer ttRepertoireScan:handle, 'U', mtoken:cUser)
            then undo blocTransaction, leave blocTransaction.

            if not f_majRepertoireScanUtilisateur() then undo blocTransaction, leave blocTransaction.
            vlPasse = true.
        end.
        if vlPasse then  mError:createError({&info}, 1000256, " "). /* Mise à jour effectuée &1  */
    end.
end procedure.

procedure setExtranet private:
    /*------------------------------------------------------------------------------
    Purpose: Assignation igeddoc creation/modif
    Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer igeddoc  for igeddoc.
    define output parameter plErreur as logical no-undo initial true.

    assign
        igeddoc.web-fgmadisp = ttDocumentGED.lPublie /* Mettre à dispo sur giextranet */
        igeddoc.web-libobjet = ttDocumentGED.cObjetGiExtranet /* Objet giextranet  */
        igeddoc.web-theme-cd = ttDocumentGED.cCodeThemeGiExtranet /* theme extranet */
        igeddoc.cdivers5     = substitute('&1,&2,&3,&4,&5'
                                        , string(ttDocumentGED.lVisibiliteCS, "O/N")
                                        , string(ttDocumentGED.lVisibiliteLocataire, "O/N")
                                        , string(ttDocumentGED.lVisibiliteProprietaire, "O/N")
                                        , string(ttDocumentGED.lVisibiliteCoproprietaire, "O/N")
                                        , string(ttDocumentGED.lVisibiliteEmployeImmeuble, "O/N"))
        igeddoc.cdivers4     = (if ttDocumentGED.lNonPubliable then "O" else "")
    no-error.
    plErreur = error-status:error.
end procedure.

procedure setDocumentGED private:
    /*------------------------------------------------------------------------------
    Purpose: Assignation igeddoc creation/modif
    Notes:
    ------------------------------------------------------------------------------*/
    define parameter buffer igeddoc for igeddoc.
    define input parameter  phProcGidemat as handle  no-undo.
    define input parameter  phProcRole    as handle  no-undo.
    define output parameter plErreur      as logical no-undo initial true.

    define variable voCollectionOld as class collection no-undo.
    define variable voCollectionNew as class collection no-undo.
    define variable vcIdentifiant as character no-undo.

    define buffer ietab    for ietab.
    define buffer igedtypd for igedtypd.
    define buffer vbRoles  for roles.

    /* --> Mise a jour des champs */
    run getIndex(buffer igeddoc, output voCollectionOld).
    /* Sauvegarde de l'identifiant de la piece/facture... avant modif  */
    vcIdentifiant = if index(igeddoc.lbrech, "IDENTIFIANT_") > 0
                    then substring(igeddoc.lbrech, index(igeddoc.lbrech, "IDENTIFIANT_"))
                    else "".
    if ttDocumentGED.iNumeroMandat > 0
    then find first ietab no-lock
        where ietab.soc-cd  = ttDocumentGED.iCodeReferenceSociete
          and ietab.etab-cd = ttDocumentGED.iNumeroMandat no-error.
    find first ttTypeRole
        where ttTypeRole.cTypeRole = string(ttDocumentGED.iCodeTypeRole,"99999") no-error.
    find first vbRoles no-lock
        where vbRoles.tprol = string(ttDocumentGED.iCodeTypeRole, "99999")
          and vbRoles.norol = ttDocumentGED.iNumeroRole no-error.
    find first igedtypd no-lock
        where igedtypd.typdoc-cd = ttDocumentGED.iNumeroTypeDocument no-error.
    assign
        igeddoc.num-soc      = ttDocumentGED.iCodeReferenceSociete when ttDocumentGED.CRUD = 'C'
        igeddoc.typdoc-cd    = ttDocumentGED.iNumeroTypeDocument
        igeddoc.dadoc        = ttDocumentGED.daDateDuDoc
        igeddoc.libobj       = ttDocumentGED.cObjet
        igeddoc.cdnat        = ttDocumentGED.cCodeNatureDocument /* Nature du document */
        igeddoc.nomdt        = ttDocumentGED.iNumeroMandat
        igeddoc.noimm        = ttDocumentGED.iNumeroImmeuble
        igeddoc.nolot        = ttDocumentGED.iNumeroLot
        igeddoc.notie        = (if available vbRoles and ttDocumentGED.iNumeroTiers = 0 then vbRoles.notie else ttDocumentGED.iNumeroTiers)
        igeddoc.tprol        = ttDocumentGED.iCodeTypeRole
        igeddoc.norol        = ttDocumentGED.iNumeroRole
        igeddoc.nomrol       = f_nomrol(string(igeddoc.tprol,"99999"), igeddoc.norol, igeddoc.notie)
        igeddoc.tpctt        = (if igeddoc.notie > 0 and lookup(string(igeddoc.notie), dynamic-function("f_LstCabinet" in phProcRole)) = 0 then ttDocumentGED.cCodeTypeContrat else "")          /* Type de contrat */
        igeddoc.noctt        = (if igeddoc.notie > 0 and lookup(string(igeddoc.notie), dynamic-function("f_LstCabinet" in phProcRole)) = 0 and trim(ttDocumentGED.cCodeTypeContrat) > "" then ttDocumentGED.iNumeroContrat else 0)      /* N° de contrat */
        igeddoc.notie-ctt    = 0            /* n° Tiers */
        igeddoc.tprol-ctt    = 0            /* Type de role */
        igeddoc.norol-ctt    = 0            /* N° de role */
        igeddoc.nomrol-ctt   = ""
        igeddoc.noord        = ttDocumentGED.iNumeroOrdre when ttDocumentGED.iNumeroOrdre <> ?
        igeddoc.nodoss       = ttDocumentGED.iNumeroDossier
        igeddoc.cdivers1     = ttDocumentGED.cMotCle /* Mot clé */
        igeddoc.theme-cd     = ttDocumentGED.cCodeThemeGed /* code theme  ged */
        igeddoc.bloque-user  = "" /* code utilisateur qui bloque le document */
        igeddoc.ccaracfic    = "" /* caractéristiques du fichier taille,date,crc... */
        igeddoc.comment      = "" /* Commentaires */
        igeddoc.typ-ratt     = "" /* Type de rattachement (pas utilisé, fait doublon avec web-typratt !) */
        igeddoc.libdesc      = ttDocumentGED.cDescriptif /* Descriptif */
        igeddoc.noctrat      = string(ttDocumentGED.iNumeroContratFournisseur) /* Numéro de contrat fournisseur */
        igeddoc.liaison-cd   = 0 /* code liaison des documents */
        igeddoc.nbpag        = 0
        igeddoc.origine      = "" /* Code origine des fichiers non stocké dans tbfic (ex : fichier joint des interventions) */
        igeddoc.cddom        = "00000" /* Code domaine évènement */
        igeddoc.cdsto        = "00000" /* Code sous-domaine évènement */
        igeddoc.cnumcpt      = (if igeddoc.notie = 0 and igeddoc.tprol = 0
                                then "00000"
                                else if igeddoc.norol > 0
                                     then substring(string(igeddoc.norol, "9999999999"), 6)
                                     else trim(string(igeddoc.notie, ">>>>>99999")))
        igeddoc.cnumsscpt    = ""
        igeddoc.clibcpt      = igeddoc.nomrol /* Nom du tiers */
        igeddoc.clibtrt      = igeddoc.libobj
        igeddoc.cdoctype     = (if igedtypd.gidemat-typdoc > "" then igedtypd.gidemat-typdoc else "9999") /* 9999 = divers */
        igeddoc.cdestinat    = (if available ttTypeRole then ttTypeRole.cLibelleTypeRole else "")
        igeddoc.ctypetrait   = igedtypd.gidemat-typtrait
        igeddoc.ctypdos      = (if entry(2, igedtypd.cdivers, separ[1]) > "" then entry(2, igedtypd.cdivers, separ[1]) else "CAB") /* CAB = Cabinet */
        igeddoc.canneemois   = string(igeddoc.id-fich)
        igeddoc.web-cdivers1 = ""
        igeddoc.web-cdivers2 = ""
        igeddoc.web-dadeb    = ? /* Date de début de mise à dispo */
        igeddoc.web-dafin    = ? /* Date de fin de mise à dispo */
        igeddoc.web-idivers1 = 0
        igeddoc.web-idivers2 = 0
        igeddoc.web-nomfic   = ""
        igeddoc.web-transf   = 0  /* Transféré sur giextranet 0 = Non, 1 = oui */
        igeddoc.web-typfonc  = "" /* Complete ou remplace les doc du meme theme */
        igeddoc.web-typratt  = "" /* Type de rattachement des contrats T=Tous, S=Liste Sauf contrats, L=Liste contrats */
        igeddoc.cdivers3     = ""
        igeddoc.lbrech       = substitute("MDT_&1 TIERS_&2 IMM_&3 LOT_&4 THM_&5 TPROL_&6 CDDOM_&7 CDSTO_&8 TPMDT_&9"
                                  , string(igeddoc.nomdt, "99999")
                                  , if igeddoc.notie = 0 and igeddoc.tprol = 0
                                            then ""
                                            else if igeddoc.notie > 0
                                                 then "T" + string(igeddoc.notie)
                                                 else substitute("F&1-&2", string(igeddoc.tprol), string(igeddoc.norol))
                                  , string(igeddoc.noimm, "999999999")
                                  , string(igeddoc.nolot, "999999999")
                                  , string(integer(igeddoc.theme-cd), "99999")
                                  , string(igeddoc.tprol, "99999")
                                  , trim(igeddoc.cddom)
                                  , trim(igeddoc.cdsto)
                                  , string(if available ietab then ietab.profil-cd else 0, "99")
                              )
                              + substitute(" DADOC_&1 NUMSOC_&2 TYPDOC_&3 CDNAT_&4 CTRASS_&5-&6 NODOSS_&7 CTRATF_&8 EMPREINTEMD5_&9"
                                  , string(igeddoc.dadoc, "99/99/9999")
                                  , string(igeddoc.num-soc, "99999")
                                  , string(igeddoc.typdoc-cd)
                                  , igeddoc.cdnat
                                  , igeddoc.tpctt
                                  , string(igeddoc.noctt)
                                  , string(igeddoc.nodoss)
                                  , replace(igeddoc.noctrat, " ", "_")
                                  , entry(1, igeddoc.cdivers2, separ[1])
                              )
                              + substitute("&1 &2 &3 &4"
                                  , if vcIdentifiant > "" then " " + trim(vcIdentifiant) else ""
                                  , trim(igeddoc.cdivers1)    /* Mot clé sans balise */
                                  , trim(igeddoc.libdesc)     /* Descriptif sans balise */
                                  , trim(igeddoc.libobj)      /* objet sans balise */
                              )
    .
    if not error-status:error then do:
        /* Mise à jour des index sur gidemat */
        run getIndex(buffer igeddoc, output voCollectionNew).
        if not voCollectionNew:isEmpty() and not voCollectionOld:isEqual(voCollectionNew)
        then run gidemat_mod_idx in phProcGidemat(igeddoc.num-soc, igeddoc.resid, voCollectionNew:serialize()).
        plErreur = false.
    end.
    else mError:createError({&error}, 1000228, "igeddoc"). /* Mise à jour impossible de [&1] */

end procedure.

procedure getListeTypeDocumentGed:
    /*------------------------------------------------------------------------------
    Purpose: Extraction de la liste ds types de documents
    Notes:   service utilisé par beVersement.cls
    ------------------------------------------------------------------------------*/
    define input  parameter pcListeNumeroTypeDocument as character no-undo.
    define output parameter table for ttGedTypeDocument.

    define variable vcWhereClause        as character no-undo.
    define variable viNumeroTypeDocument as integer   no-undo initial ?.

    empty temp-table ttGedTypeDocument.
    if pcListeNumeroTypeDocument >= "" then do:
        if num-entries(pcListeNumeroTypeDocument) = 1 then do:
            viNumeroTypeDocument = integer(pcListeNumeroTypeDocument) no-error.
            if not error-status:error then do:
                if viNumeroTypeDocument > 0
                    then vcWhereClause = substitute("where igedtypd.typdoc-cd = &1", pcListeNumeroTypeDocument). // 1 seul type de doc
            end.
        end.
        else vcWhereClause = substitute("where lookup(string(igedtypd.typdoc-cd),'&1') > 0", pcListeNumeroTypeDocument).    // liste de types de doc
    end.
    run createttGedTypeDocument(vcWhereClause).
end procedure.

procedure createttGedTypeDocument private :
    /*------------------------------------------------------------------------------
    Purpose: Création d'un enregistrement ttGedTypeDocument
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcWhereClause as character no-undo.

    define variable vhBuffer        as handle    no-undo.
    define variable vhquery         as handle    no-undo.
    define variable voCollection    as collection no-undo.

    if pcWhereClause >= "" then do:
        voCollection = new collection().
        create buffer vhBuffer for table "igedtypd".
        create query vhquery.
        vhquery:set-buffers(vhBuffer).
        vhquery:query-prepare(substitute('for each igedtypd no-lock &1', pcWhereClause)).
        vhquery:query-open().
boucle:
        repeat:
            vhquery:get-next().
            if vhquery:query-off-end then leave boucle.
            voCollection = f_TypeDeDocument(voCollection, vhBuffer).
            create ttGedTypeDocument.
            assign
                ttGedTypeDocument.iNumeroTypeDocument  = vhBuffer::typdoc-cd
                ttGedTypeDocument.cCodeOrigine         = vhBuffer::orig-cd
                ttGedTypeDocument.cLibelleTypeDocument = voCollection:getCharacter("cLibelleTypeDocument") 
                ttGedTypeDocument.cCodeTheme           = voCollection:getCharacter("cCodeTheme")
                ttGedTypeDocument.cObjet               = voCollection:getCharacter("cObjet") 
                ttGedTypeDocument.lUtilise             = voCollection:getLogical  ("lUtilise")
                ttGedTypeDocument.cTypeDossierGidemat  = voCollection:getCharacter("cTypeDossierGidemat")
            .                
        end.
        vhquery:query-close() no-error.
        delete object vhquery no-error.
        delete object vhBuffer no-error.
        delete object voCollection no-error.
    end.

end procedure.