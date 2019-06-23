/*-----------------------------------------------------------------------------
File        : extractionGarant.p
Description : Recherche des donnees de fusion garantie locataire
Author(s)   : RF - 2009/01/16, KANTENA - 2018/02/26
Notes       :
01  27/08/2010  NP    0810/0096: Modif ds fctexpor.i
02  28/09/2011  PL    0911/0160: Controle nogaruse <> 0
03  08/02/2013  SY    1112/0097: Gestion Multi-garant au niveau de la la tache contenant les informations             
04  11/01/2016  PL    0711/0069: Normalisation adresses sur 6 lignes
05  25/01/2016  PL    0711/0069: Normalisation adresses sur 6 lignes
-----------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/fusion/fusionGarant.i}
{preprocesseur/listeRubQuit2TVA.i}

using bureautique.fusion.classe.fusionGarant.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionBanque.
using bureautique.fusion.classe.fusionRole.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i} 
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}

procedure extractionGarant:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroGarant   as integer   no-undo.
    define input        parameter piNumeroBail     as integer   no-undo.
    define input        parameter piNumeroDocument as int64     no-undo.
    define input        parameter piNumeroRole     as integer   no-undo.
    define input        parameter pcListeChamp     as character no-undo.
    define input-output parameter poFusionGarant   as class fusionGarant no-undo.

    define variable viCompteur as integer no-undo.
    define variable vlBloc1    as logical no-undo.
    define variable voAdresse  as class fusionAdresse no-undo.
    define variable voRole     as class fusionRole    no-undo.

    define buffer tache for tache.

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-NomCompletGarant}     or when {&FUSION-adresseGarant}             or when {&FUSION-SuiteadresseGarant}
         or when {&FUSION-CodePostalGarant}     or when {&FUSION-VilleGarant}               or when {&FUSION-NoenregisGarant}
         or when {&FUSION-DateSignatureGarant}  or when {&FUSION-DateDebutGarant}           or when {&FUSION-DateFinGarant}
         or when {&FUSION-DelaisPreavisGarant}  or when {&FUSION-TypeacteGarant}            or when {&FUSION-MtCautionGarant}
         or when {&FUSION-VilleSignatureGarant} or when {&FUSION-TitreGarant}               or when {&FUSION-TitreLGarant}
         or when {&FUSION-NomGarant}            or when {&FUSION-PolitesseGarant}           or when {&FUSION-NomGarantContact}
         or when {&FUSION-TitreGarantContact}   or when {&FUSION-FaxGarant}                 or when {&FUSION-emailGarant}
         or when {&FUSION-VilleCedexGarant}     or when {&FUSION-VilleCedexSignatureGarant} or when {&FUSION-ComplementAdresseIdentGarant}
         or when {&FUSION-ComplementAdresseIdentSignatureGarant}  /* PL : 11/01/2016 - (Fiche : 0711/0069) */
            then do:
                if vlBloc1 then next boucleCHamp.

                vlBloc1 = true.
                if piNumeroGarant <> 0 then do:
                    /*** TACHE GARANT ***/
                    find first tache no-lock
                         where tache.tpcon = {&TYPECONTRAT-bail}
                           and tache.nocon = piNumeroBail
                           and tache.tptac = {&TYPETACHE-garantieLocataire}
                           and tache.notac = piNumeroRole no-error.       /* no garant */
                    if available tache then piNumeroGarant = tache.noita. 
                    for first tache no-lock
                        where tache.NoIta = piNumeroGarant:
                        assign
                            poFusionGarant:NoEnregisGarant           = tache.tpfin   /* modif SY le 04/11/2008 tache.tpges*/
                            poFusionGarant:DateSignatureGarant       = dateToCharacter(date(tache.ntges))
                            poFusionGarant:DateDebutGarant           = dateToCharacter(tache.dtdeb)
                            poFusionGarant:DateFinGarant             = dateToCharacter(tache.dtfin)
                            poFusionGarant:DelaisPreavisGarant       = string(tache.duree) + " Mois"
                            poFusionGarant:TypeActeGarant            = outilTraduction:getLibelleParam("TPACT", tache.pdges)
                            poFusionGarant:MtCautionGarant           = montantToCharacter(tache.mtreg, true)
                            poFusionGarant:VilleSignatureGarant      = SuppCedex(tache.tpges)          /* 0109/0192 */
                            poFusionGarant:VilleCedexSignatureGarant = tache.tpges
                            poFusionGarant:ComplementAdresseIdentSignatureGarant = voAdresse:IdentAdresse
                        .
                        assign
                            voRole                          = chargeRole({&TYPEROLE-garant}, tache.notac, piNumeroDocument)
                            poFusionGarant:TitreGarant      = voRole:Titre
                            poFusionGarant:TitreLGarant     = voRole:titreLettre
                            poFusionGarant:NomGarant        = voRole:nom
                            poFusionGarant:NomCompletGarant = voRole:nomComplet
                            poFusionGarant:PolitesseGarant  = voRole:formulePolitesse
                            poFusionGarant:TitreLocContact  = voRole:titreBis
                            poFusionGarant:NomLocContact    = voRole:NomBis
                        .
                        assign
                            voAdresse                          = chargeAdresse({&TYPEROLE-garant}, tache.notac, piNumeroDocument)
                            poFusionGarant:AdresseGarant       = voAdresse:adresse
                            poFusionGarant:SuiteAdresseGarant  = voAdresse:complementVoie
                            poFusionGarant:CodePostalGarant    = voAdresse:codePostal
                            poFusionGarant:VilleGarant         = voAdresse:villeSansCedex()
                            poFusionGarant:PaysGarant          = voAdresse:codePays
                            poFusionGarant:faxGarant           = voAdresse:fax
                            poFusionGarant:emailGarant         = voAdresse:mail
                            poFusionGarant:villeGarant         = voAdresse:ville
                            poFusionGarant:ComplementAdresseIdentGarant = voAdresse:identAdresse
                        .
                    end.
                end.
            end.
            when {&FUSION-LstLocataireGarant} then for first tache no-lock 
                where tache.noita = piNumeroGarant:
                poFusionGarant:LstLocataireGarant = caps(outilTraduction:getLibelle(000250)) + chr(9) + outilFormatage:getNomTiers({&TYPEROLE-locataire}, tache.nocon) + chr(10)
                                                  + caps(outilTraduction:getLibelle(105414)) + chr(9) + tache.tpfin                                                    + chr(10)
                                                  + caps(outilTraduction:getLibelle(105430)) + chr(9) + outilTraduction:getLibelleParam("TPACT", tache.pdges)          + chr(10)
                                                  + caps(outilTraduction:getLibelle(103650)) + chr(9) + dateToCharacter(tache.dtdeb)                                   + chr(10)
                                                  + caps(outilTraduction:getLibelle(103651)) + chr(9) + dateToCharacter(tache.dtfin)                                   + chr(10)
                                                  + caps(outilTraduction:getLibelle(703468)) + chr(9) + montantToCharacter(tache.mtreg, true).
            end.
        end case.
    end.
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.
