/*-----------------------------------------------------------------------------
File        : tfacrbqt.p
Purpose     : Génération d'une table temporaire contenant les rubriques de quittancement 
Author(s)   : Stéphane ELLENA 04/2000 - GGA 2018/10/10
Notes       : reprise cadb/fdiv/tfacrbqt.p

                                                                                    
ATTENTION LES MODIFICATIONS TELLES QUE CREATION DE NOUVELLE RUBRIQUE DE                   
QUIT NE SONT PAS PRISE EN COMPTE =>   | IL FAUT REACTUALISER CE PROGRAMME.                
                                                                                          
The zones fg1-in fg2-in fg3-in fg4-in determine whether TVA will be added                 
to the rubrique in iftln, for a particular locataire according to tache.                  
pdges  (code TVA)                                                                         
                                                                                          
tache.pdges = 00001 Add TVA for rubriques of type loyer                                   
tache.pdges = 00002 Add TVA for rubriques of type Quittance (i.e. all)                    
tache.pdges = 00003 Add TVA for rubriques of type Loyer or Charges                        
tache.pdges = 00004 Add TVA for rubriques of type Loyer or Charges or Taxes               
tache.pdges = 00005 Add TVA for rubriques of type Loyer or Taxes                          
                                                                                          
Nota. TVA is not added to rubriques de TVA (cdfam = 5 and cdfam = 2 prg05 = 7             
                                                                                          
prg05 = 7 apparament corresponds a les rubriques de cette famille/sousfammile             
          avec tva dans le libellé                                                        
i.e.                                                                                      
                                                                                          
Rubrique Type = Loyer                     ==> entry(1,ttTmpRubqt.typetva) = "O" else "N"   
Rubrique Type = Quittance                 ==> entry(2,ttTmpRubqt.typetva) = "O" else "N"   
Rubrique Type = Loyer ou Charges          ==> entry(3,ttTmpRubqt.typetva) = "O" else "N"   
Rubrique Type = Loyer ou Charges ou Taxes ==> entry(4,ttTmpRubqt.typetva) = "O" else "N"   
Rubrique Type = Loyer ou Taxes            ==> entry(5,ttTmpRubqt.typetva) = "O" else "N"   
                                                                                          
                                                                                          
e.g. Mandat 1 Locataire 00101 ==> tache.nocon = 100101                                    
                                  tache.pdges = 00001                                     
                                                                                          
RUB              ttTmpRubqt.typetva         TVA added?                                     
101               O O O O 0                   yes    (first char of typetva)              
130               N N N N N                   no     (first char of typetva)              
200               N O O O N                   no     (first char of typetva)              
                                                                                          
e.g. Mandat 13 Locataire 00101 ==> tache.nocon = 1300101                                  
                                   tache.pdges = 00002                                    
                                                                                          
RUB              ttTmpRubqt.typetva      TVA added?                                        
101               O O O O 0                yes      (second char of typetva)              
130               N N N N N                no       (second char of typetva)              
200               N O O O N                yes      (second char of typetva)                   
                                                                                          
The value of ttTmpRubqt.typetva will have an impact on the value assigned to               
aecrdtva.cat-cd (see cptatfac.p)                                                          
                                                                                          
NB : chgrubqt.p contient le même décodage pour le quittancement  !!?                      
                                                                                          
                                                                                          
 Historique des modifications                                              
  N°      Date     Auteur                   Objet                       
 001    27/11/00    SE       On prend en compte le niveau analytique de 
                           la rubrique de quittancement rubqt.prg05     
 002    15/12/00    MP       ttTmpRubqt n'est pas créée si la rubrique   
                             se trouve dans aparm "RUBINT".             
                                                                        
 003    12/09/01    JR     Ajout des rubriques 709 et 729               
                           Le code tache TVA est mis, pour le code 709  
                           comme celui du 707, et , pour le code 729    
                           comme celui du 728 ( Vu avec Prosper)        
                                                                        
 004    04/03/02    JB     0202/0401 difference between etalon Rubqt    
                           and rubriques sous-rubriques found in this   
                           program added in block7. typetva-cd generated
                           with respect to those found in this program  
                                                                        
 005    07/03/02    JB     0202/0401 All generated dynamically from     
                           ladb.rubqt                                   
                                                                        
 006    09/05/05    OF     0405/0409 Gestion de la TVA/services annexes 
                           Modif table partagee ttTmpRubqt                
                           Modif Appel tfacrbqt.p                        
 007    30/08/06    OF     0806/0170 La liste d'aide des rubriques de   
                           quitt n'affiche pas le libelle du cabinet     
 008    04/07/07    AF     0607/0154 Permettre la selection d'un rub    
                           cabinet (= ss-rub à 99)                      
 009   19/12/2007    SY    1207/0285 : suite fiche 1207/0247 on ne peut 
                           pas calculer de la TVA sur rub Hono TTC      
                           => famille 04 sfam 02 à exclure du total Qtt 
                           + correctif APL, Services hotelier, DG...    
 010   19/12/2007    SY    1207/0285 : nouveau calcul TVA CDCAL 00006   
                           Total quittance - charges                    
 011   07/12/2008    DM    0408/0032 Gestion rubrique hono par le quit  
 012   16/10/2009    SY    0309/0058 : modifications pour nouvelles     
                           rub Hono loc ouvertes avec 20 libellés à vide
 013   02/12/2009    SY    1108/0397 Quittancement rubriques calculées  
 014   19/02/2010    SY    1108/0443 ICADE - Ventilation 70-30%         
                           Si param HOLOQ alors on charge quand même    
                           les anciennes rub extournables               
                           si ventilation <> 100% (pour historisation)  
                           mais elles ne sont pas saisissables          
 015   18/02/2011    SY    0110/0230 utilisation include LibRubQ2.i     
                           pour le libellé des rubriques de quitt       
 016   19/10/2011    NP    1011/0100 modif comm\librubq2.i suite à      
                           évolution fiche 0110/0230                    
 0017  24/01/2012    SY    0112/0154 Option de régul GOSSELIN           
                           Nouvelle sous-famille 08 pour fam 04 Admin   
 0018  07/11/2013    SY    1013/0167 Filtrer Nlle rub TVA 10% et 20%    
 0019  21/11/2013    SY    Ajout sous-famille 8 pour services annexes   
 0020  13/12/2013    SY    1213/0119 TVA 2014 - Rub calculées et Serv.  
                           Si on est en décembre 2013, prendre          
                           le taux 19.6 même si la bascule a été faite   
 0021  08/02/2017    SY    1011/0158 La rubrique 629 interets sur arrieres
                           n'est pas soumise à TVA                        
                           Utilisation Nlle fonction f_isRubSoumiseTVABail
-----------------------------------------------------------------------------*/
{preprocesseur/type2contrat.i}
{preprocesseur/type2tache.i}

