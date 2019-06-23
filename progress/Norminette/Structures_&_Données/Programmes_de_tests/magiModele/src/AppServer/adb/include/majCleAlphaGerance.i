/*-----------------------------------------------------------------------------
File      : majCleAlphaGerance.i
Purpose   : Creation/Maj des cles Alpha des mandats de gerance qui sont dans
            un immeuble de copro ou un immeuble gérance pure multi-mandats (01/09/2015)
Author(s) : SY - 2000/09/06   -   GGA - 2018/01/10
Notes     : a partir de adb/comm/majcleger.i 
-----------------------------------------------------------------------------*/

procedure majClger private:
    /*------------------------------------------------------------------------------
    Purpose:
    Notes  : 
    ------------------------------------------------------------------------------*/
    define input parameter piNumeroMandat as integer no-undo.

    define variable viImmeuble      as integer no-undo.
    define variable viCleMandat     as integer no-undo.
    define variable vdTotalMillieme as decimal no-undo.

    define buffer intnt   for intnt.
    define buffer local   for local.
    define buffer vbclemi for clemi.
    define buffer clemi   for clemi.
    define buffer milli   for milli.
  
    find first intnt no-lock                                             //Recherche immeuble du mandat
        where intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
          and intnt.nocon = piNumeroMandat
          and intnt.tpidt = {&TYPEBIEN-immeuble} no-error.
    if not available intnt then return.

    assign
        viImmeuble  = intnt.noidt
        viCleMandat = 10000 + piNumeroMandat //Cle du mandat stocke
    .
boucleCleImmeuble:
    for each vbclemi no-lock                                            //Boucle sur les cles de l'immeuble
        where vbclemi.noimm = viImmeuble 
          and vbclemi.cdcle >= "A"
          and vbclemi.cdeta = "V":

        vdTotalMillieme = 0.
        for each intnt no-lock                                          //Calcul du total mandat
            where intnt.tpidt = {&TYPEBIEN-lot}
              and intnt.tpcon = {&TYPECONTRAT-mandat2Gerance}
              and intnt.nocon = piNumeroMandat
          , first local no-lock
            where local.noloc = intnt.noidt
          , each milli no-lock 
            where milli.noimm = viImmeuble
              and milli.nolot = local.Nolot
              and milli.cdcle = vbclemi.cdcle:
            vdTotalMillieme = vdTotalMillieme + milli.nbpar.
        end.
        {&_proparse_ prolint-nowarn(nowait)}
        find first clemi no-lock                              // Creation/Maj cle pour le mandat 
            where clemi.noimm = viCleMandat 
              and clemi.cdcle = vbclemi.cdcle no-error.
        create ttClemi.
        if not available clemi 
        then assign
            ttClemi.iNumeroImmeuble = viCleMandat
            ttClemi.cCodeCle = vbclemi.cdcle
            ttClemi.iNumeroOrdre = vbclemi.noord
            ttClemi.CRUD  = "C"
        .
        else do:
            outils:copyValidField(buffer clemi:handle, buffer ttClemi:handle).
            ttClemi.CRUD = "U".
        end.
        assign
            ttClemi.cNatureCle = vbclemi.tpcle
            ttClemi.cLibelleCle = vbclemi.lbcle
            ttClemi.cCodebatiment = vbclemi.cdbat
            ttClemi.cTypeContrat = {&TYPECONTRAT-mandat2Gerance}
            ttClemi.iNumeroContrat = piNumeroMandat
            ttClemi.dTotal = vdTotalMillieme
            ttClemi.cCodeArchivage = "00000" /* Clé non archivée */
            ttClemi.dEcart = 0 
            ttClemi.cCodeEtat = "V"
        .
    end.

end procedure.
