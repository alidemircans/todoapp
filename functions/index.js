const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { snapshotConstructor } = require('firebase-functions/lib/providers/firestore');

try{
admin.initializeApp(functions.config().firebase);
var msgData;

exports.taskTrigger = functions.firestore.document(
    'Task/{TaskId}'
).onCreate((snapshot,context)=>{

    admin.firestore().collection('Tasks').get().then((snapshots)=>{
        var tokens = [];

        if(snapshots.empty){
            console.log("Cihaz yok");

        }
        else{
            for(var token of snapshot.docs){
                tokens.push(token.data().Token)
            }
            var payload = {
                "notifications" : {
                    "title" :"Yeni bir proje Paylaşıldı!",
                    "body" : msgData.todoTitle,
                    "sound":"default"
                },
                "data" : {
                    "message" : msgData.todoTitle
                } 

                
            }

            return admin.messaging().sendToDevice(tokens,payload).then((response)=>{

                return console.log("Bildiirmler gönderildi!");
            }).catch((err)=>{
                
            })
        }
    })
   

  
})
}
catch(err){
    throw console.log(err);
       }
    