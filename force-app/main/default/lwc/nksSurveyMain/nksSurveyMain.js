import { LightningElement, api } from 'lwc';
import newsIcon from '@salesforce/resourceUrl/newsIcon';
import homeIcon from '@salesforce/resourceUrl/homeIcon';

export default class Nks_SurveyCommunity extends LightningElement {
    @api url;
    news = newsIcon;
    home = homeIcon;

    openSurvey() {
        try {
            window.open(this.url);
        } catch (error) {
            console.log(error);
        }
    }
}
