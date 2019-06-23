/*------------------------------------------------------------------------
File        : crebail.p
Purpose     : Création des baux rang 00 sur une ou toutes les UL d'un mandat
Author(s)   : SY 05/09/2006  -  GGA  2017/08/21
Notes       : a partir de adb/cont/crebail.p
------------------------------------------------------------------------*/
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}
{preprocesseur/type2tache.i}

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{adblib/include/ctrat.i}
{adblib/include/ctctt.i}
{adblib/include/intnt.i}
{role/include/role.i}
{tache/include/tache.i}
{adblib/include/cttac.i}
{adresse/include/ladrs.i}
{outils/include/lancementProgramme.i}

define variable ghProc as handle no-undo.
define variable goCollectionHandlePgm as class collection no-undo.

function numeroImmeuble return integer private(piNumeroMandat as int64, pcTypeMandat as character):
    /*------------------------------------------------------------------------------
    Purpose: recherche immeuble du mandat
    Notes  :
    ------------------------------------------------------------------------------*/
    define buffer intnt for intnt.

    for first intnt no-lock
        where intnt.tpcon = pcTypeMandat
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble}:
        return intnt.noidt.
    end.
    mError:createErrorGestion({&error}, 106470, string(piNumeroMandat)). //immeuble non trouve pour mandat %1
    return 0.

end function.

procedure lancementCrebail:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : service externe
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat       as character no-undo.
    define input parameter piNumeroMandat     as int64     no-undo.
    define input parameter pcTypeBailACreer   as character no-undo.
    define input parameter pcNatureBailACreer as character no-undo.

    define buffer unite for unite.

    goCollectionHandlePgm = new collection().
    for each unite no-lock
       where unite.nomdt = piNumeroMandat
         and unite.noapp < 997
         and unite.noact = 0:
         run creationBail (pcTypeMandat, piNumeroMandat, pcTypeBailACreer, pcNatureBailACreer, int64(string(piNumeroMandat, "99999") + string(unite.noapp, "999") + "00")).
    end.
    suppressionPgmPersistent(goCollectionHandlePgm).
    delete object goCollectionHandlePgm.

end procedure.

