import { LightningElement, wire, track } from 'lwc';
import getTasks from '@salesforce/apex/PAB_Ctrl.getTasks';
import updateTaskStatus from '@salesforce/apex/PAB_Ctrl.updateTaskStatus';
import quickCapture from '@salesforce/apex/PAB_Ctrl.quickCapture';
import deleteTask from '@salesforce/apex/PAB_Ctrl.deleteTask';

export default class PabAssistantDashboard extends LightningElement {
    @track tasks;
    error;
    isLoading = false;
    quickText = '';
    // UI stats
    totalTasks = 0;
    todayCount = 0;
    overdueCount = 0;
    percentComplete = 0;
    lastUpdated = null;
    statusOptions = [
        { label: 'New', value: 'New' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Completed', value: 'Completed' },
        { label: 'Deferred', value: 'Deferred' }
    ];


    @wire(getTasks)
    wiredTasks({ error, data }) {
        if (data) {
            this.tasks = data;
            this.error = undefined;
            this.computeStats();
        } else if (error) {
            this.error = error;
            this.tasks = undefined;
        }
    }

    computeStats() {
        if (!this.tasks) {
            this.totalTasks = 0;
            this.todayCount = 0;
            this.overdueCount = 0;
            this.percentComplete = 0;
            this.lastUpdated = null;
            return;
        }
        const today = new Date();
        let completed = 0;
        let todayCount = 0;
        let overdue = 0;
        for (const t of this.tasks) {
            if (t.Status__c === 'Completed') completed++;
            if (t.Due_Date__c) {
                const d = new Date(t.Due_Date__c);
                // normalize
                if (d.toDateString() === today.toDateString()) todayCount++;
                if (d < today && t.Status__c !== 'Completed') overdue++;
            }
        }
        this.totalTasks = this.tasks.length;
        this.todayCount = todayCount;
        this.overdueCount = overdue;
        this.percentComplete = this.totalTasks > 0 ? Math.round((completed / this.totalTasks) * 100) : 0;
        this.lastUpdated = new Date().toISOString();
        // update any progress-fill elements imperatively (avoid template style binding issues)
        try {
            const fills = this.template ? this.template.querySelectorAll('.progress-fill') : [];
            fills.forEach((el) => {
                if (el && typeof el.style !== 'undefined') {
                    el.style.width = `${this.percentComplete}%`;
                }
            });
        } catch (e) {
            // defensive: if template isn't ready or query fails, ignore
        }
    }

    get hasTasks() {
        return this.tasks && this.tasks.length > 0;
    }

    get formattedLastUpdated() {
        if (!this.lastUpdated) return 'never';
        try {
            const dt = new Date(this.lastUpdated);
            return dt.toLocaleTimeString();
        } catch (e) {
            return this.lastUpdated;
        }
    }

    handleQuickTextChange(event) {
        this.quickText = event.target.value;
    }

    handleQuickCapture() {
        if (!this.quickText) {
            return;
        }
        this.isLoading = true;
        quickCapture({ description: this.quickText })
            .then((created) => {
                this.quickText = '';
                return getTasks();
            })
            .then((data) => {
                this.tasks = data;
                this.error = undefined;
            })
            .catch((err) => {
                this.error = err;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleStatusChange(event) {
        const datasetOwner = event.currentTarget || event.target;
        const taskId = datasetOwner?.dataset?.id;
        const status = event.detail.value;
        if (!taskId || !status) {
            return;
        }
        this.isLoading = true;
        updateTaskStatus({ taskId, status })
            .then(() => getTasks())
            .then((data) => {
                this.tasks = data;
                this.error = undefined;
            })
            .catch((err) => {
                this.error = err;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleTaskStatusChange(event) {
        const { taskId, status } = event.detail;
        this.isLoading = true;
        updateTaskStatus({ taskId, status })
            .then(() => getTasks())
            .then((data) => {
                this.tasks = data;
                this.error = undefined;
            })
            .catch((err) => {
                this.error = err;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleTaskDelete(event) {
        const { taskId } = event.detail;
        this.isLoading = true;
        deleteTask({ taskId })
            .then((ok) => {
                if (ok) return getTasks();
                throw new Error('Delete failed');
            })
            .then((data) => { this.tasks = data; })
            .catch((err) => { this.error = err; })
            .finally(() => { this.isLoading = false; });
    }

    handleDelete(event) {
        const datasetOwner = event.currentTarget || event.target;
        const taskId = datasetOwner?.dataset?.id;
        if (!taskId) return;
        if (!confirm('Delete this task? This action cannot be undone.')) return;
        this.isLoading = true;
        deleteTask({ taskId })
            .then((ok) => {
                if (ok) return getTasks();
                throw new Error('Delete failed');
            })
            .then((data) => { this.tasks = data; })
            .catch((err) => { this.error = err; })
            .finally(() => { this.isLoading = false; });
    }

}