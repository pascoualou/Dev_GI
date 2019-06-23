/*------------------------------------------------------------------------
File        : tiersOnglets.i
Purpose     :
Author(s)   : OFA - 2018/05/15
Notes       :
------------------------------------------------------------------------*/

/* (Liste des onglets du Tiers) */
define temp-table ttOngletsTiers no-undo
    field iNumeroOnglet     as integer   initial ?
    field cCodeOnglet       as character initial ?
    field iNumeroOrdre      as integer   initial ?
    field cCodeSousFamille  as character initial ?
    field cLibelleOnglet    as character initial ?
    field CRUD              as character
    .
