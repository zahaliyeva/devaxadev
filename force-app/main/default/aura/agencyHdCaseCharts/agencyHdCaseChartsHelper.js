({
    createChartCasesByStatus : function (component) {
        var chartCanvas = component.find("chart").getElement();
        //console.log(chartCanvas);
        var action = component.get("c.getCasesByStatus");
      
        var params = this.retrieveFilters(component);
        action.setParams(params);

        action.setCallback(this, function(response) {

            var state = response.getState();
            //console.log ('state: '+state);
            if (state === "SUCCESS") {
                //console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
                var reportResultData = response.getReturnValue();
                var isCallSuccess = response.getReturnValue()["isSuccess"];
                var chartData = [];
                var chartLabels = [];
                var totCases = 0;
                if (isCallSuccess)
                {                       
                    for(var i=0; i < (reportResultData.values.queryResults.length); i++){
                        //Chart.js data
                        var tempLabel = ''+reportResultData.values.queryResults[i].label;
                        chartLabels.push(tempLabel);
                        var tempValue = ''+reportResultData.values.queryResults[i].value;
                        chartData.push(tempValue);
                        totCases = totCases + parseInt(tempValue);
                    }                    
                }else
                {
                    chartData.push('1');
                    chartLabels.push('Nessun dato trovato');

                }
                Chart.pluginService.register({
                    beforeDraw: function (chart) {
                        if (chart.config.options.elements.center) {
                            //Get ctx from string
                            var ctx = chart.chart.ctx;
                            
                            //Get options from the center object in options
                            var centerConfig = chart.config.options.elements.center;
                            var fontStyle = centerConfig.fontStyle || 'Arial';
                            var txt = centerConfig.text;
                            var color = centerConfig.color || '#000';
                            var sidePadding = centerConfig.sidePadding || 20;
                            var sidePaddingCalculated = (sidePadding/100) * (chart.innerRadius * 2)
                            
                            //Start with a base font of 30px
                            ctx.font = "30px " + fontStyle;
                            
                                    //Get the width of the string and also the width of the element minus 10 to give it 5px side padding
                            var stringWidth = ctx.measureText(txt).width;
                            var elementWidth = (chart.innerRadius * 2) - sidePaddingCalculated;

                            // Find out how much the font can grow in width.
                            var widthRatio = elementWidth / stringWidth;
                            var newFontSize = Math.floor(30 * widthRatio);
                            var elementHeight = (chart.innerRadius * 2);

                            // Pick a new font size so it will not be larger than the height of label.
                            var fontSizeToUse = Math.min(newFontSize, elementHeight);

                            //Set font settings to draw it correctly.
                            ctx.textAlign = 'center';
                            ctx.textBaseline = 'middle';
                            var centerX = ((chart.chartArea.left + chart.chartArea.right) / 2);
                            var centerY = ((chart.chartArea.top + chart.chartArea.bottom) / 2);
                            ctx.font = fontSizeToUse+"px " + fontStyle;
                            ctx.fillStyle = color;
                            
                            //Draw text in center
                            ctx.fillText(txt, centerX, centerY);
                        }
                    }
                });
                //Construct chart
                var chart = new Chart(chartCanvas,{
                    type: 'doughnut',
                    data: {
                        labels: chartLabels,
                        datasets: [
                            {
                                label: "Case",
                                data: chartData,
                                backgroundColor: [
                                    "#52BE80",
                                    "#76D7C4",
                                    "#1E8449",
                                    "#2ECC71",
                                    "#FFB74D",
                                    "#E67E22",
                                    "#F8C471",
                                    "#3498DB",
                                    "#00BCD4",
                                    "#D32F2F",
                                    "#82E0AA",
                                    "#AFB42B",
                                    //MOSCATELLI_M 25/10/2018: NMA Business -- START
                                    "#fbc314",
                                    "#e50c5a"
                                    //MOSCATELLI_M 25/10/2018: NMA Business -- END
                                ]
                            }
                        ]
                    },
                    options: {
                        maintainAspectRatio: false,
                        hover: { animationDuration: 400
                        },
                        legend: {
                            display: true,
                            position:'right',
                            reverse:false,

                            layout: {
                                padding: 60,
                            },
                            onClick: function(e, legendItem) {
                                //STOPPING CLICKS
                                /*debugger;
                                console.log(legendItem);
                                var index = legendItem.index;
                                var ci = this.chart;
                                console.log(ci);
                                var meta = ci.getDatasetMeta(index);

                                // See controller.isDatasetVisible comment
                                meta.hidden = meta.hidden === null? !ci.data.datasets[index].hidden : null;

                                // We hid a dataset ... rerender the chart
                                ci.update();
                                console.log('spam');*/
                            }
                        },
                        elements: {
                            center: {
                                text: totCases,
                                color: '#000000', // Default is #000000
                                fontStyle: 'Arial', // Default is Arial
                                sidePadding: 40 // Defualt is 20 (as a percentage)
                            }
                        }
                    }
                });
                //console.log(chart);
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message on createReport: " +
                                    //errors[0].message);
                    }
                } else {
                   // console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    createChartCasesByTime : function (component) {
        var chartCanvas = component.find("chartTimes").getElement();
        //console.log(chartCanvas);
        var action = component.get("c.getCasesResolutionTime");
      
        var params = this.retrieveFilters(component);
        action.setParams(params);

        action.setCallback(this, function(response) {

            var state = response.getState();
            //console.log ('state: '+state);
            if (state === "SUCCESS") {
                //console.log("Response " + JSON.stringify(response.getReturnValue(), null, 4));
                var reportResultData = response.getReturnValue();
                var isCallSuccess = response.getReturnValue()["isSuccess"];
                var chartDataflSupportTime = [];
                var chartLabelsflSupportTime = [];
                var chartDatatotalTime = [];
                var chartLabelstotalTime = [];
                var chartDatatotalTimeGlobal = [];
                var chartLabelstotalTimeGlobal = [];
                var maxHeight = 2;
                if (isCallSuccess)
                {
                    if(reportResultData.values.flSupportTime!= null)
                    {
                        chartDataflSupportTime.push(''+reportResultData.values.flSupportTime.value);
                        chartLabelsflSupportTime.push(''+reportResultData.values.flSupportTime.label);
                        var tempHeight = (parseInt(''+reportResultData.values.flSupportTime.value, 10));
                        if ((tempHeight+2)>maxHeight) maxHeight = tempHeight+2;
                    }
                    else
                    {
                        chartDataflSupportTime.push('0');
                        chartLabelsflSupportTime.push('Nessun dato trovato');
                    } 
                    if(reportResultData.values.totalTime!= null)
                    {
                        chartDatatotalTime.push(''+reportResultData.values.totalTime.value);
                        chartLabelstotalTime.push(''+reportResultData.values.totalTime.label);
                        var tempHeight = (parseInt(''+reportResultData.values.totalTime.value, 10));
                        if ((tempHeight+2)>maxHeight) maxHeight = tempHeight+2;
                    }
                    else
                    {
                        chartDatatotalTime.push('0');
                        chartLabelstotalTime.push('Nessun dato trovato');                        
                    }
                    if(reportResultData.values.totalTimeGlobal!= null)
                    {
                        chartDatatotalTimeGlobal.push(reportResultData.values.totalTimeGlobal.value);
                        chartLabelstotalTimeGlobal.push(''+reportResultData.values.totalTimeGlobal.label);
                        var tempHeight = (parseInt(''+reportResultData.values.totalTimeGlobal.value, 10));
                        if ((tempHeight+2)>maxHeight) maxHeight = tempHeight+2;
                    }
                    else
                    {
                        chartDatatotalTimeGlobal.push('0');
                        chartLabelstotalTimeGlobal.push('Nessun dato trovato');                          
                    }                                                                
                }else
                {
                    
                    chartDataflSupportTime.push('0');
                    chartLabelsflSupportTime.push('Nessun dato trovato');
                    chartDatatotalTime.push('0');
                    chartLabelstotalTime.push('Nessun dato trovato');
                    chartDatatotalTimeGlobal.push('0');
                    chartLabelstotalTimeGlobal.push('Nessun dato trovato');
                        
                }
                //console.log ("variables: "+chartDataflSupportTime+chartDatatotalTime+chartDatatotalTimeGlobal);
                //Construct chart
                var chart = new Chart(chartCanvas,{
                    type: 'bar',
                    data: {
                        labels: [],
                        datasets: [
                            {
                                label: chartLabelsflSupportTime[0],
                                data: chartDataflSupportTime,
                                backgroundColor: [
                                    "#52BE80",
                                    "#76D7C4",
                                    "#1E8449",
                                    "#2ECC71",
                                    "#FFB74D",
                                    "#E67E22",
                                    "#F8C471",
                                    "#3498DB",
                                    "#00BCD4",
                                    "#D32F2F",
                                    "#82E0AA",
                                    "#AFB42B"
                                ]
                            },
                            {
                                label: chartLabelstotalTime[0],
                                data: chartDatatotalTime,
                                backgroundColor: [
                                    "#FFB74D"
                                ]
                            }
                        ]
                    },
                    options: {
                        maintainAspectRatio: false,
                        hover: { animationDuration: 400
                        },
                        legend: {
                            display: true,
                            position:'right',
                            reverse:false,
                            onClick: function(e, legendItem) {
                                //STOPPING CLICKS
                            },
                            layout: {
                                padding: 60,
                            }
                        },
                       scales: {
                            yAxes: [{
                                display: true,
                                ticks: {
                                    beginAtZero: true,
                                    min: 0,
                                    max: maxHeight
                                }
                            }]
                        }/*,
                        annotation: {
                          annotations: [{
                            type: 'line',
                            mode: 'horizontal',
                            scaleID: 'y-axis-0',
                            value: chartDatatotalTime[0],
                            borderColor: 'rgb(100, 100, 100)',
                            borderWidth: 10,
                            label: {
                              enabled: true,
                              content: chartLabelstotalTimeGlobal[0]
                            }
                          }]
                        }*/
                    }
                });
                //console.log(chart);
                var linearScaleDefault = Chart.scaleService.getScaleDefaults('linear');
                //console.log(linearScaleDefault);

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message on createReport: " +
                                //    errors[0].message);
                    }
                } else {
                    //console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    retrieveFilters : function (component) {
        var queryParameters = {"selectedYear":component.get("v.selectedYear"),
                        "selectedMonth":component.get("v.selectedMonth"),
                        "selectedWeek":component.get("v.selectedWeek"),
                        "selectedLob":component.get("v.selectedLob"),
                        "selectedCategory":component.get("v.selectedCategory"),
                        "selectedSubCategory":component.get("v.selectedSubCategory"),
                        "selectedOwnership":component.get("v.selectedOwnership")};
        return queryParameters;
    }

})