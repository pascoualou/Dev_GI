/*------------------------------------------------------------------------
File        : cinimo.i
Purpose     : fichier immobilisation
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCinimo
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num       as integer    initial ? 
    field amts_annuel      as decimal    initial ?  decimals 2
    field amts_annuel-EURO as decimal    initial ?  decimals 2
    field amts_fis         as decimal    initial ?  decimals 2
    field ana              as logical    initial ? 
    field ana1-cd          as character  initial ? 
    field ana2-cd          as character  initial ? 
    field ana3-cd          as character  initial ? 
    field ana4-cd          as character  initial ? 
    field barre-num        as integer    initial ? 
    field bureau-cle       as character  initial ? 
    field calcul-cle       as character  initial ? 
    field centra-int       as integer    initial ? 
    field cession-cle      as character  initial ? 
    field compta           as logical    initial ? 
    field comptaces        as logical    initial ? 
    field corpo            as logical    initial ? 
    field cours            as decimal    initial ?  decimals 8
    field cpt-cd           as character  initial ? 
    field da1serv          as date       initial ? 
    field dacess           as date       initial ? 
    field dacrea           as date       initial ? 
    field dadepart         as date       initial ? 
    field daecr            as date       initial ? 
    field daexp            as date       initial ? 
    field dafac            as date       initial ? 
    field damod            as date       initial ? 
    field dev-cd           as character  initial ? 
    field duree            as decimal    initial ?  decimals 2
    field echu             as logical    initial ? 
    field empl-cle         as character  initial ? 
    field etab-cd          as integer    initial ? 
    field fgTaxFonc        as logical    initial ? 
    field fgTaxProf        as logical    initial ? 
    field fis-calcul-cle   as character  initial ? 
    field fis-duree        as decimal    initial ?  decimals 2
    field fis-taux         as decimal    initial ?  decimals 8
    field four-cle         as character  initial ? 
    field genecr           as logical    initial ? 
    field ihcrea           as integer    initial ? 
    field ihmod            as integer    initial ? 
    field invest-cle       as character  initial ? 
    field invest-num       as character  initial ? 
    field jou-cd           as character  initial ? 
    field lib              as character  initial ? 
    field lib2             as character  initial ? 
    field mtdev            as decimal    initial ?  decimals 2
    field mtfrais-in       as decimal    initial ?  decimals 2
    field mtfrais-out      as decimal    initial ?  decimals 2
    field mtht             as decimal    initial ?  decimals 2
    field mtht-EURO        as decimal    initial ?  decimals 2
    field mtrevente        as decimal    initial ?  decimals 2
    field mttp             as decimal    initial ?  decimals 2
    field mttpdev          as decimal    initial ?  decimals 2
    field mtttc            as decimal    initial ?  decimals 2
    field mtttc-EURO       as decimal    initial ?  decimals 2
    field mtttcdev         as decimal    initial ?  decimals 2
    field mttva            as decimal    initial ?  decimals 2
    field mttva-EURO       as decimal    initial ?  decimals 2
    field mttvadev         as decimal    initial ?  decimals 2
    field nbech            as integer    initial ? 
    field nom              as character  initial ? 
    field num-int          as integer    initial ? 
    field piece-compta     as integer    initial ? 
    field pourc-rev        as decimal    initial ?  decimals 2
    field prixcess         as decimal    initial ?  decimals 2
    field prixcess-EURO    as decimal    initial ?  decimals 2
    field proj-calcul-cle  as character  initial ? 
    field proj-duree       as decimal    initial ?  decimals 2
    field proj-taux        as decimal    initial ?  decimals 8
    field puiss-fisc       as integer    initial ? 
    field qte              as decimal    initial ?  decimals 2
    field ref-num          as character  initial ? 
    field repart-ana       as character  initial ? 
    field soc-cd           as integer    initial ? 
    field ss-type          as character  initial ? 
    field sscoll-cle       as character  initial ? 
    field sscoll-emp       as character  initial ? 
    field taux             as decimal    initial ?  decimals 8
    field taxe-cd          as integer    initial ? 
    field tvacess          as decimal    initial ?  decimals 2
    field tvaded           as logical    initial ? 
    field type             as character  initial ? 
    field usrid            as character  initial ? 
    field usridmod         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
