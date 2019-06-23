/*-----------------------------------------------------------------------------
File        : courrier.p
Purpose     : Genereration des courriers travaux
Author(s)   : AF - 2006/04/25
Notes       :
01 29/08/2006 JR   0505/0112: Travaux Lots 2, Relances devis Fournisseurs
02 24/11/2006 CC   0604/0251: mail&fax à partir des interventions
03 06/03/2008 NP   1207/0068: Pb de fusion d'un OS avec TVA à 5.5%
04 01/04/2008 SY   1007/0003: événements lot 3, Utilisation paramétrage Dossier automatique
                   ATTENTION: nouveaux param E/S creereve.p => A LIVRER AVEC TOUS LES PROGRAMMES QUI APPELLENT creereve.p.
05 04/11/2008 SY   1007/0003: Nlles modifs pour Dossier TRAVAUX. Bloquer courrier Devis si pas de fournisseur
06 01/02/2010 PL   1209/0010: Ajout theme
07 07/02/2010 PL   0211/0036: modification à la volée lors de l' édition de l'os du fournisseur si celui ci à changé depuis la dernière édition.
08 17/09/2012 PL   0512/0056: modification code TVA à 5 pour attestation tva à 7% et non plus 5,5%
09 20/09/2012 PL   0812/0143: pb si mauvais param destinataire du modèle et fusion. Pas de document et on ne pouvait plus fusionner après rectif du param.
10 19/09/2013 SY   0913/0099: Demande Michel LAURENT dans les évènements la zone "Pour" doit etre alimentée par le responsable travaux sélectionné dans la saisie des interventions                
11 17/10/2013 SY   1013/0144: Pb destinataire FOU écrasé par 0 => Cabinet DAUCHEZ ! (si courrier à partir de la liste et non de l'écran)
12 20/11/2013 SY   1013/0167: taux TVA 7% passe à 10% changement des taux au 01/01/2014
13 18/12/2013 SY   1013/0167: TVA 2014 - attestation TVA gestion des modèles d'attestation TVA par taux => nouveaux types de document 10 et 11
14 10/01/2014 SY   1113/0168: TVA 2014 - annulation modifs ci-dessus à la demande de Geneviève (on revient à 1 seul document quel que soit le taux)
15 02/04/2014 DM   0712/0239: GED
16 09/07/2014 DM   0712/0239: Droits GED
17 06/11/2015 SY   1015/0224: Ajout glmdi = FALSE pour Email.p par sécurité (ne doit pas être ouvert en onglet)
18 24/08/2016 NP   0416/0200: Gestion param nom documents pour ALLZ
19 26/08/2016 DM   0616/0084: LRE
20 22/11/2016 NP   1116/0088: Modif TbTmpInt.i
-----------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2fichier.i}
{preprocesseur/type2intervention.i}
{preprocesseur/statut2intervention.i}

using bureautique.fusion.classe.fusionWord.
using Telerik.Windows.Documents.Flow.Model.*.
using Telerik.Windows.Documents.Flow.FormatProviders.Docx.*.
using Telerik.Windows.Documents.Flow.FormatProviders.Pdf.*.
using System.Collections.ArrayList.
using parametre.pclie.parametrageRepertoireMagi.
using System.Object.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{bureautique/include/fichier.i}
{bureautique/fusion/include/ttCourrier.i}
{bureautique/fusion/include/decodorg.i}    // procedure decodorg

define variable gcExtension      as character no-undo initial {&TYPEFICHIER-docx}.
define variable gcRepertoireWord as character no-undo initial "C:\MAGI\WORD\".    // todo   initialiser la valeur !?
define variable RpTmpFic   as character no-undo.    // todo   initialiser la valeur !?
define variable ghProcFour as handle    no-undo.
define variable goListFusion as class System.collections.ArrayList no-undo.

/*--STREAM-----------------------------------------------------------------------------------------------------------------*/
define new shared stream LbCheDon.    // tel qu'utilisé, pas shared
define new shared stream LbCheBas.    // tel qu'utilisé, pas shared
define            stream LbCheMai.    // todo  stream non ouvert !?
define            stream LbCheBma.    // todo  stream non ouvert !?
define stream stOScommand.

function nettoyageNom returns character(pcNom as character):
    /*------------------------------------------------------------------------------
    Purpose: remplace les caractères non alphaNumériques et non ".-_" par "-"
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vi as integer no-undo.
    do vi = 1 to length(pcNom, "character"):
        if index("abcdefghijklmnopqrstuvwxyz0123456789-_.", substring(pcNom, vi, 1, "character")) = 0
        then substring(pcNom, vi, 1, "character") = "-".
    end.
    return pcNom.
end function.

function typeDocument returns integer private(pcTypeTraitement as character, plIntervention as logical, pcCodeStatut as character):
    /*------------------------------------------------------------------------------
    Purpose: valeurs 1, 3, 4, 5, 6, 7
    Notes:
    ------------------------------------------------------------------------------*/
    case pcTypeTraitement:
        when {&TYPEINTERVENTION-signalement}   then return 1.
        when {&TYPEINTERVENTION-demande2devis} then return if pcCodeStatut = "00050" then 5 else if plIntervention then 4 else 3.
        when {&TYPEINTERVENTION-ordre2service} then return if plIntervention then 7 else 6.
    end case.
end function.

