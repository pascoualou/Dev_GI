/*------------------------------------------------------------------------
File        : cpaiepar.i
Purpose     : Fichier Parametre Preparation des Paiements Fournisseurs
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCpaiepar
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field agence       as integer    initial ? 
    field bonapaye     as logical    initial ? 
    field bqjou-cd     as character  initial ? 
    field bqprofil-cd  as integer    initial ? 
    field categ-cd     as integer    initial ? 
    field chrono       as integer    initial ? 
    field coll-cle     as character  initial ? 
    field compens      as logical    initial ? 
    field cours        as decimal    initial ?  decimals 8
    field cptdeb-cd    as character  initial ? 
    field cptfin-cd    as character  initial ? 
    field dacrea       as date       initial ? 
    field dafin        as date       initial ? 
    field damod        as date       initial ? 
    field dapaie       as date       initial ? 
    field dev-cd       as character  initial ? 
    field echdep       as logical    initial ? 
    field etab-cd      as integer    initial ? 
    field fg-achat     as logical    initial ? 
    field fg-acompte   as logical    initial ? 
    field fg-d40       as logical    initial ? 
    field fg-divers    as logical    initial ? 
    field fg-ducs      as logical    initial ? 
    field fg-engag     as logical    initial ? 
    field fg-hb        as logical    initial ? 
    field fg-nvfac     as logical    initial ? 
    field fg-pegase    as logical    initial ? 
    field fg-rembtcop  as logical    initial ? 
    field fg-trt       as logical    initial ? 
    field fg1chqmdt    as logical    initial ? 
    field FgEtr        as logical    initial ? 
    field FgRes        as logical    initial ? 
    field gest-cle     as character  initial ? 
    field ihcrea       as integer    initial ? 
    field ihmod        as integer    initial ? 
    field letvir       as logical    initial ? 
    field libpaie-cd   as integer    initial ? 
    field lsaffair     as character  initial ? 
    field lscpt        as character  initial ? 
    field lstagence    as character  initial ? 
    field lstfac       as character  initial ? 
    field lstimm       as character  initial ? 
    field mandatdeb    as integer    initial ? 
    field mandatfin    as integer    initial ? 
    field multipaie-cd as character  initial ? 
    field paie         as logical    initial ? 
    field paieecr      as logical    initial ? 
    field paieedi      as logical    initial ? 
    field paiepre      as logical    initial ? 
    field paierep      as logical    initial ? 
    field param-edi    as logical    initial ? 
    field pos          as integer    initial ? 
    field profil-cd    as integer    initial ? 
    field situ         as logical    initial ? 
    field soc-cd       as integer    initial ? 
    field solde        as logical    initial ? 
    field sscoll-cle   as character  initial ? 
    field typdate      as logical    initial ? 
    field type-select  as integer    initial ? 
    field usrid        as character  initial ? 
    field usridmod     as character  initial ? 
    field USRIDPAI     as character  initial ? 
    field virech       as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
