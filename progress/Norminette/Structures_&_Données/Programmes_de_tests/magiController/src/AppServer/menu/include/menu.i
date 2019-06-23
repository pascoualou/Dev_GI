/*------------------------------------------------------------------------
File        : menu.i
Description : dataset arborescence des menus
Author(s)   : kantena - 2016/03/20
Notes       :
------------------------------------------------------------------------*/

define temp-table ttMenuNiv0 no-undo serialize-name "ttMenu"
    field cId          as character initial ? label "" case-sensitive serialize-hidden
    field cParentId    as character initial ? label "" case-sensitive serialize-hidden
    field tpmenu       as character initial ? label "" serialize-hidden 
    field cCodeLangue  as character initial ? label "" serialize-hidden 
    field cCodeText    as character initial ? label "" serialize-hidden 
    field cText        as character initial ? label "" format "x(30)" serialize-name "label"
    field cIcone       as character initial ? label "" serialize-name "icon"
    field encoded      as logical 
/*
    field iPositionX   as integer
    field iPositionY   as integer
*/    
    field cUrl         as character initial ? label "" serialize-name "url"
    field iRang        as integer 
index p0 cId
.
define temp-table ttMenuNiv1 no-undo serialize-name "items" like ttMenuNiv0
index p1 cId
.
define temp-table ttMenuNiv2 no-undo serialize-name "items" like ttMenuNiv0
index p2 cId
.
