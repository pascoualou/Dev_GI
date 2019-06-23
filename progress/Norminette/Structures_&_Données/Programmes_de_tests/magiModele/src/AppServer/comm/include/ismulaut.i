/*-------------------------------------------------------------------------------------
File        : ismulaut.i
Purpose     : Test si multi-libellé autorisé pour un locataire et une rubrique (limitation du multi-libellé dans certains cas)
Author(s)   : SY 08/08/2007  -  GGA 2018/07/09
Notes       : reprise comm\ismulaut.i
derniere revue: 2018/07/24 - phm: 

 01  05/12/2007  SY    1207/0066 : DAUCHEZ - autoriser multi-libellé pour calendrier d'évolution (04130)
-------------------------------------------------------------------------------------*/

{preprocesseur/type2tache.i}
{preprocesseur/codeRubrique.i}

function isMultiLibelleRubAutorise returns logical private(pcTypeContrat as character, piNumeroContrat  as int64, piNumeroRubrique as integer):
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : Multi-libelle rubrique loyer interdit si
             - tache Méhaignerie/Mermaz
             - tache Echelle Mobile
             Multi-libelle rubriques Provisions interdit si
             - rub Provision 200 à 211
    ------------------------------------------------------------------------------*/
    define variable vcListeTache        as character no-undo.
    define variable viItem              as integer   no-undo.

    vcListeTache = substitute("&1,&2", {&TYPETACHE-majorationMermaz}, {&TYPETACHE-EchelleMobileLoyer}).
    if piNumeroRubrique = {&RUBRIQUE-loyer}
    then do viItem = 1 to num-entries(vcListeTache, ","):
        if can-find(first tache no-lock
                    where tache.tpcon = pcTypeContrat
                      and tache.nocon = piNumeroContrat  
                      and tache.tptac = entry(viItem, vcListeTache, ",")) then return false.
    end.
    else if piNumeroRubrique = {&RUBRIQUE-provisionCharges}
         or piNumeroRubrique = {&RUBRIQUE-provisionChauffage}
         or piNumeroRubrique = {&RUBRIQUE-provisionAscenseur}
         or piNumeroRubrique = {&RUBRIQUE-provisionGardien}
         or piNumeroRubrique = {&RUBRIQUE-provisionEauFroide}
         or piNumeroRubrique = {&RUBRIQUE-provisionEauChaude}
         or piNumeroRubrique = {&RUBRIQUE-provisionTravauxEntretien}
         or piNumeroRubrique = {&RUBRIQUE-provisionParking}
         or piNumeroRubrique = {&RUBRIQUE-provisionTennis}
         or piNumeroRubrique = {&RUBRIQUE-provisionEnergie}
         or piNumeroRubrique = {&RUBRIQUE-provisionImpotFoncier}
         or piNumeroRubrique = {&RUBRIQUE-provisionDiverse}
         then return false.

    return true.

end function.
