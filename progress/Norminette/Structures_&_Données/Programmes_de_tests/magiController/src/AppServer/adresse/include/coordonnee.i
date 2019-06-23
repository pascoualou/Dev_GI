/*------------------------------------------------------------------------
File        : coordonnee.i
Purpose     : 
Author(s)   : KANTENA - 2016/12/20
Notes       :
derniere revue: 2018/05/22 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCoordonnee
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroIdentifiant as integer
    field cJointure          as character
index ix_Lxxx is primary iNumeroIdentifiant cJointure ascending.    // ordonne le flux JSON
