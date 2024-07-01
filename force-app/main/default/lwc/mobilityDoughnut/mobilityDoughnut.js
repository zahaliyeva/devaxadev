import { LightningElement, track, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import ChartJs from "@salesforce/resourceUrl/mobilityChartJs";


export default class MobilityDoughnut extends LightningElement {
  @api width = "100px";
  
  @api height = "100px";

	@api setData = null;
  @api isForLead;
	handlerChart = null;

	constructor() {
		super();
	}

	proxyData(data) {
		return JSON.parse(JSON.stringify(data));
	}

	inizializeComponent() {
    let ctx = this.template.querySelector("canvas").getContext("2d");
    

    let config;
    if (this.isForLead) {
    	
      config = { //configurazione per lead
        type: "doughnut",
        options: {
          animation: {
            animateScale: true,
            animateRotate: true,
          },
          legend: {
            display: false,
          },
          tooltips: {
            displayColors: false,
            
            enabled: true,
            callbacks: {
              label: function (tooltipItem, data) {
                var arr =
                  data.datasets[tooltipItem.datasetIndex].labels[
                    tooltipItem.index
                  ].split("\n");
                if (!arr[arr.length - 1]) {
                  arr.pop();
                }
                return arr;
              },
            },
          },
          responsive: false,
          cutoutPercentage: 60,
        },
      };
      if(this.setData.noData){
        config.options.tooltips.enabled = false;
        
        
      }
    }
	else{ //configurazione generica
		config = {
			type: 'doughnut',
			options: {
				animation: {
					animateScale: true,
					animateRotate: true
				},
				legend: {
					display: false
				},
				tooltips: {
					enabled: true,
				},
				responsive: false,
				cutoutPercentage: 70
			}
		};
	}

		if (this.setData) {
			config.data = {
				labels: this.setData.labels,
        datasets: [this.proxyData(this.setData)],
      };
		}

		this.handlerChart = new Chart(ctx, config);
	}

	connectedCallback() {
    loadScript(this, ChartJs)
      .then(() => {
			this.inizializeComponent();
      })
      .catch((err) => {
			console.log(`loadScript ${ChartJs} failed!`);
			console.log(err);
      });
	}

	renderedCallback() {
		if (this.handlerChart) {
      this.handlerChart.config.data.datasets[0].data = [
        this.percent,
        this.percentEmpty,
      ];

      this.handlerChart.update();
    }
		}

}