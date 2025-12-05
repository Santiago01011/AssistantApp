import { LightningElement, api, track } from 'lwc';

export default class PabAgentTaskList extends LightningElement {
    @track normalized = [];
    searchKey = '';

    @api
    set value(v) {
        this.normalized = this.normalize(v);
    }
    get value() {
        return this.normalized;
    }

    get hasTasks() {
        // This now correctly checks the length of the *filtered* list.
        return this.cardEntries.length > 0;
    }

    get cardEntries() {
        const filtered = this.normalized.filter(item => {
            if (!this.searchKey) {
                return true; // If no search key, show all items
            }
            const searchTerm = this.searchKey.toLowerCase();
            const title = (item.Title || '').toLowerCase();
            const description = (item.Description || '').toLowerCase();

            return title.includes(searchTerm) || description.includes(searchTerm);
        });

        return filtered.map((item, index) => ({
            key: item.Id || `task-${index}`,
            payload: item
        }));
    }

    /**
     * @description Updates the searchKey when the user types in the search input.
     * @param {Event} event The input change event.
     */
    handleSearchChange(event) {
        this.searchKey = event.target.value;
    }

    normalize(rawValue) {
        if (!rawValue) return [];

        // Agent wraps in aUserTasks: { aUserTasks: { userTasks: [...] } }
        if (rawValue.aUserTasks && Array.isArray(rawValue.aUserTasks.userTasks)) {
            return rawValue.aUserTasks.userTasks;
        }

        // Direct wrapped format: { userTasks: [...] }
        if (Array.isArray(rawValue.userTasks)) {
            return rawValue.userTasks;
        }

        // Flat array: [ { Id: "...", ...}, ... ]
        if (Array.isArray(rawValue)) {
            return rawValue;
        }

        return [];
    }
}

