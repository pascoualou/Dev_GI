/*------------------------------------------------------------------------
File        : menu.p
Purpose     :
Description : droits: tdroit-it - lien entre menu et item (numItem = noite)
Author(s)   : kantena - 2016/03/20
Notes       :
Tables      : BASE inter : tutil
------------------------------------------------------------------------*/

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{menu/include/menu.i}

function rechercheLibelleMenu returns character private(pcTableNoit as character, pcTableNoMess as character, piNoItem as integer):
    /*-----------------------------------------------------------------------------
    Purpose :
    Notes   :
    -----------------------------------------------------------------------------*/
    define variable vhBuffer         as handle    no-undo.
    define variable vcNumeroMessage  as character no-undo.
    define variable vcLibelleMessage as character no-undo.

    /* Récupération de l'identifiant du libelle correspondant à "noite"*/
    create buffer vhbuffer for table pcTableNoit.
    vhBuffer:find-first(substitute("where &1.noite = &2", pcTableNoit, piNoItem), no-lock).
    if vhBuffer:available
    then do:
        vcNumeroMessage = vhbuffer::nomes.
        delete object vhBuffer no-error.
        /* Récupération du libelle correspondant à "nomes"*/
        create buffer vhbuffer for table pcTableNoMess.
        vhBuffer:find-first(substitute("where &1.nomes = &2 and &1.cdlng = &3", pcTableNoMess, vcNumeroMessage, 0), no-lock).
        if vhBuffer:available then vcLibelleMessage = vhbuffer::lbmes.
    end.
    delete object vhBuffer no-error.
    return vcLibelleMessage.

end function.

function menuItemKO returns logical private(pcProfil as character, piNumItem as integer):
/*-----------------------------------------------------------------------------
Purpose :
Notes   :
-----------------------------------------------------------------------------*/
    define buffer tdroit-it for tdroit-it.

    if pcProfil <> 'ins'
    then do:
        find first tdroit-it no-lock
            where tdroit-it.profil_u = pcProfil
              and tdroit-it.noite    = piNumItem no-error.
        return not available tdroit-it or not tdroit-it.acces.
    end.
    return false.

end function.

procedure getMenu:
/*------------------------------------------------------------------------------
Purpose:
Notes  : service utilisé par beMenu.cls
------------------------------------------------------------------------------*/
define output parameter table for ttMenuNiv0.
define output parameter table for ttMenuNiv1.
define output parameter table for ttMenuNiv2.

    define buffer tutil for tutil.

    empty temp-table ttMenuNiv0.
    empty temp-table ttMenuNiv1.
    empty temp-table ttMenuNiv2.
    for first tutil no-lock
        where tutil.ident_u = mtoken:cUser:
        run createMenu (tutil.profil_u).
    end.

end procedure.

procedure createMenu private:
    /*-----------------------------------------------------------------------------
    Purpose : Récupération des menus dans la table menuweb
    Notes   :
    -----------------------------------------------------------------------------*/
    define input parameter pcProfil as character no-undo.

    define variable vcLbMes     as character no-undo.
    define variable vctableNoIt as character no-undo.
    define variable vctableMess as character no-undo.

    define buffer menuweb for menuweb.

    {&_proparse_ prolint-nowarn(wholeindex)}
boucleWeb:
    for each menuweb no-lock
        where menuweb.lItemActif
          and menuweb.idParent = ?
           by menuweb.iOrdre:
        /* Vérification des droits*/
        if menuItemKO(pcProfil, menuweb.IdMenu) then next boucleWeb.

        assign
            vcTableNoit = substitute("&1_it", entry(1, menuweb.cPrefixe))
            vctableMess = substitute("&1_lb", entry(2, menuweb.cPrefixe))
            vcLbMes     = rechercheLibelleMenu(vcTableNoit, vctableMess, menuweb.iNumeroItem)
        .
        /* Création de l'enregistrement dans la table temporaire*/
        create ttMenuNiv0.
        assign
            ttMenuNiv0.cId       = string(menuweb.idMenu)
            ttMenuNiv0.cParentId = if menuweb.idParent <> ? then string(menuweb.idParent) else ""
            ttMenuNiv0.ctext     = vcLbMes
            ttMenuNiv0.iRang     = menuweb.iOrdre
            ttMenuNiv0.cUrl      = menuweb.cLienUrl
        .
    end.
boucleNiveau0:
    for each ttMenuNiv0
        by ttMenuNiv0.iRang:
        {&_proparse_ prolint-nowarn(wholeindex)}
        for each menuweb no-lock
            where menuweb.idParent = int64(ttMenuNiv0.cid):
            /* Existence en base du menu et Vérification des droits */
            if not available menuweb or menuItemKO(pcProfil, menuweb.IdMenu) then next boucleNiveau0.

            assign
                vcTableNoit = substitute("&1_it", entry(1, menuweb.cPrefixe))
                vctableMess = substitute("&1_lb", entry(2, menuweb.cPrefixe))
                vcLbMes     = rechercheLibelleMenu(vcTableNoit, vctableMess, menuweb.iNumeroItem)
            .
            /* Création de l'enregistrement dans la table temporaire*/
            create ttMenuNiv1.
            assign
                ttMenuNiv1.cId       = string(menuweb.idMenu)
                ttMenuNiv1.cParentId = if menuweb.idParent <> ? then string(menuweb.idParent) else ""
                ttMenuNiv1.ctext     = vcLbMes
                ttMenuNiv1.iRang     = menuweb.iOrdre
                ttMenuNiv0.cUrl      = menuweb.cLienUrl
            .
        end.
    end.
boucleNiveau1:
    for each ttMenuNiv1
        by ttMenuNiv1.iRang:
        {&_proparse_ prolint-nowarn(wholeindex)}
        for each menuweb no-lock
            where menuweb.idParent = int64(ttMenuNiv1.cid):
            /* Existence en base du menu et Vérification des droits */
            if not available (menuweb) or menuItemKO(pcProfil, menuweb.IdMenu) then next boucleNiveau1.

            assign
                vcTableNoit = substitute("&1_it", entry(1, menuweb.cPrefixe))
                vctableMess = substitute("&1_lb", entry(2, menuweb.cPrefixe))
                vcLbMes     = rechercheLibelleMenu(vcTableNoit, vctableMess, menuweb.iNumeroItem)
            .
            /* Création de l'enregistrement dans la table temporaire*/
            create ttMenuNiv2.
            assign
                ttMenuNiv2.cId       = string(menuweb.idMenu)
                ttMenuNiv2.cParentId = if menuweb.idParent <> ? then string(menuweb.idParent) else ""
                ttMenuNiv2.ctext     = vcLbMes
                ttMenuNiv2.encoded   = false
                ttMenuNiv2.iRang     = menuweb.iOrdre
                ttMenuNiv2.cUrl      = menuweb.cLienUrl
            .
        end.
    end.

end procedure.
