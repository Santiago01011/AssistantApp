import { LightningElement, api, track } from 'lwc';

export default class IhdStatsCard extends LightningElement {
    @api label = '';
    @api value = 0;
    @api delta;
    @api iconName = 'utility:task';

    @track displayValue = 0;

    connectedCallback() {
        this.animateValue(0, Number(this.value || 0), 700);
    }

    renderedCallback() {
        // if value changed, animate to new
        if (Number(this.displayValue) !== Number(this.value)) {
            this.animateValue(Number(this.displayValue), Number(this.value || 0), 700);
        }
    }

    get hasDelta() {
        return typeof this.delta !== 'undefined' && this.delta !== null;
    }

    get deltaText() {
        if (!this.hasDelta) return '';
        return this.delta > 0 ? `+${this.delta}` : `${this.delta}`;
    }

    get deltaTitle() {
        return this.hasDelta ? `Change ${this.deltaText}` : '';
    }

    // simple count-up animation
    animateValue(from, to, duration) {
        const start = performance.now();
        const step = (ts) => {
            const elapsed = ts - start;
            const t = Math.min(1, elapsed / duration);
            const eased = t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t; // easeInOut
            const current = Math.round(from + (to - from) * eased);
            this.displayValue = current;
            if (t < 1) {
                window.requestAnimationFrame(step);
            }
        };
        window.requestAnimationFrame(step);
    }
}