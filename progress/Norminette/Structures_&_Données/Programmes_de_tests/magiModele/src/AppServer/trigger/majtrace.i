/* gga todo
pour le moment reprise de ce programme pouvoir tester les maj pour le traitement de validation de mutation
code a reprendre au moment de l'ecriture des ***_CRUD.p en meme temps que alimacpt et trigger-appli.p                           
gga*/

/*--------------------------------------------------------------------------+
| Application      : COMPTA ADB Progress V8                                 |
| Programme        : majtrace.i                                             |
| Objet            : mise a jour des champs de trace                        |
|===========================================================================|
| Date de création : 01/04/04                                               |
| Auteur(s)        : PS                                                     |
|===========================================================================|
| Paramètres d'entrées  : {1} = nom de la table                             |
|                         {2} = "MOD" on force en modif                     |
|                               "CRE" on force en creation                  |
+---------------------------------------------------------------------------+
+--------------------------------------------------------------------------*/
if available {1} then 
    &IF "{2}" = "" &THEN
        if time - {1}.ihcrea < 60 and time >= {1}.ihcrea and {1}.dacrea = today 
        then . /** modif suite a la creation ==> pas de trace **/
        else 
        if {1}.dacrea ne ? 
        then assign 
                 {1}.damod    = today
                 {1}.ihmod    = mtime
                 {1}.usridmod = GcUserId
        .
        else assign 
                 {1}.dacrea = today
                 {1}.ihcrea = mtime
                 {1}.usrid  = GcUserId
        .
    &ENDIF
    &IF "{2}" = "CRE" &THEN 
        assign 
            {1}.dacrea = today
            {1}.ihcrea = mtime
            {1}.usrid  = GcUserId
        .    
    &ENDIF    
    &IF "{2}" = "MOD" &THEN 
        assign 
            {1}.damod    = today
            {1}.ihmod    = mtime
            {1}.usridmod = GcUserId
        .    
    &ENDIF    
 
