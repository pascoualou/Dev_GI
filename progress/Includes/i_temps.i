/*--------------------------------------------------------------------------*
| Programme        : i_temps.i                                              |
| Objet            : procedures et fonctions sur les dates & heures         |
|---------------------------------------------------------------------------|
| Date de création : 10/01/2008                                             |
| Auteur(s)        : PL                                                     |
*---------------------------------------------------------------------------*
*---------------------------------------------------------------------------*
| Historique des modifications                                              |
|---------------------------------------------------------------------------|
|  Nø  |    Date    | Auteur |                  Objet                       |
|------+------------+--------+----------------------------------------------|
| 0001 | 23/12/2008 |   PL   | Ajout DonneJourLettres + DonneNumeroJour     |
| 0002 | 03/12/2013 |   PL   | Pb dans le calcul de la semaine              |
|      |            |        |                                              |
*--------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/
FUNCTION EnMinute RETURNS INTEGER(INPUT iHeuresMinutes AS INTEGER):
    DEFINE VARIABLE iRetour AS INTEGER  NO-UNDO.
    
    iRetour = INTEGER(SUBSTRING(STRING(iHeuresMinutes,"9999"),1,2)) * 60
            + INTEGER(SUBSTRING(STRING(iHeuresMinutes,"9999"),3)).
    
    /*
    MLog ("EnMinute :"
        + "%s iHeuresMinutes = " + STRING(iHeuresMinutes)
        + "%s iRetour = " + STRING(iRetour)
        ).
    */
    RETURN iRetour.        

END FUNCTION.

FUNCTION EnHeuresMinutes RETURNS INTEGER(INPUT iMinutes AS INTEGER):
    DEFINE VARIABLE iRetour AS INTEGER  NO-UNDO.
    DEFINE VARIABLE iTempo AS INTEGER NO-UNDO.
    
    itempo = TRUNCATE(iMinutes / 60,0).
    iRetour = iTempo * 100 + (iMinutes - (itempo * 60)).
    
    /*
    MLog ("EnHeuresMinutes :"
        + "%s iMinutes = " + STRING(iMinutes)
        + "%s iRetour = " + STRING(iRetour)
        ).
    */
    
    RETURN iRetour.        

END FUNCTION.

/* ----------------------------------------------------------------------- 
    Retourne la date en format caractere ou blanc si date = ? 
   ----------------------------------------------------------------------- */
FUNCTION DonneDateChaine RETURNS CHARACTER(dDate AS DATE):
    RETURN (IF dDate <> ? THEN STRING(dDate) ELSE "").
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Retourne l'heure en nombre de minutes à partir de l'heure formattée 
    hh:mm
   ----------------------------------------------------------------------- */
FUNCTION DonneHeureEnMinutes RETURN INTEGER(LbHeuUse AS CHARACTER):
    RETURN INTEGER(ENTRY(1,LbHeuUse,":")) * 60 * 60 
         + INTEGER(ENTRY(2,LbHeuUse,":")) * 60.
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Controle la validité d'une heure au format hh:mm
   ----------------------------------------------------------------------- */
FUNCTION ControleHeure RETURN LOGICAL(LbHeuUse AS CHARACTER):
    DEFINE VARIABLE iTempo  AS INTEGER  NO-UNDO.
    
    /* Controle de l'heure */
    iTempo = INTEGER(ENTRY(1,LbHeuUse,":")) NO-ERROR.
    IF ERROR-STATUS:ERROR OR iTempo > 23 THEN RETURN FALSE.

    /* Controle des minutes */
    iTempo = INTEGER(ENTRY(2,LbHeuUse,":")) NO-ERROR.
    IF ERROR-STATUS:ERROR OR iTempo > 59 THEN RETURN FALSE.

    RETURN TRUE.
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Retourne une durée en jours, heures, minutes à partir d'une durée en 
    heures
   ----------------------------------------------------------------------- */
