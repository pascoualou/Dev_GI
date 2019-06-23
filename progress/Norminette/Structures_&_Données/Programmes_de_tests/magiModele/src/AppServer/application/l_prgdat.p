/*------------------------------------------------------------------------
File        : l_prgdat.p
Purpose     : gestion des dates
Author(s)   : LGI/TM - 1996/01/26  /  kantena - 2017/01/02
Notes       :
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure Cl2DatFin:
    /*------------------------------------------------------------------------------
    Purpose: Calcul d'une date de fin a partir d'une date de debut, d'une duree et d'une unite de duree (UTDUR)
    Notes  : service utilisé par autasatt.p, calmehqt.p, ...
    ------------------------------------------------------------------------------*/
    define input  parameter pdaDebut     as date      no-undo.
    define input  parameter piDuree      as integer   no-undo.
    define input  parameter pcUniteDuree as character no-undo.
    define output parameter pdaFin       as date      no-undo.

    define variable vlDernierJourMois as logical no-undo.  // Flag dernier jour du mois
    define variable viNombreMois      as integer no-undo.  // Coefficient de l'unite de duree en mois
    define variable viJourFin         as integer no-undo.  // Date de fin
    define variable viMoisFin         as integer no-undo.
    define variable viAnneeFin        as integer no-undo.
    define variable viMoisSuivant     as integer no-undo.
    define variable viAnneeSuivante   as integer no-undo.
    define variable viDernierJour     as integer no-undo.

    /* La date de debut est elle une fin de mois ?   */
    vlDernierJourMois = (month(pdaDebut) <> month(pdaDebut + 1)).
    case pcUniteDuree:
        when "00001" then assign       // An, Si 28/02 et que ajout sur date tombe sur une année bissextile: il faut garder 28
            vlDernierJourMois = false when month(pdaDebut) = month(pdaDebut + 1) and month(pdaDebut) = 2 and day(pdaDebut) = 28
            viNombreMois = 12
        .
        when "00002" then assign       // mois
            viNombreMois = 1
        .
    end case.
    assign
        viJourFin  = day (pdaDebut)
        viMoisFin  = month(pdaDebut) + piDuree * viNombreMois
        viAnneeFin = year(pdaDebut)
    .
    /* Gérer les mois negatifs ... (Rappel Revision) */
    if viMoisFin < 1 then do while viMoisFin < 1:
        assign
            viMoisFin  = viMoisFin + 12
            viAnneeFin = viAnneeFin - 1
        .
    end.
    else do while viMoisFin > 12:
        assign
            viMoisFin  = viMoisFin - 12
            viAnneeFin = viAnneeFin + 1
        .
    end.
    assign
        viMoisSuivant   = viMoisFin + 1
        viAnneeSuivante = viAnneeFin
    .
    do while viMoisSuivant > 12:
        assign
            viMoisSuivant   = viMoisSuivant - 12
            viAnneeSuivante = viAnneeSuivante + 1
        .
    end.
    viDernierJour = day(date(viMoisSuivant, 1, viAnneeSuivante) - 1).
    if vlDernierJourMois or viJourFin > viDernierJour then viJourFin = viDernierJour.
    pdaFin = date (viMoisFin, viJourFin, viAnneeFin).

end procedure.

procedure NbrMoiPer:
    /*------------------------------------------------------------------------------
    Purpose: Calcul du nombre de mois d'une periode (Exemple : An = 12)
    TODO   : non utilisé. A supprimer!?
    Notes  : service?
    ------------------------------------------------------------------------------*/
    define input  parameter piCodePeriode as integer no-undo.
    define output parameter piMoisPeriode as integer no-undo.

    piMoisPeriode = (piCodePeriode - piCodePeriode modulo 100) / 100.

end procedure.

procedure NbrMoiPr2:
    /*------------------------------------------------------------------------------
    Purpose: Calcul du nombre de mois d'une periode entre deux dates
    TODO   : non utilisé. A supprimer!?
    Notes  : service? La période commence le premier jour du mois et finit le dernier jour de l'autre mois
    Exemple: 01/02/1995-30/06/1996 --> 17 Mois
    ------------------------------------------------------------------------------*/
    define input  parameter pdaDebut     as date    no-undo.
    define input  parameter pdaFin       as date    no-undo.
    define output parameter piNombreMois as integer no-undo.

    piNombreMois = month(pdaFin) - month(pdaDebut) + (year(pdaFin) - year(pdaDebut)) * 12 + 1.

end procedure.

procedure GetLibMoi:
    /*------------------------------------------------------------------------------
    Purpose: Récuperation du mois en lettre de la table sys_pr
    TODO   : non utilisé. A supprimer!?
    Notes  : A REMPLACER PAR le service outilTraduction:getLibelleParam("CDMOI", string(month(DtEncChi), '99999'), TpAffDat).
    ------------------------------------------------------------------------------*/
    define input  parameter pdate       as date      no-undo.
    define input  parameter pcourtOuLong as character no-undo. // 'C' = libellé court, libellé long sinon
    define output parameter pcLibelle   as character no-undo.

    pcLibelle = outilTraduction:getLibelleParam("CDMOI", string(month(pdate), '99999'), pcourtOuLong).

end procedure.

