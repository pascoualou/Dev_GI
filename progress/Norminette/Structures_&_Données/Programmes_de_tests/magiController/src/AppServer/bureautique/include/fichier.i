/*------------------------------------------------------------------------
File        : fichier.i
Description :
Author(s)   : KANTENA - 2018/03/29
Notes       :
derniere revue: 2018/05/23 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttFichier
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cNomFichier        as character
    field cCheminFichier     as character
    field cContenuFichier    as clob
.
