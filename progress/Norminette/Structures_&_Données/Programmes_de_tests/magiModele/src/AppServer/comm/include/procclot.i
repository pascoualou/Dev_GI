/*-------------------------------------------------------------------------------------
File        : procclot.i
Purpose     : recherche occupant d'un lot a partir de l'enregistrement local en cours  
Author(s)   : SY 10/03/2010 (0210/0196) -  GGA 2015/02/05
Notes       : reprise comm\procclot.i

| 0001 | 30/03/2010 |   SY   | 0310/0196 Ne pas prendre le copropriétaire             |
|      |            |        | si le mandat de syndic est résilié                     |
| 0002 | 19/06/2012 |   PL   | 0212/0155 Sous-location BNP                            |
| 0003 | 10/11/2016 |   SY   | 1016/0194 Gestion RAZ occupant si dernier bail résilié |
| 0004 | 30/11/2016 |   SY   | 1116/0240 correction modif précédente                  |
-------------------------------------------------------------------------------------*/

{preprocesseur/type2contrat.i}
{preprocesseur/nature2contrat.i}
{preprocesseur/type2tache.i}
{preprocesseur/type2bien.i}
{preprocesseur/type2role.i}
{preprocesseur/type2occupant.i}

procedure occupLot private:
    /*------------------------------------------------------------------------------
    Purpose:   
    Notes  : 
    ------------------------------------------------------------------------------*/
    define parameter buffer local for local.
    define output parameter pcNomOccupant       as character no-undo.
    define output parameter pdaEntreeOccupant   as date      no-undo.
    define output parameter piNumeroBail        as integer   no-undo.
    define output parameter piNumeroContratProp as integer   no-undo.
    define output parameter pcTypeRoleProp      as character no-undo.
    define output parameter piNumeroRoleProp    as integer   no-undo.
    define output parameter pdaAchat            as date      no-undo.
    define output parameter pcTypeOccupant      as character no-undo init {&TYPEOCCUPANT-indefini}.
    define output parameter pcCodeRegroupement  as character no-undo init "A".    

    define buffer cpuni   for cpuni.
    define buffer unite   for unite.
    define buffer ctrat   for ctrat.
    define buffer intnt   for intnt.
    define buffer vbctrat for ctrat.
    define buffer tache   for tache.
                      
    for each cpuni no-lock
       where cpuni.noimm = local.noimm
         and cpuni.nolot = local.nolot           
    , each unite no-lock
     where unite.nomdt = cpuni.nomdt
       and unite.noapp = cpuni.noapp       
       and unite.nocmp = cpuni.nocmp
       and unite.noact = 0:        

        /*--> Ignorer mandat Location (FL) et baux spécial vacant propriétaire */
        for first ctrat no-lock   
            where ctrat.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and ctrat.nocon = unite.nomdt
              and ctrat.ntcon <> {&NATURECONTRAT-mandatLocation}
              and ctrat.ntcon <> {&NATURECONTRAT-mandatLocationIndivision}
              and ctrat.ntcon <> {&NATURECONTRAT-mandatLocationDelegue}:
        
            /*--> Propriétaire */
            assign
                piNumeroContratProp = unite.nomdt
                pcTypeRoleProp      = {&TYPEROLE-mandant}
                piNumeroRoleProp    = ctrat.norol
            .

            /*--> unite reservé au mandant */
            if integer(unite.cdcmp) = 3 
            then assign
                     pcNomOccupant  = ctrat.lbnom
                     pcTypeOccupant = {&TYPEOCCUPANT-occupant}
            .                 
            else do:
                /* Rechercher le dernier locataire de l'UL */ 
                for each vbctrat no-lock
                   where vbctrat.tpcon   = {&TYPECONTRAT-bail}
                     and vbctrat.nocon   >= unite.nomdt * 100000 + cpuni.noapp * 100 + 1      //int64(string(unite.nomdt, "99999") + string(cpuni.noapp, "999") + "01")
                     and vbctrat.nocon   <= unite.nomdt * 100000 + cpuni.noapp * 100 + 99     //int64(string(unite.nomdt, "99999") + string(cpuni.noapp, "999") + "99")
                     and vbctrat.fgannul = false        /* SY 0909/0196 */
                     and vbctrat.ntcon   <> {&NATURECONTRAT-specialVacant}
                by vbctrat.tpcon by vbctrat.nocon:        /* SY 1116/0240 */
                    piNumeroBail = vbctrat.nocon.
                end.                                                     
            end.
        
        end.
    end.
    
    /*--> Si aucun bail prendre l'occupant saisi */
    if piNumeroBail = 0 
    then assign
             pdaEntreeOccupant = local.dtent
             pcTypeOccupant    = local.lbdiv3
             pcNomOccupant     = local.nmocc
    .
    else do:
        for first ctrat no-lock     
            where ctrat.tpcon = {&TYPECONTRAT-bail}
              and ctrat.nocon = piNumeroBail:
            /* Bailleur sous-location ou Bailleur */       
            if ctrat.ntcon = {&NATURECONTRAT-mandatSousLocation} or ctrat.ntcon = {&NATURECONTRAT-mandatSousLocationDelegue}
            then pcTypeOccupant = {&TYPEOCCUPANT-bailleurSousLoc}.
            else pcTypeOccupant = {&TYPEOCCUPANT-bailleur}.     
            if ctrat.dtree <> ? and ctrat.dtree < today 
            then do:
                piNumeroBail = 0.
                if local.nmocc = ctrat.lbnom 
                then assign                              /* RAZ infos occupant si identique au bail résilié */
                         pdaEntreeOccupant = ?
                         pcNomOccupant     = ""
                .                   
                else assign                              /* conserver l'occupant saisi */
                        pdaEntreeOccupant = local.dtent
                        pcTypeOccupant    = local.lbdiv3
                        pcNomOccupant     = local.nmocc
                .                  
            end.
            else do:
                pcNomOccupant = ctrat.lbnom.          
                for last tache no-lock
                   where tache.tpcon = {&TYPECONTRAT-bail}
                     and tache.nocon = piNumeroBail
                     and tache.tptac = {&TYPETACHE-quittancement}:
                    pdaEntreeOccupant = tache.dtdeb.  
                end.                       
            end.
        end.    /*  ctrat  */                   
    end.    /* piNumeroBail <> 0 */       

    /*--> Récupération du copropriétaire actif */
    /* Ajout SY le 30/03/2010 : le mandat de syndic ne doit pas etre résilié */
    for each intnt no-lock
       where intnt.tpcon = {&TYPECONTRAT-titre2copro}
         and intnt.tpidt = {&TYPEBIEN-lot}
         and intnt.noidt = local.noloc
         and intnt.nbden = 0
    , first ctrat no-lock  
      where ctrat.tpcon = {&TYPECONTRAT-mandat2Syndic}
        and ctrat.nocon = int64(truncate(intnt.nocon / 100000, 0))  //integer(substring(string(intnt.nocon, "9999999999"), 1, 5, 'character'))
        and ctrat.dtree = ?:
        assign
            pcCodeRegroupement = (if intnt.cdreg <> "" then intnt.cdreg else pcCodeRegroupement)
            pdaAchat           = outils:convertionDate("yyyymmdd", string(intnt.nbnum))
        .
        
        for first vbctrat no-lock
            where vbctrat.tpcon = intnt.tpcon 
              and vbctrat.nocon = intnt.nocon:
            assign
                piNumeroContratProp = vbctrat.nocon
                pcTypeRoleProp      = {&TYPEROLE-coproprietaire}
                piNumeroRoleProp    = vbctrat.norol
            .
            /*--> SI occupant */
            if pcTypeOccupant = {&TYPEOCCUPANT-occupant} or pcTypeOccupant = "" 
            then assign
                     pdaEntreeOccupant = pdaAchat
                     pcTypeOccupant    = {&TYPEOCCUPANT-occupant}
                     pcNomOccupant     = vbctrat.LbNom
            .
        end.
    end.
                    
end procedure.              