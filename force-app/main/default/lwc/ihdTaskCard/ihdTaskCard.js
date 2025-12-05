import { LightningElement, api } from 'lwc';

export default class IhdTaskCard extends LightningElement {
    // private reactive fields
    _task = null;
    _taskIndex = 0;
    _value = null;
    borderColor = '#DDDBDA';

    // public api
    @api statusOptions = [];

    /**
     * Public property used to pass the CLT response (or similar payload).
     * Setter normalizes the first user task into a plain POJO.
     */
    @api
    get value() {
        return this._value;
    }

    set value(v) {
        this._value = v;
        this.normalizeValue(v);
    }

    // expose a read-only task property for template binding
    get task() {
        return this._task;
    }

    normalizeValue(raw) {
        try {
            if (!raw) {
                this._task = null;
                return;
            }

            let taskData = raw;

            if (raw.userTasks && Array.isArray(raw.userTasks) && raw.userTasks.length > 0) {
                taskData = raw.userTasks[0];
            }

            if (taskData && taskData.Id) {
                this._task = this.normalizeRecord(taskData);
                this.updateStatusColor();
            } else {
                this._task = null;
            }
        } catch (e) {
            this._task = null;
        }
    }

    normalizeRecord(t) {
        // The CLT engine tends to pass dates without timezone.
        // We must ALWAYS return a pure object (no proxies, no reactive copies).
        const toIso = function(dateStr) {
            if (!dateStr) return null;
            try {
                let s = dateStr.replace(' ', 'T');
                if (!/Z$/.test(s) && !/[+-]\d{2}:?\d{2}$/.test(s)) {
                    s += 'Z';
                }
                return s;
            } catch (e) {
                return null;
            }
        };

        return {
            Id: t.Id,
            Title: t.Title,
            Description: t.Description,
            Context: t.Context,
            Status: t.Status,
            Due_Date_ISO: toIso(t.Due_Date),
            Due_Date: t.Due_Date,
            Energy_Level: t.Energy_Level
        };
    }

    /**
     * When status changes, dispatch a clear, descriptive event.
     * Parent components should handle persistence and related confirmation.
     */
    handleStatusChange(event) {
        if (!this._task) return;

        const newStatus = event.detail.value;
        this._task.Status = newStatus;
        this.updateStatusColor();

        this.dispatchEvent(
            new CustomEvent('taskstatuschange', {
                detail: {
                    taskId: this._task.Id,
                    status: newStatus
                }
            })
        );
    }

    /**
     * Do not perform destructive actions (like confirm) inside the reusable
     * component. Instead, emit a 'requestdelete' event and let the parent
     * show confirmation and perform the deletion. This follows LWC best
     * practices and separates concerns.
     */
    handleDelete() {
        if (!this._task) return;

        this.dispatchEvent(
            new CustomEvent('requestdelete', {
                detail: {
                    taskId: this._task.Id
                }
            })
        );
    }

    get computedStyle() {
        return `border-left-color: ${this.borderColor};`;
    }

    updateStatusColor() {
        const colorMap = {
            'Completed': '#04844B',
            'In Progress': '#0070D2',
            'Not Started': '#DDDBDA',
            'Overdue': '#EA001E'
        };
        this.borderColor = colorMap[this._task?.Status] || '#DDDBDA';
    }

    get dynamicBorderStyle() {
        return `--border-color: ${this.borderColor}`;
    }

    get statusBadgeStyle() {
        const statusColorMap = {
            'Completed': { bg: '#dffcf0', text: '#04844B' },
            'In Progress': { bg: '#e3f2fd', text: '#0070D2' },
            'Overdue': { bg: '#ffebee', text: '#EA001E' },
            'Deferred': { bg: '#fff3e0', text: '#F57C00' }
        };
        const colors = statusColorMap[this._task?.Status] || { bg: '#f5f5f5', text: '#616161' };
        return `--slds-c-badge-color-background: ${colors.bg}; --slds-c-badge-text-color: ${colors.text}`;
    }

    get energyBadgeStyle() {
        const energyColorMap = {
            'High': { bg: '#ffebee', text: '#c62828' },
            'Medium': { bg: '#fff3e0', text: '#e65100' },
            'Low': { bg: '#e8f5e9', text: '#33691e' }
        };
        const colors = energyColorMap[this._task?.Energy_Level] || { bg: '#f5f5f5', text: '#616161' };
        return `--slds-c-badge-color-background: ${colors.bg}; --slds-c-badge-text-color: ${colors.text}`;
    }

}
