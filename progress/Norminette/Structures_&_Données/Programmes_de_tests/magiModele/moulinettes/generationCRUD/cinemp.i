/*------------------------------------------------------------------------
File        : cinemp.i
Purpose     : fichier emprunt/leasing/location
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCinemp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num      as integer    initial ? 
    field amo-ech         as logical    initial ? 
    field ana             as logical    initial ? 
    field ana1-cd         as character  initial ? 
    field ana2-cd         as character  initial ? 
    field ana3-cd         as character  initial ? 
    field ana4-cd         as character  initial ? 
    field bqdev-cd        as character  initial ? 
    field bqprofil-cd     as integer    initial ? 
    field cours           as decimal    initial ?  decimals 8
    field cpt-cd          as character  initial ? 
    field dadepart        as date       initial ? 
    field daechvr         as date       initial ? 
    field daexp           as date       initial ? 
    field dev-cd          as character  initial ? 
    field duree           as decimal    initial ?  decimals 2
    field echu            as logical    initial ? 
    field etab-cd         as integer    initial ? 
    field four-cle        as character  initial ? 
    field genecr          as logical    initial ? 
    field invest-cle      as character  initial ? 
    field invest-num      as character  initial ? 
    field jou-cd          as character  initial ? 
    field jour-prel       as integer    initial ? 
    field lib             as character  initial ? 
    field mt              as decimal    initial ?  decimals 2
    field mt-EURO         as decimal    initial ?  decimals 2
    field mtassur         as decimal    initial ?  decimals 2
    field mtassur-EURO    as decimal    initial ?  decimals 2
    field mtdev           as decimal    initial ?  decimals 2
    field mtprefinan      as decimal    initial ?  decimals 2
    field mtprefinan-EURO as decimal    initial ?  decimals 2
    field mtpret          as decimal    initial ?  decimals 2
    field mtpret-EURO     as decimal    initial ?  decimals 2
    field mtttc           as decimal    initial ?  decimals 2
    field mtttc-EURO      as decimal    initial ?  decimals 2
    field mtttcdev        as decimal    initial ?  decimals 2
    field mttva           as decimal    initial ?  decimals 2
    field mttva-EURO      as decimal    initial ?  decimals 2
    field mttvadev        as decimal    initial ?  decimals 2
    field mtvr            as decimal    initial ?  decimals 2
    field mtvr-EURO       as decimal    initial ?  decimals 2
    field num-int         as integer    initial ? 
    field per-appel       as character  initial ? 
    field ref-dossier     as character  initial ? 
    field soc-cd          as integer    initial ? 
    field sscoll-cle      as character  initial ? 
    field taxe-cd         as integer    initial ? 
    field txinteret       as decimal    initial ?  decimals 3
    field type-cle        as character  initial ? 
    field type-ech        as character  initial ? 
    field validvr         as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
