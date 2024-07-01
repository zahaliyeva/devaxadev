import { LightningElement } from 'lwc';

export class PostMessage {

	static prevHeigth = 0;

	static get ACTIONS(){
		return {
			AUTH_CONFIRM: 		"AUTH_CONFIRM",
			AUTH_REFRESH: 		"AUTH_REFRESH",
			HOOK_REQUEST: 		"HOOK_REQUEST",
			GOTO: 				"GOTO",
			NAVIGATETO: 		"NAVIGATETO",
			RESIZE: 			"RESIZE",
			OPEN_SESSION: 		"OPEN_SESSION",
			OPEN_CALLBACK: 		"OPEN_CALLBACK",
			DEBUG: 				"DEBUG",
			CLOSE_MODAL:		"CLOSE_MODAL",
			MOBILITYNPSINFO:	"mobilityNpsInfo"
		}
	}


	static mobilityNpsInfo(id, params){
		PostMessage.sendMessage({
			action: PostMessage.ACTIONS.MOBILITYNPSINFO,
			id,
			params
		});
		
	}

	static authConfirm(id){
		PostMessage.sendMessage({
			action: PostMessage.ACTIONS.AUTH_CONFIRM,
			id
		});
	}

	static authRefresh(id, params){
		PostMessage.sendMessage({
			action: PostMessage.ACTIONS.AUTH_REFRESH,
			id,
			params
		});
	}

	static hookRequest(id){
		PostMessage.sendMessage({
			action: PostMessage.ACTIONS.HOOK_REQUEST,
			id
		})
	}

	static goto(id, url){
		PostMessage.sendMessage({
			action: PostMessage.ACTIONS.GOTO,
			id,
			url
		})
	}

	static navigateTo(id, target, params){
		PostMessage.sendMessage({
			action: PostMessage.ACTIONS.NAVIGATETO,
			id,
			target,
			params
		})
	}

	static resize(id){
		let body = document.body;
		let html = document.documentElement;

		let height = Math.max( body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight );

		if(height != PostMessage.prevHeigth){
			PostMessage.prevHeigth = height;

			PostMessage.sendMessage({
				action: PostMessage.ACTIONS.RESIZE,
				id,
				height
			})
		}
	}

	static openCallback(id, params){
		console.log(id, params);
		PostMessage.sendMessage({
			action: PostMessage.ACTIONS.OPEN_CALLBACK,
			id,
			params
		});
	}

	static openSession(id, params){
		PostMessage.sendMessage({
			action: PostMessage.ACTIONS.OPEN_SESSION,
			id,
			params
		});
	}

	static debug(id, txt){
		PostMessage.sendMessage({
			action: PostMessage.ACTIONS.DEBUG,
			id,
			txt
		})
	}

	static sendMessage(request = null){
		if(request.action === 'NAVIGATETO'){
			if(request.target.dashboardId != null){
				request.id='dashboardEvent';
			}
			
		}
		
		window.parent.postMessage({...request}, '*');
	}

	static close_Modal(){
		var req = {
			action: PostMessage.ACTIONS.CLOSE_MODAL,
			params: {
				type: PostMessage.ACTIONS.CLOSE_MODAL
			}
		};
		PostMessage.sendMessage(req);
	}
}