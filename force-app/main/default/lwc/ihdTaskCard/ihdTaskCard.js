import { LightningElement, api } from 'lwc';

export default class IhdTaskCard extends LightningElement {
    @api value;
    @api statusOptions = [];
    @api debug = false;

    get task() {
        return this.value || {};
    }

    handleStatusChange(event) {
        const detail = {
            taskId: this.task.Id,
            status: event.detail.value
        };
        this.dispatchEvent(new CustomEvent('statuschange', { detail }));
    }

    handleDelete() {
        if (!this.task?.Id) return;
        if (!confirm('Delete this task? This action cannot be undone.')) return;
        this.dispatchEvent(new CustomEvent('delete', { detail: { taskId: this.task.Id } }));
    }

    get _debugJson() {
        try {
            return JSON.stringify(this.value || {}, null, 2);
        } catch (e) {
            return String(e);
        }
    }
}
