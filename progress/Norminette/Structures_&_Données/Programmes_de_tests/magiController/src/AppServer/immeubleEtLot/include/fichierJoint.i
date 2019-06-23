/*------------------------------------------------------------------------
File        : fichierJoint.i
Description : 
Author(s)   : kantena  -  2017/06/01
Notes       :
derniere revue: 2018/05/25 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttFichierJoint no-undo
    field cNomFichier             as character initial ?
    field iIDFichier              as int64     initial ?
    field iCodeIdentifiant        as integer   initial ?
    field cTypeIdentifiant        as character initial ?
    field iNumeroImmeuble         as integer   initial ?
    field iNumeroEquipement       as integer   initial ?
    field cCommentaire            as character initial ?
    field cRepertoire             as character initial ?
    field cChemin                 as character initial ?
    field daDateCreation          as date
    field daDateDebut             as date
    field daDateFin               as date
    field iNumeroDocument         as int64     initial ?
    field iNumeroModeleDocument   as integer   initial ?
    field cLibelleModeleDocument  as character initial ?
    field cLibelleCanevasDocument as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
