/*------------------------------------------------------------------------
File        : filtrelo.i
Purpose     : 
Author(s)   : kantena  -  2017/11/27 
Notes       : vient de adb/comm/filtrelo.i
              rajouter using parametre.pclie.parametrageProlongationExpiration
              et preprocesseur referenceClient.i.
------------------------------------------------------------------------*/
procedure filtreLoc:
    /*--------------------------------------------------------------------------- 
    Purpose : Procédures de recherche si un locataire est concerné par un mois de quittancement
    Notes   :
    ---------------------------------------------------------------------------*/ 
    define input  parameter pdaDebutPeriodeQuittancement  as date     no-undo.
    define input  parameter piNumeroContrat               as int64    no-undo.
    define output parameter plTaciteReconduction          as logical  no-undo.
    define output parameter pdaFinBail                    as date     no-undo.
    define output parameter pdaSortieLocataire            as date     no-undo.
    define output parameter pdaResiliationBail            as date     no-undo.
    define output parameter plTransfertQuittanceLocataire as logical  no-undo.
    define output parameter pdaFinApplicationRubrique     as date     no-undo.  // DtMaxQtt
    
    define variable voProlongationExpiration  as class parametrageProlongationExpiration no-undo.
    define buffer tache for tache.
    define buffer ctrat for ctrat.

    plTransfertQuittanceLocataire = yes.
    /* Recherche de la date de Sortie du Locataire */
    find last tache no-lock
        where tache.tpTac = {&TYPETACHE-quittancement}
          and tache.tpCon = {&TYPECONTRAT-bail}
          and tache.noCon = piNumeroContrat no-error.
    if available tache then pdaSortieLocataire = tache.dtFin.
    /* Recherche de la date de résiliation du bail */
    find first ctrat no-lock
        where ctrat.tpCon = {&TYPECONTRAT-bail}
          and ctrat.noCon = piNumeroContrat no-error.
    if available ctrat then assign 
        pdaFinBail           = ctrat.dtFin
        pdaResiliationBail   = ctrat.dtRee
        plTaciteReconduction = (ctrat.tpRen = "00001")
    .
    /* Specifique manpower: On ne tient pas compte de la date de fin de bail pour calculer la date de fin d'application de la rubrique */
    if integer(mtoken:icodeSociete) = {&REFCLIENT-MANPOWER} then pdaFinBail = 12/31/2299.     /* Ajout SY le 14/10/2013 */
    /* Prendre la plus petite des dates... */
    if pdaSortieLocataire <> ? and pdaResiliationBail <> ?
    then pdaFinApplicationRubrique = minimum(pdaSortieLocataire, pdaResiliationBail).
    else do:
        if pdaResiliationBail <> ? then pdaFinApplicationRubrique = pdaResiliationBail.
        if pdaSortieLocataire <> ? then pdaFinApplicationRubrique = pdaSortieLocataire.
    end.
    if not plTaciteReconduction then do:
        voProlongationExpiration = new parametrageProlongationExpiration().
        if voProlongationExpiration:isQuittancementProlonge() then do:
            if pdaFinApplicationRubrique = ?
            then pdaFinApplicationRubrique = 12/31/2950.
            else pdaFinApplicationRubrique = minimum(pdaFinApplicationRubrique, 12/31/2950).
        end.
        else do:
            if pdaFinApplicationRubrique = ?
            then pdaFinApplicationRubrique = pdaFinBail.
            else pdaFinApplicationRubrique = minimum(pdaFinApplicationRubrique, pdaFinBail).
        end.
        delete object voProlongationExpiration.
    end.
    if pdaFinApplicationRubrique <> ? and pdaFinApplicationRubrique < pdaDebutPeriodeQuittancement
    then plTransfertQuittanceLocataire = no.  // pas de transfert de quittance pour ce locataire.
end procedure.
