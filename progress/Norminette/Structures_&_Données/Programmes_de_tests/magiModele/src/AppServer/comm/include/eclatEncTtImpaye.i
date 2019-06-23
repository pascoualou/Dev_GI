/*-----------------------------------------------------------------------------
File        : eclatEncTtImpaye.i
Purpose     : Include de definition commun aux programmes suivants:
              TRANS/SRC/GENE/CGEC.P
              CADB/SRC/BATCH/
Author(s)   : OF - 2006/06/15, Kantena - 2018/01/11
Notes       : reprise comm/tbeclat.i  --  reprise de la temp table impaye
derniere revue: 2018/09/04 - phm: 
-----------------------------------------------------------------------------*/

define temp-table ttImpaye no-undo
    field Soc-cd          as integer
    field Etab-cd         as integer
    field DateCompta      as character
    field Compte          as character
    field CodeRub         as integer
    field CodeLib         as integer
    field MtRub           as decimal format "->>>,>>>,>>>,>>9.99"
    field MtRubTva        as decimal format "->>>,>>>,>>>,>>9.99" /* DM 1006/0030 */
    field Sens            as character
    field MtEuro          as decimal format "->>>,>>>,>>>,>>9.99"
    field lettre          as character              /**OF le 15/06/06**/
    field lib-ecr         as character  extent 20   /**OF le 15/06/06**/
    field dacompta        as date                   /**OF le 15/06/06**/
    field fg-quit         as logical                /* DM 0809/0042 */
    field ecrln-jou-cd    as character              /* DM 0809/0042 */
    field ecrln-prd-cd    as integer                /* DM 0809/0042 */
    field ecrln-prd-num   as integer                /* DM 0809/0042 */
    field ecrln-piece-int as integer                /* DM 0809/0042 */
    field ecrln-lig       as integer                /* DM 0809/0042 */
    index ix-impaye    Soc-cd Etab-cd CodeRub
.
