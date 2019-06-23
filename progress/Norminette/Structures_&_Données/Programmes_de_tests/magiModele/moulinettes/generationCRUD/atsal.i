/*------------------------------------------------------------------------
File        : atsal.i
Purpose     : attestations de salaire pour la SS
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAtsal
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field admed     as character  initial ? 
    field asstiers  as character  initial ? 
    field c3sal     as character  initial ? 
    field cdcst     as character  initial ? 
    field cdcsy     as character  initial ? 
    field cddec     as character  initial ? 
    field cdmot     as character  initial ? 
    field cdmsy     as character  initial ? 
    field cdnat     as character  initial ? 
    field cdrep     as character  initial ? 
    field cdsal     as character  initial ? 
    field cdsuite   as character  initial ? 
    field dtacc     as date       initial ? 
    field dtatt     as date       initial ? 
    field dtcst     as date       initial ? 
    field dtcsy     as date       initial ? 
    field dtctt     as date       initial ? 
    field dtdbs     as date       initial ? 
    field dtdeb     as date       initial ? 
    field dtder     as date       initial ? 
    field dtdr1     as date       initial ? 
    field dtdr2     as date       initial ? 
    field dtfin     as date       initial ? 
    field dtfis     as date       initial ? 
    field dtfr1     as date       initial ? 
    field dtfr2     as date       initial ? 
    field dtinf     as date       initial ? 
    field dtmsy     as date       initial ? 
    field dtrep     as date       initial ? 
    field faita     as character  initial ? 
    field fg200     as logical    initial ? 
    field fg800     as logical    initial ? 
    field fgarret   as logical    initial ? 
    field fgdec     as logical    initial ? 
    field fggen     as logical    initial ? 
    field fginf     as logical    initial ? 
    field fgrap     as logical    initial ? 
    field fgrep     as logical    initial ? 
    field fgsub     as logical    initial ? 
    field fgtb2     as logical    initial ? 
    field fgtb3     as logical    initial ? 
    field fgtiers   as logical    initial ? 
    field fgvic     as logical    initial ? 
    field foracc    as character  initial ? 
    field heacc     as character  initial ? 
    field hecst     as character  initial ? 
    field hecsy     as integer    initial ? 
    field hedeb1    as character  initial ? 
    field hedeb2    as character  initial ? 
    field hefin1    as character  initial ? 
    field hefin2    as character  initial ? 
    field hemsy     as integer    initial ? 
    field hopital   as character  initial ? 
    field lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field lbemp     as character  initial ? 
    field lblesion  as character  initial ? 
    field lbnom     as character  initial ? 
    field lbsit     as character  initial ? 
    field lbtiers   as character  initial ? 
    field lieuacc   as character  initial ? 
    field mtcot     as decimal    initial ?  decimals 2
    field mtrg1     as decimal    initial ?  decimals 2
    field mtrg2     as decimal    initial ?  decimals 2
    field nmmed     as character  initial ? 
    field nmrapp    as character  initial ? 
    field nmsig     as character  initial ? 
    field noatt     as integer    initial ? 
    field noblc     as integer    initial ? 
    field noctt     as character  initial ? 
    field noinf     as character  initial ? 
    field nomdt     as integer    initial ? 
    field norol     as int64      initial ? 
    field norol-dec as decimal    initial ?  decimals 0
    field ntlesion  as character  initial ? 
    field quali     as character  initial ? 
    field risqu     as character  initial ? 
    field salmin    as decimal    initial ?  decimals 2
    field t2bru     as decimal    initial ?  decimals 2
    field t2cot     as decimal    initial ?  decimals 2
    field t2dt1     as date       initial ? 
    field t2dt2     as date       initial ? 
    field t2ver     as date       initial ? 
    field t3abs     as character  initial ? 
    field t3bru     as decimal    initial ?  decimals 2
    field t3cot     as decimal    initial ?  decimals 2
    field t3dt1     as date       initial ? 
    field t3dt2     as date       initial ? 
    field tbavn     as decimal    initial ?  decimals 2
    field tbcot     as decimal    initial ?  decimals 2
    field TbDetAcc  as character  initial ? 
    field tbdt1     as date       initial ? 
    field tbdt2     as date       initial ? 
    field tbech     as date       initial ? 
    field tbfr2     as decimal    initial ?  decimals 2
    field tbfrs     as decimal    initial ?  decimals 2
    field tbhef     as decimal    initial ?  decimals 2
    field tbhtc     as decimal    initial ?  decimals 2
    field tbmot     as character  initial ? 
    field tbpri     as decimal    initial ?  decimals 2
    field tbsal     as decimal    initial ?  decimals 2
    field tbsar     as decimal    initial ?  decimals 2
    field Tbtemoin  as character  initial ? 
    field tpatt     as character  initial ? 
    field tprol     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
