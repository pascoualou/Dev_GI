/*------------------------------------------------------------------------
File        : labelLadb.i
Description : dataset des traductions et des valeurs initiales
Author(s)   : kantena - 2016/02/08
Notes       :
derniere revue: 2018/05/03 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttsys_lb
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
&if defined(nomTable2)   = 0 &then &scoped-define nomTable2 ttInitValue
&endif
&if defined(serialName2) = 0 &then &scoped-define serialName2 {&nomTable2}
&endif

define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field noMes as integer   label "Numero de message"
    field lbMes as character label "Libelle du message"
index ix_sys_lb01 is primary unique nomes ascending.
{&_proparse_ prolint-nowarn(idiskeyword)}
define temp-table {&nomTable2} no-undo serialize-name '{&serialName2}'
    field code   as character label "code"
    field valeur as character label "valeur"
index primaire is primary code.
