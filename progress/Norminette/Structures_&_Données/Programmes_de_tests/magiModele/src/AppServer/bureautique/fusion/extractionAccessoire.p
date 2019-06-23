/*-----------------------------------------------------------------------------
File        : extractionAccessoire.p
Purpose     : Recherche des donnees de fusion accessoire
Author(s)   : 
Notes       : appelé par extract.p
derniere revue:
-----------------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/type2bien.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/fusion/fusionAccessoire.i}
using bureautique.fusion.classe.fusionAccessoire.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionRole.
using bureautique.fusion.classe.fusionBanque.    // Pour fctExport.i
using parametre.pclie.parametrageRepertoireMagi. // Pour fctExport.i

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}
{comm/include/procclot.i}

procedure extractionAccessoire:
    /*------------------------------------------------------------------------------
    Purpose: Valorisation des données propres aux accessoires
    Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroAccessoire as integer   no-undo.
    define input        parameter piNumeroDocument   as integer   no-undo.
    define input        parameter pcListeChamp       as character no-undo.
    define input-output parameter poFusionAccessoire as class fusionAccessoire no-undo.

    define variable voAdresse  as class fusionAdresse no-undo.
    define variable voRole     as class fusionRole    no-undo.
    define variable vlBloc1    as logical no-undo.
    define variable viCompteur as integer no-undo.

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when {&FUSION-TypeaccessoireDomotique}                     or when {&FUSION-NomFournisseuraccessoireDomotique}         or when {&FUSION-adresseFournisseuraccessoireDomotique} 
         or when {&FUSION-SuiteadresseFournisseuraccessoireDomotique}  or when {&FUSION-CodePostalFournisseuraccessoireDomotique}  or when {&FUSION-VilleFournisseuraccessoireDomotique}
         or when {&FUSION-NoLotaccessoireDomotique}                    or when {&FUSION-NomDestinataireaccessoireDomotique}        or when {&FUSION-adresseDestinataireaccessoireDomotique} 
         or when {&FUSION-SuiteadresseDestinataireaccessoireDomotique} or when {&FUSION-CodePostalDestinataireaccessoireDomotique} or when {&FUSION-VilleDestinataireaccessoireDomotique}
         or when {&FUSION-NumSerieaccessoireDomotique}                 or when {&FUSION-MontantCautionaccessoireDomotique}         or when {&FUSION-DateRemiseaccessoireDomotique}
         or when {&FUSION-DateRestitutionaccessoireDomotique}          or when {&FUSION-CommentaireaccessoireDomotique}            or when {&FUSION-BatimententreeescalierDomotique} 
         or when {&FUSION-ComplementAdresseIdentDestinataireAccessoireDomotique} or when {&FUSION-ComplementAdresseIdentFournisseurAccessoireDomotique}  /* PL : 11/01/2016 - (Fiche : 0711/0069) */
            then do:
                if vlBloc1 then next boucleCHamp.
                vlBloc1 = true.
                find tache no-lock
                   where tache.noita = piNumeroAccessoire no-error.
                if available tache then do:
                    find first roles no-lock 
                         where roles.tprol = tache.dcreg
                           and roles.notie = integer(tache.pdges) no-error.
                    if available roles then do:
                        assign
                            poFusionAccessoire:NoLotaccessoireDomotique           = tache.tpfin
                            poFusionAccessoire:NumSerieaccessoireDomotique        = tache.ntreg
                            poFusionAccessoire:MontantCautionaccessoireDomotique  = montantToCharacter(decimal(tache.pdreg),true)
                            poFusionAccessoire:DateRemiseaccessoireDomotique      = dateToCharacter(tache.dtdeb)
                            poFusionAccessoire:DateRestitutionaccessoireDomotique = dateToCharacter(tache.dtfin)
                            poFusionAccessoire:CommentaireaccessoireDomotique     = trim(tache.lbdiv)
                        .
                        assign
                            voRole = chargeRole(roles.tprol, roles.norol, piNumeroDocument)
                            poFusionAccessoire:NomDestinataireaccessoireDomotique = voRole:nomComplet
                        .
                        assign
                            voAdresse                                                      = chargeAdresse(roles.tprol, roles.norol, piNumeroDocument)
                            poFusionAccessoire:adresseDestinataireaccessoireDomotique      = voAdresse:adresse
                            poFusionAccessoire:SuiteadresseDestinataireaccessoireDomotique = voAdresse:complementVoie
                            poFusionAccessoire:CodePostalDestinataireaccessoireDomotique   = voAdresse:codePostal
                            poFusionAccessoire:VilleDestinataireaccessoireDomotique        = voAdresse:ville
                            poFusionAccessoire:ComplementAdresseIdentDestinataireAccessoireDomotique = voAdresse:identAdresse. /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                        .
                    end.
                    find tache no-lock
                       where tache.noita = integer(tache.tpges) no-error.
                    if available tache then do:
                        assign
                            poFusionAccessoire:BatimententreeescalierDomotique = (if tache.tpges = ""
                                                                                  then "" else (outilTraduction:getLibelle(100609) + " " + TRIM(tache.tpges) + " ")) +
                                                                                 (if tache.cdhon = ""
                                                                                  then "" else (outilTraduction:getLibelle(100188) + " " + TRIM(tache.cdhon) + " ")) +
                                                                                 (if tache.tphon = ""
                                                                                  then "" else (outilTraduction:getLibelle(100610) + " " + TRIM(tache.tphon) + " "))
                            poFusionAccessoire:TypeaccessoireDomotique = tache.tpfin
                        .
                        assign
                            voRole = chargeRole("FOU", integer(tache.pdges), piNumeroDocument)
                            poFusionAccessoire:NomFournisseuraccessoireDomotique = voRole:nomComplet
                        .
                        assign
                            voAdresse = chargeAdresse("FOU", integer(tache.pdges), piNumeroDocument)
                            poFusionAccessoire:adresseFournisseuraccessoireDomotique      = voAdresse:adresse
                            poFusionAccessoire:SuiteadresseFournisseuraccessoireDomotique = voAdresse:complementVoie
                            poFusionAccessoire:CodePostalFournisseuraccessoireDomotique   = voAdresse:codePostal
                            poFusionAccessoire:VilleFournisseuraccessoireDomotique        = voAdresse:ville
                            poFusionAccessoire:ComplementAdresseIdentFournisseurAccessoireDomotique = voAdresse:identAdresse /* PL : 11/01/2016 - (Fiche : 0711/0069) */
                        .
                    end.
                end.
                
            end.
        end.
    end.
    delete object voAdresse no-error.
    delete object voRole    no-error.

end procedure.