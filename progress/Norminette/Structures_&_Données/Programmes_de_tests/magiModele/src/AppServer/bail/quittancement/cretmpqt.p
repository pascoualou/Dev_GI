/*------------------------------------------------------------------------
    File        : cretmpqt.p
    Purpose     : 
    Description : 
    Author(s)   : 
    Created     : Wed Nov 22 10:09:12 CET 2017
    Notes       :
  ----------------------------------------------------------------------*/
{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */
{bail/include/tmprub.i}
{bail/include/equit.i &nomtable=ttQtt}
 
procedure copieToTmp:
    /*------------------------------------------------------------------------------
      Purpose:
      Notes: service
    ------------------------------------------------------------------------------*/
    define input parameter phbtt as handle no-undo.
    define output parameter table for ttQtt.
    define output parameter table for ttRub.
    define variable viExtent          as integer   no-undo.
    define variable vcLibelleRubrique as character no-undo.

    // Chargement de ttQtt
    create ttQtt.
    outils:copyValidField(phbtt, buffer ttQtt:handle).
    assign 
        // ttQtt.NoLoc = int64(phbtt::NoLoc)
        ttQtt.CdOri = "F"
        // Chargement de ttRub     // TODO  utiliser l'extent du champ phbtt:buffer-field('TbFam'):extent
        viExtent = 1
    .
    do while viExtent <= 20 and phbtt:buffer-field('TbRub'):buffer-value(viExtent) <> 0:
        /*
           Test si la rubrique est de type calcul ou
           resultat
        */
        /*
           SC/AF le 15/04/1999: Les Rubriques de Type
           Resultat (Revision...) n'ont plus … ˆtre
           ignorees par MajEquit.p ...
        */
        if phbtt:buffer-field('TbGen'):buffer-value(viExtent) <> "00004" then do:
            // Recuperation du no du libelle de la rubrique
/*
            run RecLibRub (phbtt:buffer-field('tbrub'):buffer-value(viExtent)
                         , phbtt:buffer-field('tblib'):buffer-value(viExtent) 
                         , phbtt::NoLoc
                         , phbtt::msqtt
                         , output LbRubQtt
                         , output CdRecLib).
*/                         
            create ttRub.
            assign
                ttRub.NoLoc = phbtt::NoLoc
                ttRub.NoQtt = phbtt::NoQtt
                ttRub.CdFam = phbtt:buffer-field('TbFam'):buffer-value(viExtent)
                ttRub.CdSfa = phbtt:buffer-field('TbSfa'):buffer-value(viExtent)
                ttRub.NoRub = phbtt:buffer-field('TbRub'):buffer-value(viExtent)
                ttRub.NoLib = phbtt:buffer-field('TbLib'):buffer-value(viExtent)
                ttRub.LbRub = vcLibelleRubrique
                ttRub.CdGen = phbtt:buffer-field('TbGen'):buffer-value(viExtent)
                ttRub.CdSig = phbtt:buffer-field('TbSig'):buffer-value(viExtent)
                ttRub.CdDet = phbtt:buffer-field('TbDet'):buffer-value(viExtent)
                ttRub.VlQte = phbtt:buffer-field('TbQte'):buffer-value(viExtent)
                ttRub.CdPro = phbtt:buffer-field('TbPro'):buffer-value(viExtent)
                ttRub.VlNum = phbtt:buffer-field('TbNum'):buffer-value(viExtent)
                ttRub.VlDen = phbtt:buffer-field('TbDen'):buffer-value(viExtent)
                ttRub.DtDap = phbtt:buffer-field('TbDt1'):buffer-value(viExtent)
                ttRub.DtFap = phbtt:buffer-field('TbDt2'):buffer-value(viExtent)
                ttRub.VlMtq = phbtt:buffer-field('TbMtq'):buffer-value(viExtent)
                ttRub.VlPun = phbtt:buffer-field('TbPun'):buffer-value(viExtent)
                ttRub.MtTot = phbtt:buffer-field('TbTot'):buffer-value(viExtent)
                ttRub.NoLig = viExtent
            .
        end. /* Test du type de la rubrique */
        else assign
            ttQtt.MtQtt = ttQtt.MtQtt
                        - phbtt:buffer-field('TbMtq'):buffer-value(viExtent)
            ttQtt.NbRub = ttQtt.NbRub - 1
        .
        assign viExtent = viExtent + 1.
    end.
end procedure.
