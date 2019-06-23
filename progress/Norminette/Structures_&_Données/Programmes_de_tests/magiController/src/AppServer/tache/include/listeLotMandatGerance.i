/*------------------------------------------------------------------------
File        : listeLotMandatGerance.i
Purpose     : liste des lots du mandat de gérance
Author(s)   : SPo  -  2018/05/17
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeLotMandatGerance
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat      as character initial ? 
    field iNumeroContrat    as int64     initial ?
    field iNumeroImmeuble   as integer   initial ?
    field iNumeroLot        as integer   initial ?
    field cLibelleNatureLot as character initial ?
    field cBatimentLot      as character initial ?
    field lIsDivisible      as logical   initial ?
    field iNumeroLocataire  as int64     initial ?                   // dernier locataire occupant
    field daDateEntree      as date                                  // Date d'entrée du locataire 
    field daDateSortie      as date                                  // Date de sortie du locataire 
    field cNomLocataire     as character initial ?
    .
