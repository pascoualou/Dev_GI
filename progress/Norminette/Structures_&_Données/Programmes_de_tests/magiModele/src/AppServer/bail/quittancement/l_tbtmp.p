/*------------------------------------------------------------------------
    File        : l_tbtmp.p
    Purpose     :
    Description :
    Author(s)   :  Kantena 2018/01/08
    Notes       :
  ----------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}

using parametre.pclie.parametrageFournisseurLoyer.
using parametre.pclie.parametrageComptabilisationEchus.
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{bail/include/equit.i &nomtable=ttqtt}

procedure LstHstTmp:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui genere la liste des quittances anterieure d'un locataire
    Notes:  HistoriqueQuittancementLocataire.p
    parametre d'entree  :   (1) = numero de locataire

    parametre de sortie :   (1) = Nombre de Champs Retourn‚s,
                            (2) = Nombre de quittances ant‚rieures trouv‚es
                            (3) = Liste des quittances ant‚rieures : 
                            Nø quittance#Mois quitt#Type quitt
    ------------------------------------------------------------------------------*/
    define input  parameter table for ttQtt.
    define input  parameter piNumeroLocataire as integer   no-undo.
    define output parameter vcListeQtt        as character no-undo.
    define output parameter vcNombreQtt       as integer   no-undo.

    /* Parcours des quittances de TmQtt dont le mois
       de traitement GI est < au mois modifiable
       OU qui sont des factures locataires */
    for each ttQtt no-lock
       where ttQtt.NoLoc = piNumeroLocataire
         and ttQtt.cdori = "H"
        by Ttqtt.msqtt by ttQtt.noqtt:
        assign 
            vcListeQtt = vcListeQtt + "@" 
                       + string(ttQtt.noqtt) + "#"
                       + string(ttQtt.msqtt) + "#"
                       + "H"
            vcNombreQtt = vcNombreQtt + 1
        .
    end.
    if vcNombreQtt > 0 then vcListeQtt = substring(vcListeQtt, 2).

end procedure.

procedure LstEncTmp:
    /*------------------------------------------------------------------------------
    Purpose: Procedure qui genere la liste des quittances en cours d'un locataire
    Notes:  HistoriqueQuittancementLocataire.p
    parametre d'entree  :   (1) = numero de locataire
    parametre de sortie :   (1) = Nombre de Champs Retourn‚s,
                            (2) = Nombre de quittances en cours trouv‚es
                            (3) = Liste des quittances en cours : 
                             Nø quittance#Mois quitt#Type quitt
    ------------------------------------------------------------------------------*/
    define input parameter table for ttQtt.
    define input parameter piNumeroLocataire  as integer          no-undo.
    define input parameter poGlobalCollection as class collection no-undo.
    define output parameter vcListeQtt        as character        no-undo.
    define output parameter viNombreQtt       as integer          no-undo.

    define variable vlGestionFourloyer as logical no-undo.
    define variable vlBailFourLoyer    as logical no-undo.
    define variable lComptaEchu        as logical no-undo.
    define variable voFournisseurLoyer      as class parametrageFournisseurLoyer      no-undo.
    define variable voComptabilisationEchus as class parametrageComptabilisationEchus no-undo.
    
    define buffer m_ctrat for ctrat.

    /* Recuperation du parametre GESFL */
    vlGestionFourloyer = voFournisseurLoyer:isGesFournisseurLoyer().
    if valid-object(voFournisseurLoyer) then delete object voFournisseurLoyer.

    /* Recuperation du parametre CPECH */
    assign
        voComptabilisationEchus = new parametrageComptabilisationEchus()
        lComptaEchu = voComptabilisationEchus:isComtabilisationEchu()
    .
    if valid-object(voComptabilisationEchus) then delete object voComptabilisationEchus.
    
    find first m_ctrat no-lock 
         where m_ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
           and m_ctrat.nocon = integer(truncate(piNumeroLocataire / 100000, 0)) no-error.
    if lookup(m_ctrat.ntcon, "03075,03093") > 0 
    then vlBailFourLoyer = yes.
    
    /* Parcours des quittances de TmQtt dont le mois
       de traitement GI est >= au mois modifiable
      ATTENTION : En cours uniquement */
    for each ttQtt no-lock
       where ttQtt.NoLoc = piNumeroLocataire
         and ttQtt.cdori <> "H"          /* Ajout Sy le 14/12/2006 */
        by ttQtt.msqtt by ttQtt.noqtt:
        if vlGestionFourloyer and vlBailFourLoyer 
        then do:
            if ttqtt.msqtt < poGlobalCollection:getInteger("GlMflMdf") then next.
        end.
        else if lComptaEchu then do:
            /* Validation s‚par‚e des ‚chus */
            if ((ttqtt.cdter = "00001" and ttqtt.msqtt < poGlobalCollection:getInteger("GlMoiMdf"))
                 or (ttqtt.cdter = "00002" and ttqtt.msqtt < poGlobalCollection:getInteger("GlMoiMEc"))) 
            then next.
        end.
        else if ttqtt.msqtt < poGlobalCollection:getInteger("GlMoiMdf") then next.
        assign
            vcListeQtt = vcListeQtt + "@" 
                       + string(ttQtt.noqtt) + "#"
                       + string(ttQtt.msqtt) + "#"
                       + "E"
            viNombreQtt = viNombreQtt + 1
        .
    end.
    if viNombreQtt > 0 then vcListeQtt = substring(vcListeQtt, 2).

end procedure.
 
