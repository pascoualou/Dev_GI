/*-----------------------------------------------------------------------------
File        : entrpadp.p
Purpose     : Exportation Mandat avec paie Pégase vers Pégase
Author(s)   : JPM 0114/0244 Interface Pégase - GGA - 2017/11/16
Notes       : a partir de adb/paie/entrpadp.p
derniere revue: 2018/04/10 - phm - KO
              - A VOIR: on trouve beaucoup de
                    if glTrace then put stream stTrace unformatted "    xxx: ". export stream stTrace xxx.
                faut-il remplacer par:
                    if glTrace then do:
                        put stream stTrace unformatted "    xxx: ".
                        export stream stTrace xxx.
                    end.
              - traiter les todo
              - remplacement os-getenv() par parametrageRepertoireMagi.cls
              - procedure entrpadpLanceExport:
                - pourquoi définir un format ?
                  define input parameter piNoRefTrans as integer no-undo format "99999".
                - Remplacer les valeurs en dur. ( A FAIRE !)
                  vcRepertoireTransfert = /*gga todo mToken:getValeur('REPGI')*/ "d:/gidev" + "/trans/"


01  19/09/2013  JPM    Initialisation programme
02  27/01/2014  SY     export mandat sur 5 chiffres, Export à partir des Nlles zones etabl.lbdiv4
03  30/01/2014  SY     Suppression variables inutilisées
04  31/01/2014  SY     MAJ date 1er export etablissement
05  26/02/2014  SY     Pb séparation copro/gérance sur 2 ref chez dauchez en newergo. On n'a plus accès à la copro.                                  |
06  26/02/2014  SY     Stockage information codSociete dans etabl
07  03/03/2014  SY     Reformatage Raison sociale avec civilité + Ajout information codSociete dans etabl et ctanx 01047 (employeur)                      |
08  13/03/2014  JPM    Formatage nom fichier sortie
09  27/03/2014  SY     Suppression champs adresse urssaf... inutiles
10  31/03/2014  SY     Adaptation pour mettre le fichier dans les répertoires de transfert et créer le suivi
11  02/04/2014  SY     Correction erreur codage codSociete pour nouveau mandat sur entreprise multi-mandats
12  03/07/2014  JPM    Ajout découpage iban idem chargadp.p
13  23/09/2014  SY     0914/0176 ajout message d'erreur si le SIRET de l'entreprise n'a pas été saisi
14  10/10/2014  JPM    Chargement de la société ZZZZZ correspondant au cabinet
15  28/10/2014  JPM    Suppression des champs convention collective et sectionAT1 absents de la version 5. entraîne une modification de la matrice d'import
16  27/11/2014  JPM    Filtrer "," dans le champ codetiers
17  02/03/2015  JPM    Ne plus envoyer la société ZZZZZ
18  31/03/2015  SY     0315/0241 correction saisie 16 est en dehors de la liste 019454 /4/FR7613390000660674101. Pb recup InfosBanque
19  31/03/2015  SY     0315/0241 correction saisie 16 est en dehors
20  11/09/2015  SY     suite réunion Pégase et demande de Dina ajout possibilité de générer le fichier pour 1 seul mandat (prmmtpeg.p)
21  04/11/2015  SY     1115/0029 Pb double cote " dans nom syndicat Syndicat "DEBUSSY"
22  09/12/2015  SY     1115/0254 transfert automatisé nouveaux includes majsuivi.i, prc_sftp.i
23  01/02/2017  JPM    Taux AT 2017 à 2.90 au lieu de 3.10
-----------------------------------------------------------------------------*/
{preprocesseur/nature2voie.i}
{preprocesseur/type2adresse.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2role.i}
using parametre.pclie.parametrageRepertoireMagi.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{application/include/glbsepar.i}

define stream stTrace.
define stream st2.

define variable glTrace as logical no-undo.

define temp-table w_file no-undo
    field putfile   as character
    field getfile   as character
    field transfert as character
    field reception as logical
.
define temp-table TbLstEtab no-undo
    field tpcon      as character 
    field nocon      as integer
    field siren      as integer
    field nonic      as integer
    field NumVoi     as character
    field BisTer     as character
    field NomVoi     as character
    field cpvoi      as character
    field cpad2      as character
    field cdpos      as character
    field lbvil      as character
    field cdins      as character
    field cdIs2Use   as character
    field cdape      as character
    field cdurs      as character  /* URSSAF */
    field cdurs-adp  as character
    field nours      as character
    field noass      as character  /* ASSEDIC */
    field nocre      as character  /* Retraite */
    field lbdiv4     as character
    field lbdiv5     as character
    field codSociete as character  /* code société envoyé à Pégase lors de la création */
    index Ix_TbLstEtab is unique nocon
.
define temp-table TbLstEnt  no-undo
    field NoTie         as integer          // Numero de Tiers
    field nosir         as integer
    field nonic         as integer
    field cdape         as character
    field RaisonSociale as character        // nom mandant ou syndicat formaté avec civilité
    field codSociete    as character        // code société envoyé à Pégase lors de la création
    field cpvoi         as character
    field cpad2         as character
    field novoi         as character
    field cdbis         as character
    field natvoi        as character
    field nmvoi         as character
    field cdins         as character
    field prsig         as character
    field lbvil         as character
    field cdpos         as character
    field lbbur         as character
    field treso         as character        // trésorerie
    field nlent         as character        // Entreprise crée depuis 1997
    field cdtva         as character        // Assujettissement TVA
    field cdHon         as character        // Versement des honoraires
    field nbtie         as integer          // Nombre de tiers
    field tpsup         as character
    field nmsig         as character        // Nom du signataire
    field cdfng         as character        // Assujettissement FNGS
    field cdeff         as character        // Classe d'effectif
    field tpfin         as character        // code d,clarant
    field tpbqu         as character        // code adresse CRIP
    field recet         as character        // centre de recette
    field taxsa         as decimal          // Mnt taxe/salaire annee precedente
    field norol         as integer          // no propriétaire ou syndicat
    field CdIs2         as character        // Code iso2 pays de l'adresse
    field CdIs3         as character        // Code iso3 pays de l'adresse
    field CdIs4         as character        // Code iso4 pays de nationalité
    field JournalBQ     as character        // code journal de banque
    field Emetteur      as character        // code émetteur
    field domiciliation as character        // domiciliation bancaire
    field cdbanque      as character        // code banque
    field cdgui         as character        // code guichet
    field nocompte      as character        // numero de compte
    field clerib        as character        // cle rib
    field iban          as character        // iban
    field bic           as character        // bic
    field firstmdt      as character        // premier mandat de l'entreprise
    index Ix_TbLstEnt is unique nosir
.
{comm/include/prcsuivt.i}       /* Procedure Prc-Cre-Suivtrf: */
{comm/include/prc_sftp.i}       /* gestion envoi par SFTP */
{comm/include/prclbdiv.i}       /* PROCEDURE MajParamLbdiv: , function getValeurParametrePROCEDURE LecParamLbdiv:*/

function formatBisTer returns character private(pcCodeAdresse as character):
    /*------------------------------------------------------------------------------
    purpose: Décodage de la nature de la voie (Rue, ...)
    Note   :
    ------------------------------------------------------------------------------*/
    case pcCodeAdresse:
        when "00001" then return "B".
        when "00002" then return "T".
        when "00003" then return "Q".
    end case.
    return " ".
