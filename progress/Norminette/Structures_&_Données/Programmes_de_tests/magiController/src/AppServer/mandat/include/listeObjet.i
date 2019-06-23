/*------------------------------------------------------------------------
File        : listeObjet.i
Description : liste objet (contractant, objet, roles annexes ...) pour un mandat
Author(s)   : gga 2017/08/03
Notes       : 
derniere revue: 2018/05/19 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeObjet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat   as character   initial ?
    field iNumeroContrat as int64       initial ?
    field cEtape         as character   initial ?
    field iSeq           as integer     initial ?
    field cRpRun         as character   initial ?
    field cNmPrg         as character   initial ? 
    field cLibelleObjet  as character   initial ?
    field cdOpeCtr       as character   initial ?  
    field cLbPrmCtr      as character   initial ? 
    field lObligatoire   as logical
.
