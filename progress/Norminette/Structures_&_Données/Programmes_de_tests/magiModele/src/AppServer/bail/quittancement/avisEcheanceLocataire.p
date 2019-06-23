/*------------------------------------------------------------------------
File        :
Purpose     :
Description :
Author(s)   : Kantena - 2017/12/21
Notes       : quitlo00_srv.p
  ----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/
{preprocesseur/type2tache.i}
{preprocesseur/type2contrat.i}

using parametre.syspg.syspg.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

procedure iniWinRch:
    /*------------------------------------------------------------------------------
    Purpose:     
    Notes:       
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeBail   as character no-undo.
    define input  parameter piNumeroBail as integer   no-undo.
    define output parameter poCollection as class Collection no-undo.
    
    define variable viNumeroInd            as integer   no-undo.
    define variable vcListeInd             as character no-undo.
    define variable vcLbTmpPdt             as character no-undo.
    define variable vlBailFournisseurLoyer as logical   no-undo.
    define variable vlRetour               as logical   no-undo.

    define buffer m_ctrat for ctrat.

    poCollection:set("lsirv", "no").
    poCollection:set("lblng", "").       /* SY 05/10/2015 initialisation */
    poCollection:set("cdhon_04160", ""). /* SY 05/10/2015 initialisation */

    /* SY 10/02/2017 : QUIT locataire ou QUFL ? */
    find first m_ctrat no-lock
        where m_ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and m_ctrat.nocon = integer(truncate(piNumeroBail / 100000, 0)) no-error.   // substring(string(piNumeroBail, "9999999999"), 1, 5))
    vlBailFournisseurLoyer = available m_ctrat and m_ctrat.fgfloy.
    find last tache no-lock
        where tache.tpcon = pcTypeBail
          and tache.Nocon = piNumeroBail
          and tache.Tptac = {&TYPETACHE-revision} no-error.
    if available tache and today >= Tache.dtfin then do:
        find first indrv no-lock
            where indrv.cdirv = integer(tache.dcreg) 
              and indrv.anper = integer(tache.cdreg) + tache.duree 
              and indrv.noper = integer(tache.ntreg) no-error.
        if not available indrv then do:
            assign
                viNumeroInd = index(entry(1, entry(2, tache.lbdiv, "&"), "#"), tache.cdreg)
                vcLbTmpPdt  = entry(1, entry(2, tache.lbdiv, "&"), "#")
                vcListeInd  = substring(vcLbTmpPdt, 1, viNumeroInd - 1) + string(integer(Tache.cdreg) + tache.duree) 
            .
            find first lsirv no-lock where lsirv.cdirv = integer(tache.dcreg) no-error.
            if available lsirv then do:
                poCollection:set("lsirv", "yes").
                poCollection:set("lblng", lsirv.lblng + " " + vcListeInd).
            end.
        end.
    end.
    find last tache no-lock
        where tache.tpcon = ctrat.tpcon    //  TODO  D'ou vient ce ctrat ??? est-ce m_ctrat ?????
          and tache.nocon = ctrat.nocon
          and Tache.tptac = {&TYPETACHE-renouvellement} no-error.

    poCollection:set("tache_04160", available tache).
    poCollection:set("cdhon_04160", tache.cdhon).
    poCollection:set("lBailFournisseurLoyer", vlBailFournisseurLoyer).

end procedure.

procedure Rech_Quitt :
/*------------------------------------------------------------------------------
  Purpose:     
  Notes:       
------------------------------------------------------------------------------*/
    define input  parameter pcTypeBail        as character no-undo.
    define input  parameter piNumeroLocataire as integer   no-undo.
    define output parameter poCollection      as class Collection no-undo.

    define variable vcLibelleEncours     as character no-undo.
    define variable vlTaciteReconduction as logical   no-undo.
    define variable vdaSortieLocataire   as date      no-undo.
    define variable vdaResiliationBail   as date      no-undo.
    define variable vdaFinBail           as date      no-undo.
    define variable viNombreQuittance    as integer   no-undo.
    define variable CdTrvQtt   as character no-undo.
    define variable vlRetour   as logical no-undo initial true.
    define buffer ctrat for ctrat.

    if pcTypeBail = {&TYPECONTRAT-preBail} then do:
        for each pquit no-lock
            where pquit.noloc = piNumeroLocataire:
            assign 
                vcLibelleEncours  = substitute("&1@&2#&3#E", vcLibelleEncours, pquit.noqtt, pquit.msqtt)
                viNombreQuittance = viNombreQuittance + 1
            .
        end.
        //if vlRetour then vlRetour = dynamic-function('createData':U,"NbTmpQtt", NbTmpQtt).
        poCollection:set("iNombreQuittance", viNombreQuittance).
        if viNombreQuittance > 0 then do:
            assign
                vcLibelleEncours = substring(vcLibelleEncours, 2)
                CdTrvQtt = "1"
            .
            poCollection:set("cLibelleEncours", vcLibelleEncours).
        end.
        else CdTrvQtt = "0".
    end.
    else do:
        run AffecIdt    (input 0, input "LstEncQtt").
        run AffecIdt    (input 1, input string(piNumeroLocataire)).
