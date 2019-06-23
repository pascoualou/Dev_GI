/*------------------------------------------------------------------------
File        : majzone.i
Purpose     :
Author(s)   : kantena - 2016/12/06
Created     : Tue Dec 06 10:00:14 CET 2016
Notes       : TODO: Est-ce utilisé ????? - calrevlo.p
------------------------------------------------------------------------*/

function recTaudev returns decimal private().
    /*--------------------------------------------------------------------------
    Purpose: pour renvoyer 1 ou le Taux de conversion suivant que GlDevEdi soit egal a ou different de GlDevRef
    Note   :
    ---------------------------------------------------------------------------*/
    define buffer isoc  for isoc.
    define buffer idev  for idev.

    define variable voActivationEuro as class parametrageActivationEuro no-undo.

    voActivationEuro = new parametrageActivationEuro().
    if voActivationEuro:isEuroActif()
    then do:
        /* On retourne le taux si pas bascule sinon 1/taux */
        find first idev no-lock
            where idev.soc-cd = mToken:iCodeSociete
              and idev.dev-cd = "FRF" no-error.
        if available idev then return 1 / idev.cours.
    end.
    for first isoc no-lock
        where isoc.soc-cd = mToken:iCodeSociete:
        return isoc.tx-euro.    // si pas de parametre: on considere que la bascule n'est pas faite
    end.
    return 1.
end function.

