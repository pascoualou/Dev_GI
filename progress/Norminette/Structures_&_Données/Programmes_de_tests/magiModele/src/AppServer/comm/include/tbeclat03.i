/*-----------------------------------------------------------------------------
File        : tbeclat03.i
Purpose     : Include de definition commun aux programmes suivants:
              TRANS/SRC/GENE/CGEC.P
              CADB/SRC/BATCH/
Author(s)   : OF - 2006/06/15, Kantena - 2018/01/11
Notes       : reprise comm/tbeclat.i  --  reprise de la temp table impaye
-----------------------------------------------------------------------------*/

define temp-table impaye no-undo
    field Soc-cd        as integer
    field Etab-cd       as integer
    field DateCompta    as character
    field Compte        as character
    field CodeRub       as integer
    field CodeLib       as integer
    field MtRub         as decimal format "->>>,>>>,>>>,>>9.99"
    field MtRubTva      as decimal format "->>>,>>>,>>>,>>9.99" /* DM 1006/0030 */
    field Sens          as character
    field MtEuro        as decimal format "->>>,>>>,>>>,>>9.99"
    field lettre        like cecrln.lettre    /**Ajout OF le 15/06/06**/
    field lib-ecr       like cecrln.lib-ecr   /**Ajout OF le 15/06/06**/
    field dacompta      like cecrln.dacompta  /**Ajout OF le 15/06/06**/
    field fg-quit       as logical /* DM 0809/0042 */
    field ecrln-jou-cd  like adbtva.ecrln-jou-cd /* DM 0809/0042 */
    field ecrln-prd-cd  like adbtva.ecrln-prd-cd /* DM 0809/0042 */
    field ecrln-prd-num like adbtva.ecrln-prd-num /* DM 0809/0042 */
    field ecrln-piece-int like adbtva.ecrln-piece-int /* DM 0809/0042 */
    field ecrln-lig       like adbtva.ecrln-lig /* DM 0809/0042 */
    index ix-impaye    Soc-cd Etab-cd CodeRub
.
