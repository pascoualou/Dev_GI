/*------------------------------------------------------------------------
    File        : extractionAccordReglement.p
    Purpose     : 
    Syntax      :
    Description : 
    Author(s)   : kantena
    Created     : Tue Jan 15 17:30:39 CET 2019
    Notes       :
  ----------------------------------------------------------------------*/
{preprocesseur/famille2tiers.i}
{preprocesseur/listeRubQuit2TVA.i}
{preprocesseur/type2bien.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2contrat.i}
{preprocesseur/type2intervention.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}
{preprocesseur/fusion/fusionAccordReglement.i}
using bureautique.fusion.classe.fusionAccordreglement.
using bureautique.fusion.classe.fusionAdresse.
using bureautique.fusion.classe.fusionRole.
using bureautique.fusion.classe.fusionBanque.    // Pour fctExport.i
using parametre.pclie.parametrageRepertoireMagi. // Pour fctExport.i

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{application/include/glbsepar.i}
{bureautique/fusion/include/fctexport.i}
{bureautique/fusion/include/decodorg.i}


procedure AccordReglement:
    /*------------------------------------------------------------------------------
    Purpose: Valorisation des données propres aux accords de réglement
    Notes: service utilisé par extraction.p
    ------------------------------------------------------------------------------*/
    define input        parameter piNumeroAccordReglement as integer   no-undo.
    define input        parameter piNumeroBail            as integer   no-undo.
    define input        parameter pcListeChamp            as character no-undo.
    define input-output parameter poFusionAccordReglement as class fusionAccordReglement no-undo.

    define variable viNombreEcheance as integer no-undo.
    define variable viCompteur       as integer no-undo.
    define variable vlBloc1          as logical no-undo.

boucleCHamp:
    do viCompteur = 1 to num-entries(pcListeChamp):
        case entry(viCompteur, pcListeChamp):
            when "109011" or when "109012" or when "109013" or when "109014" or when "109015" or when "109016" 
            then do:
                if vlBloc1 then next boucleCHamp.
                vlBloc1 = true.
                /* Périodicité de paiement */
                find first tache no-lock
                     where tache.TpTac = "04029"
                       and tache.tpcon = "01033"
                       and tache.nocon = piNumeroBail no-error.
                if available tache then poFusionAccordReglement:PeriodiciteMoratoire = outilTraduction:getLibelleParam("PDQTT", tache.pdges).

                /* Moratoire */
                find Acreg no-lock
                   where acreg.tpcon = "01065"
                     and acreg.nocon = piNumeroAccordReglement
                    and acreg.tplig = "0" no-error.
                if available acreg then do:
                    assign
                        poFusionAccordReglement:MontantMoratoire = montantToCharacter(acreg.mtini, true)
                        viNombreEcheance = 0
                    .
                    for each acreg no-lock
                       where acreg.tpcon = "01065"
                         and acreg.nocon = piNumeroAccordReglement
                         and acreg.tplig = "1"
                       break by acreg.dtech:
                        if first(acreg.dtech) then poFusionAccordReglement:DateDebutMoratoire = dateToCharacter(acreg.dtech).
                        if last(acreg.dtech)  then poFusionAccordReglement:DateFinMoratoire   = dateToCharacter(acreg.dtech).
                        assign
                            /* Nombre d'échéance */
                            viNombreEcheance = viNombreEcheance + 1.
                            /* Détail des échéances */
                            poFusionAccordReglement:DetailEcheanceMoratoire = poFusionAccordReglement:DetailEcheanceMoratoire +
                                                      (if poFusionAccordReglement:DetailEcheanceMoratoire = "" then "" else chr(10)) +
                                                      dateToCharacter(acreg.dtech) + CHR(9) + montantToCharacter(acreg.mtech,true)
                        .
                    end.
                    poFusionAccordReglement:NbEcheanceMoratoire = string(viNombreEcheance).
                end.
            end.
        end.
    end.
end procedure.