using parametre.pclie.parametrageRubriqueQuittHonoCabinet.
using parametre.pclie.parametrageRubriquesCalculees.
using parametre.pclie.parametrageRubriqueExtournable.
using parametre.syspr.syspr.

{oerealm/include/instanciateTokenOnModel.i} /* Doit être positionnée juste après using */

{cadbgestion/include/tbLstRub.i}
{adb/include/fcttvaru.i}            // fonctions f_isRubSoumiseTVABail, f_donnerubtva, donneTauxTvaArticleDate, f_donnetauxtvarubqt
{adb/include/cdanarub.i}            // description cdanaN
{bail/include/libelleRubQuitt.i}    // function f_librubqt, procédure recupLibelleDefautRubrique
  
define variable giNumeroContrat as int64   no-undo.
define variable giMoisUse       as integer no-undo.
define variable giSociete       as integer no-undo.
define variable glDebug         as logical no-undo init yes.

define variable goRubriqueQuittHonoCabinet as class parametrageRubriqueQuittHonoCabinet no-undo.
define variable goRubriquesCalculees       as class parametrageRubriquesCalculees no-undo.
define variable goRubriqueExtournable      as class parametrageRubriqueExtournable no-undo.
define variable goSyspr                    as class syspr no-undo.
  
define stream stDebug.

procedure lancementtFacrbqt:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   : service externe
    ------------------------------------------------------------------------*/
    define input parameter piSociete       as integer no-undo.
    define input parameter piNumeroContrat as int64   no-undo.
    define input parameter pgiMoisUse      as integer no-undo.
    define output parameter table for ttTmpRubqt.

    empty temp-table ttTmpRubqt.
    assign
        giSociete                  = piSociete
        giNumeroContrat            = piNumeroContrat
        giMoisUse                  = pgiMoisUse
        goRubriqueQuittHonoCabinet = new parametrageRubriqueQuittHonoCabinet()
        goRubriquesCalculees       = new parametrageRubriquesCalculees()
        goRubriqueExtournable      = new parametrageRubriqueExtournable()
        goSyspr                    = new syspr("CDTVA", "")          
    .
    if giMoisUse = 0 
    then giMoisUse = integer(string(year(today), "9999") + string(month(today), "99" )).
    