FUNCTION DonneJoursHeuresMinutes  RETURN CHARACTER(NbTpsUse AS INTEGER):
    DEFINE VARIABLE NbMinUse    AS INTEGER      NO-UNDO.
    DEFINE VARIABLE NbHeuUse    AS INTEGER      NO-UNDO.
    DEFINE VARIABLE NbJouUse    AS INTEGER      NO-UNDO.
    DEFINE VARIABLE LbTpsUse    AS CHARACTER    NO-UNDO.

    IF NbTpsUse = 0 THEN RETURN "".

    /* Ramener le temps en minute */
    NbMinUse = TRUNCATE(NbTpsUse / 60,0).

    /* Décomposition en minute / heure / jour */
    ASSIGN
    NbHeuUse = TRUNCATE(NbMinUse / 60,0)
    NbMinUse = NbMinUse MODULO 60
    NbJouUse = TRUNCATE(NbHeuUse / 8,0)
    NbHeuUse = NbHeuUse MODULO 8.

    IF NbJouUse > 0 THEN LbTpsUse = LbTpsUse + (IF LbTpsUse = "" THEN "" ELSE " ") + STRING(NbJouUse) + "jr".
    IF NbHeuUse > 0 THEN LbTpsUse = LbTpsUse + (IF LbTpsUse = "" THEN "" ELSE " ") + STRING(NbHeuUse) + "h".
    IF NbMinUse > 0 THEN LbTpsUse = LbTpsUse + (IF LbTpsUse = "" THEN "" ELSE " ") + STRING(NbMinUse) + "mn".
    IF LbTpsUse > "" THEN LbTpsUse = " : " + LbTpsUse.

    RETURN LbTpsUse.
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Ajoute un nombre d'années à une date
   ----------------------------------------------------------------------- */
FUNCTION AjouteAnnees RETURNS DATE(iNombreAnnees AS INTEGER,dDate AS DATE):
    DEFINE VARIABLE  dREtour AS DATE NO-UNDO.
    
    dREtour = DATE(STRING(DAY(dDate),"99") + "/" + STRING(MONTH(dDate),"99") + "/" + STRING(YEAR(dDate) + iNombreAnnees,"9999")).
    
    RETURN dREtour.
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Ajoute un nombre de mois à une date
   ----------------------------------------------------------------------- */
FUNCTION AjouteMois RETURNS DATE(iNombreMois AS INTEGER,dDate AS DATE):
    DEFINE VARIABLE dRetour      AS DATE         NO-UNDO.

    DEFINE VARIABLE NoAnnFin    AS INTEGER      NO-UNDO.
    DEFINE VARIABLE NoMoiFin    AS INTEGER      NO-UNDO.    
    DEFINE VARIABLE NoJouFin    AS INTEGER      NO-UNDO.
    DEFINE VARIABLE NbMoiTmp    AS INTEGER      NO-UNDO.
    DEFINE VARIABLE NoDerjou    AS INTEGER      NO-UNDO.  

    ASSIGN 
    /*--> Calcul du Nombre de Mois depuis J.C.*/
    NbMoiTmp = YEAR(dDate) * 12
    
    /*--> Ajout du Mois de la Date de Depart.*/
    NbMoiTmp = NbMoiTmp + MONTH(dDate)
    
    /*--> Ajout du Nombre de Mois de la Duree*/
    NbMoiTmp = NbMoiTmp + iNombreMois
    
    /*--> Recuperation de l'Annee d'Arrivee*/
    NoAnnFin = TRUNCATE(NbMoiTmp / 12, 0)
    
    /*--> Recuperation du Mois d'Arrivee.*/
    NoMoiFin = NbMoiTmp MODULO 12
    
    /*--> Forcer le Jour d'Arrivee avec celui de Depart.*/
    NoJouFin = DAY (dDate).

    /*--> Si NoMoiFin = 0 => On est en Decembre*/
    IF NoMoiFin = 0 THEN
        ASSIGN 
        NoMoiFin = 12
        NoAnnFin = NoAnnFin - 1.

    /*--> Recuperation du Dernier Jour du Mois d'Arrivee*/
    NoDerJou = DAY(((DATE(NoMoiFin, 28, NoAnnFin) + 4) - DAY(DATE(NoMoiFin, 28, NoAnnFin) + 4))).
        
    /*--> Tester le Dernier Jour / Jour Date de Debut.*/
    IF DAY(dDate) >= NoDerJou THEN
        NoJouFin = NoDerJou.
    
    dRetour = DATE(NoMoiFin, NoJouFin, NoAnnFin).

    RETURN dRetour.
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Donne la date de début d'un mois
   ----------------------------------------------------------------------- */