end function.
function formatLibVoi returns character private(pcNatureVoie as character, pcLibelleVoie as character):
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define variable vcNatureVoie  as character no-undo.

    if pcNatureVoie <> {&NATUREVOIE--}
    then vcNatureVoie = outilTraduction:getLibelleParam("NTVOI", pcNatureVoie).
    return trim(vcNatureVoie + " " + trim(pcLibelleVoie)).
end function.

function envoiFichiers returns logical private(
    picodeSoc as integer, pcRepertoireTransfert as character, pcRepertoireCGI as character, pcRepertoireTMP as character, pcListeEnvoi as character, piNombreDemande as integer):
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    todo : traduction messages
    ------------------------------------------------------------------------------*/
    define variable vcRepCopSvg      as character no-undo.
    define variable viNoErreur       as integer   no-undo.
    define variable vcMessageErreur  as character no-undo.
    define variable viNbFic          as integer   no-undo.
    define variable voRepertoireMagi as class parametrageRepertoireMagi no-undo.

    assign
        voRepertoireMagi = new parametrageRepertoireMagi()
        vcRepCopSvg      = replace(pcRepertoireTMP, voRepertoireMagi:getRepertoireDisque(), voRepertoireMagi:getRepertoireReseau())
        viNbFic          = num-entries(pcListeEnvoi)
    .
    run sftp-envoi(
        piCodeSoc,
        pcListeEnvoi,
        pcListeEnvoi,          // ListeNomTelecom: nom fichiers identiques pour paie Pegase
        false,                 // Mode debug
        false,                 // Mode copie
        vcRepCopSvg,           // répertoire de sauvegarde si on veut garder une copie
        pcRepertoireTransfert,
        pcRepertoireCGI,
        pcRepertoireTMP,
        output viNoErreur,
        output vcMessageErreur
    ).
    if viNoErreur > 0
    then mError:createError({&error},
        substitute("Echec de l'envoi &1 fichier&2 de transfert&2 généré&2: &3%sVeuillez vérifier la connectivité à Internet.",
                   trim(if piNombreDemande > 1 then "des " + string(piNombreDemande) else "du"),
                   trim(string(piNombreDemande = 1, "/s")),
                   vcMessageErreur)).
    else mError:createError({&information},    // todo  traduction
        if viNbFic > 1 then string(viNbFic) + " fichiers ont été envoyés à la GI" else "Le fichier a été envoyé à la GI").
    return viNoErreur = 0.
end function.

procedure entrpadpLanceExport:
    /*------------------------------------------------------------------------------
    purpose:
    Note   : service externe (tachePaiePegase.p)
    todo  remplacer les valeur en dur!
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeExtraction   as character no-undo.
    define input  parameter pcTypeMandatExport as character no-undo.
    define input  parameter piMandatExport     as int64     no-undo.
    define input  parameter piNoRefTrans       as integer   no-undo.
    define output parameter piNbEtabGen        as integer   no-undo.
    define output parameter plEnvoi-OK         as logical   no-undo.

    define variable vcMessageErreur       as character no-undo.
    define variable vcRepertoireCGI       as character no-undo.
    define variable vcRepertoireTMP       as character no-undo.
    define variable vcRepertoireTransfert as character no-undo.
    define variable vcTypeMandatExport    as character no-undo.
    define variable vcReferenceExport     as character no-undo.            /* Ajout SY le 03/03/2014 */
    define variable vcNomFichierTexte     as character no-undo.
    define variable vcRepertoireSVGpegase as character no-undo.
    define variable vcRepertoire7ZIP      as character no-undo.
    define variable vcListeEnvoi          as character no-undo.
    define variable viNombreDemande       as integer   no-undo.
    define variable vicodeSoc             as integer   no-undo.

    if pcTypeMandatExport > "" and piMandatExport <> 0
    then assign
        vcTypeMandatExport = pcTypeMandatExport
        vcReferenceExport  = (if pcTypeMandatExport = {&TYPECONTRAT-mandat2Syndic} then mtoken:cRefCopro else mtoken:cRefGerance)
    .
    else do:
        vcReferenceExport = mtoken:cRefPrincipale.
        if mtoken:cRefGerance <> mtoken:cRefCopro
        then vcTypeMandatExport = (if vcReferenceExport = mtoken:cRefGerance then {&TYPECONTRAT-mandat2Gerance} else {&TYPECONTRAT-mandat2Syndic}).
    end.
    assign
        glTrace               = true
        vcRepertoireTransfert = /*gga todo mToken:getValeur('REPGI')*/ "d:/gidev" + "/trans/"
        vcRepertoireTMP       = vcRepertoireTransfert + "tmp/"
        vcRepertoireCGI       = vcRepertoireTransfert + "cgi/"
        vcRepertoireSVGpegase = replace(vcRepertoireCGI, "cgi", "svg") + "gipegase/"
        vcRepertoire7ZIP      = /*gga todo mToken:getValeur('REPGI')*/ "d:/gidev" + "/exe/7-zip/"
        file-info:file-name   = vcRepertoireSVGpegase
        vicodeSoc             = (if vcTypeMandatExport = {&TYPECONTRAT-mandat2Gerance} 
                                 then integer(mtoken:cRefGerance)
                                 else integer(mtoken:cRefCopro))
    .
    if file-info:file-type = ? then os-create-dir value(vcRepertoireSVGpegase).
    if piNoRefTrans = 0 then piNoRefTrans = integer(mtoken:cRefPrincipale).

    /* PARAMETRE CLIENT PAIE PEGASE */

message "aaaa00000000000" substitute("&1TraceEntrAdp&2-&3.txt", session:temp-directory, string(vcReferenceExport, "99999"), pcTypeExtraction).

    output stream stTrace to value(substitute("&1TraceEntrAdp&2-&3.txt", session:temp-directory, string(vcReferenceExport, "99999"), pcTypeExtraction)).

    put stream stTrace unformatted
        "Date : " today " " string(time, "hh:mm:ss") fill(" ", 10) "REF : " vcReferenceExport skip.
    run creSuiExport("PEGAZ", "CGENT" + vcReferenceExport, "").    /* modif SY le 26/02/2014 : Ajout ref pour séparation copro/gérance DAUCHEZ */
    run chargeEtabEntreprises(piMandatExport, vcTypeMandatExport, vcReferenceExport).
    vcNomFichierTexte = substitute("PZ_&1_ExportENTR_&2&3&4_&5.txt", vcReferenceExport, year(today), string(month(today), "99"), string(day(today), "99"), time).
    run generationFichier(vcRepertoireTMP, vcNomFichierTexte, vcReferenceExport, output piNbEtabGen).
    /* copie dans le répertoire developpeur E:/ADP s'il existe... */
    file-info:file-name = "e:/adp/".    /* todo: remplacer les valeurs en dur !   */
    if file-info:file-type begins "D"
    then do:
        /* créer répertoires gipegase si absent */
        file-info:file-name = "e:/adp/gipegase/".    /* todo: remplacer les valeurs en dur !   */
        if file-info:file-type = ? then os-create-dir value("e:/adp/gipegase/").    /* todo: remplacer les valeurs en dur !   */
        os-copy value(vcRepertoireTMP + vcNomFichierTexte) value("e:/adp/gipegase/" + vcNomFichierTexte).    /* todo: remplacer les valeurs en dur !   */
    end.
    if piNbEtabGen > 0
    then run demtraitPegase("PE_ETABS", vcRepertoireTMP, vcNomFichierTexte, piNbEtabGen, piNoRefTrans, vcRepertoireCGI, vcRepertoireSVGpegase, vcRepertoire7ZIP, output vcListeEnvoi, output viNombreDemande).

    output stream stTrace close.

