import * as zb from "zeebe-node";
const { ZBClient } = zb;

// configuration from env variables - none needed if using localhost
const client = new ZBClient('http://localhost:26500');

client.createWorker({
  taskType: "charge-card",
  taskHandler: async (job) => {
    // Put your business logic here

    // Get a process variable
    // const amount = job.variables.get("amount");
    // const item = job.variables.get("item");

    // console.log(
    //   `Charging credit card with an amount of ${amount}€ for the item '${item}'...`
    // );


    console.log("variables", job.variables);

    // complete the task
    return job.complete();

    // dummy for some external rest api call

    // const requestOptions = {
    //     method: 'GET',
    //     redirect: 'follow',
    //     rejectUnauthorised: false,
    //     requestCert : true,
    //     agent : false
    // };
    //
    // const response = await fetch("https://localhost:8082/api/foo/", requestOptions);
    // const Results = await response.json();
    // console.log("New Results:" + Results);
    //
    // return job.complete({ Results, winningDate });
  },
});
