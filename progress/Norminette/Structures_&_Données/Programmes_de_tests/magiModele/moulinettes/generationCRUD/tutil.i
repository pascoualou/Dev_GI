/*------------------------------------------------------------------------
File        : tutil.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTutil
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field acq-mail         as character  initial ? 
    field cdaccord         as character  initial ? 
    field cIdentEvent      as character  initial ? 
    field Code1            as character  initial ? 
    field Code2            as character  initial ? 
    field convocAG         as logical    initial ? 
    field cParamDivers     as character  initial ? 
    field cptutil          as character  initial ? 
    field cTypeRecherche   as character  initial ? 
    field dacrea           as date       initial ? 
    field damod            as date       initial ? 
    field ddeb-inactif     as date       initial ? 
    field dfin-inactif     as date       initial ? 
    field dlastconnect     as datetime   initial ? 
    field dlastpasswd      as datetime   initial ? 
    field email            as character  initial ? 
    field favoris          as character  initial ? 
    field favoris-Soc      as character  initial ? 
    field fg-actf          as logical    initial ? 
    field fg-actif         as logical    initial ? 
    field fg-deletm        as logical    initial ? 
    field fg-giprint       as logical    initial ? 
    field fg-locCom        as logical    initial ? 
    field fg-locHab        as logical    initial ? 
    field fg-locPkg        as logical    initial ? 
    field fg-mdpgidemat    as logical    initial ? 
    field fg-referf        as logical    initial ? 
    field fg1chqmdt        as logical    initial ? 
    field FgFourCab        as logical    initial ? 
    field fgMplus1         as logical    initial ? 
    field ged              as character  initial ? 
    field ident_u          as character  initial ? 
    field ierrorpasswd     as integer    initial ? 
    field ihcrea           as integer    initial ? 
    field ihmod            as integer    initial ? 
    field initiales        as character  initial ? 
    field listhab          as character  initial ? 
    field lnom1            as character  initial ? 
    field lpre1            as character  initial ? 
    field Mot-passe        as character  initial ? 
    field nom              as character  initial ? 
    field norol            as integer    initial ? 
    field notie            as integer    initial ? 
    field onglet           as integer    initial ? 
    field palette          as integer    initial ? 
    field plan-cd          as character  initial ? 
    field profil_u         as character  initial ? 
    field ribbanqcre       as character  initial ? 
    field ribbanqmod       as character  initial ? 
    field ribcomptacre     as character  initial ? 
    field ribcomptamod     as character  initial ? 
    field ribcomptasup     as character  initial ? 
    field ribgestimcre     as character  initial ? 
    field ribgestimdef     as character  initial ? 
    field ribgestimencours as character  initial ? 
    field ribgestimmod     as character  initial ? 
    field ribgestimsup     as character  initial ? 
    field signataire1      as character  initial ? 
    field signataire2      as character  initial ? 
    field tprol            as character  initial ? 
    field usrid            as character  initial ? 
    field usridmod         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
