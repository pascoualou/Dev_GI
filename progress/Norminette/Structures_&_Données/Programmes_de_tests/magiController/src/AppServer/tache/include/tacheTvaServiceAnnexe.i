/*-----------------------------------------------------------------------------
File        : tacheTvaServiceAnnexe.i
Purpose     : 
Author(s)   : npo  -  2018/03/01
Notes       : Bail - Tache TVA Services Annexes
derniere revue: 2018/05/24 - phm: OK
-----------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheTvaServiceAnnexe
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroTache        as int64     initial ? label "noita"
    field cTypeContrat        as character initial ? label "tpcon"
    field iNumeroContrat      as int64     initial ? label "nocon"
    field cTypeTache          as character initial ? label "tptac"
    field iChronoTache        as integer   initial ? label "notac"

    field iNumeroFamille      as integer   initial ?       /* nofam */
    field cFamilleRubriques   as character initial ?       /* affam */
    field iNumeroSousFamille  as integer   initial ?       /* nosfa */
    field cSousFamille        as character initial ?       /* afsfa */
    field cCodeTauxTVA        as character initial ?       /* CdTva */
    field cLibelleTauxTVA     as character initial ?       /* LbTva */
    field dTauxTVA            as decimal   initial ?       /* TxTva */
    field iNumeroRubriqueQtt  as integer   initial ?       /* norub */
    field cLibelleRubriqueQtt as character initial ?       /* afrub */
    field iNumeroLibelleQtt   as integer   initial ?       /* nolib */
    field cLibelleQtt         as character initial ?       /* aflib */

    field dtTimestamp         as datetime
    field CRUD                as character
    field rRowid              as rowid
.
