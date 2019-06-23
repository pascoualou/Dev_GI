/*------------------------------------------------------------------------
File        : incctrpa.i
Purpose     : Include contenant les procedures de controle des no SIREN/SIRET ou no caisse retraite (CRIP)
Author(s)   : SY - 1998/03/02 : GGA - 2017/10/10
Notes       : reprise include adb\comm\incctrpa.i
              pour le moment seulement reprise procedure Ctr_Siren --> function controleSiren

01 | 26/01/2000 |  SY  | Contrôle CRIP: Gestion erreur si lettre saisie dans les 12 premiers chiffres d'un code CRIP commençant par '80' (Pb BAZIN)
02 | 27/10/2004 |  PL  | Modif controle nic non saisi.
03 | 04/02/2010 |  NP  | 0110/0273 chgmt new code CRIP sur 14 caract.
----------------------------------------------------------------------*/

function controleSiren returns logical private (pcNumeroSiren as character, pcNumeroNic as character):
    /*------------------------------------------------------------------------------
    Purpose: Fonction de controle du no SIREN ou du no SIRET (reprise de la procedure Ctr_Siren).
             Renvoit true si no siren OK.
             Exemple d'appel:
                vlRetour = controleSiren("351714704", "00019").
    Notes  : service externe (tacheTva.p)
        La clef de contrôle utilisée pour vérifier l'exactitude d'un identifiant est une clef « 1-2 », suivant l'algorithme de Luhn.
        Le principe est le suivant: on multiplie les chiffres de rang impair à partir de la droite par 1, ceux de rang pair par 2.
        On somme les chiffres du nombre obtenu, ainsi si 7, on a 7 * 2 = 14 --> 5.
    ------------------------------------------------------------------------------*/
    define variable vcSiret  as character no-undo.
    define variable viCle    as integer   no-undo.
    define variable viboucle as integer   no-undo.
    define variable viTemp   as integer   no-undo.

    integer(pcNumeroSiren) no-error.    // SIREN de valeur entière?
    if error-status:error then return false.

    integer(pcNumeroNic) no-error.      // NIC de valeur entière?
    if error-status:error then return false.

    if length(pcNumeroSIREN, "character") <> 9 or (length(pcNumeroNIC, "character") <> 5 and integer(pcNumeroNIC) <> 0) then return false.

    if integer(pcNumeroNic) = 0
    then vcSiret = "0" + pcNumeroSiren.          // On récupère la parité - 10 positions
    else vcSiret = pcNumeroSiren + pcNumeroNic.  // 14 positions
    do viboucle = 1 to length(vcSiret, 'character'):
        if viboucle modulo 2 = 0
        then viCle = viCle + integer(substring(vcSiret, viboucle, 1, 'character')).
        else assign
            viTemp = integer(substring(vcSiret, viboucle, 1, "character")) * 2
            viCle  = viCle + if viTemp >= 10 then viTemp modulo 10 + 1 else viTemp
        .
    end.
    return viCle > 0 and viCle modulo 10 = 0.

end function.


