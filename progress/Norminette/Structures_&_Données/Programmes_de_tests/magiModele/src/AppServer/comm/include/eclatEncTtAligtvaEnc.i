/*-----------------------------------------------------------------------------
File        : eclatEncTtAligtvaEnc.i
Purpose     : Include de definition commun aux programmes suivants:
              TRANS/SRC/GENE/CGEC.P
              CADB/SRC/BATCH/
Author(s)   : OF - 2006/06/15, Kantena - 2018/01/11
Notes       : reprise comm/tbeclat.i  --  reprise de la temp table aligtva-tmp
derniere revue: 2018/09/04 - phm: 
-----------------------------------------------------------------------------*/

define temp-table ttAligtva-enc no-undo
    field soc-cd        as integer
    field etab-cd       as integer
    field dateCompta    as character
    field compte        as character
    field codeRub       as integer
    field codeLib       as integer
    field MtRub         as decimal format "->>>,>>>,>>>,>>9.99"
    field MtRubTva      as decimal format "->>>,>>>,>>>,>>9.99" /* DM 0706/0055 */
    field Sens          as character
    field MtEuro        as decimal format "->>>,>>>,>>>,>>9.99"
    field jou-cd        as character        /* PS LE 18/08/02 */
    field piece-int     as integer          /* PS LE 18/08/02 */
    field lig           as integer          /* PS LE 18/08/02 */
    field type-cle      as character        /* PS LE 18/08/02 */
    field cmthono       as character        /* OF le 15/06/05**/
    field mois          as integer          /* OF le 15/06/05**/
    field lettre        as character        /* OF le 15/06/06**/
    field prd-cd        as integer          /* DM 1106/0082 */
    field prd-num       as integer          /* DM 1106/0082 */
    field ecrln-jou-cd  as character        /* DM 0809/0042 */
    field ecrln-prd-cd  as integer          /* DM 0809/0042 */
    field ecrln-prd-num as integer          /* DM 0809/0042 */
    field ecrln-piece-int as integer        /* DM 0809/0042 */
    field ecrln-lig       as integer        /* DM 0809/0042 */
    index ix-aligtva   Soc-cd Etab-cd jou-cd type-cle piece-int lig datecompta CodeRub
.
