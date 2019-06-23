/*------------------------------------------------------------------------
File        : error.i
Description :
Author(s)   : kantena - 2016/02/08
Notes       : {classProp} pour les propriétés temptable de classe (static en général)
derniere revue: 2018/05/03 - phm: OK
------------------------------------------------------------------------*/
{preprocesseur/niveauErreur.i}

&if defined(nomTable)   = 0 &then &scoped-define nomTable ttError
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define {&classProp} temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field horodate    as datetime
    field iType       as integer   // 1: Info 2: Warning 3: Erreur 4: Question 5: QuestionYesNo -1 Technique
    field iErrorId    as integer   // Numéro de message
    field cError      as character
    field lYesNo      as logical
    field cComplement as character
    field rRowid      as rowid     // En cas de création, iType = -1, rowid de l'enregistrement créé.
index primaire is primary horodate ascending.
