/*------------------------------------------------------------------------
File        : texteLocataire.i
Purpose     :
Author(s)   : gga - 2018/10/04
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTexteLocataire
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeRole    as character        label "tprol"     
    field iNumeroRole  as int64            label "norol" 
    field iNumeroTexte as integer          label "notxt"
    field cLigne1      as character        label "lbtx1" 
    field cLigne2      as character        label "lbtx2" 
    field cLigne3      as character        label "lbtx3" 
    field cLigne4      as character        label "lbtx4" 
    field cLigne5      as character        label "lbtx5" 
    field cLigne6      as character        label "lbtx6" 
    
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.

&if defined(nomTable2)   = 0 &then &scoped-define nomTable2 ttListeLocataire
&endif
&if defined(serialName2) = 0 &then &scoped-define serialName2 {&nomTable2}
&endif
define temp-table {&nomTable2} no-undo serialize-name '{&serialName2}'
    field cTypeRole         as character     
    field iNumeroRole       as int64     
    field iNumeroLocataire  as int64     
    field iNumeroTexte      as integer
    
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
