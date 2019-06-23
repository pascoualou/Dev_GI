/*------------------------------------------------------------------------
File        : tacheRefacturationDepense.i
Purpose     : 
Author(s)   : DM 2017/11/27
Notes       :
derniere revue: 2018/05/24 - DM: OK
------------------------------------------------------------------------*/
define temp-table ttRefacturationRubrique no-undo
    field cdent                     as character initial ? serialize-hidden                  // pour le crud uniquement
    field iNumeroMandat             as int64     initial ? label "iden1" format "9999999999"
    field iCodeRubriqueDepense      as integer   initial ? label "iden2" format "999"        // TbRubRefac.rub-cd  
    field iCodeSousRubriqueDepense  as integer   initial ? label "idde1" format "999"        // TbRubRefac.ssrub-cd
    field cLibelleRubriqueDepense   as character initial ?                                   // TbRubRefac.libssrub
    field iCodeFiscalite            as integer   initial ? label "idde2" format "9"          // TbRubRefac.fisc-cle
    field lRefacturation            as logical   initial ?                                   // TbRubRefac.fgfac   
    field iCodeRubriqueQuitt        as integer   initial ?                                   // TbRubRefac.noruqtt 
    field iCodeLibelleRubriqueQuitt as integer   initial ?                                   // TbRubRefac.nolbqtt 
    field cLibelleRubriqueQuitt     as character initial ?                                   // TbRubRefac.lbrub
    field dPourcentageLocataire     as decimal   initial ? label "mtde1"                     // TbRubRefac.pcloc
    field lControle                 as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.   
define temp-table ttRefacturationLocataire no-undo
    field cdent                    as character initial ? serialize-hidden                  // pour le crud uniquement
    field iNumeroMandat            as int64     initial ?                                   
    field cNatureContrat           as character initial ?                                   
    field iNumeroLocataire         as integer   initial ?                                   // TbPcLoc.nocpt   
    field cNomLocataire            as character initial ?                                   // TbPcLoc.NomLoc  
    field dPourcentageLocataire    as decimal   initial ? label "mtde1"                     // TbPcLoc.PcLocL
    field iNumeroContrat           as int64     initial ? label "iden1" format "9999999999" // TbPcLoc.noctt  
    field dtResiliation            as date                                                  // TbPcLoc.dtree
    field cLibelleNatureBail       as character initial ?                                   // TbPcLoc.Lbnatbai
    field iCodeRubriqueDepense     as integer   initial ? label "iden2" format "999"        // TbPcLoc.rub-cd  
    field iCodeSousRubriqueDepense as integer   initial ? label "idde1" format "999"        // TbPcLoc.ssrub-cd
    field iCodeFiscalite           as integer   initial ? label "idde2" format "9"          // TbPcLoc.fisc-cle
    field lActif                   as logical   initial ?                                   // Actif = true / Résilié = false
    field lCommercial              as logical   initial ?                                   // Commercial ou Professionnel = true
    field lControle                as logical   initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
define temp-table ttEdRefacturationDepense no-undo
    field iNumeroMandat                 as int64     initial ?
    field cNomMandant                   as character initial ?
    field cAdresseMandant               as character initial ?
    field daDateResiliation             as date
    field iCodeRubriqueDepense          as integer   initial ? 
    field cLibelleRubriqueDepense       as character initial ? 
    field iCodeSousRubriqueDepense      as integer   initial ? 
    field cLibelleSousRubriqueDepense   as character initial ? 
    field iCodeFiscalite                as integer   initial ? 
    field lRefacturation                as logical   initial ?
    field cCodeRubriqueQuittancement    as character initial ? 
    field cLibelleRubriqueQuittancement as character initial ? 
    field dPourcentageLocataireMandat   as decimal   initial ? 
    field iNumeroBail                   as int64     initial ? 
    field cNomLocataire                 as character initial ? 
    field dPourcentageLocataireBail     as decimal   initial ? 
    field cLibelleCategorieBail         as character initial ? 
    field cLibelleNatureBail            as character initial ? 
.
define temp-table ttTacheRefacturationDepense no-undo
    field lModifAutorise as logical  initial ?
    field iNumeroMandat  as int64    initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