message "aaaaaaaaaaaaa " viNombreDemande.

    if viNombreDemande > 0 then do:
        /* 1115/0254 Recherche si le transfert SFTP est paramétré et installé sur le poste */
        if sftp-Verif-install(vcRepertoireTransfert, output vcMessageErreur)
        /* 1115/0254 Recherche si si les demandes de traitement de demande d'info à Pégase sont paramatrées en transfert automatique */
        and can-find(first demtrait no-lock
                     where demtrait.cdtrait = "PE_ETABS"
                       and demtrait.support = "T"
                       and num-entries(demtrait.cdtypdis, separ[5]) >= 2
                       and entry(2, demtrait.cdtypdis, separ[5]) = "SFTP_AUTO")
        then 
/* todo  A confirmer cette non utilisation de lconfirm_envoi  !!!!!!!!!!
define variable lconfirm_envoi as logical   no-undo.
do:         lconfirm_envoi = TRUE.
            IF PROGRAM-NAME(1) MATCHES "*gidev*" THEN DO:
     //           RUN GestMess IN HdLibPrc(4,"",0,"Voulez-vous effectuer le transfert automatique du fichier ?%s(appli gidev)" ,"","QUESTION",OUTPUT lconfirm_envoi).
            end.
            if lconfirm_envoi then */
            plEnvoi-OK = envoiFichiers(vicodeSoc, vcRepertoireTransfert, vcRepertoireCGI, vcRepertoireTMP, vcListeEnvoi, viNombreDemande).      /* transfert automatique par SFTP */
//        end.
        else mError:createError({&information},        /* todo: traduction   */
            substitute("le&1 fichier&2 de transfert &3 été généré&2. Vous devez maintenant envoyer ce&2 fichier&2 à la GI (transferts/envoi de fichiers sur le PC1)",
                       if viNombreDemande > 1 then "s " + string(viNombreDemande) else "",
                       trim(string(viNombreDemande = 1, "/s")),
                       trim(string(viNombreDemande = 1, "a/ont")))).
    end.
end procedure.

procedure chargeEtabEntreprises private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter piMandatExport    as int64     no-undo.
    define input parameter pcTypeMandat      as character no-undo.
    define input parameter pcReferenceExport as character no-undo.

    define variable vcCodeTiers         as character no-undo.
    define variable vcCodeSocietePegase as character no-undo.
    define variable vcPremierMandat     as character no-undo.

    define buffer vbRoles         for roles.
    define buffer vbIntnt         for intnt.
    define buffer vbCtrat         for ctrat.
    define buffer vbImmeubleIntnt for intnt.
    define buffer etabl           for etabl.

message "chargeEtabEntreprises " piMandatExport pcTypeMandat pcReferenceExport.

    /* Etablissement avec la paie pégase */
    /* A FAIRE , nouveaux champs à analyser (flag paie pégase, date de début, date de fin ...) */
    /* TODO  ATTENTION : QUID gestion DAUCHEZ ref 03073 GER / 03080 COPR ??? */
    for each etabl no-lock                // todo  attention, whole-index !!!!!
        where etabl.lbdiv4 begins "PEGASE=OUI"
          and etabl.tpcon = (if pcTypeMandat > ""   then pcTypeMandat   else etabl.tpcon)     /* séparation Copro/Gérance DAUCHEZ */
          and etabl.nocon = (if piMandatExport <> 0 then piMandatExport else etabl.nocon)     /* Ajout SY le 11/09/2015 */
      , first vbCtrat no-lock
        where vbCtrat.tpcon = etabl.tpcon
          and vbCtrat.nocon = etabl.nocon
      , first vbImmeubleIntnt no-lock
        where vbImmeubleIntnt.tpcon = etabl.tpcon
          and vbImmeubleIntnt.nocon = etabl.nocon
          and vbImmeubleIntnt.tpidt = {&TYPEBIEN-immeuble} /* Immeuble */
      , first vbIntnt no-lock
        where vbIntnt.tpcon = etabl.tpcon
          and vbIntnt.nocon = etabl.nocon                                                    /* No mandat gerance ou no mandat syndic */
          and vbIntnt.tpidt = (if etabl.tpcon = {&TYPECONTRAT-mandat2Syndic} then {&TYPEROLE-syndicat2copro} else {&TYPEROLE-mandant})
      , first vbRoles no-lock
        where vbRoles.tprol = vbIntnt.tpidt
          and vbRoles.norol = vbIntnt.noidt
        break by etabl.tpcon by etabl.nocon:

