/*------------------------------------------------------------------------
File        : parametrageCrg123.cls
Description : Saisie des scénarios de CRG 123
Author(s)   : OFA  -  2018/01/25
Notes       :
------------------------------------------------------------------------*/
using oerealm.magiToken.
using outils.outilTraduction.
using outils.outils.
//{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

block-level on error undo, throw.

class parametre.pclie.parametrageCrg123 inherits parametre.pclie.pclie:
	/*------------------------------------------------------------------------------
	Purpose:
	Notes:
    ------------------------------------------------------------------------------*/

    {parametre/cabinet/gerance/include/paramCrg123.i}
    {application/include/error.i}
    {adblib/include/pclie.i}

    define public static property mToken as class oerealm.token no-undo get. set.
    define public static property mError as class outils.errorHandler no-undo get. set.

    constructor public parametrageCrg123():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes:
        ------------------------------------------------------------------------------*/
        super("RBCRG").

    end constructor.

    method public void getListeScenarios( output table ttScenarioCrg123 ):
        /*------------------------------------------------------------------------------
         Purpose: Récupère la liste des scénarios de CRG 123
         Notes: Service externe (appelé depuis paramCrg.p, lui même depuis beParametreGerance.cls)
        ------------------------------------------------------------------------------*/

        define buffer pclie     for pclie.

        /*Liste des scénarios*/
        for each pclie no-lock
            where pclie.tppar = "RBCRG"
              and pclie.zon01 = "SCEN":

            create ttScenarioCrg123.
            assign
                ttScenarioCrg123.tppar              = pclie.tppar
                ttScenarioCrg123.cCodeScenario      = pclie.zon10
                ttScenarioCrg123.cLibelleScenario   = pclie.lbdiv
                ttScenarioCrg123.CRUD               = "R"
                ttScenarioCrg123.dtTimestamp        = datetime(pclie.dtmsy, pclie.hemsy)
                ttScenarioCrg123.rRowid             = rowid(pclie)
                .
        end.    

        return.

    end method.

	method public void getRubriquesAna( input pcCodeScenario as character, output table ttScenarioCrg123, output table ttRubriquesAnaScenarioCrg123 ):
        /*------------------------------------------------------------------------------
         Purpose: Récupère la liste des rubriques analytiques paramétrées dans le scénario CRG 123
         Notes: Service externe (appelé depuis paramCrg.p, lui même depuis beParametreGerance.cls)
        ------------------------------------------------------------------------------*/
		
        define buffer pclie for pclie.

        for each pclie no-lock
            where pclie.tppar = "RBCRG"
            and   pclie.zon10 = pcCodeScenario
            and   pclie.zon01 = "ANA":

                find first alrubhlp no-lock
                    where alrubhlp.rub-cd = pclie.zon02
                    and   alrubhlp.ssrub-cd = pclie.zon03
                    and   alrubhlp.cdlng = (if valid-object(MagiToken:mtoken) then magiToken:mToken:iCodeLangueSession else 0)
                    no-error.
                create ttRubriquesAnaScenarioCrg123.
                assign
                    ttRubriquesAnaScenarioCrg123.tppar                  = pclie.tppar
                    ttRubriquesAnaScenarioCrg123.cCodeScenario          = pcCodeScenario
                    ttRubriquesAnaScenarioCrg123.cCodeRubrique          = if pclie.zon02 = "" then "-"
                                                                          else pclie.zon02
                    ttRubriquesAnaScenarioCrg123.cCodeSousRubrique      = if pclie.zon03 = "" then "-"
                                                                          else pclie.zon03
                    ttRubriquesAnaScenarioCrg123.cLibelleRubrique       = if available alrubhlp then alrubhlp.librub
                                                                          else if pclie.zon02 = "" and pclie.zon03 = "" and pclie.zon04 = "2" then "CHARGES LOCATIVES"
                                                                          else ""
                    ttRubriquesAnaScenarioCrg123.cLibelleSousRubrique   = if available alrubhlp then alrubhlp.libssrub
                                                                          else ""
                    ttRubriquesAnaScenarioCrg123.cCodeFiscalite         = if pclie.zon04 = "" then "-"
                                                                          else pclie.zon04
                    ttRubriquesAnaScenarioCrg123.cNumeroReleve          = string(pclie.int03)
                    ttRubriquesAnaScenarioCrg123.CRUD                   = "R"
                    ttRubriquesAnaScenarioCrg123.dtTimestamp            = datetime(pclie.dtmsy, pclie.hemsy)
                    ttRubriquesAnaScenarioCrg123.rRowid                 = rowid(pclie)
                    .
        end.

		return.

	end method.

	method public void getRubriquesQuit( input pcCodeScenario as character, output table ttScenarioCrg123, output table ttRubriquesQuitScenarioCrg123 ):
        /*------------------------------------------------------------------------------
         Purpose: Récupère la liste des rubriques analytiques paramétrées dans le scénario CRG 123
         Notes: Service externe (appelé depuis paramCrg.p, lui même depuis beParametreGerance.cls)
        ------------------------------------------------------------------------------*/
		
        define variable vhproc as handle no-undo. 
        define buffer pclie for pclie.

        run bail/quittancement/rubriqueQuitt.p persistent set vhproc.

        /*Chargement de la table des rubriques de quittancement -> par défaut en relevé N°1*/
        for each pclie no-lock
            where pclie.tppar = "RBCRG"
            and   pclie.zon10 = pcCodeScenario
            and   pclie.zon01 = "QTT":

                find rubqt no-lock
                    where rubqt.cdrub = integer(pclie.zon02)
                    and   rubqt.cdlib = integer(pclie.zon03)
                    no-error.
                find famqt no-lock
                    where famqt.cdfam = pclie.int01
                    and   famqt.cdsfa = pclie.int02
                    no-error.
    
                create ttRubriquesQuitScenarioCrg123.
                assign
                    ttRubriquesQuitScenarioCrg123.tppar                 = pclie.tppar
                    ttRubriquesQuitScenarioCrg123.cCodeScenario         = pcCodeScenario
                    ttRubriquesQuitScenarioCrg123.cCodeFamille          = string(pclie.int01,"99")
                    ttRubriquesQuitScenarioCrg123.cCodeSousFamille      = if pclie.int02 = 0 then "-"
                                                                          else string(pclie.int02,"99")
                    ttRubriquesQuitScenarioCrg123.cCodeRubrique         = if pclie.zon02 = "" then "-"
                                                                          else pclie.zon02
                    ttRubriquesQuitScenarioCrg123.cCodeLibelle          = if pclie.zon03 = "" then "-"
                                                                          else pclie.zon03
                    ttRubriquesQuitScenarioCrg123.cLibelleSousFamille   = if available famqt then caps(outilTraduction:getLibelle(famqt.nome1))
                                                                          else ""
                    ttRubriquesQuitScenarioCrg123.cNumeroReleve         = string(pclie.int03)
                    ttRubriquesQuitScenarioCrg123.cLibelleRubrique      = if available rubqt then caps(dynamic-function('getLibelleRubrique' in vhproc,
                                                                                                       rubqt.cdrub,
                                                                                                       rubqt.cdlib,
                                                                                                       0,
                                                                                                       0,
                                                                                                       ?,                    /* date comptable */
                                                                                                       if valid-object(MagiToken:mtoken) then integer(MagiToken:mToken:cRefGerance) else 0,
                                                                                                       0))
                                                                          else ""
                    ttRubriquesQuitScenarioCrg123.CRUD                  = "R"
                    ttRubriquesQuitScenarioCrg123.dtTimestamp           = datetime(pclie.dtmsy, pclie.hemsy)
                    ttRubriquesQuitScenarioCrg123.rRowid                = rowid(pclie)
                    .
        end.

        if valid-handle(vhproc) then delete object vhproc.

		return.

	end method.

    method private logical crudScenarioCrg123 ():
        /*------------------------------------------------------------------------------
         Purpose: CRUD des scénarios CRG 123
         Notes: 
        ------------------------------------------------------------------------------*/
        deleteScenarioCrg123 ().
        updateScenarioCrg123 ().
        createScenarioCrg123 ().
        //mError:getErrors(output table ttError). -> message d'erreur à l'exécution "catch: handle non valide."
        return not can-find(first ttError where ttError.iType >= {&error}).
    end method.
    
    method public void setScenarioCrg123 (input table for ttPclie):
        /*------------------------------------------------------------------------------
         Purpose:
         Notes: Service externe (appelé depuis paramCrg.p, lui même depuis beParametreGerance.cls)
        ------------------------------------------------------------------------------*/
        crudScenarioCrg123().
    end method.
    
    method private void updateScenarioCrg123 ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define buffer Pclie for Pclie.
    
    bloc:
        do transaction:
            for each ttPclie where ttPclie.CRUD = "U":
                find first Pclie exclusive-lock
                    where rowid(Pclie) = ttPclie.rRowid no-wait no-error.
                if not outils:copyValidField(buffer Pclie:handle, buffer ttPclie:handle, 'U', MagiToken:mToken:cUser)
                then undo bloc, leave bloc.
            end.
        end.
        error-status:error = false no-error.   // reset error-status
        return.                                // reset return-value
    end method.
    
    method private void createScenarioCrg123 ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  :
        ------------------------------------------------------------------------------*/
        define buffer Pclie for Pclie.
    
    bloc:
        do transaction:
            for each ttPclie where ttPclie.CRUD = "C" on error undo, leave:
                create Pclie.
                if not outils:copyValidField(buffer Pclie:handle, buffer ttPclie:handle, 'C', MagiToken:mtoken:cUser)
                then undo bloc, leave bloc.
            end.
        end.
        error-status:error = false no-error.   // reset error-status
        return.                                // reset return-value
    
    end method.
    
    method private void deleteScenarioCrg123 ():
        /*------------------------------------------------------------------------------
        Purpose:
        Notes  : service
        ------------------------------------------------------------------------------*/
        define buffer Pclie for Pclie.
    
    blocTrans:
        do transaction:
            for each ttPclie where ttPclie.CRUD = 'D':
                message "deleteScenarioCrg123 " ttPclie.zon10.
                //Si on supprime le scénario, il faut supprimer toutes les lignes de paramétrage rattachées
                if ttpclie.zon01 = "SCEN" then
                    for each Pclie exclusive-lock
                        where Pclie.tppar = ttPclie.tppar
                        and   Pclie.zon10 = ttPclie.zon10
                        and   Pclie.zon01 ne ttpclie.zon01
                        :
                        delete Pclie no-error.
                        if error-status:error then do:
                            //mError:createError({&error}, error-status:get-message(1)).
                            undo blocTrans, leave blocTrans.
                        end.
                    end.                   

                find first Pclie exclusive-lock
                    where rowid(Pclie) = ttPclie.rRowid no-wait no-error.
                delete Pclie no-error.
                if error-status:error then do:
                    //mError:createError({&error}, error-status:get-message(1)).
                    undo blocTrans, leave blocTrans.
                end.
            end.
        end.
        error-status:error = false no-error.  // reset error-status
    end method.    

end class.
