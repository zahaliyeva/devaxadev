({
    onInit : function(component, event, helper)
	{
		var action = component.get("c.getPageValues");

    	action.setCallback(this, function (response) {
            const result = response.getReturnValue();
            const state = response.getState();
    
            console.log(result);
            if (state === "SUCCESS") {
              var Value = result.automaticPickUp;
              
              component.set("v.setMeOnInit", Value);
            }
    	});
    	$A.enqueueAction(action);
		
	},
  onWorkAssigned : function( component, event, helper) {
      // define a function in the current context that actually issues a notification
      // if we are allowed to do so
        var workItemId = event.getParam('workItemId');
        //alert(workItemId);
      function doNotify() {
          var notify = new Notification( 'Salesforce OmniChannel', {
              body: 'New request!',
              tag: 'SalesforceOmnichannel',
              requireInteraction: false,
              renotify: true,
              lang: 'IT',
          });
            notify.onclick = (e) => {
                //window.open('https://axaitalia--scvdev.sandbox.lightning.force.com/lightning/o/VoiceCall/list?filterName=Recent', 'ctab4')
                window.focus();
      		}
        }


      // first check whether browser does actually suport notifications
      if ( !window.Notification) {
          alert( 'Notification API not supported in this browser!');
      } else {
          // OK - if user did previously grant permission to
          // show notification there is not a lot to do -
          // simply call the function defined above
          if ( Notification.permission === 'granted') {
              if(workItemId.startsWith('0LQ'))
                    		{
                              doNotify();
                     		}
          } else {
              // OK - permission is not granted.
              // if permission is "default" we may ask
              if ( Notification.permission === 'default') {
                  Notification.requestPermission().then(
                      // the following "success"-"function" gets executed BEFORE the message
                      // in the event loop will be executed - BUT asynchronously
                      // at the end of the current eventloop
                      ( permissionRequestResult) => {
                          if ( permissionRequestResult === 'granted') {
                              // show notification here
                          if(workItemId.startsWith('0LQ'))
                    		{
                              doNotify();
                     		}
                          } else {
                              console.log( 'User denied Notifications after requesting permission!');
                          }
                      }
                  ).catch(
                      // this is for when the requestPermission promise calls the failure branch
                      ( err) => {
                          console.log( 'Failing Notification.requestPermission');
                      }
                  );
              } else {
                  // permission must have the value of "denied"
                  // it looks as if we are not allowed to ask for permission
                  console.log('User denied Notifications before requesting permission!');
              }
          }
      }
                          var active1 = component.get("v.setMeOnInit");
        var omniAPI = component.find("omniToolkit");
        if (active1) {
          omniAPI
            .getAgentWorks()
            .then(function (result) {
              var works = JSON.parse(result.works);
              var work = works[0];
              omniAPI
                .acceptAgentWork({ workId: work.workId })
                .then(function (result2) {
                  if (result2) {
                    console.log("+++++++++++++++++++++");
                    console.log("Accepted work successfully");
                  } else {
                    console.log("+++++++++++++++++++++");
                    console.log("Accept work failed");
                  }
                })
                .catch(function (error) {
                  console.log("+++++++++++++++++++++");
                  console.log(error);
                });
            })
            .catch(function (error) {
              console.log("+++++++++++++++++++++");
              console.log(error);
            });
        }
  }, 
  acceptWork: function (cmp, evt, hlp) {
    
  },
  requestPermission : function( component, event, helper) {
      // first check whether browser does actually suport notifications
      if ( !window.Notification) {
          alert( 'Notification API not supported in this browser!');
      } else {
          if ( Notification.permission !== 'granted') {
              // Something is wrong here - or I misunderstand the specs
              // if the permission is not "granted" it ought to be
              // "denied" or "default" (where the latter should mean "ask")
              // "default" seems never to be the case as for some reason
              // the permissionRequest pops up during page loading
              // So it ought to be either "granted" or "denied"
              // At least on my Chrome (March 2020) - if the
              // user previously did deny the Notification no new permissionRequest
              // is shown - regardless whether requesting permission from a button
              // as trying to do here or in the onWorkAssigned case
              // Nevertheless I'll keep this code...
              Notification.requestPermission().then(
                  // the following "success"-"function" gets executed BEFORE the message
                  // in the event loop will be executed - BUT asynchronously
                  // at the end of the current eventloop
                  ( permissionRequestResult) => {
                      if ( permissionRequestResult !== 'granted') {
                          console.log( 'User denied Notifications after requesting permission!');
                      }
                  }
              ).catch(
                  // this is for when the requestPermission promise calls the failure branch
                  ( err) => {
                      console.log( 'Failing Notification.requestPermission');
                  }
              );
          }
      }
  }


})