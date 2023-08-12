package main

import (
	"context"
	"log"
	"os"
	"sync"
	"time"

	"github.com/camunda-cloud/zeebe/clients/go/pkg/entities"
	"github.com/camunda-cloud/zeebe/clients/go/pkg/worker"
	"github.com/camunda-cloud/zeebe/clients/go/pkg/zbc"
)

const ZeebeAddr = "0.0.0.0:26500"

// var readyClose = make(chan struct{})

func main() {
	gatewayAddr := os.Getenv("ZEEBE_ADDRESS")
	plainText := false

	if gatewayAddr == "" {
		gatewayAddr = ZeebeAddr
		plainText = true
	}

	plainText = true

	zbClient, err := zbc.NewClient(&zbc.ClientConfig{
		GatewayAddress:         gatewayAddr,
		UsePlaintextConnection: plainText,
	})

	if err != nil {
		panic(err)
	}

	// jobWorker := zbClient.NewJobWorker().JobType("charge-card").Handler(handleJob).Open()

	// <-readyClose
	// jobWorker.Close()
	// jobWorker.AwaitClose()

	// https://github.com/camunda/zeebe/blob/e3acb70a8cfd3ee64ccb8a7f2f679b7534fbee4e/clients/go/pkg/zbc/oauthCredentialsProvider_test.go#L694
	// maybe add some signal handler here to gracefully stop the workers

	var wg sync.WaitGroup
	wg.Add(1)
	_ = zbClient.NewJobWorker().JobType("charge-card").Handler(handleJob).Open()
	wg.Wait()
}

func handleJob(client worker.JobClient, job entities.Job) {
	time.Sleep(10 * time.Second)

	jobKey := job.GetKey()

	variables, err := job.GetVariablesAsMap()
	if err != nil {
		// failed to handle job as we require the variables
		failJob(client, job)
		return
	}

	// log.Printf("variables %v\n", variables)
	for key, value := range variables {
		log.Printf("variable %v: %v\n", key, value)
	}

	request, err := client.NewCompleteJobCommand().JobKey(jobKey).VariablesFromMap(variables)
	if err != nil {
		// failed to set the updated variables
		failJob(client, job)
		return
	}

	log.Println("Complete job", jobKey, "of type", job.Type)

	ctx := context.Background()
	_, err = request.Send(ctx)
	if err != nil {
		panic(err)
	}

	log.Println("Successfully completed job")
	// close(readyClose)
}

func failJob(client worker.JobClient, job entities.Job) {
	log.Println("Failed to complete job", job.GetKey())

	ctx := context.Background()
	_, err := client.NewFailJobCommand().JobKey(job.GetKey()).Retries(job.Retries - 1).Send(ctx)
	if err != nil {
		panic(err)
	}
}
