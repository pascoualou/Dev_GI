/*------------------------------------------------------------------------
File        : ctmpsai.i
Purpose     : Entête saisie des écritures nouvelle ergonomie
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCtmpsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field acompte        as logical    initial ? 
    field acpt-jou-cd    as character  initial ? 
    field acpt-type      as character  initial ? 
    field adr-cd         as integer    initial ? 
    field affair-num     as integer    initial ? 
    field ana1-cd        as character  initial ? 
    field ana2-cd        as character  initial ? 
    field ana3-cd        as character  initial ? 
    field ana4-cd        as character  initial ? 
    field barre-cd       as character  initial ? 
    field bonapaye       as logical    initial ? 
    field chg-cpt-cd     as character  initial ? 
    field chg-sscoll-cle as character  initial ? 
    field coll-cle       as character  initial ? 
    field consol         as logical    initial ? 
    field cours          as decimal    initial ?  decimals 8
    field cpt-cd         as character  initial ? 
    field daaff          as date       initial ? 
    field dacompta       as date       initial ? 
    field dacrea         as date       initial ? 
    field dadoss         as date       initial ? 
    field daech          as date       initial ? 
    field daecr          as date       initial ? 
    field daeff          as date       initial ? 
    field dalivr         as date       initial ? 
    field damod          as date       initial ? 
    field dev-cd         as character  initial ? 
    field devcon-num     as character  initial ? 
    field devcon-type    as character  initial ? 
    field dossier-num    as integer    initial ? 
    field etab-cd        as integer    initial ? 
    field fg-prorata     as logical    initial ? 
    field gest-cle       as character  initial ? 
    field ihcrea         as integer    initial ? 
    field ihdoss         as integer    initial ? 
    field ihmod          as integer    initial ? 
    field jou-cd         as character  initial ? 
    field lib            as character  initial ? 
    field mtdev          as decimal    initial ?  decimals 2
    field mtdev-EURO     as decimal    initial ?  decimals 2
    field mtht           as decimal    initial ?  decimals 2
    field mtimput        as decimal    initial ?  decimals 2
    field mtimput-EURO   as decimal    initial ?  decimals 2
    field mtregl         as decimal    initial ?  decimals 2
    field mtregl-EURO    as decimal    initial ?  decimals 2
    field mtttc          as decimal    initial ?  decimals 2
    field mttva          as decimal    initial ?  decimals 2
    field natjou-cd      as integer    initial ? 
    field nochrodis      as integer    initial ? 
    field nomprog        as character  initial ? 
    field ordre          as integer    initial ? 
    field piece-compta   as integer    initial ? 
    field piece-int      as integer    initial ? 
    field prd-cd         as integer    initial ? 
    field prd-num        as integer    initial ? 
    field profil-cd      as integer    initial ? 
    field ref-num        as character  initial ? 
    field regl-cd        as integer    initial ? 
    field regl-jou-cd    as character  initial ? 
    field regl-mandat-cd as integer    initial ? 
    field repart-ana     as character  initial ? 
    field scen-cle       as character  initial ? 
    field situ           as logical    initial ? 
    field soc-cd         as integer    initial ? 
    field sscoll-cle     as character  initial ? 
    field statut         as character  initial ? 
    field taxe-cd        as integer    initial ? 
    field tva-enc-deb    as logical    initial ? 
    field type-cle       as character  initial ? 
    field typenat-cd     as integer    initial ? 
    field usrid          as character  initial ? 
    field usrid-eff      as character  initial ? 
    field usridmod       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
