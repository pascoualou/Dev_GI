/*------------------------------------------------------------------------
File        : TbTmpAna.i
Purpose     :
Author(s)   : gg  -  2017/03/07
Notes       : creation a partir \gidev\comm\TbTmpAna.i
------------------------------------------------------------------------*/

define temp-table tmp-ana no-undo
    field recno        as character
    field cle          as character format "x(17)"  // like cecrlnana.ana4-cd
    field rub-cd       as character format "x(8)"   // like cecrlnana.ana1-cd
    field ssrub-cd     as character format "x(4)"   // like cecrlnana.ana2-cd
    field fisc         as character format "x(6)"   // like cecrlnana.ana3-cd
    field ana-cd       as character format "x(35)"  // like cecrlnana.ana-cd
    field piece-compta as character
    field ref-num      as character
    field datecr       as date      format "99/99/9999"
    field jou-cd       as character format "x(5)"
    field type-cle     as character format "x(5)"
    field fourn-cpt-cd as character
    field lib          as character format "x(65)"
    field lib-ecr      as character format "x(32)" extent 20
    field sens         as logical   format "Debit/Credit"
    field mttva        as decimal   decimals 2 format "->>>,>>>,>>>,>>9.99"
    field mttva-euro   as decimal   decimals 2 format "->>>,>>>,>>>,>>9.99"
    field mt           as decimal   decimals 2 format ">>>,>>>,>>>,>>9.99"
    field mt-euro      as decimal   decimals 2 format ">>>,>>>,>>>,>>9.99"
    field rgt          as character format "x(5)"
    field recno-ecr    as character
    field lig          as integer   format ">>>>>9"
    field pos          as integer   format ">>>>>9"
    field sel          as logical
    field tphono       as character /** INIT "    -    " **/
//  index ana-i   cle          rub-cd       ssrub-cd datecr piece-compta fisc rgt lig pos
//  index ana-fac fourn-cpt-cd piece-compta
//  index ana-rgt rgt
//  index ana-sel sel          datecr
.
