/*------------------------------------------------------------------------
File        : prccoros.i
Purpose     : Procedure pour rechercher les correspondances des organismes sociaux Pégase
Author(s)   : SY 26/02/2014 -  GGA 2017/11/13
Notes       : reprise comm\prccoros.i pour l'instant seulement reprise de PrcLibTypeOrg
derneire revue: 2018/04/10 - phm: OK

01 28/03/2014  SY    Ajout PrcLibTypeOrg
02 30/03/2015  JPM   Ajout compte 6413 (IJSS)
03 28/04/2015  JPM   Ajout compte 6333 (formation)
04 31/05/2016  JPM   Ajout compte 6415 (Indemnités prévoyance
05 24/02/2017  SY    0117/0232 Ajout Nl organisme MSA = nnM0 (ex : 33M0)
06 02/03/2017  JPM   0117/0232 Ajout compte 645010 (MSA)
----------------------------------------------------------------------*/

function getLibelleTypeOrganisme return character private(pcIdentifiant as character):
    /*------------------------------------------------------------------------------
    Purpose: retour libelle type organisme (ancienne procedure prcLibTypOrg ) 
    Notes  : 
    ------------------------------------------------------------------------------*/
    if pcIdentifiant begins  "I"   then return outilTraduction:getLibelle(103635).   // Taxe/salaire
    if pcIdentifiant begins  "M"   then return outilTraduction:getLibelle(110155).   // Mutuelle
    if pcIdentifiant begins  "P"   then return outilTraduction:getLibelle(110156).   // Prévoyance
    if pcIdentifiant begins  "R"   then return outilTraduction:getLibelle(1000488).  // Retraite
    if pcIdentifiant begins  "U"   then return outilTraduction:getLibelle(103482).   // URSSAF
    if pcIdentifiant matches "*M0" then return outilTraduction:getLibelle(705605).   // SY Nl organisme MSA
    return "".
end function.

function getNomOrganisme returns character private(pcReference as character, pcCodeOrganisme as character):
    /*------------------------------------------------------------------------------
    Purpose: retourne le nom du centre
    Notes  :
    ------------------------------------------------------------------------------*/
    define variable vcCollCle as character no-undo.
    define variable voCorrespondance as class parametrageCorrespondance no-undo.

    voCorrespondance = new parametrageCorrespondance(pcReference, pcCodeOrganisme).
    /* recherche si correspondance (normalement UNIQUE) existe */
    if pcCodeOrganisme begins "R"
    then vcCollCle = "ORT".
    else if (pcCodeOrganisme begins "P" or pcCodeOrganisme begins "M")
    then vcCollCle = "ODC".
    else if pcCodeOrganisme begins "U"
    then vcCollCle = "OSS".
    else if pcCodeOrganisme begins "I"
    then vcCollCle = "ORP".
    else if pcCodeOrganisme matches "*M0"
    then vcCollCle = "OMS".                               /* SY Nl organisme MSA */
    else mLogger:writeLog(1, "getNomCentre: type d'organisme non géré: " + pcCodeOrganisme).
    return voCorrespondance:getNomCentre(vcCollCle).

end function.
