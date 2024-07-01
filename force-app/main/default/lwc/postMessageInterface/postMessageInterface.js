import { LightningElement, track, api, wire } from 'lwc';

import { PostMessage } from 'c/postMessage';

export class PostMessageInterface extends LightningElement{
	
	@api params;
	@api postMessage;

	connectedCallback(){
		let postmessage = this.postMessage

		postmessage(this.params.id, (data)=>{
			this._message = data.txt;
		})

		PostMessage.hookRequest(this.params.id);
	}

	renderedCallback(){
		PostMessage.resize(this.params.id);
	}
}