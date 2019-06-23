/*-----------------------------------------------------------------------------
File        : majoff01.p
Purpose     : mise a jour de l'offre de location d'un appartement a partir de sa 1ere quittance dans equit
Author(s)   : SY 16/03/1999    -     GGA 2018/09/18
Notes       : reprise de adb/src/bien/majoff01.p
------------------------------------------------------------------------------*/
{preprocesseur/nature2contrat.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{outils/include/lancementProgramme.i}        // fonctions lancementPgm, suppressionPgmPersistent

define variable goCollectionHandlePgm as class collection no-undo.
define variable ghProc         as handle  no-undo.
define variable giNumeroBail   as int64   no-undo.
define variable giNumeroMandat as int64   no-undo.
define variable giNumeroUL     as integer no-undo.

procedure lancementMajoff01:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter poCollectionContrat as class collection no-undo.

    assign
        giNumeroBail          = poCollectionContrat:getInt64("iNumeroContrat")
        giNumeroMandat        = truncate(giNumeroBail / 100000, 0)
        giNumeroUL            = truncate((giNumeroBail modulo 100000) / 100, 0)  // integer(substring(string(giNumeroContrat, "9999999999"), 6 ,3))             
        goCollectionHandlePgm = new collection()
    .
    run trtMajoff01.
    suppressionPgmPersistent(goCollectionHandlePgm).

end procedure.

procedure trtMajoff01 private:
    /*------------------------------------------------------------------------------
    Purpose: 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define variable vcListeRubrique as character no-undo.
    define variable viNbMoisPeriode as integer   no-undo. 

    run genChaRub (output vcListeRubrique, output viNbMoisPeriode).

    if viNbMoisPeriode <> 0 and vcListeRubrique <> ""
    then do: 
        ghProc = lancementPgm("adb/bien/majofflc.p", goCollectionHandlePgm).
        run lancementMajofflc in ghProc(giNumeroMandat, giNumeroUL, vcListeRubrique, viNbMoisPeriode).
        if mError:erreur() then return.
    end.

end procedure.

procedure genChaRub private:
    /*------------------------------------------------------------------------------
    Purpose: procedure qui genere une chaine des rubriques fixes/famille a partir de equit 
    Notes  : 
    ------------------------------------------------------------------------------*/
    define output parameter pcListeRubrique as character no-undo.
    define output parameter piNbMoisPeriode as integer   no-undo. 

    define variable viFam                       as integer   no-undo.
    define variable vcTableauRubriqueParFamille as character extent 4.    /* Tableau contenant les no de rub par famille pour l'offre de location  */
    define variable vcTableauLibelleParFamille  as character extent 4.    /* Tableau contenant les no de libell‚ par famille pour l'offre de location  */
    define variable vdTableauMontantParFamille  as decimal   extent 4.    /* Tableau contenant les cumuls des rub FIXES de la quittance par famille */
    define variable viCodeFamille               as integer   no-undo.
    define variable vcTempo                     as character no-undo.

    define buffer bxrbp for bxrbp. 
    define buffer equit for equit. 

    /* Recuperation des No Rub & No libelle des 4 Familles principales pour la mise a jour des OFFRES DE LOCATION */
    do viFam = 1 to 4:
        /* recherche du no rubrique standard */
        for first bxrbp no-lock    
            where bxrbp.ntbai = {&NATURECONTRAT-fictive}
              and bxrbp.cdfam = viFam
              and bxrbp.noord = 0
        use-index Ix_bxrbp03:
            vcTableauRubriqueParFamille[viFam] = string(bxrbp.norub,"999").
        end.
        /* recherche du no de libell‚ standard dans cette rubrique */
        for first bxrbp no-lock    
            where bxrbp.ntbai = {&NATURECONTRAT-fictive}
              and bxrbp.cdfam = viFam
               and bxrbp.noord = -1
        use-index Ix_bxrbp03:
            vcTableauLibelleParFamille[viFam] = string(bxrbp.nolib,"99").
        end.
    end.

    for first equit no-lock
        where equit.noloc = giNumeroBail:
        piNbMoisPeriode = integer(substring(equit.pdqtt, 1, 3)).
        do viFam = 1 to equit.nbrub:
            if equit.tbgen[viFam] = "00001" and equit.tbfam[viFam] <= 4 
            then assign 
                     viCodeFamille = equit.tbfam[viFam]
                     vdTableauMontantParFamille[viCodeFamille] = vdTableauMontantParFamille[viCodeFamille] + equit.tbtot[viFam]
            .
        end.
        do viFam = 1 to 4:
            vcTempo = substitute("&1@&2@&3", vcTableauRubriqueParFamille[viFam], vcTableauLibelleParFamille[viFam], vdTableauMontantParFamille[viFam]).
            if pcListeRubrique = "" 
            then pcListeRubrique = vcTempo.
            else pcListeRubrique = pcListeRubrique + "|" + vcTempo.        
        end.
    end.

end procedure.
