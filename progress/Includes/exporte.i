/*---------------------------------------------------------------------------
 Application      : MAGI
 Programme        : exporte.i
 Objet            : Export d'un enregistrement d'une table (r�elle ou temporaire) 
                    dans le fichier log
*---------------------------------------------------------------------------
 Date de cr�ation : 08/09/2010
 Auteur(s)        : PL
 Dossier analyse  : ?.?.?
*---------------------------------------------------------------------------
 Entr�e :
 Sortie :
 Appel  :
*---------------------------------------------------------------------------
 Modifications :
 ....   ../../....  ... ...............................................

*--------------------------------------------------------------------------*/

    MLog ("Export de l'enregistrement courant de la table : " + "{1}" + "%s").

    OUTPUT TO VALUE(SESSION:TEMP-DIRECTORY + "Menudev2.log") APPEND.
    
    EXPORT {1}.
    
    OUTPUT CLOSE.

    MLog ("%s").
    