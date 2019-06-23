/*------------------------------------------------------------------------
File        : outilContrat.p
Purpose     : 
Author(s)   : GGA  -  2019/01/07
Notes       : 
------------------------------------------------------------------------*/
{preprocesseur/type2adresse.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

function getVilleCabinet returns character(pcCodeNatureContrat as character, pcCodeTypeContrat as character, piNumeroContrat as int64):
    /*------------------------------------------------------------------------------
    Purpose: recuperation de la ville du cabinet/gerant (anciennement recVilCab)
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define buffer sys_pg for sys_pg.
    define buffer intnt  for intnt.
    define buffer iLienAdresse  for iLienAdresse.
    define buffer iBaseAdresse  for iBaseAdresse.

    for first sys_pg no-lock
        where sys_pg.tppar = "R_CR1"
          and sys_pg.zone1 = pcCodeNatureContrat
          and sys_pg.zone7 <> "P"
      , last intnt no-lock
        where intnt.tpcon = pcCodeTypeContrat
          and intnt.nocon = piNumeroContrat
          and intnt.tpidt = sys_pg.zone2
      , first iLienAdresse no-lock
        where iLienAdresse.cTypeIdentifiant   = sys_pg.zone2
          and iLienAdresse.iNumeroIdentifiant = intnt.noidt
          and iLienAdresse.cTypeAdresse       = {&TYPEADRESSE-Principale}
      , first iBaseAdresse no-lock
        where iBaseAdresse.iNumeroAdresse = iLienAdresse.iNumeroAdresse:
        return iBaseAdresse.cVille.
    end.
    return ?.
end function.