/* ToDo
         {RunPgExp.i
             &Path   = RpRunLibADB
             &Prog   = "'L_Equit_ext.p'"}*/

        run RecupIdt (input 1, output CdTrvQtt).
        poCollection:set("CdTrvQtt", CdTrvQtt).
        if CdTrvQtt <> '0' then do:
            run RecupIdt (input 2, output viNombreQuittance).
            run RecupIdt (input 3, output vcLibelleEncours).
//            poCollection:set("viNombreQuittance", viNombreQuittance).
//            poCollection:set("LbEncQtt",          vcLibelleEncours).
        end.
    end.
    if CdTrvQtt = '0' then return.

    /* Remplacement des '#' par des '$'. */
    assign 
        vcLibelleEncours   = replace(vcLibelleEncours, '#', '$') 
        /**Mlog ( "LbEncQtt = " + LbEncQtt). **/
        /* Remise a zero de la Date butoir... */
        vdaFinBail         = ?
        vdaResiliationBail = ?
    .
    /* Remise a zero de la Date butoir... */

    /* Recherche de la date de sortie du Locataire. */
    find last tache no-lock
        where tache.TpTac = {&TYPETACHE-quittancement}
          and tache.TpCon = pcTypeBail
          and tache.NoCon = piNumeroLocataire no-error.
    poCollection:set("tache", available tache).
    if available tache then do:
        vdaSortieLocataire = tache.DtFin.
        poCollection:set("daSortieLocataire", vdaSortieLocataire).
    end.

    /* Recherche de la date de resiliation du bail */
    find first ctrat no-lock
        where ctrat.TpCon = pcTypeBail 
          and ctrat.NoCon = piNumeroLocataire no-error.
    poCollection:set("ctrat", available ctrat).
    if available ctrat then do:
        assign 
            vdaFinBail           = ctrat.DtFin
            vdaResiliationBail   = ctrat.DtRee
            vlTaciteReconduction = (ctrat.TpRen = "00001")
        .
        poCollection:set("daFinBail",         vdaFinBail).
        poCollection:set("daResiliationBail", vdaResiliationBail).
        poCollection:set("lTaciteReconduction", vlTaciteReconduction).
    end.

end procedure.

procedure _main:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:       todo   c'est quoi cette fonction 'createData'
    ------------------------------------------------------------------------------*/
    define input parameter pcTypeLocataire   as character no-undo.
    define input parameter piNumeroLocataire as int64     no-undo.
    define input parameter pcTypePro         as character no-undo.
    define input parameter pcTypeMaitre      as character no-undo.
    define input parameter pcTypeMandat      as character no-undo.
    define input parameter pcTypeBail        as character no-undo.

    define variable viTypeRoleMandant    as integer   no-undo.
    define variable viTypeRoleLocataire  as integer   no-undo.
    define variable viTypeContratMandant as integer   no-undo.
    define variable viTypeContratBail    as integer   no-undo.
    define variable vlRetour             as logical   no-undo.
    define variable vcProgramme          as character no-undo.
    define variable voSysPg              as class syspg no-undo.
    define buffer ctrat for ctrat.

    voSysPg = new syspg().

    voSysPg:reloadZone1("O_ROL", pcTypePro).     /* Rechercher le Libellé du Type de Role mandant */
    viTypeRoleMandant  = voSysPg:nome2.
    voSysPg:reloadZone1("O_ROL",                 /* Rechercher le Libellé du Type de Role locataire */
                        if pcTypeMaitre = "11" then "00059" else pcTypeLocataire).
    viTypeRoleLocataire = voSysPg:nome2.
    voSysPg:reloadZone1("O_CLC", pcTypeMandat).  /* Rechercher le Libellé du Type de Contrat mdt */
    viTypeContratMandant = voSysPg:nome2.
    voSysPg:reloadZone1("O_CLC", pcTypeBail).    /* Rechercher le Libellé du Type de Contrat bail */
    viTypeContratBail = voSysPg:nome2.

    /* Ajout SY le 23/09/2015 : gestion liste des roles pour avoir aussi les baux résiliés si besoin */
    if pcTypeMaitre = "00" and piNumeroLocataire > 0 then do:
        vcProgramme = 'frmlrl02.p'.       /* liste des baux non résiliés */
        for first ctrat no-lock 
            where ctrat.tpcon = pcTypeBail
              and ctrat.nocon = piNumeroLocataire
              and ctrat.dtree <> ?:
            vcProgramme = "frmlrl20.p".
        end.
    end.
    vlRetour = dynamic-function('createData',"NoLibMnd", viTypeRoleMandant).
    if vlRetour then vlRetour = dynamic-function('createData', "NoLibLoc", viTypeRoleLocataire).
    if vlRetour then vlRetour = dynamic-function('createData', "NoLibMdt", viTypeContratMandant).
    if vlRetour then vlRetour = dynamic-function('createData', "NoLibBai", viTypeContratBail).
    if vlRetour then vlRetour = dynamic-function('createData', "prglisterol00", vcProgramme).
    delete object voSysPg no-error.

end procedure.
