/*------------------------------------------------------------------------
File        : vidage.i
Purpose     : Vidage d'une table (réelle ou temporaire) dans le fichier log
Author(s)   : PL 29/07/2010  -  GGA 2017/11/22
Notes       : reprise comm\vidage.i
----------------------------------------------------------------------*/
/*
 0001   08/09/2010  PL  Ajout {2} pour la clause 'by'
 0002   09/06/2011  SY  Ajout de %USERNAME% dans le nom du fichier comme dans procgene.p
 0003   18/10/2011  PL  La clause 'by' passe en {3}
                        {2} est utilisé pour un numéro de buffer pour pouvoir
                        mettre 2 instances de vidage.i dans le même programme
 0004   18/10/2011  PL  Adaptation pour utiliser le log progress.
 0005   20/10/2011  PL  impossible d'utiliser nmusruse en compta -> remplacé par la date-heure
 0006   15/04/2013  PL  Changement du nom des buffer car trop long
*/

PROCEDURE Maj_SuivTrf:
    /*------------------------------------------------------------------------------
    purpose:
    Note   :
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE cLig-V-{1}{2} AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cFic-V-{1}{2} AS CHARACTER NO-UNDO.
    define buffer bBuf-V-{1}{2} for {1}.

    cFic-V-{1}{2} = "Magi-"
        /*+ NmUsrUse*/
        + string(year(today), "9999")
        + string(month(today), "99")
        + string(day(today), "99")
        + replace(string(time,"hh:mm:ss"), ":", "")
        + ".tmp".

    MLog ("Export de la table : " + "{1}" + " Fichier vidage : " + cFic-V-{1}{2} + "%s").

    output to value(session:temp-directory + cFic-V-{1}{2}).
    FOR EACH bBuf-V-{1}{2} {3}:
        EXPORT bBuf-V-{1}{2}.
    END.
    OUTPUT CLOSE.

    /* Ajout du fichier dans le log */
    input from value(session:temp-directory + cFic-V-{1}{2}).
    REPEAT:
        IMPORT UNFORMATTED cLig-V-{1}{2}.
        MLog(cLig-V-{1}{2}).
    END.
    INPUT CLOSE.
    MLog ("---------- Fin de l'export ----------%s").
    OS-DELETE VALUE(cFic-V-{1}{2}).

END PROCEDURE.
