/*------------------------------------------------------------------------
File        : salariePegase.i
Purpose     : 
Author(s)   : GGA  -  2017/11/16
Notes       :
derniere revue: 2018/05/17 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttSalariePegase
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeIdentifiant   as character initial ?   //tprol
    field iNumeroIdentifiant as integer   initial ?   //norol
    field iNumeroTiers       as integer   initial ?
    field cNom               as character initial ?
    field cCivilite          as character initial ?
    field iNiveau            as integer   initial ?
    field iCoefficient       as integer   initial ?
    field cStatut            as character initial ?
    field cLibStatut         as character initial ?
    field cEmploi            as character initial ?
    field daAnciennete       as date
    field daEntree           as date
    field daSortie           as date
    field cNoSS              as character initial ?
    field cCleSS             as character initial ?
    field daNaissance        as date
    field cIban              as character initial ?
    field cBic               as character initial ?
    field cTitulaire         as character initial ?
    field cDomiciliation     as character initial ?
    field cModeReglement     as character initial ?
    field cLibModeReglement  as character initial ?
    field cOrgRetraite       as character initial ?   /* Retraites */
    field cNomOrgRetraite    as character initial ?   /* Ajout SY le 04/07/2014 */
    field cOrgPrevoyance     as character initial ?   /* Prevoyances */
    field cNomOrgPrevoyance  as character initial ?   /* Ajout SY le 04/07/2014 */
    field cOrgMutuelle       as character initial ?   /* Mutuelles */      
    field cNomOrgMutuelle    as character initial ?   /* Ajout SY le 04/07/2014 */
    field cCollectifSolde    as character initial ?
    field cCompteSolde       as character initial ? 
    field dMontantSolde      as decimal   initial ?
.