procedure creationBail private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeMandat       as character no-undo.
    define input parameter piNumeroMandat     as int64     no-undo.
    define input parameter pcTypeBailACreer   as character no-undo.
    define input parameter pcNatureBailACreer as character no-undo.
    define input parameter piNumeroBailACreer as int64     no-undo.

    define variable viNumeroTiers    as int64 no-undo.
    define variable viNumeroImmeuble as int64 no-undo.

    define buffer ctrat for ctrat.
    define buffer ladrs for ladrs.
    define buffer vbroles for roles.

    if can-find(first ctrat no-lock
                where ctrat.tpcon = pcTypeBailACreer
                  and ctrat.nocon = piNumeroBailACreer)
    then return.
    find first ctrat no-lock
         where ctrat.tpcon = pcTypeMandat
           and ctrat.nocon = piNumeroMandat no-error.
    if not available ctrat
    then return.
    find first vbroles no-lock
         where vbroles.tprol = ctrat.tprol
           and vbroles.norol = ctrat.norol no-error.
    if not available vbroles
    then return.
    viNumeroTiers = vbroles.notie.
    viNumeroImmeuble = numeroImmeuble(ctrat.nocon, ctrat.tpcon).
    if mError:erreur() then return.
    empty temp-table ttCtrat.
    empty temp-table ttCtctt.
    empty temp-table ttRole.
    empty temp-table ttIntnt.
    empty temp-table ttTache.
    empty temp-table ttCttac.
    empty temp-table ttLadrs.
    create ttCtrat.
    assign
        ttCtrat.CRUD   = "C"
        ttCtrat.tpcon  = pcTypeBailACreer
        ttCtrat.nocon  = piNumeroBailACreer
        ttCtrat.ntcon  = pcNatureBailACreer
        ttCtrat.fgprov = no
        ttCtrat.dtdeb  = ctrat.dtini
        ttCtrat.dtfin  = ctrat.dtini
        ttCtrat.tpfin  = "40002"
        ttCtrat.nbdur  = 99
        ttCtrat.cddur  = "00001"
        ttCtrat.dtsig  = ctrat.dtsig
        ttCtrat.lisig  = ctrat.lisig
        ttCtrat.dtree  = ctrat.dtini
        ttCtrat.noree  = "VACANT"
        ttCtrat.tpren  = "00001"
        ttCtrat.nbres  = 3
        ttCtrat.utres  = "00002"
        ttCtrat.tpact  = "00000"
        ttCtrat.tprol  = {&TYPEROLE-locataire}
        ttCtrat.norol  = piNumeroBailACreer
        ttCtrat.lbnom  = ctrat.lbnom
        ttCtrat.lnom2  = ctrat.lnom2
        ttCtrat.noave  = 0
        ttCtrat.dtini  = ctrat.dtini
    .
    ghProc = lancementPgm("adblib/ctrat_CRUD.p", goCollectionHandlePgm).
    run setCtrat in ghProc(table ttCtrat by-reference).
    if mError:erreur() then return.

    //Generation d'un Enregistrement "nouveau bail/mandat" dans ctctt
    create ttCtctt.
    assign
        ttCtctt.CRUD  = "C"
        ttCtctt.tpct1 = pcTypeMandat
        ttCtctt.noct1 = piNumeroMandat
        ttCtctt.tpct2 = pcTypeBailACreer
        ttCtctt.noct2 = piNumeroBailACreer
    .
    ghProc = lancementPgm("adblib/ctctt_CRUD.p", goCollectionHandlePgm).
    run setCtctt in ghProc(table ttCtctt by-reference).
    if mError:erreur() then return.

    //Creation du nouveau roles Le propriétaire
    create ttRole.
    assign
        ttRole.CRUD  = "C"
        ttRole.cCodeTypeRole = {&TYPEROLE-locataire}
        ttRole.iNumeroRole   = piNumeroBailACreer
        ttRole.iNumeroTiers  = viNumeroTiers
    .
    ghProc = lancementPgm("role/roles_CRUD.p", goCollectionHandlePgm).
    run setRoles in ghProc(table ttRole by-reference).
    if mError:erreur() then return.

    //Duplication adresse propriétaire
    for first ladrs no-lock
        where ladrs.tpidt = ctrat.tprol
          and ladrs.noidt = ctrat.norol
          and ladrs.tpadr = "00001":
        create ttLadrs.
        outils:copyValidField(buffer ladrs:handle, buffer ttLadrs:handle).
        assign
            ttLadrs.nolie = 0
            ttLadrs.tpidt = {&TYPEROLE-locataire}
            ttLadrs.noidt = piNumeroBailACreer
            ttLadrs.CRUD  = "C"
        .
        ghProc = lancementPgm("adresse/ladrs_CRUD.p", goCollectionHandlePgm).
        run setLadrs in ghProc(table ttLadrs by-reference).
        if mError:erreur() then return.

        //duplication telephone
        ghProc = lancementPgm("adresse/fcttelep.p", goCollectionHandlePgm).
        run dupliqueTelephones in ghProc(ctrat.tprol, ctrat.norol, {&TYPEROLE-locataire}, piNumeroBailACreer).
        if mError:erreur() then return.

    end.

    //Generation des Enregistrements dans INTNT.
    if not can-find(first intnt no-lock
                    where intnt.tpcon = pcTypeBailACreer
                      and intnt.nocon = piNumeroBailACreer
                      and intnt.tpidt = {&TYPEROLE-mandant}
                      and intnt.noidt = ctrat.norol)
    then do:
        create ttIntnt.
        assign
            ttIntnt.CRUD  = 'C'
            ttIntnt.tpidt = {&TYPEROLE-mandant}
            ttIntnt.noidt = ctrat.norol
            ttIntnt.tpcon = pcTypeBailACreer
            ttIntnt.nocon = piNumeroBailACreer
            ttIntnt.nbnum = 0
            ttIntnt.idsui = 0
            ttIntnt.nbden = 0
            ttIntnt.cdreg = ""
            ttIntnt.lbdiv = ""
        .
    end.
    if not can-find(first intnt no-lock
                    where intnt.tpcon = pcTypeBailACreer
                      and intnt.nocon = piNumeroBailACreer
                      and intnt.tpidt = {&TYPEROLE-locataire}
                      and intnt.noidt = piNumeroBailACreer)
    then do:
        create ttIntnt.
        assign
            ttIntnt.CRUD  = 'C'
            ttIntnt.tpidt = {&TYPEROLE-locataire}
            ttIntnt.noidt = piNumeroBailACreer
            ttIntnt.tpcon = pcTypeBailACreer
            ttIntnt.nocon = piNumeroBailACreer
            ttIntnt.nbnum = 0
            ttIntnt.idsui = 0
            ttIntnt.nbden = 0
            ttIntnt.cdreg = ""
            ttIntnt.lbdiv = ""
        .
    end.
    if not can-find(first intnt no-lock
                    where intnt.tpcon = pcTypeBailACreer
                      and intnt.nocon = piNumeroBailACreer
                      and intnt.tpidt = {&TYPEBIEN-immeuble}
                      and intnt.noidt = viNumeroImmeuble)
    then do:
        create ttIntnt.
        assign
            ttIntnt.CRUD  = 'C'
            ttIntnt.tpidt = {&TYPEBIEN-immeuble}
            ttIntnt.noidt = viNumeroImmeuble
            ttIntnt.tpcon = pcTypeBailACreer
            ttIntnt.nocon = piNumeroBailACreer
            ttIntnt.nbnum = 0
            ttIntnt.idsui = 0
            ttIntnt.nbden = 0
            ttIntnt.cdreg = ""
            ttIntnt.lbdiv = ""
        .
    end.
    ghProc = lancementPgm("adblib/intnt_CRUD.p", goCollectionHandlePgm).
    run setIntnt in ghProc(table ttIntnt by-reference).
    if mError:erreur() then return.

    //Generation tache quittancement
    if not can-find(first cttac no-lock
                    where cttac.tpcon = pcTypeBailACreer
                      and cttac.nocon = piNumeroBailACreer
                      and cttac.tptac = {&TYPETACHE-quittancement})
    then do:
        create ttTache.
        assign
            ttTache.CRUD  = "C"
            ttTache.noita = 0
            ttTache.tptac = {&TYPETACHE-quittancement}
            ttTache.notac = 1
            ttTache.tpcon = pcTypeBailACreer
            ttTache.nocon = piNumeroBailACreer
            ttTache.dtdeb = ctrat.dtini
            ttTache.dtfin = ctrat.dtini
            ttTache.tpfin = ""
            ttTache.duree = 0
            ttTache.dtree = ?
            ttTache.ntges = "00001"
            ttTache.tpges = ""
            ttTache.pdges = "00101"
            ttTache.cdreg = "22001"
            ttTache.ntreg = "00002"
            ttTache.pdreg = "00002"
            ttTache.dcreg = "00000"
            ttTache.lbdiv = ""
        .
        create ttCttac.
        assign
            ttCttac.CRUD  = "C"
            ttCttac.tpcon = pcTypeBailACreer
            ttCttac.nocon = piNumeroBailACreer
            ttCttac.tptac = {&TYPETACHE-quittancement}
        .
    end.
    //Generation tache révision
    if not can-find(first cttac no-lock
                    where cttac.tpcon = pcTypeBailACreer
                      and cttac.nocon = piNumeroBailACreer
                      and cttac.tptac = {&TYPETACHE-quittancement})
    then do:
        create ttTache.
        assign
            ttTache.CRUD      = "C"
            ttTache.noita     = 0
            ttTache.tptac     = {&TYPETACHE-revision}
            ttTache.notac     = 1
            ttTache.tpcon     = pcTypeBailACreer
            ttTache.nocon     = piNumeroBailACreer
            ttTache.dtdeb     = 01/01/2006
            ttTache.dtfin     = 01/01/2007
            ttTache.tpfin     = "00006"
            ttTache.duree     = 1
            ttTache.dtree     = ?
            ttTache.ntges     = "01"
            ttTache.tpges     = "0"
            ttTache.pdges     = "2005"
            ttTache.cdreg     = "2005"
            ttTache.ntreg     = "01"
            ttTache.pdreg     = "00001"
            ttTache.dcreg     = "6"
            ttTache.tphon     = "YES"
            ttTache.lbdiv     = "##&##&00002#100"
            ttTache.lbdiv-dev = "##&##&00002#100"
        .
        create ttCttac.
        assign
            ttCttac.CRUD  = "C"
            ttCttac.tpcon = pcTypeBailACreer
            ttCttac.nocon = piNumeroBailACreer
            ttCttac.tptac = {&TYPETACHE-revision}
        .
    end.
    ghProc = lancementPgm("tache/tache.p", goCollectionHandlePgm).
    run setTache in ghProc(table ttTache by-reference).
    if mError:erreur() then return.

    ghProc = lancementPgm("adblib/cttac_CRUD.p", goCollectionHandlePgm).
    run setCttac in ghProc (table ttCttac by-reference).
    if mError:erreur() then return.

end procedure.
