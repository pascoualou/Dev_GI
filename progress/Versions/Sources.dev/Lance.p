
    /* Chargement de l'environnement */
    IF NOT(PROPATH MATCHES("*" + OS-GETENV("DLC") + "\src*")) THEN DO:
        PROPATH = PROPATH + "," + OS-GETENV("DLC") + "\src".
    END.

    {includes\i_environnement.i NEW GLOBAL}

    /* Variables de travail */
    DEFINE VARIABLE cProgramme AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cParametresProgramme AS CHARACTER NO-UNDO INIT "".
    DEFINE VARIABLE lBaseConnecteeEnEntree AS LOGICAL NO-UNDO INIT FALSE.

    /* R�cup�ration des parametres */
    IF SESSION:PARAMETER <> ""  THEN DO:
        cProgramme = ENTRY(1,SESSION:PARAMETER,"#").
        IF NUM-ENTRIES(SESSION:PARAMETER,"#") >= 2 THEN DO:
            cParametresProgramme = ENTRY(2,SESSION:PARAMETER,"#").
        END.
    END.

    /* connexion � la base versions si pas d�j� fait */
    lBaseConnecteeEnEntree = CONNECTED("versions").
    IF not(lBaseConnecteeEnEntree) THEN DO:
        CONNECT -pf VALUE(gcRepertoireApplication + "connexion.pf") .
    END.
    
    /* Lancement du programme demand� */
    RUN VALUE(gcRepertoireExecution + cProgramme) (INPUT cParametresProgramme).

    /* D�connexion de la base si n�cessaire */
    IF not(lBaseConnecteeEnEntree) THEN DISCONNECT versions.
    QUIT.

PROCEDURE forcage:

    IF gcRepertoireExecution MATCHES "*sources.dev*" THEN
        gcUtilisateur = gcUtilisateur + ".DEV".

END PROCEDURE.
