/*-----------------------------------------------------------------------------
File        : tantiemeMandat.i
Purpose     : DEF TANTIEMES D'UN MANDAT
Author(s)   : JR 31/10/2007   -  GGA 18/02/22
Notes       : reprise comm/tantieme.def
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTantiemeMandat
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNoBranche         as integer
    field iNoLigne           as integer
    field iRang              as integer
    field imdt               as integer
    field iNumeroIndivisaire as integer
    field iNum               as integer   extent 20
    field iDen               as integer   extent 20
    field iIndivisionSuivant as integer
    field iIndivision        as integer
    field lib_calcul         as character
    field iNum_reel          as decimal
    field iden_reel          as decimal
    field iNumTot_reel       as decimal
    field idenTot_reel       as decimal
index i-mdt  imdt
.