procedure GetLibDte:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui formatte une date en lettres en fonction d'un code langue et d'un code "libelle court" ou "libelle long"
    Notes  : code issu de l_prguti_ext.p procédure GetLibDte 
    ------------------------------------------------------------------------------*/
    define input  parameter pDaDate     as date        no-undo.
    define input  parameter pcLongCourt as character   no-undo. // l ou c
    define output parameter pcLibelleDate as character no-undo.

    define variable vcLibelle1er  as character no-undo.

    if day(pDaDate) = 1 and mToken:iCodeLangueReference = 0 then vcLibelle1er = outilTraduction:getLibelle(44). // Gestion du '1er' (pour la France)
    pcLibelleDate = substitute("&1&2 &3 &4"
                             , day(pDaDate)
                             , vcLibelle1er
                             , outilTraduction:getLibelleParam("CDMOI", string(month(pDaDate),"99999"), pcLongCourt)
                             , year(pDaDate)).

end procedure.


procedure GetLibPer:
    /*------------------------------------------------------------------------------
    Purpose: Récuperation du libellé d'une periode
    TODO   : non utilisé. A supprimer!?
    Notes  : service?
    ------------------------------------------------------------------------------*/
    define input  parameter pdaDebut          as date      no-undo.
    define input  parameter pdaFin            as date      no-undo.
    define input  parameter pcourtOuLong      as character no-undo. /* libelles courts ou longs */
    define input  parameter pcAvecLibelleDuAu as character no-undo. /* avec ou sans libelles "du..au"*/
    define input  parameter pcAvecJour        as character no-undo. /* avec ou sans jour */
    define output parameter pcLibelle         as character no-undo. // Libelle de la periode

    define variable vcLibelleDu    as character no-undo.
    define variable vcLibelleAu    as character no-undo.
    define variable vcDebutPeriode as character no-undo.
    define variable vcFinPeriode   as character no-undo.

    assign
        vcLibelleDu    = outilTraduction:getLibelle(102303)   // du
        vcLibelleAu    = outilTraduction:getLibelle(100132)   // au
        vcDebutPeriode = outilTraduction:getLibelleParam("CDMOI", string(month(pdaDebut), '99999'), pcourtOuLong)
        vcFinPeriode   = outilTraduction:getLibelleParam("CDMOI", string(month(pdaFin), '99999'), pcourtOuLong)
        pcLibelle      = pcLibelle + vcLibelleDu                 when pcAvecLibelleDuAu = "A"
        pcLibelle      = pcLibelle + " " + string(day(pdaDebut)) when pcAvecJour = "A"
        pcLibelle      = substitute('&1 &2 &3&4', pcLibelle, vcDebutPeriode, string(year(pdaDebut)), if pcAvecLibelleDuAu = "A" then " " + vcLibelleAu else " - ")
        pcLibelle      = pcLibelle + " " + string(day(pdaFin))   when pcAvecJour = "A"
        pcLibelle      = substitute('&1 &2 &3', pcLibelle, vcFinPeriode, string(year(pdaFin)))
    .

end procedure.

procedure DatDerJou:
    /*------------------------------------------------------------------------------
    Purpose: Récuperation de la date du dernier jour d'un mois
    TODO   : non utilisé. A supprimer!?
    Notes  : service?
    ------------------------------------------------------------------------------*/
    define input  parameter pdate      as date       no-undo.
    define output parameter pdaFinMois as date       no-undo.

    assign
        pdaFinMois = date(month(pdate), 28, year(pdate)) + 4
        pdaFinMois = pdaFinMois - DAY(pdaFinMois)
    .
end procedure.

procedure CalInfPer:
    /*------------------------------------------------------------------------------
    Purpose: calcul de la date de fin de période, de Msqui et Msqtt à partir de la date de début de période, de la périodicité et du terme
    Notes  : service utilisé par genoffqt.p
    ------------------------------------------------------------------------------*/
    define input  parameter pdaDebut            as date      no-undo.
    define input  parameter piNombreMois        as integer   no-undo.
    define input  parameter pcCodeTerme         as character no-undo.
    define output parameter pdaFinPeriode       as date      no-undo.
    define output parameter piMoisQuittancement as integer   no-undo.
    define output parameter piMoisTraitementGI  as integer   no-undo.

    define variable vdaMoisSuivant    as date  no-undo format "99/99/9999".

    run Cl2DatFin(pdaDebut, piNombreMois, '00002', output pdaFinPeriode).
    pdaFinPeriode = pdaFinPeriode - 1.
    /* Calcul du mois Quittancement & mois Traitement */
    if pcCodeTerme = "00001" then assign                             // Terme avance
        piMoisQuittancement = year(pdaDebut) * 100 + month(pdaDebut) // Mois quittancement= 1er mois de la période
        piMoisTraitementGI = piMoisQuittancement                     // Mois traitement   = Mois quittancement
    .
    else assign                                                                 // Terme échu
        piMoisQuittancement = year(pdaFinPeriode) * 100 + month(pdaFinPeriode)  // Mois quittancement=dernier mois de la période
        vdaMoisSuivant = pdaFinPeriode + 1                                            // Mois traitement   =Mois suivant
        piMoisTraitementGI = year(vdaMoisSuivant) * 100 + month(vdaMoisSuivant)
    .
end procedure.
