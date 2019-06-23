/*---------------------------------------------------------------------------
 Application      : MENUDEV2
 Programme        : Tables.i
 Objet            : D�finition des tables pour lire le m�tasch�ma
*---------------------------------------------------------------------------
 Date de cr�ation : 16/03/2009
 Auteur(s)        : PL
 Dossier analyse  : 
*---------------------------------------------------------------------------
 Entr�e :
 Sortie :
 Appel  :
*---------------------------------------------------------------------------
 Modifications :
 ....   ../../....    ....  

*--------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 | DEFINITIONS                                                             |
 *-------------------------------------------------------------------------*/
DEFINE {1} SHARED TEMP-TABLE ttTables
    FIELD cBase AS CHARACTER
    FIELD cNom AS CHARACTER
    FIELD cLibelle AS CHARACTER
    
    INDEX ixNom IS PRIMARY cNom 
    .

DEFINE {1} SHARED TEMP-TABLE ttChamps
    FIELD ctable AS CHARACTER
    FIELD iordre AS INTEGER
    FIELD cNom AS CHARACTER
    FIELD clabel AS CHARACTER
    FIELD cType AS CHARACTER
    FIELD cFormat AS CHARACTER
    FIELD cInitial AS CHARACTER
    FIELD cRemarque AS CHARACTER
    FIELD iExtent AS INTEGER
    
    INDEX ixNom IS PRIMARY ctable iordre  
    .

DEFINE {1} SHARED TEMP-TABLE ttindexes
    FIELD ctable AS CHARACTER
    FIELD cNom AS CHARACTER
    FIELD cDescription AS CHARACTER
    .
