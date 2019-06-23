/*-----------------------------------------------------------------------------
File        : extractionDocument.p
Purpose     : Recherche des donnees de fusion du document
Author(s)   : RF - 2008/04/11
Notes       :
Derniere revue: 2018/03/20 - phm
01  09/10/2008  PL    PB avec le référencement des courriers
02  28/04/2009  SY    ne pas initialiser les variables globales d'extraction Fgxxxxx à TRUE. (Init dans extract.p uniquement.)
03  13/05/2009  PL    1108/0433: Pb inversion sig1 et sig2 au stockage.
04  20/07/2009  PL    0709/0141: Pb inversion sig1 et sig2 pour les champs liés à l'adresse.
    10/09/2009  SY    0909/0064: livraison V10.03 patch 02 et V9.97 patch C06
05  20/07/2010  PL    0710/0005: date creation courrier = date début eve si dispo.
06  27/08/2010  NP    0810/0096 Modif ds fctexpor.i
07  11/03/2015  SY    0315/0053 Ajout Mlog pour tracer CheminLogo
08  25/01/2016  PL    0711/0069 Normalisation adresses sur 6 lignes
------------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2tiers.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/famille2tiers.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/fusion/fusionDocument.i}
{preprocesseur/listeRubQuit2TVA.i}

using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionDocument.
using bureautique.fusion.classe.fusionBanque.
using bureautique.fusion.classe.fusionRole.
 
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i} 
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}

procedure extractionDocument:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service appelé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroDocument as int64     no-undo.
    define input        parameter pcListeChamp     as character no-undo.
    define input-output parameter poFusionDocument as class FusionDocument no-undo.

    define variable voRole    as class fusionRole    no-undo.
    define variable voAdresse as class fusionAdresse no-undo.
    define variable dTempo    as date      no-undo.
    define variable LbTmpPdt  as character no-undo.
    define variable RpWrdEve  as character no-undo.

    define variable viCompteur as integer no-undo.
    define variable vlBloc1    as logical no-undo.
    define variable vlBloc2    as logical no-undo.
    define variable vlBloc3    as logical no-undo.

    define buffer docum for docum.
    define buffer lidoc for lidoc.
    define buffer ssdos for ssdos.
    define buffer tbent for tbent.

    find first docum no-lock
        where docum.nodoc = piNumeroDocument no-error.
    if not available docum then return.

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-CommentaireTechnique}      or when {&FUSION-CommentaireFinancier}          or when {&FUSION-DateCreationSousDossier}
         or when {&FUSION-DateFinSousDossier}        or when {&FUSION-DateCreationCourrier}          or when {&FUSION-DateeditionCourrier}
         or when {&FUSION-DateRelanceCourrier}       or when {&FUSION-DateFinCourrier}               or when {&FUSION-DateemailCourrier} 
         or when {&FUSION-DateFaxCourrier}           or when {&FUSION-ReferenceCourrier}             or when {&FUSION-DateLCreationSousDossier}
         or when {&FUSION-DateLFinSousDossier}       or when {&FUSION-DateLCreationCourrier}         or when {&FUSION-DateLeditionCourrier}
         or when {&FUSION-DateLRelanceCourrier}      or when {&FUSION-DateLFinCourrier}              or when {&FUSION-DateLemailCourrier}
         or when {&FUSION-DateLFaxCourrier}          or when {&FUSION-DateCreationCourrierLettre}    or when {&FUSION-DateeditionCourrierLettre}
         or when {&FUSION-DateRelanceCourrierLettre} or when {&FUSION-DateFinCourrierLettre}         or when {&FUSION-DateemailCourrierLettre}
         or when {&FUSION-DateFaxCourrierLettre}     or when {&FUSION-DateCreationSousDossierLettre} or when {&FUSION-DateFinSousDossierLettre}
            then do:
                if vlBloc1 then next boucleCHamp.

                /* Date de debut de l'évènement: Recherche du sous-dossier impossible à partir du document 
                           car le role n'est pas forcement celui sur lequel porte l'évènement. */
                // dTempo = date(DonneParametre("DATE_DEBUT_EVENEMENT")). // THK COMMENT RECUPERER CETTE INFO SANS UTILISER LA TABLE PARAMETRE ????
                if dTempo = ? then dTempo = docum.tbdat[1].
                assign
                    vlBloc1 = true
                    poFusionDocument:DateCreationCourrier       = dateToCharacter(dTempo)
                    poFusionDocument:DateLCreationCourrier      = outilFormatage:getDateFormat(dTempo, "L")
                    poFusionDocument:DateCreationCourrierLettre = outilFormatage:getDateFormat(dTempo, "LL")
                    poFusionDocument:DateEditionCourrier        = dateToCharacter(docum.tbdat[2])
                    poFusionDocument:DateLEditionCourrier       = outilFormatage:getDateFormat(docum.tbdat[2], "L")
                    poFusionDocument:DateEditionCourrierLettre  = outilFormatage:getDateFormat(docum.tbdat[2], "LL")
                    poFusionDocument:DateRelanceCourrier        = dateToCharacter(docum.tbdat[3])
                    poFusionDocument:DateLRelanceCourrier       = outilFormatage:getDateFormat(docum.tbdat[3], "L")
                    poFusionDocument:DateRelanceCourrierLettre  = outilFormatage:getDateFormat(docum.tbdat[3], "LL")
                    poFusionDocument:DateFinCourrier            = dateToCharacter(docum.tbdat[4])
                    poFusionDocument:DateLFinCourrier           = outilFormatage:getDateFormat(docum.tbdat[4], "L")
                    poFusionDocument:DateFinCourrierLettre      = outilFormatage:getDateFormat(docum.tbdat[4], "LL")
                    poFusionDocument:DateEmailCourrier          = dateToCharacter(docum.tbdat[5])
                    poFusionDocument:DateLEmailCourrier         = outilFormatage:getDateFormat(docum.tbdat[5], "L")
                    poFusionDocument:DateEmailCourrierLettre    = outilFormatage:getDateFormat(docum.tbdat[5], "LL")
                    poFusionDocument:DateFaxCourrier            = dateToCharacter(docum.tbdat[6])
                    poFusionDocument:DateLFaxCourrier           = outilFormatage:getDateFormat(docum.tbdat[6], "L")
                    poFusionDocument:DateFaxCourrierLettre      = outilFormatage:getDateFormat(docum.tbdat[6], "LL")
                    poFusionDocument:CommentaireTechnique       = docum.lbobj
                    poFusionDocument:CommentaireFinancier       = docum.lbcom
                    poFusionDocument:ReferenceCourrier~         = entry(1, entry(2, if docum.lbdoc > "" then docum.lbdoc else CRENOMDOC(docum.nodoc), "~\"), ".")
                .
                for first lidoc no-lock 
                    where lidoc.nodoc = docum.nodoc
                  , first ssdos no-lock
                        where ssdos.tpidt = lidoc.tpidt
                          and ssdos.noidt = lidoc.noidt
                          and ssdos.nossd = lidoc.nossd:
                    assign
                        poFusionDocument:DateCreationSousDossier       = dateToCharacter(ssdos.tbdat[1])
                        poFusionDocument:DateLCreationSousDossier      = outilFormatage:getDateFormat(ssdos.tbdat[1], "L")
                        poFusionDocument:DateCreationSousDossierLettre = outilFormatage:getDateFormat(ssdos.tbdat[1], "LL")
                        poFusionDocument:DateFinSousDossier            = dateToCharacter(ssdos.tbdat[2])
                        poFusionDocument:DateLFinSousDossier           = outilFormatage:getDateFormat(ssdos.tbdat[2], "L")
                        poFusionDocument:DateFinSousDossierLettre      = outilFormatage:getDateFormat(ssdos.tbdat[2], "LL")
                    .
                end.
            end.
            when {&FUSION-SignataireCourrier}          or when {&FUSION-TelSignataire1}     or when {&FUSION-FonctionSignataire1} 
         or when {&FUSION-InitialesSignataireCourrier} or when {&FUSION-PortableSignataire} or when {&FUSION-FaxSignataire} 
         or when {&FUSION-emailSignataire}
            then do:
                if vlBloc2 then next boucleCHamp.

                assign
                    vlBloc2 = true
                    voRole                                       = chargeRole({&TYPEROLE-gestionnaire}, docum.noges, piNumeroDocument)
                    poFusionDocument:SignataireCourrier          = voRole:Nom
                    poFusionDocument:FonctionSignataire1         = voRole:Profession
                    poFusionDocument:InitialesSignataireCourrier = voRole:Initiales
                    voAdresse                           = chargeAdresse({&TYPEROLE-gestionnaire}, docum.noges, piNumeroDocument)
                    poFusionDocument:TelSignataire1     = voAdresse:telephone
                    poFusionDocument:PortableSignataire = voAdresse:portable
                    poFusionDocument:FaxSignataire      = voAdresse:fax
                    poFusionDocument:EmailSignataire    = voAdresse:mail
                .
            end.
            when {&FUSION-SignataireCourrierBis}          or when {&FUSION-TelSignataire2}        or when {&FUSION-FonctionSignataire2}
         or when {&FUSION-InitialesSignataireCourrierBis} or when {&FUSION-PortableSignataireBis} or when {&FUSION-FaxSignataireBis}
         or when {&FUSION-emailSignataireBis}
            then do:
                if vlBloc3 then next boucleCHamp.

                assign
                    vlBloc3 = true
                    voRole                                          = chargeRole({&TYPEROLE-gestionnaire}, docum.nocol, piNumeroDocument)
                    poFusionDocument:SignataireCourrierBis          = voRole:Nom
                    poFusionDocument:FonctionSignataire2            = voRole:Profession
                    poFusionDocument:InitialesSignataireCourrierBis = voRole:Initiales
                    voAdresse                              = chargeAdresse({&TYPEROLE-gestionnaire}, docum.noCol, piNumeroDocument)
                    poFusionDocument:TelSignataire2        = voAdresse:Telephone
                    poFusionDocument:PortableSignataireBis = voAdresse:portable
                    poFusionDocument:FaxSignataireBis      = voAdresse:fax
                    poFusionDocument:EmailSignataireBis    = voAdresse:mail
                .
            end.
            when {&FUSION-cheminlogo} then do:
                assign
                    LbTmpPdt                    = RpWrdEve + "model~\gi~\"
                    poFusionDocument:CheminLogo = quoter(replace(LbTmpPdt, "~\", "~\~\") + "logogi.bmp")
                .
                if docum.tbsig[3] > ""
                then for first tbEnt no-lock
                    where tbEnt.cdent = string(integer(docum.tbsig[1]) + 3, "99999")
                      and tbEnt.iden1 = "00003"
                      and tbEnt.iden2 = docum.tbsig[3]:
                    if search(substitute("&1model~\sigle~\&2", RpWrdEve, tbent.lben1)) <> ? 
                    then poFusionDocument:Cheminlogo = quoter(replace(substitute("&1model~\sigle~\&2", RpWrdEve, tbEnt.lben1), "~\", "~\~\")).
                end.
                else for first tbEnt no-lock
                    where tbEnt.iden1 = "00003":
                    if search(substitute("&1model~\sigle~\&2", RpWrdEve, tbent.lben1)) <> ?
                    then poFusionDocument:Cheminlogo = quoter(replace(substitute("&1model~\sigle~\&2", RpWrdEve, tbEnt.lben1), "~\", "~\~\")).
                end.
            end.
            when {&FUSION-entete} then do:
                poFusionDocument:CheminEntete = quoter(replace(RpWrdEve + "model~\gi~\vide.doc", "~\", "~\~\")).
                if docum.tbsig[2] > ""
                then for first tbEnt no-lock
                    where tbEnt.cdent = string(integer(docum.tbsig[1]) + 3, "99999")
                      and tbEnt.iden1 = "00002"
                      and tbEnt.iden2 = docum.tbsig[2]:
                    if search(substitute("&1model~\sigle~\&2", RpWrdEve, tbent.lben1)) <> ?
                    then poFusionDocument:CheminEntete = quoter(replace(substitute("&1model~\sigle~\&2", RpWrdEve, tbEnt.lben1), "~\", "~\~\")).
                end.
            end.
            when {&FUSION-PiedPage} then do:
                poFusionDocument:CheminPied = quoter(replace(RpWrdEve + "model~\gi~\vide.doc", "~\", "~\~\")).
                if docum.tbsig[4] > ""
                then for first tbEnt no-lock
                    where tbEnt.cdent = string(integer(docum.tbsig[1]) + 3,"99999")
                      and tbEnt.iden1 = "00001"
                      and tbEnt.iden2 = docum.tbsig[4]:
                    if search(substitute("&1model~\sigle~\&2", RpWrdEve, tbent.lben1)) <> ?
                    then poFusionDocument:CheminPied = quoter(replace(substitute("&1model~\sigle~\&2", RpWrdEve, tbEnt.lben1), "~\", "~\~\")).
                end.
            end.
        end case.
    end.
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.
