/*------------------------------------------------------------------------
File        : atass.i
Purpose     : Table pour l'édition de l'attestation ASSEDIC
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAtass
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field CdAna     as integer    initial ? 
    field CdCsy     as character  initial ? 
    field CdMsy     as character  initial ? 
    field DtAdh     as date       initial ? 
    field DtCsy     as date       initial ? 
    field DtDCh     as date       initial ? 
    field DtDEm     as date       initial ? 
    field DtDIn     as date       initial ? 
    field DtDPr     as date       initial ? 
    field DtDSC     as date       initial ? 
    field DtFCh     as date       initial ? 
    field DtFEm     as date       initial ? 
    field DtFIn     as date       initial ? 
    field DtFPr     as date       initial ? 
    field DtFSC     as date       initial ? 
    field DtMsy     as date       initial ? 
    field DtNot     as date       initial ? 
    field DtplS     as date       initial ? 
    field DtPmt     as date       initial ? 
    field DtRCh     as date       initial ? 
    field FgAdh     as logical    initial ? 
    field FgAmo     as logical    initial ? 
    field FgCad     as logical    initial ? 
    field FgChP     as logical    initial ? 
    field FgChT     as logical    initial ? 
    field FgCoR     as logical    initial ? 
    field FgFNE     as logical    initial ? 
    field FgGS1     as logical    initial ? 
    field FgGS2     as logical    initial ? 
    field FgPar     as logical    initial ? 
    field FgPay     as logical    initial ? 
    field FgPlS     as logical    initial ? 
    field FgPre     as logical    initial ? 
    field FgRSS     as logical    initial ? 
    field FgS55     as logical    initial ? 
    field FgTrs     as logical    initial ? 
    field HeCsy     as integer    initial ? 
    field HeMsy     as integer    initial ? 
    field LbARC     as character  initial ? 
    field LbCPa     as character  initial ? 
    field LbCr1     as character  initial ? 
    field LbCr2     as character  initial ? 
    field lbDHo     as character  initial ? 
    field Lbdiv     as character  initial ? 
    field lbdiv2    as character  initial ? 
    field lbdiv3    as character  initial ? 
    field Lbdpt     as integer    initial ? 
    field LbEmp     as character  initial ? 
    field LbEpa     as character  initial ? 
    field LbGS1     as character  initial ? 
    field LbGS2     as character  initial ? 
    field LbJur     as character  initial ? 
    field LbLic     as character  initial ? 
    field LbNiv     as character  initial ? 
    field Lbpar     as character  initial ? 
    field LbPay     as character  initial ? 
    field LbPrm     as character  initial ? 
    field LbRSS     as character  initial ? 
    field LbRt1     as character  initial ? 
    field LbRt2     as character  initial ? 
    field Lbrt3     as character  initial ? 
    field LbSC1     as character  initial ? 
    field LbSPa     as character  initial ? 
    field LbTra     as character  initial ? 
    field Mtcho     as decimal    initial ?  decimals 2
    field MtInL     as decimal    initial ?  decimals 2
    field MtSC1     as decimal    initial ?  decimals 2
    field MtSC2     as decimal    initial ?  decimals 2
    field MtSC3     as decimal    initial ?  decimals 2
    field MtSC4     as decimal    initial ?  decimals 2
    field MtSC5     as decimal    initial ?  decimals 2
    field MtSC6     as decimal    initial ?  decimals 2
    field MtSc7     as decimal    initial ?  decimals 2
    field NbEAn     as integer    initial ? 
    field NbEHb     as integer    initial ? 
    field NbETo     as integer    initial ? 
    field NbHSC     as integer    initial ? 
    field NbJSC     as integer    initial ? 
    field NbSal     as integer    initial ? 
    field NbSAn     as integer    initial ? 
    field NbSHb     as integer    initial ? 
    field NoAtt     as integer    initial ? 
    field Nocvt     as integer    initial ? 
    field NoMdt     as integer    initial ? 
    field norev     as integer    initial ? 
    field Norol     as int64      initial ? 
    field norol-dec as decimal    initial ?  decimals 0
    field NoRSS     as character  initial ? 
    field TbDtD     as date       initial ? 
    field TbDtF     as date       initial ? 
    field TbDtP     as date       initial ? 
    field TbLbO     as character  initial ? 
    field TbMtB     as decimal    initial ?  decimals 2
    field TbMtP     as decimal    initial ?  decimals 2
    field TbNbH     as integer    initial ? 
    field TbNbJ     as integer    initial ? 
    field TpAff     as character  initial ? 
    field TpARC     as character  initial ? 
    field TpCPa     as character  initial ? 
    field TpDHo     as character  initial ? 
    field TpEpa     as character  initial ? 
    field TpIni     as character  initial ? 
    field Tplic     as character  initial ? 
    field tpmdt     as character  initial ? 
    field TpNCo     as character  initial ? 
    field TpPrm     as character  initial ? 
    field TpPub     as character  initial ? 
    field TpRet     as character  initial ? 
    field TpRol     as character  initial ? 
    field tpRup     as character  initial ? 
    field TpSPa     as character  initial ? 
    field TpSta     as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
