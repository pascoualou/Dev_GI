/*------------------------------------------------------------------------
File        : repartitionAV.i
Purpose     : 
Author(s)   : gg  -  2017/03/07
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
define temp-table ttRepartitionAV no-undo
    field cCdBat  as character
    field iNoLot  as integer
    field iNoCop  as integer
    field cNmcop  as character
    field cTpLot  as character
    field dtDtLot as date
    field iPoLot  as integer
    field dEcLot  as decimal
    field dMtApp  as decimal
    field dMtEmi  as decimal
    field iNoCol  as integer
    field CRUD    as character
    index NoLot iNoLot iNoCop dtDtLot
.
define temp-table ttInfSelRepartitionAV no-undo
    field iActifLotArrondi as integer 
    field dMtArrondi       as decimal
    field dtPresentDepuis  as date
    field CRUD             as character
    index idx01 iActifLotArrondi
.
