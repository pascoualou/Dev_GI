/*------------------------------------------------------------------------
File        : trigger-appli.p
Purpose     : lancement des triggers programmes   
Author(s)   : GGA 2018/11/26
Notes       : 
------------------------------------------------------------------------*/

//gga todo pourquoi aussi ctrigpme et comptapm ?

{oerealm/include/instanciateTokenOnModel.i}      // Doit être positionnée juste après using

define input parameter startup-data as character no-undo.

run trigger/trigger-compta.p persistent.
run trigger/trigger-cadb.p persistent.
