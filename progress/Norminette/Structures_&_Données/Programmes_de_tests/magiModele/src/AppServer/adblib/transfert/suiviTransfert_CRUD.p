/*------------------------------------------------------------------------
File        : suiviTransfert_CRUD.p
Purpose     : 
Author(s)   : Kantena 2017/11/22
Notes       : ancien l_svtrf_ext.p
  ----------------------------------------------------------------------*/
using parametre.pclie.parametrageComptabilisationEchus.
using parametre.pclie.parametragePeriodiciteQuittancement.
using parametre.pclie.parametrageFournisseurLoyer.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure getInfoTransfert:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui renvoie les informations sur un traitement pour le QUIT:
             - Mois de quittancement en cours
             - premier mois modifiable
             - no d'ordre du dernier transfert
             - premier mois modifiable pour les echus (AGF)

    Paramètre d'Entrée  :  (1) = code traitement 
    Paramètre de Sortie :  (1)  = Booléen d'existence
                           (2)  = mois de quittancement en cours
                           (3)  = premier mois modifiable
                           (4)  = no du dernier traitement
                           (5)  = premier mois modifiable pour les échus 
    Notes  :
    ------------------------------------------------------------------------------*/
    define input        parameter pcCodeTraitement as character no-undo.
    define input-output parameter poCollection     as class collection no-undo.
    define variable voFournisseurLoyer             as class parametrageFournisseurLoyer no-undo.
    define variable voPeriodiciteQuittancement     as class parametragePeriodiciteQuittancement no-undo.

/**
    /* GESTION QUITTANCEMENT */
    run calculTransfert ("QUIT", input-output poCollection).
    // Recherche si Quittancement Trimestriel
    poCollection:set("iMoisPeriodicite", 1).  // todo  A supprimer assigné 2 lignes plus bas.
    voPeriodiciteQuittancement = new parametragePeriodiciteQuittancement().
    poCollection:set("iMoisPeriodicite", voPeriodiciteQuittancement:periodiciteQuittancement()). /* Quitt Trimestriel */
    delete object voPeriodiciteQuittancement.

    /* GESTION QUITTANCEMENT FOURNISSEUR LOYER */
    voFournisseurLoyer = new parametrageFournisseurLoyer().
    if voFournisseurLoyer:isOuvert()
    then do:
        poCollection:set("iMoisPeriodicite", if voFournisseurLoyer:isQuittanceMensuel() then 1 else 3).
        run calculTransfert ("QUFL", input-output poCollection).
    end.
    delete object voFournisseurLoyer.
**/
    if pcCodeTraitement = "QUIT" then do:   // GESTION QUITTANCEMENT
        // Recherche si Quittancement Trimestriel
        poCollection:set("iMoisPeriodicite", 1).
        voPeriodiciteQuittancement = new parametragePeriodiciteQuittancement().
        poCollection:set("iMoisPeriodicite", voPeriodiciteQuittancement:periodiciteQuittancement()). // Quitt Trimestriel
        delete object voPeriodiciteQuittancement.
        run calculTransfert (pcCodeTraitement, input-output poCollection).
    end.
    else if pcCodeTraitement = "QUFL" then do:    // GESTION QUITTANCEMENT FOURNISSEUR LOYER
        voFournisseurLoyer = new parametrageFournisseurLoyer().
        if voFournisseurLoyer:isOuvert() then do:
            poCollection:set("iMoisPeriodicite", if voFournisseurLoyer:isQuittanceMensuel() then 1 else 3).
            run calculTransfert (pcCodeTraitement, input-output poCollection).
        end.
        delete object voFournisseurLoyer.
    end.

end procedure.

