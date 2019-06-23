/*------------------------------------------------------------------------
File        : montantDeclareOrgSociaux.i
Purpose     : 
Author(s)   : GGA  -  2017/11/14
Notes       :
derniere revue: 2018/05/22: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttMontantDeclareOrgSociaux
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field daDebut        as date                // DtDeb
    field daFin          as date                // DtFin
    field cPeriodeExtr   as character initial ? // lbTypExtract
    field cNoDeclarant   as character initial ? // NUMURSSAF 
    field dMontant       as decimal   initial ? // Montant 
    field lRegle         as logical   initial ? // FgRegle 
    field cInfoReglement as character initial ? // InfoReglement
.
