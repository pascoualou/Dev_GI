/*---------------------------------------------------------------------------
 Application      : MAGI
 Programme        : vidage.i
 Objet            : Vidage d'une table (r�elle ou temporaire) dans le 
                    fichier log
*---------------------------------------------------------------------------
 Date de cr�ation : 29/07/2010
 Auteur(s)        : PL
 Dossier analyse  : ?.?.?
*---------------------------------------------------------------------------
 Entr�e :
 Sortie :
 Appel  :
*---------------------------------------------------------------------------
 Modifications :
 ....   ../../....  ... ...............................................
 0001   08/09/2010  PL  Ajout {2} pour la clause 'by'
*--------------------------------------------------------------------------*/

    DEFINE BUFFER bufferLog-{1} FOR {1}.

    MLog ("Export de la table : " + "{1}" + "%s").
    

    OUTPUT TO VALUE(SESSION:TEMP-DIRECTORY + "menudev2.log") APPEND.
    
    FOR EACH bufferLog-{1} {2} NO-LOCK:
        EXPORT bufferLog-{1}.
    END.
    
    OUTPUT CLOSE.

    MLog ("%s").
    