message "lancementtFacrbqt "   giSociete   giNumeroContrat giMoisUse.
    
    run tfacrbqtPrivate.
    delete object goRubriqueQuittHonoCabinet.
    delete object goRubriquesCalculees.
    delete object goRubriqueExtournable.
    delete object goSyspr.

end procedure.

procedure tfacrbqtPrivate private:
    /*------------------------------------------------------------------------
    Purpose :
    Notes   :
    ------------------------------------------------------------------------*/
    define variable viI               as integer   no-undo.
    define variable vdTauxTva         as decimal   no-undo.
    define variable vcNomFichierDebug as character no-undo.
    define variable vlHonoLocQuit     as logical   no-undo.
    define variable vlSaiRubInterdite as logical   no-undo.
    define variable vcCodeArticle     as character no-undo. 
    define variable vlRubCalFisc      as logical   no-undo.
   
    define buffer rubqt      for rubqt.
    define buffer ifdparam   for ifdparam.
    define buffer aparm      for aparm. 
    define buffer tache      for tache.
    define buffer vbrubqt    for rubqt.
    define buffer vbtachetva for tache.
    define buffer vbrubqttax for rubqt.
    define buffer ifdart     for ifdart.
    define buffer itaxe      for itaxe.
    define buffer detail     for detail.

    empty temp-table ttTmpRubqt.
    
    /* Paramètre hono loc par le quit activé */
    if goRubriqueQuittHonoCabinet:isDbParameter
    then vlHonoLocQuit = true.
    /* Ajout SY le 02/12/2009 : rubriques calculées avec ou sans régime fiscal personnalisé */
    if goRubriquesCalculees:avecRegimeFiscalPersonnalise()
    then vlRubCalFisc = yes.
    find first ifdparam no-lock 
         where ifdparam.soc-dest = giSociete no-error.
    for each rubqt no-lock 
       where rubqt.cdlib <> 0:                     
        vlSaiRubInterdite = false.
        find first aparm no-lock
             where aparm.tppar = "TFACT"
               and aparm.cdpar = "RUBINT" no-error.
        if not available aparm or lookup(string(rubqt.cdrub), aparm.zone2, "|") = 0 
        then do:
            /* TVA sur services annexes */
            find last tache no-lock
                where tache.tpcon = {&TYPECONTRAT-bail}
                  and tache.nocon = giNumeroContrat
                  and tache.tptac = {&TYPETACHE-TVAServicesAnnexes} no-error.
            /* Modif SY le 16/10/2009 : hono cabinet au locataire HOLOQ */
            /* Controle rub hono famille 08 : au moins un libellé avec un Article doit être paramétré */
            /* controle ancienne rub hono (640,...) */      
            if rubqt.cdfam = 08 and not goRubriqueQuittHonoCabinet:auMoinsUnLibelleArticle(rubqt.cdrub, rubqt.cdlib)
            then next.    
            if vlHonoLocQuit
            then do:
                /* Anciennes rubriques EXTOURNABLES interdites */   
                /* sauf celles générées par la ventilation 70-30 % (mais non saisissables) */
                if goRubriqueExtournable:isRubriqueExtournable(rubqt.cdrub)
                then do:    
                    if not goRubriqueQuittHonoCabinet:gereParLaVentilation(rubqt.cdrub, rubqt.cdlib)   
                    then next.
                    vlSaiRubInterdite = true.
                end.                                            
            end.
            create ttTmpRubqt.
            assign 
                ttTmpRubqt.rubqt-cd          = string(rubqt.cdrub,"999")            
                ttTmpRubqt.ssrubqt-cd        = string(rubqt.cdlib,"99")
                ttTmpRubqt.ana1-cd           = cdana1[ integer(rubqt.prg05) ]
                ttTmpRubqt.ana2-cd           = cdana2[ integer(rubqt.prg05) ]
                ttTmpRubqt.ana3-cd           = cdana3[ integer(rubqt.prg05) ] 
                ttTmpRubqt.typeTva-cd        = /* Total loyer (sauf APL) */
                                              (if f_isRubSoumiseTVABail(input "00001", input rubqt.cdfam, input rubqt.cdsfa, input rubqt.cdrub, integer(rubqt.prg05)) then "O" else "N") 
                                              + "," +                                                                            
                                              /* Total quittance (sauf rubriques TVA,APL, services hoteliers, assurance locatives, DG, Hono TTC */                  
                                              /* Modif SY le 24/01/2012 : Ajout sous-famille 08 Loyer/redevance/services à 5,5% */
                                              (if f_isRubSoumiseTVABail(input "00002", input rubqt.cdfam, input rubqt.cdsfa, input rubqt.cdrub, integer(rubqt.prg05)) then "O" else "N")   
                                              + "," +
                                              /* Total loyer + charges */
                                              (if f_isRubSoumiseTVABail(input "00003", input rubqt.cdfam, input rubqt.cdsfa, input rubqt.cdrub, integer(rubqt.prg05)) then "O" else "N") 
                                              + "," +                                               
                                              /* Total loyer + charges + taxes (sauf rubriques TVA)*/     
                                              (if f_isRubSoumiseTVABail(input "00004", input rubqt.cdfam, input rubqt.cdsfa, input rubqt.cdrub, integer(rubqt.prg05)) then "O" else "N") 
                                              + "," +                                           
                                              /* Total loyer + taxes (sauf rubriques TVA) */     
                                              (if f_isRubSoumiseTVABail(input "00005", input rubqt.cdfam, input rubqt.cdsfa, input rubqt.cdrub, integer(rubqt.prg05)) then "O" else "N")                                                                                                                                                                         
      
                                               /* Total quittancement - charges (Ajout SY le 20/12/2007) */ /* Modif SY le 24/01/2012 : Ajout sous-famille 08 Loyer/redevance/services à 5,5% */
                                               + "," + 
                                              (if f_isRubSoumiseTVABail(input "00006", input rubqt.cdfam, input rubqt.cdsfa, input rubqt.cdrub, integer(rubqt.prg05)) then "O" else "N")
                ttTmpRubqt.fg-calc           = (rubqt.cdgen = "00004") 
                                                or (not available tache and rubqt.cdfam = 4 
                                                        and (rubqt.cdsfa = 3 or rubqt.cdsfa = 5 or rubqt.cdsfa = 6 or rubqt.cdsfa = 8))
                                                or vlSaiRubInterdite    /* Ajout Sy le 19/02/2010 */                                                  
                ttTmpRubqt.cdfam             = rubqt.cdfam
                ttTmpRubqt.cdsfa             = rubqt.cdsfa
                .
            ttTmpRubqt.lib = f_librubqt(rubqt.cdrub, rubqt.cdlib, giNumeroContrat, giMoisUse, 0, 0, integer(mtoken:cRefGerance)).
            if available tache 
            then do viI = 1 to num-entries(tache.lbdiv,"@"):
                if num-entries(entry(viI,tache.lbdiv,"@"),"#") > 3 
                and integer(entry(3,entry(viI,tache.lbdiv,"@"),"#")) = rubqt.cdfam
                and integer(entry(4,entry(viI,tache.lbdiv,"@"),"#")) = rubqt.cdsfa 
                then do:
                    goSyspr:reload("CDTVA", entry(5, entry(viI,tache.lbdiv, "@"), "#")).
                    if goSyspr:isDbParameter 
                    then do:
                        assign
                            ttTmpRubqt.rubtva = integer(entry(1, entry(viI, tache.lbdiv, "@"), "#"))
                            ttTmpRubqt.taux = goSyspr:zone1
                        .
                        if giMoisUse > 0 and giMoisUse < 201401 and ttTmpRubqt.taux = 20 
                        then assign
                                 ttTmpRubqt.rubtva = 788
                                 ttTmpRubqt.taux = 19.6
                        .
                        if giMoisUse > 0 and giMoisUse < 201401 and ttTmpRubqt.taux = 10 
                        then assign
                                 ttTmpRubqt.rubtva = 783
                                 ttTmpRubqt.taux = 7
                        .         
                    end.
                end.
            end.
            if available ifdparam and rubqt.cdfam = 8 
            then do: /* Rubriques Hono HT */
                vcCodeArticle = goRubriqueQuittHonoCabinet:getCodeArticleProprietaire(rubqt.cdrub, rubqt.cdlib).
                if vcCodeArticle <> ? and vcCodeArticle <> "" 
                then do:                  
                    for first ifdart no-lock
                        where ifdart.soc-cd  = ifdparam.soc-cd
                          and ifdart.art-cle = vcCodeArticle:
                        for first itaxe no-lock
                            where itaxe.soc-cd = ifdparam.soc-cd
                              and itaxe.taxe-cd = ifdart.taxe-cd:
                            for first vbrubqt no-lock 
                                where vbrubqt.prg07 = "HL" 
                                  and vbrubqt.prg04 = string(itaxe.taux * 100):
                                assign
                                    ttTmpRubqt.rubtva = vbrubqt.cdrub
                                    ttTmpRubqt.taux   = itaxe.taux
                                .
                            end.   
                            if giMoisUse > 0 and giMoisUse < 201401 and ttTmpRubqt.taux = 20 
                            then assign
                                     ttTmpRubqt.rubtva = 908
                                     ttTmpRubqt.taux   = 19.6
                            .
                            if giMoisUse > 0 and giMoisUse < 201401 and ttTmpRubqt.taux = 10 
                            then assign
                                     ttTmpRubqt.rubtva = 903
                                     ttTmpRubqt.taux   = 7
                            .                                                 
                        end.                                    
                    end.                    
                end.                
            end.
            if vlRubCalFisc 
            then do:
                for first detail no-lock 
                    where detail.cddet = {&TYPECONTRAT-bail}
                      and detail.nodet = giNumeroContrat
                      and detail.iddet = integer("04360")
                      and detail.ixd01 = string(rubqt.cdrub, "999") + string(rubqt.cdlib, "99"):
                    /* rubrique calculée */
                    ttTmpRubqt.fg-calc = (rubqt.cdgen = "00004") .    
                    /* soumis à la fiscalité du bail ? */
                    if detail.tblog[1] 
                    then do:
                        for last vbtachetva no-lock
                           where vbtachetva.tpcon = {&TYPECONTRAT-bail}
                             and vbtachetva.nocon = giNumeroContrat
                             and vbtachetva.tptac = {&TYPETACHE-TVABail}:
                            goSyspr:reload("CDTVA", vbtachetva.ntges).  //integer(sys_pr.cdpar) = integer(vbtachetva.ntges)
                            if goSyspr:isDbParameter 
                            then do:
                                assign
                                    ttTmpRubqt.rubtva     = integer(entry(1,vbtachetva.lbdiv, "#"))
                                    ttTmpRubqt.taux       = goSyspr:zone1
                                    ttTmpRubqt.typeTva-cd = fill("O,", 6)    /* cette rubrique rentre dans le calcul de TVA du bail quel que soit le mode de calcul */
                                .
                                if giMoisUse > 0 and giMoisUse < 201401 and ttTmpRubqt.taux = 20 
                                then assign
                                         ttTmpRubqt.rubtva = 778
                                         ttTmpRubqt.taux = 19.6
                                .
                                if giMoisUse > 0 and giMoisUse < 201401 and ttTmpRubqt.taux = 10 
                                then assign
                                         ttTmpRubqt.rubtva = 773
                                         ttTmpRubqt.taux = 7
                                .                                       
                            end.    
                        end.                                                                              
                    end.
                    else 
                    if detail.ixd03 = "04039" 
                    then do:
                        goSyspr:reload("CDTVA", detail.tbchr[3]).    //integer(sys_pr.cdpar) = integer(detail.tbchr[3])
                        if goSyspr:isDbParameter
                        then do: 
                            vdTauxTva = goSyspr:zone1.                            
                            if giMoisUse > 0 and giMoisUse < 201401 and vdTauxTva = 20 then vdTauxTva = 19.6.
                            if giMoisUse > 0 and giMoisUse < 201401 and vdTauxTva = 10 then vdTauxTva = 7.                 
                            /* Recherche de la rubrique tva associée au taux */
                            for first vbrubqttax no-lock
                                where vbrubqttax.cdfam = 05
                                  and vbrubqttax.cdsfa = 02
                                  and vbrubqttax.cdrub < 770
                                  and vbrubqttax.cdlib > 00
                                  and vbrubqttax.cdlib < 99
                                  and vbrubqttax.cdgen = "00003"                  /* Variable (pas la TVA Calcul) */  /* SY 1013/0167 */
                                  and vbrubqttax.cdsig = "00002"                  /* positif/négatif */
                                  and vbrubqttax.prg04 = string(vdTauxTva * 100):
                                /* normalement zones tva/service annexe  */
                                assign
                                    ttTmpRubqt.rubtva     = vbrubqttax.cdrub
                                    ttTmpRubqt.taux       = vdTauxTva
                                    ttTmpRubqt.typeTva-cd = fill("N,", 6)    /* cette rubrique ne rentre pas dans le calcul de TVA du bail (TVA séparée)*/
                                .   
                            end.                                                                                                 
                        end.                                
                    end.                                    
                end.
            end.        
        end.
    end.
    if glDebug 
    then do:
        /* ouverture du canal d'exportation */
        vcNomFichierDebug = "tfacrbqt-" + string(giSociete , "99999") + ".txt" .
        output stream stDebug to value(session:temp-directory + vcNomFichierDebug).
        put stream stDebug unformatted 
            string(today, "99/99/9999") +  " " + string(time, "HH:MM:SS") skip
            "Locataire   " + string(giNumeroContrat) skip.   
        for each ttTmpRubqt:
            export stream stDebug delimiter "|" ttTmpRubqt.
        end. 
        output stream stDebug close.       
    end.    
    
end procedure.
    
