/*------------------------------------------------------------------------
File        : periodeChargeLocative.i
Purpose     : 
Author(s)   : GGA  -  2018/01/22
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttListePeriode
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat           as character initial ?
    field iNumeroContrat         as int64     initial ?
    field iNumeroPeriode         as integer   initial ?
    field daDebut                as date
    field daFin                  as date
    field cTypeCharge            as character initial ?
    field cLibelleTypeCharge     as character initial ?
    field cCodeTraitement        as character initial ?
    field cLibelleCodeTraitement as character initial ?
    field cCommentaire           as character initial ?
    field lTraitementManuel      as logical   initial ?
    field cCleChauffage1         as character initial ?
    field cLibelleCleChauffage1  as character initial ?
    field cCleChauffage2         as character initial ?
    field cLibelleCleChauffage2  as character initial ?
    field cCleChauffage3         as character initial ?
    field cLibelleCleChauffage3  as character initial ?
    field daChauffageDebut1      as date
    field daChauffageFin1        as date
    field daChauffageDebut2      as date
    field daChauffageFin2        as date
    field daChauffageDebut3      as date
    field daChauffageFin3        as date

    field dtTimestamp as datetime 
    field CRUD        as character 
    field rRowid      as rowid
.