/*gga
PROCEDURE Ctr_CRIP:
    /*------------------------------------------------------------------------------
    Procedure de controle du no de CRIP
    Paramètres d'entrée: 
        - CdSiren-IN = Numéro de caisse de retraite 
    Paramètres de sortie: FgVerOk-OU = Flag si no CRIP OK
    Exemple d'appel: 
        RUN Ctr_CRIP ("801630823000S", OUTPUT FgExeMth ).
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  CdCRIP-IN   AS CHARACTER        NO-UNDO.
    DEFINE OUTPUT PARAMETER FgVerOk-OU  AS LOGICAL INIT FALSE   NO-UNDO.

    DEFINE VARIABLE boucle      AS integer  NO-UNDO.
    DEFINE VARIABLE NoCalTmp    AS integer  INIT 0  NO-UNDO.
    DEFINE VARIABLE Reste       AS integer  NO-UNDO.
    DEFINE VARIABLE LsPair      AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE LsimPair    AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE TbCodLet    AS CHARACTER FORMAT "X" EXTENT 23   
        INITIAL [ 
             "C" , "D" , "S" , "T" , "H"
            ,"V" , "W" , "X" , "Y" , "Z"
            ,"E" , "J" , "K" , "L" , "M"
            ,"N" , "G" , "P" , "Q" , "R"
            ,"F" , "A" , "B" 
            ]
        NO-UNDO.

    IF TRIM(CdCRIP-IN) = "" THEN RETURN.
    
/** NP 0110/0273    Ouverture sur 14 caract.
                    tout en gardant les tests sur le 80 et 004x

    IF LENGTH(CdCRIP-IN) > 13 THEN RETURN.
    ASSIGN CdCRIP-IN = STRING(CdCRIP-IN,"X(13)").

    IF SUBSTRING(CdCRIP-IN,1,2) = "80" THEN DO:
        DO boucle = 3 TO 11 BY 2:
            ASSIGN LsImPair = LsImPair + SUBSTRING(CdCRIP-IN, boucle , 1).
        END.
        DO boucle = 4 TO 12 BY 2:
            ASSIGN LsPair = LsPair + SUBSTRING(CdCRIP-IN, boucle , 1).
        END.
        ASSIGN NoCalTmp = integer(LsPair) * 2 + integer(LsImPair) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN RETURN.

        ASSIGN
            Reste = NoCalTmp MODULO 23
            Reste = Reste + 1
            .
        IF Reste > 23 THEN RETURN.
        IF TbCodLet[Reste] <> SUBSTRING(CdCRIP-IN, 13 , 1) THEN RETURN.
    END.
    ELSE  IF   SUBSTRING(CdCRIP-IN,1,4) = "0047" 
        OR SUBSTRING(CdCRIP-IN,1,4) = "0048" 
        OR SUBSTRING(CdCRIP-IN,1,4) = "0049" 
        OR SUBSTRING(CdCRIP-IN,1,4) = "0050" THEN DO:
        DO boucle = 1 TO 12:
            IF SUBSTRING(CdCrip-IN,boucle, 1) = " " THEN RETURN.
        END.
        IF SUBSTRING(CdCrip-IN,13, 1) <> " " THEN RETURN.
    END.
    ELSE
        RETURN.
****/

    IF LENGTH(CdCRIP-IN) > 14 THEN RETURN.

    IF SUBSTRING(CdCRIP-IN,1,2) = "80" THEN 
    DO:
        DO boucle = 3 TO 11 BY 2:
            ASSIGN LsImPair = LsImPair + SUBSTRING(CdCRIP-IN, boucle , 1).
        END.
        DO boucle = 4 TO 12 BY 2:
            ASSIGN LsPair = LsPair + SUBSTRING(CdCRIP-IN, boucle , 1).
        END.
        ASSIGN NoCalTmp = integer(LsPair) * 2 + integer(LsImPair) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN RETURN.

        ASSIGN
            Reste = NoCalTmp MODULO 23
            Reste = Reste + 1
            .
        IF Reste > 23 THEN RETURN.
        IF TbCodLet[Reste] <> SUBSTRING(CdCRIP-IN, 13 , 1) THEN RETURN.
    END.
    ELSE IF SUBSTRING(CdCRIP-IN,1,4) = "0047" 
         OR SUBSTRING(CdCRIP-IN,1,4) = "0048" 
         OR SUBSTRING(CdCRIP-IN,1,4) = "0049" 
         OR SUBSTRING(CdCRIP-IN,1,4) = "0050" THEN 
    DO:
        DO boucle = 1 TO 12:
            IF SUBSTRING(CdCrip-IN,boucle, 1) = " " THEN RETURN.
        END.
        IF SUBSTRING(CdCrip-IN,13, 1) <> " " THEN RETURN.
    END.
    ELSE DO:
        IF LENGTH(CdCRIP-IN) <> 14 THEN RETURN.
    END.

    ASSIGN FgVerOk-OU = TRUE.

END PROCEDURE.
gga*/