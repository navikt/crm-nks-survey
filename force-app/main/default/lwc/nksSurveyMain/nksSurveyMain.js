import { LightningElement, track } from 'lwc';
import createSurveyInvitation from '@salesforce/apex/NKS_SurveyController.createSurveyInvitation';
import newsIcon from '@salesforce/resourceUrl/newsIcon';
import homeIcon from '@salesforce/resourceUrl/homeIcon';

export default class Nks_SurveyCommunity extends LightningElement {
    @track error;
    @track result;
    news = newsIcon;
    home = homeIcon;

    openSurvey() {
        createSurveyInvitation()
            .then((returnedResult) => {
                this.result = returnedResult;
                let obj = JSON.parse(JSON.stringify(this.result));

                if (obj.error === true) {
                    console.log(obj.res);
                }
                if (obj.error === false) {
                    console.log(obj.res);
                    window.open(obj.res);
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.result = error;
                this.error = undefined;
            });
    }
}
