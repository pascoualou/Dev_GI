/*-----------------------------------------------------------------------------
File        : indiceRevisionLoyer.i
Purpose     : 
Author(s)   : npo  -  29/03/2018
Notes       :
derniere revue: 2018/05/23 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIndiceRevisionLoyer
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table ttIndiceRevisionLoyer no-undo
    field iCodeTypeIndice       as integer   initial ?  /* lsirv.cdirv */
    field cLibelleTypeIndice    as character initial ?  /* lsirv.lbcrt */
    field iNumeroAnneeReference as integer   initial ?  /* indrv.anper */
    field iNumeroPeriodAnnee    as integer   initial ?  /* indrv.noper */
    field iCodePeriodicite      as integer   initial ?  /* lsirv.cdper */
    field dValeurIndice         as decimal   initial ?  /* indrv.vlirv */
    field dTauxRevision         as decimal   initial ?  /* indrv.txirv */
    field iNombreDecimals       as integer   initial ?  /* lsirv.nbdec */
    field daParutionJO          as date                 /* indrv.dtpjo */
    field daSaisieLe            as date                 /* indrv.dtmsy */
    field cFlagAutomatique      as character initial ?  /* lsirv.fgaut */
    field iFlagValeur           as integer   initial ?  /* lsirv.fgval */
    field lCreateAutorise       as logical   initial ?
    field lModifAutorise        as logical   initial ?
    field lSupprAutorise        as logical   initial ?

    field dtTimestamp as datetime        // table indrv
    field CRUD        as character
    field rRowid      as rowid           // table indrv
.
