/*------------------------------------------------------------------------
File        : libelleCleRepartition.i
Purpose     :
Author(s)   : DMI 2017/12/18
Notes       : Param�trage des cl�s de r�partition
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLibelleCleRepartition
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field tppar             as character initial "LBCLE"
    field cCodeCle          as character initial ? label "zon01"  /* CdCle - type d'identifiant   */
    field cLibelleCle       as character initial ? label "zon02"  /* LbCle - Nom de l'identifiant */
    field cNatureCle        as character initial ? label "zon04"  /* TpCle - Nature de cle        */
    field cLibelleNatureCle as character initial ?                /* LbTcl - Libell� type de cle  */
    field lActif            as logical   initial ? label "fgact"  format "YES/NO"  /* Flag actif/inactif */

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
