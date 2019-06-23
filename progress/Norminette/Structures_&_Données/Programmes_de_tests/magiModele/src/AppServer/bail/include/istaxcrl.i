/*------------------------------------------------------------------------
File        : isTaxCrl.i
Purpose     : Recherche si un bail est soumis à la taxe additionnelle (CRL) pour un mois donné
Author(s)   : SY 2009/12/03, kantena 2017/11/27 
Notes       : vient de comm/isTaxCrl.i
Fiche       : 1108/0397, Quittancement\QuitRubriqueCalculeeV02.doc
------------------------------------------------------------------------*/

function isTaxCRL return logical
    (piNumeroContrat as integer, piMoisQuittancement as integer, pdeMontantLoyerMensuel as decimal, pdeLoyerMinimum as decimal):
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/
    define variable viNumeroImmeuble    as integer no-undo.
    define variable viAgeImmeuble       as integer no-undo.
    define variable vdaDebutExercice    as date    no-undo.
    define variable viMoisQuittancement as integer no-undo.
    define variable viAnneQuittancement as integer no-undo.
    define variable vdeLoyerAnnuel      as decimal no-undo.
    define buffer intnt for intnt.
    define buffer ctrat for ctrat.

    /* Lien intnt / immeuble pour N° immeuble. */
    find first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.nocon = piNumeroContrat no-error.
    if not available intnt then return false.

    viNumeroImmeuble = intnt.noidt.
    /* Lien intnt / Construction immeuble. */
    find first intnt no-lock
        where intnt.tpcon = {&TYPECONTRAT-construction}
          and intnt.tpidt = {&TYPEBIEN-immeuble}
          and intnt.noidt = viNumeroImmeuble no-error.
    if not available intnt then return false.
    
    /* Recherche contrat pour date fin construction */
    find first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-construction}
          and ctrat.nocon = intnt.nocon no-error.             
    if not available ctrat then return false.     

    /* Date de fin construction (Achèvement). */
    assign
        /* Date début exercice fiscal. (1er oct -> 30 septembre) */
        viMoisQuittancement = piMoisQuittancement modulo 100          // integer(substring(string(piMoisQuittancement,"999999"),5,2))
        viAnneQuittancement = truncate(piMoisQuittancement / 100, 0)  // integer( substring(string(piMoisQuittancement,"999999"),1,4))
        vdaDebutExercice    = date(10, 01, viAnneQuittancement)
    .
    if vdaDebutExercice > date(viMoisQuittancement, 01, viAnneQuittancement) then vdaDebutExercice = date(10, 01, viAnneQuittancement - 1).
    /* Calcule intervalle fin construction / deb exer */
    viAgeImmeuble = year(vdaDebutExercice) - year(ctrat.dtfin).
    if viAgeImmeuble < 15 then return false.
    if viAgeImmeuble = 15
    and date(month(ctrat.dtfin), day(ctrat.dtfin), year(ctrat.dtfin) + 15) > vdaDebutExercice then return false.
    /* l'immeuble a plus de 15 ans et le loyer annuel doit etre sup. au loyer mini forfaitaire comm.
       avant avec le droit de bail => loi finance 1999 */
    /* Recherche du loyer mini forfaitaire (1830 E) Ancien param franc = "MTFIS" (12000) */
    vdeLoyerAnnuel = pdeMontantLoyerMensuel * 12.    /* Calcul loyer annuel */
    if absolute(vdeLoyerAnnuel) <= pdeLoyerMinimum then return false.
    return true.
end function.
