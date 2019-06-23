/*-----------------------------------------------------------------------------
File        : tbeclat02.i
Purpose     : Include de definition commun aux programmes suivants:
              TRANS/SRC/GENE/CGEC.P
              CADB/SRC/BATCH/
Author(s)   : OF - 2006/06/15, Kantena - 2018/01/11
Notes       : reprise comm/tbeclat.i  --  reprise de la temp table aligtva-tmp
              NB: si la variable pré-processeur &RLVPRO n'est pas définie, pas d'include à mettre
-----------------------------------------------------------------------------*/

define temp-table aligtva-tmp no-undo
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
    field cmthono       like aligtva.cmthono /**Ajout OF le 15/06/05**/
    field mois          as integer           /**Ajout OF le 15/06/05**/
    field lettre        like cecrln.lettre   /**Ajout OF le 15/06/06**/
    field prd-cd        like cecrln.prd-cd /* DM 1106/0082 */
    field prd-num       like cecrln.prd-num /* DM 1106/0082 */  
    field ecrln-jou-cd  like adbtva.ecrln-jou-cd /* DM 0809/0042 */
    field ecrln-prd-cd  like adbtva.ecrln-prd-cd /* DM 0809/0042 */
    field ecrln-prd-num like adbtva.ecrln-prd-num /* DM 0809/0042 */
    field ecrln-piece-int like adbtva.ecrln-piece-int /* DM 0809/0042 */
    field ecrln-lig       like adbtva.ecrln-lig /* DM 0809/0042 */
    INDEX ix-aligtva   Soc-cd Etab-cd jou-cd type-cle piece-int lig datecompta CodeRub
//    index secondaire   soc-cd etab-cd jou-cd type-cle piece-int lig datecompta CodeRub
.
