/*------------------------------------------------------------------------
File        : repartco.i
Purpose     : Stockage de la répartition par matric/clé/lot des charges de copropriété (c.f. TbMatLot)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRepartco
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcle               as character  initial ? 
    field cdcsy               as character  initial ? 
    field cdfisc              as character  initial ? 
    field cdmsy               as character  initial ? 
    field cdrub               as character  initial ? 
    field cdsrub              as character  initial ? 
    field cocherefac          as logical    initial ? 
    field codregr             as character  initial ? 
    field dateecriture        as date       initial ? 
    field datmut              as integer    initial ? 
    field denpro              as integer    initial ? 
    field depenseimprimee     as character  initial ? 
    field dtcsy               as date       initial ? 
    field dtmsy               as date       initial ? 
    field editiondateecriture as logical    initial ? 
    field FgRefacRecLoc       as logical    initial ? 
    field hecsy               as integer    initial ? 
    field hemsy               as integer    initial ? 
    field imputation          as character  initial ? 
    field lbdiv               as character  initial ? 
    field lbdiv2              as character  initial ? 
    field lbdiv3              as character  initial ? 
    field lbecr               as character  initial ? 
    field libreg              as character  initial ? 
    field Mdges               as character  initial ? 
    field mdreg               as character  initial ? 
    field mtfisc2             as decimal    initial ?  decimals 2
    field mtfisc4             as decimal    initial ?  decimals 2
    field mtqpfisc2           as decimal    initial ?  decimals 2
    field mtqpfisc4           as decimal    initial ?  decimals 2
    field mtqprefac           as decimal    initial ?  decimals 2
    field mtqptva             as decimal    initial ?  decimals 2
    field mtqptva2            as decimal    initial ?  decimals 2
    field mtqptva4            as decimal    initial ?  decimals 2
    field mtqptvarefac        as decimal    initial ?  decimals 2
    field mtquotepart         as decimal    initial ?  decimals 2
    field mtrefac             as decimal    initial ?  decimals 2
    field mtrepart            as decimal    initial ?  decimals 2
    field mttva               as decimal    initial ?  decimals 2
    field mttva2              as decimal    initial ?  decimals 2
    field mttva4              as decimal    initial ?  decimals 2
    field nblib               as integer    initial ? 
    field nbmil               as integer    initial ? 
    field nolot               as integer    initial ? 
    field nomat               as integer    initial ? 
    field NoMdrefac           as integer    initial ? 
    field nomdt               as integer    initial ? 
    field notrt               as integer    initial ? 
    field ntlot               as character  initial ? 
    field numdepense          as integer    initial ? 
    field numlibelle          as character  initial ? 
    field numpro              as integer    initial ? 
    field ordrereg            as integer    initial ? 
    field participe           as character  initial ? 
    field participecle        as character  initial ? 
    field Phasetrt            as character  initial ? 
    field totmil              as int64      initial ? 
    field tpmdt               as character  initial ? 
    field tptrt               as character  initial ? 
    field tricle              as integer    initial ? 
    field triMdges            as character  initial ? 
    field trirub              as integer    initial ? 
    field typedepense         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