procedure calculTransfert private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input        parameter pcCodeTraitement as character no-undo.
    define input-output parameter poCollection     as class collection no-undo.

    define variable voComptabilisationEchus  as class parametrageComptabilisationEchus no-undo.
    define variable viMoisQuittance          as integer   no-undo.
    define variable viMoisModifiable         as integer   no-undo.
    define variable viMoisPrecedent          as integer   no-undo.
    define variable viNumeroDernierTransfert as integer   no-undo.
    define variable vlEchu                   as logical   no-undo.
    define variable viMoisMEchu              as integer   no-undo.
    define variable viAnneePrecedente        as integer   no-undo.
    define variable viNumeroMoisPrecedent    as integer   no-undo.
    define buffer svtrf for svtrf.

    case pcCodeTraitement:
        when "QUIT" or when "QUFL" then do:
            // Recherche si Validation separee des echus
            assign
                voComptabilisationEchus = new parametrageComptabilisationEchus()
                vlEchu                  = voComptabilisationEchus:isValidationEchuSepare()
            .
            delete object voComptabilisationEchus.
            
            // Lecture Mois de quittancement en cours
            find first svtrf no-lock
                 where svtrf.cdtrt = pcCodeTraitement
                   and svtrf.noord = 0 no-error.
            if not available svtrf then do:
                poCollection:set("viTrouve", 0). // Pas Trouve.
                return.
            end.
            assign
                viMoisQuittance          = svtrf.mstrt
                viNumeroDernierTransfert = svtrf.noder
                /* Lecture phases Mois de quittancement precedent, pour Recherche du premier mois modifiable standard et échus */
                viAnneePrecedente        = truncate(svtrf.mstrt / 100, 0)
                viNumeroMoisPrecedent    = (svtrf.mstrt modulo 100) - poCollection:getInteger("iMoisPeriodicite")
            .
            if viNumeroMoisPrecedent < 01 
            then assign
                viAnneePrecedente     = viAnneePrecedente - 1
                viNumeroMoisPrecedent = viNumeroMoisPrecedent + 12
            .
            assign 
                viMoisModifiable = viMoisQuittance 
                viMoisMEchu      = viMoisQuittance
                viMoisPrecedent  = viAnneePrecedente * 100 + viNumeroMoisPrecedent
            .
boucle:
            /* boucle sur les traitements du mois precedent */
            for each svtrf no-lock
               where svtrf.cdtrt = pcCodeTraitement
                 and svtrf.noord > 0 
                 and svtrf.mstrt = viMoisPrecedent
                 and svtrf.ettrf = "F"   /* transfert Fini */
                by svtrf.nopha descending:
                if svtrf.nopha = "N99" then leave boucle. /* Mois precedent termine */

                else if svtrf.nopha = "N98" then do:
                    viMoisModifiable = viMoisPrecedent.  /* Mois precedent termine pour les echus modifiable en standard */
                    leave boucle.
                end.
                else assign /* Mois precedent pas encore valide */
                    viMoisModifiable = viMoisPrecedent
                    viMoisMEchu      = viMoisPrecedent
                .
            end.

            if not vlEchu then viMoisMEchu = viMoisModifiable.
            // Affectation des variables de retour.
            poCollection:set("iTrouve", 3). // Pas Trouve.
            if pcCodeTraitement = "QUIT" then do:
                poCollection:set("GlMoiQtt", viMoisQuittance).
                poCollection:set("GlMoiMdf", viMoisModifiable).
                poCollection:set("NoDerTrt", viNumeroDernierTransfert).
                poCollection:set("GlMoiMEc", viMoisMEchu).
            end.
            else do:
                poCollection:set("GlMflQtt", viMoisQuittance).
                poCollection:set("GlMflMdf", viMoisModifiable).
                poCollection:set("NoDerTrt", viNumeroDernierTransfert).
                poCollection:set("GlMoiMEc", viMoisMEchu).
            end.
        end.
    end case.
end procedure.

