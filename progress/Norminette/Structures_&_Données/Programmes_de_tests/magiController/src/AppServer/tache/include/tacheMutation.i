/*-----------------------------------------------------------------------------
File        : tacheMutation.i
Purpose     :
Author(s)   : GGA  -  2018/02/05
Notes       :
derniere revue: 2018/05/16 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeLotMutation
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat           as character
    field iNumeroContrat         as int64
    field iNumeroUL              as integer
    field iNumeroLot             as integer
    field iNumeroClassement      as integer
    field iNumeroContratMutation as int64
    field iNumeroMutation        as integer    //TbLotMdt.nomut
    field lLotActuel             as logical
    field cNatureLot             as character  //local.ntlot
    field cLibelleNature         as character
    field lDivisible             as logical    //local.fgdiv
    field dSurface               as decimal    //cpuni.sflot local.sfree
    field cBatiment              as character  //local.cdbat
    field cEntree                as character  //TbLotMdt.CdEnt
    field cEscalier              as character  //local.cdesc
    field cEtage                 as character  //local.cdeta
    field cPorte                 as character  //local.cdpte
    field iNombrePiece           as integer    //local.nbprf
    field cCodePostal            as character  //TbLotMdt.CpLot
    field cVille                 as character  //TbLotMdt.ViLot
    field cAdresse               as character  //TbLotMdt.AdLot
    field cOccupant              as character  //TbLotMdt.NmOcc
    field cTypeProprietaire      as character  //TbLotMdt.lbOcc
    field iNumeroBail            as integer    //TbLotMdt.NoBai
    field iNumeroCopro           as integer    //TbLotMdt.NoCop
    field cNomCoproprietaire     as character  //TbLotMdt.NmCop
    field iNumeroULAch           as integer    //TbLotMdt.noapp-ach   //historique

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
&if defined(nomTableMutation)   = 0 &then &scoped-define nomTableMutation ttMutation
&endif
&if defined(serialNameMutation) = 0 &then &scoped-define serialNameMutation {&nomTableMutation}
&endif
define temp-table {&nomTableMutation} no-undo serialize-name '{&serialNameMutation}'
    field cTypeContrat           as character
    field iNumeroContrat         as int64
    field iNumeroContratMutation as int64
    field iNumeroMutation        as integer    //TbLotMdt.nomut
    field iNumeroAcheteur        as integer    //TbLotMdt.norol-ach
    field cNomAcheteur           as character  //TbLotMdt.NmAch
    field iNumeroMandatAcheteur  as int64      //TbLotMdt.MdtAch
    field daVente                as date
    field daAchat                as date       //TbLotMdt.dtachnot
    field lActuel                as logical

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
