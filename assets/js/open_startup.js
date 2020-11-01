import { _adapters, Chart, LineController, Line, BarController, Rectangle, Point, LinearScale, Tooltip, TimeScale, Legend, Title } from "chart.js"
import { ru } from 'date-fns/locale'
import dateAdatper from './chart_date_fns';

Chart.register(LineController, Line, BarController, Rectangle, Point, LinearScale, TimeScale, Tooltip, Legend, Title)
_adapters._date.override(dateAdatper);

export default {
  incomes() { return JSON.parse(this.el.dataset.incomes) },
  expenses() { return JSON.parse(this.el.dataset.expenses) },
  profits() { return JSON.parse(this.el.dataset.profits) },
  createIncomeExpensesChart() {

    const ctx = document.getElementById('data-incomes-expenses');
    const formattedIncomes = this.incomes().map((i) => {
      return {
        x: i.date,
        y: i.amount,
        description: i.description,
      }
    });
    const formattedExpenses = this.expenses().map((e) => {
      return {
        x: e.date,
        y: e.amount,
        description: e.description
      }
    })
    new Chart(ctx, {
      type: 'bar',
      data: {
        datasets: [
          {
            backgroundColor: "rgb(75, 192, 192)",
            maxBarThickness: '20',
            label: 'Поступление',
            data: formattedIncomes
          },
          {
            backgroundColor: "rgb(255, 99, 132)",
            label: 'Расход',
            maxBarThickness: '20',
            data: formattedExpenses
          }
        ]
      },
      options: {
        tooltips: {
          callbacks: {
            title: function () {
              return "";
            },
            label: function (item) {
              const description = item.dataset.data[item.dataIndex].description;
              return ` ${description}: ${item.formattedValue} $`;
            }
          },
          displayColors: false,
        },
        title: {
          display: true,
          text: "Движение средств"
        },
        scales: {
          y: {
            beginAtZero: true,
            suggestedMin: -100,
            suggestedMax: 100,
            offset: true,
          },
          x: {
            type: 'time',
            adapters: {
              date: {
                locale: ru
              }
            },
            time: {
              unit: 'month'
            },
            offset: true,
          },
        },
        responsive: true
      }
    })

  },
  createProfitsTrendChart(){
    const ctx = document.getElementById('data-profits-trend');

    var config = {
      type: 'line',
      data: {
        datasets: [
          {
            fill: false,
            label: 'Ежемесячная прибыль',
            borderColor: "rgb(153, 102, 255)",
            data: this.profits().map((p) => {
              return {
                x: p.date,
                y: p.amount,
                description: p.description
              }
            }),
          },
        ]
      },
      options: {
        title: {
          display: true,
          text: "Ежемесячная прибыль"
        },
        legend: {
          display: false
        },
        responsive: true,
        tooltips: {
          callbacks: {
            title: function () {
              return "";
            },
            label: function (item) {
              return ` ${item.formattedValue} $`;
            }
          },
          displayColors: false,
        },
        hover: {
          mode: 'nearest',
          intersect: true
        },
        scales: {
          x: {
            display: true,
            adapters: {
              date: {
                locale: ru
              }
            },
            type: 'time',
            time: {
              unit: 'month'
            },
            offset: true
          },
          y: {
            display: true,
            scaleLabel: {
              display: true,
              labelString: 'Сумма'
            },
            suggestedMin: -100,
            suggestedMax: 100,
            beginAtZero: true,
          }
        }
      }
    };
    new Chart(ctx, config)
  },

  mounted(){
    this.createIncomeExpensesChart()
    this.createProfitsTrendChart()
  }
}