FUNCTION DonneDebutMois RETURNS DATE(dDate AS DATE):
    DEFINE VARIABLE dRetour AS DATE NO-UNDO.
    
    dRetour = DATE("01/" + STRING(MONTH(dDate),"99") + "/" + STRING(YEAR(dDate),"9999")).
    
    RETURN dRetour.
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Donne la date de fin d'un mois
   ----------------------------------------------------------------------- */
FUNCTION DonneFinMois RETURNS DATE(INPUT dDate AS DATE):
    DEFINE VARIABLE dRetour AS DATE NO-UNDO.
    
    dRetour = AjouteMois(1,DonneDebutMois(dDate)) - 1.
    
    RETURN dRetour.
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Donne la semaine d'une date (Numero de la semaine
   ----------------------------------------------------------------------- */
FUNCTION DonneSemaine RETURN INTEGER(dDate-in AS DATE):
    
    DEFINE VARIABLE iBoucle  AS INTEGER.
    DEFINE VARIABLE iDeltaDate AS INTEGER.
    DEFINE VARIABLE iSemaine AS INTEGER INIT 0.
    DEFINE VARIABLE iAnneeRef  AS INTEGER.

    /* Savoir combien de jours a l'année */
    iAnneeRef = YEAR(dDate-in).
    iDeltaDate = DATE(12,31,iAnneeRef) - DATE(01,01,iAnneeRef).
    
    /* Si 1ère semaine de janvier commence après le lundi... */
    IF WEEKDAY(DATE(01,01,iAnneeRef)) > 2 THEN iSemaine = 1.

    DO  iBoucle = 0 TO iDeltaDate :
        IF WEEKDAY(DATE(01,01,iAnneeRef) + iBoucle) = 2 THEN iSemaine = iSemaine + 1.
        IF iSemaine = 53 THEN iSemaine = 1.
        IF DATE(01,01,iAnneeRef) + iBoucle >= dDate-in THEN LEAVE.
    END.
    
    /* Gestion du retour */
    RETURN iSemaine.
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Donne la date en lettre
   ----------------------------------------------------------------------- */
FUNCTION DonneDateLettre  RETURN CHARACTER(dDate-in AS DATE):

    DEFINE VARIABLE cJour   AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cMois   AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cDate   AS CHARACTER    NO-UNDO.
    
    cDate = "".
    
    /* Décodage jour de la semaine */
    CASE WEEKDAY(dDate-in):
        WHEN 1 THEN cJour = "Dimanche".
        WHEN 2 THEN cJour = "Lundi".
        WHEN 3 THEN cJour = "Mardi".
        WHEN 4 THEN cJour = "Mercredi".
        WHEN 5 THEN cJour = "Jeudi".
        WHEN 6 THEN cJour = "Vendredi".
        WHEN 7 THEN cJour = "Samedi".
    END CASE.
    
    /* Décodage mois */
    CASE MONTH(dDate-in):
        WHEN 1 THEN cMois = "Janvier".
        WHEN 2 THEN cMois = "Février".
        WHEN 3 THEN cMois = "Mars".
        WHEN 4 THEN cMois = "Avril".
        WHEN 5 THEN cMois = "Mai".
        WHEN 6 THEN cMois = "Juin".
        WHEN 7 THEN cMois = "Juillet".
        WHEN 8 THEN cMois = "Aout".
        WHEN 9 THEN cMois = "Septembre".
        WHEN 10 THEN cMois = "Octobre".
        WHEN 11 THEN cMois = "Novembre".
        WHEN 12 THEN cMois = "Décembre".
    END CASE.
    
    /* Compisition de la date */
    cDate = cJour + " " + STRING(DAY(dDate-in)) + " " + cMois.
    
    /* Gestion du retour */
    RETURN cDate.
    
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Donne le jour en lettre
   ----------------------------------------------------------------------- */