message "chargeEtabEntreprises 02 " piMandatExport pcTypeMandat pcReferenceExport. 

        if first-of(etabl.nocon) then do:
            assign
                vcPremierMandat     = string(etabl.nocon , "99999")                                /* 1er No mandat */
                vcCodeTiers         = outilFormatage:getNomTiers(vbRoles.tprol, vbRoles.norol)     /* Modif SY le 29/01/2014 */
                vcCodeTiers         = replace(vcCodeTiers, "~"", "")                               /* SY 1115/0029 */
                vcCodeTiers         = replace(vcCodeTiers, "é", "e")
                vcCodeTiers         = replace(vcCodeTiers, "-", "")
                vcCodeTiers         = replace(vcCodeTiers, " ", "")
                vcCodeTiers         = replace(vcCodeTiers, "'", "")
                vcCodeTiers         = replace(vcCodeTiers, "(", "")
                vcCodeTiers         = replace(vcCodeTiers, ")", "")
                vcCodeTiers         = replace(vcCodeTiers, ".", "")
                vcCodeTiers         = replace(vcCodeTiers, "/", "")
                vcCodeTiers         = replace(vcCodeTiers, ",", "")
                vcCodeTiers         = trim(vcCodeTiers)
                vcCodeTiers         = caps(vcCodeTiers)
                vcCodeSocietePegase = substitute ('&1&2&3', string(pcReferenceExport, "99999"), vcPremierMandat, vcCodeTiers) /* Codage de la société pour Pégase */
                vcCodeSocietePegase = trim(string(vcCodeSocietePegase, "X(20)"))                                              /* limité à 20 caractères */
            .
            /* Traitement entreprise */
            run TrtEntreprise(buffer etabl, vbRoles.tprol, vbRoles.norol, vbRoles.notie, vbCtrat.lbnom, pcReferenceExport, vcCodeSocietePegase, vcPremierMandat).
        end.
        /* Enregistrement Etablissement */
        run MajLstEtab(pcReferenceExport, vcCodeSocietePegase, vbImmeubleIntnt.noidt, buffer etabl).
    end.
end procedure.

procedure generationFichier private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input  parameter pcRepertoireTMP   as character no-undo.
    define input  parameter pcNomFichier      as character no-undo.
    define input  parameter pcReferenceExport as character no-undo.
    define output parameter piNbEtabGen       as integer   no-undo.

    define variable viPos  as integer   no-undo.
    define variable vcItem as character no-undo.

    define buffer ctanx for ctanx.
    define buffer etabl for etabl.

    output stream st2 to value(pcRepertoireTMP + pcNomFichier) /*CONVERT TARGET CdPagDos*/.

    put stream stTrace unformatted ">> generationFichier: " pcRepertoireTMP + pcNomFichier skip.
    for each TbLstEtab:
        if glTrace then put stream stTrace unformatted "Article établissement lu: ".
        export stream stTrace tbLstEtab.
        /* Entreprise correspondante */
        find first TbLstEnt where TbLstEnt.nosir = TbLstEtab.siren no-error.
        if not available TbLstEnt
        then do:    /* todo  traduction */
            put stream stTrace unformatted "*** ERREUR *** TBLSTENT INCONNU POUR ETAB: " TbLstEtab.nocon " SIREN " TbLstEtab.siren skip.

message "Erreur: Impossible de trouver l'entreprise associée au mandat " tbLstEtab.nocon " avec le SIREN " tbLstEtab.siren.

        end.
        else do:
            if glTrace then put stream stTrace unformatted "Article entreprise lu: ".
            export stream stTrace tbLstEnt.
            put stream st2 unformatted
                TbLstEtab.codSociete      chr(9)                                         /* Code société STRING(NorefExport,"99999") + TbLstEnt.firstmdt + cNomSoc */
                TbLstEnt.RaisonSociale    chr(9)                                         /* Raison ociale */
                string(TbLstEnt.nosir, "999999999")    chr(9)                            /* Numero siren */
                TbLstEnt.nmsig   chr(9)                                                  /* Nom responsable */
                TbLstEnt.nmsig   chr(9)                                                  /* Nom responsable TDS */
                trim(substitute("&1 &2 &3", TbLstEnt.novoi, TbLstEnt.cdbis, TbLstEnt.nmvoi)) chr(9)/* Adresse entreprise */
                TbLstEnt.cpvoi   chr(9)                                                  /* Adresse 2 */
                TbLstEnt.cpad2   chr(9)                                                  /* Adresse 3 */
                TbLstEnt.cdpos   chr(9)                                                  /* Code postal */
                TbLstEnt.lbvil   chr(9)                                                  /* Ville */
                TbLstEnt.cdins   chr(9)                                                  /* Insee commune */
                TbLstEnt.cdape   chr(9)                                                  /* code naf/ape */
                "Employés d'immeubles"  chr(9)                                           /* Activité */
                /* + "1043" + chr(9)                                                        code convention collective  n'existe plus en version 5*/
                TbLstEnt.JournalBq      chr(9)                                           /* nom banque  */
                TbLstEnt.domiciliation  chr(9)                                           /* domiciliation */
                TbLstEnt.cdbanque       chr(9)                                           /* code banque */
                TbLstEnt.cdgui          chr(9)                                           /* code guichet */
                TbLstEnt.nocompte       chr(9)                                           /* numero de compte */
                TbLstEnt.clerib         chr(9)                                           /* cle rib */
                TbLstEnt.emetteur       chr(9)                                           /* code émetteur */
                substring(TbLstEnt.iban,  1, 4, "character")   chr(9)                    /* iban */
                substring(TbLstEnt.iban,  5, 4, "character")   chr(9)                    /* iban */
                substring(TbLstEnt.iban,  9, 4, "character")   chr(9)                    /* iban */
                substring(TbLstEnt.iban, 13, 4, "character")   chr(9)                    /* iban */
                substring(TbLstEnt.iban, 17, 4, "character")   chr(9)                    /* iban */
                substring(TbLstEnt.iban, 21, 4, "character")   chr(9)                    /* iban */
                substring(TbLstEnt.iban, 25, 3, "character")   chr(9)                    /* iban */
                TbLstEnt.bic                      chr(9)                                 /* bic */
                string(TbLstEtab.nocon, "99999")  chr(9)                                 /* Code établissement */
                string(TbLstEtab.nonic, "99999")  chr(9)                                 /* nic  */
                trim(substitute("&1 &2 &3", TbLstEtab.NumVoi, TbLstEtab.BisTer, TbLstEtab.NomVoi)) chr(9)  /* Adresse établissement */
                TbLstEtab.cpvoi     chr(9)                                               /* Adresse 2 */
                TbLstEtab.cpad2     chr(9)                                               /* Adresse 3 */
                TbLstEtab.cdpos     chr(9)                                               /* Code postal */
                TbLstEtab.lbvil     chr(9)                                               /* nom ville  */
                TbLstEtab.cdins     chr(9)                                               /* Insee commune */
                TbLstEtab.cdape     chr(9)                                               /* code naf  */
                TbLstEtab.cdurs-adp chr(9)                                               /* code centre urssaf  */
                TbLstEtab.nours     chr(9)                                               /* numéro urssaf  */
                "R010"              chr(9)                                               /* code centre retraite ABELIO/HUMANIS */
                TbLstEtab.nocre     chr(9)                                               /* numéro caisse retraite  */
                ""                  chr(9)                                               /* code centre retraite 2 ou mutuelle ou prévoyance  */
                ""                  chr(9)                                               /* code centre retraite 2 ou mutuelle ou prévoyance  */
                ""                  chr(9)                                               /* code centre retraite 2 ou mutuelle ou prévoyance  */
                "2.90"              chr(9)                                               /* taux AT */
                "703CB"             chr(9)                                               /* Code risque */
                /* + "01" + chr(9)                                                          Code section AT n'existe plus en version 5 */
                "A"                 chr(9)                                               /* type taxe sur salaire */
                chr(10)
            .

            run creSuiExport("PEGAZ", "CGENT" + pcReferenceExport, string(TbLstEtab.nocon)).
            piNbEtabGen = piNbEtabGen + 1.
            for first etabl exclusive-lock
                where etabl.tpcon = TbLstEtab.tpcon
                  and etabl.nocon = TbLstEtab.nocon:
                if not etabl.lbdiv4 matches "*DT1EXPOR=*" then etabl.lbdiv4 = etabl.lbdiv4 + separ[2] + "DT1EXPOR=".
                if not etabl.lbdiv4 matches "*HE1EXPOR=*" then etabl.lbdiv4 = etabl.lbdiv4 + separ[2] + "HE1EXPOR=".
                do viPos = 1 to num-entries(etabl.lbdiv4 , separ[2]):
                    vcItem = entry(viPos, etabl.lbdiv4, separ[2]).
                    /* SY le 31/01/2014 : MAJ date 1er Export */
                    if vcItem begins "DT1EXPOR=" and date(entry(2, vcItem, "=")) = ? then entry(viPos, etabl.lbdiv4, separ[2]) = "DT1EXPOR=" + string(today, "99/99/9999").
                    {&_proparse_ prolint-nowarn(weakchar)}
                    if vcItem begins "HE1EXPOR=" and entry(2, vcItem, "=") = "" then entry(viPos, etabl.lbdiv4, separ[2]) = "HE1EXPOR=" + string(time, "HH:MM:SS").
                end.
                if majParamLbdiv("codSociete", "=", separ[2], TbLstEtab.codSociete, input-output etabl.lbdiv4)
                then assign
                    etabl.dtmsy = today
                    etabl.hemsy = time
                    etabl.cdmsy = mToken:cUser + "@entrpadp.p"
                .
                put stream stTrace unformatted "Maj Infos PEGASE etabl " etabl.tpcon " " etabl.nocon " " TbLstEtab.codSociete " : lbdiv4 = " etabl.lbdiv4 skip.
            end.
            /* Ajout SY le 03/03/2014: MAJ code société PEGASE de l'entreprise */
            for first ctanx exclusive-lock
                where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
                  and ctanx.tprol = {&TYPEROLE-tiers}
                  and ctanx.norol = TbLstEnt.notie:
                majParamLbdiv("codSociete", "=", separ[2], TbLstEnt.codSociete, input-output ctanx.lbdiv4).
                put stream stTrace unformatted "Maj Infos PEGASE Entreprise " TbLstEnt.nosir " " TbLstEnt.RaisonSociale " " TbLstEnt.codSociete " : lbdiv4 = " ctanx.lbdiv4 skip.
            end.
        end.
    end.

/**** Modif JPM du 02/03/2015
      Il n'est pas nécessaire d'envoyer la société ZZZZZ
    /* Chargement cabinet */
    find first roles no-lock
        where roles.tprol = "00044"
          and roles.norol = 90000 no-error.
    if available roles then do:
        find first tiers no-lock
            where tiers.notie = roles.notie no-error.
        if available tiers then do:
            /* Nom du cabinet */
            ChNomCab = tiers.lnom1.
            /* Recherche du no siren,code NIC et code APE du cabinet */
            find first ctanx no-lock
                where ctanx.tpcon = "01047"
                  and ctanx.tprol = "99999"
                  and ctanx.norol = roles.notie no-error.
              if available ctanx
              then assign
                 ChNicUse = string(ctanx.cptbq,"99999")
                 ChSirUse = string(ctanx.nosir)
             .
           end.
        end.
        /* raison sociale de paie */
        find first ctanx no-lock
            where ctanx.tpcon = "01046"
              and ctanx.tprol = "00044"
              and ctanx.norol = 90000 no-error.
        if available ctanx then do:
            assign
                ChCaiUrs = ctanx.tpfin
                ChNomCor = ctanx.lbdom
            .
            case ctanx.cdgui:
                when "10001" then ChCvlCor = "R". /* Monsieur */
                when "10005" then ChCvlCor = "L". /* Mademoiselle */
                when "10006" then ChCvlCor = "M". /* Madame */
                otherwise ChCvlCor = "".
            end case.
        end.
        /* Adresse du cabinet ou du gérant ou du syndic */
        find first ladrs no-lock
            where ladrs.tpidt = "00014"
              and ladrs.noidt = 1
              and ladrs.tpadr = "00001" no-error.
        if available ladrs
        then do:
            /* No voie : 12-14 --> 12
                         12345 --> 1234
                         121   --> 121 */
            do viCpUseInc = 1 to 4:
                vcLbTmpPdt = substring(ladrs.novoi,viCpUseInc,1).
                if vcLbTmpPdt < "0" or vcLbTmpPdt > "9" then
                leave.
            end.
            vChNumVoi = string(integer(substring(ladrs.novoi,1,viCpUseInc - 1)),"9999").

            /* Décodage de la nature de la voie (Rue, ...). */
            ChCodAdr = " ".
            case ladrs.CdAdr:
                when "00001" then assign ChCodAdr = "B".
                when "00002" then assign ChCodAdr = "T".
                when "00003" then assign ChCodAdr = "Q".
            end case.
            find first adres no-lock
                where adres.noadr = ladrs.noadr no-error.
            if available adres                  /* Décodage de la nature de la voie (Rue, ...). */
            then vChNomVoi = formatLibVoi(adres.ntvoi,adres.lbvoi).
            assign
                ChCmpAdr = adres.cpvoi
                ChCodIns = adres.cdins
                ChNomVil = adres.lbvil
                ChBurDis = adres.lbbur
                ChCodPos = adres.cdpos
            .
        end.
        put stream st2 unformatted
             string(NorefExport,"99999") "ZZZZZ" STRING(ChNomCab,"X(32)") chr(9) /* Code société STRING(NorefExport,"99999") + TbLstEnt.firstmdt + cNomSoc */
             STRING(ChNomCab,"X(32)")  chr(9)                                    /* Raison sociale */
             STRING(ChSirUse,"X(9)")   chr(9)                                    /* Numero siren */
             STRING(ChNomCor,"X(15)")  chr(9)                                    /* Nom responsable */
             " "   chr(9)                                                        /* Nom responsable TDS */
             TRIM(string(vChNumVoi, "X(4)") + " " + STRING(ChCodAdr, "X(1)") + " " + STRING(vChNomVoi,"X(26)")) chr(9)/* Adresse entreprise */
             STRING(ChCmpAdr,"X(32)")  chr(9)                                    /* Adresse 2 */
             " "   chr(9)                                                        /* Adresse 3 */
             STRING(ChCodPos,"X(5)")  chr(9)                                     /* Code postal */
             STRING(ChBurDis,"X(26)") chr(9)                                     /* Ville */
             " "   chr(9)                                                        /* Insee commune */
             " "   chr(9)                                                        /* code naf/ape */
             "Employés d'immeubles"   chr(9)                                     /* Activité */
             "1043"  chr(9)                                                      /* code convention collective */
              "01"   chr(9)                                                      /* nom banque  */
             " "  chr(9)                                                         /* domiciliation */
             " "  chr(9)                                                         /* code banque */
             " "  chr(9)                                                         /* code guichet */
             " "  chr(9)                                                         /* numero de compte */
             " "  chr(9)                                                         /* cle rib */
             " "  chr(9)                                                         /* iban */
             " "  chr(9)                                                         /* iban */
             " "  chr(9)                                                         /* iban */
             " "  chr(9)                                                         /* iban */
             " "  chr(9)                                                         /* iban */
             " "  chr(9)                                                         /* iban */
             " "  chr(9)                                                         /* iban */
             " "  chr(9)                                                         /* bic */
             "00000"  chr(9)                                                     /* Code établissement */
             "00000"  chr(9)                                                     /* nic  */
             " "  chr(9)                                                         /* Adresse établissement */
             " "  chr(9)                                                         /* Adresse 2 */
             " "  chr(9)                                                         /* Adresse 3 */
             " "  chr(9)                                                         /* Code postal */
             " "  chr(9)                                                         /* nom ville  */
             " "  chr(9)                                                         /* Insee commune */
             " "  chr(9)                                                         /* code naf  */
             " "  chr(9)                                                         /* code centre urssaf  */
             " "  chr(9)                                                         /* numéro urssaf  */
             " "  chr(9)                                                         /* code centre retraite  */
             " "  chr(9)                                                         /* numéro caisse retraite  */
             " "  chr(9)                                                         /* code centre retraite 2 ou mutuelle ou prévoyance  */
             " "  chr(9)                                                         /* code centre retraite 2 ou mutuelle ou prévoyance  */
             " "  chr(9)                                                         /* code centre retraite 2 ou mutuelle ou prévoyance  */
             " "  chr(9)                                                         /* taux AT */
             "703CB" chr(9)                                                      /* Code risque */
             "01"    chr(9)                                                      /* Code section AT */
             "A"     chr(9)                                                      /* type taxe sur salaire */
            chr(10).
****/
    output stream st2 close.
end procedure.

procedure demtraitPegase private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input  parameter pcCodeTraitement      as character no-undo.
    define input  parameter pcRepertoireTMP       as character no-undo.
    define input  parameter pcNomFichier          as character no-undo.
    define input  parameter piNombreLigne         as integer   no-undo.
    define input  parameter piNoRefTrans          as integer   no-undo.
    define input  parameter pcRepertoireCGI       as character no-undo.
    define input  parameter pcRepertoireSVGpegase as character no-undo.
    define input  parameter pcRepertoire7ZIP      as character no-undo.
    define output parameter pcListeEnvoi          as character no-undo.
    define output parameter piNombreDemande       as integer   no-undo.

    define variable vcFichierTransfert as character no-undo.

    /* compression .7z */
    vcFichierTransfert = replace(pcNomFichier, ".txt", "").
    os-delete value(vcFichierTransfert + ".7z") no-error.
    os-command silent value(substitute("&17z.exe a &2 &3&4", pcRepertoire7ZIP, vcFichierTransfert, pcRepertoireTMP, pcNomFichier)).
    /* création enregistrement de suivi */
    vcFichierTransfert = vcFichierTransfert + ".7z".
    run prc-Cre-Suivtrf(vcFichierTransfert, pcCodeTraitement, mToken:cUser, piNombreLigne, piNoRefTrans).
    assign
        pcListeEnvoi    = pcListeEnvoi + (if pcListeEnvoi > "" then "," else "") + vcFichierTransfert
        piNombreDemande = piNombreDemande + 1
    .
    /*Copie du fichier dans le répertoire TRANS/CGI pour envoi à BAL GI puis PEGASE */
    os-create-dir value(pcRepertoireCGI).
    os-copy value(vcFichierTransfert) value(pcRepertoireCGI + vcFichierTransfert).
    /*Sauvegarde du fichier dans le répertoire TRANS/SVG/gipegase */
    os-copy value(vcFichierTransfert) value(pcRepertoireSVGpegase + vcFichierTransfert).
    /*Suppression du fichier dans le répertoire TRANS/TMP */
    os-delete value(vcFichierTransfert).
    os-delete value(pcRepertoireTMP + pcNomFichier).
end procedure.

procedure MajLstEtab private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    todo: traductions
    ------------------------------------------------------------------------------*/
    define input parameter pcReferenceExport   as character no-undo.
    define input parameter pcCodeSocietePegase as character no-undo.
    define input parameter piNoidt             as integer   no-undo.
    define parameter buffer etabl for etabl.

    define variable vCdIs2Use    as character no-undo.
    define variable vCdIs3Use    as character no-undo.
    define variable vcCodeSocEtb as character no-undo.
    define variable vcdurstmp    as character no-undo.
    define variable viCpUseInc   as integer   no-undo.
    define variable vChNomVoi    as character no-undo.
    define variable vcLbTmpPdt   as character no-undo.
    define variable vChNumVoi    as character no-undo.
    define variable vChBisTer    as character no-undo.
    define buffer pclie for pclie.
    define buffer ifour for ifour.
    define buffer adres for adres.
    define buffer ladrs for ladrs.

    /* Adresse immeuble */
    for first ladrs no-lock
        where ladrs.tpidt = {&TYPEBIEN-immeuble}
          and ladrs.noidt = piNoidt
          and ladrs.tpadr = {&TYPEADRESSE-Principale}:
boucle:
        do viCpUseInc = 1 to 4:
            vcLbTmpPdt = substring(ladrs.novoi, viCpUseInc, 1, "character").
            if vcLbTmpPdt < "0" or vcLbTmpPdt > "9" then leave boucle.
        end.
        assign
            vChNumVoi = string(integer(substring(ladrs.novoi, 1, viCpUseInc - 1, "character")), "9999")
            vChBisTer = formatBisTer(ladrs.cdadr)
        .
        for first adres no-lock
            where adres.noadr = ladrs.noadr:
            vChNomVoi = formatLibVoi(adres.ntvoi, adres.lbvoi).
            run prcPays(adres.cdpay, output vCdIs2Use, output vCdIs3Use).
        end.
    end.
    create TblstEtab.
    buffer-copy etabl to TblstEtab
        assign
            tbLstEtab.siren = etabl.siren
            tbLstEtab.nonic = etabl.nonic
            tbLstEtab.NumVoi = vChNumVoi
            tbLstEtab.BisTer = vChBisTer
            tbLstEtab.NomVoi = vChNomVoi
            tbLstEtab.cpvoi = (if available adres then adres.cpvoi else "")
            tbLstEtab.cdpos = (if available adres then adres.cdpos else "")
            tbLstEtab.lbvil = (if available adres then adres.lbvil else "")
            tbLstEtab.cdins = (if available adres then adres.cdins else "")
            tbLstEtab.CdIs2Use = vCdIs2Use
            tbLstEtab.cdape = etabl.cdape
            tbLstEtab.cdurs = etabl.cdurs
            tbLstEtab.nours = etabl.nours
            tbLstEtab.noass = etabl.noass
            tbLstEtab.nocre = etabl.nocre
    .
    vcCodeSocEtb = getValeurParametre ("codSociete", "=", separ[2], etabl.lbdiv4).
    if vcCodeSocEtb = ? or vcCodeSocEtb = "" then vcCodeSocEtb = pcCodeSocietePegase.
    if lookup(pcReferenceExport, "13073,13080" ) > 0 then vcCodeSocEtb = "1" + substring(vcCodeSocEtb, 2).
    TbLstEtab.codSociete = vcCodeSocEtb.
    case TbLstEtab.cdurs:
        when "75U0" then TbLstEtab.cdurs-adp = "U750".
        otherwise do:
            /* Ajout SY le 27/05/2014: recherche correspondance dans pclie (PGCOR) */
            for first ifour no-lock
                where ifour.soc-cd = integer(pcReferenceExport)
                  and ifour.coll-cle = "OSS"
                  and ifour.four-cle = "OSS " + TbLstEtab.cdurs
                  and ifour.type-four = "O"
              , first pclie no-lock
                where pclie.tppar = "PGCOR"
                  and pclie.zon01 = pcReferenceExport
                  and pclie.zon05 = "OSS"
                  and pclie.zon06 = ifour.cpt-cd:
                TbLstEtab.cdurs-adp = pclie.zon02.
            end.
            if (TbLstEtab.cdurs-adp = ? or TbLstEtab.cdurs-adp = "")
            and TbLstEtab.cdurs matches "*U*" then do:
                assign
                    vcdurstmp            = replace(TbLstEtab.cdurs, "U", "")
                    TbLstEtab.cdurs-adp = "U" + vcdurstmp
                .
                if glTrace then put stream stTrace unformatted "*** WARNING *** Conversion code URSSAF : " TbLstEtab.cdurs " -> " TbLstEtab.cdurs skip.
            end.
            if TbLstEtab.cdurs > "" and (TbLstEtab.cdurs-adp = ? or TbLstEtab.cdurs-adp = "")
            then put stream stTrace unformatted "*** ERREUR *** Correspondance inconnue pour code URSSAF : " TbLstEtab.cdurs " Mandat " TbLstEtab.nocon skip.
        end.
    end case.
    put stream stTrace unformatted " " skip "ARTICLE etablISSEMENT CREE (TbLstEtab): ". export stream stTrace TbLstEtab.
end procedure.

procedure TrtEntreprise private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    todo : traductions
    ------------------------------------------------------------------------------*/
    define parameter buffer etabl for etabl.
    define input  parameter pcTypeRole          as character no-undo.
    define input  parameter piNumeroRole        as int64     no-undo.
    define input  parameter piNumeroTiers       as int64     no-undo.
    define input  parameter pcLbnom             as character no-undo.
    define input  parameter pcReferenceExport   as character no-undo.
    define input  parameter pcCodeSocietePegase as character no-undo.
    define input  parameter pcPremierMandat     as character no-undo.
    define buffer tiers for tiers.
    define buffer ctanx for ctanx.

    put stream stTrace unformatted "TrtEntreprise pour etabl: " etabl.tpcon " " etabl.nocon " type de role " pcTypeRole " Societe " pcCodeSocietePegase " Nom : " pcLbnom skip.
    find first ctanx no-lock
        where ctanx.tpcon = {&TYPECONTRAT-TVAIntracommunautaire}
          and ctanx.tprol = {&TYPEROLE-tiers}
          and ctanx.norol = piNumeroTiers no-error.
    if not available ctanx
    then mError:createError({&information},
        substitute("ERREUR: SIREN non trouvé pour &1 no &2&3 (table ctanx / 01047)", outilTraduction:getLibelleProg('O_ROL', pcTypeRole), piNumeroRole, pcLbnom)).
    else do:
        find first tiers no-lock where tiers.notie = piNumeroTiers no-error.
        if available tiers
        then do:
            if glTrace
            then do:
                put stream stTrace unformatted "   -entreprise roles: ".
                export stream stTrace pcTypeRole piNumeroRole piNumeroTiers.
                put stream stTrace unformatted "   -entreprise ctanx: ".
                export stream stTrace ctanx.
                put stream stTrace unformatted "   -entreprise tiers: ".
                export stream stTrace tiers.
            end.
            run MajLstEnt(buffer ctanx, piNumeroTiers, piNumeroRole, pcTypeRole, etabl.siren, etabl.nocon, pcReferenceExport, pcCodeSocietePegase, pcPremierMandat).    /* ajout siren de l'établissement suite pb 03073 mandat 6855 */
        end.
        else put stream stTrace unformatted "*** ERREUR *** Anomalie Tiers ou ctanx 01047 pour Entreprise " pcTypeRole "/" piNumeroRole " " pcLbnom skip.
    end.
end procedure.

procedure MajLstEnt private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    todo : traduction
    ------------------------------------------------------------------------------*/
    define parameter buffer ctanx for ctanx.
    define input parameter piNumeroTiers       as integer   no-undo.
    define input parameter piNumeroRole        as integer   no-undo.
    define input parameter pcTypeRole          as character no-undo.
    define input parameter piEtablSiret        as integer   no-undo.
    define input parameter piEtablNocon        as integer   no-undo.
    define input parameter pcReferenceExport   as character no-undo.
    define input parameter pcCodeSocietePegase as character no-undo.
    define input parameter pcPremierMandat     as character no-undo.

    define variable vChNumVo2    as character no-undo.
    define variable vChTypSup    as character no-undo.
    define variable vcLbNomFor   as character no-undo.
    define variable vCdIs2Use    as character no-undo.
    define variable vCdIs3Use    as character no-undo.
    define variable vcCodeSocEnt as character no-undo.
    define variable viCpUseInc   as integer   no-undo.
    define variable vChRetSol    as character no-undo.
    define variable vChNomVoi    as character no-undo.
    define variable vcLbTmpPdt   as character no-undo.
    define variable vChBisTer    as character no-undo.
    define buffer sys_pr  for sys_pr.
    define buffer ladrs   for ladrs.
    define buffer vbAdres for adres.

    if piEtablSiret <> ctanx.nosir
    then put stream stTrace unformatted "*** ERREUR *** SIRET CTANX DIFFERENT SIRET etablISSEMENT " piEtablSiret " " ctanx.nosir skip.
    for first TbLstEnt where TbLstEnt.nosir = piEtablSiret:
        /* Ajout Sy le 02/04/2014 */
        pcCodeSocietePegase = TbLstEnt.codSociete.      /* Mettre à jour le code société associé à ce no SIREN */
        return.
    end.
    put stream stTrace unformatted "Article entreprise avant création: " piNumeroTiers " SIREN = " ctanx.nosir " NIC = " ctanx.cptbq skip .

    for first ladrs no-lock
        where ladrs.tpidt = pcTypeRole
          and ladrs.noidt = piNumeroRole
          and ladrs.tpadr = {&TYPEADRESSE-Principale}:
boucle:
        do viCpUseInc = 1 to 4:
           vcLbTmpPdt = substring(ladrs.novoi, viCpUseInc, 1, "character").
           if vcLbTmpPdt < "0" or vcLbTmpPdt > "9" then leave boucle.
        end.
        assign
            vChNumVo2 = string(integer(substring(ladrs.novoi, 1, viCpUseInc - 1, "character")), "9999")
            vChBisTer = formatBisTer(ladrs.cdadr)
        .
        for first vbAdres no-lock
            where vbAdres.noadr = ladrs.noadr:
            /*--> Code Iso de l'adresse */
            run PrcPays(vbAdres.cdpay, output vCdIs2Use, output vCdIs3Use).
            vChNomVoi = formatLibVoi(vbAdres.ntvoi, vbAdres.lbvoi).
        end.
    end.

    run infosBanque(integer(pcReferenceExport), piEtablNocon, output vChRetSol).
    assign
        /*--> Nom formate */
        vcLbNomFor = outilFormatage:getNomTiersFormtiea ("TYPE", pcTypeRole, piNumeroRole, 64)  //remplace appel FormTiea.p
        vcLbNomFor = entry(1, vcLbNomFor, "|")
    .
    /*--> Type de support */
    find first sys_pr no-lock
        where sys_pr.tppar = "TPSUP"
          and sys_pr.cdpar = ctanx.cdgui no-error.
    assign
        vChTypSup    = if available sys_pr then sys_pr.zone2 else ""
        /* rechercher si l'entreprise a déjà un code société affecté */
        vcCodeSocEnt = getValeurParametre ("codSociete", "=", separ[2], ctanx.lbdiv4)
    .
    if vcCodeSocEnt > "" then pcCodeSocietePegase = vcCodeSocEnt.
    if lookup(pcReferenceExport, "13073,13080") > 0 then pcCodeSocietePegase = "1" + substring(pcCodeSocietePegase, 2).
    create TbLstEnt.
    assign
        TbLstEnt.notie = piNumeroTiers
        TbLstEnt.nosir = piEtablSiret
        TbLstEnt.nonic = ctanx.cptbq
        TbLstEnt.cdape = ctanx.cdape
        TbLstEnt.RaisonSociale = vcLbNomFor
        TbLstEnt.cpvoi = (if available vbAdres then vbAdres.cpvoi else "")
        TbLstEnt.novoi = vChNumVo2
        TbLstEnt.cdbis = vChBisTer
        TbLstEnt.nmvoi = vChNomVoi
        TbLstEnt.cdins = (if available vbAdres then vbAdres.cdins else "")
        TbLstEnt.prsig = ctanx.lbtit
        TbLstEnt.lbvil = (if available vbAdres then vbAdres.lbvil else "")
        TbLstEnt.cdpos = (if available vbAdres then vbAdres.cdpos else "")
        TbLstEnt.lbbur = (if available vbAdres then vbAdres.lbbur else "")
        tbLstEnt.treso = ctanx.ntcau        /* trésorerie (plus utilise)            */
        TbLstEnt.cdtva = ctanx.tpact        /* Assujettissement TVA                 */
        TbLstEnt.cdHon = ctanx.cdbqu        /* Versement des honoraires             */
        TbLstEnt.nbtie = ctanx.norib        /* Nombre de tiers                      */
        TbLstEnt.tpsup = vChTypSup
        TbLstEnt.nmsig = ctanx.lnnot        /* Nom du signataire                    */
        TbLstEnt.cdfng = ctanx.cdreg        /* Assujettissement FNGS                */
        TbLstEnt.cdeff = ctanx.tpuni        /* Classe d'effectif  (PAEFF)           */
        tbLstEnt.Tpfin = ctanx.tpfin        /* code déclarant                       */
        TbLstEnt.tpbqu = ctanx.tpbqu        /* code adresse CRIP                    */
        TbLstEnt.nlent = ctanx.cdjur        /* nlle entreprise                      */
        TbLstEnt.recet = ctanx.cdobj        /* centre de recette                    */
        TbLstEnt.taxsa = ctanx.mtcau        /* Taxe sur salaire annee precedente    */
        TbLstEnt.norol = piNumeroRole        /* no proprietaire ou syndicat          */
        TbLstEnt.cdis2 = vCdIs2Use           /* Code iso 2 pays de l'adresse         */
        TbLstEnt.cdis3 = vCdIs3Use           /* Code iso 3 pays de l'adresse         */
        TbLstEnt.firstmdt   = pcPremierMandat        /* 1er mandat */
        TbLstEnt.codSociete = pcCodeSocietePegase   /* code société formaté pour Pégase   */
    .
    if num-entries(vChRetSol, "|") >= 16
    then assign      /* SY 0315/0241 le 31/03/2015 */
        TbLstEnt.domiciliation = string(entry(8,  vChRetSol, "|"), "X(32)")  /* domiciliation bancaire */
        TbLstEnt.cdbanque      = string(entry(4,  vChRetSol, "|"), "X(5)")
        TbLstEnt.cdgui         = string(entry(5,  vChRetSol, "|"), "X(5)")
        TbLstEnt.nocompte      = string(entry(6,  vChRetSol, "|"), "X(11)")
        TbLstEnt.clerib        = string(entry(7,  vChRetSol, "|"), "X(2)")
        TbLstEnt.iban          = string(entry(3,  vChRetSol, "|"), "X(27)")
        TbLstEnt.bic           = string(entry(16, vChRetSol, "|"), "X(11)")
        TbLstEnt.JournalBq     = string(entry(10, vChRetSol, "|"), "X(5)")
        TbLstEnt.emetteur      = string(entry(15, vChRetSol, "|"), "X(6)")
    .
    if glTrace
    then put stream stTrace unformatted "   Adresse entreprise: " trim(substitute("&1 &2 &3", TbLstEnt.novoi, TbLstEnt.cdbis, TbLstEnt.nmvoi)) skip.
    put stream stTrace unformatted "ARTICLE ENTREPRISE CREE (TbLstEnt) : " . export stream stTrace TbLstEnt.

end procedure.

procedure PrcPays private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input  parameter pCdIs4Use as character no-undo.
    define output parameter pCdIs2Use as character no-undo.
    define output parameter pCdIs3Use as character no-undo initial "000".
    define buffer ipays for ipays.

    for first ipays no-lock
        where ipays.cdiso4 = string(integer(pCdIs4Use), "999"):
        assign
            pCdIs2Use = ipays.cdiso2
            pCdIs3Use = ipays.cdiso3
        .
        /* Faire le lien avec table des pays de PEGASE */
        if ipays.cdiso3 = "FRA" then pCdIs3Use = "FR ".
        if ipays.cdiso3 = "SLV" then pCdIs3Use = "EL ".
        if ipays.cdiso3 = "NLD" then pCdIs3Use = "PB ".
        if ipays.cdiso3 = "YUG" then pCdIs3Use = "YOU".
        if ipays.cdiso3 = "PRT" then pCdIs3Use = "POR".
    end.
end procedure.

procedure InfosBanque private:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    define input  parameter piNorefExport as integer   no-undo.
    define input  parameter piEtablNocon  as integer   no-undo.
    define output parameter pcLst-Out     as character no-undo.
    define variable viProfilClasse as integer   no-undo.
    define buffer ietab   for ietab.
    define buffer vbIetab for ietab.
    define buffer ijou    for ijou.
    define buffer ibque   for ibque.
    /* SY 0315/0241 */
    assign
        pcLst-Out                 = fill("|", 15)             /* 16 "ENTRIES" */
        entry(1, pcLst-Out, "|" ) = "999999"
        entry(2, pcLst-Out, "|" ) = "99999999999"
    .
    find first ietab no-lock
        where ietab.soc-cd  = piNorefExport
          and ietab.etab-cd = piEtablNocon no-error.
    if available ietab
    then do:
        put stream stTrace unformatted "   ietab : " ietab.profil-cd " " ietab.bqprofil-cd skip. export stream stTrace ietab.
        if ietab.profil-cd <> ietab.bqprofil-cd
        then find first vbIetab no-lock
            where vbIetab.soc-cd    = piNorefExport
              and vbIetab.profil-cd = ietab.bqprofil-cd no-error.
        case ietab.bqprofil-cd:
           when 10 then viProfilClasse = 1.
           when 20 then viProfilClasse = 2.
           when 90 then viProfilClasse = 9.
           otherwise viProfilClasse = 0.
        end case.
        if glTrace then put stream stTrace unformatted "  viProfilClasse : " viProfilClasse " "  ietab.bqjou-cd skip .
        /** recherche journal de banque par défaut **/
        for first ijou no-lock
            where ijou.soc-cd  = ietab.soc-cd
              and ijou.etab-cd = (if available vbIetab then vbIetab.etab-cd else ietab.etab-cd)
              and ijou.jou-cd  = ietab.bqjou-cd:
            if glTrace then put stream stTrace unformatted "    ijou: ".
            export stream stTrace ijou.
            find first ibque no-lock
                where ibque.soc-cd  = ietab.soc-cd
                  and ibque.etab-cd = ijou.etab-cd
                  and ibque.cpt-cd  = ijou.cpt-cd no-error.
            if available ibque then do:
                if glTrace then put stream stTrace unformatted "   ibque: ".
                export stream stTrace ibque.
                pcLst-Out = substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", "|", 
                                ibque.nne, ibque.tip-cd, ibque.iban, ibque.bque, ibque.guichet, ibque.cpt, ibque.rib, ibque.domicil[2])
                          + substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9", "|",
                                ibque.domicil[1], ijou.jou-cd, ibque.cpt-cd, string(available vbIetab), string(viProfilClasse, '9'), string(ibque.bque-cd, '999'), string(ibque.emet2-num, '999999'), ibque.bic).
            end.
            else for first ibque no-lock
                where ibque.soc-cd  = piNorefExport
                  and ibque.etab-cd = ijou.etab-cd:
                pcLst-Out = substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1", "|",
                                ibque.nne, ibque.tip-cd, ibque.iban, ibque.bque, ibque.guichet, ibque.cpt, ibque.rib, ibque.domicil[2])
                          + substitute("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9", "|",
                                ibque.domicil[1], ijou.jou-cd, ibque.cpt-cd, string(available vbIetab), string(viProfilClasse, '9'), string(ibque.bque-cd, '999'), string(ibque.emet2-num, '999999'), ibque.bic).
            end.
        end.
    end.
    else put stream stTrace unformatted " *** ERREUR *** ietab absent: " string(piNorefExport, "99999") " " piEtablNocon skip.

end procedure.

procedure creSuiExport private:
    /*------------------------------------------------------------------------------
    purpose: Creation d'un suivi
    Note   :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeExport      as character no-undo.
    define input parameter pcTypeIdentifiant as character no-undo.
    define input parameter pcIdentifiant     as character no-undo.
    define buffer SuiExport for SuiExport.

    {&_proparse_ prolint-nowarn(nowait)}
    find first SuiExport exclusive-lock
        where SuiExport.TpExp = pcTypeExport
          and SuiExport.TpIdt = pcTypeIdentifiant
          and SuiExport.NoIdt = pcIdentifiant  no-error.
    if not available SuiExport then do:
        create SuiExport.
        assign
            SuiExport.TpExp = pcTypeExport
            SuiExport.TpIdt = pcTypeIdentifiant
            SuiExport.NoIdt = pcIdentifiant
        .
    end.
    assign
        SuiExport.DtExp = today
        SuiExport.HeExp = time
    .
end procedure.
