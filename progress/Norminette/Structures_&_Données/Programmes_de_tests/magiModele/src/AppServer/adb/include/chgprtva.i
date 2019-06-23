/*-----------------------------------------------------------------------------
File        : chgprtva.i
Purpose     : Interface de chargement de la periode de TVA d'un mandat
Author(s)   : LG - 1998/03/18, Kantena - 2018/01/11 
Notes       : vient de adb/src/cpta/chgprtva.p
derniere revue: 2018/04/25 - phm: OK

01  24/12/2004  DM    fiche 0804/0095: retourne 'A' pour Annuel forfait et normal
-----------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/codePeriode.i}

function getPeriodeTVA2Mandat returns character(piNumeroMandat as integer):
    /*-----------------------------------------------------------------------------
    Purpose:
    Notes: anciennement chgprtva
    -----------------------------------------------------------------------------*/
    define buffer ctrat for ctrat.
    define buffer tache for tache.

    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroMandat
      , last tache no-lock
        where tache.tptac = {&TYPETACHE-TVA}
          and tache.tpcon = ctrat.Tpcon
          and tache.nocon = ctrat.Nocon:
        case tache.pdges:
            when {&PERIODICITEGESTION-mensuel}       then return "M".
            when {&PERIODICITEGESTION-trimestriel}   then return "T".
            when {&PERIODICITEGESTION-annuelNormal}
         or when {&PERIODICITEGESTION-annuelForfait} then return "A".
        end case.
    end.
    return "".
end function.
