/*------------------------------------------------------------------------
File        : cpaiepre.i
Purpose     : Fichier Preparation des Paiements Fournisseurs (Ecritures)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCpaiepre
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr-cd             as integer    initial ? 
    field affair-num         as integer    initial ? 
    field analytique         as logical    initial ? 
    field ancadr-cd          as integer    initial ? 
    field ancbonapaye        as logical    initial ? 
    field ancdaech           as date       initial ? 
    field ancregl-cd         as integer    initial ? 
    field bonapaye           as logical    initial ? 
    field bonapayelib        as character  initial ? 
    field bqjou-cd           as character  initial ? 
    field cdficvir           as character  initial ? 
    field chqbana-formu      as integer    initial ? 
    field chrono             as integer    initial ? 
    field cmpc-mandat-cd     as integer    initial ? 
    field coll-cle           as character  initial ? 
    field compens-coll-cle   as character  initial ? 
    field compens-cpt-cd     as character  initial ? 
    field compens-sscoll-cle as character  initial ? 
    field cours              as decimal    initial ?  decimals 8
    field cpt-cd             as character  initial ? 
    field cpte-pivot         as character  initial ? 
    field dacompta           as date       initial ? 
    field daech              as date       initial ? 
    field dalivr             as date       initial ? 
    field dapaie             as date       initial ? 
    field datecr             as date       initial ? 
    field dev-cd             as character  initial ? 
    field dossier-num        as integer    initial ? 
    field eapjou-cd          as character  initial ? 
    field edi                as logical    initial ? 
    field edidev-cd          as character  initial ? 
    field email              as character  initial ? 
    field etab-cd            as integer    initial ? 
    field etr                as logical    initial ? 
    field fg-a4              as logical    initial ? 
    field fg-chqbanal        as logical    initial ? 
    field fg1chqmdt          as logical    initial ? 
    field FgPaie             as logical    initial ? 
    field gest-cle           as character  initial ? 
    field ibanbic            as logical    initial ? 
    field jou-cd             as character  initial ? 
    field lettre             as character  initial ? 
    field lib                as character  initial ? 
    field libpaie-cd         as integer    initial ? 
    field libtier-cd         as integer    initial ? 
    field lig                as integer    initial ? 
    field mandat-cd          as integer    initial ? 
    field manu-int           as integer    initial ? 
    field modif              as logical    initial ? 
    field mt                 as decimal    initial ?  decimals 2
    field mt-dispo           as decimal    initial ?  decimals 2
    field mt-EURO            as decimal    initial ?  decimals 2
    field mtaregl            as decimal    initial ?  decimals 2
    field mtaregl-EURO       as decimal    initial ?  decimals 2
    field mtdev              as decimal    initial ?  decimals 2
    field mtregl             as decimal    initial ?  decimals 2
    field mtregl-EURO        as decimal    initial ?  decimals 2
    field natjou-cd          as integer    initial ? 
    field num-chq            as integer    initial ? 
    field num-int            as integer    initial ? 
    field piece-compta       as integer    initial ? 
    field piece-int          as integer    initial ? 
    field prd-cd             as integer    initial ? 
    field prd-num            as integer    initial ? 
    field ref-num            as character  initial ? 
    field regl-cd            as integer    initial ? 
    field ribexist           as logical    initial ? 
    field sens               as logical    initial ? 
    field sepa               as logical    initial ? 
    field soc-cd             as integer    initial ? 
    field sscoll-cle         as character  initial ? 
    field TpMod              as character  initial ? 
    field tri                as character  initial ? 
    field tva-enc-deb        as logical    initial ? 
    field type-cle           as character  initial ? 
    field type-reg           as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