function miseAJourZon returns character private(pcChaineFrom as character, pcTypeTache as character, pdeTauxDevise as decimal):
    /*--------------------------------------------------------------------------
    Purpose:
    Note   :
    ---------------------------------------------------------------------------*/
    define variable icpt         as integer   no-undo.
    define variable cOccurrence1 as character no-undo.
    define variable cOccurrence2 as character no-undo.
    define variable cChaineTo    as character no-undo.

    /* Dans tous les cas, on affecte avec la valeur devise avec la zone normale */
    cChaineTo = pcChaineFrom.
    /* Apres : On traite les taches spécifiques au cas par cas */
    case pcTypeTache:
        when {&TYPETACHE-majorationMermaz} then do:
            entry(1, cChaineTo, "#") = trim(string(decimal(entry(1, pcChaineFrom, "#")) / pdeTauxDevise, "->>>>>>>>>9.99")).
            entry(2, cChaineTo, "#") = trim(string(decimal(entry(2, pcChaineFrom, "#")) / pdeTauxDevise, "->>>>>>>>>9.99")).
            do iCpt = 3 to num-entries(pcChaineFrom, "#"):
                assign
                    cOccurrence1                = entry(iCpt, pcChaineFrom, "#")
                    cOccurrence2                = entry(iCpt, pcChaineFrom, "#")
                    entry(2, cOccurrence1, "@") = trim(string(decimal(entry(2, cOccurrence2, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
                    entry(3, cOccurrence1, "@") = trim(string(decimal(entry(3, cOccurrence2, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
                    entry(iCpt, cChaineTo, "#") = cOccurrence1
                .
            end.
        end.
        when {&TYPETACHE-empruntISF} then do iCpt = 1 to num-entries(pcChaineFrom, "&"):
            assign
                cOccurrence1                = entry(iCpt, pcChaineFrom, "&")
                cOccurrence2                = entry(iCpt, pcChaineFrom, "&")
                entry(2, cOccurrence1, "@") = trim(string(integer(entry(2, cOccurrence2, "@")) / pdeTauxDevise, "->>>>>>>>>>>9"))
                entry(3, cOccurrence1, "@") = trim(string(integer(entry(3, cOccurrence2, "@")) / pdeTauxDevise, "->>>>>>>>>>>9"))
                entry(4, cOccurrence1, "@") = trim(string(integer(entry(4, cOccurrence2, "@")) / pdeTauxDevise, "->>>>>>>>>>>9"))
                entry(iCpt, cChaineTo, "&") = cOccurrence1
            .
        end.
        when {&TYPETACHE-eauChaude}  or when {&TYPETACHE-eauChaudeGerance} 
        or when {&TYPETACHE-eauFroide} or when {&TYPETACHE-eauFroideGerance} 
        or when {&TYPETACHE-thermie}    or when {&TYPETACHE-thermieGerance}
        or when {&TYPETACHE-electricite} or when {&TYPETACHE-frigorie}  or when {&TYPETACHE-uniteEvaporation}
        then assign
            entry(1, cChaineTo, "@") = trim(string(decimal(entry(1, pcChaineFrom, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
            entry(2, cChaineTo, "@") = trim(string(decimal(entry(2, pcChaineFrom, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
        .
        when {&TYPETACHE-bareme} then if num-entries(pcChaineFrom, "&") > 1
        then assign
            entry(1, cChaineTo, "&") = trim(string(decimal(entry(1, pcChaineFrom, "&")) / pdeTauxDevise, "->>>>>>>>>9.99"))
            entry(2, cChaineTo, "&") = trim(string(decimal(entry(2, pcChaineFrom, "&")) / pdeTauxDevise, "->>>>>>>>>9.99"))
        .
        when {&TYPETACHE-honoraireSyndic} then do iCpt = 1 to num-entries(pcChaineFrom, "#"):
            assign
                cOccurrence1                = entry(iCpt, pcChaineFrom, "#")
                cOccurrence2                = entry(iCpt, pcChaineFrom, "#")
                entry(2, cOccurrence1, "@") = trim(string(decimal(entry(2, cOccurrence2, "@")) / pdeTauxDevise, "->>>>>>>>>>>9.99"))
                entry(iCpt, cChaineTo, "#") = cOccurrence1
            .
        end.
        when {&TYPETACHE-loyerContractuel} then assign
            cChaineTo = trim(string(decimal(pcChaineFrom) / pdeTauxDevise, "->>>>>>>>>>>9.99"))
        .
        when {&TYPETACHE-garantieLocataire} then do iCpt = 1 to num-entries(pcChaineFrom, chr(164)):
            assign
                cOccurrence1                      = entry(iCpt, pcChaineFrom, chr(164))
                cOccurrence2                      = entry(iCpt, pcChaineFrom, chr(164))
                entry(10, cOccurrence1, chr(177)) = trim(string(decimal(entry(10, cOccurrence2, chr(177))) / pdeTauxDevise, "->>>>>>>>>>>9.99"))
                entry(iCpt, cChaineTo, chr(164))  = cOccurrence1
            .
        end.
        when {&TYPETACHE-garantieLocative}
        then if num-entries(pcChaineFrom, "@") = 3
            then assign
                entry(1, cChaineTo, "@") = trim(string(decimal(entry(1, pcChaineFrom, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
                entry(2, cChaineTo, "@") = trim(string(decimal(entry(2, pcChaineFrom, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
            .
            else assign
                cChaineTo = trim(string(decimal(pcChaineFrom) / pdeTauxDevise, "->>>>>>>>>9.99"))
            .
        when {&TYPETACHE-droit2Bail} then assign
            cOccurrence1                   = string(decimal(entry(3, pcChaineFrom, "#")) / pdeTauxDevise, "->>>>>>>>>>>9.99")
            entry(3, cChaineTo, "#") = cOccurrence1
        .
        when {&TYPETACHE-suiviAdministratif} then if tache.tpfin = "26005"      /*--> Révision des baux */
        then assign
            entry(1, cChaineTo, "@") = trim(string(decimal(entry(1, pcChaineFrom, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
            entry(2, cChaineTo, "@") = trim(string(decimal(entry(2, pcChaineFrom, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
            entry(3, cChaineTo, "@") = trim(string(decimal(entry(3, pcChaineFrom, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
            entry(4, cChaineTo, "@") = trim(string(decimal(entry(4, pcChaineFrom, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
            entry(5, cChaineTo, "@") = trim(string(decimal(entry(5, pcChaineFrom, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
            entry(6, cChaineTo, "@") = trim(string(decimal(entry(6, pcChaineFrom, "@")) / pdeTauxDevise, "->>>>>>>>>9.99"))
        .
        when {&TYPETACHE-renouvellement} then do:
            entry(1, cChaineTo, "&") = trim(string(decimal(entry(1, pcChaineFrom, "&")) / pdeTauxDevise, "->>>>>>>>>9.99")).
            if num-entries(pcChaineFrom, "&") > 1
            then entry(2, cChaineTo, "&") =  trim(string(decimal(entry(2, pcChaineFrom, "&")) / pdeTauxDevise, "->>>>>>>>>9.99")).
        end.
    end case.
    return cChaineTo.

end function.

procedure MajZonDev private:
    /*--------------------------------------------------------------------------
    Purpose:
    Note   :
    ---------------------------------------------------------------------------*/
    tache.lbdiv-dev = miseAJourZon(tache.lbdiv, tache.tptac, RecTauDev()).

end procedure.

procedure MajZonNor private:
    /*--------------------------------------------------------------------------
    Purpose: Procedure pour la simulation du trigger EURO/DEVISE : Maj zone montants
    Note   :
    ---------------------------------------------------------------------------*/
    tache.lbdiv = miseAJourZon(tache.lbdiv-dev, tache.tptac, 1 / RecTauDev()).

end procedure.
