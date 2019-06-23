/*------------------------------------------------------------------------
File        : tacheLoiDefiscalisationIRF.i
Purpose     : 
Author(s)   : GGA - 2018/01/11
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeLotLoiDefiscalisationIRF
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroContrat       as int64
    field iNumeroLot           as integer
    field cNatureLot           as character
    field cLibelleNatureLot    as character
    field cLoi                 as character        //HwCmbLoi        
    field cLibelleLoi          as character
    field daAchat              as date             //HwFilAct
    field daAchevement         as date             //HwFilAcv
    field daVente              as date             //HwFilVen
    field daFinTravaux         as date             //HwFilDta
    field daDebutApplication   as date             //HwFilDeb  
    field daFinApplication     as date             //HwFilFin 
    field dMontantAchat        as decimal          //HwFilMLo  
    field dMontantTravaux      as decimal
    field iDuree               as integer
    field iDureeSupplementaire as integer

    field dtTimestamp as datetime 
    field CRUD        as character 
    field rRowid      as rowid
.
&if defined(nomTableDetail)   = 0 &then &scoped-define nomTableDetail ttDetailLotLoiDefiscalisationIRF
&endif
&if defined(serialNameDetail) = 0 &then &scoped-define serialNameDetail {&nomTableDetail}
&endif
define temp-table {&nomTableDetail} no-undo serialize-name '{&serialNameDetail}'
    field iNumeroContrat    as int64
    field iNumeroLot        as integer
    field iNumeroAppel      as integer
    field NoTmp             as integer
    field cTypeFrais        as character        //HwCmbFra
    field cLibelleTypeFrais as character
    field daDateFrais       as date             //HwFilDat  
    field dMontantFrais     as decimal          //HwFilMFr
    field cLibelleFrais     as character        //HwFilLib

    field dtTimestamp as datetime 
    field CRUD        as character 
    field rRowid      as rowid
.
