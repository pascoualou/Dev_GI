/*------------------------------------------------------------------------
File        : listeErreur.i
Description : liste des erreurs
Author(s)   : GGA - 2018/05/30
Notes       : utilisation d'une table avec la liste des erreurs au lieu d'un fichier pour les traitements de controle 
------------------------------------------------------------------------*/

&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListeErreur
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define {&classProp} temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iSequence as integer
    field cLibelle  as character
index primaire is primary iSequence ascending.
