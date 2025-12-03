import { LightningElement, api } from 'lwc';

export default class DebugTaskCard extends LightningElement {
    @api value;
    @api debug = false; // default false — Agent Builder can map to true for testing

    get debugJson() {
        try {
            return JSON.stringify(this.value ?? {}, null, 2);
        } catch (e) {
            return String(e);
        }
    }

}