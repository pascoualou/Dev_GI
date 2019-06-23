/*-----------------------------------------------------------------------------
File        : tbeclat01.i
Purpose     : Include de definition commun aux programmes suivants:
              TRANS/SRC/GENE/CGEC.P
              CADB/SRC/BATCH/
Author(s)   : OF - 2006/06/15, Kantena - 2018/01/11
Notes       : reprise comm/tbeclat.i  --  reprise de la temp table cecrln-enc
-----------------------------------------------------------------------------*/

define temp-table cecrln-enc no-undo
    field soc-cd        as integer
    field etab-cd       as integer
    field piece-int     as integer
    field lig           as integer
    field sscoll-cle    as character
    field cpt-cd        as character
    field jou-cd        as character
    field prd-cd        as integer
    field prd-num       as integer
    field dacompta      as date
    field sens          as logical
    field mt            as decimal
    field mtEuro        as decimal
    field type-cle      as character        /* PS LE 18/08/02 */
    field cmthono       like cecrln.cmthono /**Ajout OF le 15/06/05**/
    field lettre        like cecrln.lettre  /**Ajout OF le 15/06/06**/
    /**Ajout OF le 30/01/14 pour optimisation**/
    index ix1        Soc-cd Etab-cd jou-cd prd-cd prd-num piece-int lig
.
