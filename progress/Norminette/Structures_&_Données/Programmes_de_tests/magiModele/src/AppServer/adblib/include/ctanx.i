/*------------------------------------------------------------------------
File        : ctanx.i
Purpose     : 
Author(s)   : GGA - 2017/11/13
Notes       :
derniere revue: 2018/04/27 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCtanx
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field dtcsy     as date
    field hecsy     as integer   initial ?
    field cdcsy     as character initial ?
    field dtmsy     as date
    field hemsy     as integer   initial ?
    field cdmsy     as character initial ?
    field nodoc     as int64     initial ?
    field tpcon     as character initial ?
    field nocon     as int64     initial ?
    field dtdeb     as date
    field dtfin     as date
    field tpfin     as character initial ?
    field duree     as integer   initial ?
    field dtsig     as date
    field lisig     as character initial ?
    field dtree     as date
    field noree     as integer   initial ?
    field tpren     as character initial ?
    field nbres     as integer   initial ?
    field tpact     as character initial ?
    field noref     as integer   initial ?
    field pcpte     as integer   initial ?
    field scpte     as integer   initial ?
    field cdreg     as character initial ?
    field tpuni     as character initial ?
    field mtcap     as character initial ?
    field lbreg     as character initial ?
    field nosir     as integer   initial ?
    field cdnic     as character initial ?
    field lbprf     as character initial ?
    field cdjur     as character initial ?
    field cdape     as character initial ?
    field cdobj     as character initial ?
    field mtcau     as decimal   initial ? decimals 2
    field ntcau     as character initial ?
    field cdbqu     as character initial ?
    field cdgui     as character initial ?
    field nocpt     as character initial ?
    field norib     as integer   initial ?
    field lbdom     as character initial ?
    field tpbqu     as character initial ?
    field lbtit     as character initial ?
    field cptbq     as integer   initial ?
    field lnnot     as character initial ?
    field Liexe     as character initial ?
    field tprol     as character initial ?
    field norol     as integer   initial ?
    field mtcau-dev as decimal   initial ? decimals 2
    field cddev     as character initial ?
    field lbdiv     as character initial ?
    field lbdiv2    as character initial ?
    field lbdiv3    as character initial ?
    field iban      as character initial ?
    field bicod     as character initial ?
    field fgetr     as logical   initial ?
    field cptetr    as character initial ?
    field nocon-dec as decimal   initial ? decimals 0
    field norol-dec as decimal   initial ? decimals 0
    field cdsie     as character initial ?
    field norum-ger as character initial ?
    field norum-cop as character initial ?
    field norum-anc as character initial ? extent 2
    field dtsig-sep as date                extent 2
    field dtree-sep as date                extent 2
    field dtder-sep as date                extent 2
    field smnda     as logical   initial ? extent 2
    field ics       as character initial ? extent 2
    field cSIREN    as character initial ?
    field lbdiv4    as character initial ?
    field lbdiv5    as character initial ?
    field lbdiv6    as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
