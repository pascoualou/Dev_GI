/*------------------------------------------------------------------------
File        : outilTraduction.cls
Purpose     : classe singleton des outils de traduction
Author(s)   : kantena - 2016/03/23
Notes       : lib   --> getLibelle,
              libPr --> getLibelleParam, libpg --> getLibeleProg
Tables      : BASE sadb   :  ladrs adres
              BASE ladb   : sys_lb sys_pg sys_pr
              BASE compta : CcptCol
              BASE inter  : ifour
----------------------------------------------------------------------*/

block-level on error undo, throw.

class outils.outilTraduction use-widget-pool final:
    /*------------------------------------------------------------------------------
    purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define public static property mToken as class oerealm.token no-undo get. set.

    method private static character getLibelleTable(pcNomTable as character, pcTypeParametre as character, pcCodeParametre as character, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine traduite du libellé long du code parametre en parametre
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhBuffer         as handle    no-undo.
        define variable vcLibelleTraduit as character no-undo.

        {&_proparse_ prolint-nowarn(when)}
        assign
            piCodeLangueSession   = 0 when piCodeLangueSession = ?
            piCodeLangueReference = 0 when piCodeLangueReference = ?
        .
        create buffer vhBuffer for table pcNomTable.
        vhBuffer:find-first(substitute('where &1.tppar = "&2" and &1.cdpar = "&3"', vhBuffer:table, pcTypeParametre, pcCodeParametre), no-lock) no-error.
        if vhBuffer:available then vcLibelleTraduit = getLibelle(vhBuffer::nome1, piCodeLangueSession, piCodeLangueReference).
        if vcLibelleTraduit = "-" then vcLibelleTraduit = "".
        delete object vhBuffer no-error.
        return vcLibelleTraduit.

    end method.

    method private static character getLibelleCourtTable(pcNomTable as character, pcTypeParametre as character, pcCodeParametre as character, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine traduite du libellé court du code parametre en parametre
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhBuffer         as handle    no-undo.
        define variable vcLibelleTraduit as character no-undo.

        {&_proparse_ prolint-nowarn(when)}
        assign
            piCodeLangueSession   = 0 when piCodeLangueSession = ?
            piCodeLangueReference = 0 when piCodeLangueReference = ?
        .
        create buffer vhBuffer for table pcNomTable.
        vhBuffer:find-first(substitute('where &1.tppar = "&2" and &1.cdpar = "&3"', vhBuffer:table, pcTypeParametre, pcCodeParametre), no-lock) no-error.
        if vhBuffer:available then vcLibelleTraduit = getLibelle(vhBuffer::nome2, piCodeLangueSession, piCodeLangueReference).
        if vcLibelleTraduit = "-" then vcLibelleTraduit = "".
        delete object vhBuffer no-error.
        return vcLibelleTraduit.

    end method.

    method public static character getLibelleTable(pcNomTable as character, piNumeroMessage as integer, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        Purpose: retourne la chaine traduite du libellé long du n° de message en parametre
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhBuffer         as handle    no-undo.
        define variable vcLibelleTraduit as character no-undo.

        {&_proparse_ prolint-nowarn(when)}
        assign
            piCodeLangueSession   = 0 when piCodeLangueSession = ?
            piCodeLangueReference = 0 when piCodeLangueReference = ?
        .
        create buffer vhBuffer for table pcNomTable.
        vhBuffer:find-first(substitute('where &1.nomes = &2 and &1.cdlng = &3', vhBuffer:table, piNumeroMessage, piCodeLangueSession), no-lock) no-error.
        if not vhBuffer:available
        then vhBuffer:find-first(substitute('where &1.nomes = &2 and &1.cdlng = &3', vhBuffer:table, piNumeroMessage, piCodeLangueReference)) no-error.
        vcLibelleTraduit = if not vhBuffer:available then substitute("?.&1.?", string(piNumeroMessage)) else vhBuffer::lbmes.
        if vcLibelleTraduit = "-" then vcLibelleTraduit = "".
        delete object vhBuffer no-error.
        return vcLibelleTraduit.

    end method.

    method public static character getLibelleParam (pcTypeParametre as character, pcCodeParametre as character, pcCourtLong as character):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine du libellé long du type parametre dans la langue du token
        Notes  : court: 'c', long: autre
        ------------------------------------------------------------------------------*/
        if valid-object(mToken)
        then if pcCourtLong = 'c'
        then return getLibelleCourtTable("sys_pr", pcTypeParametre, pcCodeParametre,  mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else return getLibelleTable("sys_pr", pcTypeParametre, pcCodeParametre,  mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else if pcCourtLong = 'c'
        then return getLibelleCourtTable("sys_pr", pcTypeParametre, pcCodeParametre, 0, 0).
        else return getLibelleTable("sys_pr", pcTypeParametre, pcCodeParametre, 0, 0).

    end method.

    method public static character getLibelleParam (pcTypeParametre as character, pcCodeParametre as character):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine du libellé long du type parametre dans la langue du token
        Notes  :
        ------------------------------------------------------------------------------*/
        if valid-object(mToken)
        then return getLibelleTable("sys_pr", pcTypeParametre, pcCodeParametre, mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else return getLibelleTable("sys_pr", pcTypeParametre, pcCodeParametre, 0, 0).

    end method.

    method public static character getLibelleParam(pcTypeParametre as character, pcCodeParametre as character, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine du libellé long du type parametre dans la langue passée en paramètre
        Notes  :
        ------------------------------------------------------------------------------*/
        return getLibelleTable("sys_pr", pcTypeParametre, pcCodeParametre, piCodeLangueSession, piCodeLangueReference).

    end method.

    method public static character getLibelleProg (pcTypeParametre as character, pcCodeParametre as character, pcCourtLong as character):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine du libellé long du type parametre dans la langue du token
        Notes  : court: 'c', long: autre
        ------------------------------------------------------------------------------*/
        if valid-object(mToken)
        then if pcCourtLong = 'c'
        then return getLibelleCourtTable("sys_pg", pcTypeParametre, pcCodeParametre,  mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else return getLibelleTable("sys_pg", pcTypeParametre, pcCodeParametre,  mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else if pcCourtLong = 'c'
        then return getLibelleCourtTable("sys_pg", pcTypeParametre, pcCodeParametre, 0, 0).
        else return getLibelleTable("sys_pg", pcTypeParametre, pcCodeParametre, 0, 0).

    end method.

    method public static character getLibelleProg (pcTypeParametre as character, pcCodeParametre as character):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine du libellé long du type programme dans la langue du token
        Notes  :
        ------------------------------------------------------------------------------*/
        if valid-object(mToken)
        then return getLibelleProg(pcTypeParametre, pcCodeParametre, mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else return getLibelleProg(pcTypeParametre, pcCodeParametre, 0, 0).

    end method.

    method public static character getLibelleProg (pcTypeParametre as character, pcCodeParametre as character, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine du libellé long du type programme dans la langue passée en paramètre
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vcLibelleTraduit as character no-undo.

        vcLibelleTraduit = getLibelleTable("sys_pg", pcTypeParametre, pcCodeParametre, piCodeLangueSession, piCodeLangueReference).
        /* Cas particuliers Natures de bail */
        if pcTypeParametre = "O_COT" then vcLibelleTraduit = DonneLibelleNatureBail(pcCodeParametre, vcLibelleTraduit, piCodeLangueSession, piCodeLangueReference).
        return vcLibelleTraduit.

    end method.

    method private static character getLibelleTableZone2(pcNomTable as character, pcTypeParametre as character, pcCodeZone1 as character, pcCodeZone2 as character, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine traduite du libellé long du code parametre en parametre
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhBuffer         as handle    no-undo.
        define variable vcLibelleTraduit as character no-undo.

        {&_proparse_ prolint-nowarn(when)}
        assign
            piCodeLangueSession   = 0 when piCodeLangueSession = ?
            piCodeLangueReference = 0 when piCodeLangueReference = ?
        .
        create buffer vhBuffer for table pcNomTable.
        vhBuffer:find-first(substitute('where &1.tppar = "&2" and &1.zone1 = "&3" and &1.zone2 = "&4"', vhBuffer:table, pcTypeParametre, pcCodeZone1, pcCodeZone2), no-lock) no-error.
        if vhBuffer:available then vcLibelleTraduit = getLibelle(vhBuffer::nome1, piCodeLangueSession, piCodeLangueReference).
        delete object vhBuffer no-error.
        return vcLibelleTraduit.

    end method.

    method private static character getLibelleCourtTableZone2(pcNomTable as character, pcTypeParametre as character, pcCodeZone1 as character, pcCodeZone2 as character, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine traduite du libellé long du code parametre en parametre
        Notes  :
        ------------------------------------------------------------------------------*/
        define variable vhBuffer         as handle    no-undo.
        define variable vcLibelleTraduit as character no-undo.

        {&_proparse_ prolint-nowarn(when)}
        assign
            piCodeLangueSession   = 0 when piCodeLangueSession = ?
            piCodeLangueReference = 0 when piCodeLangueReference = ?
        .
        create buffer vhBuffer for table pcNomTable.
        vhBuffer:find-first(substitute('where &1.tppar = "&2" and &1.zone1 = "&3" and &1.zone2 = "&4"', vhBuffer:table, pcTypeParametre, pcCodeZone1, pcCodeZone2), no-lock) no-error.
        if vhBuffer:available then vcLibelleTraduit = getLibelle(vhBuffer::nome2, piCodeLangueSession, piCodeLangueReference).
        delete object vhBuffer no-error.
        return vcLibelleTraduit.

    end method.

    method public static character getLibelleProgZone2 (pcTypeParametre as character, pcCodeZone1 as character, pcCodeZone2 as character):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine du libellé long du type programme dans la langue passée en paramètre
        Notes  : utilise zone1 et zone2 au lieu de cdpar
        ------------------------------------------------------------------------------*/
        define variable vcLibelleTraduit as character no-undo.

        vcLibelleTraduit = getLibelleTableZone2("sys_pg", pcTypeParametre, pcCodeZone1, pcCodeZone2, mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        return vcLibelleTraduit.

    end method.

    method public static character getLibelleProgZone2 (pcTypeParametre as character, pcCodeZone1 as character, pcCodeZone2 as character, pcCourtLong as character):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine du libellé long du type programme dans la langue passée en paramètre
        Notes  : utilise zone1 et zone2 au lieu de cdpar
        ------------------------------------------------------------------------------*/
        define variable vcLibelleTraduit as character no-undo.

        if pcCourtLong = 'c'
        then vcLibelleTraduit = getLibelleCourtTableZone2("sys_pg", pcTypeParametre, pcCodeZone1, pcCodeZone2, mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else vcLibelleTraduit = getLibelleTableZone2     ("sys_pg", pcTypeParametre, pcCodeZone1, pcCodeZone2, mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        return vcLibelleTraduit.

    end method.

    method public static character DonneLibelleNatureBail (pcNature as character, pcLibelleInitial as character):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine du libellé long d'une nature de bail dans la langue du token
        Notes  : Si un libellé initial est fourni en entrée, il est pris par défaut.
                 Sinon, c'est le libellé GI (sys_pg) qui est pris par défaut.
                 Dans tous les cas, si un libellé spécifique est défini, c'est ce dernier qui est pris.
        ------------------------------------------------------------------------------*/
        if valid-object(mToken)
        then return DonneLibelleNatureBail(pcNature, pcLibelleInitial, mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else return DonneLibelleNatureBail(pcNature, pcLibelleInitial, 0, 0).

    end method.

    method public static character DonneLibelleNatureBail (pcNature as character, pcLibelleInitial as character, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        purpose: retourne la chaine du libellé long d'une nature de bail dans la langue passée en paramètre
        Notes  : Cf ci-dessus
        ------------------------------------------------------------------------------*/
        define variable vhBuffer         as handle    no-undo.
        define variable vcLibelleTraduit as character no-undo.

        create buffer vhBuffer for table "pclie".
        vhBuffer:find-first(substitute('where &1.tppar = "DEFBX" and &1.zon01 = "&2"', vhBuffer:table, pcNature), no-lock) no-error.
        vcLibelleTraduit = if vhBuffer:available and vhBuffer::lbdiv > ''
                  then vhBuffer::lbdiv
                  else if pcLibelleInitial > ""
                       then pcLibelleInitial
                       else getLibelleTable("sys_pg", "O_COT", pcNature, piCodeLangueSession, piCodeLangueReference).
        delete object vhBuffer no-error.
        return vcLibelleTraduit.

    end method.

    method public static character getLibelle(piNumeroMessage as integer):
        /*------------------------------------------------------------------------------
        Purpose: retourne la chaine dans la langue passée en paramètre
        Notes  : pour un n° de label
        ------------------------------------------------------------------------------*/
        if valid-object(mToken)
        then return getLibelleTable("sys_lb", piNumeroMessage, mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else return getLibelleTable("sys_lb", piNumeroMessage, 0, 0).

    end method.

    method public static character getLibelle(piNumeroMessage as integer, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        Purpose: retourne la chaine dans la langue du token
        Notes  : pour un n° de label
        ------------------------------------------------------------------------------*/
        return getLibelleTable("sys_lb", piNumeroMessage, piCodeLangueSession, piCodeLangueReference).

    end method.

    method public static character getLibelleCompta (piNumeroMessage as integer):
        /*------------------------------------------------------------------------------
        Purpose: retourne la chaine de la base compta dans la langue du token
        Notes  :
        ------------------------------------------------------------------------------*/
        if valid-object(mToken)
        then return getLibelleTable("com_lb", piNumeroMessage, mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else return getLibelleTable("com_lb", piNumeroMessage, 0, 0).

    end method.

    method public static character getLibelleCompta(piNumeroMessage as integer, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        Purpose: retourne la chaine de la base compta dans la langue passée en paramètre
        Notes  : pour un n° de label (sous format de char)
        ------------------------------------------------------------------------------*/
        return getLibelleTable("com_lb", piNumeroMessage, piCodeLangueSession, piCodeLangueReference).

    end method.

    method public static character getLibelleTransfert (piNumeroMessage as integer):
        /*------------------------------------------------------------------------------
        Purpose: retourne la chaine de la base compta dans la langue du token
        Notes  :
        ------------------------------------------------------------------------------*/
        if valid-object(mToken)
        then return getLibelleTable("trf_lb", piNumeroMessage, mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else return getLibelleTable("trf_lb", piNumeroMessage, 0, 0).

    end method.

    method public static character getLibelleTransfert(piNumeroMessage as integer, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        Purpose: retourne la chaine de la base compta dans la langue passée en paramètre
        Notes  : pour un n° de label (sous format de char)
        ------------------------------------------------------------------------------*/
        return getLibelleTable("trf_lb", piNumeroMessage, piCodeLangueSession, piCodeLangueReference).

    end method.

    method public static character getLibelle(pcNumeroMessage as character):
        /*------------------------------------------------------------------------------
        Purpose: retourne la chaine dans la langue du token
        Notes  : pour un n° de label (sous format de char)
        ------------------------------------------------------------------------------*/
        if valid-object(mToken)
        then return getLibelle(pcNumeroMessage, mToken:iCodeLangueSession, mToken:iCodeLangueReference).
        else return getLibelle(pcNumeroMessage, 0, 0).

    end method.

    method public static character getLibelle(pcNumeroMessage as character, piCodeLangueSession as integer, piCodeLangueReference as integer):
        /*------------------------------------------------------------------------------
        Purpose: retourne la chaine dans la langue passée en paramètre
        Notes  : pour un n° de label (sous format de char)
        ------------------------------------------------------------------------------*/
        define variable viNumeroMessage  as integer   no-undo.

        viNumeroMessage = integer(pcNumeroMessage) no-error.
        return if error-status:error
               then substitute("?.&1.?", pcNumeroMessage)
               else getLibelleTable("sys_lb", viNumeroMessage, piCodeLangueSession, piCodeLangueReference).

    end method.

end class.
