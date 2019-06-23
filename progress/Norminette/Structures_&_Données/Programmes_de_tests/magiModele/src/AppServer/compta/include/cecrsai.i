/*------------------------------------------------------------------------
File        : cecrsai.i
Purpose     : Entete de gestion des ecritures
Author(s)   : generation automatique le 01/31/18
Notes       :
derniere revue: 2018/07/28 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCecrsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field acompte        as logical    initial ? 
    field acpt-jou-cd    as character  initial ? 
    field acpt-type      as character  initial ? 
    field adr-cd         as integer    initial ? 
    field affair-num     as integer    initial ? 
    field barre-cd       as character  initial ? 
    field bonapaye       as logical    initial ? 
    field cdenr          as character  initial ? 
    field coll-cle       as character  initial ? 
    field consol         as logical    initial ? 
    field cours          as decimal    initial ?  decimals 8
    field cpt-cd         as character  initial ? 
    field daaff          as date 
    field dacompta       as date 
    field dacrea         as date 
    field dadoss         as date 
    field daech          as date 
    field daecr          as date 
    field daeff          as date 
    field dalivr         as date 
    field damod          as date 
    field dev-cd         as character  initial ? 
    field dossier-num    as integer    initial ? 
    field etab-cd        as integer    initial ? 
    field fg-modif       as logical    initial ? 
    field id-fich        as int64      initial ? 
    field ihcrea         as integer    initial ? 
    field ihdoss         as integer    initial ? 
    field ihmod          as integer    initial ? 
    field jou-cd         as character  initial ? 
    field lbtrvxctent    as character  initial ? 
    field lib            as character  initial ? 
    field lienOS         as character  initial ? 
    field mtdev          as decimal    initial ?  decimals 2
    field mtdev-EURO     as decimal    initial ?  decimals 2
    field mtimput        as decimal    initial ?  decimals 2
    field mtimput-EURO   as decimal    initial ?  decimals 2
    field mtregl         as decimal    initial ?  decimals 2
    field mtregl-EURO    as decimal    initial ?  decimals 2
    field natjou-cd      as integer    initial ? 
    field nochrodis      as integer    initial ? 
    field nomprog        as character  initial ? 
    field piece-compta   as integer    initial ? 
    field piece-int      as integer    initial ? 
    field prd-cd         as integer    initial ? 
    field prd-num        as integer    initial ? 
    field profil-cd      as integer    initial ? 
    field ref-fac        as character  initial ? 
    field ref-num        as character  initial ? 
    field regl-cd        as integer    initial ? 
    field regl-jou-cd    as character  initial ? 
    field regl-mandat-cd as integer    initial ? 
    field scen-cle       as character  initial ? 
    field situ           as logical    initial ? 
    field soc-cd         as integer    initial ? 
    field sscoll-cle     as character  initial ? 
    field type-cle       as character  initial ? 
    field type-piece     as character  initial ? 
    field typenat-cd     as integer    initial ? 
    field usrid          as character  initial ? 
    field usrid-eff      as character  initial ? 
    field usridmod       as character  initial ? 
    field xrdj-num       as character  initial ? 
    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
