/*------------------------------------------------------------------------
File        : isoc.i
Purpose     : Informations administratives et juridiques pour une societe
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIsoc
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr            as character  initial ? 
    field ape            as character  initial ? 
    field cdiso2         as character  initial ? 
    field cdiso3         as character  initial ? 
    field cp             as character  initial ? 
    field da-purge       as date       initial ? 
    field dacrea         as date       initial ? 
    field damod          as date       initial ? 
    field dat-decret     as date       initial ? 
    field dat-euro       as date       initial ? 
    field date-bascule   as date       initial ? 
    field fax            as character  initial ? 
    field fg-bg-copro    as logical    initial ? 
    field fg-bg-gc       as logical    initial ? 
    field fg-bg-gerance  as logical    initial ? 
    field fg-dispo       as logical    initial ? 
    field fg-norme       as logical    initial ? 
    field ihcrea         as integer    initial ? 
    field ihmod          as integer    initial ? 
    field logo-soc       as character  initial ? 
    field nb-annee-purge as integer    initial ? 
    field nom            as character  initial ? 
    field pays           as character  initial ? 
    field siren          as character  initial ? 
    field siret          as character  initial ? 
    field soc-cd         as integer    initial ? 
    field specif-cle     as integer    initial ? 
    field tel            as character  initial ? 
    field telex          as character  initial ? 
    field tiers-declar   as character  initial ? 
    field tvacee-cle     as character  initial ? 
    field tx-euro        as decimal    initial ?  decimals 5
    field typapp-cd      as character  initial ? 
    field usrid          as character  initial ? 
    field usrid-purge    as character  initial ? 
    field usridmod       as character  initial ? 
    field ville          as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
