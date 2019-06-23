/*------------------------------------------------------------------------
File        : imble.i
Purpose     : 
Author(s)   : generation automatique le 08/08/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttImble
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field afdev             as integer   initial ?
    field afhab             as integer   initial ?
    field afhob             as integer   initial ?
    field afhon             as integer   initial ?
    field after             as integer   initial ?
    field afvet             as integer   initial ?
    field cdaful            as character initial ?
    field cdcad             as character initial ?
    field cddev             as character initial ?
    field cdext             as character initial ?
    field cdinternet        as character initial ?
    field cdiris            as character initial ?
    field cdlocalisation    as character initial ?
    field cdoffgeo          as character initial ?
    field cdpln             as character initial ?
    field cdqualite         as character initial ?
    field cdres             as character initial ?
    field cdsec             as character initial ?
    field cdsse             as character initial ?
    field cdzonage          as character initial ?
    field codesite          as character initial ?
    field dtrenov           as date
    field fgservitude       as logical   initial ?
    field fgven             as logical   initial ?
    field lbaful            as character initial ?
    field lbdiv             as character initial ?
    field lbdiv2            as character initial ?
    field lbdiv3            as character initial ?
    field lbdiv4            as character initial ?
    field lbimgctent        as character initial ?
    field lbnom             as character initial ?
    field lbservitude       as character initial ?
    field lbtitctent        as character initial ?
    field mdcha             as character initial ?
    field mdchd             as character initial ?
    field mdcli             as character initial ?
    field mdfra             as character initial ?
    field nbant             as integer   initial ?
    field nbasc             as integer   initial ?
    field nbbaes            as integer   initial ?
    field nbbat             as integer   initial ?
    field nbcolsec          as integer   initial ?
    field nbdad             as integer   initial ?
    field nbdeclench        as integer   initial ?
    field nbesc             as integer   initial ?
    field nbeta             as integer   initial ?
    field nbext             as integer   initial ?
    field nbexutoir         as integer   initial ?
    field nbfer             as integer   initial ?
    field nbint             as integer   initial ?
    field nblet             as integer   initial ?
    field nblog             as integer   initial ?
    field nbmch             as integer   initial ?
    field nbpkg             as integer   initial ?
    field nbppe             as integer   initial ?
    field nbpte             as integer   initial ?
    field nbptecf           as integer   initial ?
    field nbssi             as integer   initial ?
    field nbsss             as integer   initial ?
    field nbsurpres         as integer   initial ?
    field nbtap             as integer   initial ?
    field nbttp             as integer   initial ?
    field nbvid             as integer   initial ?
    field nbvigik           as integer   initial ?
    field nbvoletd          as integer   initial ?
    field noblc             as integer   initial ?
    field nocad             as integer   initial ?
    field noimm             as integer   initial ?
    field nopln             as integer   initial ?
    field norol             as integer   initial ?
    field ntbie             as character initial ?
    field permis            as character initial ?
    field prefixecadastrale as character initial ?
    field sfdev             as decimal   initial ? decimals 2
    field sfhab             as decimal   initial ? decimals 2
    field sfhob             as decimal   initial ? decimals 2
    field sfhon             as decimal   initial ? decimals 2
    field sfter             as decimal   initial ? decimals 2
    field sfvet             as decimal   initial ? decimals 2
    field tpcha             as character initial ?
    field tpcst             as character initial ?
    field tpimm             as character initial ?
    field tplogoctent       as character initial ?
    field tppropriete       as character initial ?
    field tprol             as character initial ?
    field tptot             as character initial ?
    field usdev             as character initial ?
    field ushab             as character initial ?
    field ushob             as character initial ?
    field ushon             as character initial ?
    field uster             as character initial ?
    field usvet             as character initial ?
    field xcoordoneegps     as decimal   initial ? decimals 6
    field ycoordoneegps     as decimal   initial ? decimals 6

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
