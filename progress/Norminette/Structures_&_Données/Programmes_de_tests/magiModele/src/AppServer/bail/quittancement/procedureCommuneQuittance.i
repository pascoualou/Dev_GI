/*------------------------------------------------------------------------
File        : procedureCommuneQuittance.i
Purpose     :
Author(s)   : GGA 2018/07/12
Notes       :
derniere revue: 2018/07/24 _ phm: KO
        retirer les messages
----------------------------------------------------------------------*/
/* Nombre de rubriques maxi pour l'écran NP 0314/0049 (attention, défini aussi dans majQuittance.p) */
&SCOPED-DEFINE NbRubMax    14

procedure chgMoisQuittance private:
    /*------------------------------------------------------------------------------
    Purpose: chargement des mois de quittance 
    Notes  :
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as int64 no-undo.
    define input-output parameter poCollection as class collection no-undo.
       
    define variable vhProc as handle no-undo.
    define variable vlBailFournisseurLoyer as logical no-undo.
    define variable viMoisModifiable       as integer no-undo.
    define variable viMoisQuittancement    as integer no-undo.
    define variable viMoisEchu             as integer no-undo.
 
    define buffer ctrat for ctrat.

    for first ctrat no-lock
        where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and ctrat.nocon = piNumeroMandat:
        vlBailFournisseurLoyer = ctrat.fgfloy.
        poCollection:set("lBailFournisseurLoyer", ctrat.fgfloy).
    end.
 
    run adblib/transfert/suiviTransfert.p persistent set vhProc.
    if vlBailFournisseurLoyer
    then do:
        run getInfoTransfert in vhProc("QUFL", input-output poCollection).
        assign
            viMoisQuittancement = poCollection:getInteger("GlMflQtt")
            viMoisModifiable    = poCollection:getInteger("GlMflMdf")
            viMoisEchu          = poCollection:getInteger("GlMoiMEc")
        .
    end.
    else do:
        run getInfoTransfert in vhProc("QUIT", input-output poCollection).
        assign
            viMoisQuittancement = poCollection:getInteger("GlMoiQtt")
            viMoisModifiable    = poCollection:getInteger("GlMoiMdf")
            viMoisEchu          = poCollection:getInteger("GlMoiMEc")
        .
    end.
    poCollection:set("iMoisQuittancement", viMoisQuittancement).
    poCollection:set("iMoisModifiable"   , viMoisModifiable).
    poCollection:set("iMoisEchu"         , viMoisEchu).
    run destroy in vhProc.

end procedure.

procedure isRubMod private:
    /*------------------------------------------------------------------------------
    Purpose: determine type de maj autorise sur une rubrique
    Notes:    
    ------------------------------------------------------------------------------*/
    define input  parameter poParametrageRubriqueQuittHonoCabinet as class parametrageRubriqueQuittHonoCabinet no-undo.
    define input  parameter piNumeroRubrique as integer   no-undo.
    define input  parameter piNumeroLibelle  as integer   no-undo.
    define input  parameter pcCodeGen        as character no-undo.
    define input  parameter piNombreRubrique as integer   no-undo.
    define input  parameter pcOrigine        as character no-undo.
    define output parameter plModifAuto      as logical   no-undo.
    define output parameter plSupprAuto      as logical   no-undo.
    define output parameter plLieAuto        as logical   no-undo.

    define variable vlRubriqueService as logical no-undo.

    /* rubriques services associée à une rubrique Honoraire cabinet (HOLOQ) non modifiables */
    vlRubriqueService = poParametrageRubriqueQuittHonoCabinet:getRubriqueService(piNumeroRubrique, piNumeroLibelle).

message "a1000 "  vlRubriqueService  piNumeroRubrique   piNumeroLibelle.

    /* rubriques fixes ou variables */
    if (pcCodeGen = "00001" or pcCodeGen = "00003")
    and not vlRubriqueService        /* sauf rubriques services associée à une rubrique Honoraire cabinet (HOLOQ) */
    then assign
        plModifAuto = yes
        plSupprAuto = yes
    .
    if pcCodeGen = "00001"
    and piNombreRubrique < {&NbRubMax}
    and pcOrigine <> "O"
    and not vlRubriqueService
    then plLieAuto = yes.        // Si Fixe, Moins de 20 Rub et 'Quittance' => Ok.

end procedure.
