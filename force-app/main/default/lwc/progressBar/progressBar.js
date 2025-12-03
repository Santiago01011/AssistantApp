import { LightningElement, api } from 'lwc';

export default class ProgressBar extends LightningElement {
    @api value = 0; // 0-100
    @api height = '10px';

    get normalizedValue() {
        let v = Number(this.value) || 0;
        if (v < 0) v = 0;
        if (v > 100) v = 100;
        return v;
    }

    get fillStyle() {
        return `width: ${this.normalizedValue}%; height: ${this.height};`;
    }
}