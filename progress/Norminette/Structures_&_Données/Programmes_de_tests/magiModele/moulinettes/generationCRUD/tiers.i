/*------------------------------------------------------------------------
File        : tiers.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTiers
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field acemp             as character  initial ? 
    field ademp             as character  initial ? 
    field cdcsy             as character  initial ? 
    field cdcv1             as character  initial ? 
    field cdcv2             as character  initial ? 
    field cdcv3             as character  initial ? 
    field cdcv4             as character  initial ? 
    field cddev             as character  initial ? 
    field cdext             as character  initial ? 
    field cdfa3             as character  initial ? 
    field cdfat             as character  initial ? 
    field cdmsy             as character  initial ? 
    field cdna1             as character  initial ? 
    field cdna2             as character  initial ? 
    field cdpr1             as character  initial ? 
    field cdpr2             as character  initial ? 
    field cdpr3             as character  initial ? 
    field cdpr4             as character  initial ? 
    field cdqua             as integer    initial ? 
    field cdsft             as character  initial ? 
    field cdsp1             as character  initial ? 
    field cdsp2             as character  initial ? 
    field cdsp3             as character  initial ? 
    field cdsp4             as character  initial ? 
    field cdst1             as character  initial ? 
    field cdst2             as character  initial ? 
    field cdst3             as character  initial ? 
    field cdsx1             as character  initial ? 
    field cdsx2             as character  initial ? 
    field cdsx3             as character  initial ? 
    field cdsx4             as character  initial ? 
    field cpemp             as character  initial ? 
    field dpna1             as character  initial ? 
    field dpna2             as character  initial ? 
    field dtar1             as date       initial ? 
    field dtcsy             as date       initial ? 
    field dtdc1             as date       initial ? 
    field dtdc2             as date       initial ? 
    field dtex1             as date       initial ? 
    field dtim1             as date       initial ? 
    field dtmsy             as date       initial ? 
    field dtna1             as date       initial ? 
    field dtna2             as date       initial ? 
    field durs1             as integer    initial ? 
    field fgco3             as logical    initial ? 
    field fgct4             as logical    initial ? 
    field fgdc1             as logical    initial ? 
    field fgdc2             as logical    initial ? 
    field fgec1             as logical    initial ? 
    field fgec2             as logical    initial ? 
    field fgna1             as logical    initial ? 
    field fgna2             as logical    initial ? 
    field FgSi              as logical    initial ? 
    field hecsy             as integer    initial ? 
    field hemsy             as integer    initial ? 
    field lapr1             as character  initial ? 
    field lapr2             as character  initial ? 
    field lapr3             as character  initial ? 
    field lapr4             as character  initial ? 
    field lbdiv             as character  initial ? 
    field lbdiv2            as character  initial ? 
    field lbdiv3            as character  initial ? 
    field lina1             as character  initial ? 
    field lina2             as character  initial ? 
    field lnjf1             as character  initial ? 
    field lnjf2             as character  initial ? 
    field lnom1             as character  initial ? 
    field lnom2             as character  initial ? 
    field lnom3             as character  initial ? 
    field lnom4             as character  initial ? 
    field lpre1             as character  initial ? 
    field lpre2             as character  initial ? 
    field lpre3             as character  initial ? 
    field lpre4             as character  initial ? 
    field lprf1             as character  initial ? 
    field lprf2             as character  initial ? 
    field lprf3             as character  initial ? 
    field lprf4             as character  initial ? 
    field MDM_date          as date       initial ? 
    field MDM_erreur        as logical    initial ? 
    field MDM_Heure         as integer    initial ? 
    field MDM_transfert     as logical    initial ? 
    field MDM_Utilisateur   as character  initial ? 
    field mtcap             as decimal    initial ?  decimals 2
    field mtpar             as decimal    initial ?  decimals 2
    field nbpar             as integer    initial ? 
    field nmemp             as character  initial ? 
    field noco1             as int64      initial ? 
    field noco2             as int64      initial ? 
    field nocon             as int64      initial ? 
    field nocon-dec         as decimal    initial ?  decimals 0
    field nopid             as character  initial ? 
    field nosec             as character  initial ? 
    field notie             as int64      initial ? 
    field pyna1             as character  initial ? 
    field pyna2             as character  initial ? 
    field reva1             as decimal    initial ?  decimals 2
    field reva2             as decimal    initial ?  decimals 2
    field reva3             as decimal    initial ?  decimals 2
    field reva4             as decimal    initial ?  decimals 2
    field revm1             as decimal    initial ?  decimals 2
    field revm2             as decimal    initial ?  decimals 2
    field revm3             as decimal    initial ?  decimals 2
    field revm4             as decimal    initial ?  decimals 2
    field sipro             as character  initial ? 
    field tpmod             as character  initial ? 
    field utds1             as character  initial ? 
    field viemp             as character  initial ? 
    field web-dateouverture as date       initial ? 
    field web-div           as character  initial ? 
    field web-fgautorise    as logical    initial ? 
    field web-fgouvert      as logical    initial ? 
    field web-id            as character  initial ? 
    field web-mdp           as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
