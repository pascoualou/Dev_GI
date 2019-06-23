/*------------------------------------------------------------------------
File        : visibiliteExtranet.i
Purpose     : 
Author(s)   : LGI/  -  2017/01/13 
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttVisibiliteExtranet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field id-fich                as int64   initial ? serialize-hidden
    field lSaisirLocataire       as logical
    field lVoirLocataire         as logical
    field lSaisirProprietaire    as logical
    field lVoirProprietaire      as logical
    field lSaisirCoproprietaire  as logical
    field lVoirCoproprietaire    as logical
    field lSaisirConseilSyndical as logical
    field lVoirConseilSyndical   as logical
    field lSaisirEmployeImmeuble as logical
    field lVoirEmployeImmeuble   as logical
.
