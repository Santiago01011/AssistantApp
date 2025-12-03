import { LightningElement, api } from 'lwc';

export default class IhdIntegrationSummaryCard extends LightningElement {
    @api title = 'Completion';
    @api summary = '';
    @api percentComplete = 0;
}