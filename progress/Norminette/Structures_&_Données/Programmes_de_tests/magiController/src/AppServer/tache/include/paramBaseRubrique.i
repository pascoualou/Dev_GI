/*------------------------------------------------------------------------
File        : paramBaseRubrique.i
Purpose     :
Author(s)   : DM 2017/10/03
Notes       :  
derneire revue: 2018/05/16 - phm: OK
------------------------------------------------------------------------*/

define temp-table ttBaseCalcul no-undo
    field cCodeBaseCalcul as character initial ?  
    field cLibelleCourt   as character initial ?
    field cLibelleLong    as character initial ?
    field cTypeHonoraire  as character initial ? serialize-hidden
    field cTypeBase       as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid 
.
define temp-table ttFamilleRubrique no-undo
    field cCodeBaseCalcul     as character initial ? 
    field iCodeFamille        as integer   initial ?
    field cLibelleFamille     as character initial ?
    field iCodeSousFamille    as integer   initial ?
    field cLibelleSousFamille as character initial ?
    field lSelection          as logical   initial ?
.
define temp-table ttRubrique no-undo
    field cCodeBaseCalcul  as character initial ?    
    field iCodeFamille     as integer   initial ?
    field iCodeSousFamille as integer   initial ?              
    field iCodeRubrique    as integer   initial ?
    field iCodeLibelle     as integer   initial ?
    field cLibelleRubrique as character initial ?
    field lSelection       as logical   initial ?     

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
