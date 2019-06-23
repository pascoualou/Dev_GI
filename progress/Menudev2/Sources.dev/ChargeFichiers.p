/* Procedure de chargement des fichiers dans la base menudev2 */

DEFINE VARIABLE cRepertoire AS CHARACTER NO-UNDO INIT "D:\Partage\Disque_H\dev\outils\progress\Menudev2\Ressources\".
DEFINE VARIABLE cFichier AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLigne AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTexte AS CHARACTER NO-UNDO.

DEFINE STREAM sEntree.
 
RUN ChargeFichier("saints.txt").
RUN ChargeFichier("menudev.inf").

PROCEDURE ChargeFichier:
    DEFINE INPUT PARAMETER cFichier-in AS CHARACTER NO-UNDO.

    INPUT STREAM sEntree FROM VALUE(cRepertoire + cFichier-in).
    cTexte = "".
    REPEAT:
        IMPORT STREAM sEntree cLigne.
        cTexte = cTexte + CHR(10) + cLigne.
    END.
    cTexte = SUBSTRING(cTexte,2).
    INPUT STREAM sEntree CLOSE.
    
    FIND FIRST  fichiers    EXCLUSIVE-LOCK
        WHERE   fichiers.cUtilisateur = ""
        AND     fichiers.cTypeFichier = "SYS"
        AND     fichiers.cIdentFichier = cFichier-in
        NO-ERROR.      
    IF NOT(AVAILABLE(fichiers)) THEN DO:
        CREATE fichiers.
        ASSIGN
            fichiers.cUtilisateur = ""
            fichiers.cTypeFichier = "SYS"
            fichiers.cIdentFichier = cFichier-in
            fichiers.cCreateur = "PPL-ChargeFichiers.p"
            fichiers.dCreation = TODAY
            .
    END.
    
    ASSIGN
        fichiers.texte = cTexte
        fichiers.lAdmin = TRUE
        .
    RELEASE fichiers.    
END PROCEDURE.