function rechercheNomModele returns character(piNumeroModele as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer mddoc for mddoc.
    
    for first mddoc no-lock
        where mddoc.nodot = piNumeroModele:
        if search(gcRepertoireWord + "model/client/" + mddoc.LbDot) <> ? 
        then return gcRepertoireWord + "model/client/" + mddoc.LbDot.
        else if search(gcRepertoireWord + "model/gi/" + mddoc.LbDot) <> ?
             then return gcRepertoireWord + "model/gi/" + mddoc.LbDot.
             else return "".
    end.
    return "".
end function.

function getNomDocument returns character private():
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcAnMois     as character no-undo.
    define variable vcAnMoisJour as character no-undo.
    define variable vcUser       as character no-undo.
    define variable vcUnite      as character no-undo initial "0".
    define variable vcDizaine    as character no-undo initial "00".
    define variable vcSequence   as character no-undo initial "000".
    define variable vcNomFichier as character no-undo.
    define buffer prmtv for prmtv.

    assign
        vcUser       = substring(mtoken:cUser, 1, 3, "character")
        vcAnMois     = string(year(today) modulo 100, "99") + string(month(today), "99")
        vcAnMoisJour = vcAnMois + string(day(today), "99")
    .
    /* Creation du repertoire mensuel */
    if search(substitute("&1docum/&2/lisezmoi.txt", gcRepertoireWord, vcAnMois)) = ?
    then do:
        output stream stOScommand to value(rpTmpFic + "Commande.bat").
        put stream stOScommand unformatted skip "MD " gcRepertoireWord "docum~\" vcAnMois.
        put stream stOScommand unformatted skip "ECHO " today ">" gcRepertoireWord "docum~\" vcAnMois "~\lisezmoi.txt".
        put stream stOScommand unformatted skip "exit".
        output stream stOScommand close.
        os-command silent value(rpTmpFic + "Commande.bat").
    end.
    /* NP 0416/0200 Gestion param nom des documents pour ALLIANZ **/
    for first prmtv no-lock
        where prmtv.tppar = "INDEX"
          and prmtv.cdpar = "00002"
          and prmtv.noord = 1:
        vcNomFichier = substitute("&1/&2_&3_&4_&5_&6_&7_",
                                  vcAnMois, ttDocument.nocon, ttDocument.nmimm, ttDocument.noimm, ttDocument.nmfou, ttDocument.nofou, ttDocument.notrt).
        do while search(substitute("&1docum/&2&3", gcRepertoireWord, vcNomFichier, vcSequence)) > "":
            if vcUnite = "9"
            then vcUnite = "A".
            else do:
                if vcUnite = "Z" 
                then assign
                    vcUnite = "0"
                    vcDizaine = string(integer(vcDizaine) + 1, "99")
                .
                else vcUnite = chr(asc(vcUnite) + 1).
            end.
            vcSequence = vcDizaine + vcUnite.
        end.
        return replace(vcNomFichier + vcSequence, "/", "~\").    // todo   pas sur que le replace soit nécessaire.
    end.

    vcNomFichier = substitute("&1/&2&3", vcAnMois, vcUser, vcAnMoisJour).
    do while search(substitute("&1docum/&2&3.&4", gcRepertoireWord, vcNomFichier, vcSequence, gcExtension)) <> ?:
        if vcUnite = "9"
        then vcUnite = "A".
        else do:
            if vcUnite = "Z" 
            then assign
                vcUnite = "0"
                vcDizaine = string(integer(vcDizaine) + 1, "99")
            .
            else vcUnite = chr(asc(vcUnite) + 1).
        end.
        vcSequence = vcDizaine + vcUnite.
    end.
    return replace(vcNomFichier + vcSequence, "/", "~\").    // todo   pas sur que le replace soit nécessaire.
end function.

function ctrlTiersActif returns logical private(pcTypeRole as character, piNumeroFournisseur as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vcCodeIdentifiant as character no-undo.
    define variable vcNomTable        as character no-undo.
    define variable vcCollCle         as character no-undo.
    define variable vcNomOrganisme    as character no-undo.
    define variable viCodeReference   as integer   no-undo.
    define buffer ifour for ifour.
    define buffer bifour for ifour.

    if pcTypeRole > "" then do:
        
        viCodeReference = integer(mtoken:cRefGerance).
        run decodOrg(
            pcTypeRole,
            string(piNumeroFournisseur, "99999"),
            output vcCodeIdentifiant,
            output vcNomTable,
            output vcCollCle,
            output vcNomOrganisme
        ).
        if vcNomTable = "ifour" and vcCollCle = "00012" 
        then for first ifour no-lock
            where ifour.soc-cd = viCodeReference
              and ifour.coll-cle = "F"
              // TODO  si le format de ifour.cpt-cd <> "99999", il vaut mieux faire plusieurs find/plusieurs formats "999", "9999", "999999", ...!!!!! 
              and ifour.cpt-cd = string(piNumeroFournisseur, "99999"):
            return dynamic-function('isActif'     in ghProcFour, viCodeReference, ifour.cpt-cd) 
               and dynamic-function('isReference' in ghProcFour, viCodeReference, ifour.cpt-cd).
        end.
    end.
    return true.
end function.

procedure createDocIntervention:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par beBureautique.cls
    ------------------------------------------------------------------------------*/
    // define input parameter table for ttIntervention.
    define input  parameter pcCodeTraitement   as character no-undo.
    define input  parameter piNumeroTraitement as integer   no-undo.
    define input  parameter pcTypeFichier      as character no-undo.
    define output parameter table for ttFichier.

    define variable voRepertoireMagi as class parametrageRepertoireMagi no-undo.

    run tiers/fournisseur.p persistent set ghProcFour.
    run getTokenInstance in ghProcFour (mToken:JSessionId).

    assign
        gcExtension      = if pcTypeFichier = {&TYPEFICHIER-docx} or pcTypeFichier = {&TYPEFICHIER-pdf}
                           then pcTypeFichier
                           else {&TYPEFICHIER-docx}
        goListFusion     = new ArrayList()
        voRepertoireMagi = new parametrageRepertoireMagi()
        gcRepertoireWord = voRepertoireMagi:getRepertoireWord()
    .

    // for each ttIntervention:
    //    if ctrlTiersActif(if ttIntervention.cLibelleFournisseur > "" then "00012" else "", integer(ttIntervention.cCodeFournisseur)) = false
    //    then return. /* DM 0615/0237 */

        case pcCodeTraitement:
            when {&TYPEINTERVENTION-signalement}   then run createDocumentSignalement   (piNumeroTraitement).
            when {&TYPEINTERVENTION-demande2devis} then run createDocumentDemandeDevis  (piNumeroTraitement).
            when {&TYPEINTERVENTION-ordre2service} then run createDocumentOrdreDeService(piNumeroTraitement).
        end case.
    // end.
    if can-find(first ttModeleDocument) then do:
        run affectationModele.        /* Affectation des modèles aux traitements */
        run generationCourrier.       /* Generation des courriers */
        if can-find(first ttDocument) then do:
            run extraction.           /* chaine d'extraction */
            // run fusionMailing.     /* Fusion des courriers */
        end.
    end.
    run destroy in ghProcFour.
    delete object goListFusion     no-error.
    delete object voRepertoireMagi no-error.

end procedure.

procedure extraction private:
    /*------------------------------------------------------------------------------
    Purpose: Lance l'extraction des données
    Notes:
    ------------------------------------------------------------------------------*/
    define variable vhProcExtraction as handle no-undo.
    define variable voFusionGlobal   as class fusionWord no-undo.
    define buffer docum for docum.

    run bureautique/fusion/extraction.p persistent set vhProcExtraction.
    run getTokenInstance in vhProcExtraction (mToken:JSessionId).

    /* Constitution des documents de facon individuel */
    for each ttDocument
        break by ttDocument.nodot
              by ttDocument.nodoc
              by ttDocument.tprol
              by ttDocument.norol:
        assign
            ttDocument.lbdoc = getNomDocument()
            voFusionGlobal   = dynamic-function('extraction' in vhProcExtraction, ttDocument.nodoc, ttDocument.tprol, ttDocument.norol)
        .
        if valid-object(voFusionGlobal) then goListFusion:Add(voFusionGlobal).
        run fusion (ttDocument.lbdoc).
        goListFusion:Remove(voFusionGlobal).
        if last-of(ttDocument.nodoc)
        then for first docum exclusive-lock
            where docum.nodoc = ttDocument.nodoc:
            assign
                docum.lbdoc    = ttDocument.lbdoc 
                docum.tbdat[2] = today
            .
        end.
    end.
    
    delete object voFusionGlobal.
    run destroy in vhProcExtraction.

end procedure.

procedure fusion private:
    /*------------------------------------------------------------------------------
      Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcNomDocument      as character no-undo.
    define variable voDocument         as class RadFlowDocument    no-undo.
    define variable voMergedDocument   as class RadFlowDocument    no-undo.
    define variable voProviderWORD     as class DocxFormatProvider no-undo.
    define variable voProviderPDF      as class PdfFormatProvider  no-undo.
    define variable voMyFile           as "System.Byte[]"          no-undo.
    define variable vcFichierModele    as character no-undo.
    define variable vcFichierCible     as character no-undo.
    define variable vcSousDossier      as character no-undo initial "docum".
    define variable vcFile             as character no-undo.
    define variable vmFichier          as memptr    no-undo.
    assign
        voProviderWORD     = new DocxFormatProvider()
        voProviderPDF      = new PdfFormatProvider()
        vcFichierModele    = rechercheNomModele (ttDocument.nodot)
    .
    if pcNomDocument > "" and vcFichierModele > "" then do:
        assign
            vcFichierCible = substitute("&1&2~\&3.&4", gcRepertoireWord, vcSousDossier, pcNomDocument, gcExtension)
            voDocument     = voProviderWORD:Import(System.IO.File:OpenRead(vcFichierModele))
        .
        voMergedDocument = voDocument:mailMerge(goListFusion).   // Merge

        case gcExtension:
            when {&TYPEFICHIER-docx} then voMyFile = voProviderWORD:export(voMergedDocument).      // Export du document dans un fichier WORD
            when {&TYPEFICHIER-pdf}  then voMyFile = voProviderPDF:export(voMergedDocument).       // Export du document dans un fichier PDF
            otherwise voMyFile = voProviderWORD:export(voMergedDocument).
        end case.
        System.IO.File:WriteAllBytes(vcFichierCible, voMyFile).

        vcFile = vcFichierCible.
        if search(vcFile) = ?
        then do:
            mError:createError({&error}, 1000243, vcFichierCible). /* Le fichier &1 est inexistant */
            undo, leave.
        end.
        copy-lob from file vcFile to vmFichier no-error.
        create ttFichier.
        assign
            ttFichier.cNomFichier     = substitute("&1.&2", pcNomDocument, gcExtension)
            ttFichier.cCheminFichier  = substitute("&1&2", gcRepertoireWord, vcSousDossier)
            ttFichier.cContenuFichier = base64-encode(vmFichier)
            set-size(vmFichier)       = 0 /* sinon erreur -> Impossible d'allouer la mémoire pour un large object */
        .
    end.

    delete object voProviderWORD   no-error.
    delete object voProviderPDF    no-error.
    delete object voDocument       no-error.
    delete object voMergedDocument no-error.
end procedure.

procedure createDocumentSignalement private:
    /*------------------------------------------------------------------------------
      Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroSignalement as integer no-undo.
    define buffer inter for inter.
    define buffer signa for signa.

    find first inter no-lock
         where inter.nosig = piNumeroSignalement no-error.
    if not available inter then return.

    if inter.nopar = 0 
    then do:
        message "Pas de courrier possible sans 'signalé par'".
        return.
    end.
    if ctrlTiersActif(if Inter.tppar = "FOU" then "00012" else "", Inter.nopar) = false then return. /* DM 0615/0237 */

    find first signa no-lock
         where signa.nosig = piNumeroSignalement  no-error.
    //cCodeThemeEnCours = (if available(signa) then signa.lbdiv1 else "").
    run creTbDoc(
        {&TYPEINTERVENTION-signalement},
        piNumeroSignalement,
        inter.nores,
        inter.tpcon,
        inter.nodos <> 0,
        inter.cdsta,
        "",
        0,
        inter.nocon,
        inter.nodos /* DM 0712/0239 */
    ).
end procedure.

procedure createDocumentDemandeDevis private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroDevis as integer no-undo.
    define variable viNumeroResponsable  as integer no-undo.
    define buffer devis for devis.
    define buffer inter for inter.
    define buffer dtdev for dtdev.

    find first devis no-lock
         where devis.nodev = piNumeroDevis no-error.
    if not available devis then return.

    /* Ajout SY le 04/11/2008 : Recherche du fournisseur */
    if devis.nofou = 0 
    then do:
        message "Pas de courrier possible sans Fournisseur".
        return.
    end.
    if ctrlTiersActif("00012", devis.nofou) = false then return. /* DM 0615/0237 */

    /* Recherche du responsable */
    for first dtdev no-lock
        where dtdev.nodev = piNumeroDevis
      , first inter no-lock
        where inter.noint = dtdev.noint:
        viNumeroResponsable = inter.nores.
    end.
    // cCodeThemeEnCours = (if available(Devis) then Devis.lbdiv1 else "").
    run creTbDoc(
        {&TYPEINTERVENTION-demande2devis},
        piNumeroDevis,
        viNumeroResponsable,
        inter.tpcon,
        inter.nodos <> 0,
        inter.cdsta,
        "FOU",
        devis.nofou,
        inter.nocon,
        inter.nodos            /* DM 0712/0239 */
    ).
end procedure.

procedure createDocumentOrdreDeService private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroOrdreService as integer no-undo.

    define variable viNumeroResponsable as integer no-undo.
    define buffer ordse for ordse.
    define buffer dtord for dtord.
    define buffer inter for inter.

    for first ordse no-lock
        where ordse.noord = piNumeroOrdreService:
        /* Recherche du responsable */
        for first dtord no-lock
            where dtord.noord = piNumeroOrdreService
          , first inter no-lock
            where inter.noint = dtord.noint:
            viNumeroResponsable = inter.nores.
        end.
        if not ctrlTiersActif("00012", ordse.nofou) then return. /* DM 0615/0237 */
//        cCodeThemeEnCours = (if available(ordse) then ordse.lbdiv1 else "").

        run creTbDoc(
            {&TYPEINTERVENTION-ordre2service},
            piNumeroOrdreService,
            viNumeroResponsable,
            inter.tpcon,
            inter.nodos <> 0,
            inter.cdsta,
            "FOU",
            ordse.nofou,
            inter.nocon,
            inter.nodos        /* DM 0712/0239 */
        ).
   end.

end procedure.

/*
procedure createDocRelance:
    /*------------------------------------------------------------------------------
      Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeDocument as character no-undo.
    define output parameter FgRetUse       as logical   no-undo.

   for each TbTmpOrd where TbTmpOrd.fgsel no-lock:
       run creTbDoc( "01061"
                   , TbTmpOrd.noord
                   , TbTmpOrd.nores
                   , TbTmpOrd.TpCon
                   , (TbTmpOrd.NoDos <> 0)
                   , "00050"
                   , (if TbTmpOrd.nmfou <> "" then "FOU" else "")
                   , TbTmpOrd.nofou
                   , TbTmpOrd.Nocon
                   , TbTmpOrd.NoDos). /* DM 0712/0239 */
    end.
    FgRetUse = true.
end.
*/

procedure creTbDoc private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeTraitement    as character no-undo.
    define input parameter piNumeroTraitement  as integer   no-undo.
    define input parameter piNumeroResponsable as integer   no-undo.
    define input parameter pcTypeContrat       as character no-undo.
    define input parameter plIntervention      as logical   no-undo.
    define input parameter pcCodeStatut        as character no-undo.
    define input parameter pcTypeFournisseur   as character no-undo.
    define input parameter piNumeroFournisseur as integer   no-undo.
    define input parameter piNumeroContrat     as integer   no-undo. /* DM 0712/0239 */
    define input parameter piNumeroDossier     as integer   no-undo. /* DM 0712/0239 */

    define variable viTypeAttestationTVA as integer no-undo.
    define variable viTypeDocument       as integer no-undo.
    define buffer inter for inter.
    define buffer trint for trint.
    define buffer dtord for dtord.
    define buffer ordse for ordse.

    viTypeDocument = typeDocument(pcTypeTraitement, plIntervention, pcCodeStatut).
//    Mlog ("CreTbDoc : pcTypeTraitement = " + pcTypeTraitement + " piNumeroTraitement = " + STRING(piNumeroTraitement) + " piNumeroResponsable = " + STRING(piNumeroResponsable) + " pcTypeContrat = " + pcTypeContrat + " Fournisseur = " + pcTypeFournisseur + " " + STRING(piNumeroFournisseur) + " TpDoc = " + STRING(viTypeDocument) ).
    find first ttModeleDocument
         where ttModeleDocument.tptrt = pcTypeTraitement
           and ttModeleDocument.notrt = piNumeroTraitement
           and ttModeleDocument.tpdoc = viTypeDocument no-error.
    if not available ttModeleDocument 
    then do:
        create ttModeleDocument.
        assign
            ttModeleDocument.tptrt = pcTypeTraitement
            ttModeleDocument.notrt = piNumeroTraitement
            ttModeleDocument.tpdoc = viTypeDocument
            ttModeleDocument.NoRes = piNumeroResponsable
            ttModeleDocument.tpcon = pcTypeContrat
            ttModeleDocument.tpfou = pcTypeFournisseur
            ttModeleDocument.nofou = piNumeroFournisseur
            ttModeleDocument.nocon = piNumeroContrat /* DM 0712/0239 */
            ttModeleDocument.nodos = piNumeroDossier /* DM 0712/0239 */
        . 
    end.
    /* Generation complement d'information sur les signalement si necessaire */
    if pcTypeTraitement = {&TYPEINTERVENTION-signalement}
    then for first inter no-lock
        where inter.nosig = piNumeroTraitement
          and inter.cdsta = {&STATUTINTERVENTION-complementInfo}:
        find first ttModeleDocument
             where ttModeleDocument.tptrt = pcTypeTraitement
               and ttModeleDocument.notrt = piNumeroTraitement
               and ttModeleDocument.tpdoc = 2 no-error.
        if not available ttModeleDocument 
        then do:
            create ttModeleDocument.
            assign 
                ttModeleDocument.tptrt = pcTypeTraitement
                ttModeleDocument.notrt = piNumeroTraitement
                ttModeleDocument.tpdoc = 2
                ttModeleDocument.NoRes = piNumeroResponsable
                ttModeleDocument.tpcon = pcTypeContrat
                ttModeleDocument.tpfou = pcTypeFournisseur
                ttModeleDocument.nofou = piNumeroFournisseur
                ttModeleDocument.nocon = piNumeroContrat /* DM 0712/0239 */
                ttModeleDocument.nodos = piNumeroDossier /* DM 0712/0239 */
            .
        end.
    end.
    /* Generation des refus de devis si necessaire */
    if pcTypeTraitement = {&TYPEINTERVENTION-ordre2service}
    then for each dtord no-lock
        where dtord.noord = piNumeroTraitement
      , first ordse no-lock
        where ordse.noord = dtord.noord
      , each trint no-lock
        where trint.noint = dtord.noint
          and trint.tptrt = {&TYPEINTERVENTION-reponseDevis}
          and trint.cdsta = {&STATUTINTERVENTION-refuse}:
        find first ttModeleDocument
            where ttModeleDocument.tptrt = {&TYPEINTERVENTION-demande2devis}
              and ttModeleDocument.notrt = trint.notrt
              and ttModeleDocument.tpdoc = 8 no-error.
        if not available ttModeleDocument 
        then do:
            create ttModeleDocument.
            assign 
                ttModeleDocument.tptrt = {&TYPEINTERVENTION-demande2devis}
                ttModeleDocument.notrt = trint.notrt
                ttModeleDocument.tpdoc = 8
                ttModeleDocument.NoRes = piNumeroResponsable
                ttModeleDocument.tpcon = pcTypeContrat
                ttModeleDocument.tpfou = "FOU"
                ttModeleDocument.nofou = ordse.nofou
                ttModeleDocument.nocon = piNumeroContrat /* DM 0712/0239 */
                ttModeleDocument.nodos = piNumeroDossier /* DM 0712/0239 */
            .
        end.
    end.
    /* Generation attestation TVA si necessaire */
    if pcTypeTraitement = {&TYPEINTERVENTION-ordre2service}
    then for first dtord no-lock
        where dtord.noord = piNumeroTraitement
          and lookup(string(dtord.cdtva), "1,7,10") > 0:     /* SY 1013/0167 TVA réduite 5,5% ou 7% ou 10% */    /*1*/ /* PL : 0512/0056 le 17/09/2012 */
        find first ttModeleDocument
            where ttModeleDocument.tptrt = pcTypeTraitement
              and ttModeleDocument.notrt = piNumeroTraitement
              and ttModeleDocument.tpdoc = 9 no-error.           /* Attestation TVA à taux réduit */
        if not available ttModeleDocument 
        then do:
            create ttModeleDocument.
            assign
                viTypeAttestationTVA   = 9
                ttModeleDocument.tptrt = pcTypeTraitement
                ttModeleDocument.notrt = piNumeroTraitement
                ttModeleDocument.tpdoc = viTypeAttestationTVA
                ttModeleDocument.NoRes = piNumeroResponsable
                ttModeleDocument.tpcon = pcTypeContrat
                ttModeleDocument.nocon = piNumeroContrat  /* DM 0712/0239 */
                ttModeleDocument.nodos = piNumeroDossier  /* DM 0712/0239 */
                ttModeleDocument.tpfou = pcTypeFournisseur
                ttModeleDocument.nofou = piNumeroFournisseur
            .
//          Mlog ( "CreTbDoc - Attestation TVA à taux réduit :  FIRST dtord.cdtva = " + string(dtord.cdtva)).
        end.
    end.

end procedure.

procedure affectationModele private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define buffer prmtv for prmtv.
    define buffer mddoc for mddoc.

    for each ttModeleDocument
      , first prmtv no-lock
        where prmtv.tppar = "MDDOC"
          and prmtv.noord = ttModeleDocument.tpdoc
          and prmtv.nbpar = integer(ttModeleDocument.tpcon):
        ttModeleDocument.fgdos = prmtv.fgdef.
        if ttModeleDocument.fgdos 
        then ttModeleDocument.nodot = integer(prmtv.lbpar).
        else for first mddoc no-lock            // todo   encore un whole-index 
            where mddoc.lbdot = prmtv.lbpar:
            ttModeleDocument.nodot = mddoc.nodot.
        end.
    end.
end procedure.

procedure generationCourrier private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define variable viNumeroImmeubleEnCours as integer   no-undo. /* NP 0416/0200 */
    define variable vcNomImmeubleEnCours    as character no-undo. /* NP 0416/0200 */
    define variable vcNomFournisseur        as character no-undo. /* NP 0416/0200 */
    define variable vlDejaGenere            as logical   no-undo.

    define buffer vbDesti for desti.
    define buffer desti   for desti.
    define buffer ifour   for ifour. /* NP 0416/0200 */
    define buffer intnt   for intnt.
    define buffer ssdos   for ssdos.
    define buffer lidoc   for lidoc.
    define buffer docum   for docum.
    define buffer imble   for imble.

    /* DEBUG 
       MLOG ( "GenCourrier : " + NmPrgUse ).
       {vidage.i ttModeleDocument}
    */
//    AssigneParametre("CODE-THEME", cCodeThemeEnCours).

    for each ttModeleDocument:
        /* NP 0416/0200 Recherche du numéro d'immeuble **/
        assign
            viNumeroImmeubleEnCours = 0
            vcNomImmeubleEnCours    = ""
            vcNomFournisseur        = ""
        .
        for first intnt no-lock
            where intnt.tpidt = {&TYPEBIEN-immeuble}
              and intnt.tpcon = ttModeleDocument.tpcon
              and intnt.nocon = ttModeleDocument.nocon:
            viNumeroImmeubleEnCours = intnt.noidt.
            for first imble no-lock
                where imble.noimm = intnt.noidt:
                vcNomImmeubleEnCours = nettoyageNom(imble.lbnom).
            end.
        end.
        /* NP 0416/0200 Recherche du nom du fournisseur **/
        if ttModeleDocument.nofou > 0
        then for first ifour no-lock
            where ifour.soc-cd = integer(mtoken:cRefPrincipale)
              and ifour.coll-cle = "F"
              // TODO  si le format de ifour.cpt-cd <> "99999", il vaut mieux faire plusieurs find/plusieurs formats "999", "9999", "999999", ...!!!!! 
              and ifour.cpt-cd = string(ttModeleDocument.nofou, "99999"):
            vcNomFournisseur = nettoyageNom(ifour.nom).
        end.
        /* Generation d'un modele de sous-dossier */
        if ttModeleDocument.fgdos then do:
            /* On recherche si le modèle a déjà été généré */
            vlDejaGenere = true.
            for each ssdos no-lock
                where ssdos.tpidt = ttModeleDocument.tptrt
                  and ssdos.noidt = ttModeleDocument.notrt
                  and ssdos.nomod = ttModeleDocument.nodot:
                vlDejaGenere = false.
                for each lidoc no-lock
                    where lidoc.tpidt = ssdos.tpidt
                      and lidoc.noidt = ssdos.noidt
                      and lidoc.nossd = ssdos.nossd
                  , first docum no-lock
                    where docum.nodoc = lidoc.nodoc
                  , each desti no-lock
                    where desti.nodoc = docum.nodoc:
                    /* Maj du destinataire car il peut avoir changé */
                    /*IF desti.tprol = "FOU" AND NoFouEnc <> desti.norol THEN DO:*/ /* modif SY le 17/10/2013 */
                    if  desti.tprol    = "FOU"
                    and ttModeleDocument.tpfou = "FOU"
                    and ttModeleDocument.nofou <> desti.norol
                    then for first vbDesti exclusive-lock
                        where vbDesti.nodoc = desti.nodoc
                          and vbDesti.tprol = desti.tprol
                          and vbDesti.norol = desti.norol:
                        assign
                            vbDesti.norol = ttModeleDocument.nofou /* NoFouEnc. */ /* modif SY le 17/10/2013 */
                            vbDesti.cdmsy = mtoken:cUser
                            vbDesti.dtmsy = today
                            vbDesti.hemsy = time
                        .
                    end.
                    find first ttDocument
                        where ttDocument.nodoc = docum.nodoc  no-error. /* NP 1207/0068 */
                    if not available ttDocument 
                    then do:
                        create ttDocument.
                        assign
                            ttDocument.nodoc = docum.nodoc
                            ttDocument.nodot = docum.nodot
                            ttDocument.tprol = desti.tprol
                            ttDocument.norol = desti.norol
                            ttDocument.lbdoc = docum.lbdoc
                            ttDocument.tpcon = ttModeleDocument.tpcon  /* DM 0712/0239 */
                            ttDocument.nocon = ttModeleDocument.nocon  /* DM 0712/0239 */
                            ttDocument.nodos = ttModeleDocument.nodos  /* DM 0712/0239 */
                            ttDocument.nofou = ttModeleDocument.nofou  /* NP 0416/0200 */
                            ttDocument.nmfou = vcNomFournisseur        /* NP 0416/0200 */
                            ttDocument.noimm = viNumeroImmeubleEnCours /* NP 0416/0200 */
                            ttDocument.nmimm = vcNomImmeubleEnCours    /* NP 0416/0200 */
                            ttDocument.notrt = ttModeleDocument.notrt  /* NP 0416/0200 */
                        .
                    end.
                end.
            end.
            /* Generation du sous-dossier */
            if vlDejaGenere then do:
                /* Ajout SY le 19/09/2013 - fiche 0913/0099 : Modifier le programme pour que dans les évènements la zone "Pour" soit alimentée par le responsable travaux sélectionné dans la saisie des interventions signalement devis et OS. */
    /*                
                if ttModeleDocument.NoRes <> 0 then AssigneParametre("EVENT-POURSPECIFIQUE",string(ttModeleDocument.NoRes)).        /* param pour gerevent.p : Surcharge du Pour */
                run creerEve.p ( ttModeleDocument.tptrt
                               , ttModeleDocument.notrt
                               , ttModeleDocument.nodot
                               , FALSE
                               , GlDevEdi
                               , piNumeroAction
                               , ''
                               , INPUT-OUTPUT LsDivPar).
                SupprimeParametre("EVENT-POURSPECIFIQUE").
    */
                /* Récupération des modèles générés */
                for last ssdos no-lock
                    where ssdos.tpidt = ttModeleDocument.tptrt
                      and ssdos.noidt = ttModeleDocument.notrt
                      and ssdos.nomod = ttModeleDocument.nodot
                  , each lidoc no-lock
                    where lidoc.tpidt = ssdos.tpidt
                      and lidoc.noidt = ssdos.noidt
                      and lidoc.nossd = ssdos.nossd
                  , first docum no-lock
                    where docum.nodoc = lidoc.nodoc
                  , each Desti no-lock
                    where desti.nodoc = docum.nodoc:
                    find first ttDocument
                        where ttDocument.nodoc = docum.nodoc no-error. /* NP 1207/0068 */
                    if not available ttDocument 
                    then do:
                        create ttDocument.
                        assign
                            ttDocument.nodoc = docum.nodoc
                            ttDocument.nodot = docum.nodot
                            ttDocument.tprol = desti.tprol
                            ttDocument.norol = desti.norol
                            ttDocument.lbdoc = docum.lbdoc
                            ttDocument.tpcon = ttModeleDocument.tpcon  /* DM 0712/0239 */
                            ttDocument.nocon = ttModeleDocument.nocon  /* DM 0712/0239 */
                            ttDocument.nodos = ttModeleDocument.nodos  /* DM 0712/0239 */
                            ttDocument.nofou = ttModeleDocument.nofou  /* NP 0416/0200 */
                            ttDocument.nmfou = vcNomFournisseur        /* NP 0416/0200 */
                            ttDocument.noimm = viNumeroImmeubleEnCours /* NP 0416/0200 */
                            ttDocument.nmimm = vcNomImmeubleEnCours    /* NP 0416/0200 */
                            ttDocument.notrt = ttModeleDocument.notrt  /* NP 0416/0200 */
                        .
                    end.
                end.
            end.
        end.
        /* Generation d'un courrier simple */
        else do:
            /* On recherche si le courrier a déjà été généré */
            vlDejaGenere = true.
            /*  PL : 20/09/2012 (0812/0143) 
               Il faut vérifier si on a au moins 1 destinataire car il se peut
                   que lors de la fusion précédente on n'ait pas eu de destinataire.
                   Dans ce cas on ne les recrée pas et on ne peut plus fusionner le document */
            for each lidoc no-lock
                where lidoc.tpidt = ttModeleDocument.tptrt
                  and lidoc.noidt = ttModeleDocument.notrt
              , first docum no-lock
                where docum.nodoc = lidoc.nodoc
                  and docum.nodot = ttModeleDocument.nodot
              , each desti no-lock
                where desti.nodoc = docum.nodoc:
                vlDejaGenere = false.
                /* Maj du destinataire car il peut avoir changé */
                /* IF desti.tprol = "FOU" AND NoFouEnc <> desti.norol THEN DO: */       /* modif SY le 17/10/2013 */
                if  desti.tprol    = "FOU" 
                and ttModeleDocument.tpfou = "FOU" 
                and ttModeleDocument.nofou <> desti.norol 
                then for first vbDesti exclusive-lock
                    where vbDesti.nodoc = desti.nodoc
                      and vbDesti.tprol = desti.tprol
                      and vbDesti.norol = desti.norol:
                    assign
                        vbDesti.norol = ttModeleDocument.nofou        /* NoFouEnc. */ /* modif SY le 17/10/2013 */
                        vbDesti.cdmsy = mtoken:cUser
                        vbDesti.dtmsy = today
                        vbDesti.hemsy = time
                    .
                end.
                find first ttDocument
                    where ttDocument.nodoc = docum.nodoc no-error.    /* NP 1207/0068 */
                if not available ttDocument 
                then do:
                    create ttDocument.
                    assign
                        ttDocument.nodoc = docum.nodoc
                        ttDocument.nodot = docum.nodot
                        ttDocument.tprol = desti.tprol
                        ttDocument.norol = desti.norol
                        ttDocument.lbdoc = docum.lbdoc
                        ttDocument.tpcon = ttModeleDocument.tpcon       /* DM 0712/0239 */
                        ttDocument.nocon = ttModeleDocument.nocon       /* DM 0712/0239 */
                        ttDocument.nodos = ttModeleDocument.nodos       /* DM 0712/0239 */
                        ttDocument.nofou = ttModeleDocument.nofou       /* NP 0416/0200 */
                        ttDocument.nmfou = vcNomFournisseur             /* NP 0416/0200 */
                        ttDocument.noimm = viNumeroImmeubleEnCours      /* NP 0416/0200 */
                        ttDocument.nmimm = vcNomImmeubleEnCours         /* NP 0416/0200 */
                        ttDocument.notrt = ttModeleDocument.notrt       /* NP 0416/0200 */
                    .
                end.
            end.
            /* Generation du courrier */
            if vlDejaGenere then do:
                /*
                run credocum.p ( ttModeleDocument.tptrt
                               , ttModeleDocument.notrt
                               , ttModeleDocument.nodot
                               , ttModeleDocument.NoRes
                               , 0
                               , ''
                               , GlDevEdi).*/
                /* Récuperation du numero de document */
getLastDocument:
                for each docum no-lock
                    where docum.nodot = ttModeleDocument.nodot
                    by docum.nodoc descending:
boucleDesti:
                    for each desti no-lock
                        where desti.nodoc = docum.nodoc:
                        if can-find(first ttDocument where ttDocument.nodoc = desti.nodoc) then next boucleDesti.
                        create ttDocument.
                        assign
                            ttDocument.nodoc = docum.nodoc
                            ttDocument.nodot = docum.nodot
                            ttDocument.tprol = desti.tprol
                            ttDocument.norol = desti.norol
                            ttDocument.lbdoc = docum.lbdoc
                            ttDocument.tpcon = ttModeleDocument.tpcon  /* DM 0712/0239 */
                            ttDocument.nocon = ttModeleDocument.nocon  /* DM 0712/0239 */
                            ttDocument.nodos = ttModeleDocument.nodos  /* DM 0712/0239 */
                            ttDocument.FgNew = true                    /* DM 0712/0239 */
                            ttDocument.nofou = ttModeleDocument.nofou  /* NP 0416/0200 */
                            ttDocument.nmfou = vcNomFournisseur        /* NP 0416/0200 */
                            ttDocument.noimm = viNumeroImmeubleEnCours /* NP 0416/0200 */
                            ttDocument.nmimm = vcNomImmeubleEnCours    /* NP 0416/0200 */
                            ttDocument.notrt = ttModeleDocument.notrt  /* NP 0416/0200 */
                        .
                    end.
                    leave getLastDocument.
                end.
            end.
        end.
    end.
//    SupprimeParametre("CODE-THEME").
end procedure.


procedure fusionMailing private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
/*  define variable vcNomDocument  as character no-undo. */
    define variable RpTmpOut       as character no-undo.
    define variable vlEnvoyer      as logical   no-undo.
    define variable vcIdentifiant  as character no-undo.
    define variable vcNomTable     as character no-undo.
    define variable vcCollCle      as character no-undo.
    define variable vcNomOrganisme as character no-undo.
    define variable vcChaine       as character no-undo.
    define variable vcChaineLre    as character no-undo. /* DM 0616/0084 */
    define variable vcChaineFax    as character no-undo.
    define variable vcChaineMail   as character no-undo.
    define buffer ifour   for ifour.
    define buffer orsoc   for orsoc.
    define buffer tiers   for tiers.
    define buffer vbRoles for roles.
    define buffer desti   for desti.
    define buffer mddoc   for mddoc.
    
    /*--FUSION INDIVIDUEL------------------------------------------------------------------------------------------------------*/
    /* Fichier de donnees pour mailing */
    assign 
        rpTmpOut = os-getenv("Tmp") + "~\"    // TODO A SUPPRIMER, pas utilisée !?
        vlEnvoyer = false
    .
    for each ttDocument
        break by ttDocument.nodot:
        if first-of(ttDocument.nodot) then do:
            find first mddoc no-lock 
                 where mddoc.nodot = ttDocument.nodot no-error.
            find first desti no-lock
                 where desti.nodoc = ttDocument.nodoc no-error.
            find first vbRoles no-lock
                 where vbRoles.tprol = ttDocument.tprol
                   and vbRoles.norol = ttDocument.norol no-error.
            if available vbRoles then do:
                find first tiers no-lock
                     where tiers.notie = vbRoles.notie no-error.
                if available tiers and lookup(tiers.tpmod, "00002,00003,00004" /* DM 0616/0084 Ajout 00004 LRE */) <> 0 
                then assign
                    vlEnvoyer        = true
                    ttDocument.tpmod = tiers.tpmod
                    // todo   on fait quoi de vcChaine
                    vcChaine         = substitute("&1|&2", vcChaine, mddoc.lbdot) when available mddoc
                .
            end.
            else do:
                run decodOrg(
                    ttDocument.tprol,
                    string(ttDocument.norol, "99999"),
                    output vcIdentifiant,
                    output vcNomTable,
                    output vcCollCle,
                    output vcNomOrganisme
                ).
                if vcNomTable = "orsoc"
                then for first orsoc no-lock
                     where orsoc.tporg = ttDocument.tprol
                       and orsoc.ident = vcIdentifiant:
                     // todo   manque un bout !?
                end.
                else for first ifour no-lock
                     where ifour.soc-cd   = integer(mtoken:cRefPrincipale)
                       and ifour.coll-cle = vcCollCle
                       // TODO  si le format de ifour.cpt-cd <> "99999", il vaut mieux faire plusieurs find/plusieurs formats "999", "9999", "999999", ...!!!!! 
                       and ifour.cpt-cd   = string(ttDocument.norol, "99999")
                       and lookup(ifour.tpmod, "Fax,Email,LRE") <> 0:               /* DM 0616/0084 "Fax,Email" */
                    assign 
                        vlEnvoyer = true
                        // todo   on fait quoi de vcChaine
                        vcChaine  = substitute("&1|&2", vcChaine, mddoc.lbdot) when available mddoc
                    .
                    case ifour.tpmod:
                        when "Fax"   then ttDocument.tpmod = "00002".
                        when "Email" then ttDocument.tpmod = "00003".
                        when "LRE"   then ttDocument.tpmod = "00004". /* DM 0616/0084 */
                    end case.
                end.
            end.
        end.
    end.
    vcChaine = trim(vcChaine, "|").
    if vlEnvoyer then do:
        for each ttDocument
            where ttDocument.tpmod = "00002" :
            vcChaineFax = vcChaineFax + "," + string(ttDocument.nodoc).
        end.
        vcChaineFax = trim(vcChaineFax, ",").
        // todo  attention, fax.p n'est pas repris!
        if vcChaineFax > "" then run fax.p(vcChaineFax).

        for each ttDocument
            where ttDocument.tpmod = "00003":
            vcChaineMail = vcChaineMail + "," + string(ttDocument.nodoc).
        end.
        for each ttDocument 
            where ttDocument.tpmod = "00004":
            vcChaineLre = vcChaineLre + "," + string(ttDocument.nodoc).
        end.
        assign
            vcChaineMail = trim(vcChaineMail, ",")
            vcChaineLre  = trim(vcChaineLre, ",")
        .
        if vcChaineMail > "" or vcChaineLre > ""
        // todo  attention, email.p n'est pas repris!
        then run email.p(vcChaineMail + '¤' + vcChaineLre).
    end.
/*
    define variable LbDetUse       as character no-undo.
    define variable cFileName      as character no-undo.
    define variable cLstErreursGed as character no-undo. /* DM 0712/0239 */
    define variable hGidemat       as handle    no-undo. /* DM 0712/0239 */
    /* DM 0712/0239 */
    if f_GedActive()
    and f_GedDroit("cre",NmUsrUse) /* DM 0712/0239 09/07/2014 */
    then do :
        AssigneParametre("GED-QUESTION", "O").
        supprimeParametre("GED-reponse").
        cLstErreursGed = "".
        SupprimeParametre("GED_LISTEDESERREURS").

        for each ttDocument no-lock:
            find docum no-lock where Docum.nodoc = ttDocument.nodoc no-error.
            if not available docum then next.
            cFileName = RpWrdEve + 'docum~\' + ttDocument.lbdoc.
            if search(replace(cFileName,".doc",".pdf")) <> ?
            then cFileName = replace(cFileName,".doc",".pdf").
            if search(cFileName) = ? then next.
            if ttDocument.FgNew = false 
            and f_GedFicExiste(cFileName) 
            then next. /* Ancien document et fichier deja archivé dans la ged */
            LbDetUse = docum.lbobj.
            run ged( ttDocument.nodot
                   , cFileName
                   , ttDocument.tprol
                   , ttDocument.norol
                   , ttDocument.tpcon
                   , ttDocument.nocon
                   , ttDocument.tpmod /* 00002 = Fax, 00003 = Mail, 00004 = LRE */
                   , ttDocument.nodos
                   , docum.lbobj
                   , docum.tbdat[1]).
            cLstErreursGed = cLstErreursGed + (if cLstErreursGed <> "" then "¤" else "") + DonneEtSupprimeParametre("GED_LISTEDESERREURS").
        end.
        SupprimeParametre("GED-QUESTION").
        SupprimeParametre("GED-reponse").
        if cLstErreursGed <> "" 
        then do : /* Edition fop des anomalies */
            run value (RpRunExe + "gidemat.p") persistent set hGidemat.
            run edition_err in hGidemat(cLstErreursGed).
            delete procedure hGiDemat.
        end.
    end. /* ged activee */
    */
    /* FIN DM */

end procedure.

procedure majMail:
    /*------------------------------------------------------------------------------
      Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define variable vcChaine as character no-undo.

    input stream LbCheDon from value(os-getenv("Tmp") + "/donnees.doc").
    do while true:
        import stream LbCheDon unformatted vcChaine.
        put stream LbCheMai unformatted vcChaine skip.
    end.
    input stream LbCheDon close.
end procedure.

procedure majBaseMail:
    /*------------------------------------------------------------------------------
      Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define variable vcChaine as character no-undo.

    input stream LbCheBas from value(os-getenv("Tmp") + "/base.txt").
    do while true:
        import stream LbCheBas unformatted vcChaine.
        put stream LbCheBma unformatted vcChaine skip.
    end.
    input stream LbCheBas close.
end procedure.

procedure ged:
    /*------------------------------------------------------------------------------
      Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter piNumeroModele    as integer   no-undo.
    define input  parameter pcNomFichier      as character no-undo.
    define input  parameter pcTypeRole        as character no-undo.
    define input  parameter piNumeroRole      as int64     no-undo.
    define input  parameter pcTypeContrat     as character no-undo.
    define input  parameter piNumeroContrat   as integer   no-undo.
    define input  parameter pcModeEnvoi       as character no-undo.
    define input  parameter piNumeroDossier   as integer   no-undo.
    define input  parameter pcObjetDuDocument as character no-undo.
    define input  parameter pdaDate1          as date      no-undo.
    define output parameter pcRetour          as character no-undo.

    define variable vcLstChamps as character no-undo.
    define buffer mddoc for mddoc.

    for first mddoc no-lock
        where mddoc.nodot = piNumeroModele
          and mddoc.typdoc-cd <> 0:
        vcLstChamps = substitute("BUREAUTIQUE¤&1¤&2¤&3¤&4¤&5¤&6¤&7¤&8¤&9",
                     pcTypeRole,
                     piNumeroRole,
                     pcTypeContrat,
                     piNumeroContrat,
                     mddoc.typdoc-cd,
                     pcModeEnvoi,
                     pcNomFichier,
                     piNumeroDossier,
                     string(pdaDate1, "99/99/9999") + "¤" + pcObjetDuDocument).
// TODO  Attention, ged.p n'est pas repris.
        run ged.p(vcLstChamps, output pcRetour).
    end.
end procedure.
