/*------------------------------------------------------------------------
File        : decodorg.i
Description : Décodage organisme sociaux pour lecture orsoc OU ifour
Author(s)   :  , kantena - 2018/01/15
Notes       : appelé par extract.p / courrier.p
----------------------------------------------------------------------*/

procedure decodOrg:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes:
    ------------------------------------------------------------------------------*/
    define input  parameter pcTypeIdentifiant  as character no-undo.
    define input  parameter pcIdentifiant      as character no-undo.
    define output parameter pcCodeIdentifiant  as character no-undo.
    define output parameter pcNomTable         as character no-undo.
    define output parameter pcColl-cle         as character no-undo.
    define output parameter pcLibelleOrganisme as character no-undo.

    define variable viTypeRole as integer     no-undo.
    define buffer ccptCol for ccptCol.

    assign
        pcIdentifiant     = string(pcTypeIdentifiant , "X(5)")
        pcCodeIdentifiant = pcIdentifiant
        pcColl-cle        = pcTypeIdentifiant
        pcNomTable        = "ifour"
    .
    case pcTypeIdentifiant:
        when "CDI" then assign
            viTypeRole          = 0
            pcLibelleOrganisme = outilTraduction:getLibelle(701187)
            pcCodeIdentifiant  = substring(pcIdentifiant, 1, 3, "character") + "C" + substring(pcIdentifiant, 4, 2, "character")
            pcNomTable         = "orsoc"
        .
        when "CDR" then assign
            viTypeRole = 0
            pcLibelleOrganisme = outilTraduction:getLibelle(701191)
            pcCodeIdentifiant  = substring(pcIdentifiant, 1, 3, "character") + "R" + substring(pcIdentifiant, 4, 2, "character")
            pcNomTable         = "orsoc"
        .
        when "FOU" then assign
            viTypeRole = 12
            pcLibelleOrganisme = outilTraduction:getLibelle(100124)
            .
        when "CAF" then assign
            viTypeRole = 4093
            pcLibelleOrganisme = outilTraduction:getLibelle(104858)
            .
        when "OAS" then assign
            viTypeRole = 4373
            pcLibelleOrganisme = outilTraduction:getLibelle(105280)
        .
        when "ORT" then assign
            viTypeRole = 4372
            pcLibelleOrganisme = outilTraduction:getLibelle(105281)
        .
        when "OSS" then assign
            viTypeRole = 4310
            pcLibelleOrganisme = outilTraduction:getLibelle(105282)
        .
        when "OTS" then assign
            viTypeRole = 4374
            pcLibelleOrganisme = outilTraduction:getLibelle(103499)
        .
        when "ODB" then assign 
            viTypeRole = 4401
            pcLibelleOrganisme = outilTraduction:getLibelle(701191)
        .
        when "ORP" then assign
            viTypeRole = 4380
            pcLibelleOrganisme = outilTraduction:getLibelle(701191)
        .
        when "SIE" then assign
            viTypeRole = 0
            pcLibelleOrganisme = outilTraduction:getLibelle(110180)
        .
    end case.
    for first ccptCol no-lock 
        where ccptCol.tprol  = viTypeRole
          and ccptcol.soc-cd = mtoken:icodeSociete:
        pcColl-cle = ccptcol.coll-cle.
    end.

end procedure.