procedure calculTransfertAppelExterne:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
gga creation pour besoin test
mais pourquoi getInfoTransfert fait appel calculTransfert 2 fois en mode QUIT et en mode QUFL. Du coup les variables maj dans POCollection au 
prmeier passage sont effaces au second passage (si meme nom) + correction bug dans le calcul.          
    ------------------------------------------------------------------------------*/
    define input-output parameter poCollection as class collection no-undo.
    
    define variable voPeriodiciteQuittancement as class parametragePeriodiciteQuittancement no-undo.
    define variable voComptabilisationEchus    as class parametrageComptabilisationEchus    no-undo.
    
    define variable viMoisQuittance          as integer   no-undo.
    define variable viMoisModifiable         as integer   no-undo.
    define variable viMoisPrecedent          as integer   no-undo.
    define variable viNumeroDernierTransfert as integer   no-undo.
    define variable vlEchu                   as logical   no-undo.
    define variable viMoisMEchu              as integer   no-undo.
    define variable viAnneePrecedente        as integer   no-undo.
    define variable viNumeroMoisPrecedent    as integer   no-undo.
    define variable vcCodeTraitement         as character no-undo.
    
    define buffer svtrf for svtrf.

    vcCodeTraitement = poCollection:getCharacter("cCodeTraitement").

    case vcCodeTraitement:
        when "QUIT" or when "QUFL" then do:
            // Recherche si Validation separee des echus
            assign
                voComptabilisationEchus = new parametrageComptabilisationEchus()
                vlEchu                  = voComptabilisationEchus:isValidationEchuSepare()
            .
            delete object voComptabilisationEchus.

            if vcCodeTraitement = "QUIT"
            then do: 
                voPeriodiciteQuittancement = new parametragePeriodiciteQuittancement().
                poCollection:set("iMoisPeriodicite", voPeriodiciteQuittancement:getNombreMoisQuittance()).
                delete object voPeriodiciteQuittancement.
            end.
            else do:
                // todo 
            end.    
            
            // Lecture Mois de quittancement en cours
            find first svtrf no-lock
                 where svtrf.cdtrt = vcCodeTraitement
                   and svtrf.noord = 0 no-error.
            if not available svtrf then do:
                poCollection:set("viTrouve", 0). // Pas Trouve.
                return.
            end.
            assign
                viMoisQuittance          = svtrf.mstrt
                viNumeroDernierTransfert = svtrf.noder
                /* Lecture phases Mois de quittancement precedent, pour Recherche du premier mois modifiable standard et échus */
                viAnneePrecedente        = truncate(svtrf.mstrt / 100, 0)
                viNumeroMoisPrecedent    = (svtrf.mstrt modulo 100) - poCollection:getInteger("iMoisPeriodicite")
            .
            if viNumeroMoisPrecedent < 01 
            then assign
                viAnneePrecedente     = viAnneePrecedente - 1
                viNumeroMoisPrecedent = viNumeroMoisPrecedent + 12
            .
            assign 
                viMoisModifiable = viMoisQuittance 
                viMoisMEchu      = viMoisQuittance
                viMoisPrecedent  = viAnneePrecedente * 100 + viNumeroMoisPrecedent. 
            .
boucle:
            /* boucle sur les traitements du mois precedent */
            for each svtrf no-lock
               where svtrf.cdtrt = vcCodeTraitement
                 and svtrf.noord > 0 
                 and svtrf.mstrt = viMoisPrecedent
                 and svtrf.ettrf = "F"   /* transfert Fini */
                by svtrf.nopha descending:
                if svtrf.nopha = "N99" then leave boucle. /* Mois precedent termine */

                else if svtrf.nopha = "N98" then do:
                    viMoisModifiable = viMoisPrecedent.  /* Mois precedent termine pour les echus modifiable en standard */
                    leave boucle.
                end.
                else assign /* Mois precedent pas encore valide */
                    viMoisModifiable = viMoisPrecedent
                    viMoisMEchu      = viMoisPrecedent
                .
            end.
            if not vlEchu then viMoisMEchu = viMoisModifiable.
            // Affectation des variables de retour.
            poCollection:set("iTrouve", 3). // Pas Trouve.
            if vcCodeTraitement = "QUIT" then do:
                poCollection:set("GlMoiQtt", viMoisQuittance).
                poCollection:set("GlMoiMdf", viMoisModifiable).
                poCollection:set("NoDerTrt", viNumeroDernierTransfert).
                poCollection:set("GlMoiMEc", viMoisMEchu).
            end.
            else do:
                poCollection:set("GlMflQtt", viMoisQuittance).
                poCollection:set("GlMflMdf", viMoisModifiable).
                poCollection:set("NoDerTrt", viNumeroDernierTransfert).
                poCollection:set("GlMoiMEc", viMoisMEchu).
            end.
        end.
    end case.
end procedure.