FUNCTION DonneJourLettre  RETURN CHARACTER(dDate-in AS DATE):

    DEFINE VARIABLE cJour   AS CHARACTER    NO-UNDO.
       
    /* Décodage jour de la semaine */
    CASE WEEKDAY(dDate-in):
        WHEN 1 THEN cJour = "Dimanche".
        WHEN 2 THEN cJour = "Lundi".
        WHEN 3 THEN cJour = "Mardi".
        WHEN 4 THEN cJour = "Mercredi".
        WHEN 5 THEN cJour = "Jeudi".
        WHEN 6 THEN cJour = "Vendredi".
        WHEN 7 THEN cJour = "Samedi".
    END CASE.    
       
    /* Gestion du retour */
    RETURN cJour.
    
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Donne le numero du jour
   ----------------------------------------------------------------------- */
FUNCTION DonneNumeroJour  RETURN INTEGER(dDate-in AS DATE):

    DEFINE VARIABLE iJour   AS INTEGER    NO-UNDO.
       
    /* Décodage jour de la semaine */
    ijour = WEEKDAY(dDate-in) - 1.
    IF ijour = 0 THEN iJour = 7.
       
    /* Gestion du retour */
    RETURN iJour.
    
END FUNCTION.

/* ----------------------------------------------------------------------- 
    Donne l'heure en secondes depuis le format hh:mm:ss
   ----------------------------------------------------------------------- */
FUNCTION DonneHeureEnSeconde  RETURN INTEGER(cHeure-in AS CHARACTER):
    DEFINE VARIABLE iRetour AS INTEGER.

    /* controle du format */
    IF NUM-ENTRIES(cHeure-in,":") < 2 THEN DO:
        MESSAGE "Le format de l'heure en entrée est incorrect (" + cHeure-in + ")"
            VIEW-AS ALERT-BOX ERROR
            TITLE "DonneHeureEnSeconde : contrôle des paramètres..."
            .
        RETURN 0.
    END.

    /* traduction de l'heure */
    iRetour = 0.
    iRetour = INTEGER(ENTRY(1,cHeure-in,":")) * 3600.
    iRetour = iRetour + INTEGER(ENTRY(2,cHeure-in,":")) * 60.
    IF num-entries(cHeure-in,":") > 2 THEN iRetour = iRetour + INTEGER(ENTRY(3,cHeure-in,":")).
    
    RETURN iRetour.

END FUNCTION.

/* ----------------------------------------------------------------------- 
    Donne l'heure depuis la valeur en seconde
   ----------------------------------------------------------------------- */
FUNCTION DonneHeureDepuisSeconde  RETURN INTEGER(iHeure-in AS INTEGER):
    DEFINE VARIABLE iretour AS INTEGER.

    iretour = iHeure-in / 3600.

    RETURN iretour.

END FUNCTION.

/* ----------------------------------------------------------------------- 
    Donne les minutes depuis la valeur en seconde
   ----------------------------------------------------------------------- */
FUNCTION DonneMinutesDepuisSeconde  RETURN INTEGER(iHeure-in AS INTEGER):

    DEFINE VARIABLE iretour AS INTEGER.

    iretour = (iHeure-in MOD 3600) / 60.

    RETURN iretour.

END FUNCTION.

